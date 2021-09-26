#!/bin/bash

npm install -P && npm run build:prod && rm -rf ./dist_docker && mv ./dist ./dist_docker