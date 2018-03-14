require 'singleton'
require_relative 'class_adapter.rb'

Dir["#{File.dirname(__FILE__)}/../text_correctness_app/features/*.rb"].each { |file| require file }
Dir["#{File.dirname(__FILE__)}/../text_correctness_app/skeleton/*.rb"].each { |file| require file }

class FeatureExecutionImpl
  include Singleton

  def alter(action, feature_selector)
    myobject = feature_selector.feature.get_adapter
    parsedobject =  Object.const_get myobject
    puts feature_selector.feature
    puts 'Location'
    puts feature_selector.feature.instance_methods.sort
    puts feature_selector.feature.instance_method(:printing)
    puts '********'

    raise 'Unknown method' unless feature_selector.feature.instance_methods.include?(:printing)
    mymethod = feature_selector.feature.instance_method(:printing)
    parsedobject.define_singleton_method(mymethod)


  end

  # TODO: To be completed if needed

end