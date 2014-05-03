#!/bin/bash

docker run \
    --name "jenkins-master" \
    -p 8080:8080 \
    -p 10080:10080 \
    -e JENKINS_JNLP_PORT=10080 \
    -v /opt/example-jenkins/logs:/jenkins/logs \
    -v /opt/example-jenkins/home:/jenkins/home \
    -d \
    knjname/jenkins-master


