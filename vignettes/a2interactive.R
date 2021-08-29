## ----setup, include=FALSE-----------------------------------------------------
knitr::opts_chunk$set(echo = TRUE,include = TRUE, results = "markup", cache = FALSE)
pdf.options(useDingbats = TRUE)
start_time <- proc.time()

#library(nprcgenekeepr)
#runGeneKeepR()

## ---- include = FALSE---------------------------------------------------------
library(stringi)
#library(rmsutilityr)
suppressMessages(library(ggplot2))
library(knitr)
library(nprcgenekeepr)
set_seed(1)


## ----gh-installation, eval = FALSE, echo=TRUE---------------------------------
#  install.packages(nprcgenekeepr)
#  ## Use the following code to get the development version
#  # install.packages("devtools")
#  # devtools::install_github("rmsharp/nprcgenekeepr")
#  

## ----gh-help, eval = FALSE, echo=TRUE-----------------------------------------
#  ?nprcgenekeepr
#  

## ----make-example-pedigree, eval = FALSE, include = TRUE----------------------
#  library(nprcgenekeepr)
#  pedigreeFile <- makeExamplePedigreeFile()
#  

## ----get-file-name, eval = TRUE, echo = FALSE, include = FALSE----------------
pedigreeFile <- "../inst/extdata/ExamplePedigree.csv"


## ----read-in-example-pedigree-------------------------------------------------
breederPedCsv <- read.table(
  pedigreeFile,
  sep = ",",
  header = TRUE,
  stringsAsFactors = FALSE
)

breederPedCsv$fromCenter <- "TRUE"
breederPedCsv$fromCenter[
  suppressWarnings(sample(which(is.na(breederPedCsv$sire) &
                 is.na(breederPedCsv$dam)), 
         round(0.8 * length(which(
           is.na(breederPedCsv$sire) & 
             is.na(breederPedCsv$dam))))))] <- "FALSE"


## ----row-count----------------------------------------------------------------
nrow(breederPedCsv)


## ----form-pedigree-object-----------------------------------------------------
breederPed <- qcStudbook(breederPedCsv, minParentAge = 2)


## ----select-focal-animals-from-pedigree, results='asis'-----------------------
focalAnimals <- breederPed$id[!(is.na(breederPed$sire) & 
                                  is.na(breederPed$dam)) &
                                is.na(breederPed$exit)]
print(stri_c("There are ", length(focalAnimals), 
             " animals in the vector _focalAnimals_."))


## ----short-pedigree-list-of-focal-animals-------------------------------------
breederPed[breederPed$id %in% 
             focalAnimals, c("id", "sire", "dam", "exit")][1:10, ]


## ----set-population-flag------------------------------------------------------
breederPed <- setPopulation(ped = breederPed, ids = focalAnimals)
nrow(breederPed[breederPed$population, ])


## ----trim-pedigree------------------------------------------------------------
trimmedPed <- trimPedigree(focalAnimals, breederPed)
nrow(breederPed); nrow(trimmedPed)


## ----removed-uninformatiive-animals-------------------------------------------
trimmedPedInformative <- trimPedigree(focalAnimals, breederPed,
                                      removeUninformative = TRUE)
nrow(trimmedPedInformative)


## ----get-animals-added-to-focal-animals---------------------------------------
nonfocalInTrimmedPed <- trimmedPed$id[!trimmedPed$id %in% focalAnimals]
length(nonfocalInTrimmedPed)


## ----find-focal-parents-------------------------------------------------------
allFocalParents <- c(breederPed$sire[breederPed$id %in% focalAnimals], 
                       breederPed$dam[breederPed$id %in% focalAnimals])
trimmedFocalParents <- c(trimmedPed$sire[trimmedPed$id %in% focalAnimals], 
                       trimmedPed$dam[trimmedPed$id %in% focalAnimals])
all.equal(allFocalParents, trimmedFocalParents) # Are the IDs the same?


