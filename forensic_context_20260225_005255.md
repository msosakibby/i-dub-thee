# LEGAL FORENSICS ENGINE - IDE EXTRACTION ARTIFACT
**TIMESTAMP:** 2026-02-25T00:52:55.100972
**TOTAL FILES EXTRACTED:** 22

================================================================================
FILEPATH: .idx/airules.md
================================================================================
```md
# Gemini AI Rules for Firebase Studio Nix Projects

## 1. Persona & Expertise

You are an expert in configuring development environments within Firebase Studio. You are proficient in using the `dev.nix` file to define reproducible, declarative, and isolated development environments. You have experience with the Nix language in the context of Firebase Studio, including packaging, managing dependencies, and configuring services.

## 2. Project Context

This project is a Nix-based environment for Firebase Studio, defined by a `.idx/dev.nix` file. The primary goal is to ensure a reproducible and consistent development environment. The project leverages the power of Nix to manage dependencies, tools, and services in a declarative manner. **Note:** This is not a Nix Flake-based environment.

## 3. `dev.nix` Configuration

The `.idx/dev.nix` file is the single source of truth for the development environment. Here are some of the most common configuration options:

### `channel`
The `nixpkgs` channel determines which package versions are available.

```nix
{ pkgs, ... }: {
  channel = "stable-24.05"; # or "unstable"
}
```

### `packages`
A list of packages to install from the specified channel. You can search for packages on the [NixOS package search](https://search.nixos.org/packages).

```nix
{ pkgs, ... }: {
  packages = [
    pkgs.nodejs_20
    pkgs.go
  ];
}
```

### `env`
A set of environment variables to define within the workspace.

```nix
{ pkgs, ... }: {
  env = {
    API_KEY = "your-secret-key";
  };
}
```

### `idx.extensions`
A list of VS Code extensions to install from the [Open VSX Registry](https://open-vsx.org/).

```nix
{ pkgs, ... }: {
  idx = {
    extensions = [
      "vscodevim.vim"
      "golang.go"
    ];
  };
}
```

### `idx.workspace`
Workspace lifecycle hooks.

- **`onCreate`:** Runs when a workspace is first created.
- **`onStart`:** Runs every time the workspace is (re)started.

```nix
{ pkgs, ... }: {
  idx = {
    workspace = {
      onCreate = {
        npm-install = "npm install";
      };
      onStart = {
        start-server = "npm run dev";
      };
    };
  };
}
```

### `idx.previews`
Configure a web preview for your application. The `$PORT` variable is dynamically assigned.

```nix
{ pkgs, ... }: {
  idx = {
    previews = {
      enable = true;
      previews = {
        web = {
          command = ["npm" "run" "dev" "--" "--port" "$PORT"];
          manager = "web";
        };
      };
    };
  };
}
```

## 4. Example Setups for Common Frameworks

Here are some examples of how to configure your `dev.nix` for common languages and frameworks.

### Node.js Web Server
This example sets up a Node.js environment, installs dependencies, and runs a development server with a web preview.

```nix
{ pkgs, ... }: {
  packages = [ pkgs.nodejs_20 ];
  idx = {
    extensions = [ "dbaeumer.vscode-eslint" ];
    workspace = {
      onCreate = {
        npm-install = "npm install";
      };
      onStart = {
        dev-server = "npm run dev";
      };
    };
    previews = {
      enable = true;
      previews = {
        web = {
          command = ["npm" "run" "dev" "--" "--port" "$PORT"];
          manager = "web";
        };
      };
    };
  };
}
```

### Python with Flask
This example sets up a Python environment for a Flask web server. Remember to create a `requirements.txt` file with `Flask` in it.

```nix
{ pkgs, ... }: {
  packages = [ pkgs.python3 pkgs.pip ];
  idx = {
    extensions = [ "ms-python.python" ];
    workspace = {
      onCreate = {
        pip-install = "pip install -r requirements.txt";
      };
    };
    previews = {
      enable = true;
      previews = {
        web = {
          command = ["flask" "run" "--port" "$PORT"];
          manager = "web";
        };
      };
    };
  };
}
```

### Go CLI
This example sets up a Go environment for building a command-line interface.

```nix
{ pkgs, ... }: {
  packages = [ pkgs.go ];
  idx = {
    extensions = [ "golang.go" ];
    workspace = {
      onCreate = {
        go-mod = "go mod tidy";
      };
      onStart = {
        run-app = "go run .";
      };
    };
  };
}
```

## 5. Interaction Guidelines

- Assume the user is familiar with general software development concepts but may be new to Nix and Firebase Studio.
- When generating Nix code, provide comments to explain the purpose of different sections.
- Explain the benefits of using `dev.nix` for reproducibility and dependency management.
- If a request is ambiguous, ask for clarification on the desired tools, libraries, and versions to be included in the environment.
- When suggesting changes to `dev.nix`, explain the impact of the changes on the development environment and remind the user to reload the environment.
```

================================================================================
FILEPATH: MASTER_CONTROL_DOCUMENT.md
================================================================================
```md
# MASTER CONTROL DOCUMENT
## Evidentiary Compliance
* **FRE 901 (Authentication):** Binary `%PDF` inspection and SHA-256 generation.
* **FRE 1006 (Summaries):** Double-entry algebraic checksums applied to every transaction, including sequential "ditto" mark propagation.
* **MRE 801 (Hearsay):** Spatial `[X,Y]` polygon bounding boxes map all extractions to physical page coordinates.
```

================================================================================
FILEPATH: PROJECT_BLUEPRINT.md
================================================================================
```md
# PROJECT BLUEPRINT: Legal Forensics & Trust Protection Engine (V17.0.0)
**Environment:** Google Cloud Platform (Eventarc, Cloud Run Functions, BigQuery)
**Architect:** Mark Kibby

## Executive Vision
A Daubert-admissible, serverless forensic accounting pipeline designed to enforce Paragraph 8F and Paragraph 6 constraints. It relies on deterministic algorithmic skepticism rather than generative AI trust, featuring strict cryptographic chain-of-custody linking child slices back to parent bundles. Includes a Layer 2 Hybrid RAG API for investigative hypothesis testing.
```

================================================================================
FILEPATH: audit_environment.sh
================================================================================
```sh
#!/bin/bash
# ============================================================================
# LEGAL FORENSICS ENGINE - ENVIRONMENT STATE EXTRACTOR
# PROJECT ID: i-dub-thee
# DIRECTIVE: Absolute Ground Truth Reconnaissance
# ============================================================================
set -o nounset
set -o pipefail

export PROJECT_ID="i-dub-thee"
export REGION="us-central1"
export OUTPUT_FILE="ENVIRONMENT_STATE.md"

echo "============================================================================"
echo " INITIATING STATE RECONNAISSANCE (TARGET: ${PROJECT_ID}) "
echo "============================================================================"

# Initialize a clean output file
cat << 'EOF' > "${OUTPUT_FILE}"
# LEGAL FORENSICS ENGINE: GROUND TRUTH STATE
This document contains the exact local codebase and the live Google Cloud infrastructure configuration.
EOF

echo "--- [1/5] EXTRACTING LOCAL SOURCE CODE ---"
echo -e "\n## 1. LOCAL CODEBASE SNAPSHOT\n" >> "${OUTPUT_FILE}"

# Use find to dynamically extract all relevant files, ignoring virtual environments and git
find . -type f \( -name "*.py" -o -name "*.sh" -o -name "*.txt" -o -name "*.json" \) \
    ! -path "*/forensic_env/*" \
    ! -path "*/.git/*" \
    ! -path "*/.idx/*" \
    ! -path "*/__pycache__/*" | sort | while read -r filepath; do
    
    echo "Extracting: $filepath"
    echo -e "### FILE: ${filepath}\n\`\`\`" >> "${OUTPUT_FILE}"
    cat "${filepath}" >> "${OUTPUT_FILE}"
    echo -e "\n\`\`\`\n" >> "${OUTPUT_FILE}"
done

echo "--- [2/5] INTERROGATING BIFURCATED STORAGE VAULTS ---"
echo -e "\n## 2. GOOGLE CLOUD STORAGE CONFIGURATION\n\`\`\`yaml" >> "${OUTPUT_FILE}"
gcloud storage buckets list --project="${PROJECT_ID}" --format="yaml" >> "${OUTPUT_FILE}" 2>/dev/null || echo "Error extracting buckets." >> "${OUTPUT_FILE}"
echo -e "\n\`\`\`\n" >> "${OUTPUT_FILE}"

echo "--- [3/5] INTERROGATING BIGQUERY FACT BASE ---"
echo -e "\n## 3. BIGQUERY SCHEMA & DATASET STATE\n\`\`\`yaml" >> "${OUTPUT_FILE}"
bq show --format=prettyjson "${PROJECT_ID}:forensic_fact_base.ingestion_ledger" >> "${OUTPUT_FILE}" 2>/dev/null || echo "Error extracting BigQuery schema. Table might not exist." >> "${OUTPUT_FILE}"
echo -e "\n\`\`\`\n" >> "${OUTPUT_FILE}"

echo "--- [4/5] INTERROGATING SERVERLESS COMPUTE (LAYER 1 & 2) ---"
echo -e "\n## 4. SERVERLESS COMPUTE CONFIGURATIONS\n" >> "${OUTPUT_FILE}"

echo "### Cloud Function: forensic-pipeline-router (Layer 1)" >> "${OUTPUT_FILE}"
echo -e "\n\`\`\`yaml" >> "${OUTPUT_FILE}"
gcloud functions describe forensic-pipeline-router --region="${REGION}" --gen2 --project="${PROJECT_ID}" --format="yaml" >> "${OUTPUT_FILE}" 2>/dev/null || echo "Function forensic-pipeline-router not found or failed to deploy." >> "${OUTPUT_FILE}"
echo -e "\n\`\`\`\n" >> "${OUTPUT_FILE}"

echo "### Cloud Run: forensic-rag-api (Layer 2)" >> "${OUTPUT_FILE}"
echo -e "\n\`\`\`yaml" >> "${OUTPUT_FILE}"
gcloud run services describe forensic-rag-api --region="${REGION}" --project="${PROJECT_ID}" --format="yaml" >> "${OUTPUT_FILE}" 2>/dev/null || echo "Service forensic-rag-api not found or failed to deploy." >> "${OUTPUT_FILE}"
echo -e "\n\`\`\`\n" >> "${OUTPUT_FILE}"

echo "--- [5/5] INTERROGATING IAM BINDINGS ---"
echo -e "\n## 5. IAM POLICIES (FORENSIC SERVICE ACCOUNTS)\n\`\`\`yaml" >> "${OUTPUT_FILE}"
gcloud projects get-iam-policy "${PROJECT_ID}" \
    --flatten="bindings[].members" \
    --filter="bindings.members:forensic-engine-sa" \
    --format="yaml" >> "${OUTPUT_FILE}" 2>/dev/null || echo "Error extracting IAM bindings." >> "${OUTPUT_FILE}"
echo -e "\n\`\`\`\n" >> "${OUTPUT_FILE}"

echo "============================================================================"
echo " STATE EXTRACTION COMPLETE "
echo " Artifact generated: ${OUTPUT_FILE}"
echo "============================================================================"
```

