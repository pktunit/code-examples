#!/bin/bash

#IP=$(dig TXT +short o-o.myaddr.l.google.com @ns1.google.com | awk -F'"' '{ print $2}')
IP=$(curl --silent https://checkip.amazonaws.com)
CIDR="${IP}"/32

cat > hosts <<EOT
---
aws:
  hosts:
EOT
aws ec2 describe-instances | jq -r '.Reservations[].Instances[] | "    " + .InstanceId + ":\n      ansible_host: " + .PublicIpAddress' >> hosts

cat >> hosts <<EOT
  vars:
    ansible_user: ec2-user
    ansible_ssh_private_key_file: ~/.ssh/aws_rsa
    ansible_python_interpreter: /usr/bin/python
...
EOT
cat hosts

# Allow SSH access from current IP
for i in $(aws ec2 describe-security-groups | jq -r '.SecurityGroups[].GroupId');
  do
    echo aws ec2 authorize-security-group-ingress --group-id $i --ip-permissions IpProtocol=tcp,FromPort=22,ToPort=22,IpRanges=[{CidrIp="${CIDR}"}];
    aws ec2 authorize-security-group-ingress --group-id $i --ip-permissions IpProtocol=tcp,FromPort=22,ToPort=22,IpRanges=[{CidrIp="${CIDR}"}];
  done

# Run Ansible Playbook
ansible-playbook cert-pkg-updater-playbook.yaml

# Deny SSH access from current IP
for i in $(aws ec2 describe-security-groups | jq -r '.SecurityGroups[].GroupId');
  do
    echo aws ec2 revoke-security-group-ingress --group-id $i --ip-permissions IpProtocol=tcp,FromPort=22,ToPort=22,IpRanges=[{CidrIp="${CIDR}"}]
    aws ec2 revoke-security-group-ingress --group-id $i --ip-permissions IpProtocol=tcp,FromPort=22,ToPort=22,IpRanges=[{CidrIp="${CIDR}"}]
  done
