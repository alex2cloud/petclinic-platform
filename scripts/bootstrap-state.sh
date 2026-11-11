#!/usr/bin/env bash
# Bootstrap Terraform remote state: S3 bucket (native S3 locking via use_lockfile; no DynamoDB).
# One-time, idempotent. Usage: scripts/bootstrap-state.sh [--region eu-central-1]
set -euo pipefail

REGION="eu-central-1"
while [[ $# -gt 0 ]]; do
  case "$1" in
    --region) REGION="${2:?--region requires a value}"; shift 2 ;;
    -h|--help) echo "Usage: $0 [--region <aws-region>]"; exit 0 ;;
    *) echo "Unknown argument: $1" >&2; exit 1 ;;
  esac
done

ACCOUNT_ID="$(aws sts get-caller-identity --query Account --output text)"
BUCKET="petclinic-terraform-state-${ACCOUNT_ID}"
TAGS_KV='{"TagSet":[{"Key":"Project","Value":"petclinic"},{"Key":"ManagedBy","Value":"bootstrap-script"}]}'

echo "Account: ${ACCOUNT_ID}  Region: ${REGION}"

# --- S3 bucket ---
if aws s3api head-bucket --bucket "$BUCKET" --region "$REGION" 2>/dev/null; then
  echo "Bucket exists: ${BUCKET}"
else
  echo "Creating bucket: ${BUCKET}"
  if [[ "$REGION" == "us-east-1" ]]; then
    aws s3api create-bucket --bucket "$BUCKET" --region "$REGION" >/dev/null
  else
    aws s3api create-bucket --bucket "$BUCKET" --region "$REGION" \
      --create-bucket-configuration "LocationConstraint=${REGION}" >/dev/null
  fi
fi

# put-* calls are idempotent, so always apply to converge on desired config.
aws s3api put-bucket-versioning --bucket "$BUCKET" \
  --versioning-configuration Status=Enabled
aws s3api put-bucket-encryption --bucket "$BUCKET" \
  --server-side-encryption-configuration \
  '{"Rules":[{"ApplyServerSideEncryptionByDefault":{"SSEAlgorithm":"AES256"}}]}'
aws s3api put-public-access-block --bucket "$BUCKET" \
  --public-access-block-configuration \
  BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true
aws s3api put-bucket-tagging --bucket "$BUCKET" --tagging "$TAGS_KV"
echo "Bucket configured (versioning, AES256, public access blocked)"

echo "Done. Backend: bucket=${BUCKET} (locking: use_lockfile = true)"
