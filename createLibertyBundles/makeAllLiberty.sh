#!/bin/bash

# created by Brian S Paskin
# 5 July 2018
#set -x
LIBERTY=20.0.0.12
VERSIONS=("core" "base" "nd")
SYSTEMS=("aix-ppc64" "linux-ppc64" "linux-ppc64le" "linux-x86_64" "linux-s390x")
JAVA=8.0-6.16
JAVA11=11.0.9_11
TMP=/WAS/repository/liberty/tmp

for VERSION in "${VERSIONS[@]}"
do
        for SYSTEM in "${SYSTEMS[@]}"
        do
                echo "\nCreating $LIBERTY $VERSION for $SYSTEM\n"
                /bin/mkdir ${TMP}
                java -jar wlp-${VERSION}-all-${LIBERTY}.jar --acceptLicense ${TMP}
                /bin/cp -R etc ${TMP}/wlp
                /bin/cp -R resources ${TMP}/wlp/usr/shared
                /bin/cp server-config.xml ${TMP}/wlp/usr/shared/config/server.xml
                /bin/cp server.xml ${TMP}/wlp/templates/servers/defaultServer/
                /bin/cp jvm.options ${TMP}/wlp/templates/servers/defaultServer/
                /bin/cp oidc.xml ${TMP}/wlp/templates/servers/defaultServer/
                /bin/cp bootstrap.properties ${TMP}/wlp/templates/servers/defaultServer/

                /bin/mkdir ${TMP}/wlp/java
                /bin/cp java.env ${TMP}/wlp/java

                FILENAME=`ls /WAS/repository/liberty/ibm-java-sdk-${JAVA}-${SYSTEM}.*`
                /bin/mkdir ${TMP}/java
                /bin/cp ${FILENAME} ${TMP}/java/java.tar.gz
                /bin/gzip -d ${TMP}/java/java.tar.gz
                /bin/tar -xf ${TMP}/java/java.tar -C ${TMP}/java
                /bin/rm ${TMP}/java/java.tar
                FILENAME=`ls ${TMP}/java/`
                /bin/mv  ${TMP}/java/${FILENAME} ${TMP}/wlp/java/8.0
                /bin/rm -Rf ${TMP}/java

                FILENAME=`ls /WAS/repository/liberty/OpenJDK11U-openj9-${JAVA11}-${SYSTEM}.*`
                /bin/mkdir ${TMP}/java
                /bin/cp ${FILENAME} ${TMP}/java/java.tar.gz
                /bin/gzip -d ${TMP}/java/java.tar.gz
                /bin/tar -xf ${TMP}/java/java.tar -C ${TMP}/java
                /bin/rm ${TMP}/java/java.tar
                FILENAME=`ls ${TMP}/java/`
                /bin/mkdir ${TMP}/wlp/java/11.0
                /bin/mv  ${TMP}/java/${FILENAME} ${TMP}/wlp/java/11.0/jre
                /bin/rm -Rf ${TMP}/java

                /bin/tar -cf wlp-${VERSION}-${LIBERTY//.}-${SYSTEM}.tar -C ${TMP} wlp
                /bin/gzip wlp-${VERSION}-${LIBERTY//.}-${SYSTEM}.tar
                /bin/rm -Rf  ${TMP}
        done
done
