# =============================================================================
# Script: Load CSVs from tests/testdata/ into the database (dev only)
# =============================================================================

library(DBI)
library(readr)
library(stringr)
library(here)
library(glue)

# -----------------------------------------------------------------------------
# Load helper functions and config
# -----------------------------------------------------------------------------
source(here("R", "db_helpers.R"))
source(here("R", "project_config.R"))

# -----------------------------------------------------------------------------
# Main function
# -----------------------------------------------------------------------------
load_test_csvs_to_db <- function() {
  input_dir  <- here("tests", "testdata")
  csv_files  <- list.files(input_dir, pattern = "\\.csv$", full.names = TRUE)
  con        <- connect_to_db()
  
  for (file in csv_files) {
    base_name  <- tools::file_path_sans_ext(basename(file)) %>% toupper()
    table_name <- glue("{cohort_prefix}_{base_name}")
    df         <- readr::read_csv(file, show_col_types = FALSE)
    
    save_db_table(
      con = con,
      schema = schema_data,
      table = table_name,
      data = df,
      overwrite = TRUE
    )
    
    message(glue("Loaded {basename(file)} to DB as {schema_data}__{table_name}"))
  }
  
  DBI::dbDisconnect(con)
  message("Database connection closed.")
}

# -----------------------------------------------------------------------------
# Only run in dev mode
# -----------------------------------------------------------------------------
if (Sys.getenv("APP_ENV", unset = "dev") == "dev") {
  load_test_csvs_to_db()
} else {
  message("Skipping: `load_test_csvs_to_db()` only runs in dev (APP_ENV='dev').")
}
