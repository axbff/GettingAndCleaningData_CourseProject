# Course Project
<b>Course</b>: <i>Getting and Cleaning Data</i> by Johns Hopkins Bloomberg School of Public Health, at Coursera.org<br/>
<b>Author</b>: axbff

## Introduction

This is a processed version of the Human Activity Recognition Dataset by <b>University of California, Irvine</b>. This version of the original dataset has been created according to the guidelines and steps specified in the assignment for the course project published on Coursera.

## Files Included

* <b>README.md</b>: The one you're reading right now. Contains description of the project and references to additional information you may need.
* <b>prepareData.R</b>: Contains the script used to process the original dataset that writes the modified version to the <b>tidy_data.txt</b> file. If you want to run this script yourself, it has to be put in the same folder with the <b>unzipped</b> original dataset (do NOT put the script into <b>UCI HAR Dataset</b>). The zipped dataset can be downloaded from here:

https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip

* <b>tidy_data.txt</b>: Cleaned-up and rearranged ('tidy') version of the original dataset produced by the <b>prepareData.R</b> script. Its structure is fully described in <b>CodeBook.md</b> file. The proper way to read this file into R is like this:
<code>data <- read.table("tidy_data.txt", header = TRUE)</code>, given that the file is in your working directory.

* <b>CodeBook.md</b>: Contains the information necessary to interpret both datasets -- the original one and the resulting one -- as well as references to additional information and files that you may need.