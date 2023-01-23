# frozen_string_literal: true

#
# Created by Canaan Porter
# Originally Written 20 September 2022
#

require 'date'

##
# This class contains the methods required to create a Mailer object, given a list of
# jobs to be mailed out to the user.
#
# Mathematical Model:
#
#   this = (
#       job_list : list of JobListing objects
#       jobs_new : list of JobListing objects
#       jobs_old : list of JobListing objects
#       last_updated : date object
#   )
#
#   Define job_list as an object of the class JobList, which represents
#   the collection of the jobs filtered by the user input parameter.
#   Define jobs_new as a list of jobs that have not yet been sent to the user.
#   Define jobs_old as a list of jobs that have already been sent to the user.
#   Define user_email as a list of strings of the email addresses entered by the user.
#
# The following methods are available:
#   initialize(job_list)
#
class JobWriterKernel
  ##
  # Constructs a JobFinder object, used to create and send personalized files
  # that list job postings from the OSU career website
  #
  # @param job_list : list(Job)
  #   The list of Job objects that are to be displayed on the file
  # @ensures
  #
  def initialize(init_job_list)
    @job_list = init_job_list
    @jobs_new = []
    @jobs_old = []
    @last_updated = nil
    @date_file = 'Controller/last_date_accessed.txt'
    @todays_date = Date.today
  end

  ##
  # Reads the file "last_date_accessed.txt" to get the last date the program was run
  # @param date_file : string
  #   The name of the date file
  # @requires
  #   The file "last_date_accessed.txt exists"
  #   Use the function "save_date" to create this file if it does not exist
  # @ensures
  #   last_updated is the last date the program was run
  def update_date
    line = File.read(@date_file)
    @last_updated = Date.parse(line)
    # puts "Last updated date loaded as #{@last_updated}"
  end
end
