#
# Feature allowing to print out the text in a standard way
#
# Author: Benoît Duhoux
# Date: 07/03/2018
#
module PrintingStandard
	
	# Specify the class for which this feature is defined 
	adapt_classes :Printer

	def printing(text)
		puts text
	end

end