def adapt_classes(klass)
  instance_variable_set(:@adapted_from, klass)
  define_singleton_method(:get_adapter) do
    instance_variable_get :@adapted_from
  end
end