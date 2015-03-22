prepareData <- function()
{
  # store initial working dir to return here later
  working_dir <- getwd()
  
  # go to original dataset
  setwd("UCI HAR Dataset")
  
  # create a common place for all the data  
  data <- list()
  
  ########
  # STEP 1
  # Merge the training and the test sets to create one data set
  
  # read and combine train and test subject data
  t <- scan("train/subject_train.txt")
  t <- c(t, scan("test/subject_test.txt"))
  
  data$subject <- t
  
  # read and combine train and test feature data
  t <- scan("train/X_train.txt")
  t <- c(t, scan("test/X_test.txt"))
  
  # reshape feature data to a matrix with 561 features in a row
  # 1 row = 1 frame
  t <- matrix(t, ncol = 561, byrow = TRUE)
  
  data$features <- t
  
  # read and combine train and test activity labels
  t <- scan("train/y_train.txt")
  t <- c(t, scan("test/y_test.txt"))
  
  data$activity <- t
  
  ########
  # STEP 2
  # Extract only the measurements on the mean
  # and standard deviation for each measurement
  
  library(data.table)
  
  t <- fread("features.txt")
  
  # filter mean() and std() features
  data$selected_feature_numbers <- t[(V2 %like% "std\\(\\)" | V2 %like% "mean\\(\\)"), which = T]
  
  # store names of filtered features
  data$selected_feature_names <- t[data$selected_feature_numbers, V2]
  
  # remove unnecessary features from our dataset
  data$features <- data$features[,data$selected_feature_numbers]
  
  ########
  # STEP 3
  # Use descriptive activity names to 
  # name the activities in the data set
  
  t <- fread("activity_labels.txt")
  
  # make labels more readable by humans
  data$activity_labels <- tolower(gsub("_", " ", t[, V2]))
  
  # replace numbers with corresponding labels
  data$activity <- with(data, activity_labels[activity])
  
  ########
  # STEP 4
  # Appropriately label the data set
  # with descriptive variable names
  
  colnames(data$features) <- data$selected_feature_names
  
  ########
  # STEP 5
  # Create a second, independent tidy data set with the
  # average of each variable for each activity and each subject
  
  # convert feature matrix to use magic power of data.table
  data$tbl <- data.table(data$features)
  
  # add two extra columns for subject and activity
  data$tbl[, `:=` (Subject = data$subject, Activity = data$activity)]
  
  # calculate means for all columns except the last two
  # (features only), grouping by Subject and Activity
  data$aggr <- data$tbl[,lapply(.SD, mean),
                        by = "Subject,Activity",
                        .SDcols = 1:(ncol(data$tbl)-2)]
  
  # return to initial working directory
  setwd(working_dir)
  
  # write resulting aggregated table to file
  write.table(data$aggr, file = "tidy_data.txt", row.names = FALSE)
  
  print("Resulting dataset written to tidy_data.txt")
  
  invisible(data)
}

prepareData()

