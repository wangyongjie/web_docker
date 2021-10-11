#!/bin/bash

npm install -P && npm run build:prod && mv ./dist_docker ./dist_docker_copy && mv ./dist ./dist_docker && rm -rf ./dist_docker_copy

