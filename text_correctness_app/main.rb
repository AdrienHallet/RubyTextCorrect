#!/usr/bin/env ruby

#
# Script to execute the application without the feature visualizer tool
#
# Author: Benoît Duhoux
# Date: 07/03/2018
#

require_relative 'skeleton/text.rb'
require_relative 'skeleton/printer.rb'
require_relative '../feature_execution/feature_selector'
require_relative '../feature_execution/feature_execution_impl'

FEATURES_TEXT = {
	:clean => FeatureSelector.new('Clean', 'Text'),
	:english => FeatureSelector.new('EnglishCharacters', 'Text'),
	:french => FeatureSelector.new('FrenchCharacters', 'Text'),
	:trim => FeatureSelector.new('Trim', 'Text'),
	:capitalize => FeatureSelector.new('Capitalize', 'Text'),
	:punctuation => FeatureSelector.new('Punctuation', 'Text'),
	:printing_all_chars => FeatureSelector.new('PrintingAllChars', 'Printer'),
	:printing_standard => FeatureSelector.new('PrintingStandard', 'Printer')
}

# Method to:
# 	- create an instance of the class Text
# 	- correct the text
# 	- print out the text
def correct_text(text)
	t = Text.new(text)
	Printer.instance.printing(t.correct_text)
end

FeatureExecutionImpl.instance.alter(:adapt, FEATURES_TEXT[:printing_standard])

# Simple text
puts "Simple text"
correct_text('Hello Ruby!')
puts

# Cleaning text
puts "Cleaning text"
FeatureExecutionImpl.instance.alter(:adapt, FEATURES_TEXT[:clean])
FeatureExecutionImpl.instance.alter(:adapt, FEATURES_TEXT[:english])
puts "English language ..."
correct_text('Hello Ruby!')
correct_text('Hello Rubéy!')
FeatureExecutionImpl.instance.alter(:adapt, FEATURES_TEXT[:french])
puts "French language ..."
correct_text('Bonjour Ruby!')
correct_text('Comment vas-tu Rubéy ?')
FeatureExecutionImpl.instance.alter(:unadapt, FEATURES_TEXT[:french])
FeatureExecutionImpl.instance.alter(:unadapt, FEATURES_TEXT[:english])
FeatureExecutionImpl.instance.alter(:unadapt, FEATURES_TEXT[:clean])
puts 

# Trimming text
puts "Trimming text"
FeatureExecutionImpl.instance.alter(:adapt, FEATURES_TEXT[:trim])
correct_text('Hello Ruby!')
correct_text(' 			Hello   Ruby 				!  ')
FeatureExecutionImpl.instance.alter(:unadapt, FEATURES_TEXT[:trim])
puts 

# Capitalizing text
puts "Capitalizing text"
FeatureExecutionImpl.instance.alter(:adapt, FEATURES_TEXT[:capitalize])
correct_text('Hello Ruby!')
correct_text('hello Ruby!')
FeatureExecutionImpl.instance.alter(:unadapt, FEATURES_TEXT[:capitalize])
puts

# Punctuating text
puts "Punctuating text"
FeatureExecutionImpl.instance.alter(:adapt, FEATURES_TEXT[:punctuation])
correct_text('Hello Ruby')
correct_text('Hello Ruby!')
correct_text('Hello Ruby! ')
correct_text('How are you Rubyists ?')
correct_text('Be kind with Ruby.')
FeatureExecutionImpl.instance.alter(:unadapt, FEATURES_TEXT[:punctuation])
puts

# Correcting text
puts "Correcting text with all features"
FeatureExecutionImpl.instance.alter(:adapt, FEATURES_TEXT[:clean])
FeatureExecutionImpl.instance.alter(:adapt, FEATURES_TEXT[:english])
FeatureExecutionImpl.instance.alter(:adapt, FEATURES_TEXT[:trim])
FeatureExecutionImpl.instance.alter(:adapt, FEATURES_TEXT[:capitalize])
FeatureExecutionImpl.instance.alter(:adapt, FEATURES_TEXT[:punctuation])
correct_text("	hello newcomers	 in Ruby, could you corréect me ?")
correct_text("		the dot at the end is 	 probably added automatically		")

FeatureExecutionImpl.instance.alter(:unadapt, FEATURES_TEXT[:printing_standard])
FeatureExecutionImpl.instance.alter(:adapt, FEATURES_TEXT[:printing_all_chars])
puts "Printing all characters"
Printer.instance.printing("	hello rubyists " << 11 << 11 << "," << 12 << " how are you ?" << 15)
FeatureExecutionImpl.instance.alter(:unadapt, FEATURES_TEXT[:printing_all_chars])
FeatureExecutionImpl.instance.alter(:adapt, FEATURES_TEXT[:printing_standard])

FeatureExecutionImpl.instance.alter(:adapt, FEATURES_TEXT[:french])
correct_text(" 	pourrais-tu corriger	 ma 		phrase en 	français ?		")
FeatureExecutionImpl.instance.alter(:unadapt, FEATURES_TEXT[:french])

FeatureExecutionImpl.instance.alter(:unadapt, FEATURES_TEXT[:english])
FeatureExecutionImpl.instance.alter(:unadapt, FEATURES_TEXT[:clean])
FeatureExecutionImpl.instance.alter(:unadapt, FEATURES_TEXT[:trim])
FeatureExecutionImpl.instance.alter(:unadapt, FEATURES_TEXT[:capitalize])
FeatureExecutionImpl.instance.alter(:unadapt, FEATURES_TEXT[:punctuation])

FeatureExecutionImpl.instance.alter(:unadapt, FEATURES_TEXT[:printing_standard])