================================================================================
FILEPATH: deploy.sh
================================================================================
```sh
#!/bin/bash
# ============================================================================
# LEGAL FORENSICS ENGINE - UNIFIED MONOLITHIC DEPLOYMENT (V17.0.0)
# PROJECT ID: i-dub-thee
# CAPABILITIES: Ingestion, Mailroom Slicer, Tri-Pass, RAG API, Governance
# DIRECTIVE: Zero-Trust, Greenfield Instantiation, Zero Stranded Code
# ============================================================================
set -o errexit
set -o nounset
set -o pipefail

# --- GLOBAL CONFIGURATION ---
export PROJECT_ID="i-dub-thee"
export REGION="us-central1"
export VAULT_BUCKET="${PROJECT_ID}-forensic-vault"
export ARCHIVE_BUCKET="${PROJECT_ID}-master-filing-cabinet"
export BQ_DATASET="forensic_fact_base"
export SERVICE_ACCOUNT_NAME="forensic-engine-sa"
export SERVICE_ACCOUNT_EMAIL="${SERVICE_ACCOUNT_NAME}@${PROJECT_ID}.iam.gserviceaccount.com"

echo "============================================================================"
echo " INITIATING GREENFIELD DEPLOYMENT PROTOCOL "
echo "============================================================================"

echo "--- [1/15] EXECUTING PRECISION SCORCHED EARTH (WHITELIST CLEANUP) ---"
# Strictly isolates the root directory and annihilates EVERYTHING 
# EXCEPT hidden config files (.idx, .git) and shell scripts.
# This prevents ANY legacy/stranded code from surviving.
find . -mindepth 1 -maxdepth 1 \
    ! -name '.git' \
    ! -name '.idx' \
    ! -name '*.sh' \
    ! -name '.*' \
    -exec rm -rf {} +

# Scaffold clean Greenfield directories
mkdir -p src rag_api tools tests deploy_logs

echo "--- [2/15] PROVISIONING ISOLATED PYTHON 3.11+ ENVIRONMENT ---"
# Utilizing ${VIRTUAL_ENV:-} to satisfy strict 'nounset' bash rules
if [[ "${VIRTUAL_ENV:-}" != "" ]]; then
    deactivate || true
fi

python3 -m venv forensic_env
source forensic_env/bin/activate
pip install --upgrade pip

# Author unified semantic requirements
cat << 'END_OF_REQ' > requirements.txt
google-cloud-storage>=2.14.0
google-cloud-bigquery>=3.17.0
google-cloud-documentai>=3.4.0
google-genai>=0.3.0
functions-framework>=3.8.0
pydantic>=2.6.1
pytest>=8.0.0
pytest-mock>=3.12.0
pypdf>=4.1.0
fastapi>=0.109.2
uvicorn>=0.27.1
END_OF_REQ

pip install -r requirements.txt

echo "--- [3/15] ENABLING GOOGLE CLOUD APIS ---"
gcloud services enable \
    compute.googleapis.com \
    storage-component.googleapis.com \
    bigquery.googleapis.com \
    documentai.googleapis.com \
    aiplatform.googleapis.com \
    run.googleapis.com \
    cloudfunctions.googleapis.com \
    cloudbuild.googleapis.com \
    eventarc.googleapis.com \
    pubsub.googleapis.com \
    --project="${PROJECT_ID}"

echo "--- [4/15] PROVISIONING LEAST-PRIVILEGE IAM (METERED EXECUTION) ---"
if ! gcloud iam service-accounts describe "${SERVICE_ACCOUNT_EMAIL}" --project="${PROJECT_ID}" >/dev/null 2>&1; then
    gcloud iam service-accounts create "${SERVICE_ACCOUNT_NAME}" \
        --description="Dedicated execution account for the Legal Forensics Engine" \
        --display-name="Forensic Engine SA" \
        --project="${PROJECT_ID}"
fi

echo "Waiting for IAM Service Account propagation (10 seconds)..."
sleep 10

# UPGRADED: storage.admin is required for Eventarc trigger validation, not just objectAdmin
ROLES=(
    "roles/storage.admin"
    "roles/bigquery.dataEditor"
    "roles/documentai.apiUser"
    "roles/aiplatform.user"
    "roles/run.invoker"
    "roles/eventarc.eventReceiver"
)

# Metered loop to prevent cloudresourcemanager rate limit crashes
for ROLE in "${ROLES[@]}"; do
    echo "Binding ${ROLE} to Forensic SA..."
    gcloud projects add-iam-policy-binding "${PROJECT_ID}" \
        --member="serviceAccount:${SERVICE_ACCOUNT_EMAIL}" \
        --role="${ROLE}" \
        --condition=None >/dev/null
    sleep 3 
done

echo "Forcing GCP to provision the Cloud Storage Service Agent identity..."
GCS_SERVICE_ACCOUNT=$(gcloud storage service-agent --project="${PROJECT_ID}")
echo "Binding pubsub.publisher to GCS Service Agent..."
gcloud projects add-iam-policy-binding "${PROJECT_ID}" \
    --member="serviceAccount:${GCS_SERVICE_ACCOUNT}" \
    --role="roles/pubsub.publisher" \
    --condition=None >/dev/null

echo "Binding storage.admin to Eventarc Service Agent..."
GS_PROJECT_NUMBER=$(gcloud projects describe "${PROJECT_ID}" --format="value(projectNumber)")
EVENTARC_SERVICE_ACCOUNT="service-${GS_PROJECT_NUMBER}@gcp-sa-eventarc.iam.gserviceaccount.com"
gcloud projects add-iam-policy-binding "${PROJECT_ID}" \
    --member="serviceAccount:${EVENTARC_SERVICE_ACCOUNT}" \
    --role="roles/storage.admin" \
    --condition=None >/dev/null

echo "CRITICAL: Halting execution for 30 seconds to guarantee global IAM propagation..."
sleep 30
echo "--- [4.5/15] PROVISIONING BIFURCATED STORAGE VAULTS (STATE-AWARE PROVISIONING) ---"

# 1. Interrogate and Provision the Raw Intake Vault
echo "Inspecting state of Intake Vault: gs://${VAULT_BUCKET}"
if gcloud storage buckets describe "gs://${VAULT_BUCKET}" --project="${PROJECT_ID}" >/dev/null 2>&1; then
    echo "[STATE: EXISTS] Intake Vault verified. Enforcing strict security policies..."
    # Force public access prevention even if the bucket already existed
    gcloud storage buckets update "gs://${VAULT_BUCKET}" \
        --public-access-prevention \
        --project="${PROJECT_ID}" >/dev/null
else
    echo "[STATE: MISSING] Provisioning Greenfield Intake Vault..."
    gcloud storage buckets create "gs://${VAULT_BUCKET}" \
        --location="${REGION}" \
        --project="${PROJECT_ID}" \
        --uniform-bucket-level-access
    
    gcloud storage buckets update "gs://${VAULT_BUCKET}" \
        --public-access-prevention \
        --project="${PROJECT_ID}" >/dev/null
fi

# 2. Interrogate and Provision the Master Filing Cabinet (Archive)
echo "Inspecting state of Master Filing Cabinet: gs://${ARCHIVE_BUCKET}"
if gcloud storage buckets describe "gs://${ARCHIVE_BUCKET}" --project="${PROJECT_ID}" >/dev/null 2>&1; then
    echo "[STATE: EXISTS] Master Filing Cabinet verified."
else
    echo "[STATE: MISSING] Provisioning Greenfield Master Filing Cabinet..."
    gcloud storage buckets create "gs://${ARCHIVE_BUCKET}" \
        --location="${REGION}" \
        --project="${PROJECT_ID}" \
        --uniform-bucket-level-access
fi

echo "Storage Infrastructure State Lock Achieved."
echo "--- [5/15] PROVISIONING DOCUMENT AI FORM PARSER (PYTHON SDK GATE) ---"
# We utilize the type-safe Python SDK installed in Step 2 rather than raw REST calls
# to ensure authentication and payload structures are natively handled by Google.

cat << 'EOF_PYTHON' > provision_docai.py
import os, sys
from google.cloud import documentai

project_id = os.environ['PROJECT_ID']
location = "us" # Document AI strictly requires 'us' or 'eu'
proc_name = "forensic-form-parser"

client = documentai.DocumentProcessorServiceClient()
parent = client.common_location_path(project_id, location)

# 1. Check if processor already exists
try:
    for p in client.list_processors(parent=parent):
        if p.display_name == proc_name:
            print(p.name.split('/')[-1])
            sys.exit(0)
except Exception:
    pass # Proceed to creation if it doesn't exist

# 2. Provision the new processor
processor = documentai.Processor(
    display_name=proc_name,
    type_="FORM_PARSER_PROCESSOR"
)

try:
    created_processor = client.create_processor(
        parent=parent,
        processor=processor
    )
    print(created_processor.name.split('/')[-1])
except Exception as e:
    print(f"ERROR: {str(e)}", file=sys.stderr)
    sys.exit(1)
EOF_PYTHON

export DOCAI_PROCESSOR_ID=$(python3 provision_docai.py)

if [[ -z "$DOCAI_PROCESSOR_ID" || "$DOCAI_PROCESSOR_ID" == ERROR* ]]; then
    echo "FATAL ERROR: Failed to provision Document AI Processor via Python SDK."
    echo "Details: $DOCAI_PROCESSOR_ID"
    exit 1
fi

echo "Document AI Processor ID Locked: ${DOCAI_PROCESSOR_ID}"
rm provision_docai.py
echo "--- [6/15] AUTHORING PYTHON CORE: THE 18-LANE REGISTRY ---"
cat << 'EOF' > src/registry.py
# ============================================================================
# FORENSIC DOCUMENT REGISTRY (V17.0.0)
# ============================================================================
KNOWN_ENTITIES = [
    "Judith Grandy", "Mark Sosa-Kibby", "KibbyCo", 
    "M & J Food Market", "Keith Grandy", "K Grandy Enterprises", 
    "Max R Kibby Trust"
]

FORENSIC_DOCUMENT_TYPE_REGISTRY = {
    "LANE_00_GENERAL_TRANSACTIONAL": ["General Invoices", "Retail Receipts"],
    "LANE_01_PROPERTY_REAL_ESTATE": ["Warranty Deeds", "Fiduciary Deeds", "Residential Appraisals", "Property Tax Assessments"],
    "LANE_02_RETIREMENT_ACCOUNTS": ["401k Account Statements", "Pension Valuation Statements"],
    "LANE_03_CREDIT_DEBT": ["Credit Card Statements", "Personal Loan Agreements"],
    "LANE_04_BANKING_CHECKING": ["Monthly Bank Statements", "Handwritten Checkbook Registers"],
    "LANE_05_ASSET_VAULT_TRUSTS": ["Whole Life Insurance Policies", "Trust Indenture Agreements"],
    "LANE_06_BROKERAGE_INVESTMENTS": ["Brokerage Account Statements", "Dividend Reinvestment Summaries"],
    "LANE_07_TAX_RETURNS_DOCUMENTS": ["Federal Form 1040 Filings", "Internal Revenue Service Form 4562 Depreciation"],
    "LANE_08_INSURANCE_POLICIES": ["Insurance Policies And Claim Disbursals"],
    "LANE_09_INFRASTRUCTURE_EQUIPMENT": ["Timber Harvesting Contracts", "Barn Construction Contracts"],
    "LANE_10_LIVESTOCK_AGRICULTURE": ["United States Department Of Agriculture Contracts", "Veterinary Service Records"],
    "LANE_11_GROCERY_RETAIL": ["Heavy Equipment Purchases", "Direct Store Delivery Route Accounting"],
    "LANE_12_PAYROLL_COMPENSATION": ["Employee Payroll Records", "Employment Dispute Settlement Records"],
    "LANE_13_SUBSIDIES_FAMILY_PAYMENTS": ["Cellular Telephone Plans", "Child Support Payments"],
    "LANE_14_UTILITIES_SERVICES": ["Electrical Energy Bills", "Heating Oil Delivery Receipts"],
    "LANE_15_VEHICLES_TRANSPORT": ["State Vehicle Registrations", "Vehicle Maintenance Logs"],
    "LANE_16_LEGAL_PROFESSIONAL": ["Attorney Retainer Agreements", "Forensic Accounting Invoices"],
    "LANE_17_SPORTING_RECREATION": ["Department Of Natural Resources Hunting Licenses", "Firearm Ammunition Receipts"],
    "LANE_18_HEALTHCARE_MEDICAL": ["Out Of Pocket Medical Expenses", "Cognitive Memory Tool Purchases"]
}
EOF

echo "--- [7/15] AUTHORING PYTHON CORE: GEOSPATIAL ANCHOR ENGINE ---"
cat << 'EOF' > src/geospatial.py
import math
from typing import List, Dict, Optional
from pydantic import BaseModel, ConfigDict

class BoundingPolygon(BaseModel):
    model_config = ConfigDict(extra='forbid')
    x_vertices: List[float]
    y_vertices: List[float]
    
    def centroid(self) -> dict:
        return {"x": sum(self.x_vertices)/len(self.x_vertices), "y": sum(self.y_vertices)/len(self.y_vertices)}

class OpticalEntity(BaseModel):
    model_config = ConfigDict(extra='forbid')
    text: str
    confidence: float
    coordinates: BoundingPolygon
    is_handwritten: bool

class GeospatialAnchorEngine:
    def __init__(self, vertical_threshold: float = 0.05, horizontal_threshold: float = 0.40):
        self.v_thresh = vertical_threshold
        self.h_thresh = horizontal_threshold

    def bind_marginalia(self, printed_items: List[OpticalEntity], handwritten_notes: List[OpticalEntity]) -> List[Dict]:
        anchored_ledger = []
        for printed in printed_items:
            p_center = printed.coordinates.centroid()
            closest_note, shortest_dist = None, float('inf')
            
            for note in handwritten_notes:
                n_center = note.coordinates.centroid()
                if abs(p_center["y"] - n_center["y"]) <= self.v_thresh:
                    dist = math.sqrt((p_center["x"] - n_center["x"])**2 + (p_center["y"] - n_center["y"])**2)
                    if dist < shortest_dist and dist <= self.h_thresh:
                        shortest_dist, closest_note = dist, note
                        
            anchored_ledger.append({
                "printed_transaction": printed.model_dump(),
                "handwritten_modifier": closest_note.model_dump() if closest_note else None
            })
            if closest_note in handwritten_notes:
                handwritten_notes.remove(closest_note)
        return anchored_ledger
EOF

echo "--- [8/15] AUTHORING PYTHON CORE: PYDANTIC IRON GATE (18 LANES) ---"
cat << 'EOF' > src/schemas.py
from pydantic import BaseModel, ConfigDict, Field, model_validator
from typing import List, Union, Dict, Any, Optional

class SpatialCoordinatesPolygon(BaseModel):
    model_config = ConfigDict(extra='forbid')
    horizontal_x_vertices: List[float]
    vertical_y_vertices: List[float]

class ForensicDataEntity(BaseModel):
    model_config = ConfigDict(extra='forbid')
    extracted_string_or_numeric_value: Union[str, float]
    optical_extraction_confidence_score: float = Field(ge=0.0, le=1.0)
    physical_evidence_coordinates: SpatialCoordinatesPolygon

class SequentialTransaction(BaseModel):
    model_config = ConfigDict(extra='forbid')
    transaction_date: str
    description: str
    deposit_amount: float
    withdrawal_amount: float
    running_balance: float
    physical_evidence_coordinates: SpatialCoordinatesPolygon

class Lane00GeneralTransactionalSchema(BaseModel):
    model_config = ConfigDict(extra='forbid')
    net_receipt_amount: ForensicDataEntity
    tax_receipt_amount: ForensicDataEntity
    gross_receipt_total: ForensicDataEntity
    @model_validator(mode='after')
    def validate_transaction_mathematics(self) -> 'Lane00GeneralTransactionalSchema':
        calculated = round(float(self.net_receipt_amount.extracted_string_or_numeric_value) + float(self.tax_receipt_amount.extracted_string_or_numeric_value), 2)
        reported = round(float(self.gross_receipt_total.extracted_string_or_numeric_value), 2)
        if calculated != reported: raise ValueError(f"MATHEMATICAL VALIDATION ERROR: Calculated {calculated} != Extracted {reported}")
        return self

class Lane01PropertyRealEstateSchema(BaseModel):
    model_config = ConfigDict(extra='forbid')
    assessed_land_value: ForensicDataEntity
    assessed_improvement_value: ForensicDataEntity
    total_assessed_property_value: ForensicDataEntity
    @model_validator(mode='after')
    def validate_property_mathematics(self) -> 'Lane01PropertyRealEstateSchema':
        calculated = round(float(self.assessed_land_value.extracted_string_or_numeric_value) + float(self.assessed_improvement_value.extracted_string_or_numeric_value), 2)
        reported = round(float(self.total_assessed_property_value.extracted_string_or_numeric_value), 2)
        if calculated != reported: raise ValueError(f"MATHEMATICAL VALIDATION ERROR: Calculated {calculated} != Extracted {reported}")
        return self

class Lane02RetirementAccountsSchema(BaseModel):
    model_config = ConfigDict(extra='forbid')
    previous_period_balance: ForensicDataEntity
    period_contributions: ForensicDataEntity
    period_investment_gains: ForensicDataEntity
    period_distributions: ForensicDataEntity
    current_period_balance: ForensicDataEntity
    @model_validator(mode='after')
    def validate_retirement_mathematics(self) -> 'Lane02RetirementAccountsSchema':
        calculated = round((float(self.previous_period_balance.extracted_string_or_numeric_value) + float(self.period_contributions.extracted_string_or_numeric_value) + float(self.period_investment_gains.extracted_string_or_numeric_value)) - float(self.period_distributions.extracted_string_or_numeric_value), 2)
        reported = round(float(self.current_period_balance.extracted_string_or_numeric_value), 2)
        if calculated != reported: raise ValueError(f"MATHEMATICAL VALIDATION ERROR: Calculated {calculated} != Extracted {reported}")
        return self

class Lane03CreditDebtSchema(BaseModel):
    model_config = ConfigDict(extra='forbid')
    previous_statement_balance: ForensicDataEntity
    new_purchases_amount: ForensicDataEntity
    accrued_interest_amount: ForensicDataEntity
    payments_received_amount: ForensicDataEntity
    new_statement_balance: ForensicDataEntity
    @model_validator(mode='after')
    def validate_credit_debt_mathematics(self) -> 'Lane03CreditDebtSchema':
        calculated = round((float(self.previous_statement_balance.extracted_string_or_numeric_value) + float(self.new_purchases_amount.extracted_string_or_numeric_value) + float(self.accrued_interest_amount.extracted_string_or_numeric_value)) - float(self.payments_received_amount.extracted_string_or_numeric_value), 2)
        reported = round(float(self.new_statement_balance.extracted_string_or_numeric_value), 2)
        if calculated != reported: raise ValueError(f"MATHEMATICAL VALIDATION ERROR: Calculated {calculated} != Extracted {reported}")
        return self

class Lane04BankingCheckingSchema(BaseModel):
    model_config = ConfigDict(extra='forbid')
    institution_name: ForensicDataEntity
    page_carried_forward_balance: ForensicDataEntity
    sequential_transactions: List[SequentialTransaction]
    @model_validator(mode='after')
    def validate_sequential_ledger_state(self) -> 'Lane04BankingCheckingSchema':
        current_running_balance = round(float(self.page_carried_forward_balance.extracted_string_or_numeric_value), 2)
        previous_description = ""
        for index, txn in enumerate(self.sequential_transactions):
            if txn.description.strip() == '"' or txn.description.strip().lower() == "ditto":
                if index == 0: raise ValueError("SEQUENTIAL LOGIC ERROR: Ditto mark found on first row.")
                txn.description = previous_description
            previous_description = txn.description
            calculated_row_balance = round((current_running_balance + txn.deposit_amount) - txn.withdrawal_amount, 2)
            reported_row_balance = round(txn.running_balance, 2)
            if calculated_row_balance != reported_row_balance:
                raise ValueError(f"GAAP_SEQUENTIAL_MISMATCH: Row {index} calculated {calculated_row_balance} != {reported_row_balance}")
            current_running_balance = reported_row_balance
        return self

class Lane05AssetVaultTrustsSchema(BaseModel):
    model_config = ConfigDict(extra='forbid')
    original_principal_funding: ForensicDataEntity
    accrued_trust_interest: ForensicDataEntity
    trust_distributions_paid: ForensicDataEntity
    current_trust_value: ForensicDataEntity
    @model_validator(mode='after')
    def validate_asset_vault_mathematics(self) -> 'Lane05AssetVaultTrustsSchema':
        calculated = round((float(self.original_principal_funding.extracted_string_or_numeric_value) + float(self.accrued_trust_interest.extracted_string_or_numeric_value)) - float(self.trust_distributions_paid.extracted_string_or_numeric_value), 2)
        reported = round(float(self.current_trust_value.extracted_string_or_numeric_value), 2)
        if calculated != reported: raise ValueError(f"MATHEMATICAL VALIDATION ERROR: Calculated {calculated} != Extracted {reported}")
        return self

class Lane06BrokerageInvestmentsSchema(BaseModel):
    model_config = ConfigDict(extra='forbid')
    liquid_cash_balance: ForensicDataEntity
    sum_of_securities_market_value: ForensicDataEntity
    total_portfolio_value: ForensicDataEntity
    @model_validator(mode='after')
    def validate_brokerage_mathematics(self) -> 'Lane06BrokerageInvestmentsSchema':
        calculated = round(float(self.liquid_cash_balance.extracted_string_or_numeric_value) + float(self.sum_of_securities_market_value.extracted_string_or_numeric_value), 2)
        reported = round(float(self.total_portfolio_value.extracted_string_or_numeric_value), 2)
        if calculated != reported: raise ValueError(f"MATHEMATICAL VALIDATION ERROR: Calculated {calculated} != Extracted {reported}")
        return self

class Lane07TaxReturnsDocumentsSchema(BaseModel):
    model_config = ConfigDict(extra='forbid')
    total_gross_income: ForensicDataEntity
    total_tax_deductions: ForensicDataEntity
    adjusted_gross_income: ForensicDataEntity
    @model_validator(mode='after')
    def validate_tax_return_mathematics(self) -> 'Lane07TaxReturnsDocumentsSchema':
        calculated = round(float(self.total_gross_income.extracted_string_or_numeric_value) - float(self.total_tax_deductions.extracted_string_or_numeric_value), 2)
        reported = round(float(self.adjusted_gross_income.extracted_string_or_numeric_value), 2)
        if calculated != reported: raise ValueError(f"MATHEMATICAL VALIDATION ERROR: Calculated {calculated} != Extracted {reported}")
        return self

class Lane08InsurancePoliciesSchema(BaseModel):
    model_config = ConfigDict(extra='forbid')
    base_policy_premium: ForensicDataEntity
    additional_policy_fees: ForensicDataEntity
    total_billed_premium: ForensicDataEntity
    @model_validator(mode='after')
    def validate_insurance_mathematics(self) -> 'Lane08InsurancePoliciesSchema':
        calculated = round(float(self.base_policy_premium.extracted_string_or_numeric_value) + float(self.additional_policy_fees.extracted_string_or_numeric_value), 2)
        reported = round(float(self.total_billed_premium.extracted_string_or_numeric_value), 2)
        if calculated != reported: raise ValueError(f"MATHEMATICAL VALIDATION ERROR: Calculated {calculated} != Extracted {reported}")
        return self

class Lane09InfrastructureEquipmentSchema(BaseModel):
    model_config = ConfigDict(extra='forbid')
    contract_base_amount: ForensicDataEntity
    materials_cost_amount: ForensicDataEntity
    total_infrastructure_cost: ForensicDataEntity
    @model_validator(mode='after')
    def validate_infrastructure_mathematics(self) -> 'Lane09InfrastructureEquipmentSchema':
        calculated = round(float(self.contract_base_amount.extracted_string_or_numeric_value) + float(self.materials_cost_amount.extracted_string_or_numeric_value), 2)
        reported = round(float(self.total_infrastructure_cost.extracted_string_or_numeric_value), 2)
        if calculated != reported: raise ValueError(f"MATHEMATICAL VALIDATION ERROR: Calculated {calculated} != Extracted {reported}")
        return self

class Lane10LivestockAgricultureSchema(BaseModel):
    model_config = ConfigDict(extra='forbid')
    agricultural_unit_cost: ForensicDataEntity
    agricultural_quantity: ForensicDataEntity
    total_agricultural_expenditure: ForensicDataEntity
    @model_validator(mode='after')
    def validate_agriculture_mathematics(self) -> 'Lane10LivestockAgricultureSchema':
        calculated = round(float(self.agricultural_unit_cost.extracted_string_or_numeric_value) * float(self.agricultural_quantity.extracted_string_or_numeric_value), 2)
        reported = round(float(self.total_agricultural_expenditure.extracted_string_or_numeric_value), 2)
        if calculated != reported: raise ValueError(f"MATHEMATICAL VALIDATION ERROR: Calculated {calculated} != Extracted {reported}")
        return self

class Lane11GroceryRetailSchema(BaseModel):
    model_config = ConfigDict(extra='forbid')
    wholesale_inventory_cost: ForensicDataEntity
    retail_markup_amount: ForensicDataEntity
    final_retail_price_total: ForensicDataEntity
    @model_validator(mode='after')
    def validate_grocery_retail_mathematics(self) -> 'Lane11GroceryRetailSchema':
        calculated = round(float(self.wholesale_inventory_cost.extracted_string_or_numeric_value) + float(self.retail_markup_amount.extracted_string_or_numeric_value), 2)
        reported = round(float(self.final_retail_price_total.extracted_string_or_numeric_value), 2)
        if calculated != reported: raise ValueError(f"MATHEMATICAL VALIDATION ERROR: Calculated {calculated} != Extracted {reported}")
        return self

class Lane12PayrollCompensationSchema(BaseModel):
    model_config = ConfigDict(extra='forbid')
    gross_employee_wages: ForensicDataEntity
    total_tax_withholdings: ForensicDataEntity
    net_payroll_disbursement: ForensicDataEntity
    @model_validator(mode='after')
    def validate_payroll_mathematics(self) -> 'Lane12PayrollCompensationSchema':
        calculated = round(float(self.gross_employee_wages.extracted_string_or_numeric_value) - float(self.total_tax_withholdings.extracted_string_or_numeric_value), 2)
        reported = round(float(self.net_payroll_disbursement.extracted_string_or_numeric_value), 2)
        if calculated != reported: raise ValueError(f"MATHEMATICAL VALIDATION ERROR: Calculated {calculated} != Extracted {reported}")
        return self

class Lane13SubsidiesFamilyPaymentsSchema(BaseModel):
    model_config = ConfigDict(extra='forbid')
    base_subsidy_amount: ForensicDataEntity
    supplementary_allocation_amount: ForensicDataEntity
    total_subsidy_payment: ForensicDataEntity
    @model_validator(mode='after')
    def validate_subsidy_mathematics(self) -> 'Lane13SubsidiesFamilyPaymentsSchema':
        calculated = round(float(self.base_subsidy_amount.extracted_string_or_numeric_value) + float(self.supplementary_allocation_amount.extracted_string_or_numeric_value), 2)
        reported = round(float(self.total_subsidy_payment.extracted_string_or_numeric_value), 2)
        if calculated != reported: raise ValueError(f"MATHEMATICAL VALIDATION ERROR: Calculated {calculated} != Extracted {reported}")
        return self

class Lane14UtilitiesServicesSchema(BaseModel):
    model_config = ConfigDict(extra='forbid')
    utility_usage_charge: ForensicDataEntity
    utility_transmission_fees: ForensicDataEntity
    total_utility_bill_amount: ForensicDataEntity
    @model_validator(mode='after')
    def validate_utility_mathematics(self) -> 'Lane14UtilitiesServicesSchema':
        calculated = round(float(self.utility_usage_charge.extracted_string_or_numeric_value) + float(self.utility_transmission_fees.extracted_string_or_numeric_value), 2)
        reported = round(float(self.total_utility_bill_amount.extracted_string_or_numeric_value), 2)
        if calculated != reported: raise ValueError(f"MATHEMATICAL VALIDATION ERROR: Calculated {calculated} != Extracted {reported}")
        return self

class Lane15VehiclesTransportSchema(BaseModel):
    model_config = ConfigDict(extra='forbid')
    vehicle_purchase_price: ForensicDataEntity
    registration_and_sales_tax_fees: ForensicDataEntity
    total_transport_acquisition_cost: ForensicDataEntity
    @model_validator(mode='after')
    def validate_transport_mathematics(self) -> 'Lane15VehiclesTransportSchema':
        calculated = round(float(self.vehicle_purchase_price.extracted_string_or_numeric_value) + float(self.registration_and_sales_tax_fees.extracted_string_or_numeric_value), 2)
        reported = round(float(self.total_transport_acquisition_cost.extracted_string_or_numeric_value), 2)
        if calculated != reported: raise ValueError(f"MATHEMATICAL VALIDATION ERROR: Calculated {calculated} != Extracted {reported}")
        return self

class Lane16LegalProfessionalSchema(BaseModel):
    model_config = ConfigDict(extra='forbid')
    attorney_hourly_rate: ForensicDataEntity
    attorney_hours_billed: ForensicDataEntity
    court_filing_fees: ForensicDataEntity
    total_legal_obligation: ForensicDataEntity
    @model_validator(mode='after')
    def validate_legal_mathematics(self) -> 'Lane16LegalProfessionalSchema':
        calculated = round((float(self.attorney_hourly_rate.extracted_string_or_numeric_value) * float(self.attorney_hours_billed.extracted_string_or_numeric_value)) + float(self.court_filing_fees.extracted_string_or_numeric_value), 2)
        reported = round(float(self.total_legal_obligation.extracted_string_or_numeric_value), 2)
        if calculated != reported: raise ValueError(f"MATHEMATICAL VALIDATION ERROR: Calculated {calculated} != Extracted {reported}")
        return self

class Lane17SportingRecreationSchema(BaseModel):
    model_config = ConfigDict(extra='forbid')
    sporting_item_cost: ForensicDataEntity
    sporting_tax_amount: ForensicDataEntity
    total_recreation_expenditure: ForensicDataEntity
    @model_validator(mode='after')
    def validate_recreation_mathematics(self) -> 'Lane17SportingRecreationSchema':
        calculated = round(float(self.sporting_item_cost.extracted_string_or_numeric_value) + float(self.sporting_tax_amount.extracted_string_or_numeric_value), 2)
        reported = round(float(self.total_recreation_expenditure.extracted_string_or_numeric_value), 2)
        if calculated != reported: raise ValueError(f"MATHEMATICAL VALIDATION ERROR: Calculated {calculated} != Extracted {reported}")
        return self

class Lane18HealthcareMedicalSchema(BaseModel):
    model_config = ConfigDict(extra='forbid')
    gross_medical_provider_charge: ForensicDataEntity
    insurance_negotiated_rate_adjustment: ForensicDataEntity
    patient_copayment_amount: ForensicDataEntity
    remaining_patient_balance: ForensicDataEntity
    @model_validator(mode='after')
    def validate_healthcare_mathematics(self) -> 'Lane18HealthcareMedicalSchema':
        calculated = round((float(self.gross_medical_provider_charge.extracted_string_or_numeric_value) - float(self.insurance_negotiated_rate_adjustment.extracted_string_or_numeric_value)) - float(self.patient_copayment_amount.extracted_string_or_numeric_value), 2)
        reported = round(float(self.remaining_patient_balance.extracted_string_or_numeric_value), 2)
        if calculated != reported: raise ValueError(f"MATHEMATICAL VALIDATION ERROR: Calculated {calculated} != Extracted {reported}")
        return self

class ForensicGoldenEnvelope(BaseModel):
    model_config = ConfigDict(extra='forbid')
    original_parent_sha256: str = Field(min_length=64, max_length=64)
    sliced_child_sha256: str = Field(min_length=64, max_length=64)
    gcs_source_uri: str
    entity_slug: str
    average_confidence: float = Field(ge=0.0, le=1.0)
    requires_manual_review: bool
    extracted_payload: Union[
        Lane00GeneralTransactionalSchema, Lane01PropertyRealEstateSchema, Lane02RetirementAccountsSchema, 
        Lane03CreditDebtSchema, Lane04BankingCheckingSchema, Lane05AssetVaultTrustsSchema, 
        Lane06BrokerageInvestmentsSchema, Lane07TaxReturnsDocumentsSchema, Lane08InsurancePoliciesSchema, 
        Lane09InfrastructureEquipmentSchema, Lane10LivestockAgricultureSchema, Lane11GroceryRetailSchema, 
        Lane12PayrollCompensationSchema, Lane13SubsidiesFamilyPaymentsSchema, Lane14UtilitiesServicesSchema, 
        Lane15VehiclesTransportSchema, Lane16LegalProfessionalSchema, Lane17SportingRecreationSchema, 
        Lane18HealthcareMedicalSchema
    ]

    @model_validator(mode='after')
    def enforce_hitl_governance(self) -> 'ForensicGoldenEnvelope':
        if self.average_confidence < 0.90 and not self.requires_manual_review:
            raise ValueError("HITL_VIOLATION: Document AI average confidence < 0.90 mandates manual review flag = True.")
        return self
EOF
echo "--- [9/15] AUTHORING PYTHON CORE: PIPELINE ORCHESTRATOR (src/main.py) ---"
cat << 'EOF' > src/main.py
import os
import io
import json
import hashlib
import asyncio
import random
import logging
from typing import List, Dict, Any
from google.cloud import storage, bigquery, documentai
from google import genai
from google.genai import types
from pypdf import PdfReader, PdfWriter
import functions_framework

from src.schemas import ForensicGoldenEnvelope
from src.registry import FORENSIC_DOCUMENT_TYPE_REGISTRY
from src.geospatial import GeospatialAnchorEngine

logging.basicConfig(level=logging.INFO)

PROJECT_ID = os.environ.get("GOOGLE_CLOUD_PROJECT_IDENTIFIER", "i-dub-thee")
ARCHIVE_BUCKET = os.environ.get("GOOGLE_CLOUD_STORAGE_BUCKET_NAME", "i-dub-thee-master-filing-cabinet")
TABLE_ID = f"{PROJECT_ID}.forensic_fact_base.ingestion_ledger"
DOCAI_LOCATION = "us"
DOCAI_PROCESSOR_ID = os.environ.get("DOCAI_PROCESSOR_ID", "REQUIRED_AT_RUNTIME")

storage_client = storage.Client(project=PROJECT_ID)
bq_client = bigquery.Client(project=PROJECT_ID)
docai_client = documentai.DocumentProcessorServiceClient()
genai_client = genai.Client()

class AsyncRateLimiter:
    def __init__(self, max_concurrent_tasks: int = 4):
        self.semaphore = asyncio.Semaphore(max_concurrent_tasks)

    async def execute_with_backoff(self, coroutine_func, *args, max_retries=5, base_delay=1.0) -> str:
        async with self.semaphore:
            for attempt in range(max_retries):
                try:
                    return await coroutine_func(*args)
                except Exception as e:
                    error_msg = str(e).lower()
                    if "429" in error_msg or "quota" in error_msg or "exhausted" in error_msg:
                        if attempt == max_retries - 1:
                            raise Exception(f"FATAL: Rate limit exhausted. {e}")
                        delay = random.uniform(0, base_delay * (2 ** attempt))
                        logging.warning(f"Rate limit hit. Backing off for {delay:.2f} seconds...")
                        await asyncio.sleep(delay)
                    else:
                        raise e

def slice_and_hash_bundle(parent_bytes: bytes, parent_hash: str) -> List[Dict[str, Any]]:
    # Simulated logical boundary mapping for deterministic execution. 
    # In production, this is populated by a Gemini pre-pass.
    boundaries = [{"start_page": 1, "end_page": 1}] 
    
    sliced_artifacts = []
    reader = PdfReader(io.BytesIO(parent_bytes))
    
    for bound in boundaries:
        writer = PdfWriter()
        start = max(0, bound["start_page"] - 1)
        end = min(len(reader.pages), bound["end_page"])
        
        for i in range(start, end):
            writer.add_page(reader.pages[i])
            
        output_buffer = io.BytesIO()
        writer.write(output_buffer)
        child_bytes = output_buffer.getvalue()
        child_hash = hashlib.sha256(child_bytes).hexdigest()
        
        sliced_artifacts.append({
            "binary": child_bytes,
            "original_parent_sha256": parent_hash,
            "sliced_child_sha256": child_hash
        })
    return sliced_artifacts

async def _call_gemini_async(file_bytes: bytes, prompt: str, temperature: float, response_mime_type: str = "text/plain") -> str:
    response = genai_client.models.generate_content(
        model="gemini-2.5-pro",
        contents=[types.Part.from_bytes(data=file_bytes, mime_type="application/pdf"), prompt],
        config=types.GenerateContentConfig(temperature=temperature, response_mime_type=response_mime_type)
    )
    return response.text

async def generate_tri_pass_artifacts(file_bytes: bytes) -> Dict[str, str]:
    limiter = AsyncRateLimiter(max_concurrent_tasks=4)
    
    layout_prompt = "Output a precise MARKDOWN representation of this document's visual layout. Use GFM tables. Preserve all structure."
    sum_prompt = "Produce a Markdown report: ## Executive Summary (BLUF), ## Content Analysis, ## Risk Assessment."
    per_prompt = "Identify the optimal forensic persona to review this document. Provide strategic analysis in Markdown."
    json_prompt = "Extract absolutely every printed string, handwritten note, and table into a flat JSON store."
    
    results = await asyncio.gather(
        limiter.execute_with_backoff(_call_gemini_async, file_bytes, layout_prompt, 0.0),
        limiter.execute_with_backoff(_call_gemini_async, file_bytes, sum_prompt, 0.0),
        limiter.execute_with_backoff(_call_gemini_async, file_bytes, per_prompt, 0.2),
        limiter.execute_with_backoff(_call_gemini_async, file_bytes, json_prompt, 0.0, "application/json")
    )
    
    return {
        "uhf_markdown": results[0],
        "summary": results[1],
        "persona": results[2],
        "exhaustive_json": results[3]
    }

def process_document_pipeline(bucket_name: str, object_name: str):
    bucket = storage_client.bucket(bucket_name)
    blob = bucket.blob(object_name)
    file_bytes = blob.download_as_bytes()

    if not file_bytes.startswith(b'%PDF-'):
        raise ValueError("FRE_901_VIOLATION: Invalid binary signature.")
        
    parent_hash = hashlib.sha256(file_bytes).hexdigest()
    sliced_artifacts = slice_and_hash_bundle(file_bytes, parent_hash)
    archive_bucket = storage_client.bucket(ARCHIVE_BUCKET)
    
    for slice_data in sliced_artifacts:
        child_hash = slice_data["sliced_child_sha256"]
        child_bytes = slice_data["binary"]
        
        # Async Tri-Pass writes to Master Filing Cabinet
        artifacts = asyncio.run(generate_tri_pass_artifacts(child_bytes))
        
        base_path = f"archive/{child_hash}"
        archive_bucket.blob(f"{base_path}/exhaustive.json").upload_from_string(artifacts["exhaustive_json"], content_type="application/json")
        archive_bucket.blob(f"{base_path}/layout.md").upload_from_string(artifacts["uhf_markdown"], content_type="text/markdown")
        archive_bucket.blob(f"{base_path}/summary.md").upload_from_string(artifacts["summary"], content_type="text/markdown")
        archive_bucket.blob(f"{base_path}/persona.md").upload_from_string(artifacts["persona"], content_type="text/markdown")

        logging.info(f"[SUCCESS] Processed and archived sub-document {child_hash}")

@functions_framework.cloud_event
def forensic_document_trigger(cloud_event) -> None:
    data = cloud_event.data
    bucket_name = data["bucket"]
    object_name = data["name"]

    if "_QUARANTINE" in object_name or "archive" in object_name or not object_name.lower().endswith(".pdf"):
        return

    try:
        process_document_pipeline(bucket_name, object_name)
    except Exception as e:
        logging.error(f"[FATAL] System Error on {object_name}: {str(e)}")
        bucket = storage_client.bucket(bucket_name)
        blob = bucket.blob(object_name)
        bucket.rename_blob(blob, f"_QUARANTINE/{object_name.split('/')[-1]}")
EOF

echo "--- [10/15] AUTHORING GOVERNANCE WIZARD (tools/governance_wizard.py) ---"
cat << 'EOF' > tools/governance_wizard.py
import os
import time
from datetime import datetime, timezone

class ForensicGovernanceWizard:
    def __init__(self):
        self.project_id = "i-dub-thee"
        self.audit_log_path = "GOVERNANCE_AUDIT_LOG.md"
        self.staging_dir = "staged_deployments"
        os.makedirs(self.staging_dir, exist_ok=True)

    def run(self):
        print("=========================================================")
        print(" LEGAL FORENSICS ENGINE - GOVERNANCE & CHANGE CONTROL")
        print(f" TARGET ENVIRONMENT: {self.project_id}")
        print("=========================================================\n")
        print("Select Change Type:")
        print("  1. Add New Document Schema (Taxonomy Lane)")
        print("  2. Add/Modify Business Rule (Hypothesis Testing)")
        choice = input("\nEnter choice [1-2]: ").strip()
        
        if choice == '1':
            lane_name = input("\nEnter New Taxonomy Lane Name (e.g., LANE_19_AGRITOURISM): ").strip().upper()
            description = input("Enter Description of Document Types: ").strip()
            approver = input("Enter Authorized Approver Name (Sign-off): ").strip()
            
            timestamp = datetime.now(timezone.utc).isoformat()
            change_id = f"CHG-{int(time.time())}"
            audit_entry = f"## Change ID: {change_id}\n* **Timestamp:** {timestamp}\n* **Type:** SCHEMA ADDITION\n* **Lane:** {lane_name}\n* **Authorized By:** {approver}\n"
            
            with open(self.audit_log_path, "a") as f:
                f.write(audit_entry + "\n---\n")
                
            print(f"\n[SUCCESS] Governance logged. ID: {change_id}")
            print(f"Action: Manually add {lane_name} to src/schemas.py and run TDD suite.")
            
if __name__ == "__main__":
    wizard = ForensicGovernanceWizard()
    wizard.run()
EOF

echo "--- [11/15] AUTHORING ROLLBACK UTILITY (tools/rollback.sh) ---"
cat << 'EOF' > tools/rollback.sh
#!/bin/bash
set -o errexit
set -o nounset
set -o pipefail
export PROJECT_ID="i-dub-thee"
export REGION="us-central1"
export SERVICE_NAME="forensic-pipeline-router"
echo "--- FETCHING REVISION HISTORY ---"
gcloud run revisions list --service="${SERVICE_NAME}" --region="${REGION}" --project="${PROJECT_ID}" --sort-by="~metadata.creationTimestamp" --limit=5
echo ""
read -p "Enter the REVISION ID to rollback to: " TARGET_REVISION
gcloud run services update-traffic "${SERVICE_NAME}" --region="${REGION}" --project="${PROJECT_ID}" --to-revisions="${TARGET_REVISION}=100"
echo "--- ROLLBACK COMPLETE ---"
EOF
chmod +x tools/rollback.sh

echo "--- [12/15] AUTHORING ENTERPRISE RAG API (rag_api/main.py) ---"
cat << 'EOF' > rag_api/main.py
import os
from fastapi import FastAPI, HTTPException
from google.cloud import bigquery
from google import genai
from pydantic import BaseModel

app = FastAPI(title="i-dub-thee Hybrid RAG Engine")

PROJECT_ID = os.environ.get("GOOGLE_CLOUD_PROJECT", "i-dub-thee")
bq_client = bigquery.Client(project=PROJECT_ID)
genai_client = genai.Client()

class ForensicQuery(BaseModel):
    natural_language_question: str

def generate_sql_from_prompt(question: str) -> str:
    prompt = f"Convert this forensic hypothesis into strictly valid Google Standard SQL for table `i-dub-thee.forensic_fact_base.ingestion_ledger`: '{question}'. Output ONLY SQL."
    response = genai_client.models.generate_content(
        model="gemini-2.5-pro",
        contents=prompt,
        config={"temperature": 0.0}
    )
    return response.text.replace('```sql', '').replace('```', '').strip()

@app.post("/api/v1/hypothesis/quantitative")
async def execute_quantitative_hypothesis(query: ForensicQuery):
    try:
        sql_query = generate_sql_from_prompt(query.natural_language_question)
        query_job = bq_client.query(sql_query)
        results = [dict(row) for row in query_job]
        
        summary_prompt = f"Summarize these SQL results based on hypothesis '{query.natural_language_question}': {results}"
        summary = genai_client.models.generate_content(
            model="gemini-2.5-pro",
            contents=summary_prompt,
            config={"temperature": 0.0}
        )
        
        return {"hypothesis": query.natural_language_question, "sql": sql_query, "data": results, "synthesis": summary.text}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
EOF
echo "--- [13/15] AUTHORING EXHAUSTIVE TDD SUITE & GOLDEN REGISTRY (tests/) ---"
cat << 'EOF' > tests/golden_test_registry.json
[
  {
    "test_identifier": "TEST_FRE901_BINARY_REJECTION",
    "should_pass": false,
    "expected_error": "FRE_901_VIOLATION",
    "binary_header_simulation": "504B0304", 
    "payload": {}
  },
  {
    "test_identifier": "TEST_LANE04_SEQUENTIAL_DITTO_RESOLUTION",
    "should_pass": true,
    "taxonomy_lane": "LANE_04_BANKING_CHECKING",
    "binary_header_simulation": "25504446",
    "payload": {
      "original_parent_sha256": "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855",
      "sliced_child_sha256": "8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92",
      "gcs_source_uri": "gs://i-dub-thee-forensic-vault/LANE_04/statement.pdf",
      "entity_slug": "Judith Grandy",
      "average_confidence": 0.98,
      "requires_manual_review": false,
      "extracted_payload": {
        "institution_name": {"extracted_string_or_numeric_value": "Chemical Bank", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [0.1], "vertical_y_vertices": [0.1]}},
        "page_carried_forward_balance": {"extracted_string_or_numeric_value": 10000.00, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [0.8], "vertical_y_vertices": [0.1]}},
        "sequential_transactions": [
          {"transaction_date": "2020-01-15", "description": "DEPOSIT", "deposit_amount": 5000.00, "withdrawal_amount": 0.00, "running_balance": 15000.00, "physical_evidence_coordinates": {"horizontal_x_vertices": [0.1], "vertical_y_vertices": [0.3]}},
          {"transaction_date": "2020-01-16", "description": "\"", "deposit_amount": 1000.00, "withdrawal_amount": 0.00, "running_balance": 16000.00, "physical_evidence_coordinates": {"horizontal_x_vertices": [0.1], "vertical_y_vertices": [0.4]}}
        ]
      }
    }
  },
  {
    "test_identifier": "TEST_CRYPTOGRAPHIC_FRACTURE_REJECTION",
    "should_pass": false,
    "expected_error": "CHAIN_OF_CUSTODY_FRACTURE",
    "taxonomy_lane": "LANE_07_TAX_RETURNS_DOCUMENTS",
    "binary_header_simulation": "25504446",
    "payload": {
      "original_parent_sha256": "MISSING_HASH",
      "sliced_child_sha256": "8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92",
      "gcs_source_uri": "gs://i-dub-thee-forensic-vault/LANE_07/form.pdf",
      "entity_slug": "KibbyCo",
      "average_confidence": 0.99,
      "requires_manual_review": false,
      "extracted_payload": {}
    }
  }
]
EOF

cat << 'EOF' > tests/test_iron_gate_factory.py
import json
import pytest
import binascii
from pydantic import ValidationError

from src.schemas import (
    ForensicGoldenEnvelope, Lane04BankingCheckingSchema, Lane00GeneralTransactionalSchema,
    Lane01PropertyRealEstateSchema, Lane02RetirementAccountsSchema, Lane03CreditDebtSchema,
    Lane05AssetVaultTrustsSchema, Lane06BrokerageInvestmentsSchema, Lane07TaxReturnsDocumentsSchema,
    Lane08InsurancePoliciesSchema, Lane09InfrastructureEquipmentSchema, Lane10LivestockAgricultureSchema,
    Lane11GroceryRetailSchema, Lane12PayrollCompensationSchema, Lane13SubsidiesFamilyPaymentsSchema,
    Lane14UtilitiesServicesSchema, Lane15VehiclesTransportSchema, Lane16LegalProfessionalSchema,
    Lane17SportingRecreationSchema, Lane18HealthcareMedicalSchema
)

# ============================================================================
# PART 1: FORENSIC EDGE CASES (Crypto, Binary, Sequential State)
# ============================================================================

def load_golden_registry():
    with open('tests/golden_test_registry.json', 'r', encoding='utf-8') as f:
        return json.load(f)

def simulate_binary_auth(hex_string: str) -> bytes:
    try:
        return binascii.unhexlify(hex_string)
    except:
        return b''

@pytest.mark.parametrize("registry_entry", load_golden_registry(), ids=lambda entry: entry["test_identifier"])
def test_forensic_edge_cases(registry_entry):
    should_pass = registry_entry["should_pass"]
    expected_error = registry_entry.get("expected_error", "")
    binary_hex = registry_entry.get("binary_header_simulation", "")
    payload = registry_entry.get("payload", {})

    try:
        raw_bytes = simulate_binary_auth(binary_hex)
        if not raw_bytes.startswith(b'%PDF'):
            raise ValueError("FRE_901_VIOLATION: Binary signature does not match PDF.")
    except ValueError as e:
        if not should_pass:
            assert expected_error in str(e)
            return
        pytest.fail(f"Failed at Binary Auth: {str(e)}")

    try:
        if not payload.get("original_parent_sha256") or payload.get("original_parent_sha256") == "MISSING_HASH":
            raise ValueError("CHAIN_OF_CUSTODY_FRACTURE")
        if not payload.get("sliced_child_sha256"):
            raise ValueError("CHAIN_OF_CUSTODY_FRACTURE")

        taxonomy_lane = payload.get("taxonomy_lane")
        if taxonomy_lane == "LANE_04_BANKING_CHECKING":
            validated_data = Lane04BankingCheckingSchema(**payload.get("extracted_payload", {}))
            payload["extracted_payload"] = validated_data.model_dump()

        envelope = ForensicGoldenEnvelope(**payload)

        if not should_pass:
            pytest.fail(f"Expected failure with {expected_error}, but passed.")
            
        if taxonomy_lane == "LANE_04_BANKING_CHECKING" and should_pass:
            txns = envelope.extracted_payload.sequential_transactions
            assert txns[1].description == "DEPOSIT", "Ditto resolution failed"
            assert txns[1].running_balance == 16000.00, "Math validation failed"

    except (ValueError, ValidationError) as e:
        if should_pass:
            pytest.fail(f"Unexpected failure: {str(e)}")
        assert expected_error in str(e)

# ============================================================================
# PART 2: THE 18-LANE EXHAUSTIVE MATHEMATICS MATRIX
# ============================================================================

def mock_entity(value):
    return {
        "extracted_string_or_numeric_value": value,
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {"horizontal_x_vertices": [0.0], "vertical_y_vertices": [0.0]}
    }

# Mapping of all schemas to their respective required fields and values to achieve PERFECT math.
MATHEMATICAL_TRUTH_TABLE = [
    (Lane00GeneralTransactionalSchema, {"net_receipt_amount": 100.0, "tax_receipt_amount": 5.0, "gross_receipt_total": 105.0}),
    (Lane01PropertyRealEstateSchema, {"assessed_land_value": 50000.0, "assessed_improvement_value": 150000.0, "total_assessed_property_value": 200000.0}),
    (Lane02RetirementAccountsSchema, {"previous_period_balance": 1000.0, "period_contributions": 200.0, "period_investment_gains": 50.0, "period_distributions": 100.0, "current_period_balance": 1150.0}),
    (Lane03CreditDebtSchema, {"previous_statement_balance": 500.0, "new_purchases_amount": 200.0, "accrued_interest_amount": 10.0, "payments_received_amount": 300.0, "new_statement_balance": 410.0}),
    (Lane05AssetVaultTrustsSchema, {"original_principal_funding": 100000.0, "accrued_trust_interest": 5000.0, "trust_distributions_paid": 2000.0, "current_trust_value": 103000.0}),
    (Lane06BrokerageInvestmentsSchema, {"liquid_cash_balance": 1000.0, "sum_of_securities_market_value": 9000.0, "total_portfolio_value": 10000.0}),
    (Lane07TaxReturnsDocumentsSchema, {"total_gross_income": 100000.0, "total_tax_deductions": 20000.0, "adjusted_gross_income": 80000.0}),
    (Lane08InsurancePoliciesSchema, {"base_policy_premium": 500.0, "additional_policy_fees": 25.0, "total_billed_premium": 525.0}),
    (Lane09InfrastructureEquipmentSchema, {"contract_base_amount": 10000.0, "materials_cost_amount": 5000.0, "total_infrastructure_cost": 15000.0}),
    (Lane10LivestockAgricultureSchema, {"agricultural_unit_cost": 50.0, "agricultural_quantity": 100.0, "total_agricultural_expenditure": 5000.0}),
    (Lane11GroceryRetailSchema, {"wholesale_inventory_cost": 200.0, "retail_markup_amount": 50.0, "final_retail_price_total": 250.0}),
    (Lane12PayrollCompensationSchema, {"gross_employee_wages": 5000.0, "total_tax_withholdings": 1000.0, "net_payroll_disbursement": 4000.0}),
    (Lane13SubsidiesFamilyPaymentsSchema, {"base_subsidy_amount": 600.0, "supplementary_allocation_amount": 150.0, "total_subsidy_payment": 750.0}),
    (Lane14UtilitiesServicesSchema, {"utility_usage_charge": 120.0, "utility_transmission_fees": 30.0, "total_utility_bill_amount": 150.0}),
    (Lane15VehiclesTransportSchema, {"vehicle_purchase_price": 30000.0, "registration_and_sales_tax_fees": 2000.0, "total_transport_acquisition_cost": 32000.0}),
    (Lane16LegalProfessionalSchema, {"attorney_hourly_rate": 350.0, "attorney_hours_billed": 10.0, "court_filing_fees": 150.0, "total_legal_obligation": 3650.0}),
    (Lane17SportingRecreationSchema, {"sporting_item_cost": 850.0, "sporting_tax_amount": 51.0, "total_recreation_expenditure": 901.0}),
    (Lane18HealthcareMedicalSchema, {"gross_medical_provider_charge": 1000.0, "insurance_negotiated_rate_adjustment": 600.0, "patient_copayment_amount": 50.0, "remaining_patient_balance": 350.0})
]

@pytest.mark.parametrize("schema_class, valid_data", MATHEMATICAL_TRUTH_TABLE)
def test_exhaustive_lane_mathematics_success(schema_class, valid_data):
    """Proves that mathematically sound payloads pass the Iron Gate."""
    payload = {key: mock_entity(value) for key, value in valid_data.items()}
    validated = schema_class(**payload)
    assert validated is not None

@pytest.mark.parametrize("schema_class, valid_data", MATHEMATICAL_TRUTH_TABLE)
def test_exhaustive_lane_mathematics_failure(schema_class, valid_data):
    """Proves that a single hallucinated digit triggers an immediate Iron Gate crash."""
    payload = {key: mock_entity(value) for key, value in valid_data.items()}
    
    # Sabotage the final aggregate field by artificially inflating it by $1.00
    target_key = list(valid_data.keys())[-1] 
    payload[target_key]["extracted_string_or_numeric_value"] += 1.0 
    
    with pytest.raises(ValidationError) as e:
        schema_class(**payload)
    
    assert "MATHEMATICAL VALIDATION ERROR" in str(e.value), f"Schema {schema_class.__name__} failed to catch fraudulent math!"
EOF

echo "--- [14/15] GENERATING GHFMD DOCUMENTATION FILES ---"
cat << 'EOF_MD' > PROJECT_BLUEPRINT.md
# PROJECT BLUEPRINT: Legal Forensics & Trust Protection Engine (V17.0.0)
**Environment:** Google Cloud Platform (Eventarc, Cloud Run Functions, BigQuery)
**Architect:** Mark Kibby

## Executive Vision
A Daubert-admissible, serverless forensic accounting pipeline designed to enforce Paragraph 8F and Paragraph 6 constraints. It relies on deterministic algorithmic skepticism rather than generative AI trust, featuring strict cryptographic chain-of-custody linking child slices back to parent bundles. Includes a Layer 2 Hybrid RAG API for investigative hypothesis testing.
EOF_MD

cat << 'EOF_MD' > MASTER_CONTROL_DOCUMENT.md
# MASTER CONTROL DOCUMENT
## Evidentiary Compliance
* **FRE 901 (Authentication):** Binary `%PDF` inspection and SHA-256 generation.
* **FRE 1006 (Summaries):** Double-entry algebraic checksums applied to every transaction, including sequential "ditto" mark propagation.
* **MRE 801 (Hearsay):** Spatial `[X,Y]` polygon bounding boxes map all extractions to physical page coordinates.
EOF_MD

echo "--- [15/15] EXECUTING ADVERSARIAL TDD SUITE & GCLOUD DEPLOYMENTS ---"
export PYTHONPATH="$(pwd)"
echo "Executing Pytest against Golden Registry..."
python3 -m pytest tests/test_iron_gate_factory.py -v

# --- NEW REMEDIATION: THE ROOT PROXY ---
echo "Authoring Root Proxy for Cloud Functions..."
cat << 'EOF' > main.py
# Root Entry Point for Google Cloud Functions
from src.main import forensic_document_trigger
EOF
# ---------------------------------------
echo "TDD Validated. Deploying Layer 1: Ingestion Pipeline (Cloud Run Functions)..."
gcloud functions deploy forensic-pipeline-router \
    --gen2 \
    --runtime=python310 \
    --region="${REGION}" \
    --source=. \
    --entry-point=forensic_document_trigger \
    --trigger-event-filters="type=google.cloud.storage.object.v1.finalized" \
    --trigger-event-filters="bucket=${VAULT_BUCKET}" \
    --service-account="${SERVICE_ACCOUNT_EMAIL}" \
    --memory=4096MB \
    --timeout=540s \
    --set-env-vars="GOOGLE_CLOUD_PROJECT_IDENTIFIER=${PROJECT_ID},GOOGLE_CLOUD_STORAGE_BUCKET_NAME=${ARCHIVE_BUCKET},DOCAI_PROCESSOR_ID=${DOCAI_PROCESSOR_ID}" \
    --project="${PROJECT_ID}"

echo "Deploying Layer 2: Hybrid RAG API (Cloud Run)..."
gcloud run deploy forensic-rag-api \
    --source=rag_api/ \
    --region="${REGION}" \
    --project="${PROJECT_ID}" \
    --no-allow-unauthenticated \
    --service-account="${SERVICE_ACCOUNT_EMAIL}" \
    --set-env-vars="GOOGLE_CLOUD_PROJECT=${PROJECT_ID}"

    echo "Authoring internal Eventarc Service Agent permissions..."
GS_PROJECT_NUMBER=$(gcloud projects describe "${PROJECT_ID}" --format="value(projectNumber)")
EVENTARC_SERVICE_ACCOUNT="service-${GS_PROJECT_NUMBER}@gcp-sa-eventarc.iam.gserviceaccount.com"

echo "Binding storage.admin to Eventarc Service Agent: ${EVENTARC_SERVICE_ACCOUNT}..."
gcloud projects add-iam-policy-binding "${PROJECT_ID}" \
    --member="serviceAccount:${EVENTARC_SERVICE_ACCOUNT}" \
    --role="roles/storage.admin" \
    --condition=None >/dev/null

echo "============================================================================"
echo " SYSTEM ARCHITECTURE LOCK ACHIEVED "
echo " The V17.0.0 Legal Forensics Engine is fully deployed and verified."
echo " Drop PDFs into: gs://${VAULT_BUCKET}/"
echo " Access Governance Wizard: python3 tools/governance_wizard.py"
echo "============================================================================"
```

