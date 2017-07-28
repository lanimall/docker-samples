# Terracotta Sample docker scripts

Docker samples for Terracotta Enterprise (Terracotta Enterprise software and license required)
Important: This guide assumes that you have a Terracotta EE kit and a Terracotta license key available.

## Build the EE Images from existing installation

### Build the image for the Terracotta Server

1 - Set some variables for further reference

$ TERRACOTTA_HOME=~/Applications/terracotta/home434x/
$ TERRACOTTA_PREFIX=terracotta-ee
$ TERRACOTTA_VERSION=4.3.4.1.4

2 - Copy the TC Server docker script to the root of your Terracotta EE install and navigate to it.

$ cp ./server/Dockerfile.tc $TERRACOTTA_HOME/
$ cp -R ./server/DockerConfigs.tc $TERRACOTTA_HOME/

3 - Docker build and install image:

$ cd $TERRACOTTA_HOME; docker build -t $TERRACOTTA_PREFIX/server:$TERRACOTTA_VERSION -f Dockerfile.tc .

NOTE: By default, the docker sceript tries to find the terracotta-license file at the root of the Terracotta inzstall.
But if the terracotta-license key is NOT at the root of the Terracotta install, and rather in 1 of the subfolders, you can specify the relative path to it via variable

$ cd $TERRACOTTA_HOME; docker build -t $TERRACOTTA_PREFIX/server:$TERRACOTTA_VERSION --build-arg TERRACOTTA_LICENSE_KEY=./server/terracotta-license.key -f Dockerfile.tc .

4 - Should see successful message:

Successfully built [...]
Successfully tagged terracotta-ee/server:4.3.4.1.4

5 - Verify image is in the local reporsitory:

$ docker images
REPOSITORY             TAG                 IMAGE ID            CREATED             SIZE
terracotta-ee/server   4.3.4.1.4           e377c6a64583        10 seconds ago      212MB
openjdk                8-jdk-alpine        478bf389b75b        4 weeks ago         101MB

6 - (optional) Cleanup the docker scripts and configs fro mthe Terracotta directory

$ rm $TERRACOTTA_HOME/Dockerfile.tc
$ rm -R $TERRACOTTA_HOME/DockerConfigs.tc/

### Build the image for the Terracotta Management Server (TMC)

1 - Set some variables for further reference

$ TERRACOTTA_HOME=~/Applications/terracotta/home434x/
$ TERRACOTTA_PREFIX=terracotta-ee
$ TERRACOTTA_VERSION=4.3.4.1.4

2 - Copy the TMC docker script to the root of your Terracotta EE install and navigate to it.

$ cp ./management/Dockerfile.tmc $TERRACOTTA_HOME/
$ cp -R ./management/DockerConfigs.tmc $TERRACOTTA_HOME/

3 - Docker build and install image:

$ cd $TERRACOTTA_HOME; docker build -t $TERRACOTTA_PREFIX/management:$TERRACOTTA_VERSION -f Dockerfile.tmc .

NOTE: By default, the docker sceript tries to find the terracotta-license file at the root of the Terracotta install.
But if the terracotta-license key is NOT at the root of the Terracotta install, and rather in 1 of the subfolders, you can specify the relative path to it via variable

$ cd $TERRACOTTA_HOME; docker build -t $TERRACOTTA_PREFIX/management:$TERRACOTTA_VERSION --build-arg TERRACOTTA_LICENSE_KEY=./tools/management-console/terracotta-license.key -f Dockerfile.tmc .

4 - Should see successful message:

Successfully built [...]
Successfully tagged terracotta-ee/management:4.3.4.1.4

5 - Verify image is in the local reporsitory:

$ docker images
REPOSITORY                 TAG                 IMAGE ID            CREATED             SIZE
terracotta-ee/management   4.3.4.1.4           a6a151fc4998        6 minutes ago       300MB
terracotta-ee/server       4.3.4.1.4           7eaf2a3c438e        15 minutes ago      212MB
openjdk                    8-jdk-alpine        478bf389b75b        4 weeks ago         101MB

6 - (optional) Cleanup the docker scripts and configs fro mthe Terracotta directory

$ rm $TERRACOTTA_HOME/Dockerfile.tmc
$ rm -R $TERRACOTTA_HOME/DockerConfigs.tmc/

## Run Terracotta instances from these images

### Single Terracotta Node:

1 - Working Directory for our docker instances

Because we exposed a docker volume for the Terracotta data (in case we tell TC to backup all in memory data to disk), we should create a working directory first before we launch the instances.
Let's create a variable so we can reuse the same path for the various commands below:

TERRACOTTA_DOCKER_WORKING_DIR=~/Applications/terracotta/docker-working-dir/tc_data

2 - Create working dir

mkdir -p $TERRACOTTA_DOCKER_WORKING_DIR

3 - Run the instance

