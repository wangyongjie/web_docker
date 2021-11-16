#!/bin/bash

project="all"
branch="master"

if [ "$1" != '' ]; then
    project=$1
fi
if [ "$2" != '' ]; then
    branch=$2
fi

if [ "$project" == 'admin_frontend_template' ] || [ "$project" == 'all' ]; then
    echo '-------start update admin_frontend_template-------'
    cd ../
    if [ ! -d './admin_frontend_template' ]; then
        git clone -b $branch http://120.77.236.161/git/PublicGroup/admin_frontend_template.git
    fi
    cp web_docker/build/docker-build.sh admin_frontend_template/docker-build.sh
    cp web_docker/build/build.sh admin_frontend_template/build.sh
    cd admin_frontend_template
    sh ./docker-build.sh
    echo '-------end update admin_frontend_template-------'
fi
