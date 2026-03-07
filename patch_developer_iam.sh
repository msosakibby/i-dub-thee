#!/bin/bash
set -e

PROJECT_ID="i-dub-thee"

echo "[SYSTEM] 1. Detecting Active Developer Identity..."
ACTIVE_ACCOUNT=$(gcloud config get-value account)

if [ -z "$ACTIVE_ACCOUNT" ]; then
    echo "[FATAL] No active gcloud account detected. Run 'gcloud auth login' first."
    exit 1
fi

# Determine if the active identity is a Google User or a Service Account
if [[ "$ACTIVE_ACCOUNT" == *".gserviceaccount.com" ]]; then
    MEMBER="serviceAccount:${ACTIVE_ACCOUNT}"
else
    MEMBER="user:${ACTIVE_ACCOUNT}"
fi

echo "  -> Identity Secured: ${MEMBER}"

echo "[SYSTEM] 2. Applying Cloud Build and Cloud Run Administrator Rights..."

# Grant the ability to execute and view container builds
gcloud projects add-iam-policy-binding ${PROJECT_ID} \
    --member="${MEMBER}" \
    --role="roles/cloudbuild.builds.editor" --condition=None >/dev/null 2>&1

# Grant the ability to physically deploy Cloud Run services
gcloud projects add-iam-policy-binding ${PROJECT_ID} \
    --member="${MEMBER}" \
    --role="roles/run.admin" --condition=None >/dev/null 2>&1

# Grant the ability to attach the 'forensic-engine-sa-dev' identity to the container
gcloud projects add-iam-policy-binding ${PROJECT_ID} \
    --member="${MEMBER}" \
    --role="roles/iam.serviceAccountUser" --condition=None >/dev/null 2>&1

# Grant access to push the compiled container to Artifact Registry
gcloud projects add-iam-policy-binding ${PROJECT_ID} \
    --member="${MEMBER}" \
    --role="roles/artifactregistry.admin" --condition=None >/dev/null 2>&1

echo "============================================================================"
echo " [SUCCESS] DEVELOPER PERMISSIONS SECURED. YOU MAY NOW DEPLOY."
echo "============================================================================"
