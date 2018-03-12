#
# Feature allowing to define the set of valid characters in French
#
# Author: Benoît Duhoux
# Date: 07/03/2018
#
module FrenchCharacters
	
	# Specify the class for which this feature is defined 
	adapt_classes :Text

	def authorized_characters
		set_chars = proceed()
		return set_chars << "àâçèéêîôùû"
	end

end