#!/bin/bash

#########################################################
# Jenkins runner script
#   Wraps jenkins.war and make it possible to specify some options by specifying ENVs.
#   Assumes this script is executed under a Docker container.

# This script is based on the scripts found at
#   https://github.com/jenkinsci/jenkins/tree/master/rpm/SOURCES
# And also inherits its license described below,

#
#     SUSE system statup script for Jenkins
#     Copyright (C) 2007  Pascal Bleser
#          
#     This library is free software; you can redistribute it and/or modify it
#     under the terms of the GNU Lesser General Public License as published by
#     the Free Software Foundation; either version 2.1 of the License, or (at
#     your option) any later version.
#      
#     This library is distributed in the hope that it will be useful, but
#     WITHOUT ANY WARRANTY; without even the implied warranty of
#     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
#     Lesser General Public License for more details.
#      
#     You should have received a copy of the GNU Lesser General Public
#     License along with this library; if not, write to the Free Software
#     Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307,
#     USA.
#

#########################################################


# The location of the default Jenkins war.
: ${JENKINS_WAR:="/jenkins/bin/jenkins.war"}


## Path:        Development/Jenkins
## Description: Configuration for the Jenkins continuous build server
## Type:        string
## Default:     "/jenkins/home"
## ServiceRestart: jenkins
#
# Directory where Jenkins store its configuration and working
# files (checkouts, build reports, artifacts, ...).
#
: ${JENKINS_HOME:="/jenkins/home"}

# !!! (This is not a standard option.)
## Type: string
## Default: "/jenkins/logs"
#
# Directory into which log files will be saved.
# 
: ${JENKINS_LOG_DIR:="/jenkins/logs"}

# !!! (This is not a standard option.)
## Type: string
## Default: "/"
#
# URL prefix Jenkins recognizes.
# It must start with "/"(slash).
# Jenkins can accept HTTP requests on
# http://<host_and_port>${JENKINS_URL_PREFIX}
# 
: ${JENKINS_URL_PREFIX:="/"}


# !!! (This is not a standard option.)
## Type: integer(0:65535) but empty is allowed.
## Default: ""
#
# Port used by JNLP protocol of Jenkins.
# You will have to specify this option when a windows slave is required.
# If given, this is rewrite the JNLP value on ${JENKINS_HOME}/config.xml before running.
#
: ${JENKINS_JNLP_PORT:=""}
JENKINS_CONFIG_XML="${JENKINS_HOME}/config.xml"


## Type:        string
## Default:     ""
## ServiceRestart: jenkins
#
# Java executable to run Jenkins
# When left empty, we'll try to find the suitable Java.
#
: ${JENKINS_JAVA_CMD:="java"}

## Type:        string
## Default:     "root"
## ServiceRestart: jenkins
#
# Unix user account that runs the Jenkins daemon
# Be careful when you change this, as you need to update
# permissions of $JENKINS_HOME and /var/log/jenkins.
#
: ${JENKINS_USER:="root"}

## Type:        string
## Default:     "-Djava.awt.headless=true"
## ServiceRestart: jenkins
#
# Options to pass to java when running Jenkins.
#
: ${JENKINS_JAVA_OPTIONS:="-Djava.awt.headless=true"}

## Type:        integer(0:65535)
## Default:     8080
## ServiceRestart: jenkins
#
# Port Jenkins is listening on.
# Set to -1 to disable
#
: ${JENKINS_PORT:="8080"}

## Type:        string
## Default:     ""
## ServiceRestart: jenkins
#
# IP address Jenkins listens on for HTTP requests.
# Default is all interfaces (0.0.0.0).
#
JENKINS_LISTEN_ADDRESS=""

## Type:        integer(0:65535)
## Default:     ""
## ServiceRestart: jenkins
#
# HTTPS port Jenkins is listening on.
# Default is disabled.
#
JENKINS_HTTPS_PORT=""

## Type:        string
## Default:     ""
## ServiceRestart: jenkins
#
# IP address Jenkins listens on for HTTPS requests.
# Default is disabled.
#
JENKINS_HTTPS_LISTEN_ADDRESS=""

## Type:        integer(0:65535)
## Default:     -1
## ServiceRestart: jenkins
#
# Ajp13 Port Jenkins is listening on.
# Set to -1 to disable
#
: ${JENKINS_AJP_PORT:="-1"}

## Type:        string
## Default:     ""
## ServiceRestart: jenkins
#
# IP address Jenkins listens on for Ajp13 requests.
# Default is all interfaces (0.0.0.0).
#
JENKINS_AJP_LISTEN_ADDRESS=""

## Type:        integer(1:9)
## Default:     5
## ServiceRestart: jenkins
#
# Debug level for logs -- the higher the value, the more verbose.
# 5 is INFO.
#
: ${JENKINS_DEBUG_LEVEL:="5"}

## Type:        yesno
## Default:     no
## ServiceRestart: jenkins
#
# Whether to enable access logging or not.
#
: ${JENKINS_ENABLE_ACCESS_LOG:="no"}

