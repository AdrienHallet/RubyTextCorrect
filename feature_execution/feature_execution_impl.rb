require 'singleton'

Dir["#{File.dirname(__FILE__)}/../text_correctness_app/features/*.rb"].each { |file| require file }
Dir["#{File.dirname(__FILE__)}/../text_correctness_app/skeleton/*.rb"].each { |file| require file }

class FeatureExecutionImpl

	include Singleton

	def alter(action, feature_selector)
		# TODO To be completed
	end

	# TODO To be completed if needed
	
end