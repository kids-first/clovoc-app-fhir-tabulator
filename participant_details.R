#
# Entrypoint for tabulation of participant details.
#
# Usage: R < ./participant_details.R --save|--no-save|--vanilla
#

source("global.R", local = TRUE)


# Step 1: Patient
# Build a request URL for Patient
patient_request <- fhir_url(
    url = fhir_api_url,
    resource = "Patient",
    parameters = c("_id" = patient_ids)
)

# Download Patient reosurce bundles
patient_bundles <- fhir_search(
    request = patient_request, add_headers = cookies, verbose = 2
)

# Define a table description against the Participant Details template
patient_description <- fhir_table_description(
    resource = "Patient",
    cols = c(
        "Family ID" = "_family_id",
        "Participant ID" = "id",
        "dbGaP Consent Code" = "_dbgap_consent_code",
        "Sex" = "_sex",
        "Gender" = "gender",
        "Race ~ Ethnicity" = "extension/extension/valueString",
        "Age at Study Enrollment Value" = "_age_at_study_enrollment_value",
        "Age at Study Enrollment Units" = "_age_at_study_enrollment_units",
        "Species" = "_species",
        "Education" = "_education",
        "Family Size" = "_family_size",
        "Annual Household Income ($)" = "_annual_household_income",
        "County of Residence" = "_country_of_residence",
        "Socio-Economic Index" = "_socio_economic_index"
    ),
    sep = " ~ ",
    brackets = c("<<", ">>"),
    rm_empty_cols = FALSE,
    format = "wide"
)

# Flatten Patient resources
patients <- fhir_crack(
    bundles = patient_bundles, design = patient_description, verbose = 2
)

# Change column names
setnames(
    patients,
    old = c(
        "<<1>>Participant ID",
        "<<1>>Gender",
        "<<1.1.1>>Race ~ Ethnicity",
        "<<2.1.1>>Race ~ Ethnicity"
    ),
    new = c("Participant ID", "Gender", "Race", "Ethnicity")
)


# Step 2: Observation (vital status)
# Build a request URL for Observation
observation_request <- fhir_url(
    url = fhir_api_url,
    resource = "Observation",
    parameters = c(
        "subject" = patient_ids,
        "code" = "http://snomed.info/sct|263493007"
    )
)

# Download Observation reosurce bundles
observation_bundles <- fhir_search(
    request = observation_request, add_headers = cookies, verbose = 2
)

# Define a table description against the Participant Details template
observation_description <- fhir_table_description(
    resource = "Observation",
    cols = c(
        "Participant ID" = "subject/reference",
        "Last Known Vital Status" = "valueCodeableConcept/text",
        "Age at Status Value" = paste(
            "_effectiveDateTime",
            "extension",
            "valueDuration",
            "value",
            sep = "/"
        ),
        "Age at Status Units" = paste(
            "_effectiveDateTime",
            "extension",
            "valueDuration",
            "unit",
            sep = "/"
        )
    ),
    sep = " ~ ",
    brackets = c("<<", ">>"),
    rm_empty_cols = FALSE,
    format = "compact"
)

# Flatten Observation resources
observations <- fhir_crack(
    bundles = observation_bundles,
    design = observation_description,
    verbose = 2
)

# Remove indices
observations <- fhir_rm_indices(observations, brackets = c("<<", ">>"))

# Extract patient IDs
observations$"Participant ID" <- lapply(
    observations$"Participant ID",
    function(x) {
        return(unlist(strsplit(x, "/"))[2])
    }
)


# Step 3: Left-join
participant_details = merge(
    patients,
    observations,
    by.x = "Participant ID",
    by.y = "Participant ID",
    all.x = TRUE
)


# Replace NA with empty string
participant_details <- replace(
    participant_details, is.na(participant_details), ""
)

# Export as TSV
write.table(
    participant_details,
    file = "./output/participant_details.tsv",
    sep = "\t",
    row.names = FALSE
)
