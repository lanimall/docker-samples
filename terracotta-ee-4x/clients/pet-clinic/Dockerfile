# using the latest OpenJDK 8 update (see https://registry.hub.docker.com/u/library/java/ for more details)
FROM openjdk:8-jdk-alpine

MAINTAINER fabien.sanglier@softwareag.com

RUN apk --update add curl tar git openssl ca-certificates bash

# 
# IMPORTANT!!!!: Terracotta EE requires license file. To make it easy, we'll assume that the terracotta license file is added at the root of the mounted volume
#
ARG TERRACOTTA_LICENSE_KEY=terracotta-license.key
ARG ehcache_version
ARG terracotta_version

# Set JAVA HOME
ENV JAVA_HOME /usr/lib/jvm/java-1.8-openjdk/

# the default TSA url - can be overriden to match your environments
ENV TSA_URL 'tsa:9510'

# maven section inspired by https://github.com/carlossg/docker-maven/blob/8ab542b907e69c5269942bcc0915d8dffcc7e9fa/jdk-8/Dockerfile
ENV MAVEN_VERSION 3.3.9

RUN curl -fsSL https://archive.apache.org/dist/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz | tar xzf - -C /usr/share \
  && mv /usr/share/apache-maven-$MAVEN_VERSION /usr/share/maven \
  && ln -s /usr/share/maven/bin/mvn /usr/bin/mvn

ENV MAVEN_HOME /usr/share/maven

# clone app from repository
RUN git clone https://github.com/lanimall/spring-petclinic.git /usr/src/app/
WORKDIR /usr/src/app/
RUN git checkout using-oss-clustered-ehcache

# in a more serious deployment scenario and environment, this is where you would download your java jar
RUN mvn \
-Dehcache.artifactid=ehcache-ee -Dehcache.version=$ehcache_version \
-Dterracotta-toolkit-runtime.artifactid=terracotta-toolkit-runtime-ee -Dterracotta-toolkit-runtime.version=$terracotta_version \
package -DskipTests

# expose the webapp port
EXPOSE 9966

# setting the license location -- terracotta license file should be added at the root of the mounted volume
# Add terracotta license key
ADD $TERRACOTTA_LICENSE_KEY /usr/src/app/
ENV TC_LICENSE_PATH "/usr/src/app/terracotta-license.key"

# use a custom entry point to be able to read the ENV var properly
ADD ./docker-entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/docker-entrypoint.sh

ENTRYPOINT ["docker-entrypoint.sh"]
