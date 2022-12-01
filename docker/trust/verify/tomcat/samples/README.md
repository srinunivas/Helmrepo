# Trust Verify V5 with LDAP Basic Authentication

**Usage**

```sh
# Show configuration
docker-compose config

# Start
docker-compose up -d ldap-server
docker-compose start ldap-server
docker-compose up -d ldap-client
docker-compose up -d database
docker-compose up -d verify

# Display logs
docker-compose logs -f

# Stop
docker-compose down
```

- Trust Verify URL: `http://<server-ip>:8320/trust`.
- LDAP Account Manager URL: `http://<server-ip>:5290/lam`, the admin password is `Hello00`.
- LDAP mapped server port: `5289`

The [ldap.bootstrap.ldif file](ldap.bootstrap.ldif) adds 2 accounts on the LDAP database:

- `#admin1` with password `Hello00`
- `acunetix` with password `Hello00`

To use the environment, you must create the user `acunetix` from the Trust
Verify application.

**Note** When using LDAP Basic Authentication, you must use password setted on
LDAP database to sign in to Trust Verify application.
