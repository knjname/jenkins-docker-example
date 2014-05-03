FROM ubuntu

MAINTAINER knjname

# Install required tools
RUN apt-get update
RUN apt-get install -y openjdk-7-jdk
RUN apt-get install -y openssh-server

# Install SSH configuration
# (Should allow master's SSH request.)
ADD ssh-files /root/.ssh
RUN mkdir -p /var/run/sshd

# Install additional tools several jobs needs.
# (Following packages are just examples.)
RUN apt-get install -y gcc graphviz ruby

# Jenkins workspace
RUN mkdir -p /jenkins/ws

# Declarations
CMD /usr/sbin/sshd -D


