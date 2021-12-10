# source("src/ports/get_db_remote.R")
source("src/ports/get_db_local.R")
con <- dbConnect(RPostgres::Postgres(), dbname = db.name, host=db.host, port=db.port, user=db.user, password=db.password)  
library(clustMixType)

install.packages(c("cluster", "factoextra"))
library(cluster)
library(factoextra)
library('fpc')
library(caret)

df <- dbGetQuery(con, "
  SELECT latitude, longitude, rubrica_reduzida, 
  CASE WHEN hora_ocorrencia<> 'NULL' THEN SUBSTRING(hora_ocorrencia, 1, 2)::INTEGER ELSE NULL END AS hora_ocorrencia 
  FROM ocorrencias
  JOIN lugar  ON ocorrencias.lugar_key  = lugar.lugar_key
")
df$latitude <- as.numeric(df$latitude)
df$longitude <- as.numeric(df$longitude)
df <- na.omit(df)


processor <- preProcess(df[,c("latitude", "longitude")], method=c("range"))
df_processed <- predict(processor, df[,c("latitude", "longitude")])
df_processed$rubrica_reduzida <- as.factor(df$rubrica_reduzida)

set.seed(123)
# Compute and plot wss for k = 2 to k = 15.
k.max <- 10
wss <- sapply(1:k.max, 
              function(k){sum(kproto(df_processed, k, iter.max = 15 )$tot.withinss)})
wss
plot(1:k.max, wss,
     type="b", pch = 19, frame = FALSE, 
     xlab="Number of clusters K",
     ylab="Total within-clusters sum of squares")

x <- kproto(df_processed, k=6)
x

df_processed$cluster <- as.factor(x$cluster)
summary(subset(df_processed, cluster == 6))
