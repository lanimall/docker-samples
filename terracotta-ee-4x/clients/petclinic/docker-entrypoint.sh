#!/bin/bash

echo "Inside entrypoint -- Will connect the app to TSA_URL = ${TSA_URL}"
echo "Inside entrypoint -- JAVA_OPTS = ${JAVA_OPTS}"

# start the app using maven command
mvn tomcat7:run ${JAVA_OPTS} -Dtsa_url=${TSA_URL}