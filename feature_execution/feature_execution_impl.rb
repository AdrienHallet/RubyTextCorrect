require 'singleton'
require_relative 'class_adapter.rb'

Dir["#{File.dirname(__FILE__)}/../text_correctness_app/features/*.rb"].each { |file| require file }
Dir["#{File.dirname(__FILE__)}/../text_correctness_app/skeleton/*.rb"].each { |file| require file }

class FeatureExecutionImpl
  include Singleton

  def alter(action, feature_selector)
    thread = Thread.current
    if action == :adapt
      adapter = Object.const_get(feature_selector.feature.get_adapter)
      proceed_body = proc do
        key = feature_selector.feature.get_adapter.to_s
        callname =  caller[0][/`.*'/][1..-2] #magic
        #TODO : Access is not thread-safe, find another way to go back on proceed
        res = thread[:history][key+callname]
        unless defined? thread[:access]
          thread[:access]= Hash.new(1)
        end
        node = res[-thread[:access][callname]]
        thread[:access][callname] += 1
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

          res = thread[:history][(adapter.to_s) +(method_name.to_s)]
          if res.nil?
            thread[:history][(adapter.to_s) +(method_name.to_s)] = []

            res = thread[:history][(adapter.to_s) +(method_name.to_s)]
            res.push('HEAD')
          end
          res.push(meth)
          if thread[:history_logs][(adapter.to_s)+(method_name.to_s)].nil?
            thread[:history_logs][(adapter.to_s)+(method_name.to_s)] = []
          end
          thread[:history_logs][(adapter.to_s)+(method_name.to_s)].push(feature_selector)
          change_flag = true
        rescue NameError => e #Todo Remove duplication in conditions
          if thread[:history_logs][(adapter.to_s)].nil?
            #$history_logs[(adapter.to_s)] = []
          end


        end
        if change_flag
          feature_selector.instance_variable_set(:@change, true)
        end


        method_body = feature_selector.feature.instance_method(method_name)
        adapter.send(:define_method, method_name , method_body)
      end


    elsif action == :unadapt

      adapter = Object.const_get feature_selector.feature.get_adapter
      adapter_methods = adapter.instance_methods
      moduler = feature_selector.feature

      if feature_selector.instance_variable_defined? :@change
        added_methods = moduler.instance_methods
        added_methods.each do |current_method|
          if thread[:history][(adapter.to_s) + (current_method.to_s)].nil?
            adapter.send(:remove_method, current_method)
          else
            position = thread[:history_logs][(adapter.to_s) + (current_method.to_s)].index(feature_selector)
            adapter.send(:remove_method, current_method)
            old_version = thread[:history][(adapter.to_s) + (current_method.to_s)][position+1]
            adapter.send(:define_method, current_method, old_version)
            thread[:history][(adapter.to_s) + (current_method.to_s)].delete_at(position+1)
            thread[:history_logs][(adapter.to_s) + (current_method.to_s)].delete_at(position)
          end
        end
      else
        #We did not change any existing method

        added_methods = moduler.instance_methods
        added_methods.each do |current_method|
          if adapter_methods.include? current_method
            adapter.send(:remove_method, current_method)
          else
            puts 'This should not be reached' # Todo remove when debug ends
          end
        end

      end
      #$history_logs[adapter.to_s].delete_at(log_index)

    end


  end

  # TODO: To be completed if needed

end