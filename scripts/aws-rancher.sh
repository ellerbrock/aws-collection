#!/usr/bin/env bash

# Developer:  Maik Ellerbrock
# Github:     https://github.com/ellerbrock
# Twitter:    https://twitter.com/frapsoft

if [[ $(id -u) != 0  ]]; then
  echo "please run as root user"
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

function aws-install-rancher-ha() {
  if [[ -z "${RANCHER_MYSQL_HOST}" ]]  || \
     [[ -z "${RANCHER_MYSQL_PORT}" ]] || \
     [[ -z "${RANCHER_MYSQL_USER}" ]] || \
     [[ -z "${RANCHER_MYSQL_PASS}" ]] || \
     [[ -z "${RANCHER_MYSQL_DB}" ]] || \
     [[ -z "${RANCHER_IP}" ]]; then
    echo "rancher or mysql variables missing!"
  else
    docker run -d \
      --restart=unless-stopped \
      -p 8080:8080 \
      -p 9345:9345 rancher/server \
      --db-host ${RANCHER_MYSQL_HOST} \
      --db-port ${RANCHER_MYSQL_PORT} \
      --db-user ${RANCHER_MYSQL_USER}  \
      --db-pass ${RANCHER_MYSQL_PASS}  \
      --db-name ${RANCHER_MYSQL_DB}  \
      --advertise-address ${RANCHER_IP}
  fi
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
  aws-install-docker
  aws-install-rancher
}

