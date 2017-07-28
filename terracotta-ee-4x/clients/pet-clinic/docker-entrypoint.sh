#!/bin/bash

echo "Inside entrypoint -- Will connect the app to TSA_URL = ${TSA_URL}"
echo "Inside entrypoint -- Using ehcache.version=${ehcache_version} and terracotta-toolkit-runtime.version=${terracotta_version} with license=${TC_LICENSE_PATH}"

# start the app using maven command
mvn tomcat7:run \
-Dcom.tc.productkey.path=${TC_LICENSE_PATH} \
-Dehcache.artifactid=ehcache-ee -Dehcache.version=${ehcache_version} \
-Dterracotta-toolkit-runtime.artifactid=terracotta-toolkit-runtime-ee -Dterracotta-toolkit-runtime.version=${terracotta_version} \
-Dtsa_url=${TSA_URL}
