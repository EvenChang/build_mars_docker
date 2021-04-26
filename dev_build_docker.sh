#!/bin/bash
ONOS_ROOT=$(pwd)
GIT_COMMIT=$(git rev-parse HEAD)
GIT_COMMIT_SHORT=$(git rev-parse --short HEAD)
BRANCH_NAME=$(git rev-parse --abbrev-ref HEAD)
VERSION=$(git describe --tags --always)
HOST_NAME=$(hostname)
BUILD_DATE=$(date "+%m-%d-%yT%H:%M:%SZ")

source $ONOS_ROOT/tools/dev/bash_profile

# create verion file
cp packages/version_template.json version.json

# update version file info
sed -i 's/GIT_COMMIT/'$GIT_COMMIT'/g' version.json
sed -i 's/VERSION/'$VERSION'/g' version.json
sed -i 's/BUILD_SERVER/'$HOST_NAME'/g' version.json
sed -i 's/BUILD_DATE/'$BUILD_DATE'/g' version.json

# start to build mars docker images
mv version.json tools/package/etc/
./tools/build/onos-buck build onos
docker build -t mars:$BRANCH_NAME -f Dev_Dockerfile --label org.label-schema.commitId=$GIT_COMMIT_SHORT .
docker rmi -f $(docker images -q --filter label=stage=mars-builder)
