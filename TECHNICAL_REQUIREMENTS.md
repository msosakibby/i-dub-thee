# TECHNICAL REQUIREMENTS

## 1. Infrastructure Stack
* **Local IDE:** NixOS Container (Project IDX), Python 3.11.10.
* **Compute:** Google Cloud Run Functions (gen2, 4096MB memory, 540s timeout), Google Cloud Run (FastAPI).
* **AI/ML:** Google Vertex AI (`gemini-2.5-pro`), Document AI (Form Parser v2).
* **Database:** Google BigQuery (Serverless).

## 2. Core Python Dependencies (`requirements.txt`)
* `google-cloud-storage>=2.14.0`
* `google-cloud-bigquery>=3.17.0`
* `google-cloud-documentai>=3.4.0`
* `google-genai>=0.3.0`
* `pydantic==2.6.1`
* `pytest>=8.0.0`
* `functions-framework>=3.8.0`
* `pypdf>=4.1.0`
* `fastapi>=0.109.2`
* `uvicorn>=0.27.1`

## 3. Service Account IAM Matrix (`forensic-engine-sa`)
* `roles/storage.admin` (Required for Eventarc trigger configurations)
* `roles/bigquery.dataEditor`
* `roles/bigquery.jobUser`
* `roles/documentai.apiUser`
* `roles/aiplatform.user`
* `roles/eventarc.eventReceiver`
* `roles/run.invoker`

## 4. Mathematical Validation (Pydantic)
* All data models MUST implement `model_config = ConfigDict(extra='forbid')` to prevent LLM hallucinations from silently injecting non-schema fields.
* All financial and sequential schemas MUST contain an `@model_validator(mode='after')` decorator that manually recalculates the sub-totals, taxes, and running balances using the `extracted_string_or_numeric_value` fields before allowing the object to instantiate.
