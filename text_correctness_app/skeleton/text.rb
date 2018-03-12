#
# Class representing a text
#
# Author: Benoît Duhoux
# Date: 07/03/2018
#
class Text

	attr_reader :text

	def initialize(text)
		@text = text
	end

	# Default behaviour
	def correct_text
		@text
	end

end