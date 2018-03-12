#
# Feature allowing to define the set of valid characters in English
#
# Author: Benoît Duhoux
# Date: 07/03/2018
#
module EnglishCharacters
	
	# Specify the class for which this feature is defined 
	adapt_classes :Text

	def authorized_characters
		# Printable characters from their decimal values
		authorized_chars = ""
		(32..126).step(1) do 
			|dec_char|
			authorized_chars << dec_char.chr
		end
		return authorized_chars
	end

end