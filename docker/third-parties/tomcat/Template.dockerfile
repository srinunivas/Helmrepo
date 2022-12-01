FROM tomcat:{{version}}

# Create non-root user tomcat
RUN adduser --no-create-home --disabled-password --gecos "" tomcat \
  && adduser tomcat tomcat

RUN chown -R tomcat:tomcat webapps

# Logged as tomcat user
USER tomcat
