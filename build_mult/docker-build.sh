#!/bin/bash
echo '---start build '$1'---'
docker run --rm -v $(pwd):/work node:14.2.0-slim bash -c "cd /work/$1 && sh build.sh"
echo '---end build '$1'---'