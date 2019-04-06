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
# I want to install only what is necessary to get mono-devel installed
RUN apt-get update && apt-get install -y \
	apt-transport-https \
	sudo
#RUN mkdir /usr/local/nvm 
#RUN chmod 777 -R /var/tmp
#RUN chmod 777 -R /usr/local/nvm
RUN adduser ${usr} sudo
RUN su -l ${usr} 
USER ${usr}
RUN echo ${pass} | sudo -S apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF \
	&& sleep 2 \
	&& echo "deb https://download.mono-project.com/repo/ubuntu stable-xenial main" | sudo tee /etc/apt/sources.list.d/mono-official-stable.list \
	&& sleep 2 \
	&& sudo apt-get update && sudo apt-get install -y \
	mono-devel
USER root
RUN apt-get update && apt-get install -y \
	build-essential \
	checkinstall \
	cmake \
	curl \
	git \
	htop \
	libssl-dev \
	libtinfo-dev \
	libunwind8 \
	locales \
	net-tools \
	python-dev \
	python3-dev \
	tzdata \
	wget \
	&& rm -rf /var/lib/apt/lists/*

ENV NVM_DIR /home/${usr}/.nvm
ENV NODE_VERSION 10.11.0
WORKDIR $NVM_DIR
RUN curl https://raw.githubusercontent.com/creationix/nvm/v0.33.11/install.sh | bash \
	&& . $NVM_DIR/nvm.sh \
	&& nvm install $NODE_VERSION \
	&& nvm alias default $NODE_VERSION \
	&& nvm use default
ENV NODE_PATH $NVM_DIR/versions/node/v$NODE_VERSION/lib/node_modules
ENV PATH      $NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH
WORKDIR /home/${usr}
RUN git clone https://github.com/vim/vim.git
WORKDIR /home/${usr}/vim
RUN ./configure --enable-python3interp=yes && make && make install \
	&& make VIMRUNTIMEDIR=/usr/local/share/vim/vim81 \
	&& echo ${usrpass} | sudo -S checkinstall
WORKDIR /home/${usr}
USER root
RUN echo "LANG=en_US.UTF-8" >> /etc/environment
RUN locale-gen en_US.UTF-8
ENV TZ 'US/Central'
RUN echo $TZ > /etc/timezone && \
    rm /etc/localtime && \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
    dpkg-reconfigure -f noninteractive tzdata
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | \
	apt-key add - && \
 	echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
USER ${usr}
RUN git clone https://github.com/jimeh/tmux-themepack.git ~/.tmux-themepack
RUN git clone https://github.com/tmux-plugins/tpm /home/${usr}/.tmux/plugins/tpm
RUN echo 'set -g @plugin "tmux-plugins/tpm"' >> /home/${usr}/.tmux.conf
RUN echo 'set -g @plugin "tmux-plugins/tmux-sensible"' >> /home/${usr}/.tmux.conf
RUN echo 'set -g @plugin "jimeh/tmux-themepack"' >> /home/${usr}/.tmux.conf
RUN echo 'set -g @plugin "tmux-plugins/tmux-sidebar"' >> /home/${usr}/.tmux.conf
RUN echo 'run "/home/${usr}/.tmux/plugins/tpm/tpm"' >> /home/${usr}/.tmux.conf
RUN wget -O /home/${usr}/.vimrc https://github.com/helzgate/vimrc/blob/master/.vimrc?raw=true
RUN git clone https://github.com/VundleVim/Vundle.vim.git /home/${usr}/.vim/bundle/Vundle.vim
WORKDIR /home/${usr}
RUN curl -sS https://dot.net/v1/dotnet-install.sh | bash -s -- -c Current
RUN echo ${pass} | sudo -S chmod 777 -R /home/${usr}/.nvm \
	&& sudo apt-get update && sudo apt-get install -y \
	yarn \
	tmux \
	&& sudo ln -s /home/${usr}/.dotnet/dotnet /usr/local/bin/
RUN npm install -g typescript \
	&& echo 'export VIMRUNTIME="/usr/local/share/vim/vim81"' >> ~/.bashrc \
	&& echo 'export LC_CTYPE="en_US.UTF-8"' >> ~/.bashrc \
	&& echo 'export LC_ALL="en_US.UTF-8"' >> ~/.bashrc \
	&& touch ~/.ackrc \
	&& echo "--type-add=ts:ext:ts" >> ~/.ackrc
WORKDIR /home/${usr}/.vim/bundle/YouCompleteMe
RUN [ "/bin/bash", "-c", "vim -T dumb -n -i NONE -es -S <(echo -e 'silent! PluginInstall')" ] \
	&& python3 ./install.py --cs-completer --js-completer
#RUN vim -T dumb -n -i NONE -es -S <(echo -e "silent! PluginInstall")
USER root
EXPOSE 22 3001
