class FeatureSelector

  attr_reader :feature, :klass
  attr_accessor :hash_stacks

  def initialize(feature, klass)
    unless defined? $history
      $history = Hash.new
    end
    @feature = Object.const_get(feature)
    @hash_stacks = Hash.new
    adapter = @feature.get_adapter.to_s
    raise "#{@feature} does not adapt from #{klass}" unless adapter.eql? klass
  end

  def check_existence(feature,klass)
    flag = false

    begin
      meth = klass.method(feature) # Raise a NameError if the method does not exist
    rescue NameError => e
      flag = true
    end

    if flag # if the method exists, we put the old one on a stack
      if not hash_stacks.has_key?(klass)
        hash_stacks[klass] = []
      end
        arr = hash_stacks[klass]
        arr.push(meth)
    end


  end



end