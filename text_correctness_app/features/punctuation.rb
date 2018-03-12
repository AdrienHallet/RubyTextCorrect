#
# Feature allowing to add punctuation to end a text if needed
#
# Author: Benoît Duhoux
# Date: 07/03/2018
#
module Punctuation

	# Specify the class for which this feature is defined 
	adapt_classes :Text

	def correct_text
		text = proceed()

		if not ".?!".include? text.strip()[-1]
			text << '.'
		end

		return text
	end

end
