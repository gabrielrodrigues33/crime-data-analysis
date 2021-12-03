library(dplyr)
library(RPostgreSQL)

raw.df <- read.csv(file = 'data/raw_osasco_2014.csv')
delegacia.registro.df <- raw.df %>% select('NOME_DEPARTAMENTO', 'NOME_SECCIONAL', 'DELEGACIA')
delegacia.circ.df <- raw.df %>% select('NOME_DEPARTAMENTO_CIRC', 'NOME_SECCIONAL_CIRC', 'NOME_DELEGACIA_CIRC')
colnames(delegacia.circ.df) <- c('NOME_DEPARTAMENTO', 'NOME_SECCIONAL', 'DELEGACIA')
delegacia.df <- union(delegacia.registro.df, delegacia.circ.df)

write.table(delegacia.df, 'tmp/delegacia_dimension.csv', row.names=FALSE, col.names=FALSE, sep = ',')

db <- 'core'
host_db <- 'localhost'
db_port <- '5432'
db_user <- 'root'
db_password <- 'root'

con <- dbConnect(RPostgres::Postgres(), dbname = db, host=host_db, port=db_port, user=db_user, password=db_password)
dbExecute(con, 'COPY delegacia (nome_departamento, nome_seccional, nome_delegacia) FROM \'/app/tmp/delegacia_dimension.csv\' DELIMITER \',\' CSV;')
