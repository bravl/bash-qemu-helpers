FROM fedora:25
MAINTAINER bram.vlerick@barco.com

RUN dnf -y update
RUN dnf -y install git

RUN mkdir /root/.ssh/
ADD app_rsa /root/.ssh/id_rsa 

# Create known_hosts
RUN touch /root/.ssh/known_hosts
# Add bitbuckets key
RUN ssh-keyscan bitbucket.org >> /root/.ssh/known_hosts
RUN alalal

RUN cd && git clone git@bitbucket.org:BramVlerick/clickshare-virt-env.git test_env
RUN sh /root/test_env/install-programs.sh
