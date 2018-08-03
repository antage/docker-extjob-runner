FROM golang:1-stretch

ENV GOPATH /tmp/build/extjob-runner
RUN mkdir /tmp/build \
    && cd /tmp/build \
    && git clone git://github.com/antage/extjob-runner.git \
    && cd extjob-runner \
    && git submodule init \
    && git submodule update \
    && cd src/cmd \
    && go build -v -o ../../bin/extjob-runner .

FROM debian:stable

ENV DEBIAN_FRONTEND noninteractive

RUN \
    apt-get -y -q update \
    && echo "deb http://www.deb-multimedia.org stretch main non-free" > /etc/apt/sources.list.d/deb-multimedia.list \
    && apt-get -y -q update \
    && apt-get -y -q --allow-unauthenticated --no-install-recommends install deb-multimedia-keyring \
    && apt-get -y -q update \
    && apt-get -y -q --no-install-recommends install \
        ffmpeg \
        gosu \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && rm /var/log/dpkg.log

COPY --from=0 /tmp/build/extjob-runner/bin/extjob-runner /usr/local/bin/extjob-runner
COPY docker-entrypoint.sh /

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["extjob-runner"]
