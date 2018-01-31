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

# set proxy for user movidius
ENV http_proxy ${http_proxy}
ENV https_proxy ${https_proxy}

# set git proxy
RUN git config --global http.proxy $http_proxy || echo "No http proxy is set."
RUN git config --global https.proxy $https_proxy || echo "No https proxy is set."

# download ncsdk 
RUN git clone --progress https://github.com/movidius/ncsdk.git
RUN sudo chown movidius:movidius /home/movidius/ncsdk -R
RUN sudo chmod 755 /home/movidius/ncsdk; sync
WORKDIR /home/movidius/ncsdk

# install ncsdk
RUN sudo -E -H make install

# install opencv and dependencies to run make examples
RUN sudo -E -H pip3 install opencv-python \
                            opencv-contrib-python \
                            graphviz \
                            scikit-image

# set the pythonpath for user movidius
ENV PYTHONPATH "/usr/local/lib/python3.5/dist-packages:/usr/lib/python3/dist-packages:/opt/movidius/caffe/python"

RUN echo $PYTHONPATH

# build examples
RUN make examples

# clean the proxy settings
RUN git config --global --unset http.proxy
RUN git config --global --unset https.proxy

ENV http_proxy ""
ENV https_proxy ""
