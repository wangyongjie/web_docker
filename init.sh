#!/bin/bash

# $1 :: project
# $2 :: branch

sh ./update.sh $1 $2
docker-compose -f docker-compose.yml up -d