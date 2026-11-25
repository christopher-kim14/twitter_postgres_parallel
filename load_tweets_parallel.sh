#!/bin/bash
# NOTE: bash (not sh) because `time` on a whole pipeline is a bash feature

# ports must match docker-compose.yml
DB_NORMALIZED=postgresql+psycopg2://postgres:pass@localhost:17442/
DB_NORMALIZED_BATCH=postgresql+psycopg2://postgres:pass@localhost:17443/

files=$(find data/*)

# GNU parallel runs the given command once per line of stdin (one line per data file),
# appending that line as the final argument; all 10 commands run at the same time

echo '================================================================================'
echo 'load pg_denormalized'
echo '================================================================================'
time echo "$files" | parallel sh load_denormalized.sh

echo '================================================================================'
echo 'load pg_normalized'
echo '================================================================================'
time echo "$files" | parallel python3 -u load_tweets.py --db=$DB_NORMALIZED --inputs

echo '================================================================================'
echo 'load pg_normalized_batch'
echo '================================================================================'
time echo "$files" | parallel python3 -u load_tweets_batch.py --db=$DB_NORMALIZED_BATCH --inputs
