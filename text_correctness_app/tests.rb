#!/usr/bin/env ruby

#
# Script to test the application
#
# Author: Benoît Duhoux
# Date: 07/03/2018
#

require 'minitest/autorun'

require_relative 'skeleton/text.rb'
require_relative 'skeleton/printer.rb'
require_relative '../feature_execution/feature_selector'
require_relative '../feature_execution/feature_execution_impl'

class TestsFeatureSelectionImpl < Minitest::Test
	
	def setup
		@FEATURES_TEXT = {
			:clean => FeatureSelector.new('Clean', 'Text'),
			:english => FeatureSelector.new('EnglishCharacters', 'Text'),
			:french => FeatureSelector.new('FrenchCharacters', 'Text'),
			:trim => FeatureSelector.new('Trim', 'Text'),
			:capitalize => FeatureSelector.new('Capitalize', 'Text'),
			:punctuation => FeatureSelector.new('Punctuation', 'Text'),
			:printing_all_chars => FeatureSelector.new('PrintingAllChars', 'Printer'),
			:printing_standard => FeatureSelector.new('PrintingStandard', 'Printer')
		}
	end

	def correct_text(text)
		t = Text.new(text)
		Printer.instance.printing(t.correct_text)
	end

	def test_one_adaptation
		FeatureExecutionImpl.instance.alter(:adapt, @FEATURES_TEXT[:printing_standard])

		exp = "Hello Ruby!\n"
		assert_output(exp, nil) do
			Printer.instance.printing("Hello Ruby!")
		end

		FeatureExecutionImpl.instance.alter(:unadapt, @FEATURES_TEXT[:printing_standard])
	end

	def test_one_deactivation
		FeatureExecutionImpl.instance.alter(:adapt, @FEATURES_TEXT[:printing_standard])
		FeatureExecutionImpl.instance.alter(:unadapt, @FEATURES_TEXT[:printing_standard])

		refute(Printer.instance_methods.include?(:printing))
	end

	def test_multiple_adaptations
		FeatureExecutionImpl.instance.alter(:adapt, @FEATURES_TEXT[:printing_standard])
		FeatureExecutionImpl.instance.alter(:adapt, @FEATURES_TEXT[:printing_all_chars])

		exp = "\"Hello Ruby!\"\n"
		assert_output(exp, nil) do
			Printer.instance.printing("Hello Ruby!")
		end

		FeatureExecutionImpl.instance.alter(:unadapt, @FEATURES_TEXT[:printing_all_chars])
		FeatureExecutionImpl.instance.alter(:unadapt, @FEATURES_TEXT[:printing_standard])
	end

	def test_multiple_deactivations
		FeatureExecutionImpl.instance.alter(:adapt, @FEATURES_TEXT[:printing_standard])
		FeatureExecutionImpl.instance.alter(:adapt, @FEATURES_TEXT[:printing_all_chars])
		FeatureExecutionImpl.instance.alter(:unadapt, @FEATURES_TEXT[:printing_all_chars])
		FeatureExecutionImpl.instance.alter(:unadapt, @FEATURES_TEXT[:printing_standard])

		refute(Printer.instance_methods.include?(:printing))
	end

	def test_proceed_1
		FeatureExecutionImpl.instance.alter(:adapt, @FEATURES_TEXT[:clean])
		FeatureExecutionImpl.instance.alter(:adapt, @FEATURES_TEXT[:english])
		
		assert_equal("Hello Ruby!", Text.new('Hello Ruby!').correct_text)
		assert_equal("Hello Ruby!", Text.new('Hello Rubéy!').correct_text)

		FeatureExecutionImpl.instance.alter(:unadapt, @FEATURES_TEXT[:english])
		FeatureExecutionImpl.instance.alter(:unadapt, @FEATURES_TEXT[:clean])
	end

	def test_proceed_2
		FeatureExecutionImpl.instance.alter(:adapt, @FEATURES_TEXT[:clean])
		FeatureExecutionImpl.instance.alter(:adapt, @FEATURES_TEXT[:english])
		FeatureExecutionImpl.instance.alter(:adapt, @FEATURES_TEXT[:trim])
		FeatureExecutionImpl.instance.alter(:adapt, @FEATURES_TEXT[:capitalize])
		FeatureExecutionImpl.instance.alter(:adapt, @FEATURES_TEXT[:punctuation])
		
		t1 = Text.new('	hello newcomers	 in Ruby, could you corréect me ?')
		t1_expected = 'Hello newcomers in Ruby, could you correct me ?'
		assert_equal(t1_expected, t1.correct_text)

		t2 = Text.new('		the dot at the end is 	 probably added automatically		')
		t2_expected = 'The dot at the end is probably added automatically.'
		assert_equal(t2_expected, t2.correct_text)

		FeatureExecutionImpl.instance.alter(:unadapt, @FEATURES_TEXT[:english])
		FeatureExecutionImpl.instance.alter(:unadapt, @FEATURES_TEXT[:clean])
		FeatureExecutionImpl.instance.alter(:unadapt, @FEATURES_TEXT[:trim])
		FeatureExecutionImpl.instance.alter(:unadapt, @FEATURES_TEXT[:capitalize])
		FeatureExecutionImpl.instance.alter(:unadapt, @FEATURES_TEXT[:punctuation])
	end

	def test_proceed_3
		FeatureExecutionImpl.instance.alter(:adapt, @FEATURES_TEXT[:clean])
		FeatureExecutionImpl.instance.alter(:adapt, @FEATURES_TEXT[:english])
		FeatureExecutionImpl.instance.alter(:adapt, @FEATURES_TEXT[:trim])
		FeatureExecutionImpl.instance.alter(:adapt, @FEATURES_TEXT[:capitalize])
		FeatureExecutionImpl.instance.alter(:adapt, @FEATURES_TEXT[:punctuation])
		FeatureExecutionImpl.instance.alter(:adapt, @FEATURES_TEXT[:french])
		
		t1 = Text.new(' 	pourrais-tu corriger	 ma 		phrase en 	français ?		')
		t1_expected = 'Pourrais-tu corriger ma phrase en français ?'
		assert_equal(t1_expected, t1.correct_text)

		FeatureExecutionImpl.instance.alter(:unadapt, @FEATURES_TEXT[:french])
		FeatureExecutionImpl.instance.alter(:unadapt, @FEATURES_TEXT[:english])
		FeatureExecutionImpl.instance.alter(:unadapt, @FEATURES_TEXT[:clean])
		FeatureExecutionImpl.instance.alter(:unadapt, @FEATURES_TEXT[:trim])
		FeatureExecutionImpl.instance.alter(:unadapt, @FEATURES_TEXT[:capitalize])
		FeatureExecutionImpl.instance.alter(:unadapt, @FEATURES_TEXT[:punctuation])
	end

end