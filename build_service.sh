#!/usr/bin/env sh

gradle build
docker build --build-arg JAR_FILE=build/libs/TestService-0.0.1-SNAPSHOT.jar  -t springio/hello-world-service .