#!/usr/bin/env bash

function main() {
  local EC2_CERT="xxx.pem"
  local EC2_SERVER="xxx.compute.amazonaws.com"
  local EC2_USER="ec2-user"

  ssh -i ${EC2_CERT} ${EC2_USER}@${EC2_SERVER}
}

main

