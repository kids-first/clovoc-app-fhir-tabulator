#!/bin/bash

# Print linting a message(s) for enhanced readability and styling of code (optional)
# Make sure a lintr pacakge is installed (e.g. R -e "install.packages(\"lintr\", repos=\"http://cran.us.r-project.org\")")

# Usage: ./scripts/prettify.sh /path/to/code

set -eo pipefail

if [[ -z $1 ]];
then
    echo "❌ You must provide a path to code (e.g. ./app.R)"
    exit 1
fi

FILE_PATH=$1

R -e "lintr::lint('$FILE_PATH')"

echo "✅ linting suggestions for $FILE_PATH were generated!"
