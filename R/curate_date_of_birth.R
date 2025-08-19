# bind_rows()
# Load packages
library(tidyverse) 
library(here)
library(dbplyr)
library(stringr)
library(glue)
library(lubridate)

# Load project config and helper functions
source(here("R", "project_config.R"))
source(here("R", "db_helpers.R"))
source(here("R", "cleaning_helpers.R"))

# Connect to database
con <- connect_to_db()


is.date <- function(x) inherits(x, "Date")


#We could use the glue function here
make_date <- function(admin, age) {
  year_val  <- as.numeric(format(admin, "%Y")) - age
  month_val <- format(admin, "%m")
  day_val   <- format(admin, "%d")
  
  as.Date(glue("{year_val}-{month_val}-{day_val}"), format = "%Y-%m-%d")
}
 
         
#obtaining the tables form the database
WLGP_DOB <- load_db_table(con, schema_data, tbl_wlgp_event)
EDDS_DOB <- load_db_table(con, schema_data, tbl_edds)
OPDW_DOB <- load_db_table(con, schema_data, tbl_opdw)

#cleaning the data
wlgp_query <- cleaning(WLGP_DOB, na_option = 'fill', column_type = "Date",column_name = "WOB" , trim = TRUE)

edds_query_1 <- cleaning(EDDS_DOB, column_type = "Date", trim = TRUE, column_name = "ADMIN_ARR_DT",na_option = "fill")
edds_query_2 <- cleaning(EDDS_DOB, column_type = "NUM", trim = TRUE, column_name = "AGE", na_option = "fill")

opdw_query_1 <- cleaning(OPDW_DOB, na_option = "fill", column_type = "NUM", trim = TRUE, column_name = "AGE_AT_APPT")
opdw_query_2 <- cleaning(OPDW_DOB, na_option = "fill", column_type = "Date", trim = TRUE, column_name = "ATTEND_DT")

compute_to_db(wlgp_query, con, schema_collab, tbl_wlgp_event, overwrite=TRUE)

compute_to_db(edds_query_1, con, schema_collab, tbl_edds, overwrite=TRUE)

compute_to_db(edds_query_2, con, schema_collab, tbl_edds,overwrite=TRUE)

compute_to_db(opdw_query_1, con, schema_collab, tbl_opdw,overwrite=TRUE)

compute_to_db(opdw_query_2, con, schema_collab, tbl_opdw,overwrite=TRUE)

#combinding the tables
wlgp_h <- WLGP_DOB|>
  select(WOB, ALF_E) |>
  rename(DOB = WOB) |>
  mutate(source = "tbl_wlgp_event") |>
  head(20)

edds_h <- EDDS_DOB |>
  select(ALF_E, DOB) |>
  mutate(source = "tbl_edds") |>
  head(20)

opdw_h <- OPDW_DOB |>
  select(ALF_E, DOB) |>
  mutate(source = "tbl_opdw") |>
  head(20)

combine_dob <- bind_rows(wlgp_h, opdw_h) |>
  show_query()

compute_to_db(bind_rows(wlgp_h,edds_h,opdw_h), con, schema_collab, tbl_wlgp_event, overwrite=TRUE)


