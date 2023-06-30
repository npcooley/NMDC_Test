FROM r-base:4.3.0

ENV BIOC_VERSION "3.17"

# OS Dependencies
RUN apt-get update && \
   apt-get -y install build-essential \
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
    abyss \
    libboost-all-dev \
    cmake \
    python3 \
    python3-pip \
    samtools \
    bcftools \
    flex \
    libfl-dev \
    x11-apps \
    xvfb xauth xfonts-base \
    libcairo2-dev \
    libxt-dev \
    libx11-dev \
    libgtk2.0-dev \
    bioperl \
    libconfig-yaml-perl \
    libwww-perl \
    psmisc \
    mash \
    cwltool && \
   apt-get clean && \
   rm -rf /var/lib/apt/lists/*
   
# PIP dependencies
RUN pip3 install --break-system-packages biopython \
   plotly \
   pandas \
   numpy \
   reportlab \
   checkm-genome \
   pysam

# this is not necessarily the right choice for a container that gets passed around the OSG
# but this can be stashed and sent along as needed
# this command will tell checkM where it's DB / DBs are located:
# checkm data setRoot <checkm_data_dir>
# checkm isn't necessarily the simplest plug and play tool, see github:
# https://github.com/Ecogenomics/CheckM
# RUN wget https://data.ace.uq.edu.au/public/CheckM_databases/checkm_data_2015_01_16.tar.gz

# CONDA install
ENV CONDA_DIR /opt/conda
RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh && \
   /bin/bash ~/miniconda.sh -b -p /opt/conda
ENV PATH=$CONDA_DIR/bin:$PATH

# CONDA dependencies
# ncurses installed explicitly because it doesn't seem to behave correctly as a dependency
# https://stackoverflow.com/questions/72103046/libtinfo-so-6-no-version-information-available-message-using-conda-environment
RUN conda config --add channels defaults && \
   conda config --add channels bioconda && \
   conda config --add channels conda-forge && \
   conda update -n base -c defaults conda && \
   conda install -c bioconda fastp && \
   conda install -c conda-forge -c bioconda spades=3.15.5 && \
   conda install -c bioconda metabat2 && \
   conda install -c bioconda fastqc

# R initial dependencies from CRAN
RUN install.r remotes \
   BiocManager \
   httr \
   jsonlite \
   rvest


# Ensure correct bioc version for DECIPHER and SynExtend
RUN Rscript -e "BiocManager::install(version = '$BIOC_VERSION') ; BiocManager::install(c('DECIPHER', 'SynExtend'), type = 'source')"

WORKDIR /

CMD ["sh"]
