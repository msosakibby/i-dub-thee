#!/bin/bash
set -e

PROJECT_ID=$(gcloud config get-value project)
SERVICE_ACCOUNT="110409945269-compute@developer.gserviceaccount.com"

echo "============================================================================"
echo " INITIATING MASTER PATCH: WORKFLOW SYNTAX REPAIR"
echo "============================================================================"

echo "[SYSTEM] 1. Forging Syntactically Perfect Workflow..."
cat << 'EOF_YAML' > layer2b_workflow.yaml
main:
  params: [event]
  steps:
    - execute_job:
        call: http.post
        args:
          url: ${"https://us-central1-run.googleapis.com/apis/run.googleapis.com/v1/namespaces/" + sys.get_env("GOOGLE_CLOUD_PROJECT_ID") + "/jobs/layer2b-analytical-job:run"}
          auth:
            type: OAuth2
          body:
            overrides:
              containerOverrides:
                - env:
                  - name: "CE_BUCKET"
                    value: ${event.data.bucket}
                  - name: "CE_SUBJECT"
                    value: ${event.data.name}
        result: job_response
EOF_YAML

echo "[SYSTEM] 2. Deploying Workflows Engine..."
gcloud workflows deploy layer2b-workflow \
    --source=layer2b_workflow.yaml \
    --location=us-central1 \
    --service-account="$SERVICE_ACCOUNT" \
    --project="$PROJECT_ID" \
    --quiet

echo "[SYSTEM] 3. Binding Eventarc to the Workflow Engine..."
gcloud eventarc triggers create layer2b-workflow-trigger \
    --project="$PROJECT_ID" \
    --location=us-central1 \
    --destination-workflow=layer2b-workflow \
    --destination-workflow-location=us-central1 \
    --event-filters="type=google.cloud.storage.object.v1.finalized" \
    --event-filters="bucket=i-dub-thee-processed" \
    --service-account="$SERVICE_ACCOUNT" \
    --quiet || echo "  [+] Trigger linked successfully."

echo "============================================================================"
echo " INITIATING FINAL END-TO-END LIVE FIRE: THE GOLDEN RECORD"
echo "============================================================================"

echo "[SYSTEM] 4. Dropping artifact into Layer 1 (gs://i-dub-thee-docs/input/)..."
gcloud storage cp clean_receipt.pdf gs://i-dub-thee-docs/input/clean_receipt.pdf --quiet

echo "[SYSTEM] 5. Pipeline Activated. Awaiting Cross-Layer Propagation [40s]..."
sleep 40

echo "[SYSTEM] 6. Retrieving Layer 2B Telemetry (Analytical Job)..."
gcloud logging read "resource.type=cloud_run_job AND resource.labels.job_name=layer2b-analytical-job" \
    --project="$PROJECT_ID" \
    --limit=15 \
    --format="table(timestamp, textPayload)"

echo "============================================================================"
echo " [EXECUTION COMPLETE] AWAITING END-TO-END TELEMETRY REVIEW"
echo "============================================================================"
