# Copy this script template to customize runtime environment by modify existing options from env_mandatory.sh
# or add new one through JAVA_LS_MISC_OPTS and JAVA_LS_JAR_MISC_OPTS variables

 JAVA_TRUSTSTORE_OPTS="\
 -Djavax.net.ssl.trustStore=/LiveServices/Certs/cacerts.jks \
 -Djavax.net.ssl.trustStorePassword=changeit \
 "
LOG_DIR=/LiveServices/log
# JAVA_PROXY_OPTS=" \
# -Dhttp.proxyHost=proxy.intranet \
# -Dhttp.proxyPort=8080 \
# -Dhttp.nonProxyHosts=localhost|127.*|10.*|*.intranet \
# -Dhttps.proxyHost=proxy.intranet \
# -Dhttps.proxyPort=8080 \
# "

# JAVA_MEMORY_OPTS="-Xms512m -Xmx512m -XX:MaxMetaspaceSize=172m"
