#!/bin/bash

docker run \
    --name "jenkins-slave-${1:? Port number required. }" \
    -p ${1}:22 \
    -d \
    knjname/jenkins-slave


