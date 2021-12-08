library(RPostgreSQL)
library(RPostgres)
library(data.table)
library(ggplot2)
library(dplyr)

if (!dir.exists('figures')) dir.create('figures')

db <- 'core' 
host_db <- 'localhost'
db_port <- '5432'  
db_user <- 'root'  
db_password <- 'root'

connect <- dbConnect(RPostgres::Postgres(), dbname = db, host=host_db, port=db_port, user=db_user, password=db_password)  

pessoa <- dbGetQuery(connect, "select * from pessoa")

# age histogram
pessoa_idade_quantile <- na.omit(pessoa) %>%
  summarize(lower=quantile(idade, probs=0.025),
            upper=quantile(idade, probs=0.975),
            mean=mean(idade),
            median=median(idade))

na.omit(pessoa) %>%
  filter(idade <= 100) %>% 
    ggplot(aes(x=idade), fill="skyblue3") +
    geom_histogram(binwidth=1, fill="#69b3a2", color="#e9ecef", alpha=0.9) +
    labs(y="Número boletins de ocorrência", x="Idade") +
    geom_vline(data=pessoa_idade_quantile, aes(xintercept=lower), linetype="dashed", col="red") +
    geom_vline(data=pessoa_idade_quantile, aes(xintercept=upper), linetype="dashed", col="red") +
    geom_vline(data=pessoa_idade_quantile, aes(xintercept=mean), linetype="dashed", col="darkblue") +
    geom_vline(data=pessoa_idade_quantile, aes(xintercept=median), linetype="dashed", col="yellow4")
ggsave("figures/age_hist.png")
  
# sex histogram
ggplot(as.data.frame(table(pessoa$sexo))[-2,], aes(x=Var1, y=Freq, fill=Var1)) +
  geom_bar(stat="identity", fill="skyblue3") +
  geom_text(aes(label=Freq), vjust=0) +
  labs(y="Número boletins de ocorrência", x="Sexo") +
  theme(legend.position="none")
ggsave("figures/sex_hist.png")

# cor histogram
na.omit(pessoa) %>%
  filter(cor != "NULL" & cor != "Vermelha" & cor != "Outros") %>%
    ggplot(aes(x=cor), fill='skyblue3', stat="count") +
    geom_bar(fill="skyblue3") +
    labs(y="Número de boletins de ocorrência", x="Cor")
ggsave("figures/cor_hist.png")