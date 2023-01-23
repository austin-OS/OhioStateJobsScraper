# frozen_string_literal: true

#
# Created by Thomas Li
# Originally Written 24 September 2022
#

require 'mechanize'

##
# This class encapsulates information about a single job
# listing on the OSU Workday site.
#
# Mathematical Model:
#   this = {
#       site_url : string of character,
#       request_base : string of character,
#       external_path : string of character,
#       title : string of character,
#       description_html : string of character,
#       related_jobs : string of JobListing
#       misc_fields : map of string to any type
#   }
#   [The state consists of URL information for accessing
#   the job page and making requests for JSON data, a
#   job title, the job description formatted in HTML as
#   given on the job page, a list of related jobs,and a
#   list of miscellaneuous data fields]
#
# The following methods are available:
#   initialize(
#       site_url,
#       request_base,
#       data_fields
#   )
#   to_hash()
#   record_fields(data_fields)
#   scrape!()
#   page_url()
#   title()
#   description_html()
#   related_jobs()
#   misc_field_names()
#   misc_field_data(field_name)
#
class JobListing
  ##
  # The constructor.
  #
  # @param site_url : string of character
  #   The base URL from which the job listing's external
  #   path can be attached to access the webpage for the
  #   job listing
  # @param request_base : string of character
  #   The base URL from which the job listing's external
  #   path can be attached to make a request from the
  #   job listing's JSON data
  # @param data_fields : map of string of character to
  # any type
  #   The data fields and associated values for the job
  #   listing to initially record
  def initialize(site_url, request_base, data_fields)
    # record URL info
    @site_url = site_url
    @request_base = request_base

    # NOTE: keys to look for when retrieving
    # miscellaneuous data fields from given hash
    @description_field_name = 'jobDescription'
    @related_jobs_field_name = 'similarJobs'
    @title_field_name = 'title'
    @external_path_field_name = 'externalPath'

    # track full list of non-miscellaenous fields to
    # avoid them being redundantly listed as
    # miscellaneous fields
    @non_misc_field_names = [
      @description_field_name,
      @related_jobs_field_name,
      @title_field_name,
      @external_path_field_name
    ]

    # record given fields
    @title = nil
    @description_html = nil
    @related_jobs = nil
    @external_path = nil
    @misc_fields = {}
    record_fields(data_fields)

    # set up user agent and necessary request params
    # and headers for scraping
    @agent = Mechanize.new
    @request_headers = {
      'Content-Type' => 'application/json'
    }
  end

  ##
  # Return a representation of the stored data, other than
  # the base URLs, as a hash such that calling the
  # constructor or the record_fields method on the return
  # value will result in the same data being loaded
  def to_hash
    result = {}
    result[@external_path_field_name] = @external_path
    result[@description_field_name] = @description
    result[@title_field_name] = @title
    result[@related_jobs_field_name] = []
    #=begin
    @related_jobs&.each do |job_listing|
      result[@related_jobs_field_name].push(job_listing.to_hash)
    end
    #=end
    @misc_fields.each do |field_name, field_value|
      result[field_name] = field_value
    end
    result
  end

  ##
  # Store a given set of data fields, separating the
  # miscellaneuous fields from the non-miscellaneous
  # ones (i.e. external path, title, description,
  # related jobs)
  def record_fields(data_fields)
    data_fields.each do |field_name, field_value|
      if field_name == @external_path_field_name
        # record external path when found
        @external_path = field_value
      elsif field_name == @description_field_name
        # record description when found
        @description_html = field_value
      elsif field_name == @title_field_name
        # record title when found
        @title = field_value
      elsif field_name == @related_jobs_field_name
        # record related jobs when found
        @related_jobs = []
        field_value.each do |job_hash|
          # initialize new JobListing object for
          # each job to make things more
          # convenient
          @related_jobs.push(JobListing.new(
                               @site_url,
                               @request_base,
                               job_hash
                             ))
        end
      else
        # record other data as miscellaneous
        @misc_fields[field_name] = field_value
      end
    end
  end

  ##
  # Make a request to the job listing's data page to
  # retrieve any additional information present there
  #
  # @requires
  #   this.external_path != nil
  def scrape!
    request = JSON.parse(
      @agent.get("#{@request_base}#{@external_path}").content
    )
    # some information is nested in the 'jobPostingInfo'
    # key in the JSON object - account for this
    record_fields(request['jobPostingInfo'])
    request.delete('jobPostingInfo')
    record_fields(request)
  end

  ##
  # Get URL at which the webpage for the job listing
  # can be accessed
  def page_url
    "#{@site_url}#{@external_path}"
  end

  ##
  # Get job title, scrape if not present
  #
  # @requires
  #   this.title != nil or this.external_path != nil
  def title
    scrape! if @title.nil?
    @title
  end

  ##
  # Get HTML-formatted job description, scrape if not
  # present
  #
  # @requires
  #   this.description_html != nil
  #   or this.external_path != nil
  def description_html
    scrape! if @description_html.nil?
    @description_html
  end

  ##
  # Get list of related jobs, scrape if not present
  #
  # @requires
  #   this.related_jobs != nil
  #   or this.external_path != nil
  def related_jobs
    scrape! if @related_jobs.nil?
    @related_jobs
  end

  ##
  # Get list of names of miscellaneuous fields
  def misc_field_names
    @misc_fields.keys.reject do |field_name|
      @non_misc_field_names.include?(field_name)
    end
  end

  ##
  # Get data value associated with field name, nil
  # if data field not present
  def misc_field_data(field_name)
    @misc_fields[field_name]
  end
end
