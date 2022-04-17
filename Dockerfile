FROM ubuntu:14.04 
RUN apt-get update -qq --fix-missing; \ 
       apt-get install -qq -y wget unzip; 

RUN mkdir /app
WORKDIR app
RUN wget --no-check-certificate -q -O bowtie.zip https://sourceforge.net/projects/bowtie-bio/files/bowtie/1.3.0/bowtie-1.3.0-linux-x86_64.zip/download
RUN ls && unzip bowtie.zip

ENV PATH $PATH:/app/bowtie-1.3.0-linux-x86_64/
WORKDIR /app/bowtie-1.3.0-linux-x86_64/
CMD ["bowtie"]

