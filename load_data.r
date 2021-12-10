if (!dir.exists('tmp')) dir.create('tmp')

library('RPostgreSQL')
library(dplyr)
library('RPostgres')
library(lubridate)
library(data.table)

db <- 'core' 
host_db <- 'localhost'
db_port <- '5432'  
db_user <- 'root'  
db_password <- 'root'

con <- dbConnect(RPostgres::Postgres(), dbname = db, host=host_db, port=db_port, user=db_user, password=db_password)  

df <- read.csv("data/osasco_2014.csv", sep = ",", encoding = "UTF-8")
df$mes_ocorrencia <- month(as.IDate(df$data_ocorrencia, '%d-%m-%Y')) 
df$idade_pessoa <- as.numeric(df$idade_pessoa)

df_tempo_a <- df %>% distinct(ano_registro, mes_registro) %>% rename(ano=ano_registro, mes=mes_registro)

df_tempo_b <- df %>% distinct(ano_ocorrencia, mes_ocorrencia) %>% rename(ano=ano_ocorrencia, mes=mes_ocorrencia)
df_tempo <- union(df_tempo_a, df_tempo_b)
df_tempo$tempo_key <- seq.int(nrow(df_tempo))

write.table(df_tempo, 'tmp/time_dimension.csv', row.names=FALSE, col.names=FALSE, sep=',', na = "")
dbExecute(con, 'COPY tempo (ano, mes, tempo_key) FROM \'/app/tmp/time_dimension.csv\' DELIMITER \',\' CSV;')

df_pessoa <- df %>% distinct(tipo_envolvimento, sexo_pessoa, idade_pessoa, cor_pessoa, profissao_pessoa, grau_instrucao_pessoa) %>% replace_na(replace = list(x = "NULL"))
df_pessoa$pessoa_key <- seq.int(nrow(df_pessoa))
write.table(df_pessoa, 'tmp/pessoa_dimension.csv', row.names=FALSE, col.names=FALSE, sep=',', na = "")
dbExecute(con, 'COPY pessoa (tipo_envolvimento, sexo, idade, cor, profissao, grau_instrucao, pessoa_key) FROM \'/app/tmp/pessoa_dimension.csv\' DELIMITER \',\' CSV;')

df_lugar <- df %>% distinct(latitude, longitude, cidade, logradouro, numero_logradouro)
df_lugar$lugar_key <- seq.int(nrow(df_lugar))
write.table(df_lugar, 'tmp/lugar_dimension.csv', row.names=FALSE, col.names=FALSE, sep=',', na = "")
dbExecute(con, 'COPY lugar (latitude, longitude, cidade, logradouro, numero_logradouro, lugar_key) FROM \'/app/tmp/lugar_dimension.csv\' DELIMITER \',\' CSV;')

delegacia.registro.df <- df %>% select('nome_departamento', 'nome_seccional', 'nome_delegacia')
delegacia.circ.df <- df %>% select('nome_departamento_circ', 'nome_seccional_circ', 'nome_delegacia_circ')
colnames(delegacia.circ.df) <- c('nome_departamento', 'nome_seccional', 'nome_delegacia')
delegacia.df <- union(delegacia.registro.df, delegacia.circ.df)
delegacia.df$delegacia_key <- seq.int(nrow(delegacia.df))
write.table(delegacia.df, 'tmp/delegacia_dimension.csv', row.names=FALSE, col.names=FALSE, sep = ',')
dbExecute(con, 'COPY delegacia (nome_departamento, nome_seccional, nome_delegacia, delegacia_key) FROM \'/app/tmp/delegacia_dimension.csv\' DELIMITER \',\' CSV;')

df_ocorrencia <- df %>% distinct(ano_registro, mes_registro, num_ocorrencia, flag_status, rubrica, conduta, hora_ocorrencia)
df_joined <- inner_join(df, df_tempo, by = c("ano_registro" = "ano", "mes_registro" = "mes")) %>% rename(tempo_registro_key = tempo_key)
df_joined <- inner_join(df_joined, df_tempo, by = c("ano_ocorrencia" = "ano", "mes_ocorrencia" = "mes")) %>% rename(tempo_ocorrencia_key = tempo_key)
df_joined <- inner_join(df_joined, df_pessoa, by = c("tipo_envolvimento", "sexo_pessoa", "idade_pessoa", "cor_pessoa", "profissao_pessoa", "grau_instrucao_pessoa")) 
df_joined <- inner_join(df_joined, df_lugar, by = c("latitude", "longitude", "cidade", "logradouro", "numero_logradouro")) 
df_joined <- inner_join(df_joined, delegacia.df, by = c("nome_departamento_circ" = "nome_departamento", "nome_seccional_circ" = "nome_seccional", "nome_delegacia_circ" = "nome_delegacia")) %>% rename(delegacia_ocorrencia_key = delegacia_key)
df_joined <- inner_join(df_joined, delegacia.df, by = c("nome_departamento", "nome_seccional", "nome_delegacia")) %>% rename(delegacia_registro_key = delegacia_key)
df_joined <- df_joined %>% select( num_ocorrencia, flag_status, rubrica, conduta, hora_ocorrencia, tempo_registro_key, tempo_ocorrencia_key, pessoa_key, lugar_key, delegacia_registro_key, delegacia_ocorrencia_key)
write.table(df_joined, 'tmp/ocorrencia_fact.csv', row.names=FALSE, col.names=FALSE, sep=',', na = "")
dbExecute(con, 'COPY ocorrencias (num_ocorrencia, flag_status, rubrica, conduta, hora_ocorrencia, tempo_registro_key, tempo_ocorrencia_key, pessoa_key, lugar_key, delegacia_registro_key, delegacia_ocorrencia_key) FROM \'/app/tmp/ocorrencia_fact.csv\' DELIMITER \',\' CSV;')



kmodes_df <- df %>% select(flag_status, rubrica, conduta, tipo_envolvimento)
x <- kmodes(kmodes_df, modes=3)

set.seed(123)
# Compute and plot wss for k = 2 to k = 15.
k.max <- 15
data <- kmodes_df
wss <- sapply(1:k.max, 
              function(k){sum(kmodes(data, k, iter.max = 15 )$withindiff)})
wss
plot(1:k.max, wss,
     type="b", pch = 19, frame = FALSE, 
     xlab="Number of clusters K",
     ylab="Total within-clusters sum of squares")

x <- kmodes(kmodes_df, modes=5)
x
kmodes_df$flag_status <- as.factor(kmodes_df$flag_status)
kmodes_df$rubrica <- as.factor(kmodes_df$rubrica)
kmodes_df$conduta <- as.factor(kmodes_df$conduta)
kmodes_df$tipo_envolvimento <- as.factor(kmodes_df$tipo_envolvimento)

kmodes_df$cluster <- as.factor(x$cluster)
summary(subset(kmodes_df, cluster == 1))
