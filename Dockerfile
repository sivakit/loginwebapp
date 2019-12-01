From tomcat:latest
MAINTAINER sivaece496@gmail.com
RUN yum -y upgrade
RUN yum -y install wget
RUN wget http://admin:redhat@34.222.58.127:8081/repository/repo/onoguera/login-web-application/3.0.0.RELEASE/login-web-application-3.0.0.RELEASE.jar
java -jar login-web-application-3.0.0.RELEASE.jar
EXPOSE 8080
