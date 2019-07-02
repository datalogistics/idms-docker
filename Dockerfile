FROM python:3.6-stretch

MAINTAINER Ezra Kissel <ezkissel@indiana.edu>

EXPOSE 9001/tcp

RUN apt-get update
RUN apt-get -y install sudo cmake gcc libaprutil1-dev libapr1-dev python-setuptools python-pip supervisor

RUN export uid=1000 gid=1000 && \
    mkdir -p /home/idms && \
    echo "idms:x:${uid}:${gid}:DLT-IDMS,,,:/home/idms:/bin/bash" >> /etc/passwd && \
    echo "idms:x:${uid}:" >> /etc/group && \
    echo "idms ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/idms && \
    chmod 0440 /etc/sudoers.d/idms && \
    chown ${uid}:${gid} -R /home/idms && \
    chown ${uid}:${gid} -R /opt

USER idms
ENV HOME /home/idms
WORKDIR $HOME

RUN git clone -b develop https://github.com/periscope-ps/unisrt
RUN git clone -b develop https://github.com/datalogistics/libdlt
RUN git clone -b develop https://github.com/datalogistics/IDMS.git
ADD build.sh .
RUN bash ./build.sh

RUN mkdir $HOME/.periscope

ADD .rtcache $HOME/.periscope/.rtcache/
RUN sudo chown idms $HOME/.periscope/.rtcache 
ADD .cache $HOME/.periscope/.cache/
RUN sudo chown idms $HOME/.periscope/.cache

ENV DEBUG INFO
ADD run.sh .
ADD idms.conf /etc/supervisor/conf.d/
CMD bash ./run.sh
