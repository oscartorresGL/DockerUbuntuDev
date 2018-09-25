FROM rastasheep/ubuntu-sshd:16.04
ARG usrpass=g0lUcky 
ARG usrname=happy
ENV pass=$usrpass
ENV usr=$usrname
# Replace shell with bash so we can source files
RUN rm /bin/sh && ln -s /bin/bash /bin/sh
RUN chmod 777 -R /usr/local/share
RUN chmod 777 -R /usr/local/bin
RUN useradd ${usr}
RUN mkhomedir_helper ${usr}
RUN echo ${usr}:${usrpass} | chpasswd 

RUN apt-get update \
	&& apt-get install -y sudo \
	curl \
	git \
	build-essential \
	cmake \
	libtinfo-dev \
	python-dev \
	python3-dev \
	libssl-dev \
	checkinstall \
	locales \
	htop \
	net-tools \
	wget 
RUN mkdir /usr/local/nvm 
RUN chmod 777 -R /var/tmp
RUN chmod 777 -R /usr/local/nvm
RUN adduser ${usr} sudo
RUN su -l ${usr} 
USER ${usr}
ENV NVM_DIR /usr/local/nvm
ENV NODE_VERSION 8.12.0
WORKDIR $NVM_DIR
RUN curl https://raw.githubusercontent.com/creationix/nvm/v0.33.11/install.sh | bash \
	&& . $NVM_DIR/nvm.sh \
	&& nvm install $NODE_VERSION \
	&& nvm alias default $NODE_VERSION \
	&& nvm use default
ENV NODE_PATH $NVM_DIR/versions/node/v$NODE_VERSION/lib/node_modules
ENV PATH      $NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH


WORKDIR /home/${usr}
RUN pwd
RUN git clone https://github.com/vim/vim.git
WORKDIR /home/${usr}/vim
RUN pwd
RUN ./configure --enable-python3interp=yes && make && make install 
RUN make VIMRUNTIMEDIR=/usr/local/share/vim/vim81
RUN checkinstall
WORKDIR /home/${usr}
RUN echo "LANG=en_US.UTF-8" >> /etc/environment
RUN echo ${pass} | sudo locale-gen en_US.UTF-8

RUN echo ${pass} | sudo apt-get update && apt-get -y install tmux
RUN git clone https://github.com/jimeh/tmux-themepack.git ~/.tmux-themepack
RUN git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
RUN echo 'set -g @plugin "tmux-plugins/tpm"' >> ~/.tmux.conf
RUN echo 'set -g @plugin "tmux-plugins/tmux-sensible"' >> ~/.tmux.conf
RUN echo 'set -g @plugin "jimeh/tmux-themepack"' >> ~/.tmux.conf
RUN echo 'set -g @plugin "tmux-plugins/tmux-sidebar"' >> ~/.tmux.conf
RUN echo 'run "~/.tmux/plugins/tpm/tpm"' >> ~/.tmux.conf
RUN wget -O ~/.vimrc https://github.com/helzgate/vimrc/blob/master/.vimrc?raw=true
RUN git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
USER root
EXPOSE 22
