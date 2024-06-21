#!/usr/bin/env bash

python3 get_raw_data.py
cat process.sql | duckdb
rm -rf baby_names_pl*
