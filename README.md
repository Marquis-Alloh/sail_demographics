
# SAIL Databank Demographic Data Curation

This project develops common-use, harmonised demographic data assets within the SAIL Databank, focusing on Welsh NHS data. 

Demographic variables such as date of birth, sex, ethnicity, and LSOA of residence are often fragmented across multiple sources with varying completeness. To address this, the project builds on successful harmonisation efforts by the BHF Data Science team in NHS England datasets, enabling consistent, streamlined access to core demographics.

By standardising key variables across sources, this resource supports improved data curation and research efficiency for studies within the CVD-COVID UK Consortium and beyond.

---

## Overview: Production vs Development Setup

The project uses an environment variable `APP_ENV` (set in `.Renviron` in project root) to control behavior:

- **`APP_ENV=prod`**  
  - Connects to the production database via ODBC.  
  - Loads and saves tables using schema-qualified names.  
  - Requires manual username and password input.  

- **`APP_ENV=dev`** (default)  
  - Connects to a local SQLite database (`tests/testdata/tests_pr_sail.sqlite`).  
  - Loads and saves tables using flattened table names (e.g., `SCHEMA__TABLE`).  
  - Designed for development, testing, and experimentation without affecting prod data.  
  - Running `dev/dev_load_test_csv_to_db.R` loads `.csv` files from `tests/testdata/` into the dev database.

---

## Directory Structure

```
sail_demographics/
├── .gitignore                  # Git ignore rules
├── .Renviron                   # Environment variables (e.g., APP_ENV=dev/prod)
├── codelists/                  # Code lists or lookup/reference data
├── dev/                        # Development-only scripts (run in dev only)
│   └── dev_load_test_csv_to_db.R  # Script to load CSVs into local dev DB
├── R/                          # Core R scripts and helper functions
│   ├── db_helpers.R            # DB connection and table loading/saving helpers
│   ├── project_config.R        # Database schema and table naming config
│   ├── curate_*.R              # Data curation and processing scripts
├── sail_demographics.Rproj     # RStudio project file
├── tests/
│   └── testdata/               # Test data and local SQLite database for dev
│       ├── *.csv               # CSV files containing sythetic data
│       └── tests_pr_sail.sqlite    # Local SQLite DB used in development
└── README.md                   # Project documentation and instructions

```

---

## Usage

### Setting the Environment

Set the environment variable `APP_ENV` to switch between prod and dev modes:

- In your project `.Renviron` file (create if missing):

  ```
  APP_ENV=dev
  ```

### Connecting to the Database

Use the provided helper function `connect_to_db()` (defined in `R/db_helpers.R`):

- In **prod**, connects via ODBC to `PR_SAIL` data source, prompting for credentials.
- In **dev**, connects to the local SQLite database at `tests/testdata/tests_pr_sail.sqlite`.

### Loading and Saving Tables

Use `load_db_table(con, schema, table)` and `save_db_table(con, schema, table, data)` to interact with tables:

- Table naming adapts to environment:  
  - Prod uses schema-qualified table names.  
  - Dev uses flattened names (e.g., `"SCHEMA__TABLE"`).

### Loading CSV Data in Development

Run the script `dev/dev_load_test_csv_to_db.R` **only in dev** to load `.csv` files from `tests/testdata/` into the local dev database:

```r
# This script automatically checks APP_ENV and runs only if 'dev'
source("dev/dev_load_test_csv_to_db.R")
```

---

## Notes

- Confirm `APP_ENV` before running scripts that write to the database.
- Store test data and the dev SQLite database in `tests/testdata/`.

---

## Contributors

- Marquis Alloh (BHF Data Science Centre)
- James Farrell (BHF Data Science Centre)
- John Nolan (BHF Data Science Centre)

---