rm(list = ls())
library(httr)
library(data.table)
library(Rtsne)
library(ClusterR)
library(Metrics)
library(ggplot2)

set.seed(1)

master <- fread('./project/volume/data/interim/master.csv') #512 features
#The reason I put them together is that I need to make sure the angle is the same for those features

#Save id and reddit only keep 512 features
id<-master$id
reddit<-master$reddit
master$id<-NULL
master$reddit<-NULL

#Do a pca
pca <- prcomp(master)
summary(pca)
pca_dt <- data.table(unclass(pca)$x)
fwrite(pca_dt,'./project/volume/data/interim/pca.csv')