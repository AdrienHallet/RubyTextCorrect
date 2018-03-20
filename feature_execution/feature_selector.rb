class FeatureSelector
  attr_reader :feature, :klass
  attr_accessor :old_version, :adapted

  def initialize(feature, klass)

    @feature = Object.const_get(feature)
    @old_version = {}
    @adapted = false

    adapter = @feature.get_adapter.to_s
    raise "#{@feature} does not adapt from #{klass}" unless adapter.eql? klass
  end



end