#set the working directory 
setwd("C:/Users/Rawan/Desktop/College Admission")
#validate
getwd()
# read and save the data as dataframe 
college_admission <- read.csv("College_admission.csv")
#view the data
View(college_admission)
#check if there there are any misiing values , with the help of is.na function, 
sum(is.na(college_admission)) 
# check if there are any  outliers  
summary(college_admission)
# check the structure of the data 
str(college_admission) 
#admit
college_admission$admit <- sapply(college_admission$admit, factor)
#ses
college_admission$ses <- sapply(college_admission$ses, factor)
#gender
college_admission$Gender_Male <- sapply(college_admission$Gender_Male, factor)
#race
college_admission$Race <- sapply(college_admission$Race, factor)
#rank
college_admission$rank <- sapply(college_admission$rank, factor)
str(college_admission) 

library(e1071)
par(mfrow=c(1, 2))  # divide graph area in 2 columns
# density plot for 'gpa'
plot(density(college_admission$gpa), main="Density Plot: GPA", ylab="Frequency", sub=paste("Skewness:", round(e1071::skewness(college_admission$gpa), 2)))  
polygon(density(college_admission$gpa), col="blue")
# density plot for 'gre'
plot(density(college_admission$gre), main="Density Plot: GRE", ylab="Frequency", sub=paste("Skewness:", round(e1071::skewness(college_admission$gre), 2)))  
polygon(density(college_admission$gre), col="blue")

library(caret)
#build logistic model 
logit_model <- glm(admit ~ . ,data = college_admission, family="binomial")
#view the summary 
summary((logit_model)) 
#Drop insignificant variables
del_var <- names(college_admission) %in% c("ses","Gender_Male", "Race")
college_new <- college_admission[!del_var] 
#validate the structure
str(college_new)

# split the new data to test and train and calculate the accuracy of logistic model 
# Random sample
college_spilt <- floor(.7 * nrow(college_new))
set.seed(1)
training <- sample(seq_len(nrow(college_new)), size= college_spilt)
#spilt the data to train and test
college_train <- college_new[training, ]
college_test <- college_new[-training, ]

#logistic model 
#training
college_logistic <- glm(admit ~ . ,data =college_train, family="binomial")
#testing 
pre_log <- predict(college_logistic,college_test[-1], type = "response")

#compute the accuracy 
y_pred_num <- ifelse(pre_log > 0.5, 1, 0)
y_pred <- factor(y_pred_num, levels=c(0, 1))
y_act <- college_test$admit
mean(y_pred == y_act) #acc = 72.5%


#SVM model
#training
college_svm <- svm(admit ~ ., college_train)
#testing
pre_svm <- predict(college_svm, college_test[-1])
# confusion matrix
table_svm <- table(college_test$admit, pre_svm)
table_svm
#accuracy
confusionMatrix(table_svm,positive='1') #71.67%

library(mlbench) 

#descsion tree model 
library(rpart)
#training
college_tree <- rpart(admit ~ . ,  data= college_train, method = "class")
#testing 
tree_pre <- predict(college_tree, college_test[-1], type="class")
#confusion matrix
tree_table <- table(college_test$admit, tree_pre)
#acuracy 
confusionMatrix(tree_table,positive='1') #70%

#naive bayes
#training 
college_naive <- naiveBayes(admit ~ . ,  data= college_train)
#testing
naive_pred <- predict(college_naive, college_test[-1])
#confusion matrix
naive_table <- table(college_test$admit, naive_pred)
#acuracy 
confusionMatrix(naive_table,positive='1') 

#Categorize the average of grade point into High, Medium, 
#and Low (with admission probability percentages) and plot it on a point chart. 
library(plyr)
college_gre = mutate(college_admission,GRE_category = ifelse(gre <= 440,"Low",
                                                             ifelse(gre<=580,"Medium","High")))
View(college_gre)          
Freq= table(college_gre$GRE_category)
barplot(Freq)








