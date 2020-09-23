#FROM mgymrek/advntr:latest

#FROM python:2.7

# Base image
FROM ubuntu:18.04

# Maintainer
# MAINTAINER Mehrdad Bakhtiari <mbakhtiari@ucsd.edu>
#
# # METADATA
 LABEL base_image="ubuntu:16.04"
 LABEL version="2"
 LABEL software="advntr"
 LABEL software.version="1.4.0"
 LABEL about.summary="adVNTR genotypes Variable Number Tandem Repeats from mapped sequencing reads"
 LABEL about.home="https://github.com/mehrdadbakhtiari/adVNTR/"
 LABEL about.documentation="https://github.com/mehrdadbakhtiari/adVNTR/blob/master/README.md"
 LABEL about.license_file="https://github.com/mehrdadbakhtiari/adVNTR/blob/master/LICENSE"
 LABEL about.license="BSD3-clause"
 LABEL extra.identifiers.biotools="adVNTR"
 LABEL about.tags="Genomics"
#
# # Installation
 ENV DEBIAN_FRONTEND=noninteractive
 RUN apt-get update && apt-get upgrade -y && apt-get install -qqy \
     gcc \
         libbz2-dev \
             unzip \
                 wget \
                     awscli \
                         bzip2
#
#                         # Install conda and give write permissions to conda folder
                         RUN echo 'export PATH=/opt/conda/bin:$PATH' > /etc/profile.d/conda.sh && \
                             wget --quiet https://repo.continuum.io/miniconda/Miniconda2-4.0.5-Linux-x86_64.sh -O ~/miniconda.sh && \
                                 /bin/bash ~/miniconda.sh -b -p /opt/conda && \
                                     rm ~/miniconda.sh && chmod 777 -R /opt/conda/
#
                                     ENV PATH=$PATH:/opt/conda/bin

                                     RUN conda config --add channels r
                                     RUN conda config --add channels bioconda

                                     RUN conda config --set ssl_verify no
                                     RUN conda upgrade conda

                                     RUN conda install advntr

                                     RUN apt-get install -qqy fuse
                                     RUN wget https://raw.githubusercontent.com/mitre/fusera/master/install.sh; chmod +x install.sh
                                     RUN ./install.sh
#
                                     RUN wget https://cseweb.ucsd.edu/~mbakhtia/adVNTR/vntr_data_recommended_loci_hg38.zip
                                     RUN unzip vntr_data_recommended_loci_hg38.zip
#
                                     ENV PATH="/opt/conda/bin/:${PATH}"
#
                                     #ADD fetch_and_run.sh /usr/local/bin/fetch_and_run.sh
                                     #WORKDIR /tmp
                                     #USER nobody
                                     #ENTRYPOINT ["/usr/local/bin/fetch_and_run.sh"]
#
#RUN pip install Cython numpy scipy==1.2.2 biopython==1.76 pysam networkx joblib scikit-learn  keras==2.3.1 tensorflow

#RUN git clone https://github.com/mehrdadbakhtiari/adVNTR
#WORKDIR adVNTR
#RUN make
#RUN make install
#RUN python setup.py install
#WORKDIR ..


RUN apt-get update && apt-get install -qqy \
    awscli \
    build-essential \
    git \
    libbz2-dev \
    liblzma-dev \
    make \
    pkg-config \
    python \
    python3 \
    python3-dev \
    python3-pip \
    wget \
    unzip \
    zlib1g-dev

#RUN git clone https://github.com/mehrdadbakhtiari/adVNTR
#WORKDIR adVNTR
#RUN make
#RUN make install
#RUN python setup.py install
#WORKDIR ..

# Install samtools (needed to index reference fasta files)
RUN wget -O samtools-1.9.tar.bz2 https://github.com/samtools/samtools/releases/download/1.9/samtools-1.9.tar.bz2
RUN tar -xjf samtools-1.9.tar.bz2
WORKDIR samtools-1.9
RUN ./configure --without-curses && make && make install
WORKDIR ..

# Install bedtools (needed for DumpSTR)
RUN wget -O bedtools-2.27.1.tar.gz https://github.com/arq5x/bedtools2/releases/download/v2.27.1/bedtools-2.27.1.tar.gz
RUN tar -xzvf bedtools-2.27.1.tar.gz
WORKDIR bedtools2
RUN make && make install
WORKDIR ..


RUN apt-get update -y && \
  apt-get install python3-pip -y && \
  pip3 install --no-cache-dir --upgrade pip

RUN pip3 install Crypto
# Add the fetch_and_run.sh script
ADD dockerfiles/fetch_and_run.sh /usr/local/bin/fetch_and_run.sh
RUN which advntr
# Get set up to run
WORKDIR /tmp
ENTRYPOINT ["/usr/local/bin/fetch_and_run.sh"]

