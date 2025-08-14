library(tidyverse)
library(dplyr)
library(readxl)
library(here)

source(here("R", "project_config.R"))
#This code will only be run once and can only be rerun when you have the edds, opdw, PEDW_SPELL and wcgp csv files in the relevant folder

WLGP <- read_csv(here("tests","testdata","wcgp.csv"))
EDDS <- read_csv(here("tests","testdata","edds.csv"))
OPDW <- read_csv(here("tests","testdata","opdw.csv"))
PEDW_SPELL <- read_csv(here("tests","testdata","PEDW_SPELL.csv"))

#columns to be added
WLGP$ALF_E <- c(1000000231,1000000224,1000000236,1000000235,1000000233,1000000234,1000000232,1000000239)
WLGP$EVENT_CD <- c("m598","m599","m582","m591","m584","m593","m597","m592")
WLGP$EVENT_CD_VRS <- c("2","2","2","2","2","2","2","2")
WLGP$EVENT_VAL <- c(0,0,0,0,0,0,0,0)
WLGP$EVENT_DT  <- c(year(as.Date(1999)),year(as.Date(1994)),year(as.Date(2007)),year(as.Date(2011)),year(as.Date(1992)),year(as.Date(2020)),year(as.Date(2015)),year(as.Date(2000)) )
WLGP$PRAC_CD_E <- c(45702,45662,45802,45703,44702,45712,44765,45708)
WLGP$LSOA_CD <- c("W01001378","W01001379","W01002380","W01003175","W01000990","W01000471","W01002480","W010003823")
WLGP$WOB <- c("W01001378","W01001379","W01001380","W01001375","W01001390","W01001371","W01001370","W01001382")
WLGP$GNDR_CD <- c(1,2,9,1,1,2,8,1)
WLGP$FROM_DT <- c(as.Date("2025-05-07", format = "%y-%m-%d"),as.Date("2012-11-11", format = "%y-%m-%d"),as.Date("2003-07-06", format = "%y-%m-%d"),as.Date("2012-02-16", format = "%y-%m-%d"),as.Date("2022-08-06", format = "%y-%m-%d"),as.Date("1995-05-06", format = "%y-%m-%d"),as.Date("2011-05-08", format = "%y-%m-%d"),as.Date("2000-05-01", format = "%y-%m-%d"))

EDDS$SEX <- c(1,2,1,1,2,2,2)
EDDS$LSOA2011_CD <- c("W01001051","W01000123","W01000092","W01002126","W01001033","W01001143","W01001023")
EDDS$ADMIN_ARR_DT <- c(as.Date("2023-05-07", format = "%y-%m-%d"),as.Date("2020-04-16", format = "%y-%m-%d"),as.Date("2005-05-16", format = "%y-%m-%d"),as.Date("2023-11-03", format = "%y-%m-%d"),as.Date("1993-05-06", format = "%y-%m-%d"),as.Date("2001-05-08", format = "%y-%m-%d"),as.Date("1994-11-03", format = "%y-%m-%d"))
EDDS$ETHNIC_GROUP <- c("Z","Z","Z","Z","Z","Z","Z")
EDDS$AGE <- c(23,12,27,34,67,53,14)

OPDW$ALF_E <- c(1000000224,1000000276,1000000673,1000000253,1000000212,1000000632,1000010239)
OPDW$GNDR_CD <- c(2,2,1,2,1,2,1)
OPDW$ATTEND_DT <- c(year(as.Date(1997)),year(as.Date(1999)),year(as.Date(2000)),year(as.Date(1998)),year(as.Date(2001)),year(as.Date(2013)),year(as.Date(2011)))
OPDW$AGE_AT_APPT <- c(2,21,12,31,27,54,23)
OPDW$LSOA_11_CD <- c("W01001444","W01001031","W01001000","W01001333","E01001444","W01001431","W01001243")
OPDW$LSOA_01_CD <- OPDW$LSOA_11_CD

PEDW_SPELL$ALF_E <- c(1000061366,1000053256,1000011576,1000061363,1000061368,1000061360,1000061311)
PEDW_SPELL$LSOA_CD <- c("W01000797","W01000707","W01000796","W01000497","W01000787","W01000333","W01000711")
PEDW_SPELL$LSOA2011_CD <- c("W01000797","W01000707","W01000796","W01000497","W01000787","W01000333","W01000711")
PEDW_SPELL$LSOA2001_CD <- c("W01000797","W01000707","W01000796","W01000497","W01000787","W01000333","W01000711")
PEDW_SPELL$GNDR_CD <- c(2,2,1,1,2,1,2)
PEDW_SPELL$AVAIL_FROM_DT <- c(as.Date("2005-05-07", format = "%y-%m-%d"),as.Date("2024-04-06", format = "%y-%m-%d"),as.Date("2005-05-16", format = "%y-%m-%d"),as.Date("2023-05-06", format = "%y-%m-%d"),as.Date("1995-05-06", format = "%y-%m-%d"),as.Date("2011-05-08", format = "%y-%m-%d"),as.Date("2000-05-01", format = "%y-%m-%d"))
PEDW_SPELL$AGE_EPI_STR <- c(12,32,24,NA,45,21,NA)
PEDW_SPELL$AGE_EPI_STR_UNDER1 <- c(NA,NA,NA,6,NA,NA,2)
PEDW_SPELL$ADMIS_DT <- c(as.Date("2013-05-07", format = "%y-%m-%d"),as.Date("2025-04-06", format = "%y-%m-%d"),as.Date("2007-05-16", format = "%y-%m-%d"),as.Date("2024-02-06", format = "%y-%m-%d"),as.Date("1998-05-06", format = "%y-%m-%d"),as.Date("2012-05-08", format = "%y-%m-%d"),as.Date("2004-05-01", format = "%y-%m-%d"))

#removed the unneeded columns from the data
#WLGP <- subset(WLGP, select = -c(LSOA2001_CD, LSOA2011_CD, GNDR_CD, WOB, TREAT_SPEC_CD))
#EDDS <- subset(EDDS, select = -c(DIAG_CD_1,DIAG_CD_2,DIAG_CD_3,DIAG_CD_4,DIAG_CD_5,DIAG_CD_6))
#OPDW <- subset(OPDW, select = -c(lsoa2001_cd,attend_dt,age_at_appt,gndr_cd,diag_num))
#PEDW_SPELL <- subset(PEDW_SPELL, select = -c(lsoa2001_cd,age_epi_str_yr,age_epi_str_under1,pat_class_cd,admis_dt))


write.csv(WLGP, here("tests","testdata","WLGP.csv"))
write.csv(EDDS, here("tests","testdata","EDDS.csv"))
write.csv(OPDW, here("tests","testdata","OPDW.csv"))
write.csv(PEDW_SPELL, here("tests","testdata","PEDW_SPELL.csv"))


file.rename(here("tests","testdata","edds.csv"),here("tests","testdata","temp.csv"))
file.rename(here("tests","testdata","temp.csv"),here("tests","testdata","EDDS.csv"))
file.remove(here("tests","testdata","temp.csv"))

file.rename(here("tests","testdata","opdw.csv"),here("tests","testdata","temp.csv"))
file.rename(here("tests","testdata","temp.csv"),here("tests","testdata","OPDW.csv"))
file.remove(here("tests","testdata","temp.csv"))

file.remove(here("tests","testdata","wcgp.csv"))


#regx