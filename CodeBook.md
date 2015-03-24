## Introduction

This file gives a review of the data we started from (the original dataset) and then explicitly describes all transformation steps required by the assignment to the course project. The final part contains the description of the resulting dataset structure.

## Original Dataset

<i>NOTE: Detailed description of the dataset can be found in corresponding README.txt file inside the ZIP archive available from here along with the original dataset:</i>

https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip

The original dataset contains accelerometer and gyroscope sensor data from Samsung Galaxy S II smartphone attached to 30 different subjects performing several kinds of activites (like walking, running, etc.).

### Review of the original structure

There are two equally structured folders <b>test</b> and <b>train</b>, representing two datasets to be merged, according to project assignment. In each dataset, basically, there are some primary data representing angular and axial accelerations on X, Y, Z axes measured 50 times a second, and there is a lot (561 to be precise) of subsequently calculated characteristics (called 'features') covering different aspects of motion.

#### Primary sensor data ('Inertial Signals')

<i>NOTE: The understanding of primary data structure is quite important in interpretation of the whole dataset, but we will not be using this data for our cleaned-up dataset version.</i>

Primary data from sensors is organized in <b>frames</b> of 128 samples. Those frames overlap with each other, each frame starting 64 samples after previous one (that is, exactly a half of frames' length) and therefore resulting in some redundancy (fragments of sample series are repeated). Frame contents is written one after another in text files as numbers separated by spaces with <b>no</b> explicit separators between frames. (UPDATE: After starting peer review, I just realized there actually ARE separators in form of newline symbols. Fortunately, this fact doesn't change the correctness of my code and of the final result I got. I'm also going to update the paragraph on features below to make it consistent with this fact. If you're reading this, please note that this is just for your information, and you don't have to consider this in your grading, because this correction has been added after I submitted my project for peer review.) Primary data is in subfolders called <b>Inertial Signals</b>, arranged in files for each axis and kind of measurement. There are three kinds of measurements:

* axial acceleration (<b>total_acc_*.txt</b> files)
* extracted body acceleration (<b>body_acc_*.txt</b> files), which is simply axial acceleratoin after subtracting its constant gravitational component
* angular acceleration (<b>body_gyro_*.txt</b> files)

Given those three measurements multiplied by the three X, Y, Z axes, we get nine text files having equal number of space-separated floating point values (128 samples per frame * number of frames). Therefore, each sample is a vector of 9 values distributed across separate files and usually repeated twice (in every two successive frames), except for the first 64 and the last 64 samples, which are not repeated.

#### Features

Features are calculated based on frames (not on single samples) and put into files with names like <b>X_*.txt</b>, each file having 561 feature values for each single frame of sensor data. According to the project assignment, we are interested in specific features from these files. The complete list of feature names is located in <b>features.txt</b> file in the root folder of the original dataset (nearby <b>test</b> and <b>train</b> folders). The meaning of feature names is described in <b>features_info.txt</b> file in the same folder.

Therefore, each feature value theoretically can be based on up to 128 samples of a corresponding frame from the <b>Inertial Signals</b> folder. However, features may consider less data. The main point here is that there is NO explicit relation between a particular feature value and a particular value in any of the nine inertial signal files, but there is a one-to-one relation between each feature value and a corresponding frame of 128 samples.

#### Activity labels and test subjects
There are two additional files in same folders where features data is located:

* <b>subject_test.txt</b> - maps test subjects (numbered from 1 to 30) to each frame
* <b>y_train.txt</b> - maps activity (numbered from 1 to 6) to each frame; all six activities and their corresponding numbers are listed in <b>activity_labels.txt</b> file in the root folder of the dataset

## Transforming Dataset

Now, when we are familiar with the structure of the original dataset, we can describe the required transformation steps in context of the dataset terminology

### 1. Merge the training and the test sets to create one data set

In general context this would mean that we should concatenate all files with corresponding names from <b>train</b> and <b>test</b> folders (in the same order, obviously). However, considering steps 2 and 5, we will only need feature data along with subject and activity labels in our final dataset, so we can ignore files from 'Inertial Signals' folders. Therefore, this step can now be expressed in the following way:

* concatenate train/subject_train.txt and test/subject_test.txt
* concatenate train/X_train.txt and test/X_test.txt and transform it to 561-column matrix
* concatenate train/y_train.txt and test/y_test.txt

### 2. Extract only the measurements on the mean and standard deviation for each measurement

If we look at all 561 features we can notice that they're not completely unique. They exploit just 17 algorithms, 8 of which are calculated for separate axes, and also 17 functions calculated on top of each of the algorithms. It is quite easy to see that all possible combinations from these components result in the exact number of features:

<code>([8 by-axis algos] * [3 axes] + [9 universal algos]) * [17 functions] = 561 features</code>

So, according to the assignment, we need features for <b>mean()</b> and <b>std()</b> functions. Filtering them is easy -- just look at feature names containing corresponding substrings (there are 66 such features).

Now we are ready to formalize this step:

* from the <b>features.txt</b> file, find the numbers of features with "mean()" or "std()" in their names and select corresponding columns from the concatenated table of features

### 3. Use descriptive activity names to name the activities in the data set

This one is easy. We already have activities combined at this point. Now we simply need to look up their names in the <b>activity_labels.txt</b> file and make a new vector of activity names. We can also make those names more readable by replacing underscores with spaces and converting letters to lowercase.

### 4. Appropriately label the data set with descriptive variable names

Even easier. By this point we already have our features filtered by their names, so all we need is to assign filtered feature names to the columns of our feature matrix.

### 5. From the data set in step 4, create a second, independent tidy data set with the average of each variable for each activity and each subject.

What we need first is to combine feature, subject, and activity data into one table. We already have our nice matrix of filtered features, so let's add to it two additional columns (subject and activity) and convert the matrix to data.table object to be able to easily group things by columns. This should be no more than 3-5 lines of code if you know the magic.

Now we're ready to save the aggregated table to the <b>tidy_data.txt</b> file.

## Resulting Dataset Description (tidy_data.txt)

The file contains a table that can be read into R with the code like:

<code>data <- read.table("tidy_data.txt", header = TRUE)</code>

The table has 68 columns and 180 rows. The first two colums contain a unique combination of subject number (1 to 30) and activity label out of 180 possible combinations (6 activities by 30 subjects). Activity can be one of the following:

<pre>
1 walking
2 walking upstairs
3 walking downstairs
4 sitting
5 standing
6 laying
</pre>

The last 66 columns contain average (mean) values for all the 66 feature variables that we have selected among 561 features of the original dataset for this given combination of subject and activity. Below is the complete list of selected features with their corresponding numbers from the <b>features.txt</b> file of the original dataset -- these features are averaged in our resulting dataset. Detailed information about these features and their measurement units can be found in the <b>features_info.txt</b> file of the original dataset.

<pre>
1 tBodyAcc-mean()-X
2 tBodyAcc-mean()-Y
3 tBodyAcc-mean()-Z
4 tBodyAcc-std()-X
5 tBodyAcc-std()-Y
6 tBodyAcc-std()-Z
41 tGravityAcc-mean()-X
42 tGravityAcc-mean()-Y
43 tGravityAcc-mean()-Z
44 tGravityAcc-std()-X
45 tGravityAcc-std()-Y
46 tGravityAcc-std()-Z
81 tBodyAccJerk-mean()-X
82 tBodyAccJerk-mean()-Y
83 tBodyAccJerk-mean()-Z
84 tBodyAccJerk-std()-X
85 tBodyAccJerk-std()-Y
86 tBodyAccJerk-std()-Z
121 tBodyGyro-mean()-X
122 tBodyGyro-mean()-Y
123 tBodyGyro-mean()-Z
124 tBodyGyro-std()-X
125 tBodyGyro-std()-Y
126 tBodyGyro-std()-Z
161 tBodyGyroJerk-mean()-X
162 tBodyGyroJerk-mean()-Y
163 tBodyGyroJerk-mean()-Z
164 tBodyGyroJerk-std()-X
165 tBodyGyroJerk-std()-Y
166 tBodyGyroJerk-std()-Z
201 tBodyAccMag-mean()
202 tBodyAccMag-std()
214 tGravityAccMag-mean()
215 tGravityAccMag-std()
227 tBodyAccJerkMag-mean()
228 tBodyAccJerkMag-std()
240 tBodyGyroMag-mean()
241 tBodyGyroMag-std()
253 tBodyGyroJerkMag-mean()
254 tBodyGyroJerkMag-std()
266 fBodyAcc-mean()-X
267 fBodyAcc-mean()-Y
268 fBodyAcc-mean()-Z
269 fBodyAcc-std()-X
270 fBodyAcc-std()-Y
271 fBodyAcc-std()-Z
345 fBodyAccJerk-mean()-X
346 fBodyAccJerk-mean()-Y
347 fBodyAccJerk-mean()-Z
348 fBodyAccJerk-std()-X
349 fBodyAccJerk-std()-Y
350 fBodyAccJerk-std()-Z
424 fBodyGyro-mean()-X
425 fBodyGyro-mean()-Y
426 fBodyGyro-mean()-Z
427 fBodyGyro-std()-X
428 fBodyGyro-std()-Y
429 fBodyGyro-std()-Z
503 fBodyAccMag-mean()
504 fBodyAccMag-std()
516 fBodyBodyAccJerkMag-mean()
517 fBodyBodyAccJerkMag-std()
529 fBodyBodyGyroMag-mean()
530 fBodyBodyGyroMag-std()
542 fBodyBodyGyroJerkMag-mean()
543 fBodyBodyGyroJerkMag-std()
</pre>
