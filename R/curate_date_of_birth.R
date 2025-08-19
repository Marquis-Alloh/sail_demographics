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
cleaning(WLGP_DOB,na_option = 'fill', column_type = "Date",column_name = "WOB" , trim = TRUE)

cleaning(EDDS_DOB, column_type = "Date", trim = TRUE, column_name = "ADMIN_ARR_DT",na_option = "fill")
cleaning(EDDS_DOB, column_type = "NUM", trim = TRUE, column_name = "AGE", na_option = "fill")

cleaning(OPDW_DOB, na_option = "fill", column_type = "NUM", trim = TRUE, column_name = "AGE_AT_APPT")
cleaning(OPDW_DOB, na_option = "fill", column_type = "Date", trim = TRUE, column_name = "ATTEND_DT")

compute_to_db(con, )

WLGP_DOB <- WLGP_DOB|>
  select(WOB) |>
  head(20)
  
EDDS_DOB <- EDDS_DOB |>
  select(ADMIN_ARR_DT, AGE) |>
  #creating the date of birth
  mutate(DOB = make_date(ADMIN_ARR_DT, AGE)) |>
  head(20)

OPDW_DOB <- OPDW_DOB |>
  select(ATTEND_DT, AGE_AT_APPT) |>
  mutate(DOB = make_date(ATTEND_DT, AGE_AT_APPT)) |>
  head(20)
