require 'singleton'
require_relative 'class_adapter.rb'

Dir["#{File.dirname(__FILE__)}/../text_correctness_app/features/*.rb"].each { |file| require file }
Dir["#{File.dirname(__FILE__)}/../text_correctness_app/skeleton/*.rb"].each { |file| require file }

class FeatureExecutionImpl
  include Singleton

  def alter(action, feature_selector)
    myobject = feature_selector.feature.get_adapter
    methods = feature_selector.feature.instance_methods
    mymethod = feature_selector.feature.instance_method(:printing)
    Printer.send(:define_method, :printing, mymethod)
    puts 'End'


  end

  # TODO: To be completed if needed

end