#!/bin/bash

sa_password=$1

/opt/mssql/bin/sqlservr --accept-eula &

status=1
while [ $status -ne 0 ]
do
  sleep 1
  /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P $sa_password -Q "select 1"
  status=$?
done

/opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P $sa_password -i /opt/mssql/createMssqlUser.sql
/opt/mssql-tools/bin/sqlcmd -S localhost -U CTY_DOCKER -P 'hello00' -Q "CREATE DATABASE continuityDB;"
/opt/mssql-tools/bin/sqlcmd -S localhost -U CTY_DOCKER  -P 'hello00' -d "continuityDB" -i /opt/mssql/continuity.sql
version=$(/opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P  $sa_password -h -1 -d "continuityDB" -Q "SET NOCOUNT ON;SELECT VERSION FROM FIRCO_WKF_DB_VERSIONS WHERE DATABASE_NAME = 'Continuity';")

client="FIRCOSOFT"
prodName="Firco Continuity"
prodVer=${version:0:3}
prodOptions="11111111111111"
conc=50
expDate="31/12/2025"
cliLoc="PARIS"
keypad="308201b83082012c06072a8648ce3804013082011f02818100fd7f53811d75122952df4a9c2eece4e7f611b7523cef4400c31e3f80b6512669455d402251fb593d8d58fabfc5f5ba30f6cb9b556cd7813b801d346ff26660b76b9950a5a49f9fe8047b1022c24fbba9d7feb7c61bf83b57e7c6a8a6150f04fb83f6d3c51ec3023554135a169132f675f3ae2b61d72aeff22203199dd14801c70215009760508f15230bccb292b982a2eb840bf0581cf502818100f7e1a085d69b3ddecbbcab5c36b857b97994afbbfa3aea82f9574c0b3d0782675159578ebad4594fe67107108180b449167123e84c281613b7cf09328cc8a6e13c167a8b547c8d28e0a3ae1e2bb3a675916ea37f0bfa213562f1fb627a01243bcca4f1bea8519089a883dfe15ae59f06928b665e807b552564014c3bfecf492a0381850002818100a5b97a7e48b57fe167212f9fa4047bb2edae85f61751e18f60dc56076216dd9a8c73eba0856fc9c95f346e86adf9267d0a5b99e755ce3550a2229ebc93eb77f15e6b88e60fb6fca9fffd20ab562d0cac8c79e1f496b453feb833a1289681d41f510bbfeae8937cbdada6d78e9e5e51e47518ac7f11f3b1ed3901bbbc14cd10a2"

string="$client|$cliLoc|$prodName|$prodVer|$prodOptions|$conc|$expDate"
final_string="$string|$keypad"


echo -n $final_string | md5sum 

final_string=`echo -n $final_string | md5sum`

final_string=${final_string/ *-/}


query="INSERT INTO FIRCO_WKF_APPLICATION_LICENSES (APPLICATION_ID, CLIENT_NAME, CLIENT_LOCATION, PRODUCT_NAME, PRODUCT_VERSION, PRODUCT_OPTIONS, CONCURRENT_SESSIONS, EXPIRATION_DATE, LICENSE_KEY) VALUES ('1', 'FIRCOSOFT', 'PARIS', 'Firco Continuity', '$prodVer', '$prodOptions', '$conc', CONVERT(DATETIME, '$expDate', 103), '$final_string')"

echo "Inserting license in database"
/opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P $sa_password -d "continuityDB" -Q "$query"

pkill sqlservr

echo "Done, continuity database image is ready to use!"