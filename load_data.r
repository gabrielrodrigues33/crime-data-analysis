mkdir('tmp')

library('RPostgreSQL')
install.packages('RPostgres')

con<-dbConnect(RPostgres::Postgres())

db <- 'core' 
host_db <- 'localhost'
db_port <- '5432'  
db_user <- 'root'  
db_password <- 'root'

con <- dbConnect(RPostgres::Postgres(), dbname = db, host=host_db, port=db_port, user=db_user, password=db_password)  

df <- read.csv("data/osasco_2014.csv", sep = ",", encoding = "UTF-8")
library(dplyr)
require(data.table)

df_tempo_a <- df %>% distinct(ano_registro, mes_registro) %>% rename(ano=ano_registro, mes=mes_registro)
df$mes_ocorrencia <- month(as.IDate(df$data_ocorrencia, '%d-%m-%Y')) 
df_tempo_b <- df %>% distinct(ano_ocorrencia, mes_ocorrencia) %>% rename(ano=ano_ocorrencia, mes=mes_ocorrencia)
df_tempo <- union(df_tempo_a, df_tempo_b)
write.table(df_tempo, 'tmp/time_dimension.csv', row.names=FALSE, col.names=FALSE, sep=',', na = "")
dbExecute(con, 'COPY tempo (ano, mes) FROM \'/app/tmp/time_dimension.csv\' DELIMITER \',\' CSV;')

df_pessoa <- df %>% distinct(tipo_envolvimento, sexo_pessoa, idade_pessoa, cor_pessoa, profissao_pessoa, grau_instrucao_pessoa) %>% replace_na(replace = list(x = "NULL"))
df_pessoa$idade_pessoa <- as.numeric(df_pessoa$idade_pessoa)
write.table(df_pessoa, 'tmp/pessoa_dimension.csv', row.names=FALSE, col.names=FALSE, sep=',', na = "")
dbExecute(con, 'COPY pessoa (tipo_envolvimento, sexo, idade, cor, profissao, grau_instrucao) FROM \'/app/tmp/pessoa_dimension.csv\' DELIMITER \',\' CSV;')

df_lugar <- df %>% distinct(latitude, longitude, cidade, logradouro, numero_logradouro)
write.table(df_lugar, 'tmp/lugar_dimension.csv', row.names=FALSE, col.names=FALSE, sep=',', na = "")
dbExecute(con, 'COPY lugar (latitude, longitude, cidade, logradouro, numero_logradouro) FROM \'/app/tmp/lugar_dimension.csv\' DELIMITER \',\' CSV;')

delegacia.registro.df <- df %>% select('NOME_DEPARTAMENTO', 'NOME_SECCIONAL', 'DELEGACIA')
delegacia.circ.df <- df %>% select('NOME_DEPARTAMENTO_CIRC', 'NOME_SECCIONAL_CIRC', 'NOME_DELEGACIA_CIRC')
colnames(delegacia.circ.df) <- c('NOME_DEPARTAMENTO', 'NOME_SECCIONAL', 'DELEGACIA')
delegacia.df <- union(delegacia.registro.df, delegacia.circ.df)
write.table(delegacia.df, 'tmp/delegacia_dimension.csv', row.names=FALSE, col.names=FALSE, sep = ',')
dbExecute(con, 'COPY delegacia (nome_departamento, nome_seccional, nome_delegacia) FROM \'/app/tmp/delegacia_dimension.csv\' DELIMITER \',\' CSV;')
