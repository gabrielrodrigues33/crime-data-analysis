library(dplyr)

raw.df <- read.csv(file = 'data/raw_osasco_2014.csv')
delegacia.df <- raw.df %>% select('NOME_DEPARTAMENTO', 'NOME_SECCIONAL', 'DELEGACIA')
write.table(delegacia.df, 'tmp/delegacia_dimension.csv', row.names=FALSE, col.names=FALSE, sep=',')
