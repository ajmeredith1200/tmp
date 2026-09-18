#!/usr/bin/env bash
set -euo pipefail

AWS_REGION="${AWS_REGION:-eu-west-1}"
S3_PREFIX="${S3_PREFIX:-gitlab-source}"
S3_BUCKETS="${S3_BUCKETS:-}"
ARCHIVE_NAME="${ARCHIVE_NAME:-latest.zip}"
ARCHIVE_PATH="/tmp/${ARCHIVE_NAME}"

if [ -z "${CI_COMMIT_SHA:-}" ]; then
  echo "CI_COMMIT_SHA is required" >&2
  exit 1
fi

if [ -z "${S3_BUCKETS:-}" ]; then
  echo "S3_BUCKETS is required" >&2
  exit 1
fi

zip -r "${ARCHIVE_PATH}" . \
  -x ".git/*" \
  -x ".terraform/*" \
  -x "**/.terraform/*" \
  -x "**/.git/*"

for bucket in ${S3_BUCKETS}; do
  target="s3://${bucket}/${S3_PREFIX}/${ARCHIVE_NAME}"
  aws s3 cp "${ARCHIVE_PATH}" "${target}" --region "${AWS_REGION}" --only-show-errors
  echo "Uploaded ${ARCHIVE_NAME} to ${target}"
done
