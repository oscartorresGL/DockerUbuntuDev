# DockerUbuntuDev
Docker Dockerfile for Ubuntu 16.0.4 development environment

* Linux .Net/Javascript development environment ready to go
* Uses VIM with development plugins installed
* Tmux
* SSH enabled

## Setup (see below if you want your own username/password)
1. `git clone https://github.com/helzgate/DockerUbuntuDev`
2. `cd DockerUbuntuDev`
3. `docker build -t somename .`  ( <-- notice the period at the end)
4. `docker run -d -P --name othername somename:latest` 
5. `docker port othername` ( this gives you the port that 22 is running as on your localhost)
> Note: if your host machine that Docker is installed on is Mac you need to add the following to your .bashrc  or bash_profile first then reopen terminal
6. (if on a MAC) `export LC_CTYPE=en_US.UTF-8`
7. (if on a MAC) `export LC_ALL=en_US.UTF-8`

## Run
1. `ssh happy@localhost -p <the port shown from step 5 above>`
2. password is g0lUcky

## Custom Setup
1. `docker build --build-arg usrname=yourname --build-arg usrpass=yourpass -t somename .`  (don't forget the period on the end)

