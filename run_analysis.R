# load plyr package to work with data frame
library(plyr)

#there is two set of volunteer, one will do the test, one will do the training
#feature.txt include the code and all the features/measurement categories
#y train and y_test match the activity label with the recording data in x txt
#activty label: the code and the corresponding activty names
#subject test identify the subject by using code

#STEP 1: merge train and test dataset 
#first we load the data, and find the common column
#train folder
train_x<-read.table("./UCI HAR Dataset/train/X_train.txt")
train_y_activity<-read.table("./UCI HAR Dataset/train/y_train.txt", col.names = "activitylabels")
train_subject<-read.table("./UCI HAR Dataset/train/subject_train.txt", col.names = "subjectcode")

#combine all the data from TRAIN folder. do not use merge!!!
library(dplyr)
data_train <- cbind(train_subject, train_y_activity, train_x)

#repeat the same thing with the test folder
test_x<-read.table("./UCI HAR Dataset/test/X_test.txt")
test_y_activity<-read.table("./UCI HAR Dataset/test/y_test.txt", col.names = "activitylabels")
test_subect<-read.table("./UCI HAR Dataset/test/subject_test.txt", col.names = "subjectcode")

#combine all TEST data. Use cbind so that is faster compared to merge
data_test <- cbind(test_subect, test_y_activity, test_x)

#finally combine train and test data into one big data  row to row
data_all<-rbind(data_train, data_test)


#STEP 2: since we only need the mearsurement for mean and SD -> work on feature.txt first
features<-read.table("./UCI HAR Dataset/features.txt", col.names = c("code", "measurements"))
#grab only the measurement with mean and SD
features_select<-grep("mean|std", features$measurement)
# this give indexes of values that satisfy the condition.

#Plus 2 since data all has 563 while features has only 561 due to the subject 
#and label column
#data2 is all column 1 2 of data_all but only select the column that match the feature
#index indicated above +2 (lui lai 2 column)

data_all2<-data_all[, c(1, 2, features_select + 2)]

#STEP 3: use descriptive names to names the activity in the dataset
#match the activity label in y dataset with the activity label.txt
activity_txt <- read.table("./UCI HAR Dataset/activity_labels.txt", col.names = c("n", "activity_name"))

#now find and match n with activity label in data_all dataset
#replace old value of activitylables column in data_all with the matching pair
#from the activty _ txt
data_all2$activitylabels <- activity_txt[match(data_all$activitylabels, activity_txt$n), 2]

#STEP 4: Label data set with descriptive names USING features txt that only has mean
#and STD value , assign the name to data_all
names(data_all2)[-c(1, 2)] <- features[features_select, 2]


#Step 5 create a second data table with mean of each feature of each subject and each activity
#best to use aggregate function
Tidy_Data <- aggregate(data_all2[,3:81], by = list(activity = data_all2$activitylabels, subject = data_all2$subjectcode),FUN = mean)
# now save it to the working directory
write.table(x = Tidy_Data, file = "Tidy_data.txt", row.names = FALSE)



