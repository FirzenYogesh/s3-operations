#!/usr/bin/env bash

set -e

s3Object() {
    echo "s3://$AWS_S3_BUCKET/$1"
}

if [[ -z "$AWS_OPERATION" ]]; then
    AWS_OPERATION="sync"
fi

if [ -z "$AWS_S3_BUCKET" ]; then
    echo "AWS_S3_BUCKET is required."
    exit 1
fi

if [ -z "$AWS_ACCESS_KEY_ID" ]; then
    echo "AWS_ACCESS_KEY_ID is required."
    exit 1
fi

if [ -z "$AWS_SECRET_ACCESS_KEY" ]; then
    echo "AWS_SECRET_ACCESS_KEY is required."
    exit 1
fi

# Default to us-east-1 if AWS_REGION not set.
if [ -z "$AWS_REGION" ]; then
    AWS_REGION="us-east-1"
fi

# Override default AWS endpoint if user sets AWS_S3_ENDPOINT.
if [ -n "$AWS_S3_ENDPOINT" ]; then
    ENDPOINT_URL="--endpoint-url $AWS_S3_ENDPOINT"
fi

mkdir -p ~/.aws

echo "[s3-operations]
aws_access_key_id=$AWS_ACCESS_KEY_ID
aws_secret_access_key=$AWS_SECRET_ACCESS_KEY
region=$AWS_REGION
" | tee ~/.aws/credentials  >/dev/null

if [[ $AWS_OPERATION == "sync" ]]; then
    DEST="$(s3Object $DEST)"
    sh -c "aws s3 sync ${SOURCE:-.} ${DEST} --profile s3-operations --no-progress ${ENDPOINT_URL} $*"
elif [[ $AWS_OPERATION == "sync-to-s3" ]]; then
    DEST="$(s3Object $DEST)"
    sh -c "aws s3 sync ${SOURCE:-.} ${DEST} --profile s3-operations --no-progress ${ENDPOINT_URL} $*"
elif [[ $AWS_OPERATION == "sync-from-s3" ]]; then
    SOURCE="$(s3Object $SOURCE)"
    sh -c "aws s3 sync ${SOURCE} ${DEST:-.} --profile s3-operations --no-progress ${ENDPOINT_URL} $*"
fi