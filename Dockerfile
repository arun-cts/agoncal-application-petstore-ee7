# Base image with wildfly server on it
FROM jboss/wildfly:latest

# Appserver related env variables
ENV WILDFLY_USER admin
ENV WILDFLY_PASS adminPassword

# Database related env variables. In PCF, this should be overridden by using cf set-env command
ENV DB_NAME moviefun
ENV DB_INSTANCE_NAME moviefun
ENV DB_USER db_user
ENV DB_PASS db_password
ENV DB_URI localhost:3306

ENV MYSQL_VERSION 8.0.15
ENV JBOSS_CLI /opt/jboss/wildfly/bin/jboss-cli.sh
ENV DEPLOYMENT_DIR /opt/jboss/wildfly/standalone/deployments/


# Setting up WildFly Admin Console
RUN echo "=> Adding WildFly administrator"
RUN $JBOSS_HOME/bin/add-user.sh -u $WILDFLY_USER -p $WILDFLY_PASS --silent

# Downloading MySQL driver jar with specified mysql version (can be customizable from environment variable - In PCF use cf set-env)
RUN echo "=> Downloading MySQL driver" && \
  curl --location --output /tmp/mysql-connector-java-${MYSQL_VERSION}.jar --url http://search.maven.org/remotecontent?filepath=mysql/mysql-connector-java/${MYSQL_VERSION}/mysql-connector-java-${MYSQL_VERSION}.jar

# Copying application packaged archive to deployments folder of Wildfly server
ADD target/petstoreee7-7.0.war /opt/jboss/wildfly/standalone/deployments/

# Copying shell script for customizing and starting of Wildfly server to root
ADD configureAndStartJBoss.sh /

# Expose http and admin ports
EXPOSE 8080 9990

# Executing the shell script to customize the Wildfly configuration for datasource using jboss-cli and restart jboss
CMD ["/configureAndStartJBoss.sh"]
