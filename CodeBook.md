---
title: "Code Book"
output: github_document
---

This document describes the code inside run_analysis.R.

## Variables

* `training_set_file`,`training_labels_file`, `training_subjects_file`, `test_set_file`, `test_labels_file`, `test_subjects_file`, `activity_labels_file`, `features_file` - variables to store path to the files
* `training_set`, `training_labels`, `training_subjects`, `test_set`, `test_labels`, `test_subjects`, `features`, `activitiesNames` - data frames read from files
* `one_training`, `one_test` is used for merging data
* `one_dataset` stores merged training and test data
* `selected_columns` - list of columns, that will be used
* `var_names` - variable/columns names
* `tidy_data` - tidy data frame for the 5th step of project.

## Functions

* `checkFile` - checks if file exist. If not, prints the error.

## Data

Data used for the project:
https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip

Result is stored in `tidy_data.txt`.


## Transformations

1. Merges the training and the test sets to create one data set.
```
one_training <- bind_cols(training_labels,training_subjects,training_set)
one_test <- bind_cols(test_labels,test_subjects,test_set)
one_dataset <- bind_rows(one_training, one_test)
```

2. Extracts only the measurements on the mean and standard deviation for each measurement.
```
# Assigns column names from feature file
colnames(one_dataset)[3:563]<-as.character(features[,2]) 
# Selects requested columns
selected_columns <- grepl( "mean\\(|std|subject|activity" , names(one_dataset))
# Subsets requested columns.
one_dataset <- one_dataset[ , selected_columns]
```

3. Uses descriptive activity names to name the activities in the data set
```
# Loads activities names from file
activitiesNames <- read.table(activity_labels_file, col.names = c("id","name"))
# replaces activities id with names
one_dataset$activity <- activitiesNames$name[match(one_dataset$activity, activitiesNames$id)]
```
4. Appropriately labels the data set with descriptive variable names.
```
var_names <- colnames(one_dataset)
# changing column names with gsub functions, for example:
var_names <- gsub("[\\(\\)-]", "", var_names)
colnames(one_dataset) <- var_names
```
5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.
```
tidy_data <-ddply(one_dataset, .(subject, activity), function(x) colMeans(x[, -(1:2)]))
```

## Writing final tidy data to text file

Creates the `tidy_data.txt` file and write `tidy_data` data frame in it.
