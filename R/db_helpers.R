# =============================================================================
# Database Utilities for PR_SAIL
#
# Provides helper functions to:
# - Connect to the PR_SAIL database (ODBC in prod, SQLite in dev)
# - Load tables with environment-aware naming
# - Save tables with environment-aware naming
#
# Environment behavior:
# - Controlled via APP_ENV
# - APP_ENV is set in the project root `.Renviron` file (e.g., APP_ENV=prod)
# - If APP_ENV == "prod", uses schema-qualified names
# - Otherwise, uses dev-style "SCHEMA__TABLE" names
#
# Dependencies: DBI, dplyr, dbplyr, odbc, RSQLite, here, rstudioapi
#
# =============================================================================


#' Connect to PR_SAIL database based on environment
#'
#' Uses `APP_ENV` to determine connection:
#' - `prod`: Connects to PR_SAIL via ODBC (prompts for credentials)
#' - `dev`: Connects to local SQLite DB at `tests/testdata/tests_pr_sail.sqlite`
#'
#' @return A `DBIConnection` object
#' @export
connect_to_db <- function() {
  env <- Sys.getenv("APP_ENV", unset = "dev")
  
  if (env == "prod") {
    con <- DBI::dbConnect(
      odbc::odbc(),
      "PR_SAIL",
      uid = rstudioapi::askForPassword("Enter username"),
      password = rstudioapi::askForPassword("Enter password")
    )
  } else {
    con <- DBI::dbConnect(
      duckdb::duckdb(
        dbdir = here::here("tests", "testdata", "tests_pr_sail.duckdb"),
        bigint = "integer64"
      )
    )
  }
  
  return(con)
}


#' Load a database table based on environment
#'
#' Uses `APP_ENV` to determine table naming:
#' - `prod`: loads schema-qualified table via `in_schema()`
#' - `dev`: loads table as `SCHEMA__TABLE`
#'
#' @param con A DBI or dplyr connection object
#' @param schema Schema name as string
#' @param table Table name as string
#'
#' @return A lazy `dplyr::tbl` reference
#' @export
load_db_table <- function(con, schema, table) {
  if (is.null(con)) {
    stop("`con` (database connection) must not be NULL.")
  }
  
  stopifnot(is.character(schema), is.character(table))
  
  env <- Sys.getenv("APP_ENV", unset = "dev")
  
  if (env == "prod") {
    return(tbl_explicit(con, schema, table))
  } else {
    dev_table <- paste0(schema, "__", table)
    return(dplyr::tbl(con, dev_table))
  }
}


#' Create a lazy table with explicit column selection
#'
#' Avoids problematic `SELECT schema.*` queries by expanding all columns
#' explicitly in the SQL. Useful when working with databases or dialects
#' that do not support qualified wildcard selectors (e.g., `"SCHEMA".*`).
#'
#' @param con A `DBIConnection` object.
#' @param schema A string specifying the schema name.
#' @param table A string specifying the table name.
#'
#' @return A `tbl_dbi` lazy query object with explicit column selection.
#' @export
tbl_explicit <- function(con, schema, table) {
  full_table <- dbplyr::in_schema(schema, table)
  cols <- DBI::dbListFields(con, DBI::Id(schema = schema, table = table))
  
  quoted_cols <- DBI::dbQuoteIdentifier(con, cols)
  quoted_table <- DBI::dbQuoteIdentifier(con, DBI::Id(schema = schema, table = table))
  
  sql_query <- dbplyr::build_sql(
    "SELECT ",
    dbplyr::sql(paste(quoted_cols, collapse = ", ")),
    " FROM ",
    quoted_table,
    con = con
  )
  
  dplyr::tbl(con, dbplyr::sql(sql_query))
}


#' Save a data frame to a database table based on environment
#'
#' Uses `APP_ENV` to determine table naming:
#' - `prod`: writes to schema-qualified table via `DBI::Id()`
#' - `dev`: writes to table named `SCHEMA__TABLE`
#'
#' @param con A DBI connection object
#' @param schema Schema name
#' @param table Table name
#' @param data Data frame or tibble to write
#' @param overwrite Overwrite existing table? Default `FALSE`
#' @param append Append to existing table? Default `FALSE`
#'
#' @return Invisibly returns `NULL`
#' @export
save_db_table <- function(con, schema, table, data, overwrite = FALSE, append = FALSE) {
  if (is.null(con)) {
    stop("`con` (database connection) must not be NULL.")
  }
  
  stopifnot(is.character(schema), is.character(table))
  
  if (!is.data.frame(data)) {
    stop("`data` must be a data frame or tibble.")
  }
  
  env <- Sys.getenv("APP_ENV", unset = "dev")
  
  if (env == "prod") {
    DBI::dbWriteTable(
      con,
      DBI::Id(schema = schema, table = table),
      value = data,
      overwrite = overwrite,
      append = append
    )
  } else {
    dev_table <- paste0(schema, "__", table)
    DBI::dbWriteTable(
      con,
      name = dev_table,
      value = data,
      overwrite = overwrite,
      append = append
    )
  }
  
  invisible(NULL)
}


#' Materialize a dbplyr query to a database table (DB2- and SQLite-compatible)
#'
#' Uses APP_ENV to decide how and where to write the table:
#' - In 'prod' (DB2): creates schema-qualified table via SQL with WITH DATA
#' - In 'dev' (SQLite): uses dbplyr::compute() to create local table
#'
#' @param query A dbplyr query (lazy tbl object)
#' @param schema Schema name
#' @param table Table name
#' @param con A DBI connection
#' @param overwrite Should existing table be overwritten? Default: FALSE
#' @return A `dplyr::tbl` pointing to the new table
#' @export
compute_to_db <- function(query, con, schema, table, overwrite = FALSE) {
  env <- Sys.getenv("APP_ENV", unset = "dev")
  
  if (env == "prod") {
    full_table <- DBI::Id(schema = schema, table = table)
    
    if (DBI::dbExistsTable(con, full_table)) {
      if (overwrite) {
        DBI::dbRemoveTable(con, full_table)
      } else {
        stop(glue::glue("Table {schema}.{table} already exists. Use overwrite = TRUE to replace it."))
      }
    }
    
    sql_query <- dbplyr::sql_render(query)
    sql_string <- as.character(sql_query)
    
    full_sql <- glue::glue(
      'CREATE TABLE "{schema}"."{table}" AS ({sql_string}) WITH DATA'
    )
    
    DBI::dbExecute(con, full_sql)
    
    # Return lazy query of new table, like dplyr::compute()
    return(load_db_table(con, schema, table))
    
  } else {
    # dev: use compute() with flattened table name
    table_name <- paste0(schema, "__", table)
    
    # Remove if exists
    if (DBI::dbExistsTable(con, table_name)) {
      if (overwrite) {
        DBI::dbRemoveTable(con, table_name)
      } else {
        stop(glue::glue("Table {table_name} already exists. Use overwrite = TRUE to replace it."))
      }
    }
    
    # compute creates and returns a tbl
    result <- dplyr::compute(query, name = table_name, temporary = FALSE)
    return(result)
  }
}




