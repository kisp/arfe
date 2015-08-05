FROM davazp/quicksbcl

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

ADD docker/.screenrc .screenrc
ADD docker/.mrconfig .mrconfig
ADD docker/.gitconfig .gitconfig

RUN mr checkout

RUN cd /root/quicklisp/local-projects/arfe && git pull   && ./configure --prefix=/usr/local && make && make install && make clean

ENV CDPATH /root/quicklisp/local-projects