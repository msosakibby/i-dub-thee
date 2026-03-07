#!/bin/bash
set -e

PROJECT_ID=$(gcloud config get-value project)

echo "============================================================================"
echo " INITIATING MASTER PATCH: WORKFLOW V2 API ALIGNMENT"
echo "============================================================================"

echo "[SYSTEM] 1. Forging Native V2 Workflow Connector..."
cat << 'EOF_YAML' > layer2b_workflow.yaml
main:
  params: [event]
  steps:
    - init:
        assign:
          - project_id: ${sys.get_env("GOOGLE_CLOUD_PROJECT_ID")}
    - run_job:
        call: googleapis.run.v2.projects.locations.jobs.run
        args:
          name: ${"projects/" + project_id + "/locations/us-central1/jobs/layer2b-analytical-job"}
          body:
            overrides:
              containerOverrides:
                - env:
                    - name: "CE_BUCKET"
                      value: ${event.data.bucket}
                    - name: "CE_SUBJECT"
                      value: ${event.data.name}
EOF_YAML

echo "[SYSTEM] 2. Deploying Fortified Workflows Engine..."
gcloud workflows deploy layer2b-workflow \
    --source=layer2b_workflow.yaml \
    --location=us-central1 \
    --project="$PROJECT_ID" \
    --quiet

echo "============================================================================"
echo " INITIATING KINETIC BOUNCE TO RETRIGGER PIPELINE"
echo "============================================================================"

echo "[SYSTEM] 3. Purging remote artifact to clear state..."
gcloud storage rm gs://i-dub-thee-processed/clean_receipt.pdf --quiet || echo "  [-] File already missing."

echo "[SYSTEM] 4. Uploading fresh artifact to Processed Vault..."
gcloud storage cp clean_receipt.pdf gs://i-dub-thee-processed/clean_receipt.pdf --quiet

echo "[SYSTEM] 5. Awaiting Workflow -> Job Propagation [35s]..."
sleep 35

echo "--- 6. LAYER 2B JOB TELEMETRY (Application Logs) ---"
gcloud logging read "resource.type=cloud_run_job AND resource.labels.job_name=layer2b-analytical-job AND severity>=INFO" \
    --project="$PROJECT_ID" \
    --limit=25 \
    --format="table(timestamp, severity, textPayload)"

echo "============================================================================"
echo " [EXECUTION COMPLETE]"
echo "============================================================================"
