FROM microsoft/azure-cli

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get -yqq update \
    && apt-get -yqq install incron \
    && rm -f /etc/incron.allow

ADD . /opt/src

RUN chmod 777 /opt/src/run.sh

VOLUME ["/var/files"]

ENTRYPOINT ["/opt/src/run.sh"]
CMD ["start"]