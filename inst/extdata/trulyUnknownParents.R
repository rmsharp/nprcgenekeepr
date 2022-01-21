library(nprcgenekeepr)
library(rmsutilityr)
library(stringi)
# Reading in large ped file and transforming columns and values - delete from script
pedOne_file <- stri_c("/Users/msharp/Documents/Projects/Active_Projects/",
                      "nprcgenekeepr_project/Deidentified\ Pedegrees/",
                      "2021-01-06_Deidentified_Pedigree.csv")
pedOne <- read.csv(file = pedOne_file, header = TRUE, sep = ",")
minParentAge <- 2 #Min breeding age
pedOne <- qcStudbook(pedOne, minParentAge = minParentAge)
pedOne$fromCenter[is.na(pedOne$fromCenter)] <- TRUE

#calc list of births prior to loop
#pre allocate mem for containers - create matrix with NAs - make ids factors
potentialParents <-
  getPotentialParents(ped = pedOne, minParentAge = 2,
                      maxGestationalPeriod = 210)
for (i in c(1390, 1508, 1629, 1644, 1813)) {
  cat(paste0("#", i, " is counter: ", potentialParents[[i]]$counter,
             "; id: ", potentialParents[[i]]$id, "; dams are ",
             get_and_or_list(potentialParents[[i]]$dams), "; sires are ",
             get_and_or_list(potentialParents[[i]]$sires), ".\n"))
}

n <- 1
simKinships <- createSimKinships(ped = pedOne, allSimParents = potentialParents,
                                 pop = pedOne$id, n = n, verbose = TRUE)
kValues <- kinshipMatricesToKValues(simKinships)
counts <- countKinshipValues(kValues)
for (i in 1:5) {
  simKinships <- createSimKinships(ped = pedOne,
                                   allSimParents = potentialParents,
                                   pop = pedOne$id, n = n, verbose = TRUE)
  kValues <- kinshipMatricesToKValues(simKinships)
  counts <- countKinshipValues(kValues, counts)
}
stats <- summarizeKinshipValues(counts)
filename <- get_dated_excel_name("counts")
nprcgenekeepr::create_wkbk(file = filename, df_list = list(stats),
                           sheetnames = "stats", replace = TRUE)
### Testing - looking at how many potential parents for each offspring and time
### to run
##library(dplyr)
##potentialParents_counts <- potentialParents %>%
##  count(id, sex)
##potentialParents_counts2 <- potentialParents_counts %>%
##  count(n)
##colnames(potentialParents_counts2) <-
##  c("Number of potential parents", "n")
##plot(potentialParents_counts2)
##
##print(
##  glue::glue(
##    "{NROW(unique(potentialParents$id))} offspring have potential parents out of {NROW(unique(pUnknown$id))} offspring born at the center and lack parentage"
##  )
##)
###2155 offspring have potential parents out of 2156 offspring born at the center and lack parentage
##
##start_time <- Sys.time()
##potentialParents <-
##  getPotentialParents(ped = ped, minParentAge)
##end_time <- Sys.time()
##idsWithUnknownParents <- ped[ped$fromCenter &
##                               (is.na(ped$sires) | is.na(ped$dams)), "id"]
##print(
##  glue::glue(
##    "Function took {end_time - start_time} minutes to run with {length(idsWithUnknownParents)} unknown parents out of a {nrow(ped)} NHP pedigree"
##  )
##)
##dams <- unlist(sapply(potentialParents, function(x) {
##  if (!is.null(x$dam))
##    x$dam
##  else
##    character(0)}))
##
##
###V1 Function took 2.15986945231756 minutes to run with 2156 unknown parents out of a 5000 NHP pedigree
###V2 Function took 1.74734245141347 minutes to run with 2156 unknown parents out of a 5000 NHP pedigree; 53.7 minutes to run with 8771 unknown parents out of 27220 NHP pedigree
##
