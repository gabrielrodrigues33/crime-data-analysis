df <- read.csv("data/raw_osasco_2014.csv", sep = ",", encoding = "UTF-8")
library(dplyr)
df_tempo <- df %>% distinct(ANO, MES)

write.table(df_tempo, 'tmp/time_dimension.csv', row.names=FALSE, col.names=FALSE, sep=',')

library('RPostgreSQL')
install.packages('RPostgres')

con<-dbConnect(RPostgres::Postgres())

db <- 'core' 
host_db <- 'localhost'
db_port <- '5432'  
db_user <- 'root'  
db_password <- 'root'

con <- dbConnect(RPostgres::Postgres(), dbname = db, host=host_db, port=db_port, user=db_user, password=db_password)  
dbExecute(con, 'COPY tempo (ano, mes) FROM \'/app/tmp/time_dimension.csv\' DELIMITER \',\' CSV;')
