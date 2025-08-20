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
  input_dir   <- here("tests", "testdata")
  schema_dir  <- here("tests", "testdata", "schema")
  csv_files   <- list.files(input_dir, pattern = "\\.csv$", full.names = TRUE)
  con         <- connect_to_db()
  
  for (file in csv_files) {
    base_name  <- tools::file_path_sans_ext(basename(file)) %>% toupper()
    table_name <- glue("{cohort_prefix}_{base_name}")
    
    # JSON schema path
    json_file <- file.path(schema_dir, paste0(tools::file_path_sans_ext(basename(file)), ".json"))
    if (!file.exists(json_file)) {
      stop(glue("Schema JSON file does not exist for {basename(file)}"))
    }
    
    # Load schema
    schema_json <- jsonlite::fromJSON(json_file)
    
    # Load CSV as all character
    df <- readr::read_csv(file, col_types = readr::cols(.default = readr::col_character()), show_col_types = FALSE)
    
    # Check for exact column match
    csv_cols <- colnames(df)
    schema_cols <- names(schema_json)
    
    missing_cols <- setdiff(schema_cols, csv_cols)
    extra_cols   <- setdiff(csv_cols, schema_cols)
    
    if (length(missing_cols) > 0) {
      stop(glue("CSV {basename(file)} is missing columns: {paste(missing_cols, collapse=', ')}"))
    }
    
    if (length(extra_cols) > 0) {
      stop(glue("CSV {basename(file)} has extra columns not in schema: {paste(extra_cols, collapse=', ')}"))
    }
    
    # Convert columns to intended types
    for (col_name in schema_cols) {
      df[[col_name]] <- tryCatch(
        switch(
          schema_json[[col_name]],
          "character" = as.character(df[[col_name]]),
          "numeric"   = as.numeric(df[[col_name]]),
          "integer"   = as.integer(df[[col_name]]),
          "bigint"    = bit64::as.integer64(df[[col_name]]),
          "logical"   = as.logical(df[[col_name]]),
          "date"      = as.Date(df[[col_name]]),
          "datetime"  = as.POSIXct(df[[col_name]]),
          df[[col_name]]
        ),
        error = function(e) stop(glue("Error converting column {col_name} in {basename(file)} to type {schema_json[[col_name]]}: {e$message}"))
      )
    }
    
    # Save to DB
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
