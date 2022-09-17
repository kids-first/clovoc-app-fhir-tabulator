#
# Entrypoint for tabulation of participant phenotypes.
#
# Usage: R < ./participant_phenotypes.R --save|--no-save|--vanilla
#

source("global.R", local = TRUE)


# Build a request URL for Condition (phenotypes)
condition_request <- fhir_url(
    url = fhir_api_url,
    resource = "Condition",
    parameters = c(
        "_profile:below" = "https://nih-ncpi.github.io/ncpi-fhir-ig/StructureDefinition/phenotype",
        "subject" = patient_ids
    )
)

# Download Condition reosurce bundles
condition_bundles <- fhir_search(
    request = condition_request, add_headers = cookies, verbose = 2
)

# Define a table description against the Participant Phenotypes template
condition_description <- fhir_table_description(
    resource = "Condition",
    cols = c(
        "Participant ID" = "subject/reference",
        "Age at Onset Value" = "_recordedDate/extension/extension/valueDuration/value",
        "Age at Onset Units" = "_recordedDate/extension/extension/valueDuration/unit",
        "Condition Prevalence Duration Value" = "_condition_prevalence_duration_value",
        "Condition Prevalence Duration Units" = "_condition_prevalence_duration_units",
        "Group" = "_group",
        "Age at Abatement Value" = "_age_at_abatement_value",
        "Age at Abatement Units" = "_age_at_abatement_units",
        "Condition Name" = "code/text",
        "Condition Ontology URI" = "code/coding/system",
        "Condition Code" = "code/coding/code",
        "Verification Status" = "verificationStatus/text",
        "Body Site Name" = "bodySite/text",
        "Body Site Ontology URI" = "bodySite/coding/system",
        "Body Site Code" = "bodySite/coding/code"
    ),
    sep = " ~ ",
    brackets = c("<<", ">>"),
    rm_empty_cols = FALSE,
    format = "compact"
)

# Flatten Condition resources
participant_phenotypes <- fhir_crack(
    bundles = condition_bundles,
    design = condition_description,
    verbose = 2
)

# Remove indices
participant_phenotypes <- fhir_rm_indices(
    participant_phenotypes, brackets = c("<<", ">>")
)

# Extract patient IDs
participant_phenotypes$"Participant ID" <- lapply(
    participant_phenotypes$"Participant ID", ParsePatientID
)

# Replace NA with empty string
participant_phenotypes <- ReplaceNA(participant_phenotypes)

# Export as TSV
fwrite(
    participant_phenotypes,
    file = "./output/participant_phenotypes.tsv",
    sep = "\t",
    row.names = FALSE
)
