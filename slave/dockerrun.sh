#!/bin/bash

docker run \
    --name "jenkins-slave" \
    -p 10022:22 \
    -d \
    knjname/jenkins-slave


