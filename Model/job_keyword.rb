# frozen_string_literal: true

#
# Created by Thomas Li
# Originally Written 28 September 2022
#

##
# This class represents a regex pattern used for searching
# for job listings, with information about whether to
# search in the title, the description, or both
#
# Mathematical Model:
#   this = (
#     pattern : string of character,
#     must_be_in_title : boolean,
#     must_be_in_description : boolean
#   )
#
# The following methods are available
#   intialize(
#     pattern_string,
#     must_be_in_title,
#     must_be_in_description
#   )
#   pattern()
#   must_be_in_title()
#   must_be_in_description()
#   num_matches(job_listing)
class JobKeyword
  ##
  # The constructor.
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
  def initialize(pattern_string, must_be_in_title, must_be_in_description)
    @pattern = Regexp.new(pattern_string)
    @must_be_in_title = must_be_in_title
    @must_be_in_description = must_be_in_description
  end

  # Accessors for all data members
  attr_reader :pattern, :must_be_in_title, :must_be_in_description

  ##
  # Count number of times the pattern matches with the
  # title and/or description of a given job listing,
  # depending on the indicators that have been set
  #
  # @param job_listing : JobListing
  #   The listing to search in
  def num_matches(job_listing)
    result = 0

    # Compute number of matches in each section
    title_match = @pattern.match(job_listing.title)
    num_title_matches = (title_match.nil? ? 0 : title_match.length)
    description_match = @pattern.match(job_listing.description_html)
    num_description_matches = (description_match.nil? ? 0 : description_match.length)

    # Add number of title matches to result if matches
    # don't need to be in description
    result += num_title_matches unless @must_be_in_description

    # Add number of description matches to result if
    # matches don't need to be in title
    result = num_description_matches unless @must_be_in_title

    # Compute number of matches as minimum of number of
    # title matches and number of description matches if
    # matches need to be in both
    if @must_be_in_title && @must_be_in_description
      result = (num_title_matches < num_description_matches ? num_title_matches : num_description_matches)
    end

    # return total count
    result
  end
end
