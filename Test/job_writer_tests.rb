
#
# Created by Canaan Porter
# Written 28 September 2022
#

require 'minitest/autorun'
require_relative '../Controller/job_writer'
require_relative '../Model/job_scraper'
require_relative '../global_constants.rb'

# these tests MUST be run in the main directory (team4-project3) in order for file creation to work

class TestJobWriter < MiniTest::Test
    # testing the constructor
    def test_constructor
        jobList = []
        assert JobWriter.new(jobList) != nil
    end

    def test_sort_jobs_by_date
        site_url = GlobalConstants::BASE_PAGE_PATH
        request_base = GlobalConstants::BASE_REQUEST_PATH
        request_path = GlobalConstants::QUERY_REQUEST_PATH
        min_query_size = GlobalConstants::MIN_QUERY_SIZE
        max_query_size = GlobalConstants::MAX_QUERY_SIZE

        # getting a small job list to test with
        scraper = JobScraper.new(site_url, request_base, request_path, min_query_size, max_query_size)
        listings = scraper.query(num_jobs: 10)
        (0...listings.size).each do |i|
            listings[i].scrape!
        end
        writer = JobWriter.new(listings)
        # setting todays date as the date
        writer.save_date
        writer.update_date
        writer.sort_jobs_by_date!
        
        writer.jobs_new.each {|job|
            puts Date.parse(job.to_hash['startDate'])
            puts Date.today
            puts
            assert Date.parse(job.to_hash['startDate']) >= Date.today
        }

        writer.jobs_old.each {|job|
            assert Date.parse(job.to_hash['startDate']) < Date.today
        }
    end
end