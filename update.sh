#!/bin/bash

project="all"
branch="master"

if [ "$1" != '' ]; then
    project=$1
fi
if [ "$2" != '' ]; then
    branch=$2
fi

if [ "$project" == 'vue-admin-template' ] || [ "$project" == 'all' ]; then
    echo '-------start update vue-admin-template-------'
    cd ../
    if [ ! -d './vue-admin-template' ]; then
        git clone -b $branch https://github.com/PanJiaChen/vue-admin-template.git
    fi
    cp web_docker/build/docker-build.sh vue-admin-template/docker-build.sh
    cp web_docker/build/build.sh vue-admin-template/build.sh
    cd vue-admin-template
    sh ./docker-build.sh
    echo '-------end update vue-admin-template-------'
fi
