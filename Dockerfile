FROM openjdk:8-jre-alpine
LABEL Pentaho server 9.1

ENV PENTAHO_HOME /opt/pentaho
ENV PENTAHO_JAVA_HOME $JAVA_HOME
ENV PENTAHO_SERVER ${PENTAHO_HOME}/server/pentaho-server
ENV CATALINA_OPTS="-Djava.awt.headless=true -Xms4096m -Xmx8192m -XX:MaxPermSize=256m -Dsun.rmi.dgc.client.gcInterval=3600000 -Dsun.rmi.dgc.server.gcInterval=3600000"

# Get support packages
RUN apk add --update wget curl unzip tzdata bash postgresql-client ttf-dejavu

WORKDIR /tmp

RUN curl -L -o pentaho-server-ce-9.4.0.0-343.zip https://privatefilesbucket-community-edition.s3.us-west-2.amazonaws.com/9.4.0.0-343/ce/server/pentaho-server-ce-9.4.0.0-343.zip
RUN curl -L -o jtds-1.3.1.jar https://repo1.maven.org/maven2/net/sourceforge/jtds/jtds/1.3.1/jtds-1.3.1.jar
RUN curl -L -o mssql-jdbc-6.4.0.jre8.jar https://repo1.maven.org/maven2/com/microsoft/sqlserver/mssql-jdbc/6.4.0.jre8/mssql-jdbc-6.4.0.jre8.jar
RUN curl -L -o mysql-connector-java-5.1.17.jar https://repo1.maven.org/maven2/mysql/mysql-connector-java/5.1.17/mysql-connector-java-5.1.17.jar
RUN curl -L -o mysql-connector-java-8.0.11.jar https://repo1.maven.org/maven2/mysql/mysql-connector-java/8.0.11/mysql-connector-java-8.0.11.jar

# Setup pentaho user
RUN mkdir -p ${PENTAHO_HOME}/server; mkdir ${PENTAHO_HOME}/.pentaho; adduser -D -s /bin/sh -h ${PENTAHO_HOME} pentaho; chown -R pentaho:pentaho ${PENTAHO_HOME}

USER pentaho

WORKDIR ${PENTAHO_HOME}/server

# Get Pentaho Server
RUN cp /tmp/pentaho-server-ce-9.4.0.0-343.zip tmp.zip && unzip -q tmp.zip -d ${PENTAHO_HOME}/server && rm -f tmp.zip
RUN cp /tmp/jtds-1.3.1.jar ${PENTAHO_HOME}/server/pentaho-server/tomcat/lib/
RUN cp /tmp/mssql-jdbc-6.4.0.jre8.jar ${PENTAHO_HOME}/server/pentaho-server/tomcat/lib/
RUN cp /tmp/mysql-connector-java-5.1.17.jar ${PENTAHO_HOME}/server/pentaho-server/tomcat/lib/
RUN cp /tmp/mysql-connector-java-8.0.11.jar ${PENTAHO_HOME}/server/pentaho-server/tomcat/lib/

# Delete the samples zip file from the ${PENTAHO_HOME}/server/pentaho-solutions/system/default-content
RUN rm -rf ${PENTAHO_HOME}/server/pentaho-solutions/system/default-content/samples.zip

# Disable first-time startup prompt
RUN rm ${PENTAHO_SERVER}/promptuser.sh

# Disable daemon mode for Tomcat
RUN sed -i -e 's/\(exec ".*"\) start/\1 run/' ${PENTAHO_SERVER}/tomcat/bin/startup.sh

# Copy scripts and fix permissions
USER root

COPY scripts ${PENTAHO_HOME}/scripts
COPY config ${PENTAHO_HOME}/config
RUN chown -R pentaho:pentaho ${PENTAHO_HOME}/scripts && chmod -R +x ${PENTAHO_HOME}/scripts

#Configure Timezone Europe/Moscow
RUN cp /usr/share/zoneinfo/Europe/Moscow /etc/localtime
RUN echo "Europe/Moscow" >  /etc/timezone

USER pentaho

EXPOSE 8080
ENTRYPOINT ["sh", "-c", "$PENTAHO_HOME/scripts/run.sh"]
