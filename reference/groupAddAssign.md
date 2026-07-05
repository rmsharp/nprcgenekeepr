# Add animals to a breeding group or form new groups

Part of Group Formation

## Usage

``` r
groupAddAssign(
  candidates,
  kmat,
  ped,
  currentGroups = list(character(0L)),
  threshold = 0.015625,
  ignore = list(c("F", "F")),
  minAge = 1,
  iter = 1000L,
  numGp = 1L,
  harem = FALSE,
  sexRatio = 0,
  withKin = FALSE,
  updateProgress = NULL
)
```

## Arguments

- candidates:

  Character vector of IDs of the animals available for use in forming
  the groups. The animals that may be present in `currentGroups` are not
  included within `candidates`.

- kmat:

  a numeric matrix of pairwise kinship coefficients. Animal IDs are the
  row and column names.

- ped:

  dataframe that is the `Pedigree`. It contains pedigree information
  including the IDs listed in `ids`.

- currentGroups:

  List of character vectors of IDs of animals currently assigned to
  groups. Defaults to a list with character(0) in each sublist element
  (one for each group being formed) assuming no groups are prepopulated.

- threshold:

  Numeric value indicating the minimum kinship level to be considered in
  group formation. Pairwise kinship below this level will be ignored.
  The default value is 0.015625.

- ignore:

  List of character vectors representing the sex combinations to be
  ignored. If provided, the vectors in the list specify if pairwise
  kinship should be ignored between certain sexes. Default is to ignore
  all pairwise kinship between females.

- minAge:

  Integer value indicating the minimum age to consider in group
  formation. Pairwise kinships involving an animal of this age or
  younger will be ignored. Default is 1 year.

- iter:

  Integer indicating the number of times to perform the random group
  formation process. Default value is 1000 iterations.

- numGp:

  Integer value indicating the number of groups that should be formed
  from the list of IDs. Default is 1.

- harem:

  Logical variable when set to `TRUE`, the formed groups have a single
  male at least `minAge` old.

- sexRatio:

  Numeric value indicating the ratio of females to males x from 0.5 to
  20 by increments of 0.5.

- withKin:

  Logical variable when set to `TRUE`, the kinship matrix for the group
  is returned along with the group and score. Defaults to not return the
  kinship matrix. This maintains compatibility with earlier versions.

