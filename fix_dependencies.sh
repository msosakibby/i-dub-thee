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