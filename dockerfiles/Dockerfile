FROM mgymrek/advntr:latest


RUN apt-get install python3-pip

RUN pip3 install --upgrade pip
RUN pip3 install Crypto
# Add the fetch_and_run.sh script
ADD dockerfiles/fetch_and_run.sh /usr/local/bin/fetch_and_run.sh

# Get set up to run
WORKDIR /tmp
ENTRYPOINT ["/usr/local/bin/fetch_and_run.sh"]
