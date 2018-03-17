require 'singleton'
require_relative 'class_adapter.rb'

Dir["#{File.dirname(__FILE__)}/../text_correctness_app/features/*.rb"].each { |file| require file }
Dir["#{File.dirname(__FILE__)}/../text_correctness_app/skeleton/*.rb"].each { |file| require file }

class FeatureExecutionImpl
  include Singleton

  def alter(action, feature_selector)
    if action == :adapt
      adapter = Object.const_get(feature_selector.feature.get_adapter)
      adapter.instance_variable_set(:@last_called, Hash.new(nil))

      proceed_body = proc do
        myself = self
        unless self.instance_variable_defined?(:@last_called)
          @last_called = Hash.new(nil)
        end
        callname = caller_locations(1,1)[0].label
        available_methods = self.class.instance_methods(false).sort
        candidate = nil
        id = nil
        available_methods.reverse_each do |method|
          if method.to_s.start_with?(callname)
            id = method.to_s.sub! callname, ''
            lc = @last_called[callname]
            boolean = lc.nil?
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
            @last_called[callname] = nil
          else
            @last_called[callname] = id
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
        end

        method_body = feature_selector.feature.instance_method(method_name)
        adapter.send(:define_method, method_name , method_body)

      end


    elsif action == :unadapt


    end


  end

  def integer_convert(string)
    num = string.to_i
    num if num.to_s == string
  end

end