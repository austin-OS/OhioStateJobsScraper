# Ohio State Jobs Web Scraper

### Technical Requirements

To run the program, the first step is to have Ruby and the following installed on your system.

Next, enter the following commands into your terminal:

```
gem install mechanize
```

```
gem install json
```

### Starting The Program

Before starting the program, make sure to install the Mechanize and JSON gems first. Otherwise, start by running the file: main.rb with Ruby ($ ruby main.rb) in a terminal app while in the project's directory.

After starting the program, you will be prompted to set a filter for the locations of the jobs you search for. Your options are [1] Remote, [2] Columbus Campus, [3] Medical Center, or any other entry for all job locations.

Once that filter is applied, you will apply the job time type filter. This is between [1] Full Time, [2] Part Time, or enter anything else for both types.

The code will then recieve all of the jobs that fit these filters and list the number of jobs. This may take some time to load. You will then enter the number of jobs you want to get listed (the program will take longer the more jobs you enter). The program will then scrape those jobs one by one until all of the jobs have been scraped from the website. The program will ask you to press enter to continue once this is done.

You have now entered the main menu, where you have the options to [1] View Listed Jobs, [2] Apply Data-Field Filters, [3] Apply Keywords, [4] Sort and Truncate, [5] Write File, [6] Exit. It will prompt you to enter a menu option.

Menu Options:
[1] View Listed Jobs:
View list options gives you two options [1] List Filtered Jobs, which displays only the jobs that fit your given filters, and [2] List All Jobs, which will list all the jobs that have been grabbed from the website. [3] is an options to exit.

[2] Apply Data-Field Filters:
This option allows you to filter the jobs by any of the different attributes that the job has. When you select this option, a list of possible job-attributes will be listed, and you can select and deselect filter values to sort the jobs by these attributes.

[3] Apply Keywords:
This option allows you to [1] Add Keyword, [2] Remove Keyword, [3] Clear Keywords, and [4] Go Back. When you add a keyword, yout type in the keyword to add, then you select whether it is applied to the title, description, both, or either. When removing a keyword, you must enter the index of that specific keyword to remove it. Clearing the keywords will remove all of the keywords from your search.

[4] Sort and Truncate:
When you select this option, you are given the option to sort the list of jobs by [1] Relevance, [2] Newest, [3] Oldest, [4] A-Z, [5] Z-A. Option [7] allows you to truncate the job list to a certain number of jobs, and option [8] clears that truncation. [8] Allows you to go back to the main menu.

[5] Write File:
This option creates an HTML file listing all the jobs listed under the filters and keywords you have applied. This file will be located in the directory you ran the file from. You can open this by opening a web browser of your choice, click on "file > open" and select your file from the directory.

[6] Exit:
This option will exit the program.

## Credits

This project was developed by:

- **[Thomas Li](https://github.com/li11315-osu)**
- **[Canaan Porter](https://github.com/CPort28)**
- **[Austin Greer](https://github.com/austin-OS)**
- **[Alvin Ishimwe](https://github.com/ai003)**
