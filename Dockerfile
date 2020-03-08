FROM ubuntu:18.04

MAINTAINER Yuki Watanabe <watanabe@future-needs.com>

ENV PATH=$PATH:/usr/local/go/bin
ENV GOPATH=$HOME/go
ENV PATH=$PATH:$GOPATH/bin
ARG GOLANG_VERSION=${GOLANG_VERSION:-1.13.8}

RUN set -xe \
        && apt-get update && apt-get install -y wget git

RUN wget https://dl.google.com/go/go${GOLANG_VERSION}.linux-amd64.tar.gz
RUN tar -C /usr/local -xzf go${GOLANG_VERSION}.linux-amd64.tar.gz

# install glide, the package dependency manager
RUN go get -u github.com/Masterminds/glide
# download the code
RUN git clone https://github.com/FactomProject/factomd $GOPATH/src/github.com/FactomProject/factomd
RUN git clone https://github.com/FactomProject/factom-cli $GOPATH/src/github.com/FactomProject/factom-cli
RUN git clone https://github.com/FactomProject/factom-walletd $GOPATH/src/github.com/FactomProject/factom-walletd
RUN git clone https://github.com/FactomProject/enterprise-wallet $GOPATH/src/github.com/FactomProject/enterprise-wallet

# get the dependencies and build each factom program
RUN glide cc
RUN cd $GOPATH/src/github.com/FactomProject/factomd && glide install && go install -v -ldflags "-X github.com/FactomProject/factomd/engine.Build=`git rev-parse HEAD` -X github.com/FactomProject/factomd/engine.FactomdVersion=`cat VERSION`"
RUN cd $GOPATH/src/github.com/FactomProject/factom-cli && glide install && go install -v
RUN cd $GOPATH/src/github.com/FactomProject/factom-walletd && glide install && go install -v
RUN cd $GOPATH/src/github.com/FactomProject/enterprise-wallet && glide install && go install -v

# Setup the cache directory
# RUN mkdir -p /root/.factom/m2

# COPY factomd.conf /root/.factom/m2/factomd.conf

ENTRYPOINT ["/go/bin/factomd","-sim_stdin=false"]

EXPOSE 8088 8090 8108 8109 8110
