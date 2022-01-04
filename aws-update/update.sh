#!/bin/bash

#IP=$(dig TXT +short o-o.myaddr.l.google.com @ns1.google.com | awk -F'"' '{ print $2}')
IP=$(curl --silent https://checkip.amazonaws.com)
CIDR="${IP}"/32

aws ec2 authorize-security-group-ingress --group-id sg-9b34a8a3 --ip-permissions IpProtocol=tcp,FromPort=22,ToPort=22,IpRanges=[{CidrIp="${CIDR}"}]
ansible-playbook cert-pkg-updater-playbook.yaml
aws ec2 revoke-security-group-ingress --group-id sg-9b34a8a3 --ip-permissions IpProtocol=tcp,FromPort=22,ToPort=22,IpRanges=[{CidrIp="${CIDR}"}]
