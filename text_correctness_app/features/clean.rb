#
# Feature allowing to remove unvalid characters of a language
#
# Author: Benoît Duhoux
# Date: 07/03/2018
#
module Clean
	
	# Specify the class for which this feature is defined 
	adapt_classes :Text

	def correct_text
		text = proceed()
		return remove_unknown_chars(text)
	end

	def remove_unknown_chars(text)
		# authorized_characters is a method defined in English- or FrenchCharacters
		return text.tr("^#{authorized_characters}", '')
	end

end