- updateProgress:

  Function or NULL. If this function is defined, it will be called
  during each iteration to update a
  [`shiny::Progress`](https://rdrr.io/pkg/shiny/man/Progress.html)
  object.

## Value

A list with list items `group`, `score` and optionally `groupKin`. The
list item `group` contains a list of the best group(s) produced during
the simulation. The list item `score` provides the score associated with
the group(s). The list item `groupKin` contains the subset of the
kinship matrix that is specific for each group formed.

## Details

`groupAddAssign` finds the largest group that can be formed by adding
unrelated animals from a set of candidate IDs to an existing group, to a
new group it has formed from a set of candidate IDs or if more than 1
group is desired, it finds the set of groups with the largest average
size.

The function implements a maximal independent set (MIS) algorithm to
find groups of unrelated animals. A set of animals may have many
different MISs of varying sizes, and finding the largest would require
traversing all possible combinations of animals. Since this could be
very time consuming, this algorithm produces a random sample of the
possible MISs, and selects from these. The size of the random sample is
determined by the specified number of iterations.

## Examples

``` r
library(nprcgenekeepr)
examplePedigree <- nprcgenekeepr::examplePedigree
breederPed <- qcStudbook(examplePedigree,
  minParentAge = 2,
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
  guIter = 50, # should be >= 1000
  guThresh = 3,
  byID = TRUE,
  updateProgress = NULL
)
trimmedGeneticValue <- reportGV(trimmedPed,
  guIter = 50, # should be >= 1000
  guThresh = 3,
  byID = TRUE,
  updateProgress = NULL
)
candidates <- trimmedPed$id[trimmedPed$birth < as.Date("2013-01-01") &
  !is.na(trimmedPed$birth) &
  is.na(trimmedPed$exit)]
haremGrp <- groupAddAssign(
  kmat = trimmedGeneticValue[["kinship"]],
  ped = trimmedPed,
  candidates = candidates,
  iter = 10, # should be >= 1000
  numGp = 6,
  harem = TRUE
)
haremGrp$group
#> [[1]]
#>  [1] "80KACX" "1CIRC9" "AW400C" "TQEMY6" "XFWVVX" "MH88T6" "SHG3RB" "WJXIH9"
#>  [9] "0X4W26" "K3TNHP" "YLRNIK" "1FAZ0K" "1SSCJC" "H2J6UA" "1SPLS8" "5IAFMK"
#> [17] "AP1YLW" "Q17CG3" "G8MCV7" "3YJIMV" "QQMBT1" "7NE2UT" "Q8U9LB" "FL170P"
#> [25] "W0GUKI" "AIHJ8Z" "7ZNY75" "Y0TCYX" "3DTD2N" "5EDIEE" "DPXEQE" "DCJJYS"
#> [33] "0IIAEN" "QCENKM" "01QRQ4"
#> 
#> [[2]]
#>  [1] "09LFE4" "PVY432" "S7IWWA" "WK89I9" "XYRDKV" "MX4J7G" "AFZKBS" "CHK1ZX"
#>  [9] "FG0SFA" "PYPM1W" "8JUUJ9" "0XTZQ1" "F7I2ED" "NK802Y" "G58RGY" "S3EBGZ"
#> [17] "CMMUKU" "TYEWF1" "321LLB" "F45799" "I5CI33" "ESUIAF" "J3F6PD" "KZY6PD"
#> [25] "B134XZ" "1GF3GM" "TXZUKC" "3SKITJ" "NN3GDQ" "LYSLPP" "465ERA" "CS23RV"
#> 
#> [[3]]
#>  [1] "FLIZQI" "0HYZ23" "GCBYDW" "6F9FB8" "EMV4P6" "D9P18Y" "5W621W" "Q7U139"
#>  [9] "QRZK48" "ZATMEE" "72LYDE" "MYUMMX" "0SGJ12" "ZH3YG1" "87AQLF" "VWC5ZH"
#> [17] "D4B0RM" "PU7RSG" "38K2SR" "5KWNMZ" "D33J06" "MTCAIG" "N79QXB" "N4NV8B"
#> [25] "7B9CA6" "S5H1GC" "WKY2SZ" "YTJ2UL" "GIIEUD" "1QVS67" "DRXMW4" "PI4VHT"
#> [33] "DI4AHD" "JLFKV8" "FJS7RQ"
#> 
#> [[4]]
#>  [1] "ZW2X4N" "SCFSBF" "30J3CQ" "HE0SCR" "LS184H" "50D77I" "Z904TJ" "6X6BG9"
#>  [9] "AZ3L0D" "XEC0M5" "ZPS15A" "RVHVTZ" "PJ72W1" "DKIM6U" "R5AYJK" "WI38KZ"
#> [17] "13B1QL" "6KWVRI" "EX5K0S" "PBAFJF" "N5QBWD" "AR17R5" "9P0DES" "92UG4N"
#> [25] "414N7M" "WNEAS6" "GAS52W" "QW2Z3R" "KEA4QG"
#> 
#> [[5]]
#>  [1] "K7900I" "BCJJKN" "967Y3D" "E5Q33K" "YFCIHJ" "SH3FB7" "MPIQ4N" "5EDLL7"
#>  [9] "CLSVU6" "WLMGS1" "GTLA8R" "3GECJJ" "83HQBN" "BKWE4D" "B1WVCN" "C18V6I"
#> [17] "IH1KPA" "DHNQ1W" "2Z4YLY" "MB6NYQ" "S056D5" "QCA36T" "5ERY5Z" "W5WIRP"
#> [25] "AR5U44" "M9PVG5" "BS3RLE" "ILVQVB" "WTE53B" "5BPBUI" "EZ2F8A" "MKY9TK"
#> 
#> [[6]]
#>  [1] "PHB6TE" "1KJ2MG" "9MG040" "7RA57Q" "G25E3F" "T3QPW5" "B228Q6" "MFKT9C"
#>  [9] "1VP3UC" "RJ4JPC" "ZQXZYB" "99BMJW" "1CZM30" "FB5L3N" "LVYYNY" "Y6DB6L"
#> [17] "KX0RJ3" "46ZHKN" "TEACA3" "W6MDVK" "2F6J3U" "X694YR" "DH9WJQ" "S222R3"
#> [25] "QWKFBH" "I8ABC7" "CRPXY7"
#> 
#> [[7]]
#> [1] NA
#> 
sexRatioGrp <- groupAddAssign(
  kmat = trimmedGeneticValue[["kinship"]],
  ped = trimmedPed,
  candidates = candidates,
  iter = 10L, # should be >= 1000L
  numGp = 6L,
  sexRatio = 9.0
)
sexRatioGrp$group
#> [[1]]
#>  [1] "PU7RSG" "2F1IV1" "465ERA" "QCENKM" "DKIM6U" "7NE2UT" "QQMBT1" "83HQBN"
#>  [9] "3DTD2N" "N5QBWD" "WI38KZ" "1SSCJC" "W0GUKI" "9FRCIE" "ILVQVB" "MB6NYQ"
#> [17] "K3TNHP" "B228Q6" "S7IWWA" "C18V6I" "D33J06" "CRPXY7" "KZY6PD" "DI4AHD"
#> [25] "3MMZD4" "HE0SCR"
#> 
#> [[2]]
#>  [1] "KX0RJ3" "BW10CL" "CLSVU6" "AFZKBS" "1CZM30" "T3QPW5" "3YJIMV" "I5CI33"
#>  [9] "PBAFJF" "WK89I9" "ESUIAF" "0HYZ23" "YLRNIK" "KZM9RB" "W6MDVK" "IH1KPA"
#> [17] "5BPBUI" "D4B0RM" "ZH3YG1" "6KWVRI" "RVHVTZ" "0SGJ12" "2F6J3U" "S056D5"
#> [25] "PA9F3J" "1GF3GM" "MH88T6" "PYPM1W"
#> 
#> [[3]]
#>  [1] "5KWNMZ" "T38W6H" "B134XZ" "CS23RV" "6F9FB8" "6X6BG9" "JLFKV8" "TQEMY6"
#>  [9] "LYSLPP" "DCJJYS" "414N7M" "87AQLF" "H2J6UA" "GDXWJ1" "46ZHKN" "99BMJW"
#> [17] "8JUUJ9" "2Z4YLY" "FL170P" "01QRQ4" "PJ72W1" "GIIEUD" "F45799" "DHNQ1W"
#> [25] "IZDV8K"
#> 
#> [[4]]
#>  [1] "ZATMEE" "SXSVEH" "ZQXZYB" "XEC0M5" "NK802Y" "MYUMMX" "Q8U9LB" "EMV4P6"
#>  [9] "AP1YLW" "LVYYNY" "WNEAS6" "Y6DB6L" "TEACA3" "K7900I" "Q7U139" "5EDLL7"
#> [17] "7ZNY75" "S3EBGZ" "GCBYDW" "7B9CA6" "30J3CQ" "PI4VHT" "321LLB" "TXZUKC"
#> [25] "G2GYST"
#> 
#> [[5]]
#>  [1] "GTLA8R" "JSAP3H" "N4NV8B" "BKWE4D" "GAS52W" "YTJ2UL" "1QVS67" "TYEWF1"
#>  [9] "G58RGY" "CHK1ZX" "MX4J7G" "7RA57Q" "QCA36T" "S63QDN" "DH9WJQ" "WKY2SZ"
#> [17] "EZ2F8A" "9MG040" "FG0SFA" "AIHJ8Z" "Q17CG3" "5IAFMK" "AW400C" "3SKITJ"
#> [25] "GM371F" "PVY432" "KEA4QG" "MFKT9C" "N79QXB" "QWKFBH" "92UG4N" "WJXIH9"
#> [33] "B1WVCN" "XFWVVX" "A6A1M1"
#> 
#> [[6]]
#>  [1] "VWC5ZH" "5PW7WT" "1SPLS8" "5ERY5Z" "50D77I" "BS3RLE" "5W621W" "G8MCV7"
#>  [9] "XYRDKV" "1KJ2MG" "9P0DES" "FJS7RQ" "RJ4JPC" "CFD12A" "X694YR" "FB5L3N"
#> [17] "J3F6PD" "38K2SR" "13B1QL" "G25E3F" "S222R3" "EX5K0S" "SHG3RB" "72LYDE"
#> [25] "R6HV9A" "SH3FB7" "MTCAIG" "ZPS15A" "Z904TJ" "AZ3L0D" "AR5U44" "DRXMW4"
#> [33] "DPXEQE" "AR17R5" "Z25D52"
#> 
#> [[7]]
#>   [1] "WTE53B" "HLQ9SY" "B2CKHA" "BCJJKN" "TR5L57" "XC304E" "Z7NBA2" "1E8KD1"
#>   [9] "5KFB90" "AEP5EG" "CHJ9D2" "D9P18Y" "FTVE03" "IRFJ09" "KXHGRH" "LMJWTN"
#>  [17] "M9PVG5" "Q9LWGX" "RNQU14" "SCFSBF" "W5WIRP" "Y0TCYX" "09LFE4" "0X4W26"
#>  [25] "1CIRC9" "3GECJJ" "3QHAFI" "55BPSE" "5XVTVH" "8IG767" "ER464J" "F7I2ED"
#>  [33] "FFGPS4" "FG6L7S" "NHWTJ9" "P7RBPI" "R5AYJK" "S5H1GC" "TBCE78" "YFCIHJ"
#>  [41] "YI16QD" "1FAZ0K" "1VP3UC" "4LHK19" "59NYZE" "5EDIEE" "5IYDXN" "6KLWVC"
#>  [49] "80F2MI" "8TV4MT" "A98D7P" "AZ4D19" "BTTHAJ" "CHSCFG" "EEGLWY" "FX9E4X"
#>  [57] "G91ZM6" "I8ABC7" "J1R2EW" "LDND6J" "LN1DLY" "LS184H" "MKY9TK" "MPIQ4N"
#>  [65] "MQT080" "NN3GDQ" "NSIC4I" "PHB6TE" "QRWYQZ" "QW2Z3R" "RY1AZM" "WHQLH5"
#>  [73] "WLMGS1" "WQUN84" "XL658N" "XX0GYV" "YHHVC7" "YP910X" "0IIAEN" "0V4SAC"
#>  [81] "0X1RZ9" "0XTZQ1" "3YHBC1" "55VDSQ" "653J82" "6MEP2C" "76DIT4" "80KACX"
#>  [89] "967Y3D" "B2YJJP" "CMMUKU" "E3JP0C" "E5Q33K" "FLIZQI" "MEUZ85" "QRZK48"
#>  [97] "TJN1AD" "WNKKW3" "XY2CK7" "XZH41H" "YDRD81" "ZDRSG0" "3P9BX6" "7D09WH"
#> [105] "DGZLV3" "ZW2X4N"
#> 
```
