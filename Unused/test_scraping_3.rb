# frozen_string_literal: true

# Driver code for seeing if the JobScraper class works

require_relative '../Model/job_scraper'
require_relative '../global_constants'

site_url = GlobalConstants::BASE_PAGE_PATH
request_base = GlobalConstants::BASE_REQUEST_PATH
request_path = GlobalConstants::QUERY_REQUEST_PATH
min_query_size = GlobalConstants::MIN_QUERY_SIZE
max_query_size = GlobalConstants::MAX_QUERY_SIZE

scraper = JobScraper.new(site_url, request_base, request_path, min_query_size, max_query_size)

puts 'Filter Options'
scraper.facet_names.each do |facet_name|
  facet = scraper.facet_info(facet_name)
  puts facet.descriptor
  facet.options.each do |facet_option|
    puts "\t#{facet_option.descriptor} (ID: #{facet_option.id}) - #{facet_option.count} Match(es)"
  end
end

puts
puts "Total Jobs: #{scraper.num_matching_jobs}"
puts

puts 'Enter number of jobs to retrieve:'
text_input = gets

listings = scraper.query(num_jobs: text_input.to_i)
(0...listings.size).each do |i|
  puts "[#{i}] #{listings[i].title}"
end
puts

puts 'Enter the index of a job to retrieve additiona info for:'
text_input = gets
listing = listings[text_input.to_i]
puts

puts 'Scraping...'
listing.scrape!
puts

puts 'Description:'
puts listing.description_html
puts

puts 'Related Jobs:'
listing.related_jobs.each do |related_job|
  puts "\t#{related_job.title}"
end
puts

puts 'Other Fields:'
listing.misc_field_names.each do |field_name|
  puts "#{field_name}: #{listing.misc_field_data(field_name)}"
end
puts

puts "Job page accessible at #{listing.page_url}"
