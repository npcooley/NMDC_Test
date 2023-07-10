FROM r-base:4.3.0

# a relatively lightweight docker container built on r-base that includes the 
# CWL runner for the express purposes of using CWL to install and test a SPAdes
# installation

# 'docker build --no-cache -t npcooley/nmdctest02:1.0'

# environment variables
ENV BLAST_VERSION "2.14.0"
ENV HMMER_VERSION "3.3.2"
ENV MCL_VERSION "14-137"
ENV BIOC_VERSION "3.17"
ENV SRA_VERSION "3.0.5"
ENV SPADES_VERSION "3.15.5"
ENV BBTOOLS_VERSION "39.01"
ENV export CLICOLOR=1
ENV export LSCOLORS=fxfxcxdxDxegedabagacad

# OS Dependencies
RUN apt-get update && \
   apt-get -y install nano \
    bash-completion \
    build-essential \
    software-properties-common \
    libgmp-dev \
    libcurl4-openssl-dev \
    libssl-dev \
    openmpi-common \
    libopenmpi-dev \
    libzmq3-dev \
    curl \
    libxml2-dev \
    git \
    libboost-all-dev \
    cmake \
    python3 \
    python3-pip \
    python3-distutils \
    wget \
    pigz \
    ca-certificates \
    libconfig-yaml-perl \
    libwww-perl \
    psmisc \
    samtools \
    bcftools \
    bowtie2 \
    flex \
    libfl-dev \
    default-jdk \
    cwltool && \
   apt-get -y autoclean && \
   rm -rf /var/lib/apt/lists/* && \
   update-alternatives --install /usr/bin/python python /usr/bin/python3 10
   
# R initial dependencies from CRAN
RUN install.r remotes \
   BiocManager \
   igraph \
   dendextend \
   ape \
   httr \
   stringr \
   phytools \
   phangorn \
   TreeDist \
   nlme \
   cluster \
   deSolve \
   rvest

# Ensure correct bioc version for DECIPHER and SynExtend
RUN Rscript -e "BiocManager::install(version = '$BIOC_VERSION') ; BiocManager::install(c('DECIPHER', 'SynExtend', 'rtracklayer', 'Rsamtools'), type = 'source')"

# EDirect
RUN sh -c "$(curl -fsSL ftp://ftp.ncbi.nlm.nih.gov/entrez/entrezdirect/install-edirect.sh)" && \
   cp -r /root/edirect/ /edirect/
ENV PATH=$PATH:/edirect

# install SPAdes from source, the provided tarball faults under debian
RUN wget http://cab.spbu.ru/files/release$SPADES_VERSION/SPAdes-$SPADES_VERSION.tar.gz && \
  tar -xzvf SPAdes-$SPADES_VERSION.tar.gz && \
  rm SPAdes-$SPADES_VERSION.tar.gz && \
  cd SPAdes-$SPADES_VERSION && \
  ./spades_compile.sh && \
  cd ..

ENV PATH=$PATH:/SPAdes-$SPADES_VERSION/bin

# install bbtools
RUN wget https://sourceforge.net/projects/bbmap/files/latest/download/BBMap_$BBTOOLS_VERSION.tar.gz && \
  tar -xzvf BBMap_$BBTOOLS_VERSION.tar.gz && \
  rm BBMap_$BBTOOLS_VERSION.tar.gz

# add the bbamp directory to the path
ENV PATH=$PATH:/bbmap

# BLAST
RUN wget https://ftp.ncbi.nlm.nih.gov/blast/executables/blast+/$BLAST_VERSION/ncbi-blast-$BLAST_VERSION+-x64-linux.tar.gz && \
  tar -zxvpf ncbi-blast-$BLAST_VERSION+-x64-linux.tar.gz && \
  rm ncbi-blast-$BLAST_VERSION+-x64-linux.tar.gz

ENV PATH=$PATH:/ncbi-blast-$BLAST_VERSION

# HMMER
RUN wget http://eddylab.org/software/hmmer/hmmer-$HMMER_VERSION.tar.gz && \
  tar -zxvf hmmer-$HMMER_VERSION.tar.gz && \
  cd hmmer-$HMMER_VERSION && \
  ./configure --prefix /hmmer-$HMMER_VERSION && \
  make && \
  make install && \
  cd .. && \
  rm hmmer-$HMMER_VERSION.tar.gz

ENV PATH=$PATH:/hmmer-$HMMER_VERSION/bin

# MCL
RUN mkdir installmcl && \
  cd installmcl && \
  wget https://raw.githubusercontent.com/micans/mcl/main/install-this-mcl.sh -o install-this-mcl && \
  chmod u+x install-this-mcl.sh && \
  ./install-this-mcl.sh && \
  cd ..

ENV PATH=$PATH:/root/local/bin

# prodigal
# prodigal adds itself to /usr/local/bin by default, this should be fine
RUN git clone https://github.com/hyattpd/Prodigal.git && \
  cd Prodigal && \
  make install && \
  cd ..

# pplacer
RUN wget https://github.com/matsen/pplacer/releases/download/v1.1.alpha19/pplacer-linux-v1.1.alpha19.zip && \
  unzip pplacer-linux-v1.1.alpha19.zip && \
  rm pplacer-linux-v1.1.alpha19.zip

ENV PATH=$PATH:/pplacer-Linux-v1.1.alpha19

# PIP dependencies
RUN pip3 install --break-system-packages biopython \
  plotly \
  pandas \
  numpy \
  reportlab \
  pysam \
  checkm-genome

# force an updated checkm
# RUN pip3 install checkm-genome --upgrade --no-deps

CMD ["bash"]
