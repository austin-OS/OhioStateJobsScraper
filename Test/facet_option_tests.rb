
#
# Created by Canaan Porter
# Written 28 September 2022
#

require 'minitest/autorun'
require_relative '../Model/facet_option'
require_relative '../global_constants.rb'

class TestFacetOption < MiniTest::Test
    
    # test for the constructor
    def test_constructor
        assert f_option = FacetOption.new(1, "option", 1) != nil
    end

    # testing the FacetOption readers
    def test_ID_reader
        f_option = FacetOption.new(1, "option", 1)
        assert f_option.id == 1
    end

    def test_descriptor_reader
        f_option = FacetOption.new(1, "option", 1)
        assert f_option.descriptor == "option"
    end

    def test_count_reader
        f_option = FacetOption.new(1, "option", 5)
        assert f_option.count == 5
    end

    # testing update count
    def test_update_count
        f_option = FacetOption.new(1, "option", 5)
        f_option.update_count(15)
        assert f_option.count == 15
    end

end