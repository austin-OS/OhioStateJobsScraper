# frozen_string_literal: true

#
# Created by Thomas Li
# Originally Written 28 September 2022
#

require_relative 'job_keyword'
require_relative 'facet'

##
# This class contains methods for applying filtering,
# keyword searches, and sorting a list of retrieved
# job postings.
#
# Mathematical Model:
#   this = (
#       all_listings : string of JobListing,
#       facets : string of Facet,
#       applied_facets : map of string of character to
#       string of character,
#       applied_keywords : string of JobKeyword,
#       limit_amount : integer
#   )
#   [The state consists of the list of all stored job
#   postings, information about the availabe and selected
#   data-field filters (referred to internally as facets
#   for consistency with the JobScraper class, the
#   keywords, and an option to limit the number of
#   postings in the filtered and sorted list]
#
# The following methods are available:
#   initialize(listings)
#   get_facets!()
#   facet_names()
#   facet_info(facet_name)
#   applied_facet_options(facet_name)
#   select_facet_option!(facet_name, facet_option_id)
#   deselect_facet_option!(facet_name, facet_option_id)
#   facet_option_selected?(facet_name, facet_option_id)
#   clear_facet_options!(facet_name)
#   applied_keywords()
#   add_keyword!(pattern_string, must_be_in_title, must_be_in_description)
#   remove_keyword!(keyword_index)
#   clear_keywords!()
#   sort_alphabetically!(ascending: true)
#   sort_by_date!(ascending: true)
#   sort_by_relevance!(ascending: true)
#   limit_amount()
#   set_limit!(amount)
#   clear_limit!()
#   all_listings()
#   filtered_listings()
class JobListManager
  ##
  # The constructor.
  #
  # @param listings : string of JobListings
  #   The full list of job postings to manage
  def initialize(listings)
    @listings = listings
    @facets = nil
    @applied_facets = {}
    @applied_keywords = []
    @limit_amount = nil
  end

  ##
  # Refresh the list of available facet options,
  # or initialize it if it hasn't been determined
  # yet, with the set of available options comprising
  # all data fields and field values present among
  # the filtered listings
  #
  # @param name_map : map of string of character to
  # string of character
  #   Optional hash mapping internal field names to more
  #   reader-friendly descriptors. Only needs to be
  #   passed in once, as subsequent calls will "remember"
  #   the mappings
  def get_facets!(name_map: {})
    # reocrd name mappings
    @name_map = name_map if @name_map.nil?

    if @facets.nil?
      # initialize empty hash if currently nil
      @facets = {}
    else
      # reset all counts otherwise
      @facets.each_value do |facet|
        facet.options.each do |facet_option|
          facet_option.update_count(0)
        end
      end
    end

    # Look through each listing's data fields to determine
    # the possible facets
    # Determine count for each option in terms of how many
    # listings matching that option value would be
    # included in the filtered list if the option were to
    # be selected
    @listings.each do |listing|
      listing.misc_field_names.each do |field_name|
        # Add new corresponding facet if one is not already
        # present
        unless @facets.key?(field_name)
          # Get reader-friendly name if one is present,
          # use internal name otherwise
          facet_descriptor = (@name_map.key?(field_name) ? @name_map[field_name] : field_name)
          # initialize facet
          @facets[field_name] = Facet.new(field_name, facet_descriptor)
        end
        facet = @facets[field_name]
        # Add new facet option corresponding to field value if
        # one isn't already present
        facet_option = nil
        facet_option_value = listing.misc_field_data(field_name)
        facet.options.each do |option|
          if option.descriptor == facet_option_value
            facet_option = option
            break
          end
        end
        if facet_option.nil?
          # generate new ID based on index
          facet_option_id = facet.options.size.to_s
          facet.add_option!(facet_option_id, facet_option_value, 0)
          facet_option = facet.find_option_by_id(facet_option_id)
        end
        # increment count if job listing matches currently
        # set options for all other facets
        passes_filters = true
        @applied_facets.each do |facet_name, applied_options|
          passes_filters = facet_name == field_name || applied_options.empty? || applied_options.any? do |option_id|
            @facets[facet_name].find_option_by_id(option_id).descriptor == listing.misc_field_data(facet_name)
          end
          break unless passes_filters
        end
        # as well as at least one keyword
        passes_filters &&= (@applied_keywords.empty? || @applied_keywords.sum(0) do |keyword|
                              keyword.num_matches(listing)
                            end.positive?)
        facet_option.update_count(facet_option.count + 1) if passes_filters
      end
    end
  end

  ##
  # Returns list of internal names for all available facets
  def facet_names
    get_facets! if @facets.nil? # make sure facets are initialized
    @facets.keys
  end

  ##
  # Returns facet object associated with given internal
  # name
  def facet_info(facet_name)
    get_facets! if @facets.nil? # make sure facets are initialized
    @facets[facet_name]
  end

  ##
  # Return list of IDs of options selected for named facet
  def applied_facet_options(facet_name)
    @applied_facets[facet_name] = [] if @applied_facets[facet_name].nil?
    @applied_facets[facet_name]
  end

  ##
  # Select the option associated with the given ID for the
  # facet with the given internal name, unless it's
  # already been selected
  # @param facet_name
  #   The internal name of the facet to check
  # @param facet_option_id
  #   The ID of the FacetOption object containing the
  #   option value to check
  def select_facet_option!(facet_name, facet_option_id)
    # initialize array of selected options if one isn't
    # present
    @applied_facets[facet_name] = [] unless @applied_facets.key?(facet_name)
    # add option id to list of selections if it's not
    # already present
    @applied_facets[facet_name].push(facet_option_id) unless @applied_facets[facet_name].include?(facet_option_id)
    # refresh the facet counts
    get_facets!
  end

  ##
  # Remove the option with the given ID from the list of
  # applied options for the facet with the given internal
  # name, unless it's already not selected, and return a
  # reference to the corresponding FacetOption object (or
  # null if none found)
  #
  # @param facet_name
  #   The internal name of the facet to check
  # @param facet_option_id
  #   The ID of the FacetOption object containing the
  #   option value to check
  def deselect_facet_option!(facet_name, facet_option_id)
    removed_option = nil
    if @applied_facets.key?(facet_name)
      # record object reference for return value
      removed_option = facet_name.find_option_by_id(facet_option_id)
      # remove option from selection list
      @applied_facets[facet_name].delete(facet_option_id)
    end
    # refresh the facet counts
    get_facets!
    removed_option
  end

  ##
  # Check whether the option for a given facet
  # corresponding to a given ID has been selected
  #
  # @param facet_name
  #   The internal name of the facet to check
  # @param facet_option_id
  #   The ID of the FacetOption object containing the
  #   option value to check
  def facet_option_selected?(facet_name, facet_option_id)
    @applied_facets.key?(facet_name) && @applied_facets[facet_name].include?(facet_option_id)
  end

  ##
  # Clear selected facet options for the facet associated
  # with the given internal name
  def clear_facet_options!(facet_name)
    # set selection list to empty list
    @applied_facets[facet_name] = []
    # refresh the facet counts
    get_facets!
  end

  ##
  # Accessor for list of keywords, returned as a list of
  # JobKeyword objects.
  attr_reader :applied_keywords

  ##
  # Apply the given keyword pattern, with indicators for
  # whether to look for the keyword in the title, the
  # description, either, or both, and return a reference
  # to the corresponding object created to represent the
  # keyword
  #
  # @param pattern_string : string of character
  #   The pattern to match with, can be either a normal
  #   or a regex pattern
  # @param must_be_in_title : boolean
  #   Indicator for whether the pattern must be in the
  #   title of the job listing to constitute a match
  # @param must_be_in_description : boolean
  #   Indicator for whether the pattern must be in the
  #   description of the job listing to constitute a match
  def add_keyword!(pattern_string, must_be_in_title, must_be_in_description)
    # initialize new JobKeyword object, add to list
    @applied_keywords.push(JobKeyword.new(
                             pattern_string,
                             must_be_in_title,
                             must_be_in_description
                           ))
    # refresh the facet counts
    get_facets!
    # return added keyword
    @applied_keywords.last
  end

  ##
  # Remove the keyword at the given index in the keyword
  # list, and return a reference to the corresponding
  # JobKeyword object, or nil if one isn't found
  def remove_keyword!(keyword_index)
    removed_keyword = @applied_keywords[keyword_index]
    # look for element at index, remove from list
    @applied_keywords.delete_at(keyword_index)
    # refresh the facet counts
    get_facets!
    # return removed keyword, or nil if none found
    removed_keyword
  end

  ##
  # Remove all keywords from the keyword list
  def clear_keywords!
    # set keyword list to empty list
    @applied_keywords = []
    # refresh the facet counts
    get_facets!
  end

  ##
  # Sort the stored listings in alphabetical order of
  # title
  #
  # @param ascending
  #   True to sort in ascending order (A-Z), false to
  #   sort descending
  def sort_alphabetically!(ascending: true)
    # sort listings by title
    @listings.sort_by!(&:title)
    # reverse order if doing descending sort
    @listings.reverse! unless ascending
    # refresh the facet counts
    get_facets!
  end

  ##
  # Sort the stored listings in order of post date
  #
  # @param ascending
  #   True to sort in ascending order (earliest to most
  #   recent), false to sort descending
  def sort_by_date!(ascending: false)
    # sort listings by given start date
    @listings.sort_by! { |listing| listing.misc_field_data('startDate') }
    # reverse order if doing descending sort
    @listings.reverse! unless ascending
    # refresh the facet counts
    get_facets!
  end

  ##
  # Sort the stored listings in order of number of matches
  # with the selected keywords
  #
  # @param ascending
  #   True to sort in ascending order (lowest to highest),
  #   false to sort descending
  def sort_by_relevance!(ascending: false)
    # sort listings by total number of keyword matches
    @listings.sort_by! { |listing| @applied_keywords.sum(0) { |keyword| keyword.num_matches(listing) } }
    # reverse order if doing descending sort
    @listings.reverse! unless ascending
    # refresh the facet counts
    get_facets!
  end

  ##
  # Accessor for the limit amount
  attr_reader :limit_amount

  ##
  # Set the limit to the given value
  def set_limit!(amount)
    @limit_amount = amount
    # Refresh the facet counts
    get_facets!
  end

  ##
  # Clear the set limit so that it no longer has any
  # effect on the filtered list
  def clear_limit!
    @limit_amount = nil
    # Refresh the facet counts
    get_facets!
  end

  ##
  # Accessor for full list of stored job postings
  def all_listings
    @listings
  end

  ##
  # Accessor for list of job postings that match
  # facets and keywords, with the limit also applied
  def filtered_listings
    result = []
    # look through each listing, add the ones that
    # match both the applied facets and the keywords
    @listings.each do |listing|
      include_listing = true

      # check facets
      get_facets! if @facets.nil?
      @applied_facets.each do |facet_name, applied_options|
        # if any options are selected, check if listing's
        # corresponding data field matches any of them
        include_listing = applied_options.empty? || applied_options.any? do |option_id|
          @facets[facet_name].find_option_by_id(option_id).descriptor == listing.misc_field_data(facet_name)
        end
        break unless include_listing
      end

      # check keywords, if listing matches applied facets
      if include_listing
        # count total number of keyword matches, make sure is
        # not 0
        total_matches = 0
        @applied_keywords.each do |keyword|
          total_matches += keyword.num_matches(listing)
        end
        include_listing = @applied_keywords.empty? || total_matches.positive?
      end

      result.push(listing) if include_listing
    end
    # cut the size of the result list down to the
    # given limit
    result = result[0, @limit_amount] unless @limit_amount.nil?
    result # return list of matching listings
  end
end
