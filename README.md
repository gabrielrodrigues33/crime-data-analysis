# Osasco Crime Data Analysis

## Dataset

The base dataset is [crime in São Paulo](https://data.world/maszanchi/crime-in-sao-paulo), filtered for 2014 Osasco occurrences.  

## Load Credentials (optional)

To use remote server, get credentials at `.env` (template: `.env.example`) and at `src/ports/get_db_remote.R`.

## Migrate database

```
source .env
./prepare-database.sh (local|remote)
```

Use `remote` if you want to use remote server (credentials must be set), defaults to local.

# Complete setup script
```
source .env
./prepare-database.sh (local|remote)
Rscript src/preprocessing/preprocessing.R
Rscript src/load_data.R
Rscript src/analysis/clustering.R
```

