#!/bin/bash

npm install && npm run build && rm -rf ../dist_docker && cp -r ../dist ../dist_docker