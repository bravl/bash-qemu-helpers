FROM ubuntu
MAINTAINER bram.vlerick@barco.com

RUN apt-get update && apt-get upgrade -y
RUN apt-get install -y git

RUN mkdir /root/.ssh/
ADD app_rsa /root/.ssh/id_rsa 

# Create known_hosts
RUN touch /root/.ssh/known_hosts
# Add bitbuckets key
RUN ssh-keyscan bitbucket.org >> /root/.ssh/known_hosts

RUN cd && git clone git@bitbucket.org:BramVlerick/clickshare-virt-env.git test_env
RUN sh /root/test_env/install-programs.sh
