#!/bin/bash
set -e

PROJECT_ID=$(gcloud config get-value project)
SERVICE_ACCOUNT="110409945269-compute@developer.gserviceaccount.com"

echo "============================================================================"
echo " INITIATING MASTER PATCH: THE WORKFLOW BRIDGE"
echo "============================================================================"

echo "[SYSTEM] 1. Enabling Workflows API and Binding Roles..."
gcloud services enable workflows.googleapis.com --project="$PROJECT_ID" --quiet
gcloud projects add-iam-policy-binding "$PROJECT_ID" --member="serviceAccount:$SERVICE_ACCOUNT" --role="roles/workflows.invoker" --condition=None --quiet >/dev/null
gcloud projects add-iam-policy-binding "$PROJECT_ID" --member="serviceAccount:$SERVICE_ACCOUNT" --role="roles/run.developer" --condition=None --quiet >/dev/null
gcloud projects add-iam-policy-binding "$PROJECT_ID" --member="serviceAccount:$SERVICE_ACCOUNT" --role="roles/iam.serviceAccountUser" --condition=None --quiet >/dev/null

echo "[SYSTEM] 2. Authoring Workflow Logic (layer2b_workflow.yaml)..."
cat << 'EOF_YAML' > layer2b_workflow.yaml
main:
  params: [event]
  steps:
    - check_if_pdf:
        switch:
          - condition: ${text.endswith(text.lower(event.data.name), ".pdf")}
            next: execute_job
        next: skip_execution
    - execute_job:
        call: googleapis.run.v1.namespaces.jobs.run
        args:
          name: ${"namespaces/" + sys.get_env("GOOGLE_CLOUD_PROJECT_ID") + "/jobs/layer2b-analytical-job"}
          location: "us-central1"
          body:
            overrides:
              containerOverrides:
                - env:
                  - name: "CE_BUCKET"
                    value: ${event.data.bucket}
                  - name: "CE_SUBJECT"
                    value: ${event.data.name}
        result: job_response
    - skip_execution:
        return: "File is not a PDF. Ignored."
EOF_YAML

echo "[SYSTEM] 3. Deploying Workflows Engine..."
gcloud workflows deploy layer2b-workflow \
    --source=layer2b_workflow.yaml \
    --location=us-central1 \
    --service-account="$SERVICE_ACCOUNT" \
    --project="$PROJECT_ID" \
    --quiet

echo "[SYSTEM] 4. Binding Eventarc to the Workflow Engine..."
gcloud eventarc triggers create layer2b-workflow-trigger \
    --project="$PROJECT_ID" \
    --location=us-central1 \
    --destination-workflow=layer2b-workflow \
    --destination-workflow-location=us-central1 \
    --event-filters="type=google.cloud.storage.object.v1.finalized" \
    --event-filters="bucket=i-dub-thee-processed" \
    --service-account="$SERVICE_ACCOUNT" \
    --quiet

echo "============================================================================"
echo " INITIATING FINAL END-TO-END LIVE FIRE: THE GOLDEN RECORD"
echo "============================================================================"

echo "[SYSTEM] 5. Forging a clean 'Golden Record' artifact..."
cat << 'EOF_PYTHON' > generate_clean_artifact.py
from reportlab.pdfgen import canvas
c = canvas.Canvas("clean_receipt.pdf")
c.setFont("Helvetica-Bold", 16)
c.drawString(100, 750, "M & J FOOD MARKET - CLEAN RECEIPT")
c.setFont("Helvetica", 12)
c.drawString(100, 710, "Transaction Date: 2026-02-26")
c.drawString(100, 690, "Payment Method: Corporate Credit Card")
c.drawString(100, 670, "Total Amount: $150.00")
c.drawString(100, 650, "Notes: Standard office supplies.")
c.save()
EOF_PYTHON

python3 generate_clean_artifact.py

echo "[SYSTEM] 6. Dropping artifact into Layer 1 (gs://i-dub-thee-docs/input/)..."
gcloud storage cp clean_receipt.pdf gs://i-dub-thee-docs/input/clean_receipt.pdf --quiet

echo "[SYSTEM] 7. Pipeline Activated. Awaiting Cross-Layer Propagation [35s]..."
sleep 35

echo "[SYSTEM] 8. Retrieving Layer 2B Telemetry (Analytical Job)..."
gcloud logging read "resource.type=cloud_run_job AND resource.labels.job_name=layer2b-analytical-job" \
    --project="$PROJECT_ID" \
    --limit=15 \
    --format="table(timestamp, textPayload)"

echo "============================================================================"
echo " [EXECUTION COMPLETE] AWAITING END-TO-END TELEMETRY REVIEW"
echo "============================================================================"
