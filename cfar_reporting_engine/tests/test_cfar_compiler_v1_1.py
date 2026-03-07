import pytest

# ==============================================================================
# IMPORT STUBS FOR FUTURE IMPLEMENTATION
# These will fail until the cfar_compiler.py is upgraded to V1.1.0.
# ==============================================================================
try:
    from cfar_compiler import (
        build_8f_discrepancy_table,
        build_tag_cloud_exhibit
    )
except ImportError:
    build_8f_discrepancy_table = None
    build_tag_cloud_exhibit = None

# ==============================================================================
# CFAR-4: ALIAS REGISTRY JOIN VALIDATION
# ==============================================================================
def test_cfar_alias_registry_join():
    """Validates the inclusion of the canonical_entity_id in the 8F Ledger."""
    if build_8f_discrepancy_table is None:
        pytest.skip("Implementation missing")
    
    # Mocking BigQuery RowIterator output from vw_paragraph_8f_parity_ledger 
    # joined with account_alias_registry
    mock_bq_rows = [
        {
            "resolved_entity": "JOINT_CHECKING_MAIN", # The Canonical ID
            "document_type": "Utility Bill", 
            "expense_category": "Total Amount Due", 
            "total_expense_amount": 1000.00, 
            "keith_owed_share": 300.00
        }
    ]
    
    table_markdown, total_shortfall = build_8f_discrepancy_table(mock_bq_rows)
    
    # Structural Proof (GFM Table layout must now include the Resolved Entity)
    assert "| Resolved Entity | Document Type | Expense Category | Total Expense | Keith's 30% Shortfall |" in table_markdown
    assert "| JOINT_CHECKING_MAIN | Utility Bill | Total Amount Due | $1,000.00 | $300.00 |" in table_markdown

# ==============================================================================
# CFAR-5: TAG CLOUD EXHIBIT GENERATION
# ==============================================================================
def test_tag_cloud_exhibit_generation():
    """Proves the engine formats the continuous metadata tags into Exhibit B."""
    if build_tag_cloud_exhibit is None:
        pytest.skip("Implementation missing")
    
    # Mocking BigQuery RowIterator output from vw_continuous_tag_cloud
    mock_bq_rows = [
        {
            "forensic_tag": "ASSET_DISSIPATION",
            "source_key": "Settlement Block",
            "flagged_context_text": "Net proceeds wired to separate account [FLAG: ASSET_DISSIPATION]",
            "gcs_source_uri": "gs://vault/annuity_surrender.pdf"
        }
    ]
    
    table_markdown = build_tag_cloud_exhibit(mock_bq_rows)
    
    # Structural Proof
    assert "## 🔍 EXHIBIT B: CONTINUOUS METADATA TAG CLOUD" in table_markdown
    assert "| Forensic Tag | Source Node | Flagged Context | Source Artifact |" in table_markdown
    assert "| ASSET_DISSIPATION | Settlement Block | Net proceeds wired to separate account [FLAG: ASSET_DISSIPATION] | [View Source](gs://vault/annuity_surrender.pdf) |" in table_markdown

