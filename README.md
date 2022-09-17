# CLOVoc App FHIR Tabulator

The CLOVoc App FHIR Tabulator pulls JSON resources from a FHIR API, tabluates against custom table descriptions, and exports as tabular files.

## Quickstart

1. Make sure R is installed on your local machine or remote server where the tabulator is deployed.

2. Clone this repository:

```
$ git clone git@github.com:kids-first/clovoc-app-fhir-tabulator.git
$ cd clovoc-app-fhir-tabulator
```

3. Create a `.env` file in the root directory:

```
FHIR_API_URL="YOUR-FHIR-API-URL"
FHIR_API_COOKIE="YOUR-FHIR-API-COOKIE"
```

4. Put the list of cohort patients' FHIR resource IDs udner the `./input` folder.

5. Run the scripts. For example:

```
$ R < ./participant_details.R --save|--no-save|--vanilla
```

6. A tabular export will be created under the `./output` folder.

## Development

- To contribute to this repository, please follow [Google's R Stype Guide](https://google.github.io/styleguide/Rguide.html).
- Run the linter `./scripts/prettify.sh /path/to/code` before pushing commits.
