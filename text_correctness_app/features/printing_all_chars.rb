#
# Feature allowing to print out all the characters of the text
# (even if some characters are unprintable)
#
# Author: Benoît Duhoux
# Date: 07/03/2018
#
module PrintingAllChars
	
	# Specify the class for which this feature is defined 
	adapt_classes :Printer

	def printing(text)
		puts text.dump
	end

end