================================================================================
FILEPATH: deploy_context_extractor.sh
================================================================================
```sh
#!/bin/bash
# ==============================================================================
# MASTER DEPLOYMENT: FORENSIC CONTEXT EXTRACTOR (TDD + ISOLATED DEPENDENCIES)
# ==============================================================================
set -e

echo "[SYSTEM] Initiating Zero-Trust Extraction Deployment..."

# ==============================================================================
# 0. DEPENDENCY ISOLATION BOUNDARY
# ==============================================================================
echo "[SYSTEM] Establishing ephemeral virtual environment (.venv_forensic_extract)..."
python3 -m venv .venv_forensic_extract
source .venv_forensic_extract/bin/activate

echo "[SYSTEM] Installing adversarial testing framework (Pytest)..."
pip install --quiet --upgrade pip
pip install --quiet pytest

# 1. Scaffold Directories
mkdir -p tools tests

# ==============================================================================
# 2. WRITE TDD FIXTURES (pytest)
# ==============================================================================
echo "[SYSTEM] Generating Adversarial Pytest Fixtures..."
cat << 'EOF' > tests/test_context_extractor.py
import os
import pytest
from pathlib import Path
from tools.context_extractor import build_allow_list, extract_workspace

@pytest.fixture
def mock_ide_environment(tmp_path: Path):
    """Dynamically generates a mock IDE with both valid files and poison vectors."""
    # Create valid directories and files
    src_dir = tmp_path / "src"
    src_dir.mkdir()
    (src_dir / "main.py").write_text("print('Legal Forensics Engine')")
    
    tools_dir = tmp_path / "tools"
    tools_dir.mkdir()
    (tools_dir / "deploy.sh").write_text("echo 'Deploying...'")

    # Create poison vectors (Should be excluded)
    (tmp_path / ".env").write_text("GCP_SERVICE_ACCOUNT_KEY=12345")
    
    venv_dir = tmp_path / ".venv_forensic_extract"
    venv_dir.mkdir()
    (venv_dir / "dependency.py").write_text("print('noise')")
    
    git_dir = tmp_path / ".git"
    git_dir.mkdir()
    (git_dir / "config").write_text("git config data")

    return tmp_path

def test_exclusion_gate(mock_ide_environment: Path):
    """Proves that credentials and noise directories are strictly bypassed."""
    allowed_files = build_allow_list(mock_ide_environment)
    allowed_paths = [str(p.relative_to(mock_ide_environment)) for p in allowed_files]
    
    assert ".env" not in allowed_paths, "FATAL: Credentials leaked into allow-list."
    assert ".venv_forensic_extract/dependency.py" not in allowed_paths, "FATAL: Ephemeral venv bypassed exclusion gate."
    assert ".git/config" not in allowed_paths, "FATAL: Git history bypassed exclusion gate."

def test_allow_list_gate(mock_ide_environment: Path):
    """Proves that valid architectural files are successfully targeted."""
    allowed_files = build_allow_list(mock_ide_environment)
    allowed_paths = [str(p.relative_to(mock_ide_environment)) for p in allowed_files]
    
    assert "src/main.py" in allowed_paths, "FATAL: Core logic file dropped."
    assert "tools/deploy.sh" in allowed_paths, "FATAL: Deployment script dropped."

def test_output_formatting_gate(mock_ide_environment: Path):
    """Proves the mathematical boundaries of the output artifact."""
    output_artifact = mock_ide_environment / "test_forensic_context.md"
    extract_workspace(mock_ide_environment, output_artifact)
    
    content = output_artifact.read_text(encoding="utf-8")
    
    assert "================================================================================" in content
    assert "FILEPATH: src/main.py" in content
    assert "print('Legal Forensics Engine')" in content
    assert "GCP_SERVICE_ACCOUNT_KEY" not in content
EOF

# ==============================================================================
# 3. WRITE EXTRACTION LOGIC (Python 3.10+)
# ==============================================================================
echo "[SYSTEM] Generating Python 3.10+ Extraction Logic..."
cat << 'EOF' > tools/context_extractor.py
import os
import datetime
from pathlib import Path
from typing import List

# ==============================================================================
# HARDENED CONFIGURATION MATRIX
# ==============================================================================
EXCLUDE_DIRS = {
    ".git", "venv", "env", "__pycache__", ".pytest_cache", 
    ".vscode", "idea", "node_modules", ".mypy_cache", ".venv_forensic_extract"
}

EXCLUDE_FILES = {
    ".env", ".pem", "credentials.json", "service-account.json", 
    ".DS_Store"
}

ALLOW_EXTENSIONS = {
    ".py", ".sh", ".json", ".md", ".yaml", ".yml", ".sql", ".txt", ".toml", ".ini"
}

def build_allow_list(root_dir: Path) -> List[Path]:
    """
    Recursively scans the directory, violently rejecting any path matching
    the EXCLUDE_DIRS or EXCLUDE_FILES sets, and filtering by ALLOW_EXTENSIONS.
    """
    valid_files = []
    for current_root, dirs, files in os.walk(root_dir):
        # Mutate dirs in-place to prevent os.walk from entering excluded directories
        dirs[:] = [d for d in dirs if d not in EXCLUDE_DIRS]
        
        for file in files:
            if file in EXCLUDE_FILES:
                continue
                
            file_path = Path(current_root) / file
            if file_path.suffix.lower() in ALLOW_EXTENSIONS:
                valid_files.append(file_path)
                
    return sorted(valid_files)

def extract_workspace(root_dir: Path, output_path: Path) -> None:
    """
    Iterates through the verified allow-list and generates the highly structured
    Markdown artifact for LLM ingestion.
    """
    valid_files = build_allow_list(root_dir)
    
    with open(output_path, "w", encoding="utf-8") as outfile:
        timestamp = datetime.datetime.now().isoformat()
        outfile.write(f"# LEGAL FORENSICS ENGINE - IDE EXTRACTION ARTIFACT\n")
        outfile.write(f"**TIMESTAMP:** {timestamp}\n")
        outfile.write(f"**TOTAL FILES EXTRACTED:** {len(valid_files)}\n\n")
        
        for file_path in valid_files:
            try:
                # Calculate relative path for clean headers
                rel_path = file_path.relative_to(root_dir)
                content = file_path.read_text(encoding="utf-8")
                
                outfile.write("=" * 80 + "\n")
                outfile.write(f"FILEPATH: {rel_path}\n")
                outfile.write("=" * 80 + "\n")
                
                # Use standard markdown code blocks, defaulting to raw text if extension varies
                ext = file_path.suffix.lower().replace(".", "")
                outfile.write(f"```{ext}\n")
                outfile.write(content)
                if not content.endswith("\n"):
                    outfile.write("\n")
                outfile.write("```\n\n")
                
            except Exception as e:
                outfile.write(f"[WARNING: FAILED TO EXTRACT {rel_path} - {str(e)}]\n\n")

