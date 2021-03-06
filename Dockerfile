#--------- Generic stuff all our Dockerfiles should start with so we get caching ------------
FROM phusion/baseimage:0.9.15

MAINTAINER Tim Sutton<tim@kartoza.com>

RUN  export DEBIAN_FRONTEND=noninteractive
ENV  DEBIAN_FRONTEND noninteractive
RUN  dpkg-divert --local --rename --add /sbin/initctl

RUN echo "deb http://archive.ubuntu.com/ubuntu trusty main universe" > /etc/apt/sources.list

# needed for apt-add-repository
RUN apt-get install -y software-properties-common
## Add pgRouting launchpad repository ("stable" or "unstable")
RUN add-apt-repository ppa:georepublic/pgrouting-unstable
RUN apt-get -y update
RUN apt-get -y install ca-certificates rpl pwgen

#-------------Application Specific Stuff ----------------------------------------------------

# Next line a workaround for https://github.com/dotcloud/docker/issues/963
RUN apt-get install -y postgresql-9.3-postgis-2.1

# Start with supervisor
ADD postgres.conf /etc/supervisor/conf.d/postgres.conf

# Open port 5432 so linked containers can see them
EXPOSE 5432

# Run any additional tasks here that are too tedious to put in
# this dockerfile directly.
ADD setup.sh /setup.sh
RUN chmod 0755 /setup.sh
RUN /setup.sh

# instructions from: http://docs.pgrouting.org/2.0/en/doc/src/installation/index.html#ubuntu-debian
## Install pgRouting packages
RUN apt-get install -y postgresql-9.3-pgrouting

# We will run any commands in this when the container starts
ADD start-postgis.sh /start-postgis.sh
RUN chmod 0755 /start-postgis.sh

RUN apt-get install -y git

CMD /start-postgis.sh
