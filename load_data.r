library('RPostgreSQL')
library('lubridate')
library('dplyr')
library('tidyr')
library(data.table)
library('RPostgres')

source("src/ports/get_db_remote.R")
#source("src/ports/get_db_local.R")
con <- dbConnect(RPostgres::Postgres(), dbname = db.name, host=db.host, port=db.port, user=db.user, password=db.password)  

df <- read.csv("data/osasco_2014.csv", sep = ",", encoding = "UTF-8")
df$mes_ocorrencia <- month(as.IDate(df$data_ocorrencia, '%m-%d-%Y')) 
df$dia_ocorrencia <- day(as.IDate(df$data_ocorrencia, '%m-%d-%Y')) 
df$idade_pessoa <- as.numeric(df$idade_pessoa)

df_tempo_a <- df %>% distinct(ano_registro, mes_registro) %>% rename(ano=ano_registro, mes=mes_registro)

df_tempo_b <- df %>% distinct(ano_ocorrencia, mes_ocorrencia) %>% rename(ano=ano_ocorrencia, mes=mes_ocorrencia)
df_tempo <- union(df_tempo_a, df_tempo_b)
df_tempo$tempo_key <- seq.int(nrow(df_tempo))

write.table(df_tempo, 'tmp/time_dimension.csv', row.names=FALSE, col.names=FALSE, sep=',', na = "")
dbWriteTable(con, "tempo", df_tempo, append=TRUE)

df_pessoa <- df %>% distinct(tipo_envolvimento, sexo_pessoa, idade_pessoa, cor_pessoa, profissao_pessoa, grau_instrucao_pessoa) %>% replace_na(replace = list(x = "NULL")) %>% 
    rename(idade = idade_pessoa, sexo = sexo_pessoa, cor = cor_pessoa, profissao = profissao_pessoa, grau_instrucao = grau_instrucao_pessoa) 

df_pessoa$pessoa_key <- seq.int(nrow(df_pessoa))
dbWriteTable(con, "pessoa", df_pessoa, append=TRUE)

df_lugar <- df %>% distinct(latitude, longitude, cidade, logradouro, numero_logradouro)
df_lugar$lugar_key <- seq.int(nrow(df_lugar))
dbWriteTable(con, "lugar", df_lugar, append=TRUE)

delegacia.registro.df <- df %>% select('nome_departamento', 'nome_seccional', 'nome_delegacia')
delegacia.circ.df <- df %>% select('nome_departamento_circ', 'nome_seccional_circ', 'nome_delegacia_circ')
colnames(delegacia.circ.df) <- c('nome_departamento', 'nome_seccional', 'nome_delegacia')
delegacia.df <- union(delegacia.registro.df, delegacia.circ.df)
delegacia.df$delegacia_key <- seq.int(nrow(delegacia.df))
dbWriteTable(con, "delegacia", delegacia.df, append=TRUE)

df_ocorrencia <- df %>% distinct(ano_registro, mes_registro, num_ocorrencia, flag_status, rubrica, rubrica_reduzida, conduta, hora_ocorrencia)
df_joined <- inner_join(df, df_tempo, by = c("ano_registro" = "ano", "mes_registro" = "mes")) %>% rename(tempo_registro_key = tempo_key)
df_joined <- inner_join(df_joined, df_tempo, by = c("ano_ocorrencia" = "ano", "mes_ocorrencia" = "mes")) %>% rename(tempo_ocorrencia_key = tempo_key)
df_joined <- inner_join(df_joined, df_pessoa, by = c("tipo_envolvimento"="tipo_envolvimento", "sexo_pessoa"="sexo", "idade_pessoa"="idade", "cor_pessoa"="cor", "profissao_pessoa"="profissao", "grau_instrucao_pessoa"="grau_instrucao")) 
df_joined <- inner_join(df_joined, df_lugar, by = c("latitude", "longitude", "cidade", "logradouro", "numero_logradouro")) 
df_joined <- inner_join(df_joined, delegacia.df, by = c("nome_departamento_circ" = "nome_departamento", "nome_seccional_circ" = "nome_seccional", "nome_delegacia_circ" = "nome_delegacia")) %>% rename(delegacia_ocorrencia_key = delegacia_key)
df_joined <- inner_join(df_joined, delegacia.df, by = c("nome_departamento", "nome_seccional", "nome_delegacia")) %>% rename(delegacia_registro_key = delegacia_key)
df_joined <- df_joined %>% select( num_ocorrencia, flag_status, rubrica, rubrica_reduzida, conduta, hora_ocorrencia, tempo_registro_key, tempo_ocorrencia_key, pessoa_key, lugar_key, delegacia_registro_key, delegacia_ocorrencia_key)
dbWriteTable(con, "ocorrencias", df_joined, append=TRUE)

dbExecute(con, '
    INSERT INTO ocorrencias_agregada (rubrica, conduta, flag_status, tempo_ocorrencia_key, quantidade_ocorrencias)
    SELECT rubrica, conduta, flag_status, tempo_ocorrencia_key, count(*) 
    from ocorrencias 
    GROUP BY rubrica, conduta, flag_status, tempo_ocorrencia_key')
