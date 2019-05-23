FROM ubuntu:16.04

RUN echo "#!/bin/sh\nexit 0" > /usr/sbin/policy-rc.d

RUN apt update \ 
  && apt --assume-yes install inetutils-ping \
  && apt --assume-yes install telnet \
  && apt --assume-yes install curl \
  && apt --assume-yes install vim \
  && apt --assume-yes install python3-dev python3-pip libxml2-dev libxslt1-dev zlib1g-dev libffi-dev libssl-dev \
  && apt --assume-yes install memcached 

WORKDIR /usr/bin

RUN ln -s pip3 pip

RUN ln -s python3 python

RUN mkdir -p /opt/oracle

RUN mkdir -p /opt/remote_ecg_server

COPY requirements.txt /opt/remote_ecg_server

ENV PYTHONIOENCODING=utf-8

WORKDIR /opt/remote_ecg_server

RUN pip install -r requirements.txt