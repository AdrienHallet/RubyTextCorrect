class FeatureSelector
  attr_reader :feature, :klass

  def initialize(feature, klass)
    thread = Thread.current
    unless thread.key?(:history)
      thread[:history] = Hash.new
      thread[:history_logs] = Hash.new
    end
    @feature = Object.const_get(feature)

    adapter = @feature.get_adapter.to_s
    raise "#{@feature} does not adapt from #{klass}" unless adapter.eql? klass
  end



end