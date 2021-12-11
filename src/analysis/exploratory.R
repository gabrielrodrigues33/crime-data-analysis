library(RPostgreSQL)
library(RPostgres)
library(data.table)
library(ggplot2)
library(dplyr)
library(tm)
library(SnowballC)
library(wordcloud)
library(RCurl)
library(XML)
library(stringr)


if (!dir.exists('figures')) dir.create('figures')


source("src/ports/get_db_remote.R")
#source("src/ports/get_db_local.R")
connect <- dbConnect(RPostgres::Postgres(), dbname = db.name, host=db.host, port=db.port, user=db.user, password=db.password)

pessoa <- dbGetQuery(connect, "select * from pessoa")
ocorrencias <- dbGetQuery(connect, "select * from ocorrencias")

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

# education histogram
na.omit(pessoa) %>%
  filter(grau_instrucao != "NULL") %>%
  ggplot(aes(x=grau_instrucao, fill=grau_instrucao), stat="count") +
  geom_bar() +
  labs(y="Número de boletins de ocorrência", x="Grau de instrução") +
  theme(axis.ticks.x=element_blank())
ggsave("figures/education_hist.png")

# violin plot
na.omit(pessoa) %>%
  filter(cor != "NULL" & cor != "Vermelha" & cor != "Outros") %>%
    ggplot(aes(x=cor, y=idade, fill=cor)) +
    geom_violin(trim=FALSE)
ggsave("figures/idade_cor_violin.png")

# time histogram
hora_ocorrencia <- ocorrencias[ocorrencias$hora_ocorrencia != "NULL",]$hora_ocorrencia
hora_ocorrencia <- strptime(hora_ocorrencia, format="%H:%M")
hora_ocorrencia <- as.numeric(format(hora_ocorrencia, format="%H"))
png("figures/time_hist.png")
hist(hora_ocorrencia, breaks=23, xlim=c(0,23), col="skyblue3",
     xlab="Hora", ylab="Número de boletins de ocorrência", main=NULL,
     xaxt='n')
axis(1, at=seq(0,23))
dev.off()

# word cloud
#profissao_pessoa <- pessoa[pessoa$profissao != "NULL" & pessoa$profissao != "POLICIAL MILITAR",]
profissao_pessoa <- pessoa[pessoa$profissao != "NULL",]
profissao_pessoa <- as.data.frame(table(profissao_pessoa$profissao))
wordcloud(words = profissao_pessoa$Var1, freq = profissao_pessoa$Freq, min.freq = 80,
          max.words=100, random.order=FALSE,
          colors=brewer.pal(8, "Dark2"))
