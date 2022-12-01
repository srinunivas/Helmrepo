#!/bin/bash

#echo on
#set -x
DB_USER=CTY_DOCKER
DB_USER_PWD=hello00

# SETUP-UP SCRIPTS ARE EXECUTED EACH TIME THE CONTAINER STARTS IN SEQUENCE
#author Filipe Coelho

version=`sqlplus -s $DB_USER/$DB_USER_PWD@orclpdb1 << EOF
   set heading off;
   set pagesize 0;
   SELECT DISTINCT VERSION FROM FIRCO_WKF_DB_VERSIONS WHERE DATABASE_NAME = 'Continuity';
   exit;
EOF`
ret=$?
echo $version

client="FIRCOSOFT"
prodName="Firco Continuity"
prodVer=${version:0:3}
prodOptions="11111111111111"
conc=50
expDate="31/12/2025"
cliLoc="PARIS"
keypad="308201b83082012c06072a8648ce3804013082011f02818100fd7f53811d75122952df4a9c2eece4e7f611b7523cef4400c31e3f80b6512669455d402251fb593d8d58fabfc5f5ba30f6cb9b556cd7813b801d346ff26660b76b9950a5a49f9fe8047b1022c24fbba9d7feb7c61bf83b57e7c6a8a6150f04fb83f6d3c51ec3023554135a169132f675f3ae2b61d72aeff22203199dd14801c70215009760508f15230bccb292b982a2eb840bf0581cf502818100f7e1a085d69b3ddecbbcab5c36b857b97994afbbfa3aea82f9574c0b3d0782675159578ebad4594fe67107108180b449167123e84c281613b7cf09328cc8a6e13c167a8b547c8d28e0a3ae1e2bb3a675916ea37f0bfa213562f1fb627a01243bcca4f1bea8519089a883dfe15ae59f06928b665e807b552564014c3bfecf492a0381850002818100a5b97a7e48b57fe167212f9fa4047bb2edae85f61751e18f60dc56076216dd9a8c73eba0856fc9c95f346e86adf9267d0a5b99e755ce3550a2229ebc93eb77f15e6b88e60fb6fca9fffd20ab562d0cac8c79e1f496b453feb833a1289681d41f510bbfeae8937cbdada6d78e9e5e51e47518ac7f11f3b1ed3901bbbc14cd10a2"

string="$client|$cliLoc|$prodName|$prodVer|$prodOptions|$conc|$expDate"

echo "prod version is $prodVer"
echo
echo $string
echo

final_string="$string|$keypad"


echo -n $final_string | md5sum 

final_string=`echo -n $final_string | md5sum`

final_string=${final_string/ *-/}


query="INSERT INTO FIRCO_WKF_APPLICATION_LICENSES (APPLICATION_ID, CLIENT_NAME, CLIENT_LOCATION, PRODUCT_NAME, PRODUCT_VERSION, PRODUCT_OPTIONS, CONCURRENT_SESSIONS, EXPIRATION_DATE, LICENSE_KEY) VALUES ('2', 'FIRCOSOFT', 'PARIS', 'Firco Continuity', '$prodVer', '$prodOptions', '$conc', TO_DATE('$expDate', 'DD/MM/RR'), '$final_string')"

echo "$query;">license.sql
echo "COMMIT;">>license.sql

sqlplus $DB_USER/$DB_USER_PWD@orclpdb1 @license.sql

rm -rf license.sql