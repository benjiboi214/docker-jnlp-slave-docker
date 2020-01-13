FROM python:3.7-alpine

# Tini
ADD https://github.com/krallin/tini/releases/download/v0.18.0/tini /tini
RUN chmod +x /tini

# Get Curl
RUN apk add curl

# AWS CLI, j2cli
RUN pip3 install awscli && \
    pip3 install j2cli

# Jenkins
ENV HOME /home/jenkins
RUN adduser --home $HOME --uid 10000 --disabled-password jenkins
LABEL Description="This is a base image, which provides the Jenkins agent executable (slave.jar) and tools: j2cli, awscli, docker client, kubectl and helm" Vendor="KoreKontrol" Version="3.27"

ARG VERSION=3.27

RUN curl --create-dirs -sSLo /usr/share/jenkins/slave.jar https://repo.jenkins-ci.org/public/org/jenkins-ci/main/remoting/${VERSION}/remoting-${VERSION}.jar \
  && chmod 755 /usr/share/jenkins \
  && chmod 644 /usr/share/jenkins/slave.jar

USER jenkins
RUN mkdir /home/jenkins/.jenkins
VOLUME /home/jenkins/.jenkins
WORKDIR /home/jenkins

# jnlp slave
COPY jenkins-slave /usr/local/bin/jenkins-slave
ENTRYPOINT ["/tini", "--", "jenkins-slave"]
