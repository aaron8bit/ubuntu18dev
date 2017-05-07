FROM centos:7
MAINTAINER Aaron Albert <aaron8bit@gmail.com>

# Update CentOS
RUN yum updateinfo -y \
 && yum update -y \
 && yum install -y @base

# Install some basic tools
RUN yum install -y zsh \
                   tmux \
                   git \
                   sudo \
                   docker

# Add EPEL Repos
RUN rpm -Uvh http://download.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-9.noarch.rpm \
 && yum updateinfo

# Install Ansible
RUN yum install -y ansible

# Install Java 1.8
RUN yum install -y java-1.8.0-openjdk

# Install Maven 3.3.9
RUN cd /opt \
 && wget http://www-eu.apache.org/dist/maven/maven-3/3.3.9/binaries/apache-maven-3.3.9-bin.tar.gz \
 && wget http://www-eu.apache.org/dist/maven/maven-3/3.3.9/binaries/apache-maven-3.3.9-bin.tar.gz.sha1 \
 && export MVN_SHA1=$(cat apache-maven-3.3.9-bin.tar.gz.sha1) \
 && echo "${MVN_SHA1} apache-maven-3.3.9-bin.tar.gz" | sha1sum --check - \
 && tar xzf apache-maven-3.3.9-bin.tar.gz \
 && rm apache-maven-3.3.9-bin.tar.gz apache-maven-3.3.9-bin.tar.gz.sha1 \
 && ln -s apache-maven-3.3.9 maven \
 && echo 'export M2_HOME=/opt/maven' > /etc/profile.d/maven.sh \
 && echo 'PATH=${M2_HOME}/bin:${PATH}' >> /etc/profile.d/maven.sh

## Install pip
#RUN apt-get install -y python-pip python-dev build-essential && \
#  pip install --upgrade pip && \
#  pip install --upgrade virtualenv

# Use zsh while running commands
SHELL ["/bin/zsh", "-c"]

RUN useradd -u 1000 -g users -c 'Aaron Albert' -d /home/aja -s /bin/zsh -m aja && \
  echo 'aja ALL=NOPASSWD:ALL' >> /etc/sudoers

# Everything else should be non-root
USER aja

# Copy a bunch of installation material for later use
COPY install_ohmyzsh.sh aaron8bit.zsh-theme /tmp/

## the install exits with 1 but seems to work fine
RUN export TERM=xterm \
 && /tmp/install_ohmyzsh.sh \
 && cp /tmp/aaron8bit.zsh-theme ~/.oh-my-zsh/themes/ \
 && sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="aaron8bit"/g' ~/.zshrc \
 && sed -i 's/# CASE_SENSITIVE="true"/CASE_SENSITIVE="true"/g' ~/.zshrc \
 && sudo rm /tmp/install_ohmyzsh.sh

#COPY install_rvm.sh gradle-3.3-all.zip /tmp/
#
## Install rvm
#RUN gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
## why does ruby hate zsh? bash works fine...
#RUN cat /tmp/install_rvm.sh | bash -s stable --ruby-2.3.1 && \
#  echo "# Source rvm" >> ~/.zshrc && \
#  echo "source ~/.rvm/scripts/rvm" >> ~/.zshrc && \
#  sudo rm /tmp/install_rvm.sh
#
### Install and configure ruby-2.3.1
##RUN source ~/.rvm/scripts/rvm && \
##  rvm install ruby-2.3.1 && \
##  rvm --default use ruby-2.3.1 && \
##  gem install bundler pry rspec guard rubocop && \
##  rvm get stable --auto-dotfiles
##
### Install gradle
### This should check the download, md5 or something
##RUN unzip /tmp/gradle-3.3-all.zip -d ~/ && \
##  mv ~/gradle-3.3 ~/.gradle-3.3 && \
##  echo "# Gradle config" >> ~/.zshrc && \
##  echo "export GRADLE_HOME=~/.gradle-3.3" >> ~/.zshrc && \
##  echo "export PATH=$PATH:$GRADLE_HOME/bin" >> ~/.zshrc && \
##  sudo rm /tmp/gradle-3.3-all.zip
##
#
