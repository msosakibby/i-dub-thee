#!/bin/bash
set -e

PROJECT_ID=$(gcloud config get-value project)

echo "============================================================================"
echo " INITIATING MASTER PATCH: NATIVE WORKFLOW CONNECTOR"
echo "============================================================================"

echo "[SYSTEM] 1. Forging Strongly-Typed Workflow Logic..."
cat << 'EOF_WF' > layer2b_workflow.yaml
main:
  params: [event]
  steps:
    - init:
        assign:
          - project_id: ${sys.get_env("GOOGLE_CLOUD_PROJECT_ID")}
          - job_name: "layer2b-analytical-job"
          - location: "us-central1"
    - run_job:
        call: googleapis.run.v1.namespaces.jobs.run
        args:
          name: ${"namespaces/" + project_id + "/jobs/" + job_name}
          location: ${location}
          body:
            overrides:
              containerOverrides:
                - env:
                  - name: "CE_BUCKET"
                    value: ${event.data.bucket}
                  - name: "CE_SUBJECT"
                    value: ${event.data.name}
        result: job_result
    - return_result:
        return: ${job_result}
EOF_WF

echo "[SYSTEM] 2. Deploying Native Workflows Engine..."
gcloud workflows deploy layer2b-workflow \
    --source=layer2b_workflow.yaml \
    --location=us-central1 \
    --project="$PROJECT_ID" \
    --quiet

echo "[SYSTEM] 3. Bouncing PDF to Trigger the Native Bridge..."
gcloud storage cp gs://i-dub-thee-processed/clean_receipt.pdf gs://i-dub-thee-processed/clean_receipt.pdf --quiet

echo "[SYSTEM] 4. Awaiting Container Execution [20s]..."
sleep 20

echo "--- 5. CLOUD RUN JOB EXECUTIONS (Did the container boot?) ---"
gcloud run jobs executions list --job=layer2b-analytical-job --region=us-central1 --limit=3

echo "--- 6. LAYER 2B JOB TELEMETRY (Application Logs) ---"
gcloud logging read "resource.type=cloud_run_job AND resource.labels.job_name=layer2b-analytical-job" \
    --project="$PROJECT_ID" \
    --limit=10 \
    --format="table(timestamp, textPayload)"

echo "============================================================================"
echo " [EXECUTION COMPLETE]"
echo "============================================================================"
