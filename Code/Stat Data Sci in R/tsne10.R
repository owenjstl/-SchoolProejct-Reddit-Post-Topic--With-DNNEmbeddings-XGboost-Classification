rm(list = ls())
library(httr)
library(data.table)
library(Rtsne)
library(ClusterR)
library(Metrics)

set.seed(1)

#Read master
master <- fread('./project/volume/data/interim/master.csv')

#Save id and reddit only keep 512 features
id<-master$id
reddit<-master$reddit
master$id<-NULL
master$reddit<-NULL

tsne1 <- Rtsne(master, 
               perplexity = 5, 
               check_duplicates = F)
tsne2 <- Rtsne(master, 
               perplexity = 25, 
               check_duplicates = F)
tsne3 <- Rtsne(master, 
               perplexity = 50, 
               check_duplicates = F)
tsne4 <- Rtsne(master, 
               perplexity = 100, 
               check_duplicates = F)
tsne5 <- Rtsne(master, 
               perplexity = 120, 
               check_duplicates = F)
tsne6 <- Rtsne(master, 
               perplexity = 150, 
               check_duplicates = F)
tsne7 <- Rtsne(master, 
               perplexity = 175, 
               check_duplicates = F)
tsne8 <- Rtsne(master, 
               perplexity = 200, 
               check_duplicates = F)
tsne9 <- Rtsne(master, 
               perplexity = 250, 
               check_duplicates = F)
tsne10 <- Rtsne(master, 
               perplexity = 300, 
               check_duplicates = F)

#save them
tsne_1 <- data.table(tsne1$Y)
tsne_2 <- data.table(tsne2$Y)
tsne_3 <- data.table(tsne3$Y)
tsne_4 <- data.table(tsne4$Y)
tsne_5 <- data.table(tsne5$Y)
tsne_6 <- data.table(tsne6$Y)
tsne_7 <- data.table(tsne7$Y)
tsne_8 <- data.table(tsne8$Y)
tsne_9 <- data.table(tsne9$Y)
tsne_10 <- data.table(tsne10$Y)


tsne_dt <- cbind(tsne_1, tsne_2, tsne_3, tsne_4, tsne_5, tsne_6, tsne_7, tsne_8, tsne_9, tsne_10)
fwrite(tsne_dt,'./project/volume/data/interim/tsne10.csv')


