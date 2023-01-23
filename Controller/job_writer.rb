# frozen_string_literal: true

#
# Created by Canaan Porter
# Originally Written 24 September 2022
#

require_relative 'job_writer_kernel'
require_relative '../Model/job_listing'

##
# The job_writer class contains the methods required to create a file
# that lists the most up to date jobs on the
#
# Mathematical Model:
#   same as JobWriterKernel
#
# Methods Inherited from JobWriterKernel:
#   initialize(job_list)
#   add_email(email)
# Methods Added:
#   sort_jobs_by_date
#
class JobWriter < JobWriterKernel
  ##
  # Sorts the list of jobs into two lists
  #   1) jobs_new : jobs posted after the last updated date
  #   2) jobs_old : jobs posted before the last updated date
  # @requires
  #   The last updated date has been loaded
  def sort_jobs_by_date
    # sorting each job into old or new job
    @job_list.each do |job|
      # determining how many days ago the date was posted
      if Date.parse(job.to_hash['startDate']) >= @last_updated
        @jobs_new.push(job)
      else
        @jobs_old.push(job)
      end
    end

    # sorting each job list by the date posted, most
    # recent at the top
    @jobs_new.sort_by! { |listing| listing.to_hash['startDate'] }
    @jobs_new.reverse!
    @jobs_old.sort_by! { |listing| listing.to_hash['startDate'] }
    @jobs_old.reverse!
  end

  ##
  # Saves the job_writer parameters (time mailed, email list)
  # to a file that can be loaded in next time the program is run.
  def save_date
    file = File.new(@date_file, 'w')
    file.syswrite(@todays_date)
    file.syswrite("\n")
    file.close

    # puts "Last date updated saved as #{@todays_date}"
  end

  ##
  # Displays the user emails and the last time emails were sent
  # to the terminal
  def disp_params
    puts @last_updated
    puts @user_emails
  end

  ##
  # Obtains the rest of the information required for each job listing
  #
  def scrape_job_list
    @job_list.each(&:scrape!)
  end

  ##
  # Creates HTML table of OSU jobs given a list of jobs
  #
  # @param j_list : list of JobListing objects
  #   The jobs to create the HTML table of
  # @param out : a File object
  #   file to write the job table to
  def generate_table(j_list, out)
    # column headers
    out.syswrite('  <tr><th>Job Title</th><th>Posted On</th>')
    out.syswrite("<th>Job Location</th><th>Job Type</th></tr>\n")
    j_list.each do |job|
      out.syswrite("  <tr>\n")
      out.syswrite("      <th><a href=\"#{job.page_url}\">#{job.title}</a></th>\n")
      out.syswrite("      <th>#{job.to_hash['postedOn']}</th>\n")
      out.syswrite("      <th>#{job.to_hash['locationsText']}</th>\n")
      out.syswrite("      <th>#{job.to_hash['timeType']}</th>\n")
      out.syswrite("  </tr>\n")
    end
  end

  ##
  # Creates the HTML file listing OSU Campus jobs
  #
  # @param filename
  #   Name to be used for output file, default will be
  #   used if none given
  #
  # Displayed Job Listing Structure:
  #
  #   HTML TABLE
  #   Title (Linked) - Posted - Location - Job Type
  #
  def create_file(filename: nil)
    filename = "OSU_Jobs_#{@todays_date}.html" if filename.nil?
    out = File.new(filename, 'w')

    # HTML required tags
    out.syswrite("<!DOCTYPE html>\n")
    out.syswrite("<html lang=\"en\">\n\n")

    # creating table for new jobs
    out.syswrite("<table>\n")
    out.syswrite("<caption> New Jobs on OSU Campus --- #{@todays_date} </caption>\n")
    generate_table(@jobs_new, out)
    # ending new jobs table
    out.syswrite("</table>\n\n")

    # creating table for older jobs
    out.syswrite("<table>\n")
    out.syswrite("<caption> Older Jobs on OSU Campus --- #{@todays_date} </caption>\n")
    generate_table(@jobs_old, out)
    # ending older jobs table
    out.syswrite("</table>\n")

    # ending HTML file
    out.syswrite('</html>')
  end
end
