FROM centos:7
MAINTAINER sivaece496@gmail.com
RUN yum -y update && \
yum -y install httpd && \
yum -y install wget && \
yum -y install java && \
yum clean all
ARG version
RUN wget http://admin:redhat@34.222.58.127:8081/repository/repo/onoguera/login-web-application/${version}.RELEASE/login-web-application-${version}.RELEASE.jar
CMD java -jar login-web-application-${version}.RELEASE.jar
EXPOSE 8080
