#!/bin/bash
set -e
set -o pipefail

echo "============================================================================"
echo " INITIATING ENVIRONMENT PATCH: INSTALLING LAYER 1 DEPENDENCIES"
echo "============================================================================"

echo "[SYSTEM] 1. Updating requirements.txt..."
cat << 'EOF_REQ' > requirements.txt
google-cloud-aiplatform>=1.38.0
google-cloud-storage>=2.14.0
pydantic>=2.5.0
pytest>=7.4.0
pytest-asyncio>=0.23.5
pytest-mock>=3.12.0
EOF_REQ

echo "[SYSTEM] 2. Installing dependencies into active virtual environment..."
pip install -r requirements.txt --quiet

echo "[SYSTEM] 3. Executing Pytest Iron Gate (Expecting 100% Green State)..."
python3 -m pytest tests/test_layer1_refactor.py -v

echo "============================================================================"
echo " [AWAITING FINAL GREEN TELEMETRY]"
echo "============================================================================"
