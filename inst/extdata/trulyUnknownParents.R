library(nprcgenekeepr)
library(stringi)
# Reading in large ped file and transforming columns and values - delete from script
pedOne_file <- stri_c("/Users/msharp/Documents/Projects/Active_Projects/",
                      "nprcgenekeepr_project/Deidentified\ Pedegrees/",
                      "2021-01-06_Deidentified_Pedigree.csv")
pedOne <- read.csv(file = pedOne_file, header = TRUE, sep = ",")
ped <- qcStudbook(pedOne, minParentAge = 2)
pedOne$exit <- pedOne$death
pedOne$exit[is.na(pedOne$exit)] <-
  pedOne$departure[is.na(pedOne$exit)]
pedOne$exit <- as.Date(pedOne$exit)
pedOne$birth_date <- as.Date(pedOne$birth)
pedOne$ego_id <- as.character(pedOne$id)
pedOne$fromCenter <- pedOne$from.center
pedOne$fromCenter[is.na(pedOne$fromCenter)] <- "T"
pedOne$fromCenter[pedOne$fromCenter == "TRUE"] <- "T"
pedOne$fromCenter[pedOne$fromCenter == "FALSE"] <- "F"
pedOne$fromCenter[pedOne$fromCenter == "Yes"] <- "T"
pedOne$fromCenter[pedOne$fromCenter == "No"] <- "T"
pedOne <- pedOne[!pedOne$sex == "u", ]
pedOne$sex[pedOne$sex == "m"] <- "M"
pedOne$sex[pedOne$sex == "f"] <- "F"
pedOne <- pedOne[!is.na(pedOne$id), ]
pedOne <- pedOne[!is.na(pedOne$birth_date), ]
#pedOne <- pedOne[1:1500, ]
pedOne$sire_id <- pedOne$sire
pedOne$dam_id <- pedOne$dam

minParentAge <- 2 #Min breeding age

#calc list of births prior to loop
#pre allocate mem for containers - create matrix with NAs - make ids factors
potentialParents <- getPotentialParents(ped = ped, minParentAge)
for (i in c(1390, 1508, 1629, 1644, 1813)) {
  cat(paste0("#", i, " is counter: ", potentialParents[[i]]$counter,
             "; id: ", potentialParents[[i]]$id, "; dams are ",
             get_and_or_list(potentialParents[[i]]$dams), "; sires are ",
             get_and_or_list(potentialParents[[i]]$sires), ".\n"))
}

n <- 1
simKinships <- createSimKinships(ped, allSimParents = potentialParents,
                                 pop = ped$id, n = n)
kValues <- kinshipMatricesToKValues(simKinships)
counts <- countKinshipValues(kValues)
stats <- summarizeKinshipValues(counts)

# Testing - looking at how many potential parents for each offspring and time to run
library(dplyr)
potentialParents_counts <- potentialParents %>%
  count(id, sex)
potentialParents_counts2 <- potentialParents_counts %>%
  count(n)
colnames(potentialParents_counts2) <-
  c("Number of potential parents", "n")
plot(potentialParents_counts2)

print(
  glue::glue(
    "{NROW(unique(potentialParents$id))} offspring have potential parents out of {NROW(unique(pUnknown$id))} offspring born at the center and lack parentage"
  )
)
#2155 offspring have potential parents out of 2156 offspring born at the center and lack parentage

start_time <- Sys.time()
potentialParents <-
  getPotentialParents(ped = ped, minParentAge)
end_time <- Sys.time()
idsWithUnknownParents <- ped[ped$fromCenter &
                               (is.na(ped$sires) | is.na(ped$dams)), "id"]
print(
  glue::glue(
    "Function took {end_time - start_time} minutes to run with {length(idsWithUnknownParents)} unknown parents out of a {nrow(ped)} NHP pedigree"
  )
)
dams <- unlist(sapply(potentialParents, function(x) {
  if (!is.null(x$dam))
    x$dam
  else
    character(0)}))


#V1 Function took 2.15986945231756 minutes to run with 2156 unknown parents out of a 5000 NHP pedigree
#V2 Function took 1.74734245141347 minutes to run with 2156 unknown parents out of a 5000 NHP pedigree; 53.7 minutes to run with 8771 unknown parents out of 27220 NHP pedigree
