#!/bin/sh
set +x

siteinfo=$(/usr/local/easysoft/oracle/siteinfo)
echo "Checking license for ${siteinfo} from the DB"
curl -s -f -X GET 'http://inventaire.fircosoft.net:5984/licenses/_design/keySite/_view/keys-per-site?group_level=1&startkey=\["'"${siteinfo}"'"\]&endkey=\["'"${siteinfo}"'\ufff0"\]' -u licm:greatstuffhere -o /tmp/key.json

key=$(jq -r '.rows[0].value.license_key // ""' /tmp/key.json)
expiration_date=$(jq -r '.rows[0].value.expiration_date // ""' /tmp/key.json)
expiration_timestamp=$(date --date="$expiration_date" +%s)
timestamp=$(date +%s)

request_license="no"

if [ -z "$key" ]
then
  echo "No license for site $siteinfo ..."
  request_license="yes"
else
  if [ "$expiration_timestamp" -lt "$timestamp" ]
  then
    echo "License for site $siteinfo has expired ..."
    request_license="yes"
  fi
fi

if [ "$request_license" = "yes" ]
then
  echo "Requesting license"
  expect /opt/third-parties/easysoft/license-dialog.exp

  license_status=$(/usr/local/easysoft/license/licshell view 2>&1 | head -1 | cut -f1 -d' ')
  if [ "$license_status" = "No" ] || [ "$license_status" = "Failed" ]
  then
    echo "License was not installed correctly, please check log messages"
  else
    echo "License was installed correctly, pushing data to the DB"
    license_info=$(/usr/local/easysoft/license/licshell view | tail -1)
    product=$(echo "$license_info" | cut -c -21)
    expiration_date=$(echo "$license_info" | cut -c 43-63)
    expiration_date=$(date --date="$expiration_date" +%FT%T)
    creation_date=$(echo "$license_info" | cut -c 22-42)
    creation_date=$(date --date="$creation_date" +%FT%T)
    version=$(echo "$license_info" | cut -c 74-)
    key=$(grep "^[^#]" /usr/local/easysoft/license/licenses | head -1)

    id=$(uuidgen | sed 's/-//g')
    curl -s -f -X PUT "http://inventaire.fircosoft.net:5984/licenses/$id" \
        -u licm:greatstuffhere \
        -d '{"vendor": "easysoft", "product":"'"$product"'", "version":"'"$version"'", "siteinfo":"'"$siteinfo"'", "license_key":"'"$key"'", "expiration_date":"'"$expiration_date"'", "request_date":"'"$creation_date"'"}'
  fi
else
  echo "Found license $key for site $siteinfo"
  mv -bf /usr/local/easysoft/license/licenses /usr/local/easysoft/license/licenses.bak
  echo "$key" > /usr/local/easysoft/license/licenses
fi

# define ODBC_DRIVER to use the EasySoft driver as default one on
# /opt/third-parties/unixodbc-oracle-client/entrypoint.sh
export ODBC_DRIVER='ORACLE'

exec /opt/third-parties/unixodbc-oracle-client/entrypoint.sh "$*"