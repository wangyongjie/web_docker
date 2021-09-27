#!/bin/bash

case $1 in 
    'project1')
        echo '-------start update project1-------'
        cd $(pwd) && cd ../
        if [ ! -d './project1' ]; then
            git clone -b $2 http://xx.xx.xx.xx/git/project1.git
        fi
        cp docker-compose/build/docker-build.sh project1/docker-build.sh
        cp docker-compose/build/build.sh project1/build.sh
        cd project1
        sh ./docker-build.sh
        echo '-------end update project1-------'
    ;;
    'project2')
        echo '-------start update project2-------'
        cd $(pwd) && cd ../
        if [ ! -d './project2' ]; then
            git clone -b $2 http://xx.xx.xx.xx/git/project2.git
        fi
        cp docker-compose/build/docker-build.sh project2/docker-build.sh
        cp docker-compose/build/build.sh project2/build.sh
        cd project2
        sh ./docker-build.sh
        echo '-------end update project2-------'
    ;;
esac