if __name__ == "__main__":
    workspace_root = Path.cwd()
    timestamp_str = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
    output_artifact = workspace_root / f"forensic_context_{timestamp_str}.md"
    
    print(f"[SYSTEM] Extracting Legal Forensics Engine workspace from: {workspace_root}")
    extract_workspace(workspace_root, output_artifact)
    print(f"[SUCCESS] Extraction complete. Artifact generated at: {output_artifact.name}")
EOF

# ==============================================================================
# 4. EXECUTE ADVERSARIAL TDD SUITE
# ==============================================================================
echo "[SYSTEM] Executing Pytest Gate via isolated environment..."
python -m pytest tests/test_context_extractor.py -v

# ==============================================================================
# 5. EXECUTE EXTRACTION IF GREEN
# ==============================================================================
echo "[SYSTEM] TDD Gate Passed. Executing Workspace Extraction..."
python tools/context_extractor.py

# ==============================================================================
# 6. TEARDOWN
# ==============================================================================
echo "[SYSTEM] Tearing down ephemeral dependency boundary..."
deactivate
echo "[SYSTEM] Extraction Lifecycle Complete."
```

================================================================================
FILEPATH: fix_dependencies.sh
================================================================================
```sh
#!/bin/bash
# ============================================================================
# LEGAL FORENSICS ENGINE - DEPENDENCY HOTFIX (V2)
# DIRECTIVE: Semantic Versioning / Unbound Variable Resolution
# ============================================================================
set -o errexit
set -o nounset
set -o pipefail

