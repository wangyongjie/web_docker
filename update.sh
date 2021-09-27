#!/bin/bash

project = 'all'
branch = 'master'

if [$1 != '']; then
    $project = $1
fi
if [$2 != '']; then
    $branch = $2
fi

if [$project == 'admin_frontend_pg' || $project == 'all' ]; then
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
fi