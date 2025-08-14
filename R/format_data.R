#the data shows some number of issues and here they will be fixed.
library(tidyverse)
library(dplyr)
library(readxl)
library(here)

#WLGP <- subset(WLGP, select = -c(LSOA2001_CD,LSOA2011_CD,WELSH_ADDRESS, TREAT_SPEC_CD, FROM_DT, PRAC_CD_E))
#WLGP$LSOA2011_CD <- c("W01001444","W01001434","W01001031","W01001000","W01001333","E01001444","W01001431","W01001243")
#WLGP$LSOA2001_CD <- c("W01001444","W01001434","W01001031","W01001000","W01001333","E01001444","W01001431","W01001243")

WLGP$ALF_E <- c("1000000231","1000000224","1000000236","1000000235","1000000233","1000000234","1000000232","1000000239")
WLGP <- subset(WLGP, select = -c(EVENT_DT))

WLGP$EVENT_DT <- c(as.Date("1993-05-07", format = "%Y-%m-%d"),as.Date("1998-11-11", format = "%Y-%m-%d"),as.Date("1998-07-06", format = "%Y-%m-%d"),as.Date("2000-02-16", format = "%Y-%m-%d"),as.Date("1997-08-06", format = "%Y-%m-%d"),as.Date("1992-05-06", format = "%Y-%m-%d"),as.Date("1990-05-08", format = "%Y-%m-%d"),as.Date("1991-05-01", format = "%Y-%m-%d"))

write.csv(WLGP, here("tests","testdata","WLGP.csv"))

EDDS$ADMIN_ARR_DT <- c(as.Date("2023-05-07", format = "%Y-%m-%d"),as.Date("2020-04-16", format = "%Y-%m-%d"),as.Date("2005-05-16", format = "%Y-%m-%d"),as.Date("2023-11-03", format = "%Y-%m-%d"),as.Date("1993-05-06", format = "%Y-%m-%d"),as.Date("2001-05-08", format = "%Y-%m-%d"),as.Date("1994-11-03", format = "%Y-%m-%d"))
EDDS$RECORD_ID_E <- c("1022452891","2232452891","1111891","2230913891","2903452521","132092891","2292455491")
write.csv(EDDS, here("tests","testdata","EDDS.csv"))


EDDS <- subset(EDDS, select = -c(ADMIN_ARR_DT))


OPDW <- subset(OPDW, select = -c(ATTEND_DT,AVAIL_FROM_DT))
OPDW$ATTEND_DT <- c(as.Date("1995-02-12", format = "%Y-%m-%d"),as.Date("2009-04-16", format = "%Y-%m-%d"),as.Date("2015-11-13", format = "%Y-%m-%d"),as.Date("2002-04-21", format = "%Y-%m-%d"),as.Date("1996-05-06", format = "%Y-%m-%d"),as.Date("2012-05-08", format = "%Y-%m-%d"),as.Date("2000-05-01", format = "%Y-%m-%d"))
OPDW$AVAIL_FROM_DT <- c(as.Date("1996-02-12", format = "%Y-%m-%d"),as.Date("2010-04-16", format = "%Y-%m-%d"),as.Date("2016-11-13", format = "%Y-%m-%d"),as.Date("2003-04-21", format = "%Y-%m-%d"),as.Date("1997-05-06", format = "%Y-%m-%d"),as.Date("2013-05-08", format = "%Y-%m-%d"),as.Date("2001-05-01", format = "%Y-%m-%d"))
write.csv(OPDW, here("tests","testdata","OPDW.csv"))

PEDW_SPELL <- subset(PEDW_SPELL, select = -c(...1,...2,...3,...4,AVAIL_FROM_DT,ADMIS_DT))
PEDW_SPELL$AVAIL_FROM_DT <- c(as.Date("2005-05-07", format = "%Y-%m-%d"),as.Date("2024-04-06", format = "%Y-%m-%d"),as.Date("2005-05-16", format = "%Y-%m-%d"),as.Date("2023-05-06", format = "%Y-%m-%d"),as.Date("1995-05-06", format = "%Y-%m-%d"),as.Date("2011-05-08", format = "%Y-%m-%d"),as.Date("2000-05-01", format = "%Y-%m-%d"))
PEDW_SPELL$ADMIS_DT <- c(as.Date("2013-05-07", format = "%Y-%m-%d"),as.Date("2025-04-06", format = "%Y-%m-%d"),as.Date("2007-05-16", format = "%Y-%m-%d"),as.Date("2024-02-06", format = "%Y-%m-%d"),as.Date("1998-05-06", format = "%Y-%m-%d"),as.Date("2012-05-08", format = "%Y-%m-%d"),as.Date("2004-05-01", format = "%Y-%m-%d"))
write.csv(PEDW_SPELL, here("tests","testdata","PEDW_SPELL.csv"))
