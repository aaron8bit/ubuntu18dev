FROM ubuntu:18.04
MAINTAINER Aaron Albert <aaron8bit@gmail.com>

ARG TERRAFORM_VER
ARG TERRAFORM_DST
ARG VAULT_VER
ARG VAULT_DST
ARG KOPS_VER
ARG KOPS_DST
ARG AWS_VER
ARG AWS_DST

# Update CentOS
RUN apt-get update \
 && apt-get upgrade -y

# Install some basic tools
RUN apt-get update \
 && apt-get install -y \
  zsh \
  tmux \
  git \
  sudo \
  docker \
  tree \
  ack \
  curl \
  vim \
  wget \
  groff

## Install python and pip
RUN apt-get install -y python3 python3-pip \
 && pip3 install --upgrade pip
 #&& pip install --upgrade virtualenv

# Install ansible
RUN apt-get install -y ansible jq

# Install ruby
RUN apt-get install -y ruby rubygems

# Copy install files
COPY ${VAULT_DST} ${TERRAFORM_DST} ${KOPS_DST} ${AWS_DST} /tmp/
#COPY vault_1.1.3_linux_amd64.zip terraform_0.12.3_linux_amd64.zip kops-linux-amd64 /tmp/

# Install vault
RUN cd /opt \
 && mkdir vault_${VAULT_VER} \
 && unzip -q /tmp/${VAULT_DST} -d vault_${VAULT_VER}/ \
 && rm /tmp/${VAULT_DST} \
 && chmod -R 755 vault_${VAULT_VER}/ \
 && ln -s vault_${VAULT_VER} vault \
 && echo 'export VAULT_HOME=/opt/vault' > /etc/profile.d/vault.sh \
 && echo 'PATH=${PATH}:${VAULT_HOME}' >> /etc/profile.d/vault.sh

# Install terraform
RUN cd /opt \
 && mkdir terraform_${TERRAFORM_VER} \
 && unzip -q /tmp/${TERRAFORM_DST} -d terraform_${TERRAFORM_VER}/ \
 && rm /tmp/${TERRAFORM_DST} \
 && chmod -R 755 terraform_${TERRAFORM_VER}/ \
 && ln -s terraform_${TERRAFORM_VER} terraform \
 && echo 'export TERRAFORM_HOME=/opt/terraform' > /etc/profile.d/terraform.sh \
 && echo 'PATH=${PATH}:${TERRAFORM_HOME}' >> /etc/profile.d/terraform.sh

# Install kops
RUN cp /tmp/${KOPS_DST} /usr/local/bin/kops \
 && chmod 755 /usr/local/bin/kops

# Install aws cli
RUN cd /opt \
 && mkdir aws \
 && unzip /tmp/${AWS_DST} \
 && /opt/aws/install

# Use zsh while running commands
SHELL ["/bin/zsh", "-c"]

RUN useradd -u 1000 -g users -c 'Aaron Albert' -d /home/aaron -s /bin/zsh -m aaron \
 && echo 'aaron ALL=NOPASSWD:ALL' >> /etc/sudoers

# Everything else should be non-root
USER aaron

# Setup oh-my-zsh
COPY aaron8bit.zsh-theme aaron8bit2.zsh-theme /tmp/
# the install exits with 1 but seems to work fine
RUN sudo apt-get install -y powerline fonts-powerline
RUN git clone https://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh \
 && cp ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc \
 && cp /tmp/aaron8bit.zsh-theme ~/.oh-my-zsh/themes/ \
 && cp /tmp/aaron8bit2.zsh-theme ~/.oh-my-zsh/themes/ \
 && sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="aaron8bit2"/g' ~/.zshrc \
 && sed -i 's/# CASE_SENSITIVE="true"/CASE_SENSITIVE="true"/g' ~/.zshrc

# Install AWS CLI tools
#RUN pip3 install awscli --upgrade --user \
# && echo "# User specific environment and startup programs" >> ~/.zshrc \
# && echo "export PATH=\${PATH}:\${HOME}/.local/bin:\${HOME}/bin" >> ~/.zshrc \
# && echo "export PATH" >> ~/.zshrc

# Install Google SDK
#RUN curl -sSL https://sdk.cloud.google.com | bash \
# && echo "export PATH=\${PATH}:\${HOME}/google-cloud-sdk/bin" >> ~/.zshrc \
# && echo "export PATH" >> ~/.zshrc

# Install pulumi
#RUN curl -fsSL https://get.pulumi.com | sh \
# && echo "export PATH=\${PATH}:\${HOME}/.pulumi/bin" >> ~/.zshrc \
# && echo "export PATH" >> ~/.zshrc

# I hate having this layer last but it runs as non-root and seems to break a lot
#
# Install rvm
# Why does the rvm install hate zsh? bash works fine...
# TODO: Make this a multi-user install and put source into /etc/profile.d/
# 20190103: Remove ruby because I'm not using it and it takes forever to build
# RUN gpg --keyserver hkp://keys.gnupg.net \
#         --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB \
#  && curl -sSL https://get.rvm.io | bash -s stable
# RUN bash -l -c "rvm install ruby-2.3" \
#  && bash -l -c "rvm --default use ruby-2.3"
# RUN bash -l -c "gem install rake bundler pry rspec guard rubocop"

# THIS USED TO WORK BUT RVM HAS A BUG
# && curl -sSL https://get.rvm.io | bash -s stable --ruby=ruby-2.3 --gems=bundler,pry,rspec,guard,rubocop

#RUN echo >> ~/.zshrc \
# && echo "# Source rvm" >> ~/.zshrc \
# && echo "source ~/.rvm/scripts/rvm" >> ~/.zshrc

