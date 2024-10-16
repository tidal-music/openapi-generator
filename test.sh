#!/bin/zsh

echo "Compiling"
mvn clean package -DskipTests

echo "Go to module"
cd ~/work/tidal-sdk/tidal-sdk-android-private/userprofile

echo "Run generate script"
./bin/generate.sh https://developer.tidal.com/apiref/api-specifications/api-public-user-jsonapi/tidal-user-v2-openapi-3.0.json
