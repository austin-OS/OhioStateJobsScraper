
#
# Created by Canaan Porter
# Written 28 September 2022
#

require 'minitest/autorun'
require_relative '../Model/facet'
require_relative '../global_constants.rb'

class TestFacet < MiniTest::Test
    # testing that the constructor does not return nil
    def test_constructor
        assert facet = Facet.new("facet1", "user-option") != nil
    end

    # testing the facet class readers
    def test_name_reader
        facet = Facet.new("facet1", "user-option")
        assert facet.name == "facet1"
    end

    def test_descriptor_reader
        facet = Facet.new("facet1", "user-option")
        assert facet.descriptor == "user-option"
    end

    # testing adding facet options
    # adding one option
    def test_add_one_option_test
        facet = Facet.new("facet1", "user-option")
        facet.add_option(1, "facet option", 3)
        assert facet.find_option_by_id(1) != nil
    end

    # adding two options
    def test_add_two_option
        facet = Facet.new("facet1", "user-option")
        facet.add_option(1, "facet option", 3)
        facet.add_option(2, "facet option", 4)
        assert facet.find_option_by_id(1) != nil
        assert facet.find_option_by_id(2) != nil
    end

    # adding many option
    def test_add_many_options
        facet = Facet.new("facet1", "user-option")
        for i in 1...100 do
            facet.add_option(i, "facet option", i)
        end
        for i in 1...100 do
            assert facet.find_option_by_id(i) != nil
        end
    end

    # testing the removal of facet options
    def test_remove_one_option
        facet = Facet.new("facet1", "user-option")
        facet.add_option(1, "facet option", 1)

        #checking that the facet option was added
        assert facet.find_option_by_id(1) != nil

        #removing option with id 1
        facet.remove_option(1)
        assert facet.find_option_by_id(1) == nil
    end

    # removing facet option that doesnt exist (should be nil)
    def test_emove_facet_from_empty
        facet = Facet.new("facet1", "user-option")
        facet.remove_option(1)
        assert facet.find_option_by_id(1) == nil
    end
end