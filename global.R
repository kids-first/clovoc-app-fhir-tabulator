#
# Load into the global environment of the R session.
#

required_packages <- c(
    "dotenv",
    "fhircrackr",
    "data.table"
)

# Install or load dependencies
for (package in required_packages) {
    if (!require(package, character.only = TRUE)) {
        install.packages(package, repos = "http://cran.us.r-project.org")
        library(package, character.only = TRUE)
    }
}

# Load environmental variables
load_dot_env()

# Get FHIR credentails
fhir_api_url <- Sys.getenv("FHIR_API_URL")
fhir_api_cookie <- Sys.getenv("FHIR_API_COOKIE")

# Build global headers
cookies <- c(Cookie = fhir_api_cookie)

# Read in and parameterize the cohort patients' FHIR resource IDs
patient_ids <- read.csv(file = "./input/patient_ids.csv")
patient_ids <- paste(patient_ids$patient_id, collapse = ",")
