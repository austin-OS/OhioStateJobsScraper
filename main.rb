# frozen_string_literal: true

require_relative 'Model/job_scraper'
require_relative 'Model/job_list_manager'
require_relative 'Controller/job_writer'
require_relative 'global_constants'
require 'date'

site_url = GlobalConstants::BASE_PAGE_PATH
request_base = GlobalConstants::BASE_REQUEST_PATH
request_path = GlobalConstants::QUERY_REQUEST_PATH
min_query_size = GlobalConstants::MIN_QUERY_SIZE
max_query_size = GlobalConstants::MAX_QUERY_SIZE

##
# Changes the site_url to reflect a search for keywords
#
# @param keywords : a list of string
#   The keywords you want to search for
# @param site_url : string
#	The base path of the website you want to search (OSU Careers)
def get_search_url(keywords, site_url)
  if keywords.length.positive?
    site_url += '?q='
    # adding each keyword to the URL
    keywords.each_with_index do |keyword, i|
      site_url += keyword
      # adding a "space" in the URL if not the last word
      site_url += '%20' if i != keywords.length - 1
    end
  end
  site_url
end

##
# Prints an array of job listings in short form
def print_job_list(listings)
  # For each listing, print an index and the title
  (0...listings.size).each do |i|
    puts "[#{i}] #{listings[i].title}"
  end
end

##
# Prints an individual job listing in long form
def print_job_listing(listing)
  # Display the title
  puts "Title: #{listing.title}"
  # Pretty-print the HTML using Nokogiri
  # I borrowed this approach from StackOverflow
  puts 'Description:'
  puts Nokogiri::HTML(listing.description_html)
  # Display the URL
  puts "Link: #{listing.page_url}"
  # Display all miscellaneous fields
  puts 'Data Fields:'
  listing.misc_field_names.each do |field_name|
    puts "\t#{field_name}: #{listing.misc_field_data(field_name)}"
  end
end

##
# Get a string describing the state of a job keyword's
# location indicator
def keyword_location_string(keyword)
  (if keyword.must_be_in_title
     keyword.must_be_in_description ? 'both title and description' : 'title'
   else
     (keyword.must_be_in_description ? 'description' : 'either title or description')
   end)
end

# getting the user input for the location
puts
puts 'This app will create an HTML file with the most recent available OSU jobs.'
puts
puts 'Choose a number to filter jobs by location.'
puts '[1] Remote Jobs'
puts '[2] Columbus Campus Jobs'
puts '[3] Medical Center'
puts '(Enter anything else for all locations.)'
print 'Enter here: '
location = gets.chomp.to_i

# getting the user input for the job type
puts 'Choose a number to filter jobs by their time type.'
puts '[1] Full Time'
puts '[2] Part Time'
puts '(Enter anything else for both time types.)'
print 'Enter here: '
fullOrPart = gets.chomp.to_i

# creating scraper object
scraper = JobScraper.new(site_url, request_base, request_path, min_query_size, max_query_size)

# setting the facet "location"
case location
when 1
  scraper.select_facet_option!('locations', 'cfeaeb92ccbc01249f6733da8b0186fa')
  puts 'Working with Remote jobs.'
when 2
  scraper.select_facet_option!('locations', '819c1ab743bd01f14b629c006501acb6')
  puts 'Working with Columbus Campus jobs.'
when 3
  scraper.select_facet_option!('locations', '819c1ab743bd0130a44a99006501a2b6')
  puts 'Working with Medical Center jobs.'
else
  puts 'Working with all possible jobs.'
end

# setting the facet "timeType"
case fullOrPart
when 1
  scraper.select_facet_option!('timeType', '38709af0feb60197596be2b9ff095800')
  puts 'Working with full time jobs.'
when 2
  scraper.select_facet_option!('timeType', '38709af0feb6015d2940e2b9ff095700')
  puts 'Working with part time jobs.'
else
  puts 'Working with both full and part time jobs.'
end

puts "The number of total active jobs is: #{scraper.num_matching_jobs}"
puts '(Enter anything else to get all the jobs)'
print 'Enter the number of recent jobs you want: '
text_input = gets

