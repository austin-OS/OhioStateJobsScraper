# frozen_string_literal: true

# This file stores all constant values used in the main
# program

module GlobalConstants
  # The base URL for the pages on the jobs site that
  # return JSON data for POST requests
  BASE_REQUEST_PATH = 'https://osu.wd1.myworkdayjobs.com/wday/cxs/osu/OSUCareers'

  # The path to send POST requests to when scraping for
  # the full list of matching jobs, relative to BASE_
  # REQUEST_PATH
  QUERY_REQUEST_PATH = '/jobs'

  # The lowest number of job listings that can be
  # specified in the request params without resulting in a
  # client error
  MIN_QUERY_SIZE = 1

  # The highest number of job listings that can be
  # specified in the request params without resulting in a
  # client error
  MAX_QUERY_SIZE = 20

  ##
  # The base URL for the pages on the jobs site that
  # return browser-friendly HTML
  BASE_PAGE_PATH = 'https://osu.wd1.myworkdayjobs.com/en-US/OSUCareers'
end
