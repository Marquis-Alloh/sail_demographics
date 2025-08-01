library(tidyverse)
library(here)
library(janitor)

# Load mapping files, codelist and Read v2 look-up
ctv3_to_readv2_map <- read_csv(here("codelists","raw","ctv3rctmap_uk_20200401000002.csv.xz"))
ethnicity_ctv3_codes  <- read_csv(here("codelists","raw","opensafely-ethnicity-2020-04-27.csv"))
readv2_lookup  <- read_csv(here("codelists","raw","readv2_codes_descriptions.csv.xz"))

# Standardise column names to snake_case and rename key columns for clarity
ethnicity_ctv3_codes <- ethnicity_ctv3_codes |>
  clean_names() |>
  rename(
    ctv3_conceptid = code,
    ctv3_description = description,
    ethnicity_16 = grouping_16,
    ethnicity_5 = grouping_6,
  )

ctv3_to_readv2_map <- ctv3_to_readv2_map |>
  clean_names()

readv2_lookup <- readv2_lookup |> 
  clean_names() |>
  rename(
    v2_conceptid = read_code,
    v2_termid = term_code,
    v2_description = description
  )

# Join CTV3 ethnicity codes with mapping table
ctv3_mapped <- ethnicity_ctv3_codes |>
  left_join(
    ctv3_to_readv2_map, 
    by = "ctv3_conceptid", 
    relationship = "many-to-many"
  )

# Join with Read V2 lookup table
ethnicity_read_v2 <- ctv3_mapped |>
  left_join(
    readv2_lookup, 
    by = c("v2_conceptid", "v2_termid"), 
    relationship = "many-to-many"
  )

# Remove duplicates based on Read V2 code and term
ethnicity_read_v2 <- ethnicity_read_v2 |> 
  distinct(v2_conceptid, v2_termid, .keep_all = TRUE)

# Drop rows with missing key identifiers
ethnicity_read_v2 <- ethnicity_read_v2 |> 
  drop_na(v2_conceptid, v2_termid)

# Final cleaned and deduplicated Read v2 codelist
ethnicity_read_v2 <- ethnicity_read_v2 |> 
  select(
    code = v2_conceptid,
    term = v2_termid,
    description = v2_description,
    ethnicity_5,
    ethnicity_16,
  )

# Save final codelist to file
write.csv(ethnicity_read_v2, here("codelists","ethnicity_readv2.csv"))
