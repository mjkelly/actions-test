#!/bin/bash
set -u
set -e
bucket=s3://scratch.michaelkelly.org
dir=public
cf_id=EX8C2142KHBD7
scripts=$(dirname $0)

which aws || (echo "'aws' command not found. Aborting."; exit 2)

echo "=== Building ==="
${scripts}/generate.sh

echo "=== Deploying ==="

#echo "Special handling for .well-known directory..."
#aws s3 cp "$dir/.well-known/openpgpkey" "$bucket/.well-known/openpgpkey" \
#  --recursive \
#  --content-type=application/octet-stream \
#  --cache-control=max-age=3600

echo "Synchronizing directory $PWD/$dir to ${bucket}..."
aws s3 sync "$dir" "$bucket" \
  --cache-control=max-age=3600

echo "Invalidating CloudFront ${cf_id}..."
aws cloudfront create-invalidation \
  --distribution-id "${cf_id}" \
  --paths "/*"
