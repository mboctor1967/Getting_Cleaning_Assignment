#beging of run_analysis
library(plyr);

#point to my project directory
path_rf <- "UCI HAR Dataset"
files<-list.files(path_rf, recursive=TRUE)

#read test and train files
print ("reading text and train data ...")
dataActivityTest  <- read.table(file.path(path_rf, "test" , "Y_test.txt" ),header = FALSE)
dataActivityTrain <- read.table(file.path(path_rf, "train", "Y_train.txt"),header = FALSE)
dataSubjectTrain <- read.table(file.path(path_rf, "train", "subject_train.txt"),header = FALSE)
dataSubjectTest  <- read.table(file.path(path_rf, "test" , "subject_test.txt"),header = FALSE)
dataFeaturesTest  <- read.table(file.path(path_rf, "test" , "X_test.txt" ),header = FALSE)
dataFeaturesTrain <- read.table(file.path(path_rf, "train", "X_train.txt"),header = FALSE)

#combine test and train files
print ("Combining Train & Test data ...")
dataSubject <- rbind(dataSubjectTrain, dataSubjectTest)
dataActivity<- rbind(dataActivityTrain, dataActivityTest)
dataFeatures<- rbind(dataFeaturesTrain, dataFeaturesTest)

#set names to each dataset
names(dataSubject)<-c("subject")
names(dataActivity)<- c("activity")

#reading features data ....
dataFeaturesNames <- read.table(file.path(path_rf, "features.txt"),head=FALSE)
names(dataFeatures)<- dataFeaturesNames$V2

#combine all datasets int Data
dataCombine <- cbind(dataSubject, dataActivity)
Data <- cbind(dataFeatures, dataCombine)

#subset all fields with mean and std text in them + subject & activity
print ("Extracting all std/mean columns ...")
subdataFeaturesNames<-dataFeaturesNames$V2[grep("mean\\(\\)|std\\(\\)", dataFeaturesNames$V2)]
selectedNames<-c(as.character(subdataFeaturesNames), "subject", "activity" )
Data<-subset(Data,select=selectedNames)

#add column to include activitytext based on activity_labels mapping file
print ("Mapping activity level ...")
activityLabels <- read.table(file.path(path_rf, "activity_labels.txt"),header = FALSE)
Data$activitytext <- c("")
for (i in 1:nrow(Data)) {
  Data$activitytext [i] <- as.character(activityLabels [Data$activity[i],2])
}

#rename the column names
names(Data)<-gsub("^t", "Time", names(Data))
names(Data)<-gsub("^f", "Frequency", names(Data))
names(Data)<-gsub("Acc", "Accelerometer", names(Data))
names(Data)<-gsub("Gyro", "Gyroscope", names(Data))
names(Data)<-gsub("Mag", "Magnitude", names(Data))
names(Data)<-gsub("BodyBody", "Body", names(Data))

# extract key columns and write to tidydata subet & file
print ("Forming & writting Tidy Data ...")
tidydata <-aggregate(. ~subject + activitytext, Data, mean)
tidydata <- tidydata[order(tidydata$subject, tidydata$activitytext),]
write.table(tidydata, file = "tidydata.txt",row.name=FALSE)

# end
