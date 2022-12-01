# Fircosoft base image for RedHat

This image intends to serve as base image for deploying Fircosoft products. It derives from the **Universal Base Image** [**ubi**] or **RedHat** images provided by Red Hat Inc.

## Installed packages
The following packages are deployed:

* OpenJDK version 11
* Development Tools: llvm-toolset, gcc-gfortran, libstdc++.i686, libaio.i686 and libsnl
* Oracle instantclient 19.6 basic, sqlplus and odbc packages
* IBM MQ client 9.2 package