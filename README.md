# baby-names

Data exploration on baby names in Poland (2000-2023)

Raw data can be accessed [here](data).

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

## Sources

[Otwarte dane](https://dane.gov.pl/pl/dataset/219) (CC0 1.0)
