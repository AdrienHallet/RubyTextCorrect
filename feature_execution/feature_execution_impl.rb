require 'singleton'
require_relative 'class_adapter.rb'
require 'thread'

Dir["#{File.dirname(__FILE__)}/../text_correctness_app/features/*.rb"].each { |file| require file }
Dir["#{File.dirname(__FILE__)}/../text_correctness_app/skeleton/*.rb"].each { |file| require file }

class FeatureExecutionImpl
  include Singleton


  def alter(action, feature_selector)
    adapter = Object.const_get(feature_selector.feature.get_adapter)
    if action == :adapt
      proceed_body = proc do
      unless self.instance_variable_defined?(:@last_called)
        self.instance_variable_set(:@last_called, Hash.new(nil))
      end
      callname = caller_locations(1,1)[0].label
      candidate = nil
      id = nil
        available_methods = self.class.instance_methods(false)
        available_methods.reverse_each do |method|
          if method.to_s.start_with?(callname)
            id = method.to_s.sub! callname, ''
            lc = self.instance_variable_get(:@last_called)[callname]
            if (id.eql? '') || (lc.nil?) || (id < lc)
              candidate = method
              break
            end
          end
        end
        if candidate.nil?
          p 'did not find :' + callname.to_s
        else
          if id == ''
            map = self.instance_variable_get(:@last_called)
            map[callname] = nil
            self.instance_variable_set(:@last_called, map)
          else
            map = self.instance_variable_get(:@last_called)
            map[callname] = id
            self.instance_variable_set(:@last_called, map)
          end
          self.method(candidate).call

        end
      end
      adapter.send(:define_method, :proceed, &proceed_body)

      methods = feature_selector.feature.instance_methods
      methods.each do |method_name|
        if method_name.to_s.eql? 'proceed'
          next
        end

        adapter_methods = adapter.instance_methods.sort
        if adapter_methods.include? method_name
          to_move = adapter.instance_method(method_name)
          adapter.send(:remove_method, method_name)
          id = 1
          while adapter_methods.include? (method_name.to_s + id.to_s).to_sym
            id += 1
          end
          new_name = (method_name.to_s + id.to_s).to_sym
          adapter.send(:define_method, new_name, to_move)
          feature_selector.old_version[method_name.to_s] = id
        end
        method_body = feature_selector.feature.instance_method(method_name)
        adapter.send(:define_method, method_name , method_body)

      end
    elsif action == :unadapt
      module_methods = feature_selector.feature.instance_methods(false)
      module_methods.each do |method|
        version = feature_selector.old_version[method.to_s]
        if version.nil?
          #No older version, just remove
          adapter.send(:remove_method, method)
        else
          adapter_methods = adapter.instance_methods.sort
          old_name = (method.to_s + version.to_s).to_sym
          if adapter_methods.include? old_name
            old_method = adapter.instance_method(old_name)
            adapter.send(:remove_method, old_name)
            adapter.send(:define_method, method, old_method)
          else
            raise 'Unhandled exception'
          end
        end
      end
    end
  end
end