## ----find-non-focal-non-focal-parent------------------------------------------
notFocalNotParent <- 
  trimmedPed$id[!trimmedPed$id %in% c(focalAnimals, allFocalParents)]
length(notFocalNotParent)


## ----find-grandparents, echo = FALSE, include=FALSE, eval = TRUE--------------
allFocalGrandParents <- c(breederPed$sire[breederPed$id %in% allFocalParents],
                          breederPed$dam[breederPed$id %in% allFocalParents])
## Not all parents are known so the unknown individuals (NA) are removed.
allFocalGrandParents <- allFocalGrandParents[!is.na(allFocalGrandParents)] 
trimmedFocalGrandParents <- 
  c(trimmedPed$sire[trimmedPed$id %in% allFocalParents],
    trimmedPed$dam[trimmedPed$id %in% allFocalParents])
trimmedFocalGrandParents <- 
  trimmedFocalGrandParents[!is.na(trimmedFocalGrandParents)] 
all.equal(allFocalGrandParents, trimmedFocalGrandParents)


## ----find-non-focal-non-focal-grandparent-------------------------------------
notFocalGParent <-
  trimmedPed$id[trimmedPed$id %in% trimmedFocalGrandParents]
length(notFocalGParent)
length(trimmedFocalGrandParents)


## ----get-informative-and-uninformative-added-animals, echo=FALSE, include=FALSE, eval=TRUE----
trimmedPedInformative <- trimPedigree(focalAnimals, breederPed,
                                            removeUninformative = TRUE)
uninformative <- trimmedPed$id[!trimmedPed$id %in% trimmedPedInformative$id]
notFocalInTrimmedPed <- trimmedPed$id[!trimmedPed$id %in% focalAnimals]
additionalAnimals <- nrow(trimmedPed) - length(focalAnimals)
geneticallyInformative <- 
  nrow(trimPedigree(focalAnimals, breederPed, 
                                 removeUninformative = TRUE)) - 
  length(focalAnimals)


## ----animals-no-birth-no-exit, echo = FALSE, eval = TRUE, include=FALSE-------
unknownBirth <- breederPed$id[is.na(breederPed$birth)]
unknownBirthOrExit <- 
  breederPed$id[is.na(breederPed$birth) | !is.na(breederPed$exit)]
knownPed <- breederPed[!breederPed$id %in% unknownBirthOrExit, ]
otherIds <- knownPed$id[!knownPed$id %in% trimmedPed$id[is.na(trimmedPed$exit)]]


## ----show-living-animals-not-in-trimmed-pedigree, results = 'asis'------------
unknownBirth <- breederPed$id[is.na(breederPed$birth)]
knownExit <- breederPed$id[ !is.na(breederPed$exit)]
unknownBirthKnownExit <- 
  breederPed$id[is.na(breederPed$birth) | !is.na(breederPed$exit)]
knownPed <- breederPed[!breederPed$id %in% unknownBirthKnownExit, ]
otherIds <- knownPed$id[!knownPed$id %in% trimmedPed$id[is.na(trimmedPed$exit)]]
print(stri_c("The living animals in the pedigree that are not in the trimmed ",
             "pedigree are ", get_and_or_list(otherIds), "."))


## ----plot-focal-age-sex-pyramid, include = TRUE-------------------------------
getPyramidPlot(ped = trimmedPed[is.na(trimmedPed$exit), ])


## ----set-entire-pedigree-as-population----------------------------------------
ped <- setPopulation(breederPed, NULL)


## ----full-pedigree-genetic-value-summary--------------------------------------
probands <- ped$id[ped$population]
ped <- trimPedigree(probands, ped, removeUninformative = FALSE,
                    addBackParents = FALSE)

## ----full-geneticValue--------------------------------------------------------
geneticValue <- reportGV(ped, guIter = 50,
                         guThresh = 3,
                         byID = TRUE,
                         updateProgress = NULL)
