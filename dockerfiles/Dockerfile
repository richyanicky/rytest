FROM mgymrek/advntr:latest


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

# Get set up to run
WORKDIR /tmp
ENTRYPOINT ["/usr/local/bin/fetch_and_run.sh"]

