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
          $history_logs[(adapter.to_s)].push(feature_selector)
        rescue NameError => e #Todo Remove duplication in conditions
          if $history_logs[(adapter.to_s)].nil?
            $history_logs[(adapter.to_s)] = []
          end
          feature_selector.instance_variable_set(:@nochange, true)
          $history_logs[(adapter.to_s)].push(feature_selector)
        end

        method_body = feature_selector.feature.instance_method(method_name)
        adapter.send(:define_method, method_name , method_body)
        end

    elsif action == :unadapt
      puts "Finding dory :"
      array = $history_logs[feature_selector.feature.get_adapter.to_s]
      index = array.index(feature_selector)
      puts index.to_s + ' feature empty ' + feature_selector.instance_variable_get(:@nochange).to_s
      # if index != 0 :> revert
      # if index == 0 :> remove

    end


  end

  # TODO: To be completed if needed

end