#!/bin/bash

# Load environmental vars from dotenv
set -a
source .env
set +a

# Verify connection props are correct
echo "Connecting to $PGUSER@$PGHOST:$PGPORT/$PGDATABASE"

# Load GTFS into postgres database
npm exec -- gtfs-to-sql --require-dependencies -- gtfs/*.txt | sponge | psql -b

