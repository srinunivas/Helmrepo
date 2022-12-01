#!/bin/sh

###################################################################################
# Create the mTLS curl command onto localhost CMAPI health-check endpoint, by
# - extracting keystore location, passwords and service port from runtime setting
# - converting JKS keystore into P12 if necessary
# - extracting pem certificate and private key supported by curl from the keystore
# and finally
# - creating a command under "/opt/cty-backend/cmapi-healthcheck" that examines
#   the CMAPI response to give result in 0/1 exit code
###################################################################################

healthcheck=/opt/cty-backend/cmapi-healthcheck
echo "#!/bin/sh" > $healthcheck
echo "exit 0" > $healthcheck
chmod +x $healthcheck

properties=/opt/cty-backend/conf/CaseManagerAPI.properties

keystore_file_location=`grep server.ssl.key-store= $properties| cut -d = -f2`
keystore_password=`grep server.ssl.key-store-password= $properties| cut -d = -f2`
key_password=`grep server.ssl.key-password= $properties| cut -d = -f2`
# regex and ^ because we don't want to match defaults.server.port line by grep
server_port=`grep -E ^server.port= $properties| cut -d = -f2`

dir=/opt/cty-backend/keys
rm -rf $dir
mkdir $dir
cd $dir

keystore_file_location=`echo $(eval echo $keystore_file_location)`
case $keystore_file_location in
file:*)
  keystore_file_location=`echo $keystore_file_location | cut -d : -f2` ;;
esac
server_port=`echo $(eval echo $server_port)`

# if the keystore is in JKS, convert it to p12
case $keystore_file_location in
*.jks)
  keytool -importkeystore -srckeystore $keystore_file_location \
    -destkeystore keystore.p12 -deststoretype pkcs12 \
    -deststorepass $keystore_password -srcstorepass $keystore_password
  keystore_file_location=`realpath keystore.p12`
  ;;
esac

# extract PEM certificate and private key
openssl pkcs12 -in $keystore_file_location -out my_crt.pem -clcerts -nokeys -password pass:$keystore_password
openssl pkcs12 -in $keystore_file_location -out my_key.pem -nocerts -nodes -password pass:$key_password
crt_file=`realpath my_crt.pem`
key_file=`realpath my_key.pem`

url=https://localhost:$server_port/cmapi-health

cat > $healthcheck <<EOF
#!/bin/sh

# curl will silently (-s) interrogate CMAPI for its health with max 5s (-m 5) request.
response=\$(curl -s -m 5 --cacert $crt_file --key $key_file --cert $crt_file $url)
echo "response: \$response (curl command's exit code: \$?)"

# the response should contain "CMAPI is up"
case \$response in
*'"CMAPI is up"'* ) exit 0;;
* ) exit 1;;
esac
EOF

###################################################################################
# display some useful information for this docker container user
###################################################################################
cat <<EOF

*****************************************************************************
Case Manager API docker documentation: Here is some useful information.

- The package is unzipped under /opt/cty-backend.
- The standard start script (/opt/cty-backend/ContinuityCaseManagerAPI/Start_CaseManagerAPI.sh)
  is used to launch the Case Manager API program.
- You can replace any file or directory via "-v (or --volume)". (true for any docker)
- If you give "[COMMAND] [ARG...]" after the IMAGE argument of "docker run" command,
  i.e. docker run ... jenkins-deploy.fircosoft.net/continuity6/cty-cmapi:master java -version,
  in such a case "java -version" will be executed without starting the Case Manager API.

Docker run command example:
    $ docker run \\
      -v /tmp/my-cmapi-config.properties:/opt/cty-backend/conf/CaseManagerAPI.properties \\
      -v /tmp/backend-log:/opt/cty-backend/log \\
      -it --hostname cmapi-host --name cmapi --rm \\
      jenkins-deploy.fircosoft.net/continuity6/cty-cmapi:master

N.B. As of the initial version, the license file for 6.4.0.0 is included
      and placed /opt/cty-backend/conf/fbe.cf.
*****************************************************************************

EOF

###################################################################################
# finally execute the CMAPI startup script, or given command
###################################################################################
if [[ "$1" == "" ]]; then
  echo "==========================================="
  echo "Invoking the Case Manager API start script:"
  echo "==========================================="
  cd /opt/cty-backend/ContinuityCaseManagerAPI
  ./Start_CaseManagerAPI.sh
else
  echo "==========================================="
  echo "Executing the following: $@"
  echo "==========================================="
  $@
fi