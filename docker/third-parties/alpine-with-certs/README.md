# Alpine image with latest certificates

This image is based on **`alpine`** with the addition of the latest SSL certificates required for all `apk` operations.

Otherwise when using the latest **`alpine`** image you will experience this error:
```
#5 [2/5] RUN apk update && apk upgrade && apk add openjdk11-jre
#5 sha256:5e92234430d6a6c349863fda44bdcff0c1bd69e59e77656e5054a54de10cc9ac
#5 0.558 fetch https://dl-cdn.alpinelinux.org/alpine/v3.14/main/x86_64/APKINDEX.tar.gz
#5 1.652 139798116363080:error:1416F086:SSL routines:tls_process_server_certificate:certificate verify failed:ssl/statem/statem_clnt.c:1914:
#5 1.654 ERROR: https://dl-cdn.alpinelinux.org/alpine/v3.14/main: Permission denied
#5 1.654 WARNING: Ignoring https://dl-cdn.alpinelinux.org/alpine/v3.14/main: No such file or directory
#5 1.654 fetch https://dl-cdn.alpinelinux.org/alpine/v3.14/community/x86_64/APKINDEX.tar.gz
#5 1.702 139798116363080:error:1416F086:SSL routines:tls_process_server_certificate:certificate verify failed:ssl/statem/statem_clnt.c:1914:
#5 1.704 ERROR: https://dl-cdn.alpinelinux.org/alpine/v3.14/community: Permission denied
#5 1.704 WARNING: Ignoring https://dl-cdn.alpinelinux.org/alpine/v3.14/community: No such file or directory
#5 1.704 2 errors; 14 distinct packages available
#5 ERROR: executor failed running [/bin/sh -c apk update && apk upgrade && apk add openjdk11-jre]: exit code: 2
```

It is a chicken and egg problem where running the `update-ca-certificates` requires the installation of the package **ca-certificates**. Solution is to add the certificate from https://dl-cdn.alpinelinux.org/ in the <ins>`/etc/ssl/certs/ca-certificates.crt`</ins> file. The package can be installed, the certificate is then copied in <ins>`/usr/local/share/ca-certificates`</ins> directory and the `update-ca-certificates` command can be executed.

Finally the `apk update` and `apk upgrade` commands are executed.