summary(geneticValue)


## ----trimmed-genetic-value-analysis-------------------------------------------

trimmedGeneticValue <- reportGV(trimmedPed, guIter = 50,
                         guThresh = 3,
                         byID = TRUE,
                         updateProgress = NULL)
summary(trimmedGeneticValue)

## ----list-genetic-value-objects-----------------------------------------------
names(trimmedGeneticValue)

## ----list-report-object-parts-------------------------------------------------
names(trimmedGeneticValue$report) ## column names
nrow(trimmedGeneticValue$report) ## Number of rows

## ----look-at-genetic-value-report---------------------------------------------
rpt <- trimmedGeneticValue[["report"]]
rpt$indivMeanKin <- round(rpt$indivMeanKin, 5)
rpt$zScores <- round(rpt$zScores, 2)
rpt$gu <- round(rpt$gu, 5)
rpt <- toCharacter(rpt)
names(rpt) <- headerDisplayNames(names(rpt))
knitr::kable(rpt[1:10, ]) # needs more work for display purposes.

## ----kinship-and-founders-----------------------------------------------------
rpt <- trimmedGeneticValue[["report"]]
kmat <- trimmedGeneticValue[["kinship"]]
f <- trimmedGeneticValue[["total"]]
mf <- trimmedGeneticValue[["maleFounders"]]
ff <- trimmedGeneticValue[["femaleFounders"]]
nmf <- trimmedGeneticValue[["nMaleFounders"]]
nff <- trimmedGeneticValue[["nFemaleFounders"]]
fe <- trimmedGeneticValue[["fe"]]
fg <- trimmedGeneticValue[["fg"]]


## ----genetic-uniqueness-boxplot-----------------------------------------------
gu <- rpt[, "gu"]
guBox <- ggplot(data.frame(gu = gu), aes(x = "", y = gu)) +
  geom_boxplot(
    color = "darkblue",
    fill = "lightblue",
    notch = TRUE,
    outlier.color = "red",
    outlier.shape = 1
  ) +
  theme_classic() + geom_jitter(width = 0.2) + coord_flip() +
  ylab("Score")  + ggtitle("Genetic Uniqueness")
print(guBox)

## ----extraction-of-mk-zs------------------------------------------------------
mk <- rpt[, "indivMeanKin"]
zs <- rpt[, "zScores"]


## ----groupAddAssign-help-request, eval = FALSE--------------------------------
#  ?groupAddAssign

## ----get-candidates-----------------------------------------------------------
candidates <- trimmedPed$id[trimmedPed$birth < as.Date("2013-01-01") &
                              !is.na(trimmedPed$birth) &
                              is.na(trimmedPed$exit)]
table(trimmedPed$sex[trimmedPed$id %in% candidates])


## ----create-harem-groups------------------------------------------------------
haremGrp <- groupAddAssign(candidates = candidates,
                     kmat = trimmedGeneticValue[["kinship"]],
                     ped = trimmedPed,
                     iter = 10,
                     numGp = 6,
                     harem = TRUE)
haremGrp$group


## ----list-males-in-harem-groups-----------------------------------------------
sapply(haremGrp$group, function(ids) {
  ids[ids %in% trimmedPed$id[trimmedPed$sex == "M"]]})


## ----harem-count-and-sexratios------------------------------------------------
lines <- sapply(haremGrp$group, function(ids) {
  paste0("Count: ", length(ids), " Sex Ratio: ", 
         round(calculateSexRatio(ids, trimmedPed), 2))})
for (line in lines) print(line)

## ----create-sexratio-groups---------------------------------------------------
sexRatioGrp <- groupAddAssign(candidates = candidates,
                     kmat = trimmedGeneticValue[["kinship"]],
                     ped = trimmedPed,
                     iter = 10,
                     numGp = 6,
                     sexRatio = 9)
sexRatioGrp$group