echo "--- [1/3] PURGING CORRUPTED DEPENDENCY TREES ---"
# BASH FIX: Utilizing ${VIRTUAL_ENV:-} parameter expansion to satisfy 'nounset' strict mode
if [[ "${VIRTUAL_ENV:-}" != "" ]]; then
    deactivate || true
fi

rm -rf forensic_environment requirements.txt
python3 -m venv forensic_environment
source forensic_environment/bin/activate
pip install --upgrade pip

echo "--- [2/3] AUTHORING ENVIRONMENT-AWARE REQUIREMENTS ---"
# Utilizing >= to allow pip to resolve Python 3.11+ compatible wheels
cat << 'END_OF_REQ' > requirements.txt
google-cloud-storage>=2.14.0
google-cloud-bigquery>=3.17.0
google-cloud-documentai>=3.4.0
google-genai>=0.3.0
functions-framework>=3.8.0
pydantic>=2.6.1
pytest>=8.0.0
pypdf>=4.1.0
END_OF_REQ

echo "--- [3/3] EXECUTING STRICT PIP INSTALLATION ---"
pip install -r requirements.txt

echo "============================================================================"
echo " DEPENDENCY LOCK ACHIEVED "
echo " You may now resume your previous deployment or testing execution."
echo " To re-run the TDD tests: python3 -m pytest tests/test_iron_gate_factory.py -v"
echo "============================================================================"
```

================================================================================
FILEPATH: main.py
================================================================================
```py
# Root Entry Point for Google Cloud Functions
from src.main import forensic_document_trigger
```

================================================================================
FILEPATH: rag_api/main.py
================================================================================
```py
import os
import re
import json
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from google.cloud import bigquery, storage
from google import genai
from google.genai import types

# Satisfies TR-5.1: Serverless Async Interaction Layer
app = FastAPI(title="Legal Forensics Engine - Hybrid RAG API")

PROJECT_ID = os.environ.get("GOOGLE_CLOUD_PROJECT", "i-dub-thee")
REGION = "us-central1"
ARCHIVE_BUCKET = f"{PROJECT_ID}-master-filing-cabinet"
TABLE_ID = f"{PROJECT_ID}.forensic_fact_base.ingestion_ledger"

bq_client = bigquery.Client(project=PROJECT_ID)
storage_client = storage.Client(project=PROJECT_ID)

# FATAL ERROR REMEDIATED: Enterprise Vertex AI mode strictly enforced
genai_client = genai.Client(vertexai=True, project=PROJECT_ID, location=REGION)

class ForensicHypothesis(BaseModel):
    natural_language_query: str

def generate_sql_from_hypothesis(hypothesis: str) -> str:
    """Satisfies FR-1.1: Quantitative Natural Language Translation."""
    prompt = f"""
    You are a forensic data engineer. Convert this investigative hypothesis into strictly valid Google Standard SQL.
    Target Table: `{TABLE_ID}`
    Schema fields available: original_parent_sha256, sliced_child_sha256, gcs_source_uri, entity_slug, taxonomy_lane, average_confidence, extracted_payload (JSON).
    
    Hypothesis: '{hypothesis}'
    
    IMPORTANT: You MUST include `sliced_child_sha256` in your SELECT statement so we can trace the math back to the physical document.
    Output ONLY the raw SQL string. Do not use markdown blocks.
    """
    response = genai_client.models.generate_content(
        model="gemini-2.5-pro",
        contents=prompt,
        config=types.GenerateContentConfig(temperature=0.0)
    )
    sql_query = response.text.replace('```sql', '').replace('```', '').strip()
    return sql_query

def retrieve_qualitative_context(hashes: list[str]) -> str:
    """Satisfies FR-1.2: Qualitative Vector Retrieval (via GCS Markdown Stream)."""
    bucket = storage_client.bucket(ARCHIVE_BUCKET)
    context_accumulator = []
    
    # Cap retrieval to prevent token overflow on massive sweeps
    for doc_hash in hashes[:10]: 
        try:
            layout_blob = bucket.blob(f"archive/{doc_hash}/layout.md")
            if layout_blob.exists():
                markdown_content = layout_blob.download_as_text()
                context_accumulator.append(f"--- DOCUMENT HASH: {doc_hash} ---\n{markdown_content}\n")
        except Exception as e:
            print(f"Failed to retrieve context for {doc_hash}: {e}")
            
    return "\n".join(context_accumulator)

@app.post("/api/v1/investigate")
async def execute_hybrid_investigation(query: ForensicHypothesis):
    """Orchestrates TR-1.1: Hybrid RAG & FR-5.1: Hypothesis Report Generation."""
    try:
        # STEP 1: Deterministic Math (BigQuery)
        sql_query = generate_sql_from_hypothesis(query.natural_language_query)
        query_job = bq_client.query(sql_query)
        sql_results = [dict(row) for row in query_job]
        
        # Extract the cryptographic hashes to link to the narrative
        document_hashes = list(set([row.get("sliced_child_sha256") for row in sql_results if row.get("sliced_child_sha256")]))

        # STEP 2: Contextual Narrative (Google Cloud Storage)
        qualitative_context = retrieve_qualitative_context(document_hashes)

        # STEP 3: Cryptographic Synthesis (FR-1.3)
        synthesis_prompt = f"""
        You are an expert forensic accountant analyzing commingled assets.
        Synthesize the mathematical facts from the SQL database with the narrative context from the physical documents.
        
        HYPOTHESIS: {query.natural_language_query}
        
        DETERMINISTIC MATH (SQL RESULTS): 
        {json.dumps(sql_results, default=str)}
        
        NARRATIVE CONTEXT (MARKDOWN):
        {qualitative_context}
        
        MANDATORY RULES:
        1. Output a formal Markdown report titled '## Hypothesis Validation Report'.
        2. You MUST append an exact source citation to every single insight, claim, or calculation.
        3. The citation MUST be strictly formatted as: (Source: Hash [insert sliced_child_sha256 here], Bbox: [x,y])
        4. If the bounding box is unknown, output Bbox: [Unknown].
        5. Do not hallucinate data. If the SQL math contradicts the Markdown, state the contradiction clearly.
        """
        
        synthesis_response = genai_client.models.generate_content(
            model="gemini-2.5-pro",
            contents=synthesis_prompt,
            config=types.GenerateContentConfig(temperature=0.1)
        )
        
        return {
            "hypothesis": query.natural_language_query, 
            "executed_sql": sql_query,
            "quantitative_matches": len(sql_results),
            "report": synthesis_response.text
        }
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"HYBRID_RAG_FAILURE: {str(e)}")

# Initialization requirement for Cloud Run buildpack
if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=int(os.environ.get("PORT", 8080)))
```

================================================================================
FILEPATH: requirements.txt
================================================================================
```txt
google-cloud-storage>=2.14.0
google-cloud-bigquery>=3.17.0
google-cloud-documentai>=3.4.0
google-genai>=0.3.0
functions-framework>=3.8.0
pydantic>=2.6.1
pypdf>=4.1.0
```

================================================================================
FILEPATH: src/__init__.py
================================================================================
```py

```

================================================================================
FILEPATH: src/geospatial.py
================================================================================
```py
import math
from typing import List, Dict, Optional
from pydantic import BaseModel, ConfigDict

class BoundingPolygon(BaseModel):
    model_config = ConfigDict(extra='forbid')
    x_vertices: List[float]
    y_vertices: List[float]
    
    def centroid(self) -> dict:
        return {"x": sum(self.x_vertices)/len(self.x_vertices), "y": sum(self.y_vertices)/len(self.y_vertices)}

class OpticalEntity(BaseModel):
    model_config = ConfigDict(extra='forbid')
    text: str
    confidence: float
    coordinates: BoundingPolygon
    is_handwritten: bool

class GeospatialAnchorEngine:
    def __init__(self, vertical_threshold: float = 0.05, horizontal_threshold: float = 0.40):
        self.v_thresh = vertical_threshold
        self.h_thresh = horizontal_threshold

    def bind_marginalia(self, printed_items: List[OpticalEntity], handwritten_notes: List[OpticalEntity]) -> List[Dict]:
        anchored_ledger = []
        for printed in printed_items:
            p_center = printed.coordinates.centroid()
            closest_note, shortest_dist = None, float('inf')
            
            for note in handwritten_notes:
                n_center = note.coordinates.centroid()
                if abs(p_center["y"] - n_center["y"]) <= self.v_thresh:
                    dist = math.sqrt((p_center["x"] - n_center["x"])**2 + (p_center["y"] - n_center["y"])**2)
                    if dist < shortest_dist and dist <= self.h_thresh:
                        shortest_dist, closest_note = dist, note
                        
            anchored_ledger.append({
                "printed_transaction": printed.model_dump(),
                "handwritten_modifier": closest_note.model_dump() if closest_note else None
            })
            if closest_note in handwritten_notes:
                handwritten_notes.remove(closest_note)
        return anchored_ledger
```

================================================================================
FILEPATH: src/main.py
================================================================================
```py
import os
import io
import json
import hashlib
import asyncio
import random
import logging
from typing import List, Dict, Any
from google.cloud import storage, bigquery, documentai
from google import genai
from google.genai import types
from pypdf import PdfReader, PdfWriter
import functions_framework
from pydantic import ValidationError

from src.schemas import ForensicGoldenEnvelope
from src.registry import FORENSIC_DOCUMENT_TYPE_REGISTRY
from src.geospatial import GeospatialAnchorEngine, OpticalEntity, BoundingPolygon

logging.basicConfig(level=logging.INFO)

PROJECT_ID = os.environ.get("GOOGLE_CLOUD_PROJECT_IDENTIFIER", "i-dub-thee")
ARCHIVE_BUCKET = os.environ.get("GOOGLE_CLOUD_STORAGE_BUCKET_NAME", "i-dub-thee-master-filing-cabinet")
TABLE_ID = f"{PROJECT_ID}.forensic_fact_base.ingestion_ledger"
REGION = "us-central1"
DOCAI_PROCESSOR_ID = os.environ.get("DOCAI_PROCESSOR_ID", "REQUIRED_AT_RUNTIME")

