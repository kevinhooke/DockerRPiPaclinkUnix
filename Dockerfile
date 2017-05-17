#
# Dockerfile to create an RPi Docker image based on the install instructions for Paclink-unix
# from here: http://bazaudi.com/plu/doku.php?id=plu:install_plu
# Kevin Hooke, May 2017
#
FROM resin/rpi-raspbian:latest
RUN apt-get update && \
    apt-get install build-essential autoconf automake libtool && \
    apt-get install postfix libdb-dev libglib2.0-0 zlib1g-dev libncurses5-dev libdb5.3-dev libgmime-2.6-dev && \
    apt-get install cvs && \
    useradd -m -s /bin/bash pi && \
    mkdir /home/pi/paclink-unix && \
    chown pi:pi /home/pi/paclink-unix && \
    mkdir -p /cvsroot/paclink-unix && \
    chown -R pi:pi /cvsroot

#USER pi

WORKDIR /cvsroot

RUN cvs -d:pserver:anonymous:@paclink-unix.cvs.sourceforge.net:/cvsroot/paclink-unix login && \
    cvs -z3 -d:pserver:anonymous@paclink-unix.cvs.sourceforge.net:/cvsroot/paclink-unix co -P paclink-unix

WORKDIR /cvsroot/paclink-unix

#force successful exit 0 even though autgen returns an error, this is fixed by the following steps
RUN cp /usr/share/automake-1.14/missing . && \
    ./autogen.sh --enable-postfix; exit 0

RUN automake --add-missing && \
    ./configure --enable-postfix && \
    make && \
    make install

