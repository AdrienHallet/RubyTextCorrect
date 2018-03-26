require 'singleton'
require_relative 'class_adapter.rb'

Dir["#{File.dirname(__FILE__)}/../text_correctness_app/features/*.rb"].each { |file| require file }
Dir["#{File.dirname(__FILE__)}/../text_correctness_app/skeleton/*.rb"].each { |file| require file }
#
# Allows the adapt and un-adapt of a FeatureSelector
#
# LSINF2335 - Group 4
# Authors:
# Hallet Adrien
# Rucquoy Alexandre
# Date: 29/03/2018
class FeatureExecutionImpl
  include Singleton

  # alter a feature selector
  # @param action : action to perform (adapt/unadapt)
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
      stack_old(adapter, feature_selector, method_name)
      method_body = feature_selector.feature.instance_method(method_name)
      adapter.send(:define_method, method_name, method_body)
    end
    feature_selector.adapted = true
  end

  # Collision = name already defined.
  # if collision -> stack old version
  # else do nothing
  # @param adapter : the adapter to stack onto
  # @param feature_selector : the current FeatureSelector
  # @param method_name : the method to stack
  def stack_old(adapter, feature_selector, method_name)
    adapter_methods = adapter.instance_methods.sort
    # no need to stack if it is the first definition
    return unless adapter_methods.include? method_name
    to_move = adapter.instance_method(method_name)
    adapter.send(:remove_method, method_name)
    # get the last defined method id
    id = position?adapter_methods, (method_name.to_s + id.to_s).to_sym
    if id.nil? || id == ''
      id = 1 # the method only had one definition
    else
      id = Integer(id)
      id += 1 # the method already has multiple definitions
    end
    new_name = (method_name.to_s + id.to_s).to_sym
    adapter.send(:define_method, new_name, to_move)
    feature_selector.old_version[method_name.to_s] = id
  end

  # un-adapt a feature
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
        # We have an older version, remove it from the stack
        destack_old(adapter, method, id, version)
      end
    end
    feature_selector.adapted = false
  end

  # return the last version of method on the stack
  # if method not found -> @return nil
  # if method has only the original version -> @return ''
  # @param adapter_methods : the methods with the stack inside
  # @param method : the method we are looking for
  def position?(adapter_methods, method)
    adapter_methods.reverse_each do |meth|
      if meth.to_s.start_with?(method.to_s)
        id = meth.to_s.sub! method.to_s, ''
        return id
      end
    end
    nil
  end

  # remove @method from the @adapter, knowing that
  # @method has id @id and should have previous version of
  # @version. If there is a mismatch, then don't restore previous
  # version as it means there is/are newer version(s)
  # @param adapter : the adapter to remove from
  # @param method : the method to destack
  # @param id : the known id of method
  # @param version : the version of method
  def destack_old(adapter, method, id, version)
    adapter_methods = adapter.instance_methods(false).sort
    id = Integer(id || nil)
    if version < id
      # There is a more recent version
      version += 1
    elsif version > id
      version = ''
    end
    old_name = (method.to_s + version.to_s).to_sym
    raise 'Trying to unstack unstacked method' unless adapter_methods.include? old_name
    old_method = adapter.instance_method(old_name)
    # replace the removed method with the older version
    adapter.send(:remove_method, old_name)
    adapter.send(:define_method, method, old_method)
  end

  # send the proceed method on the adapter
  # When sent on an adapter, proceed will call the last un-executed
  # version of the calling method.
  # @param adapter : the adapter
  def send_proceed_on(adapter)
    # define a procedure
    proceed_body = proc do
      unless instance_variable_defined?(:@last_called)
        instance_variable_set(:@last_called, Hash.new(nil))
      end
      # get method calling
      callname = caller_locations(1, 1)[0].label
      candidate = nil
      id = nil
      available_methods = self.class.instance_methods(false)
      # browse stacked methods
      available_methods.reverse_each do |method|
        next unless method.to_s.start_with?(callname)
        id = method.to_s.sub! callname, ''
        lc = instance_variable_get(:@last_called)[callname]
        next unless (id.eql? '') || (lc.nil?) || (id < lc)
        # we found a fitting method
        candidate = method
        break
      end
      raise 'Did not find :' + callname.to_s if candidate.nil?
      # update the access hash
      map = instance_variable_get(:@last_called)
      map[callname] = if id == ''
                        nil
                      else
                        id
                      end
      instance_variable_set(:@last_called, map)
      # call the method
      self.method(candidate).call
    end
    # send the procedure
    adapter.send(:define_method, :proceed, &proceed_body)
  end
end