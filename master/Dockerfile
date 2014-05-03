FROM ubuntu

MAINTAINER knjname

# Install required tools
RUN apt-get update
RUN apt-get install -y openjdk-7-jdk
RUN apt-get install -y openssh-client

# Install SSH configuration
ADD ssh-files /root/.ssh

# Install Jenkins
RUN mkdir -p /jenkins/bin
RUN mkdir -p /jenkins/home
RUN mkdir -p /jenkins/logs

ADD http://mirrors.jenkins-ci.org/war/latest/jenkins.war /jenkins/bin/jenkins.war
ADD resources/run.sh /jenkins/bin/run.sh

# Declarations
CMD /jenkins/bin/run.sh


