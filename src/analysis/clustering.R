library(RPostgreSQL)
library(RPostgres)
source("src/ports/get_db_remote.R")
#source("src/ports/get_db_local.R")
con <- dbConnect(RPostgres::Postgres(), dbname = db.name, host=db.host, port=db.port, user=db.user, password=db.password)  
library(clustMixType)

library(cluster)
library(factoextra)
library('fpc')
library(caret)

df <- dbGetQuery(con, "
  SELECT latitude, longitude
  FROM ocorrencias
  JOIN lugar  ON ocorrencias.lugar_key  = lugar.lugar_key
")
df$latitude <- as.numeric(df$latitude)
df$longitude <- as.numeric(df$longitude)
df <- na.omit(df)

processor <- preProcess(df[,c("latitude", "longitude")], method=c("range"))
df_processed <- predict(processor, df[,c("latitude", "longitude")])
df_processed$latitude <- as.numeric(df_processed$latitude)
df_processed$longitude <- as.numeric(df_processed$longitude)

set.seed(123)
k.max <- 8
wss <- sapply(1:k.max, 
              function(k){sum(kmeans(df_processed, k, iter.max = 15 )$tot.withinss)})
wss
plot(1:k.max, wss,
     type="b", pch = 19, frame = FALSE, 
     xlab="Número de Clusters",
     ylab="Erro total dentro dos clusters")

x <- kmeans(df_processed, 4)
df_result <- data.frame(
  latitude = df$latitude,
  longitude = df$longitude,
  cluster = as.factor(x$cluster)
)
dbWriteTable(con, "clustering_result", df_result, append=TRUE)