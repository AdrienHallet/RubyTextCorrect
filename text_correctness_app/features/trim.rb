#
# Feature allowing to remove unnecessary spaces
# (spaces before the text, space after the text and the justify style)
#
# Author: Benoît Duhoux
# Date: 07/03/2018
#
module Trim

	# Specify the class for which this feature is defined 
	adapt_classes :Text

	def correct_text
		text = proceed()
		return remove_useless_spaces(text)
	end

	def remove_useless_spaces(text)
		return text.strip().gsub(/\s{1,}/, " ")
	end

end
