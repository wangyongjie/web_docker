#!/bin/bash

# $1 :: project
# $2 :: branch

if [$1 eq '']; then
    echo 'Tips: please input project name'
else 
    if [$2 eq '']; then
        ./update.sh $1 master
        docker-compose -f docker-compose.yml up -d
    else 
        ./update.sh $1 $2
        docker-compose -f docker-compose.yml up -d
    fi
fi

