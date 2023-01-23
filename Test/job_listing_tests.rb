
#
# Created by Canaan Porter
# Written 28 September 2022
#

require 'minitest/autorun'
require_relative '../Model/job_scraper'
require_relative '../global_constants.rb'

class TestJobListing < MiniTest::Test
    
    # test for the constructor
    def test_constructor
        site_url = GlobalConstants::BASE_PAGE_PATH
        request_base = GlobalConstants::BASE_REQUEST_PATH
        
        # creating a JobListing Object
        assert JobListing.new(site_url, request_base, {"data" => "field"}) != nil
    end

    def test_to_hash
        site_url = GlobalConstants::BASE_PAGE_PATH
        request_base = GlobalConstants::BASE_REQUEST_PATH
        
        # creating a JobListing Object
        job1 = JobListing.new(site_url, request_base, {"data" => "field"})
        job1_hash = job1.to_hash
        # checking if the object is a hash
        assert job1_hash.class == Hash
    end

end