#!/bin/bash
set -xeuo pipefail

if [ ! -f ".env" ]; then
  echo "No .env file found"
  exit 1
fi

source .env

echo "Terminating EC2 instance $INSTANCE_ID..."
aws ec2 terminate-instances --instance-ids $INSTANCE_ID --region us-east-1

echo "Waiting for instance to terminate..."
aws ec2 wait instance-terminated --instance-ids $INSTANCE_ID --region us-east-1
echo "Instance terminated."

echo "Deleting security group $SECURITY_GROUP_ID..."
aws ec2 delete-security-group --group-id $SECURITY_GROUP_ID --region us-east-1
echo "Security group deleted."

echo "Deleting key pair $KEY_NAME from AWS..."
aws ec2 delete-key-pair --key-name $KEY_NAME --region us-east-1

echo "Removing local key file $KEY_FILE..."
rm -f "$KEY_FILE"

echo "Teardown complete."
