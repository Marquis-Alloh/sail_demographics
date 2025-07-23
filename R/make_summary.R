# Load packages
library(tidyverse) 
library(here)
library(dbplyr)

# Load project config and helper functions
source(here("R", "project_config.R"))
source(here("R", "db_helpers.R"))

# Connect to database
con <- connect_to_db()

print(con)
# Load PEDW_SPELL table using load_db_table()
pedw_spell <- load_db_table(con, schema_data, tbl_pedw_spell) 

# Query the max age by sex
pedw_spell_summary = pedw_spell %>% 
  select(GNDR_CD, age_epi_str_under1) %>% 
  group_by(GNDR_CD) %>% 
  summarise(
    max_age = max(age_epi_str_under1, na.rm = TRUE)
  )

# Nothing is computed yet but you can see the SQL query plan 
pedw_spell_summary %>% 
  show_query()

#> <SQL>
#>   SELECT `GNDR_CD`, MAX(`age_epi_str_under1`) AS `max_age`
#> FROM (
#>   SELECT `GNDR_CD`, `age_epi_str_under1`
#>   FROM `SAILWMCCV__C19_COHORT_PEDW_SPELL`
#> ) AS `q01`
#> GROUP BY `GNDR_CD`

# Execute query and bring results into memory by calling collect()
pedw_spell_summary <- pedw_spell_summary %>% 
  collect()

# Display tibble in terminal
pedw_spell_summary

#> # A tibble: 2 × 2
#> GNDR_CD max_age
#> <chr>     <dbl>
#> 1 F          45
#> 2 M          35

# Save to collab database using save_db_table
save_db_table(
  con, schema = schema_collab, table = tbl_out_example,
  data = pedw_spell_summary, overwrite = TRUE
)
