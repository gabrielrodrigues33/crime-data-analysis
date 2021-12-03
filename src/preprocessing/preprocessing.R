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

unique(raw_osasco$nome_departamento)      # remove spaces
unique(raw_osasco$nome_seccional)         # remove spaces
unique(raw_osasco$nome_delegacia)         # remove spaces
unique(raw_osasco$nome_departamento_circ) # remove spaces
unique(raw_osasco$nome_seccional_circ)    # remove spaces
unique(raw_osasco$nome_delegacia_circ)    # remove spaces
unique(raw_osasco$data_ocorrencia)        # do not remove spaces
unique(raw_osasco$hora_ocorrencia)        # do not remove spaces
unique(raw_osasco$flag_status)            # do not remove spaces
unique(raw_osasco$rubrica)                # do not remove spaces
unique(raw_osasco$conduta)                # do not remove spaces
unique(raw_osasco$cidade)                 # do not remove spaces
unique(raw_osasco$logradouro)             # remove spaces
unique(raw_osasco$tipo_envolvimento)      # remove spaces
unique(raw_osasco$sexo_pessoa)            # do not remove spaces
unique(raw_osasco$cor_pessoa)             # remove spaces
unique(raw_osasco$profissao_pessoa)       # remove spaces
unique(raw_osasco$grau_instrucao_pessoa)  # remove spaces

raw_osasco$nome_departamento <- trimws(raw_osasco$nome_departamento)
raw_osasco$nome_seccional <- trimws(raw_osasco$nome_seccional)
raw_osasco$nome_delegacia <- trimws(raw_osasco$nome_delegacia)
raw_osasco$nome_departamento_circ <- trimws(raw_osasco$nome_delegacia_circ)
raw_osasco$nome_seccional_circ <- trimws(raw_osasco$nome_seccional_circ)
raw_osasco$nome_delegacia_circ <- trimws(raw_osasco$nome_delegacia_circ)
raw_osasco$logradouro <- trimws(raw_osasco$logradouro)
raw_osasco$tipo_envolvimento <- trimws(raw_osasco$tipo_envolvimento)
raw_osasco$cor_pessoa <- trimws(raw_osasco$cor_pessoa)
raw_osasco$profissao_pessoa <- trimws(raw_osasco$profissao_pessoa)
raw_osasco$grau_instrucao_pessoa <- trimws(raw_osasco$grau_instrucao_pessoa)

write.csv(raw_osasco, "data/osasco_2014.csv", row.names=FALSE)
