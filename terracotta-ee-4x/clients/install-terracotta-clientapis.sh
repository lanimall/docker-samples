#!/bin/sh
EHCACHE_GROUPID="net.sf.ehcache"
TERRACOTTA_GROUPID="org.terracotta"

# This script is expected to run from the Terracotta base path
TERRACOTTA_APIS=./apis

for jarfile in "$TERRACOTTA_APIS"/ehcache/lib/ehcache*.jar; do
	filenamefull=$(basename $jarfile);
	filename_version=$(echo $filenamefull | sed 's/.*-\([0-9]*\.[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*\).*/\1/');
	filename_noversion=$(echo $filenamefull | sed 's/-[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*//g');
	filename=$(echo $filename_noversion | cut -f 1 -d '.');
	#echo "$jarfile";
	#echo "$filenamefull";
	#echo "$filename_noversion";
	#echo "$filename_version";
	#echo "$filename";
	mvn install:install-file -Dfile=${jarfile} -DgroupId=${EHCACHE_GROUPID} -DartifactId=${filename} -Dversion=${filename_version} -Dpackaging=jar;
done

for jarfile in "$TERRACOTTA_APIS"/toolkit/lib/*toolkit*.jar; do
	filenamefull=$(basename $jarfile);
	filename_version=$(echo $filenamefull | sed 's/.*-\([0-9]*\.[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*\).*/\1/');
	filename_noversion=$(echo $filenamefull | sed 's/-[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*//g');
	filename=$(echo $filename_noversion | cut -f 1 -d '.');
	#echo "$jarfile";
	#echo "$filenamefull";
	#echo "$filename_noversion";
	#echo "$filename_version";
	#echo "$filename";
	mvn install:install-file -Dfile=${jarfile} -DgroupId=${TERRACOTTA_GROUPID} -DartifactId=${filename} -Dversion=${filename_version} -Dpackaging=jar;
done