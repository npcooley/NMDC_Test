FROM ubuntu:focal

# SPAdes segfaults in debian for some reason, though not when installed
# via CONDA ... 
# FROM r-base:4.3.0

# a relatively lightweight docker container built on r-base that includes the 
# CWL runner for the express purposes of using CWL to install and test a SPAdes
# installation

# 'docker build --no-cache -t npcooley/synextend:nmdctest02:1.0'

# OS Dependencies
RUN apt-get update && \
   apt-get --no-install-recommends -y install nano \
    python3 \
    python3-pip \
    python3-distutils \
    wget \
    pigz \
    ca-certificates \
    cwltool && \
   apt-get -y autoclean && \
   rm -rf /var/lib/apt/lists/* && \
   update-alternatives --install /usr/bin/python python /usr/bin/python3 10
   

CMD ["sh"]
