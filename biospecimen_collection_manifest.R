#
# Entrypoint for tabulation of biospecimen collection manifest.
#
# Usage: R < ./biospecimen_collection_manifest.R --save|--no-save|--vanilla
#

source("global.R", local = TRUE)#


# Build a request URL for Specimen
specimen_request <- fhir_url(
    url = fhir_api_url,
    resource = "Specimen",
    parameters = c("subject" = patient_ids)
)

# Download Specimen reosurce bundles
specimen_bundles <- fhir_search(
    request = specimen_request, add_headers = cookies, verbose = 2
)

# Define a table description
# against the Biospecimen Collection Manifest template
specimen_description <- fhir_table_description(
    resource = "Specimen",
    cols = c(
        "Participant ID" = "subject/reference",
        "Specimen ID" = "id",
        "Consent Short Name" = "_consent_short_name",
        "Consent Group" = "_consent_group",
        "Specimen Type Name" = "type/text",
        "Specimen Type Ontology URI" = "type/coding/system",
        "Specimen Type Code" = "type/coding/code",
        "Body Site Name" = "collection/bodySite/text",
        "Body Site Ontology URI" = "collection/bodySite/coding/system",
        "Body Site Code" = "collection/bodySite/coding/code",
        "Age at Collection Value" = "collection/_collectedDateTime/extension/extension/valueDuration/value",
        "Age at Collection Units" = "collection/_collectedDateTime/extension/extension/valueDuration/unit",
        "Method of Sample Procurement" = "collection/method/text",
        "Ischemic Time" = "_ischemic_time",
        "Ischemic Units" = "_ischemic_units",
        "Parent Specimen ID" = "parent/reference",
        "Specimen Group ID" = "_specimen_group_id"
    ),
    sep = " ~ ",
    brackets = c("<<", ">>"),
    rm_empty_cols = FALSE,
    format = "wide"
)

# Flatten Specimen resources
biospecimen_collection_manifest <- fhir_crack(
    bundles = specimen_bundles, design = specimen_description, verbose = 2
)

# Drop columns
biospecimen_collection_manifest <- biospecimen_collection_manifest[
    ,
    !grepl(
        "<<1.2.1>>Specimen Type Ontology URI|<<1.2.1>>Specimen Type Code|<<1.3.1>>Specimen Type Ontology URI|<<1.3.1>>Specimen Type Code",
        names(biospecimen_collection_manifest)
    )
]

# Change column names
setnames(
    biospecimen_collection_manifest,
    old = c(
        "<<1.1>>Participant ID",
        "<<1>>Specimen ID",
        "<<1.1>>Specimen Type Name",
        "<<1.1.1>>Specimen Type Ontology URI",
        "<<1.1.1>>Specimen Type Code",
        "<<1.1.1>>Body Site Name",
        "<<1.1.1.1>>Body Site Ontology URI",
        "<<1.1.1.1>>Body Site Code"
    ),
    new = c(
        "Participant ID",
        "Specimen ID",
        "Specimen Type Name",
        "Specimen Type Ontology URI",
        "Specimen Type Code",
        "Body Site Name",
        "Body Site Ontology URI",
        "Body Site Code"
    )
)

# Extract patient IDs
biospecimen_collection_manifest$"Participant ID" <- lapply(
    biospecimen_collection_manifest$"Participant ID", ParsePatientID
)

# Replace NA with empty string
biospecimen_collection_manifest <- ReplaceNA(biospecimen_collection_manifest)

# Export as TSV
fwrite(
    biospecimen_collection_manifest,
    file = "./output/biospecimen_collection_manifest.tsv",
    sep = "\t",
    row.names = FALSE
)
