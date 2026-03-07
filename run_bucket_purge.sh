#!/bin/bash
echo "============================================================================"
echo " INITIATING ZERO-TRUST PURGE: ERADICATING RECURSIVE GHOST ARTIFACTS"
echo "============================================================================"

# Physically target and destroy all mutated downstream artifacts
gcloud storage rm "gs://i-dub-thee-processed/**/*_Report*"

echo "============================================================================"
echo " [PURGE COMPLETE] THE MASTER FILING CABINET IS STERILIZED"
echo "============================================================================"
