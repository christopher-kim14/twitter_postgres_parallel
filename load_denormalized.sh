#!/bin/sh

# load a single data file (passed as $1) into pg_denormalized;
# this is the same pipeline as in load_tweets_sequential.sh
unzip -p "$1" | sed 's/\\u0000//g' | psql postgresql://postgres:pass@localhost:17441/ -c "COPY tweets_jsonb (data) FROM STDIN csv quote e'\x01' delimiter e'\x02';"