## ----list-males-in-sexratio-groups--------------------------------------------
sapply(sexRatioGrp$group, function(ids) {
  ids[ids %in% trimmedPed$id[trimmedPed$sex == "M"]]})


## ----list-count-and-sexratios-------------------------------------------------
lines <- sapply(sexRatioGrp$group, function(ids) {
  paste0("Count: ", length(ids), " Sex Ratio: ", 
         round(calculateSexRatio(ids, trimmedPed), 2))})
for (line in lines) print(line)

## ----getEmptyErrorLst---------------------------------------------------------
names(getEmptyErrorLst())

## ----make-errorList-definition-tbl, echo = FALSE, eval=TRUE-------------------
errorTypes <- names(getEmptyErrorLst())
errorDescriptions <- c(
  "Database connection failed: configuration or permissions are invalid",
  "Columns that must be within the pedigree file are missing.",
  "Values, which are supposed to be dates, cannot be interpreted as a date.",
  "Parents were too young on the date of birth of to have been the parent.",
  "Individuals listed as female or hermaphroditic and as a sire.",
  "Individuals are listed as male and as a dam.", 
  "Individuals who are listed as both a sire and a dam.",
  "IDs listed more than once.",
  "Fatal Errors.",
  stri_c("Columns that have been changed to conform to internal naming ",
  "conventions and what they were changed to.")
)
errorTbl <- data.frame(`Error` = errorTypes, Definition = errorDescriptions, 
                       stringsAsFactors = FALSE)


## ----print-error-definition-tbl, echo=FALSE-----------------------------------
knitr::kable(errorTbl) 


## ----list-pedOne--------------------------------------------------------------
knitr::kable(nprcgenekeepr::pedOne)

## ----summary-pedOne-no-errors, error = TRUE-----------------------------------
pedOne <- nprcgenekeepr::pedOne # put it in the local environment
ped <- qcStudbook(pedOne, minParentAge = 0)


## ----read-lowParentAge.csv, echo = FALSE, include = FALSE---------------------
lowParentAge <- read.csv(paste0(tempdir(),"/lowParentAge.csv"))

## ----print-lowParentAge.csv, echo = FALSE-------------------------------------
knitr::kable(lowParentAge)

## ----correct-birthdate, error = TRUE------------------------------------------
pedOne$birth_date[pedOne$ego_id == "o4"] <- as.Date("2015-09-16")
pedOne$birth_date[pedOne$ego_id == "d2"] <- as.Date("2006-04-13")

## ----display-corrected-birth-records------------------------------------------
ped <- qcStudbook(pedOne, minParentAge = 0)
ped[ped$id %in% c("s2", "d2", "o3", "o4"), ]


## ----look-for-errors----------------------------------------------------------
errorList <- qcStudbook(pedOne, minParentAge = 0, reportChanges = TRUE, 
                        reportErrors = TRUE)
summary(errorList)

## ----look-for-errors-only---------------------------------------------------------------
pedOne <- nprcgenekeepr::pedOne
errorList <- qcStudbook(pedOne, minParentAge = 0, reportChanges = FALSE, 
                        reportErrors = TRUE)
options(width = 90)
summary(errorList)

## ----look-at-loops----------------------------------------------------------------------
exampleTree <- createPedTree(breederPed)
exampleLoops <- findLoops(exampleTree)


## ----countLoops-------------------------------------------------------------------------
length(exampleLoops[exampleLoops == TRUE])
nLoops <- countLoops(exampleLoops, exampleTree)
sum(unlist(nLoops[nLoops > 0]))


## ----listLoops--------------------------------------------------------------------------

examplePedigree[exampleLoops == TRUE, c("id", "sire", "dam")][1:10, ]



## ----elapsed-time-----------------------------------------------------------------------
elapsed_time <- get_elapsed_time_str(start_time)

## ----session-info-----------------------------------------------------------------------
sessionInfo()


