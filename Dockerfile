FROM tomcat:10.1-jdk17
LABEL maintainer="Avadut Patil"
RUN rm -rf /usr/local/tomcat/webapps/*
COPY target/maven-web-app.war /usr/local/tomcat/webapps/ROOT.war
EXPOSE 8080
CMD ["catalina.sh","run"]
