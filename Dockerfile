FROM ubuntu:16.04

ARG http_proxy

ARG https_proxy

ENV http_proxy ${http_proxy}

ENV https_proxy ${https_proxy}

RUN echo $https_proxy

RUN echo $http_proxy

# Uncomment the two lines below if you wish to use an Ubuntu mirror repository
# that is closer to you (and hence faster). The 'sources.list' file inside the
# 'tools/docker/' folder is set to use one of Ubuntu's official mirror in Taiwan.
# You should update this file based on your own location. For a list of official
# Ubuntu mirror repositories, check out: https://launchpad.net/ubuntu/+archivemirrors
#COPY sources.list /etc/apt
#RUN rm /var/lib/apt/lists/* -vf
#RUN rm /var/lib/apt/lists/partial/* -vf

RUN apt-get clean all \
    && apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y \
      build-essential \
      git \
      lsb-release \
      sudo \
      udev \
      usbutils \
      wget \
      vim 


RUN useradd -c "Movidius User" -m movidius
COPY 10-installer /etc/sudoers.d/
RUN mkdir -p /etc/udev/rules.d/
USER movidius
WORKDIR /home/movidius

ENV http_proxy ${http_proxy}
ENV https_proxy ${https_proxy}

RUN git config --global https.proxy $http_proxy
RUN git config --global https.proxy $https_proxy

RUN git clone --progress https://github.com/movidius/ncsdk.git
#COPY ncsdk /home/movidius/ncsdk
RUN sudo chown movidius:movidius /home/movidius/ncsdk -R
RUN sudo chmod 775 /home/movidius/ncsdk
WORKDIR /home/movidius/ncsdk

RUN sudo -E -H make install

RUN sudo -E -H pip3 install opencv-python \
                            opencv-contrib-python \
                            graphviz \
                            scikit-image

ENV PYTHONPATH "/usr/local/lib/python3.5/dist-packages:/usr/lib/python3/dist-packages:/opt/movidius/caffe/python"

RUN echo $PYTHONPATH

RUN make examples

ENV http_proxy ""
ENV https_proxy ""