# Scraping data from the OSU job website
num_jobs = text_input.to_i
if num_jobs.zero?
  num_jobs = nil
  puts 'Scraping all jobs from job board...'
else
  puts "Scraping #{num_jobs} jobs from job board..."
end
listings = scraper.query(num_jobs: num_jobs)
puts "#{listings.size} jobs retrieved"
# puts "Press enter to continue"
# text_input = gets
(0...listings.size).each do |i|
  puts "Scraping external page for job posting ##{i + 1}..."
  listings[i].scrape!
end
puts 'All information retrieved. Press enter to continue.'
text_input = gets

# Present menu for setting filters, keywords, and sorting
# before writing to file
list_manager = JobListManager.new(listings)
loop_menu = true
while loop_menu
  puts 'Options'
  puts '[1] View Listed Jobs'
  puts '[2] Apply Data-Field Filters'
  puts '[3] Apply Keywords'
  puts '[4] Sort and Truncate'
  puts '[5] Write File'
  puts '[6] Exit'
  print 'Select an option: '

  text_input = gets.to_i
  puts
  case text_input
  when 1
    # allow user to view job info for 1
    puts 'View Listed Jobs option selected.'
    puts
    loop_view_menu = true
    while loop_view_menu
      puts 'Options'
      puts '[1] List Filtered Jobs'
      puts '[2] List All Jobs'
      puts '[3] Go Back'
      print 'Select an option: '

      text_input = gets.to_i
      puts
      list_to_view = nil
      case text_input
      when 1
        # display filtered jobs for 1
        list_to_view = list_manager.filtered_listings
      when 2
        # display all jobs for 2
        list_to_view = list_manager.all_listings
      else
        # go back to main menu otherwise
        loop_view_menu = false
      end
      next if list_to_view.nil?

      # display jobs, give user the option to view
      # details on individual jobs
      loop_view_submenu = true
      while loop_view_submenu
        print_job_list(list_to_view)
        print 'Enter the index of a job listing to view in detail, or enter blank input to return: '
        text_input = gets
        puts
        if text_input.size > 1 && text_input.to_i >= 0 && text_input.to_i < list_to_view.size
          # display specified job in detail if index in
          # bounds
          print_job_listing(list_to_view[text_input.to_i])
          puts 'Press enter to continue'
          text_input = gets
        else
          # exit submenu for blank or invalid input
          loop_view_submenu = false
        end
      end
    end
  when 2
    # allow user to view and apply facets for 2
    puts 'Apply Data-Fields Filters option selected.'
    puts

    # obtain count of each distinct data value for each
    # data field, allow user to select fields and values
    # to filter for
    list_manager.get_facets!
    loop_filter_menu = true
    while loop_filter_menu
      puts 'Filterable Data Fields:'
      # list all field names, with an index
      list_manager.facet_names.each_index do |i|
        facet_name = list_manager.facet_names[i]
        facet = list_manager.facet_info(facet_name)
        puts "[#{i}] #{facet_name} (#{facet.options.size} distinct values, #{list_manager.applied_facet_options(facet_name).size} selected)"
      end
      # let user select field to set filter options for
      print 'Enter the index of a data field to toggle filters for, or enter blank input to go return: '
      text_input = gets
      puts

      # open sub-menu for setting filter options, or go
      # back in case of blank input or out-of-bounds index
      if text_input.length > 1 && text_input.to_i >= 0 && text_input.to_i < list_manager.facet_names.length
        facet_name = list_manager.facet_names[text_input.to_i]
        facet = list_manager.facet_info(facet_name)
        puts "Setting filters for field #{facet_name}"
        puts
        loop_filter_submenu = true
        while loop_filter_submenu
          # display available filter options for the given
          # data field
          puts 'Available Values:'
          facet.options.each_index do |i|
            facet_option = facet.options[i]
            puts "[#{i}] #{facet_option.descriptor} (#{facet_option.count} matching jobs) #{'- Currently Selected' if list_manager.facet_option_selected?(
              facet_name, facet_option.id
            )}"
          end
          puts 'If any values are selected, then only jobs that match at least one of the selected values will appear in the filtered list. If none are selected, then all values are allowed.'
          puts

          puts 'Options'
          puts '[1] Select Filter Value'
          puts '[2] Deselect Filter Value'
          puts '[3] Clear Selections'
          puts '[4] Go Back'
          print 'Select an option: '

          text_input = gets.to_i
          puts
          case text_input
          when 1
            # allow user to select for 1
            print 'Enter the index of the value to select: '
            text_input = gets.to_i
            puts
            if text_input >= 0 && text_input < facet.options.length
              facet_option = facet.options[text_input]
              puts "Adding value #{facet_option.descriptor} to filter..."
              list_manager.select_facet_option!(facet_name, facet_option.id)
            else
              puts 'Index out of bounds'
            end
          when 2
            # allow user to deselect for 2
            if list_manager.applied_facet_options(facet_name).length.positive?
              print 'Enter the index of the value to deselect: '
              text_input = gets.to_i
              puts
              if text_input >= 0 && text_input < facet.options.length
                facet_option = facet.options[text_input]
                puts "Removing value #{facet_option.descriptor} from filter..."
                list_manager.deselect_facet_option!(facet_name, facet_option.id)
              else
                puts 'Index out of bounds'
              end
            else
              puts 'No facets currently selected'
            end
          when 3
            # clear selected options for 3
            puts 'Clearing filter...'
            list_manager.clear_facet_options!(facet_name)
          else
            # exit submenu for 4
            loop_filter_submenu = false
          end

          # for options 1, 2, and 3, list number of jobs
          # that match newly-set filters
          next unless loop_filter_submenu

          print "There are now #{list_manager.filtered_listings.size} total matching jobs. Display? (y/n): "
          text_input = gets
          next unless text_input[0].downcase == 'y'

          print_job_list(list_manager.filtered_listings)
          puts 'Press enter to continue'
          text_input = gets
        end
      else
        loop_filter_menu = false
      end
    end
  when 3
    # allow user to view and apply keywords for 3
    puts 'Apply Keywords option selected.'
    puts

    loop_keywords_menu = true
    while loop_keywords_menu
      # display current keywords
      puts 'Current Keywords:'
      list_manager.applied_keywords.each_index do |i|
        keyword = list_manager.applied_keywords[i]
        puts "[#{i}] #{keyword.pattern.to_s} - match with #{keyword_location_string(keyword)}"
      end
      puts '[none]' if list_manager.applied_keywords.empty?
      puts 'Only job listings that match at least one keyword will show up in the filtered list.'
      puts 'Keywords are interpreted as regular expressions, allowing advanced matching in addition to plaintext lookups.'
      puts

      # display menu options for handling keywords
      puts 'Options'
      puts '[1] Add Keyword'
      puts '[2] Remove Keyword'
      puts '[3] Clear Keywords'
      puts '[4] Go Back'
      print 'Select an option: '

      text_input = gets.to_i
      puts

      case text_input
      when 1
        # allow user to add keyword for 1
        # take input for pattern string
        print 'Enter the pattern to match for the keyword: '
        pattern_string = gets.chomp!
        # take input for search location indicators
        puts 'Keyword must be matched with: '
        puts '[1] Title'
        puts '[2] Description'
        puts '[3] Both'
        puts '[4] Either'
        print 'Select an option: '
        must_be_in_title = false
        must_be_in_description = false
        text_input = gets.to_i
        case text_input
        when 1
          must_be_in_title = true
        when 2
          must_be_in_description = true
        when 3
          must_be_in_title = true
          must_be_in_description = true
        end
        added_keyword = list_manager.add_keyword!(pattern_string, must_be_in_title, must_be_in_description)
        puts "Added keyword #{added_keyword.pattern.to_s}, matching #{keyword_location_string(added_keyword)}"
      when 2
        # allow user to remove keyword for 2
        if list_manager.applied_keywords.empty?
          puts 'No keywords currently applied.'
        else
          # take input for removal index unless list empty
          print 'Enter the index in the keyword list of the keyword to remove, or enter blank input to cancel: '
          text_input = gets
          # check bounds
          if text_input.length > 1 && text_input.to_i >= 0 && text_input.to_i < list_manager.applied_keywords.length
            removed_keyword = list_manager.remove_keyword!(text_input.to_i)
            puts "Removed keyword #{removed_keyword.pattern.to_s}, matching with #{keyword_location_string(removed_keyword)}"
          end
        end
      when 3
        # clear all keywords for 3
        puts 'Clearing keywords...'
        list_manager.clear_keywords!
      else
        # return to previous menu otherwise
        loop_keywords_menu = false
      end

      # for options 1, 2, and 3, list number of jobs
      # that match newly-set keywords
      next unless loop_keywords_menu

      print "There are now #{list_manager.filtered_listings.size} total matching jobs. Display? (y/n): "
      text_input = gets
      next unless text_input[0].downcase == 'y'

      print_job_list(list_manager.filtered_listings)
      print 'Press enter to continue'
      text_input = gets
    end
  when 4
    # allow user to sort list and limit filter results
    # to top X postings for 4
    puts 'Sort and Truncate option selected.'
    puts

    loop_sorting_menu = true
    while loop_sorting_menu
      # display menu options for sorting jobs and
      # truncating length of results
      puts 'Options'
      puts '[1] Sort by Relevance (# keyword matches)'
      puts '[2] Sort by Newest'
      puts '[3] Sort by Oldest'
      puts '[4] Sort A-Z'
      puts '[5] Sort Z-A'
      puts "[6] Truncate List #{"(Current Limit: #{list_manager.limit_amount})" unless list_manager.limit_amount.nil?}"
      puts '[7] Clear Truncation'
      puts '[8] Go Back'
      print 'Select an option: '

      text_input = gets.to_i
      puts
      case text_input
      when 1
        # sort by relevance descending for 1
        list_manager.sort_by_relevance!
        puts 'Sorted by relevance'
      when 2
        # sort by date descending for 2
        list_manager.sort_by_date!(ascending: false)
        puts 'Sorted by newest'
      when 3
        # sort by date ascending for 3
        list_manager.sort_by_date!(ascending: true)
        puts 'Sorted by oldest'
      when 4
        # sort alphabetically ascending for 4
        list_manager.sort_alphabetically!(ascending: true)
        puts 'Sorted A-Z'
      when 5
        # sort alphabetically descending for 5
        list_manager.sort_alphabetically!(ascending: false)
        puts 'Sorted Z-A'
      when 6
        # set length limit for 6
        print 'Enter the maximum number of jobs to include in the filtered list - this works in conjunction with sorting: '
        text_input = gets.to_i
        list_manager.set_limit!(text_input)
        puts "Filtered list limited to top #{list_manager.limit_amount} job postings"
      when 7
        # clear length limit for 7
        list_manager.clear_limit!
        puts 'Length limit removed'
      else
        loop_sorting_menu = false
      end

      # allow user to see result of sorting or truncation
      next unless loop_sorting_menu

      print 'See resulting filtered list? (y/n): '
      text_input = gets
      next unless text_input[0].downcase == 'y'

      print_job_list(list_manager.filtered_listings)
      puts 'Press enter to continue'
      text_input = gets
    end
  when 5
    # write job list to file for 5
    puts 'Write File option selected.'
    puts

    # generating the file
    puts "The filename is OSU_Jobs<today's date>.html"

    # create JobWriter object to handle file create
    writer = JobWriter.new(list_manager.filtered_listings)
    writer.update_date
    writer.sort_jobs_by_date
    writer.create_file
    writer.save_date

    puts 'The file has been created in the current terminal directory. Press enter to continue.'
    text_input = gets
  else
    # exit for 6 or any other input
    print 'Exit option selected. Are you sure you want to exit? (y/n): '
    text_input = gets
    if text_input[0].downcase == 'y'
      puts 'Exit confirmed. Exiting...'
      loop_menu = false
    else
      puts 'Exit not confirmed. Continuing...'
    end
  end
end

