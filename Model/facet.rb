# frozen_string_literal: true

#
# Created by Thomas Li
# Originally Written 23 September 2022
#

require_relative 'facet_option'

##
# This class encapsulates the data associated with a given
# filter setting on the OSU Workday site, including the
# list of all possible option values
#
# Mathematical Model:
#   this = (
#     name : string of character,
#     descriptor : string of character,
#     options : string of FacetOption
#   )
#   [The state consists of an internal name, a human
#   reader-friendly descriptor, and a list of selectable
#   options, all encapsulated in the FacetOption class]
#
#   Invariants:
#   for each distinct o1, o2 in options
#     o1.id != o2.id
#   [i.e. All options have unique internal IDs]
#
# The following methods are available:
#   initialize(name, descriptor)
#   name()
#   descriptor()
#   options()
#   add_option!(option_id, option_descriptor, item_count)
#   remove_option!(option_id)
#   find_option_by_id(option_id)
class Facet
  ##
  # The constructor.
  #
  # @param name : string of character
  #   The internal name used for referring to this facet
  # @param descriptor : string of character
  #   The reader-friendly display name
  def initialize(name, descriptor)
    @name = name
    @descriptor = descriptor
    # correspondence: this.options = ~this.options.values
    @options = {}
  end

  # Accessors for all data fields
  attr_reader :name
  attr_reader :descriptor

  def options
    @options.values
  end

  ##
  # Add a possible option value, given a human-readable
  # descriptor, internal ID, and count of matching items.
  # If there is an existing option with that ID, it will
  # be replaced.
  def add_option!(option_id, option_descriptor, item_count)
    @options[option_id] = FacetOption.new(
      option_id,
      option_descriptor,
      item_count
    )
  end

  ##
  # Remove and return the option value with the given ID,
  # returning nil if none matches
  def remove_option!(option_id)
    result = nil
    result = @options[option_id] if @options.key?(option_id)
    @options.delete(option_id) unless result.nil?
    result
  end

  ##
  # Return the option value with the given ID, returning
  # nil if none matches
  def find_option_by_id(option_id)
    result = nil
    result = @options[option_id] if @options.key?(option_id)
    result
  end
end
