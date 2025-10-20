#!/bin/zsh

echo "Compiling"
mvn clean package -DskipTests

echo "Go to module"
cd [PATH_TO_SDK]/tidal-sdk-android/tidalapi

echo "Run generate script"
./bin/generate-api.sh
