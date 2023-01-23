# frozen_string_literal: true

# Fiddling around with web scraping libraries to see what
# works

require 'mechanize'
require 'json'
require 'debug'

host = 'https://osu.wd1.myworkdayjobs.com'
base_html_url = 'https://osu.wd1.myworkdayjobs.com/en-US/OSUCareers'
base_json_url = 'https://osu.wd1.myworkdayjobs.com/wday/cxs/osu/OSUCareers'
request_dest = '/wday/cxs/osu/OSUCareers/jobs'
request_path = "#{host}#{request_dest}"
request_params = {
  appliedFacets: {},
  limit: 1,
  offset: 0,
  searchText: ''
}
request_headers = {
  'Content-Type' => 'application/json'
}

agent = Mechanize.new
request = agent.post(
  request_path,
  JSON.generate(request_params),
  request_headers
)

result = JSON.parse(request.content)
facets = result['facets']
postings = result['jobPostings']
puts facets
(0...postings.size).each do |i|
  posting_url = "#{base_json_url}#{postings[i]['externalPath']}"
  posting_page = agent.get(posting_url)
  puts posting_page.content
end
