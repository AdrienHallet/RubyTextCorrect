require 'singleton'
require_relative 'class_adapter.rb'

Dir["#{File.dirname(__FILE__)}/../text_correctness_app/features/*.rb"].each { |file| require file }
Dir["#{File.dirname(__FILE__)}/../text_correctness_app/skeleton/*.rb"].each { |file| require file }

class FeatureExecutionImpl
  include Singleton

  # alter a feature selector
  # @param action : action to perform (add/remove)
  # @param feature_selector : feature on which to perform the action
  def alter(action, feature_selector)
    adapter = Object.const_get(feature_selector.feature.get_adapter)
    if action == :adapt
      raise 'AlreadyAdaptedException' if feature_selector.adapted
      adapt(adapter, feature_selector)
    elsif action == :unadapt
      raise 'AlreadyUnadaptedException' unless feature_selector.adapted
      unadapt(adapter, feature_selector)
    end
  end

  # adapt a feature
  # @param adapter : the adapter
  # @param feature_selector : the FeatureSelector
  def adapt(adapter, feature_selector)
    send_proceed_on adapter
    methods = feature_selector.feature.instance_methods
    methods.each do |method_name|
      next if method_name.to_s.eql? 'proceed'
      enqueue_old(adapter, feature_selector, method_name)
      method_body = feature_selector.feature.instance_method(method_name)
      adapter.send(:define_method, method_name, method_body)
    end
    feature_selector.adapted = true
  end

  # Collision = name already defined.
  # if collision -> enqueue old version
  # else do nothing
  # @param adapter
  # @param feature_selector
  # @param method_name
  def enqueue_old(adapter, feature_selector, method_name)
    adapter_methods = adapter.instance_methods.sort
    return unless adapter_methods.include? method_name
    to_move = adapter.instance_method(method_name)
    adapter.send(:remove_method, method_name)
    id = 1
    id += 1 while adapter_methods.include?((method_name.to_s + id.to_s).to_sym)
    new_name = (method_name.to_s + id.to_s).to_sym
    adapter.send(:define_method, new_name, to_move)
    feature_selector.old_version[method_name.to_s] = id
  end

  # unadapt a feature
  # @param adapter : the adapter
  # @param feature_selector : the FeatureSelector
  def unadapt(adapter, feature_selector)
    module_methods = feature_selector.feature.instance_methods(false)
    module_methods.each do |method|
      adapter_methods = adapter.instance_methods(false).sort
      id = position? adapter_methods, method
      version = feature_selector.old_version[method.to_s]

      if version.nil?
        # No older version, just remove
        adapter.send(:remove_method, method)
      else
        # We have an older version, remove it from the queue
        dequeue_old(adapter, method, id, version)
      end
    end
    feature_selector.adapted = false
  end

  def position?(adapter_methods, method)
    adapter_methods.reverse_each do |meth|
      if meth.to_s.start_with?(method.to_s)
        id = meth.to_s.sub! method.to_s, ''
        return id
      end
    end
    nil
  end

  def dequeue_old(adapter, method, id, version)
    adapter_methods = adapter.instance_methods(false).sort
    id = Integer(id || nil)
    if version < id
      version += 1
    elsif version > id
      version = ''
    end

    old_name = (method.to_s + version.to_s).to_sym
    if adapter_methods.include? old_name
      old_method = adapter.instance_method(old_name)
      adapter.send(:remove_method, old_name)
      adapter.send(:define_method, method, old_method)
    else
      raise 'Unhandled exception'
    end
  end

  def send_proceed_on(adapter)
    proceed_body = proc do
      unless instance_variable_defined?(:@last_called)
        instance_variable_set(:@last_called, Hash.new(nil))
      end
      callname = caller_locations(1,1)[0].label
      candidate = nil
      id = nil
      available_methods = self.class.instance_methods(false)
      available_methods.reverse_each do |method|
        if method.to_s.start_with?(callname)
          id = method.to_s.sub! callname, ''
          lc = instance_variable_get(:@last_called)[callname]
          if (id.eql? '') || (lc.nil?) || (id < lc)
            candidate = method
            break
          end
        end
      end
      if candidate.nil?
        p 'did not find :' + callname.to_s
      else
        if id == ''
          map = instance_variable_get(:@last_called)
          map[callname] = nil
          self.instance_variable_set(:@last_called, map)
        else
          map = instance_variable_get(:@last_called)
          map[callname] = id
          instance_variable_set(:@last_called, map)
        end
        self.method(candidate).call

      end
    end
    adapter.send(:define_method, :proceed, &proceed_body)
  end

end
