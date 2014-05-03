
# Jenkins over Docker example

This project contains various files such as Dockerfile or related files, which forms a practical Jenkins master-slave configuration over Docker.

## To build Jenkins master node

```
#> cd master
#> bash dockerbuild.sh
(An image knjname/jenkins-master will be registered.)
```

### And to run

```
#> cd master
#> bash dockerrun.sh
(Note that /opt/jenkins-example will be automatically created.)
```

You can see the Jenkins at http://your_docker_host:8080/ .

## To build Jenkins master node

```
#> cd slave
#> bash dockerbuild.sh
(An image knjname/jenkins-slave will be registered.)
```

### And to run

```
#> cd slave
#> bash dockerrun.sh
```

SSHD listens to your_docker_host:10022 .

To connect between the master and the slave, you have to configure it manually via Jenkins administration menu.

# See more details

See my blog entry http://knjname.hateblo.jp/entry/2014/05/03/190842 (In Japanese)
