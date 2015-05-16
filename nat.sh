#!/bin/bash

# This script is to set default route with NAT.

MAC_ADDRESS=`curl http://169.254.169.254/latest/meta-data/network/interfaces/macs/`
VPC_ID=`curl http://169.254.169.254/latest/meta-data/network/interfaces/macs/${MAC_ADDRESS:-1}/vpc-id`

INSTANCE_ID=`curl http://169.254.169.254/latest/meta-data/instance-id`
REGION=`curl http://169.254.169.254/latest/dynamic/instance-identity/document|grep region|awk -F\" '{print $4}'`
#ROUTE_TABLES=`aws ec2 describe-tags --filter "Name=resource-type,Values=route-table"  "Name=key,Values=network" "Name=value,Values=private" --region $REGION --output text | awk '{print $3}'`
ROUTE_TABLES=`Shings-Air:aws-auto-healing-nat schen$ aws ec2 describe-route-tables --filters "Name=vpc-id,Values=$VPC_ID" --filters "Name=tag:$TAG_KEY,Values=$TAG_VALUE"`

for i in $ROUTE_TABLES
do
   # Replace default route
   aws ec2 replace-route --route-table-id $i --destination-cidr-block 0.0.0.0/0 --instance-id $INSTANCE_ID --region $REGION > /dev/null 2>&1

   # Create default route 
   if [ $? -ne 0 ]; then
      aws ec2 create-route --route-table-id $i --destination-cidr-block 0.0.0.0/0 --instance-id $INSTANCE_ID --region $REGION
   fi
done

# disable source destination check
aws ec2 modify-instance-attribute --instance-id $INSTANCE_ID --no-source-dest-check --region $REGION
