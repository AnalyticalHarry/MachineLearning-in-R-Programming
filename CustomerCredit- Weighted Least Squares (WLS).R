## Author: Hemant Thapa
## Multiple Linear Regression 
## Programming Language: R Programming
## Date Pushed to GitHub: 24.01.2024
## Email: hemantthapa1998@gmail.com

#####################################
######## Loading Libraries ##########
#####################################

#Loading all libraries
library(skimr)
library(RCurl)
library('stringi')
library('ggplot2')
library(dplyr)
library(tidyr)
library(caret)
library(randomForest)
library(glmnet)
library(rpart)

#####################################
######## Loading Data Set ###########
#####################################

# 1. Loading  laod dataset and checking dimension
dataset = read.csv('Credit.csv')

#####################################
######### Pre Processing ############
#####################################

# 2. View tab for showing data set
View(dataset)

# 3. print the first 10 rows
head(dataset, 10)

# 4. print the last 10 rows
tail(dataset, 10)

# 5. Function returns the class of an object
class(dataset)

# 6. Function will return internal structure of R object
str(dataset)

# 7. Function will print unique columns name and data types
sapply(dataset, class)
print(names(dataset))

# 8. Summary statistics 
summary(dataset)

# 9. Missing values 
total_missing_values <- sum(is.na(dataset))
print(paste("Total Missing Values:", total_missing_values))

#####################################
##### Exploratory Data Analysis #####
#####################################

# 10. Histograms for Continuous Variables
hist(dataset$Income, main = "Histogram of Income", xlab = "Income", col = "lightblue")
hist(dataset$Limit, main = "Histogram of Limit", xlab = "Limit", col = "lightblue")
hist(dataset$Rating, main = "Histogram of Rating", xlab = "Rating", col = "lightblue")
hist(dataset$Balance, main = "Histogram of Balance", xlab = "Balance", col = "lightblue")
grid()

# 11. Box Plots for Continuous Variables
boxplot(dataset$Income, main = "Boxplot of Income", ylab = "Income")
boxplot(dataset$Limit, main = "Boxplot of Limit", ylab = "Limit")
boxplot(dataset$Rating, main = "Boxplot of Rating", ylab = "Rating")
boxplot(dataset$Balance, main = "Boxplot of Balance", ylab = "Balance")
grid()

# 12. Correlation Matrix
correlation_matrix <- cor(dataset[, sapply(dataset, is.numeric)])
print(correlation_matrix)

# 13. Scatter Plot for Income vs. Balance
plot(dataset$Income, dataset$Balance, main = "Income vs. Balance", 
     xlab = "Income", ylab = "Balance", pch = 19, col = "blue")
grid()

# 14. Bar Plots for Categorical Variables
barplot(table(dataset$Gender), main = "Gender Distribution", col = "lightblue")
barplot(table(dataset$Student), main = "Student Distribution", col = "lightblue")
barplot(table(dataset$Married), main = "Married Distribution", col = "lightblue")
barplot(table(dataset$Ethnicity), main = "Ethnicity Distribution", col = "lightblue")
grid()

# 15. Feature Selection 
X <- dataset[, c('Balance', 'Income', 'Rating', 'Age')]
y <- dataset$Limit


#####################################
######### Post Processing ###########
#####################################

# Splitting the data into training (80%) and testing (20%) sets
# reproducibility
set.seed(100) 
indexes <- sample(1:nrow(X), size = 0.7 * nrow(X))
train_X <- X[indexes, ]
train_y <- y[indexes]
test_X <- X[-indexes, ]
test_y <- y[-indexes]

#####################################
########## Linear Model #############
#####################################

# 16. Multiple Linear Regression Model
train_model <- lm(train_y ~ ., data = data.frame(train_X, train_y))

# summarising the model
summary(train_model)

# 17. Predicting using the model
train_pred <- predict(train_model, newdata = train_X)
test_pred <- predict(train_model, newdata = test_X)


# viewing the first few predictions
head(train_pred, 20)
head(test_pred, 20)

#####################################
#### Evaluating Model Performance ###
#####################################

evaluate_model <- function(actual, predicted) {
  mse <- mean((predicted - actual) ^ 2)
  rmse <- sqrt(mse)
  mae <- mean(abs(predicted - actual))
  r_squared <- summary(lm(actual ~ predicted))$r.squared
  
  return(list(MSE = mse, RMSE = rmse, MAE = mae, R_Squared = r_squared))
}

# evaluation on Training Data
train_evaluation <- evaluate_model(train_y, train_pred)
print("Training Data Evaluation:")
print(train_evaluation)

