#SVM
#install.packages('e1071')
library(forecast)
library(rpart)
library(rpart.plot)
library(e1071)

setwd("C:/rworking")
r <- read.csv(file="C:/rworking/gt_full.csv")

r1 <- r[,1:11] 

# partition
set.seed(1)  
train.index <- sample(c(1:dim(r1)[1]), dim(r1)[1]*0.7)  
train1.df <- r1[train.index, ]
valid1.df <- r1[-train.index, ]
train.df <- train1.df[,-1] # r csv 불러오기
valid.df <- valid1.df[,-1]

#obj <- tune(svm, TEY~., data = train.df, kernel="linear",
#            ranges = list(cost = 2^(0:5)),
#            tunecontrol = tune.control(sampling = "fix"))

obj <- tune(svm, TEY~., data = train.df, kernel="sigmoid",
            ranges = list(gamma = 2^(-9:0), cost = 2^(0:5), czero = 2^(0:5)),
            tunecontrol = tune.control(sampling = "fix"))


#obj <- tune(svm, TEY~., data = train.df, kernel="polynomial",
#            ranges = list(gamma = 2^(-9:0),  cost = 2^(0:5),czero = 2^(0:5)),
#           tunecontrol = tune.control(sampling = "fix"))

summary(obj)
plot(obj)

#svm.model <- svm(TEY~.,data=train.df, kernel="radial",gamma= 0.0078125, cost =32)
svm.model <- svm(TEY~.,data=train.df, kernel="sigmoid",gamma= 0.001953125, cost =1, czero=1)
summary(svm.model)
svm.pred <- predict(svm.model, valid.df)
accuracy(svm.pred, valid.df$TEY)



