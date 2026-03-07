# 🏛️ PRODUCTION ENVIRONMENT STATE AUDIT
**Project:** i-dub-thee
**Directive:** Ground-Truth Blueprint for Staging Mirror

## 1. STORAGE CONFIGURATIONS
```yaml
---
location: US-CENTRAL1
name: gcf-v2-sources-110409945269-us-central1
---
location: US-CENTRAL1
name: gcf-v2-uploads-110409945269.us-central1.cloudfunctions.appspot.com
---
location: US-CENTRAL1
name: i-dub-thee-docs
---
location: US-CENTRAL1
name: i-dub-thee-forensic-vault
---
location: US-CENTRAL1
name: i-dub-thee-master-filing-cabinet
---
location: US-CENTRAL1
name: i-dub-thee-processed
---
location: US-CENTRAL1
name: i-dub-thee-quarantine
---
location: US
name: i-dub-thee_cloudbuild
```

## 2. BIGQUERY FACT BASE (ingestion_ledger)
```json
[
  {
    "mode": "REQUIRED",
    "name": "original_parent_sha256",
    "type": "STRING"
  },
  {
    "mode": "REQUIRED",
    "name": "sliced_child_sha256",
    "type": "STRING"
  },
  {
    "mode": "REQUIRED",
    "name": "gcs_source_uri",
    "type": "STRING"
  },
  {
    "mode": "REQUIRED",
    "name": "entity_slug",
    "type": "STRING"
  },
  {
    "mode": "REQUIRED",
    "name": "taxonomy_lane",
    "type": "STRING"
  },
  {
    "mode": "REQUIRED",
    "name": "average_confidence",
    "type": "FLOAT"
  },
  {
    "mode": "REQUIRED",
    "name": "requires_manual_review",
    "type": "BOOLEAN"
  },
  {
    "mode": "REQUIRED",
    "name": "extracted_payload",
    "type": "JSON"
  },
  {
    "defaultValueExpression": "CURRENT_TIMESTAMP()",
    "name": "ingestion_timestamp",
    "type": "TIMESTAMP"
  }
]
```

## 3. LAYER 1: PIPELINE ROUTER (Cloud Function)
```yaml
environment: GEN_2
eventTrigger:
  eventFilters:
  - attribute: bucket
    value: i-dub-thee-docs
  eventType: google.cloud.storage.object.v1.finalized
  pubsubTopic: projects/i-dub-thee/topics/eventarc-us-central1-forensic-pipeline-router-503777-159
  retryPolicy: RETRY_POLICY_DO_NOT_RETRY
  serviceAccountEmail: 110409945269-compute@developer.gserviceaccount.com
  trigger: projects/i-dub-thee/locations/us-central1/triggers/forensic-pipeline-router-503777
  triggerRegion: us-central1
name: projects/i-dub-thee/locations/us-central1/functions/forensic-pipeline-router
serviceConfig:
  availableMemory: 1024M
  environmentVariables:
    GOOGLE_CLOUD_PROJECT_ID: i-dub-thee
    LOG_EXECUTION_ID: 'true'
  timeoutSeconds: 540
```

## 4. LAYER 2B: ANALYTICAL ORCHESTRATOR (Cloud Run Job)
```yaml

  null
```

