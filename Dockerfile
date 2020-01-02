FROM ubuntu:18.04
MAINTAINER Aaron Albert <aaron8bit@gmail.com>

# Update CentOS
RUN apt-get update \
 && apt-get upgrade -y

# Install some basic tools
RUN apt-get install -y \
  zsh \
  tmux \
  git \
  sudo \
  docker \
  tree \
  ack \
  curl

# Install Ansible
RUN apt-get install -y ansible jq

# Install Ruby
RUN apt-get install -y ruby rubygems

# Copy install files
COPY vault_1.0.1_linux_amd64.zip terraform_0.11.11_linux_amd64.zip kops-linux-amd64 /tmp/

## Install Maven 3.3.9
#RUN cd /opt \
# && tar xzf /tmp/apache-maven-3.3.9-bin.tar.gz \
# && rm /tmp/apache-maven-3.3.9-bin.tar.gz \
# && ln -s apache-maven-3.3.9 maven \
# && echo 'export M2_HOME=/opt/maven' > /etc/profile.d/maven.sh \
# && echo 'PATH=${PATH}:${M2_HOME}/bin' >> /etc/profile.d/maven.sh

## Install gradle
## Using a hard coded checksum because no download checksum available
#RUN cd /opt \
# && unzip -q /tmp/gradle-3.5-all.zip \
# && rm /tmp/gradle-3.5-all.zip \
# && ln -s gradle-3.5 gradle \
# && echo 'export GRADLE_HOME=/opt/gradle' > /etc/profile.d/gradle.sh \
# && echo 'export PATH=${PATH}:${GRADLE_HOME}/bin' >> /etc/profile.d/gradle.sh

# Install Vault
RUN cd /opt \
 && mkdir vault_1.0.1 \
 && unzip -q /tmp/vault_1.0.1_linux_amd64.zip -d vault_1.0.1/ \
 && rm /tmp/vault_1.0.1_linux_amd64.zip \
 && chmod -R 755 vault_1.0.1/ \
 && ln -s vault_1.0.1 vault \
 && echo 'export VAULT_HOME=/opt/vault' > /etc/profile.d/vault.sh \
 && echo 'PATH=${PATH}:${VAULT_HOME}' >> /etc/profile.d/vault.sh

# Install Terraform
RUN cd /opt \
 && mkdir terraform_0.11.11 \
 && unzip -q /tmp/terraform_0.11.11_linux_amd64.zip -d terraform_0.11.11/ \
 && rm /tmp/terraform_0.11.11_linux_amd64.zip \
 && chmod -R 755 terraform_0.11.11/ \
 && ln -s terraform_0.11.11 terraform \
 && echo 'export TERRAFORM_HOME=/opt/terraform' > /etc/profile.d/terraform.sh \
 && echo 'PATH=${PATH}:${TERRAFORM_HOME}' >> /etc/profile.d/terraform.sh

# Install kops
RUN cp /tmp/kops-linux-amd64 /usr/local/bin/kops \
 && chmod 755 /usr/local/bin/kops

## Install pip
RUN apt-get install -y python3 python3-pip \
 && pip3 install --upgrade pip
 #&& pip install --upgrade virtualenv

# Use zsh while running commands
SHELL ["/bin/zsh", "-c"]

RUN useradd -u 1000 -g users -c 'Aaron Albert' -d /home/aaron -s /bin/zsh -m aaron \
 && echo 'aaron ALL=NOPASSWD:ALL' >> /etc/sudoers

# Everything else should be non-root
USER aaron

# Setup oh-my-zsh
COPY install_ohmyzsh.sh aaron8bit.zsh-theme aaron8bit2.zsh-theme /tmp/
# the install exits with 1 but seems to work fine
RUN sudo apt-get install -y powerline fonts-powerline
RUN git clone https://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh \
 && cp ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc \
 && cp /tmp/aaron8bit.zsh-theme ~/.oh-my-zsh/themes/ \
 && cp /tmp/aaron8bit2.zsh-theme ~/.oh-my-zsh/themes/ \
 && sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="aaron8bit2"/g' ~/.zshrc \
 && sed -i 's/# CASE_SENSITIVE="true"/CASE_SENSITIVE="true"/g' ~/.zshrc

# Install AWS CLI tools
RUN pip3 install awscli --upgrade --user \
 && echo "# User specific environment and startup programs" >> ~/.zshrc \
 && echo "export PATH=\${PATH}:\${HOME}/.local/bin:\${HOME}/bin" >> ~/.zshrc \
 && echo "export PATH" >> ~/.zshrc

# Install Google SDK
RUN curl -sSL https://sdk.cloud.google.com | bash \
 && echo "export PATH=\${PATH}:\${HOME}/google-cloud-sdk/bin" >> ~/.zshrc \
 && echo "export PATH" >> ~/.zshrc

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

