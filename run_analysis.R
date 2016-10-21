library(plyr)

if(!file.exists("./quizeData")){dir.create("./quizeData")}
url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(url ,destfile="./quizeData/quizeDataset.zip", method="curl")

unzip(zipfile="./quizeData/quizeDataset.zip", exdir="./quizeData")

quizeDir <- file.path("./quizeData" , "UCI HAR Dataset")
files <- list.files(quizeDir, recursive=TRUE)

activityTrainData <- read.table(file.path(quizeDir, "train", "y_train.txt"), header = FALSE)
activityTestData  <- read.table(file.path(quizeDir, "test" , "y_test.txt" ), header = FALSE)

subjectTrainData <- read.table(file.path(quizeDir, "train", "subject_train.txt"), header = FALSE)
subjectTestData  <- read.table(file.path(quizeDir, "test" , "subject_test.txt"), header = FALSE)

featuresTrainData <- read.table(file.path(quizeDir, "train", "X_train.txt"), header = FALSE)
featuresTestData  <- read.table(file.path(quizeDir, "test" , "X_test.txt" ), header = FALSE)

subjectData <- rbind(subjectTrainData, subjectTestData)
activityData <- rbind(activityTrainData, activityTestData)
featuresData <- rbind(featuresTrainData, featuresTestData)

names(subjectData) <- c("subject")
names(activityData) <- c("activity")
featuresDataNames <- read.table(file.path(quizeDir, "features.txt"), head = FALSE)
names(featuresData) <- featuresDataNames$V2

combinedData <- cbind(subjectData, activityData)
Data <- cbind(featuresData, combinedData)

featuresSubdataNames <- featuresDataNames$V2[grep("mean\\(\\)|std\\(\\)", featuresDataNames$V2)]

selectedNames <- c(as.character(featuresSubdataNames), "subject", "activity" )
Data <-subset(Data, select = selectedNames)

activityLabels <- read.table(file.path(quizeDir, "activity_labels.txt"), header = FALSE)
Data$activity <- factor(Data$activity, labels = as.character(activityLabels$V2))

names(Data)<-gsub("^t", "time", names(Data))
names(Data)<-gsub("^f", "frequency", names(Data))
names(Data)<-gsub("Acc", "Accelerometer", names(Data))
names(Data)<-gsub("Gyro", "Gyroscope", names(Data))
names(Data)<-gsub("Mag", "Magnitude", names(Data))
names(Data)<-gsub("BodyBody", "Body", names(Data))

SecondData <- aggregate(. ~subject + activity, Data, mean)
SecondData <- SecondData[order(SecondData$subject, SecondData$activity),]
write.table(SecondData, file = "tidydata.txt",row.name = FALSE)