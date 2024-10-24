#!/bin/zsh

echo "Compiling"
mvn clean package -DskipTests

echo "Go to module"
cd ~/work/tidal-sdk/tidal-sdk-android-private/userprofile

echo "Run generate script"
./bin/generate.sh clean.json
