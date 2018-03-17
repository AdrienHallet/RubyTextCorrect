require 'singleton'
require_relative 'class_adapter.rb'

Dir["#{File.dirname(__FILE__)}/../text_correctness_app/features/*.rb"].each { |file| require file }
Dir["#{File.dirname(__FILE__)}/../text_correctness_app/skeleton/*.rb"].each { |file| require file }

class FeatureExecutionImpl
  include Singleton

  def alter(action, feature_selector)

    if action == :adapt

      proceed_body = proc do
        #to be completed
      end

      if feature_selector.next == nil
        new_feat = FeatureSelector.new(feature_selector.feature,feature_selector.klass)
        feature_selector.next = new_feat
      end

      new_adapter = Object.const_get(feature_selector.next.feature.get_adapter)
      feature_selector.next.previous = feature_selector
      ancient_methods = feature_selector.feature.instance_methods

      ancient_methods.each do |meth| #copying methods from Old feature selector to the new one
        method_body = feature_selector.feature.instance_method(meth)
        new_adapter.send(:define_method,meth,method_body)
      end

      new_adapter.send(:define_method, :proceed, &proceed_body)


    elsif action == :unadapt

      # Check if a previous definition exists. If yes, replace the content with the ancient one, else erase everything
      adapter = Object.const_get(feature_selector.feature.get_adapter)

      #Erase everything
      methods = feature_selector.feature.instance_methods
      methods.each do |meth|
        adapter.send(:remove_method,meth)
      end

      #If there was something previously, put it back
      unless feature_selector.previous == nil
        previous_methods = feature_selector.previous.feature.instance_methods

        previous_methods.each do |meth|
          method_body = feature_selector.feature.instance_method(meth)
          adapter.send(:define_method,meth,method_body)
        end

      end

      #Dunno if it's the good way to do it or if we should call const_set
      feature_selector.previous = feature_selector.previous.previous



    else raise "Unhandled action : use either :adapt or :unadapt"

    end #endif


  end

  # TODO: To be completed if needed

end