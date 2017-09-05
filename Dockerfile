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

# Copy install files
COPY apache-maven-3.3.9-bin.tar.gz gradle-3.5-all.zip vault_0.7.2_linux_amd64.zip terraform_0.9.4_linux_amd64.zip /tmp/

# Install Maven 3.3.9
RUN cd /opt \
 && tar xzf /tmp/apache-maven-3.3.9-bin.tar.gz \
 && rm /tmp/apache-maven-3.3.9-bin.tar.gz \
 && ln -s apache-maven-3.3.9 maven \
 && echo 'export M2_HOME=/opt/maven' > /etc/profile.d/maven.sh \
 && echo 'PATH=${PATH}:${M2_HOME}/bin' >> /etc/profile.d/maven.sh

# Install gradle
# Using a hard coded checksum because no download checksum available
RUN cd /opt \
 && unzip -q /tmp/gradle-3.5-all.zip \
 && rm /tmp/gradle-3.5-all.zip \
 && ln -s gradle-3.5 gradle \
 && echo 'export GRADLE_HOME=/opt/gradle' > /etc/profile.d/gradle.sh \
 && echo 'export PATH=${PATH}:${GRADLE_HOME}/bin' >> /etc/profile.d/gradle.sh

# Install Vault
RUN cd /opt \
 && mkdir vault_0.7.2 \
 && unzip -q /tmp/vault_0.7.2_linux_amd64.zip -d vault_0.7.2/ \
 && rm /tmp/vault_0.7.2_linux_amd64.zip \
 && chmod -R 755 vault_0.7.2/ \
 && ln -s vault_0.7.2 vault \
 && echo 'export VAULT_HOME=/opt/vault' > /etc/profile.d/vault.sh \
 && echo 'PATH=${PATH}:${VAULT_HOME}' >> /etc/profile.d/vault.sh

# Install Terraform
RUN cd /opt \
 && mkdir terraform_0.9.4 \
 && unzip -q /tmp/terraform_0.9.4_linux_amd64.zip -d terraform_0.9.4/ \
 && rm /tmp/terraform_0.9.4_linux_amd64.zip \
 && chmod -R 755 terraform_0.9.4/ \
 && ln -s terraform_0.9.4 terraform \
 && echo 'export TERRAFORM_HOME=/opt/terraform' > /etc/profile.d/terraform.sh \
 && echo 'PATH=${PATH}:${TERRAFORM_HOME}' >> /etc/profile.d/terraform.sh

## Install pip
RUN yum install -y python-pip python34-pip \
 && pip install --upgrade pip \
 && pip install --upgrade virtualenv

# Use zsh while running commands
SHELL ["/bin/zsh", "-c"]

RUN useradd -u 1000 -g users -c 'Aaron Albert' -d /home/aja -s /bin/zsh -m aja \
 && echo 'aja ALL=NOPASSWD:ALL' >> /etc/sudoers

# Everything else should be non-root
USER aja

# Setup oh-my-zsh
COPY install_ohmyzsh.sh aaron8bit.zsh-theme aaron8bit2.zsh-theme /tmp/
# the install exits with 1 but seems to work fine
RUN export TERM=xterm \
 && /tmp/install_ohmyzsh.sh \
 && cp /tmp/aaron8bit.zsh-theme ~/.oh-my-zsh/themes/ \
 && cp /tmp/aaron8bit2.zsh-theme ~/.oh-my-zsh/themes/ \
 && sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="aaron8bit2"/g' ~/.zshrc \
 && sed -i 's/# CASE_SENSITIVE="true"/CASE_SENSITIVE="true"/g' ~/.zshrc
# && sudo rm /tmp/install_ohmyzsh.sh /tmp/aaron8bit.zsh-theme /tmp/aaron8bit2.zsh-theme

# Install rvm
# Why does the rvm install hate zsh? bash works fine...
# TODO: Make this a multi-user install and put source into /etc/profile.d/
#RUN gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 \
# && curl -sSL https://get.rvm.io | bash -s stable --ruby=ruby-2.3 --gems=bundler,pry,rspec,guard,rubocop
#RUN echo >> ~/.zshrc \
# && echo "# Source rvm" >> ~/.zshrc \
# && echo "source ~/.rvm/scripts/rvm" >> ~/.zshrc

# Install AWS CLI tools
RUN pip install awscli --upgrade --user \
 && echo "# User specific environment and startup programs" >> ~/.zshrc \
 && echo "export PATH=\${PATH}:\${HOME}/.local/bin:\${HOME}/bin" >> ~/.zshrc \
 && echo "export PATH" >> ~/.zshrc

