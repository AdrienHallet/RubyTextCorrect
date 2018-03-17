class FeatureSelector
  attr_accessor :feature, :klass
  attr_accessor :next, :previous

  def initialize(feature, klass)
    @next = nil
    @previous = nil
    @feature = Object.const_get(feature)
    adapter = @feature.get_adapter.to_s #Local variable, can we remove it ?
    raise "#{@feature} does not adapt from #{klass}" unless adapter.eql? klass
  end

end