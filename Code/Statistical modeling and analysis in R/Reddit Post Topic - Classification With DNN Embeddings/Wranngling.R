rm(list = ls())
library(data.table)
library(Metrics)


train <- fread('./project/volume/data/raw/train_data.csv')
test <- fread('./project/volume/data/raw/test_data.csv')
train_emb <- fread('./project/volume/data/interim/train_emb.csv')
test_emb <- fread('./project/volume/data/interim/test_emb.csv')

#For train, give all reddit 0 first and then give them 1-9 value. For test, reddit be 0
train$reddit <- 0
train$reddit[train$subredditCooking == 1] <- 1
train$reddit[train$subredditMachineLearning == 1] <- 2
train$reddit[train$subredditmagicTCG == 1] <- 3
train$reddit[train$subredditpolitics == 1] <- 4
train$reddit[train$subredditReal_Estate == 1] <- 5
train$reddit[train$subredditscience == 1] <- 6
train$reddit[train$subredditStockMarket == 1] <- 7
train$reddit[train$subreddittravel == 1] <- 8
train$reddit[train$subredditvideogames == 1] <- 9
test$reddit <- 0
train$subredditcars <- NULL
train$subredditCooking <- NULL
train$subredditMachineLearning <- NULL
train$subredditmagicTCG <- NULL
train$subredditpolitics <- NULL
train$subredditReal_Estate <- NULL
train$subredditscience <- NULL
train$subredditStockMarket <- NULL
train$subreddittravel <- NULL
train$subredditvideogames <- NULL

#Put them together
master_dt <- rbind(train, test)
master_emb <- rbind(train_emb, test_emb)
master <- cbind(master_dt, master_emb)
#We dont need text data
master$text <- NULL
fwrite(master, './project/volume/data/interim/master.csv')