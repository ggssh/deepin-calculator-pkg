FROM mamaship/qt5.15:v2

WORKDIR /workspace

RUN cat /etc/issue
RUN sed -i 's/deb.debian.org/mirrors.ustc.edu.cn/g' /etc/apt/sources.list && \
    sed -i 's/security.debian.org/mirrors.ustc.edu.cn/g' /etc/apt/sources.list && \
    sed -i 's/archive.ubuntu.com/mirrors.ustc.edu.cn/g' /etc/apt/sources.list && \
    apt update && \
    apt install -y cmake libqt5svg5 libqt5svg5-dev qttools5-dev qt5-default qtbase5-private-dev \
    libgsettings-qt-dev libgsettings-qt1 libgtest-dev qtmultimedia5-dev git librsvg2-dev libxi-dev \
    libxcb-util-dev libstartup-notification0-dev libcups2-dev &&\
    apt-get install -y --reinstall ca-certificates wget && \
    mkdir /usr/local/share/ca-certificates/cacert.org && \
    wget -P /usr/local/share/ca-certificates/cacert.org http://www.cacert.org/certs/root.crt http://www.cacert.org/certs/class3.crt && \
    update-ca-certificates && \
    git config --global http.sslCAinfo /etc/ssl/certs/ca-certificates.crt

# dtk
RUN qmake -set prefix /usr
RUN mkdir -p /workspace/dtk && cd /workspace/dtk &&\
    git clone https://hub.fastgit.xyz/linuxdeepin/dtkcommon.git && \
    cd dtkcommon && qmake && make && make install
RUN mkdir -p /workspace/dtk && cd /workspace/dtk &&\
    git clone https://hub.fastgit.xyz/linuxdeepin/dtkcore.git && \
    cd dtkcore && qmake && make -nomake tests && make install
RUN mkdir -p /workspace/dtk && cd /workspace/dtk &&\
    git clone https://hub.fastgit.xyz/linuxdeepin/dtkgui.git && \
    cd dtkgui && qmake && make -nomake tests && make install
RUN mkdir -p /workspace/dtk && cd /workspace/dtk &&\
    git clone https://hub.fastgit.xyz/linuxdeepin/dtkwidget.git &&\
    cd dtkwidget && qmake QMAKE_INCDIR=/usr/include/x86_64-linux-gnu/qt5 && make -nomake tests && make install

#RUN mkdir AppDir
#
#RUN wget https://github.com/AppImage/AppImageKit/releases/download/13/appimagetool-x86_64.AppImage -O appimagetool.AppImage && \
#    chmod a+x appimagetool.AppImage

RUN #cp /opt/Qt/5.15.2/gcc_64/lib/lib*.so /usr/lib

RUN #export LD_LIBRARY_PATH=/opt/Qt/5.15.2/gcc_64/lib:$LD_LIBRARY_PATH

#RUN git clone https://github.com/ggssh/deepin-calculator.git --depth=1 && \
#    apt install -y libdframeworkdbus-dev && cd deepin-calculator && mkdir build && cd build && cmake .. && \
#    make install DESTDIR=/workspace/AppDir
#RUN ./appimagetool.AppImage AppDir deepin-calculator.AppImage