## Type:        integer
## Default:     100
## ServiceRestart: jenkins
#
# Maximum number of HTTP worker threads.
#
: ${JENKINS_HANDLER_MAX:="100"}

## Type:        integer
## Default:     20
## ServiceRestart: jenkins
#
# Maximum number of idle HTTP worker threads.
#
: ${JENKINS_HANDLER_IDLE:="20"}

## Type:        string
## Default:     ""
## ServiceRestart: jenkins
#
# Pass arbitrary arguments to Jenkins.
# Full option list: java -jar jenkins.war --help
#
: ${JENKINS_ARGS:=""}


# Check whether fundamental conditions are satisfied.
[ -r "$JENKINS_WAR"  ] || { echo "$JENKINS_WAR not installed"; exit 5 ; }
[ -n "$JENKINS_HOME" ] || { echo "JENKINS_HOME not configured in $JENKINS_CONFIG"; exit 6 ; }
[ -d "$JENKINS_HOME" ] || { echo "JENKINS_HOME directory does not exist: $JENKINS_HOME"; exit 1 ; }

# Search usable Java. We do this because various reports indicated
# that /usr/bin/java may not always point to Java 1.5
# see http://www.nabble.com/guinea-pigs-wanted-----Hudson-RPM-for-RedHat-Linux-td25673707.html
for candidate in /etc/alternatives/java /usr/lib/jvm/java-1.6.0/bin/java /usr/lib/jvm/jre-1.6.0/bin/java /usr/lib/jvm/java-1.5.0/bin/java /usr/lib/jvm/jre-1.5.0/bin/java /usr/bin/java
do
    [ -x "$JENKINS_JAVA_CMD" ] && break
    JENKINS_JAVA_CMD="$candidate"
done

# Construct the arguments to be given to Jenkins.
JAVA_CMD="$JENKINS_JAVA_CMD $JENKINS_JAVA_OPTIONS -DJENKINS_HOME=$JENKINS_HOME -jar $JENKINS_WAR"
PARAMS="--logfile=${JENKINS_LOG_DIR}/jenkins.log --webroot=/var/cache/jenkins/war"
[ -n "$JENKINS_PORT" ] && PARAMS="$PARAMS --httpPort=$JENKINS_PORT"
[ -n "$JENKINS_LISTEN_ADDRESS" ] && PARAMS="$PARAMS --httpListenAddress=$JENKINS_LISTEN_ADDRESS"
[ -n "$JENKINS_HTTPS_PORT" ] && PARAMS="$PARAMS --httpsPort=$JENKINS_HTTPS_PORT"
[ -n "$JENKINS_HTTPS_LISTEN_ADDRESS" ] && PARAMS="$PARAMS --httpsListenAddress=$JENKINS_HTTPS_LISTEN_ADDRESS"
[ -n "$JENKINS_AJP_PORT" ] && PARAMS="$PARAMS --ajp13Port=$JENKINS_AJP_PORT"
[ -n "$JENKINS_AJP_LISTEN_ADDRESS" ] && PARAMS="$PARAMS --ajp13ListenAddress=$JENKINS_AJP_LISTEN_ADDRESS"
[ -n "$JENKINS_DEBUG_LEVEL" ] && PARAMS="$PARAMS --debug=$JENKINS_DEBUG_LEVEL"
[ -n "$JENKINS_HANDLER_STARTUP" ] && PARAMS="$PARAMS --handlerCountStartup=$JENKINS_HANDLER_STARTUP"
[ -n "$JENKINS_HANDLER_MAX" ] && PARAMS="$PARAMS --handlerCountMax=$JENKINS_HANDLER_MAX"
[ -n "$JENKINS_HANDLER_IDLE" ] && PARAMS="$PARAMS --handlerCountMaxIdle=$JENKINS_HANDLER_IDLE"

[ -n "${JENKINS_URL_PREFIX}" ] && PARAMS="$PARAMS --prefix=${JENKINS_URL_PREFIX}"

[ -n "$JENKINS_ARGS" ] && PARAMS="$PARAMS $JENKINS_ARGS"

if [ "$JENKINS_ENABLE_ACCESS_LOG" = "yes" ]; then
    PARAMS="$PARAMS --accessLoggerClassName=winstone.accesslog.SimpleAccessLogger --simpleAccessLogger.format=combined --simpleAccessLogger.file=${JENKINS_LOG_DIR}/access_log"
fi


# Rewrite JNLP port setting.
## Ensure existence of config.xml
if ! [ -f "${JENKINS_CONFIG_XML}" ] ; then
    cat <<EOF > "${JENKINS_CONFIG_XML}" 
<?xml version="1.0"?>

<hudson>
  <slaveAgentPort>0</slaveAgentPort>
</hudson>
EOF
fi
if [ -n "${JENKINS_JNLP_PORT}" ] ; then
    sed -i "s|<slaveAgentPort>.*</slaveAgentPort>|<slaveAgentPort>${JENKINS_JNLP_PORT}</slaveAgentPort>|" "${JENKINS_CONFIG_XML}"
fi

# Launch the Jenkins!
exec sudo -u "${JENKINS_USER}" $JAVA_CMD $PARAMS
