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

RUN wget http://admin:redhat@34.222.58.127:8081/repository/repo/onoguera/login-web-application/${version}.RELEASE/login-web-application-${version}.RELEASE.jar
CMD java -jar login-web-application-${version}.RELEASE.jar
EXPOSE 8080


===========================

FROM ubuntu

ARG VERSION=4.3
ARG user=jenkins
ARG group=jenkins
ARG uid=1000
ARG gid=1000

RUN groupadd -g ${gid} ${group}
RUN useradd -c "Jenkins user" -d /home/${user} -u ${uid} -g ${gid} -m ${user}
LABEL Description="This is a base image, which provides the Jenkins agent executable (agent.jar)" Vendor="Jenkins project" Version="${VERSION}"

ARG AGENT_WORKDIR=/home/${user}/agent





RUN apt-get update && \
    apt-get install -y software-properties-common && \
    rm -rf /var/lib/apt/lists/*

RUN apt-get update -y && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    ansible\
    default-jdk \
    bzip2 \
    cdbs \
    curl \
    debhelper \
    debianutils \
    devscripts \
    docbook-xml \
    dpkg-dev \
    fakeroot \
    gawk \
    gcc \
    git \
    libffi-dev \
    libssl-dev \
    libxml2-utils \
    locales \
    make \
    mercurial \
    openssh-client \
    openssh-server \
    python-dev \
    pass \
    python-httplib2 \
    python-jinja2 \
    python-lxml \
    python-mock \
    python-nose \
    python-passlib \
    reprepro \
    rsync \
    ruby \
    sshpass \
    subversion \
    sudo \
    tzdata \
    unzip \
    xsltproc \
    zip \
    && \
    apt-get clean


# helpful things taken from the ubuntu-upstart Dockerfile:
# https://github.com/tianon/dockerfiles/blob/4d24a12b54b75b3e0904d8a285900d88d3326361/sbin-init/ubuntu/upstart/14.04/Dockerfile
ADD init-fake.conf /etc/init/fake-container-events.conf

# undo some leet hax of the base image
RUN rm /usr/sbin/policy-rc.d; \
        rm /sbin/initctl; dpkg-divert --rename --remove /sbin/initctl
# remove some pointless services
RUN /usr/sbin/update-rc.d -f ondemand remove; \
        for f in \
                /etc/init/u*.conf \
                /etc/init/mounted-dev.conf \
                /etc/init/mounted-proc.conf \
                /etc/init/mounted-run.conf \
                /etc/init/mounted-tmp.conf \
                /etc/init/mounted-var.conf \
                /etc/init/hostname.conf \
                /etc/init/networking.conf \
                /etc/init/tty*.conf \
                /etc/init/plymouth*.conf \
                /etc/init/hwclock*.conf \
                /etc/init/module*.conf\
        ; do \
                dpkg-divert --local --rename --add "$f"; \
        done; \
        echo '# /lib/init/fstab: cleared out for bare-bones Docker' > /lib/init/fstab
# end things from ubuntu-upstart Dockerfile

RUN rm /etc/apt/apt.conf.d/docker-clean
# RUN mkdir /etc/ansible/
RUN /bin/echo -e "[local]\nlocalhost ansible_connection=local" > /etc/ansible/hosts
RUN locale-gen en_US.UTF-8
RUN ssh-keygen -q -t rsa -N '' -f /root/.ssh/id_rsa && \
    cp /root/.ssh/id_rsa.pub /root/.ssh/authorized_keys && \
    for key in /etc/ssh/ssh_host_*_key.pub; do echo "localhost $(cat ${key})" >> /root/.ssh/known_hosts; done
VOLUME /sys/fs/cgroup /run/lock /run /tmp
RUN curl --create-dirs -fsSLo /usr/share/jenkins/agent.jar https://repo.jenkins-ci.org/public/org/jenkins-ci/main/remoting/${VERSION}/remoting-${VERSION}.jar \
  && chmod 755 /usr/share/jenkins \
  && chmod 644 /usr/share/jenkins/agent.jar \
  && ln -sf /usr/share/jenkins/agent.jar /usr/share/jenkins/slave.jar

USER ${user}
ENV AGENT_WORKDIR=${AGENT_WORKDIR}
RUN mkdir /home/${user}/.jenkins && mkdir -p ${AGENT_WORKDIR}

VOLUME /home/${user}/.jenkins
VOLUME ${AGENT_WORKDIR}
WORKDIR /home/${user}
