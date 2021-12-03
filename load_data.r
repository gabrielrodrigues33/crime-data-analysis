mkdir('tmp')
df <- read.csv("data/osasco_2014.csv", sep = ",", encoding = "UTF-8")
library(dplyr)

df_tempo <- df %>% distinct(ano_registro, mes_registro)

df_pessoa <- df %>% distinct(tipo_envolvimento, sexo_pessoa, idade_pessoa, cor_pessoa, profissao_pessoa, grau_instrucao_pessoa) %>% replace_na(replace = list(x = "NULL"))
df_pessoa$idade_pessoa <- as.numeric(df_pessoa$idade_pessoa)
write.table(df_tempo, 'tmp/time_dimension.csv', row.names=FALSE, col.names=FALSE, sep=',', na = "null")
write.table(df_pessoa, 'tmp/pessoa_dimension.csv', row.names=FALSE, col.names=FALSE, sep=',', na = "")

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
dbExecute(con, 'COPY pessoa (tipo_envolvimento, sexo, idade, cor, profissao, grau_instrucao) FROM \'/app/tmp/pessoa_dimension.csv\' DELIMITER \',\' CSV;')