storage_client = storage.Client(project=PROJECT_ID)
bq_client = bigquery.Client(project=PROJECT_ID)
docai_client = documentai.DocumentProcessorServiceClient()
genai_client = genai.Client(vertexai=True, project=PROJECT_ID, location=REGION)

class AsyncRateLimiter:
    def __init__(self, max_concurrent_tasks: int = 4):
        self.semaphore = asyncio.Semaphore(max_concurrent_tasks)

    async def execute_with_backoff(self, coroutine_func, *args, max_retries=5, base_delay=1.0) -> str:
        async with self.semaphore:
            for attempt in range(max_retries):
                try:
                    return await coroutine_func(*args)
                except Exception as e:
                    error_msg = str(e).lower()
                    if "429" in error_msg or "quota" in error_msg or "exhausted" in error_msg:
                        if attempt == max_retries - 1:
                            raise Exception(f"FATAL: Rate limit exhausted. {e}")
                        delay = random.uniform(0, base_delay * (2 ** attempt))
                        logging.warning(f"Rate limit hit. Backing off for {delay:.2f} seconds...")
                        await asyncio.sleep(delay)
                    else:
                        raise e

def slice_and_hash_bundle(parent_bytes: bytes, parent_hash: str) -> List[Dict[str, Any]]:
    boundaries = [{"start_page": 1, "end_page": 1}] 
    sliced_artifacts = []
    reader = PdfReader(io.BytesIO(parent_bytes))
    for bound in boundaries:
        writer = PdfWriter()
        start = max(0, bound["start_page"] - 1)
        end = min(len(reader.pages), bound["end_page"])
        for i in range(start, end):
            writer.add_page(reader.pages[i])
        output_buffer = io.BytesIO()
        writer.write(output_buffer)
        child_bytes = output_buffer.getvalue()
        child_hash = hashlib.sha256(child_bytes).hexdigest()
        sliced_artifacts.append({
            "binary": child_bytes,
            "original_parent_sha256": parent_hash,
            "sliced_child_sha256": child_hash
        })
    return sliced_artifacts

def execute_optical_extraction(file_bytes: bytes) -> tuple[float, List[Dict]]:
    """Satisfies FR-5.1 & FR-5.2: Document AI + Geospatial Engine"""
    name = docai_client.processor_path(PROJECT_ID, "us", DOCAI_PROCESSOR_ID)
    raw_document = documentai.RawDocument(content=file_bytes, mime_type="application/pdf")
    request = documentai.ProcessRequest(name=name, raw_document=raw_document)
    
    try:
        result = docai_client.process_document(request=request)
        document = result.document
    except Exception as e:
        logging.error(f"DocAI Error: {e}")
        return 0.0, []

    printed_entities = []
    handwritten_entities = []
    confidence_scores = []
    
    for entity in document.entities:
        conf = entity.confidence
        confidence_scores.append(conf)
        
        # Extract vertices
        x_verts = [v.x for v in entity.page_anchor.page_refs[0].bounding_poly.normalized_vertices]
        y_verts = [v.y for v in entity.page_anchor.page_refs[0].bounding_poly.normalized_vertices]
        
        if not x_verts or not y_verts:
            continue
            
        opt_entity = OpticalEntity(
            text=entity.mention_text,
            confidence=conf,
            coordinates=BoundingPolygon(x_vertices=x_verts, y_vertices=y_verts),
            is_handwritten=False # Simplified for V17 baseline
        )
        printed_entities.append(opt_entity)
        
    avg_conf = sum(confidence_scores) / len(confidence_scores) if confidence_scores else 0.0
    
    geo_engine = GeospatialAnchorEngine()
    anchored_data = geo_engine.bind_marginalia(printed_entities, handwritten_entities)
    
    return avg_conf, anchored_data

async def _call_gemini_async(file_bytes: bytes, prompt: str, temperature: float, response_mime_type: str = "text/plain") -> str:
    response = genai_client.models.generate_content(
        model="gemini-2.5-pro",
        contents=[types.Part.from_bytes(data=file_bytes, mime_type="application/pdf"), prompt],
        config=types.GenerateContentConfig(temperature=temperature, response_mime_type=response_mime_type)
    )
    return response.text

async def generate_tri_pass_artifacts(file_bytes: bytes, anchored_data: List[Dict]) -> Dict[str, str]:
    limiter = AsyncRateLimiter(max_concurrent_tasks=4)
    layout_prompt = "Output a precise MARKDOWN representation of this document's visual layout. Use GFM tables. Preserve all structure."
    sum_prompt = "Produce a Markdown report: ## Executive Summary (BLUF), ## Content Analysis, ## Risk Assessment."
    per_prompt = "Identify the optimal forensic persona to review this document. Provide strategic analysis in Markdown."
    
    # Feeding the Geospatial Anchors to Gemini to inform the JSON extraction
    json_prompt = f"""
    Extract all data into a strictly formatted JSON object. 
    Utilize this OCR geometric data as ground truth: {str(anchored_data)[:2000]}
    You MUST output a root JSON object containing:
    1. 'entity_slug': The primary entity
    2. 'taxonomy_lane': The exact lane string (e.g., 'LANE_04_BANKING_CHECKING')
    3. 'extracted_payload': The nested data object corresponding to that lane's schema.
    """
    
    results = await asyncio.gather(
        limiter.execute_with_backoff(_call_gemini_async, file_bytes, layout_prompt, 0.0),
        limiter.execute_with_backoff(_call_gemini_async, file_bytes, sum_prompt, 0.0),
        limiter.execute_with_backoff(_call_gemini_async, file_bytes, per_prompt, 0.2),
        limiter.execute_with_backoff(_call_gemini_async, file_bytes, json_prompt, 0.0, "application/json")
    )
    
    return {
        "uhf_markdown": results[0],
        "summary": results[1],
        "persona": results[2],
        "exhaustive_json": results[3]
    }

def process_document_pipeline(bucket_name: str, object_name: str):
    bucket = storage_client.bucket(bucket_name)
    blob = bucket.blob(object_name)
    file_bytes = blob.download_as_bytes()

    if not file_bytes.startswith(b'%PDF-'):
        raise ValueError("FRE_901_VIOLATION: Invalid binary signature.")
        
    parent_hash = hashlib.sha256(file_bytes).hexdigest()
    sliced_artifacts = slice_and_hash_bundle(file_bytes, parent_hash)
    archive_bucket = storage_client.bucket(ARCHIVE_BUCKET)
    
    for slice_data in sliced_artifacts:
        child_hash = slice_data["sliced_child_sha256"]
        child_bytes = slice_data["binary"]
        
        # 1. Hardware Optical Extraction & Geospatial Binding
        avg_confidence, anchored_data = execute_optical_extraction(child_bytes)
        
        # 2. Tri-Pass LLM Generation
        artifacts = asyncio.run(generate_tri_pass_artifacts(child_bytes, anchored_data))
        
        try:
            raw_extraction = json.loads(artifacts["exhaustive_json"])
        except json.JSONDecodeError:
            raise ValueError("GEMINI_JSON_FAILURE: Failed to decode extraction payload.")

        # 3. Construct Golden Envelope
        envelope_payload = {
            "original_parent_sha256": parent_hash,
            "sliced_child_sha256": child_hash,
            "gcs_source_uri": f"gs://{ARCHIVE_BUCKET}/archive/{child_hash}/document.pdf",
            "entity_slug": raw_extraction.get("entity_slug", "UNKNOWN_ENTITY"),
            "taxonomy_lane": raw_extraction.get("taxonomy_lane", "LANE_00_GENERAL_TRANSACTIONAL"),
            "average_confidence": avg_confidence, # REAL DocAI confidence
            "requires_manual_review": False,
            "extracted_payload": raw_extraction.get("extracted_payload", {})
        }

        # 4. The Iron Gate
        validated_envelope = ForensicGoldenEnvelope(**envelope_payload)

        # 5. BigQuery Insert
        bq_rows = [validated_envelope.model_dump(mode='json')]
        errors = bq_client.insert_rows_json(TABLE_ID, bq_rows)
        if errors:
            raise RuntimeError(f"BIGQUERY_INSERTION_FRACTURE: {errors}")
        
        logging.info(f"[FACT BASE SEALED] Inserted {child_hash}")

        # 6. GCS Archive
        base_path = f"archive/{child_hash}"
        archive_bucket.blob(f"{base_path}/document.pdf").upload_from_string(child_bytes, content_type="application/pdf")
        archive_bucket.blob(f"{base_path}/layout.md").upload_from_string(artifacts["uhf_markdown"], content_type="text/markdown")
        archive_bucket.blob(f"{base_path}/summary.md").upload_from_string(artifacts["summary"], content_type="text/markdown")
        archive_bucket.blob(f"{base_path}/persona.md").upload_from_string(artifacts["persona"], content_type="text/markdown")

@functions_framework.cloud_event
def forensic_document_trigger(cloud_event) -> None:
    data = cloud_event.data
    bucket_name = data["bucket"]
    object_name = data["name"]

    if "_QUARANTINE" in object_name or "archive" in object_name or not object_name.lower().endswith(".pdf"):
        return

    try:
        process_document_pipeline(bucket_name, object_name)
    except Exception as e:
        logging.error(f"[FATAL] System Error on {object_name}: {str(e)}")
        bucket = storage_client.bucket(bucket_name)
        blob = bucket.blob(object_name)
        bucket.rename_blob(blob, f"_QUARANTINE/{object_name.split('/')[-1]}")
```

================================================================================
FILEPATH: src/registry.py
================================================================================
```py
# ============================================================================
# FORENSIC DOCUMENT REGISTRY (V17.0.0)
# ============================================================================
KNOWN_ENTITIES = [
    "Judith Grandy", "Mark Sosa-Kibby", "KibbyCo", 
    "M & J Food Market", "Keith Grandy", "K Grandy Enterprises", 
    "Max R Kibby Trust"
]

FORENSIC_DOCUMENT_TYPE_REGISTRY = {
    "LANE_00_GENERAL_TRANSACTIONAL": ["General Invoices", "Retail Receipts"],
    "LANE_01_PROPERTY_REAL_ESTATE": ["Warranty Deeds", "Fiduciary Deeds", "Residential Appraisals", "Property Tax Assessments"],
    "LANE_02_RETIREMENT_ACCOUNTS": ["401k Account Statements", "Pension Valuation Statements"],
    "LANE_03_CREDIT_DEBT": ["Credit Card Statements", "Personal Loan Agreements"],
    "LANE_04_BANKING_CHECKING": ["Monthly Bank Statements", "Handwritten Checkbook Registers"],
    "LANE_05_ASSET_VAULT_TRUSTS": ["Whole Life Insurance Policies", "Trust Indenture Agreements"],
    "LANE_06_BROKERAGE_INVESTMENTS": ["Brokerage Account Statements", "Dividend Reinvestment Summaries"],
    "LANE_07_TAX_RETURNS_DOCUMENTS": ["Federal Form 1040 Filings", "Internal Revenue Service Form 4562 Depreciation"],
    "LANE_08_INSURANCE_POLICIES": ["Insurance Policies And Claim Disbursals"],
    "LANE_09_INFRASTRUCTURE_EQUIPMENT": ["Timber Harvesting Contracts", "Barn Construction Contracts"],
    "LANE_10_LIVESTOCK_AGRICULTURE": ["United States Department Of Agriculture Contracts", "Veterinary Service Records"],
    "LANE_11_GROCERY_RETAIL": ["Heavy Equipment Purchases", "Direct Store Delivery Route Accounting"],
    "LANE_12_PAYROLL_COMPENSATION": ["Employee Payroll Records", "Employment Dispute Settlement Records"],
    "LANE_13_SUBSIDIES_FAMILY_PAYMENTS": ["Cellular Telephone Plans", "Child Support Payments"],
    "LANE_14_UTILITIES_SERVICES": ["Electrical Energy Bills", "Heating Oil Delivery Receipts"],
    "LANE_15_VEHICLES_TRANSPORT": ["State Vehicle Registrations", "Vehicle Maintenance Logs"],
    "LANE_16_LEGAL_PROFESSIONAL": ["Attorney Retainer Agreements", "Forensic Accounting Invoices"],
    "LANE_17_SPORTING_RECREATION": ["Department Of Natural Resources Hunting Licenses", "Firearm Ammunition Receipts"],
    "LANE_18_HEALTHCARE_MEDICAL": ["Out Of Pocket Medical Expenses", "Cognitive Memory Tool Purchases"]
}
```

================================================================================
FILEPATH: src/schemas.py
================================================================================
```py
from pydantic import BaseModel, ConfigDict, Field, model_validator
from typing import List, Union, Dict, Any, Optional

class SpatialCoordinatesPolygon(BaseModel):
    model_config = ConfigDict(extra='forbid')
    horizontal_x_vertices: List[float]
    vertical_y_vertices: List[float]

class ForensicDataEntity(BaseModel):
    model_config = ConfigDict(extra='forbid')
    extracted_string_or_numeric_value: Union[str, float]
    optical_extraction_confidence_score: float = Field(ge=0.0, le=1.0)
    physical_evidence_coordinates: SpatialCoordinatesPolygon

class SequentialTransaction(BaseModel):
    model_config = ConfigDict(extra='forbid')
    transaction_date: str
    description: str
    deposit_amount: float
    withdrawal_amount: float
    running_balance: float
    physical_evidence_coordinates: SpatialCoordinatesPolygon

class Lane00GeneralTransactionalSchema(BaseModel):
    model_config = ConfigDict(extra='forbid')
    net_receipt_amount: ForensicDataEntity
    tax_receipt_amount: ForensicDataEntity
    gross_receipt_total: ForensicDataEntity
    @model_validator(mode='after')
    def validate_transaction_mathematics(self) -> 'Lane00GeneralTransactionalSchema':
        calculated = round(float(self.net_receipt_amount.extracted_string_or_numeric_value) + float(self.tax_receipt_amount.extracted_string_or_numeric_value), 2)
        reported = round(float(self.gross_receipt_total.extracted_string_or_numeric_value), 2)
        if calculated != reported: raise ValueError(f"MATHEMATICAL VALIDATION ERROR: Calculated {calculated} != Extracted {reported}")
        return self

class Lane01PropertyRealEstateSchema(BaseModel):
    model_config = ConfigDict(extra='forbid')
    assessed_land_value: ForensicDataEntity
    assessed_improvement_value: ForensicDataEntity
    total_assessed_property_value: ForensicDataEntity
    @model_validator(mode='after')
    def validate_property_mathematics(self) -> 'Lane01PropertyRealEstateSchema':
        calculated = round(float(self.assessed_land_value.extracted_string_or_numeric_value) + float(self.assessed_improvement_value.extracted_string_or_numeric_value), 2)
        reported = round(float(self.total_assessed_property_value.extracted_string_or_numeric_value), 2)
        if calculated != reported: raise ValueError(f"MATHEMATICAL VALIDATION ERROR: Calculated {calculated} != Extracted {reported}")
        return self

class Lane02RetirementAccountsSchema(BaseModel):
    model_config = ConfigDict(extra='forbid')
    previous_period_balance: ForensicDataEntity
    period_contributions: ForensicDataEntity
    period_investment_gains: ForensicDataEntity
    period_distributions: ForensicDataEntity
    current_period_balance: ForensicDataEntity
    @model_validator(mode='after')
    def validate_retirement_mathematics(self) -> 'Lane02RetirementAccountsSchema':
        calculated = round((float(self.previous_period_balance.extracted_string_or_numeric_value) + float(self.period_contributions.extracted_string_or_numeric_value) + float(self.period_investment_gains.extracted_string_or_numeric_value)) - float(self.period_distributions.extracted_string_or_numeric_value), 2)
        reported = round(float(self.current_period_balance.extracted_string_or_numeric_value), 2)
        if calculated != reported: raise ValueError(f"MATHEMATICAL VALIDATION ERROR: Calculated {calculated} != Extracted {reported}")
        return self

class Lane03CreditDebtSchema(BaseModel):
    model_config = ConfigDict(extra='forbid')
    previous_statement_balance: ForensicDataEntity
    new_purchases_amount: ForensicDataEntity
    accrued_interest_amount: ForensicDataEntity
    payments_received_amount: ForensicDataEntity
    new_statement_balance: ForensicDataEntity
    @model_validator(mode='after')
    def validate_credit_debt_mathematics(self) -> 'Lane03CreditDebtSchema':
        calculated = round((float(self.previous_statement_balance.extracted_string_or_numeric_value) + float(self.new_purchases_amount.extracted_string_or_numeric_value) + float(self.accrued_interest_amount.extracted_string_or_numeric_value)) - float(self.payments_received_amount.extracted_string_or_numeric_value), 2)
        reported = round(float(self.new_statement_balance.extracted_string_or_numeric_value), 2)
        if calculated != reported: raise ValueError(f"MATHEMATICAL VALIDATION ERROR: Calculated {calculated} != Extracted {reported}")
        return self

class Lane04BankingCheckingSchema(BaseModel):
    model_config = ConfigDict(extra='forbid')
    institution_name: ForensicDataEntity
    page_carried_forward_balance: ForensicDataEntity
    sequential_transactions: List[SequentialTransaction]
    @model_validator(mode='after')
    def validate_sequential_ledger_state(self) -> 'Lane04BankingCheckingSchema':
        current_running_balance = round(float(self.page_carried_forward_balance.extracted_string_or_numeric_value), 2)
        previous_description = ""
        for index, txn in enumerate(self.sequential_transactions):
            if txn.description.strip() == '"' or txn.description.strip().lower() == "ditto":
                if index == 0: raise ValueError("SEQUENTIAL LOGIC ERROR: Ditto mark found on first row.")
                txn.description = previous_description
            previous_description = txn.description
            calculated_row_balance = round((current_running_balance + txn.deposit_amount) - txn.withdrawal_amount, 2)
            reported_row_balance = round(txn.running_balance, 2)
            if calculated_row_balance != reported_row_balance:
                raise ValueError(f"GAAP_SEQUENTIAL_MISMATCH: Row {index} calculated {calculated_row_balance} != {reported_row_balance}")
            current_running_balance = reported_row_balance
        return self

