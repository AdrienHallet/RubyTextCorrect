class FeatureSelector

  attr_reader :feature, :klass

  def initialize(feature, klass)
    @feature = Object.const_get(feature)

    adapter = @feature.get_adapter.to_s
    raise "#{@feature} does not adapt from #{klass}" unless adapter.eql? klass

  end

end