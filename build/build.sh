#!/bin/bash

npm install -P && npm run build:prod
if [ -d './dist_docker' ]; then
    mv ./dist_docker ./dist_docker_copy
fi
mv ./dist ./dist_docker
if [ -d './dist_docker_copy' ]; then
    rm -rf ./dist_docker_copy
fi