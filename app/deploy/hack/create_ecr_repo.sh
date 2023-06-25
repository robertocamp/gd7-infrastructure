#!/bin/bash

# Set your AWS region and repository name
AWS_REGION="your-aws-region"
REPO_NAME="your-repo-name"

# Create the ECR repository
echo "Creating ECR repository: $REPO_NAME"
aws ecr create-repository --repository-name "$REPO_NAME" --region "$AWS_REGION"

# Check the result
if [ $? -eq 0 ]; then
    echo "ECR repository created successfully."
else
    echo "Failed to create ECR repository."
fi
