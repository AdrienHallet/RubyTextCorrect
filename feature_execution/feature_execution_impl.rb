require 'singleton'
require_relative 'class_adapter.rb'

Dir["#{File.dirname(__FILE__)}/../text_correctness_app/features/*.rb"].each { |file| require file }
Dir["#{File.dirname(__FILE__)}/../text_correctness_app/skeleton/*.rb"].each { |file| require file }

class FeatureExecutionImpl
  include Singleton

  def alter(action, feature_selector)
    if action == :adapt
      adapter = Object.const_get(feature_selector.feature.get_adapter)
      proceed_body = proc do
        key = feature_selector.feature.get_adapter.to_s
        callname =  caller[0][/`.*'/][1..-2] #magic
        res = $history[key+callname]
        unless defined? $access
          $access = Hash.new(1)
        end


        if res[-$access[callname]].to_s.eql? 'HEAD'
          $access[callname] = 1
        end

        node = res[-$access[callname]]
        $access[callname] += 1
        meth = node.bind(self)
        meth.call
      end
      adapter.send(:define_method, :proceed, &proceed_body)
      methods = feature_selector.feature.instance_methods
      methods.each do |method_name|
        if method_name.to_s.eql? 'proceed'
          next
        end

        change_flag = false
        begin
          meth = adapter.instance_method(method_name) # Raise a NameError if the method does not exist

          res = $history[(adapter.to_s) +(method_name.to_s)]
          if res.nil?
            $history[(adapter.to_s) +(method_name.to_s)] = []

            res = $history[(adapter.to_s) +(method_name.to_s)]
            res.push('HEAD')
          end
          res.push(meth)
          if $history_logs[(adapter.to_s)].nil?
            $history_logs[(adapter.to_s)] = []
          end
          change_flag = true
        rescue NameError => e #Todo Remove duplication in conditions
          if $history_logs[(adapter.to_s)].nil?
            $history_logs[(adapter.to_s)] = []
          end


        end
        if change_flag
          feature_selector.instance_variable_set(:@change, true)
        end
        $history_logs[(adapter.to_s)].push(feature_selector)

        method_body = feature_selector.feature.instance_method(method_name)
        adapter.send(:define_method, method_name , method_body)
        end

    elsif action == :unadapt

      adapter = Object.const_get feature_selector.feature.get_adapter
      adapter_methods = adapter.instance_methods
      moduler = feature_selector.feature
      log_index = $history_logs[adapter.to_s].index(feature_selector) #Todo maybe raise error if attempting to remove (already) unadapted module ?
      
      if feature_selector.instance_variable_defined? :@change
        #ToDo
      else
        puts 'DEBUG : cleaning added methods'
        #We did not change any existing method

        added_methods = moduler.instance_methods
        added_methods.each do |current_method|
          if adapter_methods.include? current_method
            puts 'Removing method '+ current_method.to_s
            adapter.send(:remove_method, current_method)
            $history_logs[adapter.to_s].delete_at(log_index)
          else
            puts 'This should not be reached' # Todo remove when debug ends
          end
        end

      end
      puts 'End of procedure'
    end


  end

  # TODO: To be completed if needed

end