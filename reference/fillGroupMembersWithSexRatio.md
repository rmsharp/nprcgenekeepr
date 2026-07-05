# Form breeding groups to match a target sex ratio

The sex ratio is the ratio of females to males.

## Usage

``` r
fillGroupMembersWithSexRatio(
  candidates,
  groupMembers,
  grpNum,
  kin,
  ped,
  minAge,
  numGp,
  sexRatio
)
```

## Arguments

- candidates:

  character vector of IDs of the animals available for use in the group.

- groupMembers:

  list initialized and ready to receive groups with the desired sex
  ratios that are created within this function

- grpNum:

  is a list `numGp` long with each member an integer vector of
  `1:numGp`.

- kin:

  list of animals and those animals who are related above a threshold
  value.

- ped:

  dataframe that is the `Pedigree`. It contains pedigree information
  including the IDs listed in `ids`.

- minAge:

  integer value indicating the minimum age to consider in group
  formation. Pairwise kinships involving an animal of this age or
  younger will be ignored. Default is 1 year.

- numGp:

  integer value indicating the number of groups that should be formed
  from the list of IDs. Default is 1.

- sexRatio:

  numeric value indicating the ratio of females to males x from 0.5 to
  20 by increments of 0.5.

## Value

A list containing one character vector of animal IDs such that the sex
ratio of the group is as close as possible to the ratio specified by
`sexRatio`.

## Examples

``` r
library(nprcgenekeepr)
examplePedigree <- nprcgenekeepr::examplePedigree
examplePedigree <- examplePedigree[1:300, ] # Comment out for full example
ped <- qcStudbook(examplePedigree,
  minParentAge = 2L, reportChanges = FALSE,
  reportErrors = FALSE
)

kmat <- kinship(ped$id, ped$sire, ped$dam, ped$gen, sparse = FALSE)
currentGroups <- list(1)
currentGroups[[1]] <- examplePedigree$id[1L:3L]
candidates <- examplePedigree$id[examplePedigree$status == "ALIVE"]
threshold <- 0.015625
kin <- getAnimalsWithHighKinship(kmat, ped, threshold, currentGroups,
  ignore = list(c("F", "F")), minAge = 1L
)
# Filtering out candidates related to current group members
conflicts <- unique(c(
  unlist(kin[unlist(currentGroups)]),
  unlist(currentGroups)
))
candidates <- setdiff(candidates, conflicts)

kin <- addAnimalsWithNoRelative(kin, candidates)

ignore <- NULL
minAge <- 1.0
numGp <- 1L
harem <- FALSE
sexRatio <- 0.0
withKin <- FALSE
groupMembers <- nprcgenekeepr::makeGroupMembers(numGp,
  currentGroups,
  candidates,
  ped,
  harem = harem,
  minAge = minAge
)
groupMembersStart <- groupMembers
grpNum <- nprcgenekeepr::makeGroupNum(numGp)

groupMembers <- fillGroupMembersWithSexRatio(
  candidates, groupMembers, grpNum, kin, ped, minAge, numGp,
  sexRatio = 1.0
)
```
