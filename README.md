###ReadMe for Getting and Cleaning Data Course Project

####Overview

run_analysis.R loads data from the Samsung dataset, which is assumed to be in the "UCI HAR Dataset" directory in the working directory, creates a tidy data set of averaged measurements by subject, activity and feature, and writes the comma-delimted tidy data to tidy_data.txt in the working directory. The tidy data is in "narrow" layout as discussed in [Long Data, Wide Data, and Tidy Data for the Assignment](https://class.coursera.org/getdata-005/forum/thread?thread_id=199) in the Course Project discussion forum. A description of the tidy data can be found in CodeBook.md also located in this repo.

####Steps
Read in features.txt to get column names of measurements

* Clean up column names - remove dashes and parentheses

Read in data from files

* Assign cleaned up column names on import of X_test.txt and X_train.txt

Read in activity_labels.txt to get descriptive names of activities

Assign descriptive activity labels by merging activity labels with y_test and y_train data sets

Bind all data sets together into data frame called fullData

* Bind subject, activity, and measurement test columns
* Bind train columns - subject,activity,data
* Bind test and train rows

Sort fullData by subject and activity

Get which columns are means and standard deviations 

* Keep any feature (column) that starts with t (time) or f (frequency) and contains mean or std

Extract as data table subjectID, activity, and mean and std columns

* Assign key columns and sort by them

Melt data table - put features in rows ("narrow" form of tidy data)

* Assign key columns and sort by them

Average by feature, activity, and subject

* Assign key columns and sort by them
* Rename Measurement column to reflect that it now contains the average Measurements

Write tidy data to comma delimited text file
