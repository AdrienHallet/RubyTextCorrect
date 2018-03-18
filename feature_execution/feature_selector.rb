class FeatureSelector
  attr_reader :feature, :klass
  attr_accessor :old_version

  def initialize(feature, klass)
    thread = Thread.current
    unless thread.key?(:history)
      thread[:history] = Hash.new
      thread[:history_logs] = Hash.new
    end
    @feature = Object.const_get(feature)
    @old_version = Hash.new(nil)

    adapter = @feature.get_adapter.to_s
    raise "#{@feature} does not adapt from #{klass}" unless adapter.eql? klass
  end



end