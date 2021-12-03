raw_osasco <- read.csv("data/raw_osasco_2014.csv")

remove_colnames <- c("ID_DELEGACIA",
                     "DESDOBRAMENTO",
                     "FLAG_STATUS.1",
                     "CONT_PESSOA")


new_colnames <- setdiff(colnames(raw_osasco), remove_colnames)

raw_osasco <- raw_osasco[new_colnames]

colnames(raw_osasco) <- c("num_ocorrencia",
                          "ano_ocorrencia",
                          "nome_departamento",
                          "nome_seccional",
                          "nome_delegacia",
                          "nome_departamento_circ",
                          "nome_seccional_circ",
                          "nome_delegacia_circ",
                          "ano_registro",
                          "mes_registro",
                          "data_ocorrencia",
                          "hora_ocorrencia",
                          "flag_status",
                          "rubrica",
                          "conduta",
                          "latitude",
                          "longitude",
                          "cidade",
                          "logradouro",
                          "numero_logradouro",
                          "tipo_envolvimento",
                          "sexo_pessoa",
                          "idade_pessoa",
                          "cor_pessoa",
                          "profissao_pessoa",
                          "grau_instrucao_pessoa")

write.csv(raw_osasco, "data/osasco_2014.csv", row.names=FALSE)
