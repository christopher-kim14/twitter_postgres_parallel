#!/bin/bash

# ports must match docker-compose.yml
DB_DENORMALIZED=postgresql://postgres:pass@localhost:17441/
DB_NORMALIZED=postgresql+psycopg2://postgres:pass@localhost:17442/
DB_NORMALIZED_BATCH=postgresql+psycopg2://postgres:pass@localhost:17443/

files=$(find data/*)

echo '================================================================================'
echo 'load denormalized'
echo '================================================================================'
time for file in $files; do
    echo
    unzip -p "$file" | sed 's/\\u0000//g' | psql $DB_DENORMALIZED -c "COPY tweets_jsonb (data) FROM STDIN csv quote e'\x01' delimiter e'\x02';"
done

echo '================================================================================'
echo 'load pg_normalized'
echo '================================================================================'
time for file in $files; do
    echo
    python3 -u load_tweets.py --db=$DB_NORMALIZED --inputs $file
done

echo '================================================================================'
echo 'load pg_normalized_batch'
echo '================================================================================'
time for file in $files; do
    python3 -u load_tweets_batch.py --db=$DB_NORMALIZED_BATCH --inputs $file
done
