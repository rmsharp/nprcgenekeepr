# summary.nprcgenekeeprErr Summary function for class nprcgenekeeprErr

summary.nprcgenekeeprErr Summary function for class nprcgenekeeprErr

## Usage

``` r
# S3 method for class 'nprcgenekeeprErr'
summary(object, ...)

# S3 method for class 'nprcgenekeeprGV'
summary(object, ...)
```

## Arguments

- object:

  object of class nprcgenekeeprErr and class list

- ...:

  additional arguments for the `summary.default` statement

## Value

Object of class summary.nprcgenekeeprErr

object of class summary.nprcgenekeeprGV

## Examples

``` r
errorList <- qcStudbook(nprcgenekeepr::pedOne,
  minParentAge = 0,
  reportChanges = TRUE,
  reportErrors = TRUE
)
summary(errorList)
#> Error: The animal listed as a sire and also listed as a female is: s1.
#> Error: The animal listed as a dam and also listed as a male is: d1.
#> Change: The column where period was removed is: sire.id to sireid.
#> Change: The columns where underscore was removed are: ego_id, dam_id, and birth_date to egoid, damid, and birthdate.
#> Change: The column changed from: egoid to id.
#> Change: The column changed from: sireid to sire.
#> Change: The column changed from: damid to dam.
#> Change: The column changed from: birthdate to birth.
#> 
#> Please check and correct the pedigree file.
#>  
#> Animal records where parent records are suspicous because of dates.
#> One or more parents appear too young at time of birth.
#>   dam sire id sex      birth recordStatus exit  sireBirth   damBirth sireAge
#> 2  d2   s1 o2   F 2009-03-17     original <NA> 2000-07-18 2015-09-16    8.66
#> 3  d2   s2 o3   F 2012-04-11     original <NA> 2006-06-19 2015-09-16    5.81
#> 4  d2   s2 o4   M 2006-04-13     original <NA> 2006-06-19 2015-09-16   -0.18
#>   damAge
#> 2   -6.5
#> 3   -3.4
#> 4   -9.4
examplePedigree <- nprcgenekeepr::examplePedigree
breederPed <- qcStudbook(examplePedigree,
  minParentAge = 2L,
  reportChanges = FALSE,
  reportErrors = FALSE
)
focalAnimals <- breederPed$id[!(is.na(breederPed$sire) &
  is.na(breederPed$dam)) &
  is.na(breederPed$exit)]
ped <- setPopulation(ped = breederPed, ids = focalAnimals)
trimmedPed <- trimPedigree(focalAnimals, breederPed)
probands <- ped$id[ped$population]
ped <- trimPedigree(probands, ped,
  removeUninformative = FALSE,
  addBackParents = FALSE
)
geneticValue <- reportGV(ped,
  guIter = 50L, # should be >= 1000L
  guThresh = 3L,
  byID = TRUE,
  updateProgress = NULL
)
trimmedGeneticValue <- reportGV(trimmedPed,
  guIter = 50L, # should be >= 1000L
  guThresh = 3L,
  byID = TRUE,
  updateProgress = NULL
)
summary(geneticValue)
#> The genetic value report 
#> Individuals in Pedigree: 327 
#> Male Founders: 3
#> Female Founders: 17
#> Total Founders: 20 
#> Founder Equivalents: 109.67 
#> Founder Genome Equivalents: 47.01 +/- 0.31 
#> Live Offspring: 321 
#> High Value Individuals: 238 
#> Low Value Individuals: 89 
summary(trimmedGeneticValue)
#> The genetic value report 
#> Individuals in Pedigree: 704 
#> Male Founders: 3
#> Female Founders: 17
#> Total Founders: 20 
#> Founder Equivalents: 116.8 
#> Founder Genome Equivalents: 65.85 +/- 0.19 
#> Live Offspring: 1004 
#> High Value Individuals: 288 
#> Low Value Individuals: 234 
```
