rm(list = ls())
library(httr)
library(data.table)



getEmbeddings <- function(text){
  input <- list(
    instances = list( text )
  )
  res <- POST("https://dsalpha.vmhost.psu.edu/api/use/v1/models/use:predict", body = input,encode = "json", verbose())
  emb <- unlist(content(res)$predictions)
  emb
}



data <- fread('./project/volume/data/raw/train_data.csv')
emb_dt<-NULL
#loops
for (i in 1:length(data$text)){
  emb_dt<-rbind(emb_dt,getEmbeddings(data$text[i]))
}

emb_dt <- data.table(emb_dt)

fwrite(emb_dt,"./project/volume/data/interim/train_emb.csv")