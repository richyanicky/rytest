#FROM mgymrek/advntr:latest

#FROM python:2.7

# Base image
FROM ubuntu:18.04

# # Installation
 ENV DEBIAN_FRONTEND=noninteractive
 RUN apt-get update && apt-get upgrade -y && apt-get install -qqy \
     gcc \
         libbz2-dev \
             unzip \
                 wget \
                     awscli \
                         bzip2 \
python python-pip \
libz-dev \
curl

RUN wget https://github.com/mehrdadbakhtiari/adVNTR/archive/1.4.0.tar.gz
RUN tar -xzvf 1.4.0.tar.gz
WORKDIR adVNTR-1.4.0

# Install pip dependencies
  RUN pip install numpy==1.15.0
  RUN pip install joblib==0.14.1
  RUN pip install scipy==1.1.0
  RUN pip install scikit-learn==0.16.1
  RUN pip install Keras==2.3.1
  RUN pip install cython
  RUN pip install biopython==1.76
  RUN pip install pysam==0.9.1.4
  RUN pip install networkx==1.11
  RUN pip install tensorflow==1.13.2
#

# # Install advntr
  RUN python setup.py install

WORKDIR ..
#  #


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

                                     RUN apt-get install -qqy fuse
                                     RUN wget https://raw.githubusercontent.com/mitre/fusera/master/install.sh; chmod +x install.sh
                                     RUN ./install.sh
#
                                     RUN wget https://cseweb.ucsd.edu/~mbakhtia/adVNTR/vntr_data_recommended_loci_hg38.zip
                                     RUN unzip vntr_data_recommended_loci_hg38.zip
#
                                     ENV PATH="/opt/conda/bin/:${PATH}"
#
                                     ADD fetch_and_run.sh /usr/local/bin/fetch_and_run.sh
                                     WORKDIR /tmp
                                     #USER nobody
                                     ENTRYPOINT ["/usr/local/bin/fetch_and_run.sh"]




RUN apt-get -y install autoconf automake make gcc perl zlib1g-dev libbz2-dev liblzma-dev libcurl4-gnutls-dev libssl-dev
# Install samtools (needed to index reference fasta files)
RUN wget -O samtools-1.9.tar.bz2 https://github.com/samtools/samtools/releases/download/1.9/samtools-1.9.tar.bz2
RUN tar -xjf samtools-1.9.tar.bz2
WORKDIR samtools-1.9
RUN ./configure --without-curses && make && make install
#--without-curses && make && make install
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
#ADD dockerfiles/fetch_and_run.sh /usr/local/bin/fetch_and_run.sh
RUN advntr --help
# Get set up to run
WORKDIR /tmp
#ENTRYPOINT ["/usr/local/bin/fetch_and_run.sh"]

