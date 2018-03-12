#
# Feature allowing to capitalize the text if needed
#
# Author: Benoît Duhoux
# Date: 07/03/2018
#
module Capitalize

	# Specify the class for which this feature is defined 
	adapt_classes :Text

	def correct_text
		text = proceed()
		text[0] = text[0].upcase
		return text
	end

end
