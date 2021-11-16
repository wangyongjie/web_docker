#!/bin/bash
echo '---start build---'
docker run --rm --privileged=true -v $(pwd):/work node:14.2.0-slim bash -c "cd /work && sh build.sh"
echo '---end build---'