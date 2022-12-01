# SOAP CMAPI + mock client/server
**Case Manager API**, its **mock server** and **client** will run communicating with each other.
Respectively, their containers are named `cmapisoap`, `soapservermock` and `soapclientmock` and
these are their resolved hostnames.

## mTLS keystore, truststores
The **Mock Server** should identify itself and should be *trusted* by **Case Manager API**, its client.
As the authentication is mutual with **mTLS**, Case Manager API's identity also should be trusted
in the `truststore` used by the Mock Server. Case Manager API's identity should equally be trusted
by the **Mock Client**. And Mock Client's identity should be trusted by Case Manager API.

[Mock Server] <==> [Case Manager API] <==> [Mock Client]

There is no networking between Mock Server and Mock Client.

This means we need
- Three identities (keystore + certificates)
- One truststore with all the three certificates

### Create the "keystore", the identity
```sh
# keystore may be in other than JKS format. ".p12" is accepted.
$ keytool -genkey -alias keys -keyalg RSA -storetype PKCS12 \
-keystore cmapikeystore.p12 -ext SAN=dns:cmapisoap,dns:localhost,ip:127.0.0.1
```
This will create a file "cmapikeystore.p12". The part **-ext SAN=dns:cmapisoap** (SAN = **Subject Alternative Names**)
is important if you want CMAPI and other components to run on different docker containers.
"cmapisoap" declares the docker container machine's hostname, resolvable
under the same docker bridge network.

The docker container machine's names are defined in `docker-compose.yml`, with **container_name**
directive.

From the three keystores, we export the "certificate" files, from which we create the total
**truststore**.

```sh
$ for i in *.p12
do f=`basename $i .p12`
keytool -export -alias keys -file $f.cer -keystore $i
done

$ for i in *.cer
do keytool -import -file $i -alias `basename $i .cer`CA -keystore truststore
done
```

The used password is `secret`, alias `keys`, as is specified in properties files.

## Environment variable values used hard-written in docker-compose.yml
It is important to keep them coherent between them. If you change environment variable values,
change them in `docker-compose.yml` file also.
- envs/general
    - MOCK_SENDER_DIR=/var/cmapi-data
- envs/keys
    - CMAPI_KEY=/opt/cty-backend/cmapikeystore.p12
    - MOCK_SERVER_KEY=/opt/cty-backend/mockserverkeystore.p12
    - MOCK_CLIENT_KEY=/opt/cty-backend/mockclientkeystore.p12
    - TRUST_STORE=/opt/cty-backend/truststore
