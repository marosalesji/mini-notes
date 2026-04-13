#!/bin/bash
set -xeuo pipefail

KEY_NAME="mini-notes-key"
AMI_ID="ami-0b6c6ebed2801a5cb"  # Ubuntu 24.04

aws ec2 create-key-pair \
  --key-name $KEY_NAME \
  --query 'KeyMaterial' \
  --output text \
  --region us-east-1 > "${KEY_NAME}.pem"
chmod 400 "${KEY_NAME}.pem"
echo "Key pair created: ${KEY_NAME}.pem"

SG_ID=$(aws ec2 create-security-group \
  --group-name mini-notes-sg \
  --description "Security group for mini-notes demo" \
  --region us-east-1 \
  --query 'GroupId' \
  --output text)
echo "Security Group created: $SG_ID"

aws ec2 authorize-security-group-ingress \
  --group-id $SG_ID \
  --protocol tcp \
  --port 22 \
  --cidr 0.0.0.0/0 \
  --region us-east-1

aws ec2 authorize-security-group-ingress \
  --group-id $SG_ID \
  --protocol tcp \
  --port 8000 \
  --cidr 0.0.0.0/0 \
  --region us-east-1

INSTANCE_ID=$(aws ec2 run-instances \
  --image-id $AMI_ID \
  --instance-type t3.nano \
  --key-name $KEY_NAME \
  --security-group-ids $SG_ID \
  --associate-public-ip-address \
  --iam-instance-profile Name=LabInstanceProfile \
  --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=mini-notes-instance}]' \
  --query 'Instances[0].InstanceId' \
  --output text \
  --region us-east-1)
echo "EC2 instance created: $INSTANCE_ID"

echo "Waiting for instance to be running..."
aws ec2 wait instance-running --instance-ids $INSTANCE_ID --region us-east-1

EC2_IP=$(aws ec2 describe-instances \
  --instance-ids $INSTANCE_ID \
  --query 'Reservations[].Instances[].PublicIpAddress' \
  --output text \
  --region us-east-1)
echo "Instance IP: $EC2_IP"

cat > .env << EOF
SECURITY_GROUP_ID=$SG_ID
INSTANCE_ID=$INSTANCE_ID
EC2_IP=$EC2_IP
KEY_NAME=$KEY_NAME
KEY_FILE="${KEY_NAME}.pem"
EOF
echo "Config saved to .env"

echo "Waiting for SSH to be ready..."
sleep 30

echo "Installing Docker on EC2..."
ssh -o StrictHostKeyChecking=no -t -i "${KEY_NAME}.pem" ubuntu@"$EC2_IP" << 'ENDSSH'
set -euo pipefail

sudo apt-get update -y
sudo apt-get install -y ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] \
  https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update -y
sudo apt-get install -y docker-ce docker-ce-cli containerd.io

sudo usermod -aG docker ubuntu
echo "Docker installed. Re-login or run 'newgrp docker' to use without sudo."
ENDSSH

echo "Setup complete."
echo "SSH: ssh -i ${KEY_NAME}.pem ubuntu@$EC2_IP"
