# baby-names

Data exploration on baby names in Poland (2000-2023)

## Data prep

1. Download and reformat data

```
# data_extraction
bash extract.sh
```

2. Produce input data for interactive viz

```
cat analysis.sql | duckdb
```
