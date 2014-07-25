#####################################################################################
##                                                                                 ##
## Script to create tidy data set for Getting and Cleaning Data Course Project     ##
## by F. DeBolt, 25 July 2014                                                      ##
##                                                                                 ##
#####################################################################################

## Search for installation of necessary packages
pkgs <- c("plyr","data.table","reshape2")
for (i in 1:length(pkgs)){
  trap<-try(find.package(pkgs[i]),T)
  if(length(grep("Error",trap))>0){
    install.packages(pkgs[i])
  }
}
library(plyr)
library(data.table)
library(reshape2)
# setwd("~/R/Coursera/Getting and Cleaning Data/Course Project")
dataDir <- "./UCI HAR Dataset"

## Read in features to get column names
features <- read.table(file=paste(dataDir,"features.txt",sep="/"),stringsAsFactors=F)
## Clean up column names - remove dots, white spaces, make descriptive
colNames <- features[,2]
# head(colNames)
# tail(colNames)
tidyColNames <- gsub("\\(\\)","",gsub("-","_",colNames))
# length(grep("^(t|f)(.*)mean|std",tidyColNames))
# head(tidyColNames)
# tail(tidyColNames)

## Read in data from files
testSubjects <- read.table(file=paste(dataDir,"test","subject_test.txt",sep="/"))
# head(testSubjects)
testLabels <- read.table(file=paste(dataDir,"test","y_test.txt",sep="/"))
# head(testLabels)
testSet <- read.table(file=paste(dataDir,"test","X_test.txt",sep="/"),col.names=tidyColNames)
# head(testSet[,1:7])
# length(grep("^(t|f)(.*)mean|std",names(testSet),value=T))

trainSubjects <- read.table(file=paste(dataDir,"train","subject_train.txt",sep="/"))
# head(trainSubjects)
trainLabels <- read.table(file=paste(dataDir,"train","y_train.txt",sep="/"))
# head(trainLabels)
trainSet <- read.table(file=paste(dataDir,"train","X_train.txt",sep="/"),col.names=tidyColNames)
# head(trainSet[,1:7])
# length(grep("^(t|f)(.*)mean|std",names(trainSet),value=T))

## Read in activity labels
activityLabels <- read.table(file=paste(dataDir,"activity_labels.txt",sep="/"))

## Assign descriptive activity labels
testActivities <- merge(testLabels,activityLabels,by="V1",type="right",match="all")
# head(testActivities)
trainActivities <- merge(trainLabels,activityLabels,by="V1",type="right",match="all")
# head(trainActivities)
# tail(trainActivities)

## Bind test columns - subject,activity,data
testData <- cbind(subjectID=testSubjects[,1],Activity=testActivities[,2],testSet)
# head(testData[,1:5])
# length(grep("^(t|f)(.*)mean|std",names(testData),value=T))

## Bind train columns - subject,activity,data
trainData <- cbind(subjectID=trainSubjects[,1],Activity=trainActivities[,2],trainSet)
# head(trainData[,1:5])
# length(grep("^(t|f)(.*)mean|std",names(trainData),value=T))

## Bind test and train rows
fullData <- rbind(testData,trainData)
# length(grep("^(t|f)(.*)mean|std",names(fullData),value=T))

## Sort fullData by subject and activity
fullData.srt <- arrange(fullData,subjectID,Activity)
# head(fullData.srt[,1:5],20)

## Get which columns in fullData.srt are means and standard deviations 
## - any feature that starts with t (time) or f (frequency) and contains mean or std
keepCols <- grep("^(t|f)(.*)mean|std",names(fullData.srt))
## Extract as data table subjectID, activity, and mean and std columns
meanStdDT <- data.table(fullData.srt[,c(1:2,keepCols)])
## Assign key columns and sort by them
setkey(meanStdDT,subjectID,Activity)

## Melt data table - put features in rows ("narrow" form of tidy data)
moltenData <- melt(meanStdDT,names(meanStdDT)[1:2],names(meanStdDT)[3:ncol(meanStdDT)],
                   variable.name="Feature",value.name="Measurement")
# head(moltenData)
# summary(moltenData)
## Assign key columns and sort by them
setkey(moltenData,subjectID,Activity,Feature)

## Average for each feature, for each activity for each subject
aggData <- data.table(aggregate(Measurement~subjectID+Activity+Feature,moltenData,mean))
setkey(aggData,subjectID,Activity,Feature)
## Rename value column to reflect that it now contains the average Measurements
setnames(aggData,names(aggData),c(names(aggData)[1:3],"avgMeasurement"))
# summary(aggData)
# head(aggData,80)
# tail(aggData,80)

## Write tidy data to comma delimited text file
write.table(aggData,file="tidy_data.txt",sep=",",row.names=F,quote=F)