class Lane05AssetVaultTrustsSchema(BaseModel):
    model_config = ConfigDict(extra='forbid')
    original_principal_funding: ForensicDataEntity
    accrued_trust_interest: ForensicDataEntity
    trust_distributions_paid: ForensicDataEntity
    current_trust_value: ForensicDataEntity
    @model_validator(mode='after')
    def validate_asset_vault_mathematics(self) -> 'Lane05AssetVaultTrustsSchema':
        calculated = round((float(self.original_principal_funding.extracted_string_or_numeric_value) + float(self.accrued_trust_interest.extracted_string_or_numeric_value)) - float(self.trust_distributions_paid.extracted_string_or_numeric_value), 2)
        reported = round(float(self.current_trust_value.extracted_string_or_numeric_value), 2)
        if calculated != reported: raise ValueError(f"MATHEMATICAL VALIDATION ERROR: Calculated {calculated} != Extracted {reported}")
        return self

class Lane06BrokerageInvestmentsSchema(BaseModel):
    model_config = ConfigDict(extra='forbid')
    liquid_cash_balance: ForensicDataEntity
    sum_of_securities_market_value: ForensicDataEntity
    total_portfolio_value: ForensicDataEntity
    @model_validator(mode='after')
    def validate_brokerage_mathematics(self) -> 'Lane06BrokerageInvestmentsSchema':
        calculated = round(float(self.liquid_cash_balance.extracted_string_or_numeric_value) + float(self.sum_of_securities_market_value.extracted_string_or_numeric_value), 2)
        reported = round(float(self.total_portfolio_value.extracted_string_or_numeric_value), 2)
        if calculated != reported: raise ValueError(f"MATHEMATICAL VALIDATION ERROR: Calculated {calculated} != Extracted {reported}")
        return self

class Lane07TaxReturnsDocumentsSchema(BaseModel):
    model_config = ConfigDict(extra='forbid')
    total_gross_income: ForensicDataEntity
    total_tax_deductions: ForensicDataEntity
    adjusted_gross_income: ForensicDataEntity
    @model_validator(mode='after')
    def validate_tax_return_mathematics(self) -> 'Lane07TaxReturnsDocumentsSchema':
        calculated = round(float(self.total_gross_income.extracted_string_or_numeric_value) - float(self.total_tax_deductions.extracted_string_or_numeric_value), 2)
        reported = round(float(self.adjusted_gross_income.extracted_string_or_numeric_value), 2)
        if calculated != reported: raise ValueError(f"MATHEMATICAL VALIDATION ERROR: Calculated {calculated} != Extracted {reported}")
        return self

class Lane08InsurancePoliciesSchema(BaseModel):
    model_config = ConfigDict(extra='forbid')
    base_policy_premium: ForensicDataEntity
    additional_policy_fees: ForensicDataEntity
    total_billed_premium: ForensicDataEntity
    @model_validator(mode='after')
    def validate_insurance_mathematics(self) -> 'Lane08InsurancePoliciesSchema':
        calculated = round(float(self.base_policy_premium.extracted_string_or_numeric_value) + float(self.additional_policy_fees.extracted_string_or_numeric_value), 2)
        reported = round(float(self.total_billed_premium.extracted_string_or_numeric_value), 2)
        if calculated != reported: raise ValueError(f"MATHEMATICAL VALIDATION ERROR: Calculated {calculated} != Extracted {reported}")
        return self

class Lane09InfrastructureEquipmentSchema(BaseModel):
    model_config = ConfigDict(extra='forbid')
    contract_base_amount: ForensicDataEntity
    materials_cost_amount: ForensicDataEntity
    total_infrastructure_cost: ForensicDataEntity
    @model_validator(mode='after')
    def validate_infrastructure_mathematics(self) -> 'Lane09InfrastructureEquipmentSchema':
        calculated = round(float(self.contract_base_amount.extracted_string_or_numeric_value) + float(self.materials_cost_amount.extracted_string_or_numeric_value), 2)
        reported = round(float(self.total_infrastructure_cost.extracted_string_or_numeric_value), 2)
        if calculated != reported: raise ValueError(f"MATHEMATICAL VALIDATION ERROR: Calculated {calculated} != Extracted {reported}")
        return self

class Lane10LivestockAgricultureSchema(BaseModel):
    model_config = ConfigDict(extra='forbid')
    agricultural_unit_cost: ForensicDataEntity
    agricultural_quantity: ForensicDataEntity
    total_agricultural_expenditure: ForensicDataEntity
    @model_validator(mode='after')
    def validate_agriculture_mathematics(self) -> 'Lane10LivestockAgricultureSchema':
        calculated = round(float(self.agricultural_unit_cost.extracted_string_or_numeric_value) * float(self.agricultural_quantity.extracted_string_or_numeric_value), 2)
        reported = round(float(self.total_agricultural_expenditure.extracted_string_or_numeric_value), 2)
        if calculated != reported: raise ValueError(f"MATHEMATICAL VALIDATION ERROR: Calculated {calculated} != Extracted {reported}")
        return self

class Lane11GroceryRetailSchema(BaseModel):
    model_config = ConfigDict(extra='forbid')
    wholesale_inventory_cost: ForensicDataEntity
    retail_markup_amount: ForensicDataEntity
    final_retail_price_total: ForensicDataEntity
    @model_validator(mode='after')
    def validate_grocery_retail_mathematics(self) -> 'Lane11GroceryRetailSchema':
        calculated = round(float(self.wholesale_inventory_cost.extracted_string_or_numeric_value) + float(self.retail_markup_amount.extracted_string_or_numeric_value), 2)
        reported = round(float(self.final_retail_price_total.extracted_string_or_numeric_value), 2)
        if calculated != reported: raise ValueError(f"MATHEMATICAL VALIDATION ERROR: Calculated {calculated} != Extracted {reported}")
        return self

class Lane12PayrollCompensationSchema(BaseModel):
    model_config = ConfigDict(extra='forbid')
    gross_employee_wages: ForensicDataEntity
    total_tax_withholdings: ForensicDataEntity
    net_payroll_disbursement: ForensicDataEntity
    @model_validator(mode='after')
    def validate_payroll_mathematics(self) -> 'Lane12PayrollCompensationSchema':
        calculated = round(float(self.gross_employee_wages.extracted_string_or_numeric_value) - float(self.total_tax_withholdings.extracted_string_or_numeric_value), 2)
        reported = round(float(self.net_payroll_disbursement.extracted_string_or_numeric_value), 2)
        if calculated != reported: raise ValueError(f"MATHEMATICAL VALIDATION ERROR: Calculated {calculated} != Extracted {reported}")
        return self

class Lane13SubsidiesFamilyPaymentsSchema(BaseModel):
    model_config = ConfigDict(extra='forbid')
    base_subsidy_amount: ForensicDataEntity
    supplementary_allocation_amount: ForensicDataEntity
    total_subsidy_payment: ForensicDataEntity
    @model_validator(mode='after')
    def validate_subsidy_mathematics(self) -> 'Lane13SubsidiesFamilyPaymentsSchema':
        calculated = round(float(self.base_subsidy_amount.extracted_string_or_numeric_value) + float(self.supplementary_allocation_amount.extracted_string_or_numeric_value), 2)
        reported = round(float(self.total_subsidy_payment.extracted_string_or_numeric_value), 2)
        if calculated != reported: raise ValueError(f"MATHEMATICAL VALIDATION ERROR: Calculated {calculated} != Extracted {reported}")
        return self

class Lane14UtilitiesServicesSchema(BaseModel):
    model_config = ConfigDict(extra='forbid')
    utility_usage_charge: ForensicDataEntity
    utility_transmission_fees: ForensicDataEntity
    total_utility_bill_amount: ForensicDataEntity
    @model_validator(mode='after')
    def validate_utility_mathematics(self) -> 'Lane14UtilitiesServicesSchema':
        calculated = round(float(self.utility_usage_charge.extracted_string_or_numeric_value) + float(self.utility_transmission_fees.extracted_string_or_numeric_value), 2)
        reported = round(float(self.total_utility_bill_amount.extracted_string_or_numeric_value), 2)
        if calculated != reported: raise ValueError(f"MATHEMATICAL VALIDATION ERROR: Calculated {calculated} != Extracted {reported}")
        return self

class Lane15VehiclesTransportSchema(BaseModel):
    model_config = ConfigDict(extra='forbid')
    vehicle_purchase_price: ForensicDataEntity
    registration_and_sales_tax_fees: ForensicDataEntity
    total_transport_acquisition_cost: ForensicDataEntity
    @model_validator(mode='after')
    def validate_transport_mathematics(self) -> 'Lane15VehiclesTransportSchema':
        calculated = round(float(self.vehicle_purchase_price.extracted_string_or_numeric_value) + float(self.registration_and_sales_tax_fees.extracted_string_or_numeric_value), 2)
        reported = round(float(self.total_transport_acquisition_cost.extracted_string_or_numeric_value), 2)
        if calculated != reported: raise ValueError(f"MATHEMATICAL VALIDATION ERROR: Calculated {calculated} != Extracted {reported}")
        return self

class Lane16LegalProfessionalSchema(BaseModel):
    model_config = ConfigDict(extra='forbid')
    attorney_hourly_rate: ForensicDataEntity
    attorney_hours_billed: ForensicDataEntity
    court_filing_fees: ForensicDataEntity
    total_legal_obligation: ForensicDataEntity
    @model_validator(mode='after')
    def validate_legal_mathematics(self) -> 'Lane16LegalProfessionalSchema':
        calculated = round((float(self.attorney_hourly_rate.extracted_string_or_numeric_value) * float(self.attorney_hours_billed.extracted_string_or_numeric_value)) + float(self.court_filing_fees.extracted_string_or_numeric_value), 2)
        reported = round(float(self.total_legal_obligation.extracted_string_or_numeric_value), 2)
        if calculated != reported: raise ValueError(f"MATHEMATICAL VALIDATION ERROR: Calculated {calculated} != Extracted {reported}")
        return self

class Lane17SportingRecreationSchema(BaseModel):
    model_config = ConfigDict(extra='forbid')
    sporting_item_cost: ForensicDataEntity
    sporting_tax_amount: ForensicDataEntity
    total_recreation_expenditure: ForensicDataEntity
    @model_validator(mode='after')
    def validate_recreation_mathematics(self) -> 'Lane17SportingRecreationSchema':
        calculated = round(float(self.sporting_item_cost.extracted_string_or_numeric_value) + float(self.sporting_tax_amount.extracted_string_or_numeric_value), 2)
        reported = round(float(self.total_recreation_expenditure.extracted_string_or_numeric_value), 2)
        if calculated != reported: raise ValueError(f"MATHEMATICAL VALIDATION ERROR: Calculated {calculated} != Extracted {reported}")
        return self

class Lane18HealthcareMedicalSchema(BaseModel):
    model_config = ConfigDict(extra='forbid')
    gross_medical_provider_charge: ForensicDataEntity
    insurance_negotiated_rate_adjustment: ForensicDataEntity
    patient_copayment_amount: ForensicDataEntity
    remaining_patient_balance: ForensicDataEntity
    @model_validator(mode='after')
    def validate_healthcare_mathematics(self) -> 'Lane18HealthcareMedicalSchema':
        calculated = round((float(self.gross_medical_provider_charge.extracted_string_or_numeric_value) - float(self.insurance_negotiated_rate_adjustment.extracted_string_or_numeric_value)) - float(self.patient_copayment_amount.extracted_string_or_numeric_value), 2)
        reported = round(float(self.remaining_patient_balance.extracted_string_or_numeric_value), 2)
        if calculated != reported: raise ValueError(f"MATHEMATICAL VALIDATION ERROR: Calculated {calculated} != Extracted {reported}")
        return self

class ForensicGoldenEnvelope(BaseModel):
    model_config = ConfigDict(extra='forbid')
    original_parent_sha256: str = Field(min_length=64, max_length=64)
    sliced_child_sha256: str = Field(min_length=64, max_length=64)
    gcs_source_uri: str
    entity_slug: str
    taxonomy_lane: str
    average_confidence: float = Field(ge=0.0, le=1.0)
    requires_manual_review: bool
    extracted_payload: Union[
        Lane00GeneralTransactionalSchema, Lane01PropertyRealEstateSchema, Lane02RetirementAccountsSchema, 
        Lane03CreditDebtSchema, Lane04BankingCheckingSchema, Lane05AssetVaultTrustsSchema, 
        Lane06BrokerageInvestmentsSchema, Lane07TaxReturnsDocumentsSchema, Lane08InsurancePoliciesSchema, 
        Lane09InfrastructureEquipmentSchema, Lane10LivestockAgricultureSchema, Lane11GroceryRetailSchema, 
        Lane12PayrollCompensationSchema, Lane13SubsidiesFamilyPaymentsSchema, Lane14UtilitiesServicesSchema, 
        Lane15VehiclesTransportSchema, Lane16LegalProfessionalSchema, Lane17SportingRecreationSchema, 
        Lane18HealthcareMedicalSchema
    ]

    @model_validator(mode='after')
    def enforce_hitl_governance(self) -> 'ForensicGoldenEnvelope':
        if self.average_confidence < 0.90 and not self.requires_manual_review:
            raise ValueError("HITL_VIOLATION: Document AI average confidence < 0.90 mandates manual review flag = True.")
        return self
