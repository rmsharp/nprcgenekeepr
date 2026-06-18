# Sets sex for animals listed as either a sire or dam

Part of Pedigree Curation

## Usage

``` r
correctParentSex(id, sire, dam, sex, recordStatus, reportErrors = FALSE)
```

## Arguments

- id:

  character vector with unique identifier for an individual

- sire:

  character vector with unique identifier for an individual's father
  (`NA` if unknown).

- dam:

  character vector with unique identifier for an individual's mother
  (`NA` if unknown).

- sex:

  factor with levels: "M", "F", "U". Sex specifier for an individual.

- recordStatus:

  character vector with value of `"added"` or `"original"`, which
  indicates whether an animal was added or an original animal.

- reportErrors:

  logical value if TRUE will scan the entire file and make a list of all
  errors found. The errors will be returned in a list of list where each
  sublist is a type of error found.

## Value

A factor with levels: "M", "F", "H", and "U" representing the sex codes
for the ids provided

## Details

Only true female-sires (`"F"`) and male-dams (`"M"`) are corrected (to
`"M"` and `"F"` respectively). Parents recorded as hermaphrodite (`"H"`)
or unknown (`"U"`) sex are left unchanged, consistent with
`reportErrors = TRUE` mode, which does not flag them.

## Examples

``` r
library(nprcgenekeepr)
pedOne <- data.frame(
  id = c("s1", "d1", "s2", "d2", "o1", "o2", "o3", "o4"),
  sire = c(NA, "s0", "s4", NA, "s1", "s1", "s2", "s2"),
  dam = c(NA, "d0", "d4", NA, "d1", "d2", "d2", "d2"),
  sex = c("F", "F", "M", "F", "F", "F", "F", "M"),
  recordStatus = rep("original", 8),
  stringsAsFactors = FALSE
)
pedTwo <- data.frame(
  id = c("s1", "d1", "s2", "d2", "o1", "o2", "o3", "o4"),
  sire = c(NA, "s0", "s4", NA, "s1", "s1", "s2", "s2"),
  dam = c("d0", "d0", "d4", NA, "d1", "d2", "d2", "d2"),
  sex = c("M", "M", "M", "F", "F", "F", "F", "M"),
  recordStatus = rep("original", 8),
  stringsAsFactors = FALSE
)
pedOneCorrected <- pedOne
pedOneCorrected$sex <- correctParentSex(
  pedOne$id, pedOne$sire, pedOne$dam,
  pedOne$sex, pedOne$recordStatus
)
pedOne[pedOne$sex != pedOneCorrected$sex, ]
#>   id sire  dam sex recordStatus
#> 1 s1 <NA> <NA>   F     original
pedOneCorrected[pedOne$sex != pedOneCorrected$sex, ]
#>   id sire  dam sex recordStatus
#> 1 s1 <NA> <NA>   M     original

pedTwoCorrected <- pedTwo
pedTwoCorrected$sex <- correctParentSex(
  pedTwo$id, pedTwo$sire, pedTwo$dam,
  pedTwo$sex, pedOne$recordStatus
)
pedTwo[pedTwo$sex != pedTwoCorrected$sex, ]
#>   id sire dam sex recordStatus
#> 2 d1   s0  d0   M     original
pedTwoCorrected[pedTwo$sex != pedTwoCorrected$sex, ]
#>   id sire dam sex recordStatus
#> 2 d1   s0  d0   F     original
```