# evaluation on Testing Data
test_evaluation <- evaluate_model(test_y, test_pred)
print("Testing Data Evaluation:")
print(test_evaluation)

# residuals
train_residuals <- train_y - train_pred
test_residuals <- test_y - test_pred

# residuals for Training Data
plot(train_pred, train_residuals, main = "Residuals vs Predicted (Training Data)", 
     xlab = "Predicted Values", ylab = "Residuals", pch = 19, col = "blue")
abline(h = 0, col = "red")
grid()

# residuals for Testing Data
plot(test_pred, test_residuals, main = "Residuals vs Predicted (Testing Data)", 
     xlab = "Predicted Values", ylab = "Residuals", pch = 19, col = "blue")
abline(h = 0, col = "red")
grid()

# Residuals for Both Training and Testing Data in a Single Plot
plot(train_pred, train_residuals, 
     main = "Residuals vs Predicted (Training and Testing Data)", 
     xlab = "Predicted Values", ylab = "Residuals", 
     pch = 19, col = "blue", xlim = range(c(train_pred, test_pred)), 
     ylim = range(c(train_residuals, test_residuals)))

points(test_pred, test_residuals, pch = 17, col = "red")
abline(h = 0, col = "black")
legend("topright", legend = c("Training", "Testing"), pch = c(19, 17), col = c("blue", "red"))
grid()

# box plot of Residuals
boxplot(train_residuals, test_residuals, 
        names = c("Training Residuals", "Testing Residuals"), 
        main = "Box Plot of Residuals", col = c("blue", "red"))
grid()

# histogram of Residuals
hist(train_residuals, breaks = 30, main = "Histogram of Training and Testing Residuals", 
     xlab = "Residuals", col = rgb(0, 0, 1, alpha = 0.5), 
     xlim = range(c(train_residuals, test_residuals)), ylim = c(0, max(hist(train_residuals, breaks = 30, plot = FALSE)$counts, 
                                                                       hist(test_residuals, breaks = 30, plot = FALSE)$counts)))
hist(test_residuals, breaks = 30, col = rgb(1, 0, 0, alpha = 0.5),
     add = TRUE)
legend("topright", legend = c("Training Residuals", "Testing Residuals"), 
       fill = c(rgb(0, 0, 1, alpha = 0.5), rgb(1, 0, 0, alpha = 0.5)))
grid()


# KDE Plot of Residuals
plot(density(train_residuals), main = "KDE of Residuals", 
     xlab = "Residuals", ylab = "Density", col = "blue", lwd = 2)
lines(density(test_residuals), col = "red", lwd = 2)
legend("topright", legend = c("Training Residuals", "Testing Residuals"), 
       col = c("blue", "red"), lty = 1, lwd = 2)
grid()

# Cook's Distance for Training set
cook_train_mlr <- cooks.distance(train_model)
plot(cook_train_mlr, pch = 19, main = "Cook's Distance Plot (Train set)", xlab = "Observation", ylab = "Cook's Distance", col = "blue")
abline(h = 4 / length(cook_train_mlr), col = "red")  
grid()

# Cook's Distance for Testing set
cook_test_mlr <- cooks.distance(train_model, newdata = data.frame(test_X, test_y))
plot(cook_test_mlr, pch = 19, main = "Cook's Distance Plot (Test set)", xlab = "Observation", ylab = "Cook's Distance", col = "blue")
abline(h = 4 / length(cook_test_mlr), col = "red") 
grid()

# Influential observations in the Training set
influential_train_mlr <- which(cook_train_mlr > 4 / length(cook_train_mlr))
cat("Influential observations in Training Data (MLR Model):", influential_train_mlr, "\n")

# Influential observations in the Testing set
influential_test_mlr <- which(cook_test_mlr > 4 / length(cook_test_mlr))
cat("Influential observations in Testing Data (MLR Model):", influential_test_mlr, "\n")

#####################################
############# WLS model #############
#####################################

# weights based on the absolute residuals of the training data
weights <- 1/abs(train_residuals)

# fit a Weighted Least Squares (WLS) model
wls_model <- lm(train_y ~ ., data = data.frame(train_X, train_y), weights = weights)

# summarise the WLS model
summary(wls_model)

# predicting using the WLS model
train_pred_wls <- predict(wls_model, newdata = train_X)
test_pred_wls <- predict(wls_model, newdata = test_X)

# viewing the first few predictions from the WLS model
head(train_pred_wls, 20)
head(test_pred_wls, 20)

# evaluating the WLS model on Training Data
train_evaluation_wls <- evaluate_model(train_y, train_pred_wls)
print("Training Data Evaluation (WLS Model):")
print(train_evaluation_wls)

