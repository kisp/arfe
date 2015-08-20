FROM davazp/quicksbcl

RUN rm -fr /tmp/install.lisp /tmp/quicklisp.lisp /tmp/sbcl /tmp/sbcl.tar.bz2

RUN ln -s /usr/local/bin/sbcl /usr/bin/sbcl

RUN apt-get update && apt-get -y upgrade && apt-get update

RUN apt-get -y install mr

RUN apt-get -y install man

RUN apt-get -y install git

RUN apt-get -y install graphviz

RUN apt-get -y install rlwrap

RUN apt-get -y install tree

RUN apt-get -y install screen

RUN apt-get -y install nvi

RUN apt-get -y install netcat

RUN apt-get -y install build-essential

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

RUN mr checkout

RUN cd /root/quicklisp/local-projects/arfe && git pull   && ./configure --prefix=/usr/local && make && make install && make clean
