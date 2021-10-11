#!/bin/bash

project="all"
branch="master"

if [ "$1" != '' ]; then
    project=$1
fi
if [ "$2" != '' ]; then
    branch=$2
fi

if [ "$project" == 'admin_frontend_pg' ] || [ "$project" == 'all' ]; then
    echo '-------start update admin_frontend_pg-------'
    cd ../
    if [ ! -d './admin_frontend_pg' ]; then
        git clone -b $branch http://120.77.236.161/git/PgAdmin/admin_frontend_pg.git
    fi
    cp web_docker/build/docker-build.sh admin_frontend_pg/docker-build.sh
    cp web_docker/build/build.sh admin_frontend_pg/build.sh
    cd admin_frontend_pg
    sh ./docker-build.sh
    echo '-------end update admin_frontend_pg-------'
fi
