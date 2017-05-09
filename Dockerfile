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
 && curl -fsSLO http://www-eu.apache.org/dist/maven/maven-3/3.3.9/binaries/apache-maven-3.3.9-bin.tar.gz \
 && curl -fsSLO http://www-eu.apache.org/dist/maven/maven-3/3.3.9/binaries/apache-maven-3.3.9-bin.tar.gz.sha1 \
 && export MVN_SHA1=$(cat apache-maven-3.3.9-bin.tar.gz.sha1) \
 && echo "${MVN_SHA1} apache-maven-3.3.9-bin.tar.gz" | sha1sum --check - \
 && tar xzf apache-maven-3.3.9-bin.tar.gz \
 && rm apache-maven-3.3.9-bin.tar.gz apache-maven-3.3.9-bin.tar.gz.sha1 \
 && ln -s apache-maven-3.3.9 maven \
 && echo 'export M2_HOME=/opt/maven' > /etc/profile.d/maven.sh \
 && echo 'PATH=${PATH}:${M2_HOME}/bin' >> /etc/profile.d/maven.sh

# Install gradle
# Using a hard coded checksum because no download checksum available
RUN cd /opt \
 && curl -fsSLO https://services.gradle.org/distributions/gradle-3.5-all.zip \
 && echo "6c10209bd7ba0a2dd1191ad97e657c929d38f676 gradle-3.5-all.zip" | sha1sum --check - \
 && unzip -q gradle-3.5-all.zip \
 && rm gradle-3.5-all.zip \
 && ln -s gradle-3.5 gradle \
 && echo 'export GRADLE_HOME=/opt/gradle' > /etc/profile.d/gradle.sh \
 && echo 'export PATH=${PATH}:${GRADLE_HOME}/bin' >> /etc/profile.d/gradle.sh

# Install Vault
RUN cd /opt \
 && curl -fsSLO https://releases.hashicorp.com/terraform/0.7.2/vault_0.7.2_linux_amd64.zip \
 && curl -fsSLO https://releases.hashicorp.com/terraform/0.7.2/vault_0.7.2_SHA256SUMS \
 && grep linux_amd64 vault_0.7.2_SHA256SUMS | sha256sum --check - \
 && mkdir vault_0.7.2 \
 && unzip -q vault_0.7.2_linux_amd64.zip -d vault_0.7.2/ \
 && chmod -R 755 vault_0.7.2/ \
 && ln -s vault_0.7.2 vault \
 && rm vault_0.7.2_linux_amd64.zip vault_0.7.2_SHA256SUMS \
 && echo 'export VAULT_HOME=/opt/vault' > /etc/profile.d/vault.sh \
 && echo 'PATH=${PATH}:${VAULT_HOME}' >> /etc/profile.d/vault.sh

# Install Terraform
RUN cd /opt \
 && curl -fsSLO https://releases.hashicorp.com/terraform/0.9.4/terraform_0.9.4_linux_amd64.zip \
 && curl -fsSLO https://releases.hashicorp.com/terraform/0.9.4/terraform_0.9.4_SHA256SUMS \
 && grep linux_amd64 terraform_0.9.4_SHA256SUMS | sha256sum --check - \
 && mkdir terraform_0.9.4 \
 && unzip -q terraform_0.9.4_linux_amd64.zip -d terraform_0.9.4/ \
 && chmod -R 755 terraform_0.9.4/ \
 && ln -s terraform_0.9.4 terraform \
 && rm terraform_0.9.4_linux_amd64.zip terraform_0.9.4_SHA256SUMS \
 && echo 'export TERRAFORM_HOME=/opt/terraform' > /etc/profile.d/terraform.sh \
 && echo 'PATH=${PATH}:${TERRAFORM_HOME}' >> /etc/profile.d/terraform.sh

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

# Setup oh-my-zsh
# curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh -o install_ohmyzsh.sh
# chmod 755 install_ohmyzsh.sh
COPY install_ohmyzsh.sh aaron8bit.zsh-theme aaron8bit2.zsh-theme /tmp/

## the install exits with 1 but seems to work fine
RUN export TERM=xterm \
 && /tmp/install_ohmyzsh.sh \
 && cp /tmp/aaron8bit.zsh-theme ~/.oh-my-zsh/themes/ \
 && cp /tmp/aaron8bit2.zsh-theme ~/.oh-my-zsh/themes/ \
 && sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="aaron8bit2"/g' ~/.zshrc \
 && sed -i 's/# CASE_SENSITIVE="true"/CASE_SENSITIVE="true"/g' ~/.zshrc \
 && sudo rm /tmp/install_ohmyzsh.sh /tmp/aaron8bit.zsh-theme /tmp/aaron8bit2.zsh-theme

# Install rvm
# Why does the rvm install hate zsh? bash works fine...
# TODO: Make this a multi-user install and put source into /etc/profile.d/
RUN gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 \
 && curl -sSL https://get.rvm.io | bash -s stable --ruby=ruby-2.3 --gems=bundler,pry,rspec,guard,rubocop \
 && echo >> ~/.zshrc \
 && echo "# Source rvm" >> ~/.zshrc \
 && echo "source ~/.rvm/scripts/rvm" >> ~/.zshrc

