FROM tomcat:9-jdk11

COPY target/*.war /usr/local/tomcat/webapps/facebook-app.war

EXPOSE 8080
