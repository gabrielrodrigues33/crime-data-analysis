# crime-data-analysis

## Load Credentials (optional)

To use remote server, get credentials at `.env` (template: `.env.example`) and at `src/ports/get_db_remote.R`.

## Migrate database

```
source .env
./prepare-database.sh (local|remote)
```

Use `remote` if you want to use remote server (credentials must be set), defaults to local.
