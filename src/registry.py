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
