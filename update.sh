#!/bin/bash

case $1 in 
    'admin_frontend_pg')
        echo '-------start update admin_frontend_pg-------'
        cd $(pwd) && cd ../
        if [ ! -d './admin_frontend_pg' ]; then
            git clone -b $2 http://120.77.236.161/git/PgAdmin/admin_frontend_pg.git
        fi
        cp docker-compose/build/docker-build.sh admin_frontend_pg/docker-build.sh
        cp docker-compose/build/build.sh admin_frontend_pg/build.sh
        cd admin_frontend_pg
        sh ./docker-build.sh
        echo '-------end update admin_frontend_pg-------'
    ;;
    'rainbow')
        echo '-------start update rainbow-------'
        cd $(pwd) && cd ../
        if [ ! -d './rainbow' ]; then
            git clone -b $2 http://120.77.236.161/git/MandGame/rainbow.git
        fi
        cp docker-compose/build/docker-build.sh rainbow/docker-build.sh
        cp docker-compose/build/build.sh rainbow/build.sh
        cd rainbow
        sh ./docker-build.sh
        echo '-------end update rainbow-------'
    ;;
esac
