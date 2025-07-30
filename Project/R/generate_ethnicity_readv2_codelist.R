library(glue)
library(tidyverse)
library(dplyr)
library(readxl)
library(here)

setwd("C:\Users\MarquisAlloh\Documents\code\task_2\Read_v2\Project")
glue('we are now here: {getwd()}')

#file path
ctv3_to_readv2_map <- read_tsv(here("codelists","raw","ctv3rctmap_uk_20200401000002.txt"))
ethnicity_ctv3_codes  <- read_csv(here("codelists","raw","opensafely-ethnicity-2020-04-27.csv"))
readv2_lookup  <- read_excel(here("codelists","raw","read code V2 - codes and descriptions.xlsx"))

#setting up our tables for the join
ethnicity_ctv3_codes  <- ethnicity_ctv3_codes  |>
  rename(ctv3_conceptid = Code,
         ethnicity_17 = Grouping_16,
         ethnicity_5 = Grouping_6,
         ethnicity_17_Description = Description)

ctv3_to_readv2_map <- ctv3_to_readv2_map |>
  rename(ctv3_conceptid = CTV3_CONCEPTID,
         ctv3_termid = CTV3_TERMID,
         v2_conceptid = V2_CONCEPTID,
         v2_termid = V2_TERMID)

readv2_lookup  <- readv2_lookup  |>
  rename(v2_conceptid = ReadCode,
         v2_termid = TermCode,
         ethnicity_5_Description = Description)

# The Joins are occurring here
semi_joined_df <- left_join(ethnicity_ctv3_codes , ctv3_to_readv2_map, by = "ctv3_conceptid", relationship = "many-to-many")

#c() is used as it must be joined based on multiple columns, this prevents the many-to-many issue from happening
Fully_joined_df <- left_join(semi_joined_df, readv2_lookup , by = c("v2_termid" = "v2_termid", "v2_conceptid" = "v2_conceptid") , relationship = "many-to-many")

Grimy_df <- Fully_joined_df

# As far as I'm aware the other columns aren't of interest 
ethnicity_read_v2 <- Grimy_df |>
  select(ctv3_conceptid,ctv3_termid, v2_conceptid, v2_termid, ethnicity_5, ethnicity_17, ethnicity_5_Description, ethnicity_17_Description) |>
  distinct(v2_conceptid, v2_termid, .keep_all = TRUE) |> # went from 354 obs to 267 obs
  drop_na(c(v2_conceptid,v2_termid,ctv3_conceptid,ctv3_termid)) # went from 267 obs to 253 obs


write.csv(ethnicity_read_v2, here("codelists","raw","ethnicity_readv2.csv"))
