### load packages
library(dplyr)
library(tidyr)

### 1. Merges the training and the test sets to create one data set

## assign directories to variables
mainDir <- paste0("~/Documents/Online Courses/Coursera 'Data Science' Specialization/",
                  "Course 3 - Getting and Cleaning Data/Project/UCI HAR Dataset/")
trainDir <- paste0("~/Documents/Online Courses/Coursera 'Data Science' Specialization/",
                   "Course 3 - Getting and Cleaning Data/Project/UCI HAR Dataset/train/")
testDir <- paste0("~/Documents/Online Courses/Coursera 'Data Science' Specialization/",
                   "Course 3 - Getting and Cleaning Data/Project/UCI HAR Dataset/test/")

## set working directory
setwd(mainDir)

## load all files into variables
features <- read.table("features.txt")
activities <- read.table("activity_labels.txt")
subject.test <- read.table(paste0(testDir,"subject_test.txt"))
x.test <- read.table(paste0(testDir,"X_test.txt"))
y.test <- read.table(paste0(testDir,"y_test.txt"))
subject.train <- read.table(paste0(trainDir,"subject_train.txt"))
x.train <- read.table(paste0(trainDir,"X_train.txt"))
y.train <- read.table(paste0(trainDir,"y_train.txt"))

## attach variable names from 'features' to train and test data
names(x.test)  <- features$V2
names(x.train)  <- features$V2

## attach activity column (y.test/train) to data sets and rename
x.test <- cbind(y.test, x.test)
x.train <- cbind(y.train, x.train)
names(x.test)[1] <- "activity"
names(x.train)[1] <- "activity"

## attach subject column to data sets and rename
x.test <- cbind(subject.test, x.test)
x.train <- cbind(subject.train, x.train)
names(x.test)[1] <- "subject"
names(x.train)[1] <- "subject"

## combine test and train data sets
complete <- rbind(x.test, x.train)

## remove original variables now that data set is merged
rm(features, subject.test, subject.train, y.test, y.train, x.test, x.train)

### 2. Extracts only the measurements on the mean and standard deviation for 
###    each measurement.

## remove duplicate column names (and then remove temporary variables)
a <- duplicated(names(complete))
b <- which(a %in% TRUE)
complete.f <- complete[,-b]
rm(a,b)

### select columns that contain 'mean()' and 'std()'
### and leave 'subject' and 'activity' columns
complete.f <- select(complete.f, subject, activity, contains("mean()"), 
                     contains("std()"))
### what about meanFreq() NO--explicitly state in codebook
### what about angle...mean (555:561)? NO--explicitly state in codebook

### 3. Uses descriptive activity names to name the activities in the data set

## merge activity names to data set
complete.f <- merge(complete.f, activities, by.x="activity", by.y="V1")

## remove original numerical activity column, rename activity names column as
## "activity", and sort the data set by subject and activity
complete.f <- complete.f %>% select(-activity) %>% rename(activity = V2) %>% 
    arrange(subject, activity)

### 4. Appropriately labels the data set with descriptive variable names

## replace hyphens "-" with periods "."
names(complete.f) <- gsub("-",".", names(complete.f), fixed=TRUE)

## add ".mean" or ".std" to the end of the variable names
names(complete.f)[grep("mean()", names(complete.f), fixed = TRUE)] <- 
    paste0(names(complete.f)[grep("mean()", names(complete.f), fixed = TRUE)], 
           ".mean")
names(complete.f)[grep("std()", names(complete.f), fixed = TRUE)] <- 
    paste0(names(complete.f)[grep("std()", names(complete.f), fixed = TRUE)], 
           ".std")

## remove original "mean()" or "std()" from variable names
names(complete.f) <- gsub(".mean()", "", names(complete.f), fixed=TRUE)
names(complete.f) <- gsub(".std()", "", names(complete.f), fixed=TRUE)

## move activity to the second column
complete.f <- select(complete.f, subject, activity, ends_with("mean"), 
                     ends_with("std"))

### 5. From the data set in step 4, creates a second, independent tidy data set 
### with the average of each variable for each activity and each subject

## create tidy data set with four columns (subject, activity, variable, value)
tidy <- complete.f %>% gather("variable", "value", -(1:2))

## group by first three columns and find average of each variable for each 
## activity and subject
tidy <- tidy %>% group_by(subject, activity, variable) %>% 
        summarize(average = mean(value))

### Please upload the tidy data set created in step 5 of the instructions. 
### Please upload your data set as a txt file created with write.table() using 
### row.name=FALSE
write.table(tidy, file = "tidy.txt", row.names = FALSE)