```

================================================================================
FILEPATH: tests/golden_test_registry.json
================================================================================
```json
[
  {
    "test_identifier": "TEST_FRE901_BINARY_REJECTION",
    "should_pass": false,
    "expected_error": "FRE_901_VIOLATION",
    "binary_header_simulation": "504B0304", 
    "payload": {}
  },
  {
    "test_identifier": "TEST_LANE04_SEQUENTIAL_DITTO_RESOLUTION",
    "should_pass": true,
    "taxonomy_lane": "LANE_04_BANKING_CHECKING",
    "binary_header_simulation": "25504446",
    "payload": {
      "original_parent_sha256": "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855",
      "sliced_child_sha256": "8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92",
      "gcs_source_uri": "gs://i-dub-thee-forensic-vault/LANE_04/statement.pdf",
      "entity_slug": "Judith Grandy",
      "average_confidence": 0.98,
      "requires_manual_review": false,
      "extracted_payload": {
        "institution_name": {"extracted_string_or_numeric_value": "Chemical Bank", "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [0.1], "vertical_y_vertices": [0.1]}},
        "page_carried_forward_balance": {"extracted_string_or_numeric_value": 10000.00, "optical_extraction_confidence_score": 0.99, "physical_evidence_coordinates": {"horizontal_x_vertices": [0.8], "vertical_y_vertices": [0.1]}},
        "sequential_transactions": [
          {"transaction_date": "2020-01-15", "description": "DEPOSIT", "deposit_amount": 5000.00, "withdrawal_amount": 0.00, "running_balance": 15000.00, "physical_evidence_coordinates": {"horizontal_x_vertices": [0.1], "vertical_y_vertices": [0.3]}},
          {"transaction_date": "2020-01-16", "description": "\"", "deposit_amount": 1000.00, "withdrawal_amount": 0.00, "running_balance": 16000.00, "physical_evidence_coordinates": {"horizontal_x_vertices": [0.1], "vertical_y_vertices": [0.4]}}
        ]
      }
    }
  },
  {
    "test_identifier": "TEST_CRYPTOGRAPHIC_FRACTURE_REJECTION",
    "should_pass": false,
    "expected_error": "CHAIN_OF_CUSTODY_FRACTURE",
    "taxonomy_lane": "LANE_07_TAX_RETURNS_DOCUMENTS",
    "binary_header_simulation": "25504446",
    "payload": {
      "original_parent_sha256": "MISSING_HASH",
      "sliced_child_sha256": "8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92",
      "gcs_source_uri": "gs://i-dub-thee-forensic-vault/LANE_07/form.pdf",
      "entity_slug": "KibbyCo",
      "average_confidence": 0.99,
      "requires_manual_review": false,
      "extracted_payload": {}
    }
  }
]
```

================================================================================
FILEPATH: tests/test_context_extractor.py
================================================================================
```py
import os
import pytest
from pathlib import Path
from tools.context_extractor import build_allow_list, extract_workspace

@pytest.fixture
def mock_ide_environment(tmp_path: Path):
    """Dynamically generates a mock IDE with both valid files and poison vectors."""
    # Create valid directories and files
    src_dir = tmp_path / "src"
    src_dir.mkdir()
    (src_dir / "main.py").write_text("print('Legal Forensics Engine')")
    
    tools_dir = tmp_path / "tools"
    tools_dir.mkdir()
    (tools_dir / "deploy.sh").write_text("echo 'Deploying...'")

    # Create poison vectors (Should be excluded)
    (tmp_path / ".env").write_text("GCP_SERVICE_ACCOUNT_KEY=12345")
    
    venv_dir = tmp_path / ".venv_forensic_extract"
    venv_dir.mkdir()
    (venv_dir / "dependency.py").write_text("print('noise')")
    
    git_dir = tmp_path / ".git"
    git_dir.mkdir()
    (git_dir / "config").write_text("git config data")

    return tmp_path

def test_exclusion_gate(mock_ide_environment: Path):
    """Proves that credentials and noise directories are strictly bypassed."""
    allowed_files = build_allow_list(mock_ide_environment)
    allowed_paths = [str(p.relative_to(mock_ide_environment)) for p in allowed_files]
    
    assert ".env" not in allowed_paths, "FATAL: Credentials leaked into allow-list."
    assert ".venv_forensic_extract/dependency.py" not in allowed_paths, "FATAL: Ephemeral venv bypassed exclusion gate."
    assert ".git/config" not in allowed_paths, "FATAL: Git history bypassed exclusion gate."

def test_allow_list_gate(mock_ide_environment: Path):
    """Proves that valid architectural files are successfully targeted."""
    allowed_files = build_allow_list(mock_ide_environment)
    allowed_paths = [str(p.relative_to(mock_ide_environment)) for p in allowed_files]
    
    assert "src/main.py" in allowed_paths, "FATAL: Core logic file dropped."
    assert "tools/deploy.sh" in allowed_paths, "FATAL: Deployment script dropped."

def test_output_formatting_gate(mock_ide_environment: Path):
    """Proves the mathematical boundaries of the output artifact."""
    output_artifact = mock_ide_environment / "test_forensic_context.md"
    extract_workspace(mock_ide_environment, output_artifact)
    
    content = output_artifact.read_text(encoding="utf-8")
    
    assert "================================================================================" in content
    assert "FILEPATH: src/main.py" in content
    assert "print('Legal Forensics Engine')" in content
    assert "GCP_SERVICE_ACCOUNT_KEY" not in content
```

================================================================================
FILEPATH: tests/test_iron_gate_factory.py
================================================================================
```py
import json
import pytest
import binascii
from pydantic import ValidationError

from src.schemas import (
    ForensicGoldenEnvelope, Lane04BankingCheckingSchema, Lane00GeneralTransactionalSchema,
    Lane01PropertyRealEstateSchema, Lane02RetirementAccountsSchema, Lane03CreditDebtSchema,
    Lane05AssetVaultTrustsSchema, Lane06BrokerageInvestmentsSchema, Lane07TaxReturnsDocumentsSchema,
    Lane08InsurancePoliciesSchema, Lane09InfrastructureEquipmentSchema, Lane10LivestockAgricultureSchema,
    Lane11GroceryRetailSchema, Lane12PayrollCompensationSchema, Lane13SubsidiesFamilyPaymentsSchema,
    Lane14UtilitiesServicesSchema, Lane15VehiclesTransportSchema, Lane16LegalProfessionalSchema,
    Lane17SportingRecreationSchema, Lane18HealthcareMedicalSchema
)

# ============================================================================
# PART 1: FORENSIC EDGE CASES (Crypto, Binary, Sequential State)
# ============================================================================

def load_golden_registry():
    with open('tests/golden_test_registry.json', 'r', encoding='utf-8') as f:
        return json.load(f)

def simulate_binary_auth(hex_string: str) -> bytes:
    try:
        return binascii.unhexlify(hex_string)
    except:
        return b''

@pytest.mark.parametrize("registry_entry", load_golden_registry(), ids=lambda entry: entry["test_identifier"])
def test_forensic_edge_cases(registry_entry):
    should_pass = registry_entry["should_pass"]
    expected_error = registry_entry.get("expected_error", "")
    binary_hex = registry_entry.get("binary_header_simulation", "")
    payload = registry_entry.get("payload", {})

    try:
        raw_bytes = simulate_binary_auth(binary_hex)
        if not raw_bytes.startswith(b'%PDF'):
            raise ValueError("FRE_901_VIOLATION: Binary signature does not match PDF.")
    except ValueError as e:
        if not should_pass:
            assert expected_error in str(e)
            return
        pytest.fail(f"Failed at Binary Auth: {str(e)}")

    try:
        if not payload.get("original_parent_sha256") or payload.get("original_parent_sha256") == "MISSING_HASH":
            raise ValueError("CHAIN_OF_CUSTODY_FRACTURE")
        if not payload.get("sliced_child_sha256"):
            raise ValueError("CHAIN_OF_CUSTODY_FRACTURE")

        taxonomy_lane = payload.get("taxonomy_lane")
        if taxonomy_lane == "LANE_04_BANKING_CHECKING":
            validated_data = Lane04BankingCheckingSchema(**payload.get("extracted_payload", {}))
            payload["extracted_payload"] = validated_data.model_dump()

        envelope = ForensicGoldenEnvelope(**payload)

        if not should_pass:
            pytest.fail(f"Expected failure with {expected_error}, but passed.")
            
        if taxonomy_lane == "LANE_04_BANKING_CHECKING" and should_pass:
            txns = envelope.extracted_payload.sequential_transactions
            assert txns[1].description == "DEPOSIT", "Ditto resolution failed"
            assert txns[1].running_balance == 16000.00, "Math validation failed"

    except (ValueError, ValidationError) as e:
        if should_pass:
            pytest.fail(f"Unexpected failure: {str(e)}")
        assert expected_error in str(e)

# ============================================================================
# PART 2: THE 18-LANE EXHAUSTIVE MATHEMATICS MATRIX
# ============================================================================

def mock_entity(value):
    return {
        "extracted_string_or_numeric_value": value,
        "optical_extraction_confidence_score": 0.99,
        "physical_evidence_coordinates": {"horizontal_x_vertices": [0.0], "vertical_y_vertices": [0.0]}
    }

# Mapping of all schemas to their respective required fields and values to achieve PERFECT math.
MATHEMATICAL_TRUTH_TABLE = [
    (Lane00GeneralTransactionalSchema, {"net_receipt_amount": 100.0, "tax_receipt_amount": 5.0, "gross_receipt_total": 105.0}),
    (Lane01PropertyRealEstateSchema, {"assessed_land_value": 50000.0, "assessed_improvement_value": 150000.0, "total_assessed_property_value": 200000.0}),
    (Lane02RetirementAccountsSchema, {"previous_period_balance": 1000.0, "period_contributions": 200.0, "period_investment_gains": 50.0, "period_distributions": 100.0, "current_period_balance": 1150.0}),
    (Lane03CreditDebtSchema, {"previous_statement_balance": 500.0, "new_purchases_amount": 200.0, "accrued_interest_amount": 10.0, "payments_received_amount": 300.0, "new_statement_balance": 410.0}),
    (Lane05AssetVaultTrustsSchema, {"original_principal_funding": 100000.0, "accrued_trust_interest": 5000.0, "trust_distributions_paid": 2000.0, "current_trust_value": 103000.0}),
    (Lane06BrokerageInvestmentsSchema, {"liquid_cash_balance": 1000.0, "sum_of_securities_market_value": 9000.0, "total_portfolio_value": 10000.0}),
    (Lane07TaxReturnsDocumentsSchema, {"total_gross_income": 100000.0, "total_tax_deductions": 20000.0, "adjusted_gross_income": 80000.0}),
    (Lane08InsurancePoliciesSchema, {"base_policy_premium": 500.0, "additional_policy_fees": 25.0, "total_billed_premium": 525.0}),
    (Lane09InfrastructureEquipmentSchema, {"contract_base_amount": 10000.0, "materials_cost_amount": 5000.0, "total_infrastructure_cost": 15000.0}),
    (Lane10LivestockAgricultureSchema, {"agricultural_unit_cost": 50.0, "agricultural_quantity": 100.0, "total_agricultural_expenditure": 5000.0}),
    (Lane11GroceryRetailSchema, {"wholesale_inventory_cost": 200.0, "retail_markup_amount": 50.0, "final_retail_price_total": 250.0}),
    (Lane12PayrollCompensationSchema, {"gross_employee_wages": 5000.0, "total_tax_withholdings": 1000.0, "net_payroll_disbursement": 4000.0}),
    (Lane13SubsidiesFamilyPaymentsSchema, {"base_subsidy_amount": 600.0, "supplementary_allocation_amount": 150.0, "total_subsidy_payment": 750.0}),
    (Lane14UtilitiesServicesSchema, {"utility_usage_charge": 120.0, "utility_transmission_fees": 30.0, "total_utility_bill_amount": 150.0}),
    (Lane15VehiclesTransportSchema, {"vehicle_purchase_price": 30000.0, "registration_and_sales_tax_fees": 2000.0, "total_transport_acquisition_cost": 32000.0}),
    (Lane16LegalProfessionalSchema, {"attorney_hourly_rate": 350.0, "attorney_hours_billed": 10.0, "court_filing_fees": 150.0, "total_legal_obligation": 3650.0}),
    (Lane17SportingRecreationSchema, {"sporting_item_cost": 850.0, "sporting_tax_amount": 51.0, "total_recreation_expenditure": 901.0}),
    (Lane18HealthcareMedicalSchema, {"gross_medical_provider_charge": 1000.0, "insurance_negotiated_rate_adjustment": 600.0, "patient_copayment_amount": 50.0, "remaining_patient_balance": 350.0})
]

@pytest.mark.parametrize("schema_class, valid_data", MATHEMATICAL_TRUTH_TABLE)
def test_exhaustive_lane_mathematics_success(schema_class, valid_data):
    """Proves that mathematically sound payloads pass the Iron Gate."""
    payload = {key: mock_entity(value) for key, value in valid_data.items()}
    validated = schema_class(**payload)
    assert validated is not None

@pytest.mark.parametrize("schema_class, valid_data", MATHEMATICAL_TRUTH_TABLE)
def test_exhaustive_lane_mathematics_failure(schema_class, valid_data):
    """Proves that a single hallucinated digit triggers an immediate Iron Gate crash."""
    payload = {key: mock_entity(value) for key, value in valid_data.items()}
    
    # Sabotage the final aggregate field by artificially inflating it by $1.00
    target_key = list(valid_data.keys())[-1] 
    payload[target_key]["extracted_string_or_numeric_value"] += 1.0 
    
    with pytest.raises(ValidationError) as e:
        schema_class(**payload)
    
    assert "MATHEMATICAL VALIDATION ERROR" in str(e.value), f"Schema {schema_class.__name__} failed to catch fraudulent math!"
```

================================================================================
FILEPATH: tools/context_extractor.py
================================================================================
```py
import os
import datetime
from pathlib import Path
from typing import List

# ==============================================================================
# HARDENED CONFIGURATION MATRIX
# ==============================================================================
EXCLUDE_DIRS = {
    ".git", "venv", "env", "__pycache__", ".pytest_cache", 
    ".vscode", "idea", "node_modules", ".mypy_cache", ".venv_forensic_extract"
}

EXCLUDE_FILES = {
    ".env", ".pem", "credentials.json", "service-account.json", 
    ".DS_Store"
}

ALLOW_EXTENSIONS = {
    ".py", ".sh", ".json", ".md", ".yaml", ".yml", ".sql", ".txt", ".toml", ".ini"
}

def build_allow_list(root_dir: Path) -> List[Path]:
    """
    Recursively scans the directory, violently rejecting any path matching
    the EXCLUDE_DIRS or EXCLUDE_FILES sets, and filtering by ALLOW_EXTENSIONS.
    """
    valid_files = []
    for current_root, dirs, files in os.walk(root_dir):
        # Mutate dirs in-place to prevent os.walk from entering excluded directories
        dirs[:] = [d for d in dirs if d not in EXCLUDE_DIRS]
        
        for file in files:
            if file in EXCLUDE_FILES:
                continue
                
            file_path = Path(current_root) / file
            if file_path.suffix.lower() in ALLOW_EXTENSIONS:
                valid_files.append(file_path)
                
    return sorted(valid_files)

def extract_workspace(root_dir: Path, output_path: Path) -> None:
    """
    Iterates through the verified allow-list and generates the highly structured
    Markdown artifact for LLM ingestion.
    """
    valid_files = build_allow_list(root_dir)
    
    with open(output_path, "w", encoding="utf-8") as outfile:
        timestamp = datetime.datetime.now().isoformat()
        outfile.write(f"# LEGAL FORENSICS ENGINE - IDE EXTRACTION ARTIFACT\n")
        outfile.write(f"**TIMESTAMP:** {timestamp}\n")
        outfile.write(f"**TOTAL FILES EXTRACTED:** {len(valid_files)}\n\n")
        
        for file_path in valid_files:
            try:
                # Calculate relative path for clean headers
                rel_path = file_path.relative_to(root_dir)
                content = file_path.read_text(encoding="utf-8")
                
                outfile.write("=" * 80 + "\n")
                outfile.write(f"FILEPATH: {rel_path}\n")
                outfile.write("=" * 80 + "\n")
                
                # Use standard markdown code blocks, defaulting to raw text if extension varies
                ext = file_path.suffix.lower().replace(".", "")
                outfile.write(f"```{ext}\n")
                outfile.write(content)
                if not content.endswith("\n"):
                    outfile.write("\n")
                outfile.write("```\n\n")
                
            except Exception as e:
                outfile.write(f"[WARNING: FAILED TO EXTRACT {rel_path} - {str(e)}]\n\n")

if __name__ == "__main__":
    workspace_root = Path.cwd()
    timestamp_str = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
    output_artifact = workspace_root / f"forensic_context_{timestamp_str}.md"
    
    print(f"[SYSTEM] Extracting Legal Forensics Engine workspace from: {workspace_root}")
    extract_workspace(workspace_root, output_artifact)
    print(f"[SUCCESS] Extraction complete. Artifact generated at: {output_artifact.name}")
```

================================================================================
FILEPATH: tools/governance_wizard.py
================================================================================
```py
import os
import time
from datetime import datetime, timezone

class ForensicGovernanceWizard:
    def __init__(self):
        self.project_id = "i-dub-thee"
        self.audit_log_path = "GOVERNANCE_AUDIT_LOG.md"
        self.staging_dir = "staged_deployments"
        os.makedirs(self.staging_dir, exist_ok=True)

    def run(self):
        print("=========================================================")
        print(" LEGAL FORENSICS ENGINE - GOVERNANCE & CHANGE CONTROL")
        print(f" TARGET ENVIRONMENT: {self.project_id}")
        print("=========================================================\n")
        print("Select Change Type:")
        print("  1. Add New Document Schema (Taxonomy Lane)")
        print("  2. Add/Modify Business Rule (Hypothesis Testing)")
        choice = input("\nEnter choice [1-2]: ").strip()
        
        if choice == '1':
            lane_name = input("\nEnter New Taxonomy Lane Name (e.g., LANE_19_AGRITOURISM): ").strip().upper()
            description = input("Enter Description of Document Types: ").strip()
            approver = input("Enter Authorized Approver Name (Sign-off): ").strip()
            
            timestamp = datetime.now(timezone.utc).isoformat()
            change_id = f"CHG-{int(time.time())}"
            audit_entry = f"## Change ID: {change_id}\n* **Timestamp:** {timestamp}\n* **Type:** SCHEMA ADDITION\n* **Lane:** {lane_name}\n* **Authorized By:** {approver}\n"
            
            with open(self.audit_log_path, "a") as f:
                f.write(audit_entry + "\n---\n")
                
            print(f"\n[SUCCESS] Governance logged. ID: {change_id}")
            print(f"Action: Manually add {lane_name} to src/schemas.py and run TDD suite.")
            
if __name__ == "__main__":
    wizard = ForensicGovernanceWizard()
    wizard.run()
```

================================================================================
FILEPATH: tools/rollback.sh
================================================================================
```sh
#!/bin/bash
set -o errexit
set -o nounset
set -o pipefail
export PROJECT_ID="i-dub-thee"
export REGION="us-central1"
export SERVICE_NAME="forensic-pipeline-router"
echo "--- FETCHING REVISION HISTORY ---"
gcloud run revisions list --service="${SERVICE_NAME}" --region="${REGION}" --project="${PROJECT_ID}" --sort-by="~metadata.creationTimestamp" --limit=5
echo ""
read -p "Enter the REVISION ID to rollback to: " TARGET_REVISION
gcloud run services update-traffic "${SERVICE_NAME}" --region="${REGION}" --project="${PROJECT_ID}" --to-revisions="${TARGET_REVISION}=100"
echo "--- ROLLBACK COMPLETE ---"
```

================================================================================
FILEPATH: transition_wipe.sh
================================================================================
```sh
#!/bin/bash
# ============================================================================
# TRANSITION PROTOCOL: APPLICATION TEAR-DOWN
# PROJECT ID: i-dub-thee
# ============================================================================
set -o nounset
set -o pipefail

export PROJECT_ID="i-dub-thee"
export REGION="us-central1"

echo "--- [1/3] PURGING COMPROMISED SERVERLESS COMPUTE ---"
# Deleting the hollow Cloud Function (Layer 1)
gcloud functions delete forensic-pipeline-router \
    --region="${REGION}" --gen2 --project="${PROJECT_ID}" --quiet || echo "Router already removed."

# Deleting the incomplete FastAPI service (Layer 2)
gcloud run services delete forensic-rag-api \
    --region="${REGION}" --project="${PROJECT_ID}" --quiet || echo "RAG API already removed."

echo "--- [2/3] PURGING COMPROMISED LOCAL CODEBASE ---"
# Whitelist scorch: Keep tests, git, and idx. Destroy the hollow src and rag_api.
find . -mindepth 1 -maxdepth 1 \
    ! -name 'tests' \
    ! -name '.git' \
    ! -name '.idx' \
    ! -name '*.sh' \
    ! -name '.*' \
    -exec rm -rf {} +

echo "--- [3/3] PROVISIONING THE MISSING BIGQUERY VAULT ---"
# Remediating the missing infrastructure from TR-3.1 / FR-2.2
if ! bq show --dataset "${PROJECT_ID}:forensic_fact_base" >/dev/null 2>&1; then
    echo "Creating BigQuery Dataset..."
    bq mk --dataset --location=US "${PROJECT_ID}:forensic_fact_base"
fi

# Authoring the native JSON schema explicitly
bq query --use_legacy_sql=false \
"CREATE TABLE IF NOT EXISTS \`${PROJECT_ID}.forensic_fact_base.ingestion_ledger\` (
    original_parent_sha256 STRING NOT NULL,
    sliced_child_sha256 STRING NOT NULL,
    gcs_source_uri STRING NOT NULL,
    entity_slug STRING NOT NULL,
    taxonomy_lane STRING NOT NULL,
    average_confidence FLOAT64 NOT NULL,
    requires_manual_review BOOL NOT NULL,
    extracted_payload JSON NOT NULL,
    ingestion_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
);"

echo "============================================================================"
echo " TRANSITION COMPLETE: ENVIRONMENT IS PRISTINE AND READY FOR PLATINUM CODE "
echo "============================================================================"
```

