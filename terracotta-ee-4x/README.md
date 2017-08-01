# Terracotta Sample docker scripts

Some working docker samples and instructions to "dockerize" Terracotta Enterprise 4.x and related components.
What we'll cover with this guide:
 - [Create docker images for Terracotta EE Server component](#build-the-terracotta-ee-images-from-existing-package)
 - [Create docker images for Terracotta EE Monitoring component](#build-the-image-for-the-tmc-terracotta-management-server)
 - [Run Terracotta instances from newly created docker images](#run-terracotta-instances-from-these-images)
 - [Run Terracotta Management Console instances from newly created docker images](#adding-the-terracotta-management-console)
 - [Create and run docker images for cache clients connecting to the Terracotta](#adding-some-cache-application-clients)
 - [Tie everything together with docker-compose](#Using-docker-compose-to-automate-most-of-it)

**Important**: Terracotta Enterprise software and license are required for this guide (we will be using them to create the docker images)

** For more information on Terracotta EE, please refer to:**
 - [BigMemory Max/Terracotta-EE](http://terracotta.org/products/bigmemorymax)
 - [Terracotta Mamagement Console (TMC)](http://terracotta.org/documentation/4.0/tms/tms)

**For Terracotta open-source versions, and related docker guides, please refer to:**
 - [Terracotta Open-Source](http://terracotta.org/downloads/open-source/catalog)
 - [Ehcache Open-Source](http://www.ehcache.org/)
 - [Terracotta OSS Docker Repo on GitHub](https://github.com/Terracotta-OSS/docker)
 - [Terracotta on Docker Hub](https://hub.docker.com/u/terracotta/)

## Build the Terracotta EE images from existing package

### Pre-requisites and conventions

1 - Clone this repository

2 - Copy the Terracotta EE installation package (tar.gz) and license key in the ./resources directory

**Conventions**: All the docker scripts created in this project will expect:
 - The Terracotta EE package shoudl be named following the convention: ${TERRACOTTA_PREFIX}-${TERRACOTTA_VERSION}.tar.gz
  * ${TERRACOTTA_PREFIX} will become the docker image prefix
  * ${TERRACOTTA_VERSION} will become the docker image version
 - The Terracotta license key (required for EE) should be named "terracotta-license.key"

### Build the image for the Terracotta Server

1 - In your terminal, set some variables for further reference 

```bash
TERRACOTTA_PREFIX=bigmemory-max
TERRACOTTA_VERSION=4.3.4.1.4
```

2 - Create the Docker image:

```bash
docker build -t $TERRACOTTA_PREFIX/server:$TERRACOTTA_VERSION \
  --build-arg TERRACOTTA_PREFIX=$TERRACOTTA_PREFIX \
  --build-arg TERRACOTTA_VERSION=$TERRACOTTA_VERSION \
  -f Dockerfile.tc .
```

4 - Should see successful message:

```bash
Successfully built [...]
Successfully tagged bigmemory-max/server:4.3.4.1.4
```

5 - Verify image is in the local reporsitory:

```bash
docker images

REPOSITORY             TAG                 IMAGE ID            CREATED             SIZE
bigmemory-max/server   4.3.4.1.4           e377c6a64583        10 seconds ago      212MB
openjdk                8-jdk-alpine        478bf389b75b        4 weeks ago         101MB
```

### Build the image for the TMC Terracotta Management Server

1 - In your terminal, set some variables for further reference (in case you're starting from here somehow)

```bash
TERRACOTTA_PREFIX=bigmemory-max
TERRACOTTA_VERSION=4.3.4.1.4
```

3 - Docker build and install image:

```bash
docker build -t $TERRACOTTA_PREFIX/management:$TERRACOTTA_VERSION \
  --build-arg TERRACOTTA_PREFIX=$TERRACOTTA_PREFIX \
  --build-arg TERRACOTTA_VERSION=$TERRACOTTA_VERSION \
  -f Dockerfile.tmc .
```

4 - Should see successful message:

```bash
Successfully built [...]
Successfully tagged bigmemory-max/management:4.3.4.1.4
```

5 - Verify image is in the local reporsitory:

```bash
docker images

REPOSITORY                 TAG                 IMAGE ID            CREATED             SIZE
bigmemory-max/management   4.3.4.1.4           a6a151fc4998        6 minutes ago       300MB
bigmemory-max/server       4.3.4.1.4           7eaf2a3c438e        15 minutes ago      212MB
openjdk                    8-jdk-alpine        478bf389b75b        4 weeks ago         101MB
```

## Run Terracotta instances from these images

### Single Terracotta Node:

1 - Working Directory for our docker instances

Because we exposed a docker volume for the Terracotta data (in case we tell TC to backup all in memory data to disk), we should create a working directory first before we launch the instances.
Let's create a variable so we can reuse the same path for the various commands below.
Let's also set the same TERRACOTTA_PREFIX and TERRACOTTA_VERSION variables for further reference (in case you're starting from here somehow)


```bash
TERRACOTTA_DOCKER_WORKING_DIR=~/Applications/terracotta/docker-working-dir/tc_data
TERRACOTTA_PREFIX=bigmemory-max
TERRACOTTA_VERSION=4.3.4.1.4
```

2 - Create working dir

```bash
mkdir -p $TERRACOTTA_DOCKER_WORKING_DIR
```

3 - Run the instance

```bash
docker run -p 9510:9510 -p 9540:9540 --name tsa_singlenode \
  -v $TERRACOTTA_DOCKER_WORKING_DIR:/terracotta_data \
  -d $TERRACOTTA_PREFIX/server:$TERRACOTTA_VERSION
```

4 - Check all is well

First, check the process:

```bash
docker ps

CONTAINER ID        IMAGE                            COMMAND                  CREATED             STATUS              PORTS                                                      NAMES
7939215f551f        bigmemory-max/server:4.3.4.1.4   "/bin/sh -c 'sed -..."   23 seconds ago      Up 23 seconds       0.0.0.0:9510->9510/tcp, 0.0.0.0:9540->9540/tcp, 9530/tcp   tsa_singlenode
```

Second, check the logs:

```bash
docker logs tsa_singlenode
```

### Two Terracotta nodes (active / mirror)

0 - (optional) If you haven't already, stop the single node that may still be running

```bash
docker stop tsa_singlenode
docker ps

CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES
```

1 - Because we need the 2 Terracotta nodes to talk to each other, let's first create a docker network that will be used by the 2 TC processes.

```bash
docker network create myTSANet 
```

2 - Then, start the 2 nodes with the following commands:

TSA1:

```bash
docker run -p 9510:9510 --hostname tsa1 --name tsa1 \
  -v $TERRACOTTA_DOCKER_WORKING_DIR/terracotta_data1/:/terracotta_data \
  -e TC_SERVER1=tsa1 -e TC_SERVER2=tsa2 --net=myTSANet \
  -d $TERRACOTTA_PREFIX/server:$TERRACOTTA_VERSION
```

TSA2:

```bash
docker run -p 9610:9510 --hostname tsa2 --name tsa2 \
  -v $TERRACOTTA_DOCKER_WORKING_DIR/terracotta_data2/:/terracotta_data \
  -e TC_SERVER1=tsa1 -e TC_SERVER2=tsa2 --net=myTSANet \
  -d $TERRACOTTA_PREFIX/server:$TERRACOTTA_VERSION
```

3 - Check all is well

First, check the processes:

```bash
docker ps

CONTAINER ID        IMAGE                            COMMAND                  CREATED             STATUS              PORTS                                        NAMES
7687ee3e9b29        bigmemory-max/server:4.3.4.1.4   "/bin/sh -c 'sed -..."   3 seconds ago       Up 2 seconds        9530/tcp, 9540/tcp, 0.0.0.0:9610->9510/tcp   tsa2
5ca30dfa5396        bigmemory-max/server:4.3.4.1.4   "/bin/sh -c 'sed -..."   11 seconds ago      Up 10 seconds       9530/tcp, 0.0.0.0:9510->9510/tcp, 9540/tcp   tsa1
```

Second, check the logs (and particularly check that both TC nodes have a status of ACTIVE and PASSIVE_STANDBY, which proves that both node are talking to each other)

```bash
docker logs tsa1
```

I see amongst other log entries:

```bash
18:00:40,850  INFO console:90 - Becoming State[ ACTIVE-COORDINATOR ]
2017-07-28 18:00:40,850 INFO - Becoming State[ ACTIVE-COORDINATOR ]
```

And:

```bash
docker logs tsa2
```

I see amongst other log entries:

```bash
18:00:46,750  INFO console:90 - Moved to State[ PASSIVE-STANDBY ]
[TC] 2017-07-28 18:00:46,750 INFO - Moved to State[ PASSIVE-STANDBY ]
```

## Adding the Terracotta Management Console

0 - First, as befoire, set some variables for further reference (in case you're starting from here somehow)

```bash
TERRACOTTA_PREFIX=bigmemory-max
TERRACOTTA_VERSION=4.3.4.1.4
```

To be able to visually see what's going on with the Terracotta clister or the connected client, the Enterprise (EE) version offers a Management console. 

1 - Let's start TMC, using the same network as the one used by the 2 running Terracotta processes

```bash
docker run -p 9889:9889 --name tmc --net=myTSANet \
  -d $TERRACOTTA_PREFIX/server:$TERRACOTTA_VERSION
```

2 - (First time only) Open TMC Web UI and set authentication scheme

If all went well, the TMC UI should now be accessible on port 9889 at http://localhost:9889/tmc
If it's the first time you started this instance though, you will first need to chose how you want to secure the TMC UI.
Once you did, you will need to restart the TMC instance.

```bash
docker stop tmc
docker start tmc
```

3 - Login to the TMC Web UI.

If all went well, the TMC UI should now be accessible on port 9889 at http://localhost:9889/tmc

4 - Create a TMC connection to the running Terracotta nodes

Click "Create Connection", and enter either "http://tsa1:9540" or "http://tsa2:9540" in the "Connection Location (URL)".

That should find the running Terracotta cluster without issues...now you can monitor whatr's happening! 

## Adding some cache application clients

So far, we have a running Terracotta cluster (2 nodes, active / mirror) and a running Terracotta Management Console to monitor in real-time what's going on.
The last missing piece is to have an actual client application that use Terracotta.
For now, we will be using a sample java application known-as [spring-pet-clinic](https://github.com/spring-projects/spring-petclinic) 
Other samples will be added too TBD

0 - In your terminal, set some variables for further reference

```bash
TERRACOTTA_PREFIX=bigmemory-max
TERRACOTTA_VERSION=4.3.4.1.4
EHCACHE_VERSION=2.10.4.1.4
```

1 - Create the custom pet-clinic image

```bash
docker build -t spring-petclinic/$TERRACOTTA_PREFIX:$TERRACOTTA_VERSION \
  --build-arg ehcache_version=$EHCACHE_VERSION --build-arg terracotta_version=$TERRACOTTA_VERSION \
  -f Dockerfile.petclinic.clients .
```

2 - Run it

Noptice the environment variable "TSA_URL": it defines the url to a running Terracotta cluster.
Depending on if you're running a single node or a Terracotta active / mirror cluster, you should update that variable's value properly.

```bash
TSA_URL=tsa1:9510,tsa2:9510

docker run -p 9966:9966 --name pet-clinic -e TSA_URL=$TSA_URL --net=myTSANet -d spring-petclinic/bigmemory-max:$TERRACOTTA_VERSION
```

3 - Check all is well

First, check the processes:

```bash
docker ps

CONTAINER ID        IMAGE                            COMMAND                  CREATED             STATUS              PORTS                                        NAMES
7687ee3e9b29        terracotta-ee/server:4.3.4.1.4   "/bin/sh -c 'sed -..."   3 seconds ago       Up 2 seconds        9530/tcp, 9540/tcp, 0.0.0.0:9610->9510/tcp   tsa2
5ca30dfa5396        terracotta-ee/server:4.3.4.1.4   "/bin/sh -c 'sed -..."   11 seconds ago      Up 10 seconds       9530/tcp, 0.0.0.0:9510->9510/tcp, 9540/tcp   tsa1
5ca30ddw2344        spring-petclinic/clustered-ehcache:4.3.4.1.4   "mvn tomcat7:run ..."   12 seconds ago      Up 10 seconds       9966/tcp, 0.0.0.0:9966->9966/tcp  pet-clinic
```

Second, check the logs (and particularly check that the application started properly and connected to the Terracotta cluster)

```bash
docker logs pet-clinic
```

Finally, you could also check that you see a cache client connected in the Terracotta management console (http://localhost:9889/tmc)

## Using docker-compose to automate most of it

I create docker-compose scripts so that we could start all related component from 1 single command.

NOTE: First edit these docker compose scripts with the right TERRACOTTA / EHCAHE versions in there.

For example, to start 2 Terracotta nodes in a cluster + Terracotta Mamnagement console + 1 cache client ("pet-clinic"), simply do:

```bash
cd ./clients/pet-clinic/
docker-compose -f docker-compose-AandP.yml up
```

Or for the same with a single Terracotta node:

```bash
cd ./clients/pet-clinic/
docker-compose -f docker-compose.yml up
```

Both command should start the full infrastructure without issues.