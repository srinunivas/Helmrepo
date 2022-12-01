#!/bin/bash
function createUsers(){
  echo "##########begin createUsers "
  declare users=""
  declare user=""
  declare client=""
  declare -i index=1
  separator=", "
  while [ $index -le $USN ]
  do
    echo $index
    user=' {    "username": "user'$index'","enabled": true,"attributes":[{"saml.persistent.name.id.for.'$SPU'":"user'$index'"}],"credentials": [{ "type": "password","value": "password"}],"clientRoles": { "realm-management": [ "realm-admin" ],"account": [ "manage-account" ]}}'
    users=$users$separator$user
    index+=1
  done
  cp /tmp/keycloak-template.json /tmp/keycloak-config-generated.json
  echo "users =  $users"
  sed -i "s=USERS_TO_REPLACE=$users=" /tmp/keycloak-config-generated.json

  echo "##########begin generateClienturl "

  client='"clients": [{"clientId": "'$SPU'","directAccessGrantsEnabled": true,"enabled": true,"publicClient": true,"fullScopeAllowed": true,"baseUrl": "'$SPU'","redirectUris": ["'$SPU'*"],"secret": "password","frontchannelLogout": false,"protocol": "saml","attributes": {	"saml.assertion.signature": true,	"saml.authnstatement": false,	"saml.server.signature": false,	"saml.signature.algorithm": "RSA_SHA256",	"saml_signature_canonicalization_method": "http://www.w3.org/2001/10/xml-exc-c14n#",	"saml_name_id_format": "username", "saml_force_name_id_format": "true", "saml.signature.keyName": "NONE",	"saml.client.signature": false,	"saml.force.post.binding": false}}]'
  echo "clients =  $client"
  sed -i "s=CLIENT_TO_REPLACE=$client=" /tmp/keycloak-config-generated.json
}


USN=$USERS_NUMBER
SPU=$SP_URL
echo "USN=$USN"
echo "SPU=$SPU"

if [ -z "$SPU" ]
then
  echo "ERROR! SP_URL not set. "
  exit 0  
fi

if [ -z "$USN" ]
then
  echo "USN is not set : default value 10"
  USN=10  
fi
createUsers $USN

/opt/jboss/tools/docker-entrypoint.sh  -b 0.0.0.0