# evaluating the WLS model on Testing Data
test_evaluation_wls <- evaluate_model(test_y, test_pred_wls)
print("Testing Data Evaluation (WLS Model):")
print(test_evaluation_wls)

# residuals for Training Data (WLS Model)
train_residuals_wls <- train_y - train_pred_wls

# residuals for Testing Data (WLS Model)
test_residuals_wls <- test_y - test_pred_wls

# residuals for Training Data (WLS Model)
plot(train_pred_wls, train_residuals_wls, main = "Residuals vs Predicted (Training Data - WLS Model)", 
     xlab = "Predicted Values", ylab = "Residuals", pch = 19, col = "blue")
abline(h = 0, col = "red")
grid()

# residuals for Training Data (WLS Model)
plot(train_pred_wls, train_residuals_wls, main = "Residuals vs Predicted (Training Data - WLS Model)", 
     xlab = "Predicted Values", ylab = "Residuals", pch = 19, col = "blue")
abline(h = 0, col = "red")
grid()


# residuals for Both Training and Testing Data in a Single Plot (WLS Model)
plot(train_pred_wls, train_residuals_wls, 
     main = "Residuals vs Predicted (Training and Testing Data - WLS Model)", 
     xlab = "Predicted Values", ylab = "Residuals", 
     pch = 19, col = "blue", xlim = range(c(train_pred_wls, test_pred_wls)), 
     ylim = range(c(train_residuals_wls, test_residuals_wls)))

points(test_pred_wls, test_residuals_wls, pch = 17, col = "red")
abline(h = 0, col = "black")
legend("topright", legend = c("Training (WLS Model)", "Testing (WLS Model)"), pch = c(19, 17), col = c("blue", "red"))
grid()

# box plot of Residuals (WLS Model)
boxplot(train_residuals_wls, test_residuals_wls, 
        names = c("Training Residuals (WLS Model)", "Testing Residuals (WLS Model)"), 
        main = "Box Plot of Residuals (WLS Model)", col = c("blue", "red"))
grid()

# histogram of Residuals (WLS Model)
hist(train_residuals_wls, breaks = 30, main = "Histogram of Training and Testing Residuals (WLS Model)", 
     xlab = "Residuals", col = rgb(0, 0, 1, alpha = 0.5), 
     xlim = range(c(train_residuals_wls, test_residuals_wls)), ylim = c(0, max(hist(train_residuals_wls, breaks = 30, plot = FALSE)$counts, 
                                                                               hist(test_residuals_wls, breaks = 30, plot = FALSE)$counts)))
hist(test_residuals_wls, breaks = 30, col = rgb(1, 0, 0, alpha = 0.5),
     add = TRUE)
legend("topright", legend = c("Training Residuals (WLS Model)", "Testing Residuals (WLS Model)"), 
       fill = c(rgb(0, 0, 1, alpha = 0.5), rgb(1, 0, 0, alpha = 0.5)))
grid()

# KDE Plot of Residuals (WLS Model)
plot(density(train_residuals_wls), main = "KDE of Residuals (WLS Model)", 
     xlab = "Residuals", ylab = "Density", col = "blue", lwd = 2)
lines(density(test_residuals_wls), col = "red", lwd = 2)
legend("topright", legend = c("Training Residuals (WLS Model)", "Testing Residuals (WLS Model)"), 
       col = c("blue", "red"), lty = 1, lwd = 2)
grid()


# Cook's Distance for Training Data (WLS Model)
cook_train_wls <- cooks.distance(wls_model)
plot(cook_train_wls, pch = 19, main = "Cook's Distance Plot (Train set - WLS)", xlab = "Observation", ylab = "Cook's Distance", col = "blue")
abline(h = 4 / length(cook_train_wls), col = "red")  # Highlight the threshold for influential points
grid()

# Cook's Distance for Testing Data (WLS Model)
cook_test_wls <- cooks.distance(wls_model, newdata = data.frame(test_X, test_y))
plot(cook_test_wls, pch = 19, main = "Cook's Distance Plot (Test set WLS)", xlab = "Observation", ylab = "Cook's Distance", col = "blue")
abline(h = 4 / length(cook_test_wls), col = "red")  # Highlight the threshold for influential points
grid()

# Influential observations in the Training Data (WLS Model)
influential_train_wls <- which(cook_train_wls > 4 / length(cook_train_wls))
cat("Influential observations in Training Data (WLS Model):", influential_train_wls, "\n")

# Influential observations in the Testing Data (WLS Model)
influential_test_wls <- which(cook_test_wls > 4 / length(cook_test_wls))
cat("Influential observations in Testing Data (WLS Model):", influential_test_wls, "\n")
