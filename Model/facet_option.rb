# frozen_string_literal: true

#
# Created by Thomas Li
# Originally Written 23 September 2022
#

##
# This class encapsulates the data present in a given
# selectable value for a filter option (referred to
# internally as a "facet") on the OSU Workday site
#
# Mathematical Model:
#   this = (
#     id : string of character,
#     descriptor : string of character,
#     count : integer
#   )
#   [The state consists of a human-readable name, an
#   internal ID, and a tracker for the number of items
#   that match the facet option]
#
# The following methods are available:
#   initialize(id, descriptor, count)
#   id()
#   descriptor()
#   count()
#   update_count(count)
class FacetOption
  ##
  # The constructor.
  #
  # @param descriptor : string of character
  #   The display name for the option
  # @param id : string of character
  #   The internal identifier
  # @param count : int
  #   The number of items that match the option value
  def initialize(id, descriptor, count)
    @id = id
    @descriptor = descriptor
    @count = count
  end

  # Accessors for all three data fields
  attr_reader :descriptor
  attr_reader :id, :count

  ##
  # Changes the count tracker to the specified value
  def update_count(count)
    @count = count
  end
end
