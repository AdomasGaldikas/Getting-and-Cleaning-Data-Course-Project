# Coursera Getting and Cleaning Data Course Project
# Adomas Galdikas
# 28.01.2017

# Clean memory
rm(list=ls())

# Load libraries
library(plyr)
library(dplyr)

# Function to check if files exists. If not, prints error.
checkFile<-function(file){
      if(!(file.exists(file))){
            print(paste0("Error: File ",file," does not exists."))
      }
}


# Seeting paths to files
training_set_file<-'UCI HAR Dataset/train/X_train.txt'
training_labels_file<-'UCI HAR Dataset/train/y_train.txt'
training_subjects_file<-'UCI HAR Dataset/train/subject_train.txt'
test_set_file<-'UCI HAR Dataset/test/X_test.txt'
test_labels_file<-'UCI HAR Dataset/test/y_test.txt'
test_subjects_file<-'UCI HAR Dataset/test/subject_test.txt'
activity_labels_file <- 'UCI HAR Dataset/activity_labels.txt'
features_file <- 'UCI HAR Dataset/features.txt'

# Checks if files exist
checkFile(training_set_file)
checkFile(test_set_file)
checkFile(training_labels_file)
checkFile(test_labels_file)
checkFile(training_subjects_file)
checkFile(test_subjects_file)
checkFile(activity_labels_file)
checkFile(features_file)

# Read files to data frames
training_set<-read.table(training_set_file)
training_labels<-read.table(training_labels_file, col.names = c("activity"))
training_subjects<-read.table(training_subjects_file, col.names = c("subject"))
test_set<-read.table(test_set_file)
test_labels<-read.table(test_labels_file, col.names = c("activity"))
test_subjects<-read.table(test_subjects_file, col.names = c("subject"))
features <- read.table(features_file)

# 1. Merges the training and the test sets to create one data set.

# merges training data
one_training <- bind_cols(training_labels,training_subjects,training_set)
# merges test data
one_test <- bind_cols(test_labels,test_subjects,test_set)
# merges training and test data
one_dataset <- bind_rows(one_training, one_test)

# 2. Extracts only the measurements on the mean and standard deviation for each measurement.

# Assigns column names from feature file
colnames(one_dataset)[3:563]<-as.character(features[,2]) 

# Selects requested columns
selected_columns <- grepl( "mean\\(|std|subject|activity" , names(one_dataset))
# Subsets requested columns.
one_dataset <- one_dataset[ , selected_columns]


# 3. Uses descriptive activity names to name the activities in the data set

# Loads activities names from file
activitiesNames <- read.table(activity_labels_file, col.names = c("id","name"))
# replaces activities id with names
one_dataset$activity <- activitiesNames$name[match(one_dataset$activity, activitiesNames$id)]

# 4. Appropriately labels the data set with descriptive variable names.

# gets columns names
var_names <- colnames(one_dataset)
# removes special characters
var_names <- gsub("[\\(\\)-]", "", var_names)
# replaces abbreviations by words
var_names <- gsub("^f", "freq", var_names)
var_names <- gsub("^t", "time", var_names)
var_names <- gsub("BodyBody|Body","Body",var_names)
var_names <- gsub("Acc", "Accelerometer", var_names)
var_names <- gsub("Gyro", "Gyroscope", var_names)
var_names <- gsub("Mag", "Magnitude", var_names)
var_names <- gsub("Freq", "Frequency", var_names)
var_names <- gsub("mean", "Mean", var_names)
var_names <- gsub("std", "StandardDeviation", var_names)

# puts columns names back
colnames(one_dataset) <- var_names

# 5. From the data set in step 4, creates a second, independent tidy data
# set with the average of each variable for each activity and each subject.

# creates new data frame with means. Calculating means, we exclude first two columns: subject and activity
tidy_data <-ddply(one_dataset, .(subject, activity), function(x) colMeans(x[, -(1:2)]))

# writes tidy_data to a file
write.table(tidy_data, "tidy_data.txt", row.name=FALSE)
