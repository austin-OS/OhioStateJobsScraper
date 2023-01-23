
#
# Created by Canaan Porter
# Written 28 September 2022
#

require 'minitest/autorun'
require_relative '../Model/job_scraper'
require_relative '../global_constants.rb'

class TestJobScraper < MiniTest::Test
    
    # test for the constructor
    def test_constructor
        site_url = GlobalConstants::BASE_PAGE_PATH
        request_base = GlobalConstants::BASE_REQUEST_PATH
        request_path = GlobalConstants::QUERY_REQUEST_PATH
        min_query_size = GlobalConstants::MIN_QUERY_SIZE
        max_query_size = GlobalConstants::MAX_QUERY_SIZE
        assert JobScraper.new(site_url, request_base, request_path, min_query_size, max_query_size) != nil
    end

end