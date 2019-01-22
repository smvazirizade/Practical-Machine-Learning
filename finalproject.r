#Adding the required libraries
rm(list = setdiff(ls(), lsf.str()))
wants <- c("caret", "ggplot2","corrplot","rpart","rpart.plot","RColorBrewer","rattle","randomForest")
has   <- wants %in% rownames(installed.packages())
if(any(!has)) install.packages(wants[!has])
for (pkg in wants) {library(pkg, character.only = TRUE)}
#Downloading the Data and import it
destfile1 <- "TrainingData.csv"
destfile2 <- "TestData.csv"
URLAddress1 <- "https://d396qusza40orc.cloudfront.net/predmachlearn/pml-training.csv"
URLAddress2 <- "https://d396qusza40orc.cloudfront.net/predmachlearn/pml-testing.csv"
if (!file.exists(destfile1)) {download.file(URLAddress1,destfile1, mode='wb')}
if (!file.exists(destfile2)) {download.file(URLAddress2,destfile2, mode='wb')}
TrainData <- read.csv(destfile1, header = TRUE)
TestData <- read.csv(destfile2, header = TRUE)
dim(TrainData)
#removing the columns they have missing data
TrainDataC <- TrainData[,complete.cases(t(TrainData))]
dim(TrainDataC)
TrainDataCC <-  TrainDataC[,-nearZeroVar(TrainDataC)]
dim(TrainDataCC)
TrainDataCC <-  TrainDataCC[,-c(1,2,3,4,5)]
dim(TrainDataCC)
TestDataC  <- TestData[,complete.cases(t(TrainData))]
TestDataCC <-  TestDataC[,-nearZeroVar(TrainDataC)]
TestDataCC <-  TestDataCC[,-c(1,2,3,4,5)]
dim(TestDataCC)
#Seperating data for Training and Testing
set.seed(1) 
inTrain <- createDataPartition(TrainDataCC$classe, p = 0.7, list = FALSE)
TrainDataCCTrain <- TrainDataCC[inTrain, ]
TrainDataCCTest <- TrainDataCC[-inTrain, ]
dim(TrainDataCCTrain)
dim(TrainDataCCTest)
#Correlation Matirx
corMatrix <- cor(TrainDataCCTrain[,-c(54)])
corrplot(corMatrix, order = "FPC", method = "color", type = "lower", tl.cex = 0.8, tl.col = rgb(0, 0, 0))
#Method 1: Classifaction Tree
set.seed(1)
Method1 <- rpart(classe ~ ., data=TrainDataCCTrain, method="class")
#Method1 <- train(classe ~ ., method="rpart", data=TrainDataCCTrain)
fancyRpartPlot(Method1)
#or rpart.plot(Method1)
predictMethod1 <- predict(Method1, TrainDataCCTest, type = "class")
cmTree <- confusionMatrix(predictMethod1, TrainDataCCTest$classe)
cmTree
plot(cmTree$table, col = cmTree$byClass, main = paste("Accuracy of Decision Tree =", round(cmTree$overall['Accuracy'], 4)))
#Method 2: Random Forest
set.seed(1)
controlRF <- trainControl(method="cv", number=3, verboseIter=FALSE)
Method2 <- randomForest(classe ~ ., data=TrainDataCCTrain, proximity=TRUE)
#Method2 <- train(classe ~ ., data=TrainDataCCTrain, method="rf", trControl=controlRF)
Method2$finalModel
predictMethod2 <- predict(Method2, TrainDataCCTest)
cmRF<- confusionMatrix(predictMethod2, TrainDataCCTest$classe)
cmRF
plot(cmRF$table, col = cmRF$byClass, main = paste("Accuracy of Random Forest  =", round(cmRF$overall['Accuracy'], 4)))
MostImpVars <- varImp(Method2)
MostImpVars
plot(Method2,main="Model error of Random forest model by number of trees")
#Method 3: Generalized Boosted Regression Models
set.seed(1)
controlGBM <- trainControl(method = "repeatedcv", number = 5, repeats = 1)
Method3  <- train(classe ~ ., data=TrainDataCCTrain, method = "gbm", trControl = controlGBM, verbose = FALSE)
Method3
predictMethod3 <- predict(Method3, TrainDataCCTest)
cmGBM <- confusionMatrix(predictMethod3, TrainDataCCTest$classe)
cmGBM
plot(Method3)

#Final Answer, applying the best model
cmTree$overall[1]
cmRF$overall[1]
cmGBM$overall[1]
Results <- predict(Method2,TestDataCC)
Results

