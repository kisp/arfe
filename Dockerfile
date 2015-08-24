FROM debian:latest

# Install dependencies from Debian repositories
RUN apt-get update && apt-get install -y make wget bzip2

# Install SBCL from the tarball binaries.
RUN wget http://prdownloads.sourceforge.net/sbcl/sbcl-1.2.9-x86-64-linux-binary.tar.bz2 \
    -O /tmp/sbcl.tar.bz2 && \
    mkdir /tmp/sbcl && \
    tar jxvf /tmp/sbcl.tar.bz2 --strip-components=1 -C /tmp/sbcl/ && \
    cd /tmp/sbcl && \
    sh install.sh && \
    cd / && \
    rm -rf /tmp/sbcl*

ENV HOME /root

WORKDIR /tmp/
RUN wget http://beta.quicklisp.org/quicklisp.lisp
ADD docker/install-quicklisp.lisp /tmp/install.lisp

RUN sbcl --non-interactive --load install.lisp

WORKDIR /root

RUN rm /tmp/install.lisp /tmp/quicklisp.lisp

RUN ln -s /usr/local/bin/sbcl /usr/bin/sbcl

RUN apt-get -y install mr man git graphviz rlwrap tree screen nvi netcat build-essential

RUN wget http://pallini.di.uniroma1.it/nauty25r9.tar.gz
RUN tar xzf nauty25r9.tar.gz
RUN cd nauty25r9 && ./configure && make # && make install
RUN cd nauty25r9 && rm runalltests install-sh config*
RUN cd nauty25r9 && find -type f -executable | xargs -I% cp -v % /usr/local/bin/%
RUN rm -rf nauty25r9.tar.gz nauty25r9

ADD docker/.screenrc .screenrc
ADD docker/.mrconfig .mrconfig
ADD docker/.gitconfig .gitconfig
ADD docker/.arferc .arferc

ENV CDPATH /root/quicklisp/local-projects
ENV SHELL /bin/bash
ENV SBCL_HOME /usr/local/lib/sbcl

RUN mr checkout

RUN cd /root/quicklisp/local-projects/arfe && git pull && \
    ./configure --prefix=/usr/local && make && make install && make clean

# cleanup package manager
RUN apt-get autoclean && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
