## Copyright(c) 2017-2026 R. Mark Sharp
## This file is part of nprcgenekeepr
##
## Shared by test_runQcStudbook.R and test_modInput_qcStudbook.R (S982;
## BACKLOG.md:156): the Input tab's warning about animals with a death or
## departure date earlier than their birth date.

## pedGood (8 animals) with a death column and a departure column: o1, born
## 2015-02-04, dies on 2014-12-01 (before its birth); o2, born 2009-03-17,
## dies on its birth day (not flagged: the owner ruled strictly earlier only);
## o3, born 2012-04-11, leaves on 2012-01-01 (before its birth). Every other
## animal has no exit date. The columns are named death_date (which
## qcStudbook() renames to death) and departure (qcStudbook() does not rename
## departure_date). Cleaned, o1 and o3 come out at exit < birth, age < 0.
pedEarlyExits <- function() {
  ped <- nprcgenekeepr::pedGood
  ped$death_date <- as.Date(NA)
  ped$death_date[ped$ego_id == "o1"] <- as.Date("2014-12-01")
  ped$death_date[ped$ego_id == "o2"] <- as.Date("2009-03-17")
  ped$departure <- as.Date(NA)
  ped$departure[ped$ego_id == "o3"] <- as.Date("2012-01-01")
  ped
}
