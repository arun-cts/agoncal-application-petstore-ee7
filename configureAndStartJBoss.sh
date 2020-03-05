#!/bin/bash
# Added by FEGO

echo $DB_NAME
echo $DB_USER
echo $DB_PASS
echo $DB_URI 

echo "=> Starting WildFly server" && \
      bash -c '$JBOSS_HOME/bin/standalone.sh &' && \
echo "=> Waiting for the server to boot" && \
  bash -c 'until `$JBOSS_CLI -c ":read-attribute(name=server-state)" 2> /dev/null | grep -q running`; do echo `$JBOSS_CLI -c ":read-attribute(name=server-state)" 2> /dev/null`; sleep 1; done' && \
echo "=> Adding MySQL module" && \
  $JBOSS_CLI --connect --command="module add --name=com.mysql --resources=/tmp/mysql-connector-java-${MYSQL_VERSION}.jar --dependencies=javax.api,javax.transaction.api" && \
echo "=> Adding MySQL driver" && \
                                 #/subsystem=datasources/jdbc-driver=mysql:add(driver-name=mysql,driver-module-name=com.mysql.driver,driver-class-name=com.mysql.jdbc.Driver)
  $JBOSS_CLI --connect --command="/subsystem=datasources/jdbc-driver=mysql:add(driver-name=mysql,driver-module-name=com.mysql,driver-xa-datasource-class-name=com.mysql.cj.jdbc.MysqlXADataSource)" && \
echo "=> Creating a new datasource" && \
  $JBOSS_CLI --connect --command="data-source add \
    --name=${DB_NAME}DS \
    --jndi-name=java:/jdbc/${DB_NAME} \
    --user-name=${DB_USER} \
    --password=${DB_PASS} \
    --driver-name=mysql \
    --connection-url=jdbc:mysql://${DB_URI}/${DB_INSTANCE_NAME} \
    --use-ccm=false \
    --max-pool-size=25 \
    --blocking-timeout-wait-millis=5000 \
    --enabled=true" && \
echo "=> Shutting down WildFly and Cleaning up" && \
  $JBOSS_CLI --connect --command=":shutdown" && \
  rm -rf $JBOSS_HOME/standalone/configuration/standalone_xml_history/ $JBOSS_HOME/standalone/log/* && \
  rm -f /tmp/*.jar

#starting the server with updated configuration
bash -c '$JBOSS_HOME/bin/standalone.sh -b 0.0.0.0 -bmanagement 0.0.0.0'
