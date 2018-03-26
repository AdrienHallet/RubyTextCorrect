#
# Simple injection to allow asking a feature for its adapter
#
# LSINF2335 - Group 4
# Authors:
# Hallet Adrien
# Rucquoy Alexandre
# Date: 29/03/2018
def adapt_classes(klass)
  instance_variable_set(:@adapted_from, klass)
  define_singleton_method(:get_adapter) do
    instance_variable_get :@adapted_from
  end
end