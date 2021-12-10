# source("src/ports/get_db_remote.R")
source("src/ports/get_db_local.R")
con <- dbConnect(RPostgres::Postgres(), dbname = db, host=host_db, port=db_port, user=db_user, password=db_password)  

df <- read.csv("data/osasco_2014.csv", sep = ",", encoding = "UTF-8")

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
