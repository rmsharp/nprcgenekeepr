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
  including the IDs listed in `candidates`.

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
#> Warning: Founder genome equivalents undefined: founder(s) with positive contribution were retained in 0 of the gene-drop iterations; raise the number of iterations (K).
#> Warning: Founder genome equivalents undefined: founder(s) with positive contribution were retained in 0 of the gene-drop iterations; raise the number of iterations (K).
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
#>  [1] "80KACX" "GIIEUD" "SHG3RB" "WI38KZ" "WKY2SZ" "CRPXY7" "1SPLS8" "5IAFMK"
#>  [9] "AP1YLW" "NN3GDQ" "D33J06" "1FAZ0K" "S3EBGZ" "1VP3UC" "MX4J7G" "EX5K0S"
#> [17] "T3QPW5" "967Y3D" "C18V6I" "MYUMMX" "SCFSBF" "R5AYJK" "1SSCJC" "IH1KPA"
#> [25] "K3TNHP" "DH9WJQ" "1GF3GM" "J3F6PD" "FJS7RQ" "465ERA" "W0GUKI" "GAS52W"
#> [33] "7NE2UT" "5KWNMZ" "0SGJ12" "2F6J3U" "FG0SFA" "0HYZ23" "G25E3F"
#> 
#> [[2]]
#>  [1] "TBCE78" "YTJ2UL" "BKWE4D" "LS184H" "CHK1ZX" "QRZK48" "AIHJ8Z" "Q8U9LB"
#>  [9] "XEC0M5" "E5Q33K" "DRXMW4" "50D77I" "AW400C" "I8ABC7" "AR5U44" "ZPS15A"
#> [17] "PYPM1W" "S222R3" "MKY9TK" "83HQBN" "0XTZQ1" "6F9FB8" "5W621W" "321LLB"
#> [25] "DKIM6U" "BS3RLE" "MFKT9C" "3DTD2N" "Q7U139" "Z904TJ" "XFWVVX"
#> 
#> [[3]]
#>  [1] "1E8KD1" "WLMGS1" "46ZHKN" "S5H1GC" "1QVS67" "ILVQVB" "1CZM30" "0IIAEN"
#>  [9] "WK89I9" "KZY6PD" "GTLA8R" "G8MCV7" "3GECJJ" "LYSLPP" "H2J6UA" "W6MDVK"
#> [17] "DHNQ1W" "D9P18Y" "8JUUJ9" "KX0RJ3" "F7I2ED" "3YJIMV" "5ERY5Z" "WNEAS6"
#> [25] "HE0SCR" "5EDIEE" "2Z4YLY" "CS23RV" "414N7M" "G58RGY" "72LYDE" "RVHVTZ"
#> [33] "FL170P"
#> 
#> [[4]]
#>  [1] "Q9LWGX" "6X6BG9" "92UG4N" "S7IWWA" "TYEWF1" "QCENKM" "MTCAIG" "B228Q6"
#>  [9] "N79QXB" "TQEMY6" "Y0TCYX" "3SKITJ" "AZ3L0D" "M9PVG5" "LVYYNY" "5BPBUI"
#> [17] "87AQLF" "CMMUKU" "1KJ2MG" "TXZUKC" "F45799" "NK802Y" "ZH3YG1" "JLFKV8"
#> [25] "B134XZ" "QCA36T" "PU7RSG" "01QRQ4" "TEACA3" "BCJJKN"
#> 
#> [[5]]
#>  [1] "WHQLH5" "6KWVRI" "7RA57Q" "30J3CQ" "9P0DES" "D4B0RM" "5EDLL7" "YFCIHJ"
#>  [9] "FB5L3N" "PI4VHT" "QQMBT1" "ZATMEE" "N5QBWD" "99BMJW" "PVY432" "1CIRC9"
#> [17] "AR17R5" "WTE53B" "13B1QL" "SH3FB7" "B1WVCN" "QWKFBH" "MPIQ4N" "MB6NYQ"
#> [25] "7ZNY75" "GCBYDW" "XYRDKV" "S056D5" "VWC5ZH" "38K2SR"
#> 
#> [[6]]
#>  [1] "3MMZD4" "X694YR" "Y6DB6L" "0X4W26" "DCJJYS" "ESUIAF" "WJXIH9" "I5CI33"
#>  [9] "ZQXZYB" "PBAFJF" "Q17CG3" "W5WIRP" "QW2Z3R" "AFZKBS" "N4NV8B" "RJ4JPC"
#> [17] "9MG040" "EMV4P6" "EZ2F8A" "DI4AHD" "PJ72W1" "CLSVU6" "YLRNIK" "MH88T6"
#> [25] "7B9CA6" "KEA4QG" "DPXEQE"
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
#>  [1] "9MG040" "B2YJJP" "38K2SR" "0X4W26" "QRZK48" "S222R3" "MH88T6" "DPXEQE"
#>  [9] "QQMBT1" "Q8U9LB" "83HQBN" "GIIEUD" "AR5U44" "G2GYST" "S056D5" "LVYYNY"
#> [17] "PU7RSG" "AW400C" "LS184H" "D33J06" "Y0TCYX" "CHK1ZX" "JLFKV8" "5EDLL7"
#> [25] "KZM9RB"
#> 
#> [[2]]
#>  [1] "5EDIEE" "80KACX" "ESUIAF" "7RA57Q" "IH1KPA" "5KWNMZ" "EMV4P6" "T3QPW5"
#>  [9] "Q7U139" "CMMUKU" "1CZM30" "B134XZ" "465ERA" "FG6L7S" "1SPLS8" "N5QBWD"
#> [17] "S7IWWA" "1FAZ0K" "F45799" "BS3RLE" "B228Q6" "967Y3D" "1KJ2MG" "GCBYDW"
#> [25] "LN1DLY"
#> 
#> [[3]]
#>  [1] "1CIRC9" "3MMZD4" "Y6DB6L" "R5AYJK" "MYUMMX" "AP1YLW" "WKY2SZ" "G25E3F"
#>  [9] "G58RGY" "6F9FB8" "SHG3RB" "M9PVG5" "NK802Y" "R6HV9A" "BKWE4D" "FG0SFA"
#> [17] "HE0SCR" "MPIQ4N" "TEACA3" "Q17CG3" "W6MDVK" "D9P18Y" "GAS52W" "MB6NYQ"
#> [25] "Z25D52" "8JUUJ9" "0SGJ12" "1SSCJC" "ZPS15A" "RVHVTZ" "EZ2F8A" "I5CI33"
#> [33] "QCA36T" "N4NV8B" "JSAP3H" "87AQLF" "H2J6UA" "MFKT9C" "S3EBGZ" "TYEWF1"
#> [41] "7B9CA6" "EX5K0S" "ZQXZYB"
#> 
#> [[4]]
#>  [1] "QWKFBH" "BW10CL" "5IAFMK" "ILVQVB" "PI4VHT" "99BMJW" "13B1QL" "VWC5ZH"
#>  [9] "YTJ2UL" "G8MCV7" "TQEMY6" "K3TNHP" "2F6J3U" "IRFJ09" "LYSLPP" "MTCAIG"
#> [17] "WNEAS6" "WI38KZ" "CS23RV" "CLSVU6" "5ERY5Z" "ZATMEE" "FB5L3N" "30J3CQ"
#> [25] "A6A1M1" "S5H1GC" "0IIAEN" "KEA4QG" "GTLA8R"
#> 
#> [[5]]
#>  [1] "0HYZ23" "CFD12A" "FL170P" "DH9WJQ" "F7I2ED" "W0GUKI" "3DTD2N" "PYPM1W"
#>  [9] "BCJJKN" "3GECJJ" "1VP3UC" "01QRQ4" "J3F6PD" "5PW7WT" "PVY432" "DCJJYS"
#> [17] "AIHJ8Z" "TXZUKC" "5W621W" "2Z4YLY" "WTE53B" "AR17R5" "W5WIRP" "72LYDE"
#> [25] "ZW2X4N" "E5Q33K" "DKIM6U" "PBAFJF" "1GF3GM"
#> 
#> [[6]]
#>  [1] "3SKITJ" "TBCE78" "50D77I" "3YJIMV" "DHNQ1W" "9P0DES" "AFZKBS" "7ZNY75"
#>  [9] "SH3FB7" "CRPXY7" "NN3GDQ" "92UG4N" "ZH3YG1" "9FRCIE" "MKY9TK" "XFWVVX"
#> [17] "WLMGS1" "FJS7RQ" "DI4AHD" "0XTZQ1" "I8ABC7" "XEC0M5" "321LLB" "KX0RJ3"
#> [25] "A98D7P" "1QVS67" "RJ4JPC" "X694YR" "5BPBUI"
#> 
#> [[7]]
#>   [1] "HLQ9SY" "6X6BG9" "B2CKHA" "GDXWJ1" "TR5L57" "WK89I9" "XC304E" "Z7NBA2"
#>   [9] "1E8KD1" "5KFB90" "AEP5EG" "CHJ9D2" "D4B0RM" "FTVE03" "K7900I" "KXHGRH"
#>  [17] "LMJWTN" "MX4J7G" "Q9LWGX" "RNQU14" "SCFSBF" "09LFE4" "3QHAFI" "414N7M"
#>  [25] "55BPSE" "5XVTVH" "6KWVRI" "8IG767" "ER464J" "FFGPS4" "N79QXB" "NHWTJ9"
#>  [33] "P7RBPI" "QCENKM" "YFCIHJ" "YI16QD" "2F1IV1" "4LHK19" "59NYZE" "5IYDXN"
#>  [41] "6KLWVC" "7NE2UT" "80F2MI" "8TV4MT" "AZ4D19" "B1WVCN" "BTTHAJ" "CHSCFG"
#>  [49] "DRXMW4" "EEGLWY" "FX9E4X" "G91ZM6" "J1R2EW" "KZY6PD" "LDND6J" "MQT080"
#>  [57] "NSIC4I" "PHB6TE" "PJ72W1" "QRWYQZ" "QW2Z3R" "RY1AZM" "WHQLH5" "WQUN84"
#>  [65] "XL658N" "XX0GYV" "XYRDKV" "YHHVC7" "YLRNIK" "YP910X" "Z904TJ" "0V4SAC"
#>  [73] "0X1RZ9" "3YHBC1" "46ZHKN" "55VDSQ" "653J82" "6MEP2C" "76DIT4" "AZ3L0D"
#>  [81] "C18V6I" "E3JP0C" "FLIZQI" "GM371F" "IZDV8K" "MEUZ85" "PA9F3J" "SXSVEH"
#>  [89] "T38W6H" "TJN1AD" "WJXIH9" "WNKKW3" "XY2CK7" "XZH41H" "YDRD81" "ZDRSG0"
#>  [97] "3P9BX6" "7D09WH" "DGZLV3" "S63QDN"
#> 
```
