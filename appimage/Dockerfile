FROM msojocs/ubuntu16-qt5:15.2

LABEL author="ggssh"
LABEL email="me@ggssh.cn"

WORKDIR /workspace

RUN apt update && apt upgrade
RUN apt install -y qtbase5-dev libkf5codecs-dev libicu-dev libfuse2 gcc g++ python3 git

RUN mkdir -p /workplace/other && cd /workplace/other &&\
    git clone https://hub.fastgit.xyz/sailfishos/qtmpris.git &&\
    cd qtmpris && qmake && make && make install &&\
    mkdir -p /workplace/other && cd /workplace/other &&\
    git clone https://hub.fastgit.xyz/linuxdeepin/udisks2-qt5.git &&\
    cd udisks2-qt5 && qmake QMAKE_CXXFLAGS=-fno-sized-deallocation QMAKE_CFLAGS=-fno-sized-deallocation && \
    make && make install &&\
    mkdir -p /workplace/other && cd /workplace/other &&\
    git clone https://hub.fastgit.xyz/sailfishos/qtdbusextended.git &&\
    cd qtdbusextended && qmake && make && make install && \
    mkdir -p /workplace/other && cd /workplace/other &&\
    git clone https://hub.fastgit.xyz/linuxdeepin/dde-qt-dbus-factory.git &&\
    cd dde-qt-dbus-factory && qmake && make && make install &&\
    mkdir -p /workplace/other && cd /workplace/other &&\
    git clone https://hub.fastgit.xyz/ubports/gsettings-qt.git &&\
    cd gsettings-qt && qmake && make && make install
