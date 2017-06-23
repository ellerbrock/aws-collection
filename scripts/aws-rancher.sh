#!/usr/bin/env bash

# Developer:  Maik Ellerbrock
# Github:     https://github.com/ellerbrock
# Twitter:    https://twitter.com/frapsoft

if [[ $(id -u) != 0  ]]; then
  echo "please run as root user"
  exit 1
fi

function aws-system-update() {
  yum update -y
  yum upgrade -y
}

function aws-install-tools() {
  yum install -y \
    git \
    htop
}

function aws-install-docker() {
  yum install -y docker
  service docker start
  usermod -a -G docker ec2-user
}

function aws-install-rancher() {
  docker volume create --name rancher-mysql

  docker run -d \
    --restart=unless-stopped \
    -v rancher-mysql:/var/lib/mysql \
    -p 8080:8080 \
  rancher/server:latest
}

function aws-shell-setup() {
  rm ~/.bashrc ~/.bash_profile
  rm -rf ~/.bash_it
  git clone --depth=1 https://github.com/Bash-it/bash-it.git ~/.bash_it
  ~/.bash_it/install.sh --silent
  echo -e "\n\nsource /home/rancher/scripts/rancher-shell.sh" >> ~/.bashrc
  echo "export BASH_IT_THEME='sexy'" >> ~/.bashrc
  echo "source ~/.bashrc" > ~/.bash_profile
}

function aws-init() {
  aws-system-update
  aws-install-tools
  aws-shell-setup
  aws-install docker
  aws-install-rancher
}

alias ls="ls --color=auto"
alias l="ls -alF"
alias ..="cd .."
alias top="htop"