$ docker run -p 9510:9510 -p 9540:9540 --name tsa_singlenode \
  -v $TERRACOTTA_DOCKER_WORKING_DIR:/terracotta_data \
  -d terracotta-ee/server:4.3.4.1.4 

4 - Check all is well

First, check the process:

$ docker ps
CONTAINER ID        IMAGE                            COMMAND                  CREATED             STATUS              PORTS                                                      NAMES
7939215f551f        terracotta-ee/server:4.3.4.1.4   "/bin/sh -c 'sed -..."   23 seconds ago      Up 23 seconds       0.0.0.0:9510->9510/tcp, 0.0.0.0:9540->9540/tcp, 9530/tcp   tsa_singlenode

Second, check the logs:

$ docker logs tsa_singlenode

### Two Terracotta nodes (active / mirror)

0 - if you haven't already, stop the single node that may still be running

$ docker stop tsa_singlenode
$ docker ps
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES

Great, nothing is runnning anymore...we can move forward

1 - Because we need the 2 Terracotta nodes to talk to each other, let's first create a docker network that will be used by the 2 TC processes.

$ docker network create myTSANet 

2 - Then, start the 2 nodes with the following commands:

$ docker run -p 9510:9510 --hostname tsa1 --name tsa1 \
  -v $TERRACOTTA_DOCKER_WORKING_DIR/terracotta_data1/:/terracotta_data \
  -e TC_SERVER1=tsa1 -e TC_SERVER2=tsa2 --net=myTSANet \
  -d terracotta-ee/server:4.3.4.1.4 

$ docker run -p 9610:9510 --hostname tsa2 --name tsa2 \
  -v $TERRACOTTA_DOCKER_WORKING_DIR/terracotta_data2/:/terracotta_data \
  -e TC_SERVER1=tsa1 -e TC_SERVER2=tsa2 --net=myTSANet \
  -d terracotta-ee/server:4.3.4.1.4 

3 - Check all is well

First, check the processes:

$ docker ps
CONTAINER ID        IMAGE                            COMMAND                  CREATED             STATUS              PORTS                                        NAMES
7687ee3e9b29        terracotta-ee/server:4.3.4.1.4   "/bin/sh -c 'sed -..."   3 seconds ago       Up 2 seconds        9530/tcp, 9540/tcp, 0.0.0.0:9610->9510/tcp   tsa2
5ca30dfa5396        terracotta-ee/server:4.3.4.1.4   "/bin/sh -c 'sed -..."   11 seconds ago      Up 10 seconds       9530/tcp, 0.0.0.0:9510->9510/tcp, 9540/tcp   tsa1

Second, check the logs (and particularly check that both TC nodes have a status of ACTIVE and PASSIVE_STANDBY, which proves that both node are talking to each other)

$ docker logs tsa1

I see amongst other log entries:

18:00:40,850  INFO console:90 - Becoming State[ ACTIVE-COORDINATOR ]
2017-07-28 18:00:40,850 INFO - Becoming State[ ACTIVE-COORDINATOR ]

$ docker logs tsa2

I see amongst other log entries:

18:00:46,750  INFO console:90 - Moved to State[ PASSIVE-STANDBY ]
[TC] 2017-07-28 18:00:46,750 INFO - Moved to State[ PASSIVE-STANDBY ]

## Adding the Terracotta Management Console

To be able to visually see what's going on with the Terracotta clister or the connected client, the Enterprise (EE) version offers a Management console. 

1 - Let's start TMC, using the same network as the one used by the 2 running Terracotta processes

docker run -p 9889:9889 --name tmc --net=myTSANet -d terracotta-ee/management:4.3.4.1.4

2 - Restart TMC if it's the first time launched

If it's the first time we start it, TMC will ask if we want to use or disable authentication. Your choice, but after that, we'll need to restart TMC (in other words, the TMC instance.)

$ docker stop tmc
$ docker start tmc

3 - Login to the TMC UI.

If all went well, the TMC UI should now be accessible on port 9889 at http://localhost:9889/tmc

4 - Create a TMC connection to the running Terracotta nodes

Click "Create Connection", and enter either "http://tsa1:9540" or "http://tsa2:9540" in the "Connection Location (URL)".

That should find the running Terracotta cluster without issues...now you can monitor whatr's happening! 

## Adding some cache clients

So far, we have a running Terracotta cluster (2 nodes, active / mirror) and a running Terracotta Management Console to monitor in real-time what's going on.
The last missing piece is to have an actual client application that use Terracotta.
We will be using the well known "spring-pet-clinic" application as an example. Other samples will be added too.

1 - Create the custom pet-clinic image

$ cd ./clients/pet-clinic/
$ docker build -t spring-petclinic/clustered-ehcache:4.3.4.1.4 \
  --build-arg ehcache_version=2.10.4.1.4 --build-arg terracotta_version=4.3.4.1.4 \
  -f Dockerfile .

2 - Run it
















