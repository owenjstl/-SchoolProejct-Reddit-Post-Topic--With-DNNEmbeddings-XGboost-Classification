rm(list = ls())
library(httr)
library(data.table)
library(caret)
library(Metrics)
library(xgboost)
library(ClusterR)
sleep_for_a_minute <- function() { Sys.sleep(60) }
set.seed(1)

#read
master_data <- fread('./project/volume/data/interim/master.csv')
pca_data <- fread('./project/volume/data/interim/pca.csv')
tsne_data <- fread('./project/volume/data/interim/tsne20.csv') #Use tsne 20
#Choose tsne 

#tsne20 can improve accuracy from tsne10 by 12%

#----------------------------------#
#      Prep Data for Modeling      #
#----------------------------------#

#Use pca 1:25 and split
pca_data <- pca_data[,1:25]
train_data <- master_data[1:200,] #top 200 is train data 
test_data <- master_data[201:20754] #201-20754 is test data 

#cbine them and split
master <- cbind(tsne_data, pca_data) 
train <- master[1:200,]
test <- master[201:20754]

#Give them reddit columns and make them be 0 because I don't wanna they know the answer when they make prediction
trainpre <- cbind(train, type = train_data$reddit)
testpre<- cbind(test, type = test_data$reddit)

y.train <- trainpre$type
y.test <- testpre$type
trainpre$type <- NULL
testpre$type <- NULL

x.train <- as.matrix(trainpre)
x.test <- as.matrix(testpre)


#xgb.Dmatrix:change data structure
dtrain <- xgb.DMatrix(x.train, label = y.train,missing = NA)
dtest <- xgb.DMatrix(x.test, missing = NA)



#----------------------------------#
#     Use cross validation         #
#----------------------------------#

#XGboost related link
#https://rpubs.com/jeandsantos88/search_methods_for_hyperparameter_tuning_in_r
#tune parameter link: https://xgboost.readthedocs.io/en/stable/parameter.html
#for loop example: https://stackoverflow.com/questions/35390449/r-caret-package-tuning-parameters-using-a-data-set
start_time <- Sys.time()

# set my parameters for xgboost training
param <- list(  objective           = "multi:softprob",
                gamma               = 0.01,
                booster             = "gbtree",
                eval_metric         = "mlogloss",
                eta                 = 0.01,
                max_depth           = 4, # make the model more complex and more likely to overfit
                min_child_weight    = 3,
                sub_sample          = 0.8,
                num_class           = 10,
                tree_method = 'hist'
)

#
#Try 1:  gamma = 0.1, eta = 0.3,  maxdepth = 10, min_child_weight = 5, logloss=0.2212
#Try 2:  gamma = 0,01  eta = 0.3, maxdepth = 10, min_child_weight = 5,  logloss=0.205523 
#Try 3:  gamma = 0,01  eta = 0.01, maxdepth = 10, min_child_weight = 5, loglosee=0.2050
#Try 4:  gamma = 0,01  eta = 0.01,, maxdepth = 20 min_child_weight = 5,  logloss=0.2174 (maxdepth should not be large)
#Try 5:  gamma = 0,1  eta = 0.01, maxdepth = 5, min_child_weight = 5,  logloss=0.2046
#Try 6:  gamma = 0,01  eta = 0.01, maxdepth = 5, min_child_weight = 4,  logloss=0.169001 (gamma should be 0.01 and decrease the mcw)
#Try 7:  gamma = 0,01  eta = 0.01, maxdepth = 5, min_child_weight = 4, subsample = 0.75,logloss=0.1863 (Add subsample feature)
#Try 8:  gamma = 0,01  eta = 0.01, maxdepth = 5, min_child_weight = 4, subsample = 0.8,  logloss= 0.1607
#Try 9:  gamma = 0,01  eta = 0.01, maxdepth = 4, min_child_weight = 3, subsample = 0.8,  logloss= 0.1295 (decrease mcw)


XGBfit <- xgb.cv(  params = param, 
                   nfold = 5, 
                   nrounds = 10000, 
                   missing = NA, 
                   data = dtrain, 
                   print_every_n = 25, 
                   early_stopping_rounds = 20)


# Get the best iteration for the training
best_tree_n <- unclass(XGBfit)$best_iteration
new_row <- data.table(t(param))
new_row$best_tree_n <- best_tree_n

test_error <- unclass(XGBfit)$evaluation_log[best_tree_n,]$test_rmse_mean
new_row$test_error <- test_error
hyper_perm_tune <- rbind(new_row, hyper_perm_tune)

#----------------------------------#
# fit the model to all of the data #
#----------------------------------#

watchlist <- list( train = dtrain)

#Fit
XGBfit <- xgb.train( params = param, 
                     nrounds = best_tree_n, 
                     missing = NA, 
                     data = dtrain, 
                     watchlist = watchlist, 
                     print_every_n = 5)
end_time <- Sys.time()



#Predict
pred <- predict(XGBfit, x.test, reshape = T)
pred <- data.table(pred)

#Give them the original name
setnames(pred, c('subredditcars','subredditCooking','subredditMachineLearning','subredditmagicTCG', 'subredditpolitics', 'subredditReal_Estate', 'subredditscience','subredditStockMarket', 'subreddittravel', 'subredditvideogames'))
submit <- cbind(id = test_data$id, pred)
summary(submit)
fwrite(submit,'./project/volume/data/processed/submit11.csv')
Timeuse = end_time - start_time
Timeuse
