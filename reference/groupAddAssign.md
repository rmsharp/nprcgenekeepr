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
  maxCandidates = 5L,
  exhaustive = FALSE,
  maxExhaustiveCandidates = 20L,
  exhaustiveTimeLimit = 10,
  ancestryRules = NULL,
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

- maxCandidates:

  Integer value indicating the maximum number of distinct candidate
  solutions to retain during the simulation (issue \#146 Slice 1).
  Default is 5.

- exhaustive:

  Logical. When `TRUE`, enumerate every maximal independent set of the
  conflict graph instead of random sampling (issue \#146 Slice 2),
  subject to `maxExhaustiveCandidates`/ `exhaustiveTimeLimit`. Only
  supported for `numGp = 1`, `harem = FALSE`, `sexRatio = 0` – any other
  combination [`stop()`](https://rdrr.io/r/base/stop.html)s with a
  message naming the specific unsupported condition, rather than
  silently falling back to sampling. Default is `FALSE` (the existing
  sampling behavior, unchanged).

- maxExhaustiveCandidates:

  Integer. Pre-flight feasibility ceiling for `exhaustive = TRUE`: a
  candidate pool larger than this
  [`stop()`](https://rdrr.io/r/base/stop.html)s before any enumeration
  runs. Default is 20.

- exhaustiveTimeLimit:

  Numeric. Wall-clock seconds allowed for `exhaustive = TRUE`'s search
  before it truncates gracefully (`exhaustive = FALSE` in the return
  value, not an error). Default is 10.

- ancestryRules:

  Optional data frame of ancestry compatibility rules (issue \#168), in
  the shape
  [`checkAncestryRules`](https://github.com/rmsharp/nprcgenekeepr/reference/checkAncestryRules.md)
  validates – it is (re-)validated here, so structural or domain errors
  [`stop()`](https://rdrr.io/r/base/stop.html) with the validator's
  specific message. Default `NULL`: no rules, behavior identical to
  previous versions. When supplied, `ped` must carry an `ancestry`
  column (an error otherwise, so a script user who passed rules gets
  truth, not silence). `block`-severity rules exclude their conflicting
  pairs during formation – in sampling, exhaustive, and `sexRatio`
  modes, and sex-blind (deliberately bypassing the female-female kinship
  exemption in `ignore`). `flag`-severity rules never affect the search;
  compute them afterward with
  [`reportAncestryViolations`](https://github.com/rmsharp/nprcgenekeepr/reference/reportAncestryViolations.md).
  Known limitation (shared with the kinship machinery): a harem's
  sampled sire is seeded into the group before the fill loop, so
  conflicts against the sire himself are not enforced – only pairs among
  loop-placed members are.

- updateProgress:

  Function or NULL. If this function is defined, it will be called
  during each iteration to update a
  [`shiny::Progress`](https://rdrr.io/pkg/shiny/man/Progress.html)
  object.

## Value

A list with list items `group`, `score`, `candidates` and optionally
`groupKin`. The list item `group` contains a list of the best group(s)
produced during the simulation (an alias for `candidates[[1]]$group`,
kept for backward compatibility). The list item `score` provides the
score associated with the group(s) (an alias for
`candidates[[1]]$score`). The list item `candidates` is a list of up to
`maxCandidates` distinct candidate solutions (default 5; issue \#125,
configurable per issue \#146 Slice 1), each a list with its own `group`,
`score` and, when `withKin = TRUE`, `groupKin`, ordered best-scoring
first. Candidates are deduplicated by partition content, not by score –
two trials with the same score but different membership both count as
distinct candidates; two trials with identical membership count once.
The list item `groupKin` contains the subset of the kinship matrix that
is specific for each group formed in the best candidate (an alias for
`candidates[[1]]$groupKin`). When `exhaustive = TRUE` was requested
(issue \#146 Slice 2), three additional top-level items are present –
absent entirely, not merely `NULL`, when `exhaustive = FALSE` (the
default): `exhaustive` (logical, whether the search completed before its
wall-clock deadline), `examined` (integer, the total number of distinct
maximal independent sets found), and `retentionRule` (character,
describing the top-`maxCandidates` cutoff actually applied to
`candidates`).

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

## References

Vinson, A. and Raboin, M.J. (2015) "A Practical Approach for Designing
Breeding Groups to Maximize Genetic Diversity in a Large Colony of
Captive Rhesus Macaques (*Macaca mulatta*)" *Journal of the American
Association for Laboratory Animal Science*, 2015 Nov, Vol.54(6),
pp.700-707.

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
#>  [1] "653J82" "967Y3D" "1GF3GM" "WNEAS6" "PYPM1W" "NK802Y" "YTJ2UL" "G58RGY"
#>  [9] "S3EBGZ" "D4B0RM" "AW400C" "PI4VHT" "LS184H" "ZH3YG1" "92UG4N" "1QVS67"
#> [17] "5EDLL7" "FL170P" "Y0TCYX" "MTCAIG" "321LLB" "T3QPW5" "QCA36T" "Z904TJ"
#> [25] "W6MDVK" "DCJJYS" "0XTZQ1" "3SKITJ" "1SPLS8" "D9P18Y" "EMV4P6"
#> 
#> [[2]]
#>  [1] "FX9E4X" "2F6J3U" "8JUUJ9" "AP1YLW" "W5WIRP" "HE0SCR" "AZ3L0D" "5ERY5Z"
#>  [9] "PJ72W1" "414N7M" "83HQBN" "M9PVG5" "S056D5" "5KWNMZ" "BKWE4D" "N79QXB"
#> [17] "MX4J7G" "EX5K0S" "S7IWWA" "CLSVU6" "RVHVTZ" "JLFKV8" "BS3RLE" "ESUIAF"
#> [25] "CRPXY7" "6KWVRI" "ZATMEE" "I8ABC7" "SCFSBF" "WI38KZ" "TEACA3" "5EDIEE"
#> [33] "0SGJ12" "S5H1GC"
#> 
#> [[3]]
#>  [1] "9FRCIE" "RJ4JPC" "Q8U9LB" "DRXMW4" "DPXEQE" "7NE2UT" "AR5U44" "1SSCJC"
#>  [9] "PBAFJF" "WK89I9" "N4NV8B" "9MG040" "1CIRC9" "3GECJJ" "FG0SFA" "465ERA"
#> [17] "1KJ2MG" "SHG3RB" "MKY9TK" "NN3GDQ" "KX0RJ3" "9P0DES" "5BPBUI" "PVY432"
#> [25] "SH3FB7" "99BMJW" "DKIM6U" "X694YR" "GIIEUD"
#> 
#> [[4]]
#>  [1] "80KACX" "Q17CG3" "PU7RSG" "MPIQ4N" "13B1QL" "BCJJKN" "CMMUKU" "C18V6I"
#>  [9] "ZPS15A" "72LYDE" "H2J6UA" "7RA57Q" "WJXIH9" "AFZKBS" "XEC0M5" "B134XZ"
#> [17] "CS23RV" "MFKT9C" "FJS7RQ" "6F9FB8" "IH1KPA" "MYUMMX" "GTLA8R" "TXZUKC"
#> [25] "F7I2ED" "7B9CA6" "DH9WJQ" "GCBYDW" "50D77I" "3DTD2N" "5W621W" "Y6DB6L"
#> [33] "FB5L3N" "E5Q33K" "AR17R5" "QQMBT1"
#> 
#> [[5]]
#>  [1] "8IG767" "46ZHKN" "YLRNIK" "WTE53B" "G8MCV7" "DHNQ1W" "ZQXZYB" "0HYZ23"
#>  [9] "I5CI33" "QWKFBH" "WKY2SZ" "S222R3" "WLMGS1" "B228Q6" "QRZK48" "0IIAEN"
#> [17] "VWC5ZH" "TYEWF1" "LVYYNY" "G25E3F" "0X4W26" "1FAZ0K" "LYSLPP" "GAS52W"
#> [25] "F45799" "XYRDKV" "2Z4YLY" "J3F6PD" "TQEMY6"
#> 
#> [[6]]
#>  [1] "T38W6H" "Q7U139" "XFWVVX" "1VP3UC" "CHK1ZX" "1CZM30" "EZ2F8A" "AIHJ8Z"
#>  [9] "ILVQVB" "YFCIHJ" "DI4AHD" "K3TNHP" "5IAFMK" "N5QBWD" "3YJIMV" "30J3CQ"
#> [17] "KZY6PD" "7ZNY75" "87AQLF" "D33J06" "QW2Z3R" "QCENKM" "MH88T6" "01QRQ4"
#> [25] "MB6NYQ" "6X6BG9" "KEA4QG" "38K2SR" "B1WVCN" "W0GUKI" "R5AYJK"
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
#>  [1] "DCJJYS" "5PW7WT" "S056D5" "7ZNY75" "BCJJKN" "CLSVU6" "XFWVVX" "D9P18Y"
#>  [9] "967Y3D" "AIHJ8Z" "LS184H" "87AQLF" "SCFSBF" "3P9BX6" "30J3CQ" "QCA36T"
#> [17] "5ERY5Z" "EX5K0S" "TQEMY6" "3DTD2N" "PBAFJF" "ZATMEE" "N5QBWD" "T3QPW5"
#> [25] "5KFB90" "B1WVCN" "QW2Z3R" "B228Q6" "BS3RLE" "KEA4QG" "QRZK48" "AW400C"
#> [33] "CHK1ZX" "DRXMW4" "2F1IV1"
#> 
#> [[2]]
#>  [1] "99BMJW" "YHHVC7" "WNEAS6" "AFZKBS" "1CZM30" "BKWE4D" "ESUIAF" "8JUUJ9"
#>  [9] "MH88T6" "N79QXB" "QCENKM" "CRPXY7" "DPXEQE" "K7900I" "TYEWF1" "RVHVTZ"
#> [17] "K3TNHP" "5EDIEE" "Q7U139" "N4NV8B" "PI4VHT" "01QRQ4" "1QVS67" "5EDLL7"
#> [25] "Z7NBA2"
#> 
#> [[3]]
#>  [1] "YTJ2UL" "1E8KD1" "VWC5ZH" "6KWVRI" "7RA57Q" "R5AYJK" "5IAFMK" "50D77I"
#>  [9] "46ZHKN" "NK802Y" "13B1QL" "5KWNMZ" "PVY432" "5XVTVH" "DHNQ1W" "Q17CG3"
#> [17] "1CIRC9" "RJ4JPC" "FG0SFA" "PYPM1W" "X694YR" "LYSLPP" "S222R3" "C18V6I"
#> [25] "3MMZD4" "SH3FB7" "EMV4P6" "G25E3F" "1GF3GM" "D4B0RM" "414N7M" "5W621W"
#> [33] "MX4J7G" "J3F6PD" "A6A1M1"
#> 
#> [[4]]
#>  [1] "GIIEUD" "G2GYST" "9MG040" "AR5U44" "YLRNIK" "AR17R5" "CS23RV" "0SGJ12"
#>  [9] "AZ3L0D" "PU7RSG" "ILVQVB" "MYUMMX" "3YJIMV" "BTTHAJ" "7B9CA6" "465ERA"
#> [17] "B134XZ" "7NE2UT" "H2J6UA" "JLFKV8" "TXZUKC" "MFKT9C" "NN3GDQ" "LVYYNY"
#> [25] "Z25D52" "TEACA3"
#> 
#> [[5]]
#>  [1] "2Z4YLY" "T38W6H" "DKIM6U" "SHG3RB" "G58RGY" "ZH3YG1" "WKY2SZ" "FJS7RQ"
#>  [9] "321LLB" "S3EBGZ" "1KJ2MG" "KX0RJ3" "PJ72W1" "FLIZQI" "0X4W26" "FL170P"
#> [17] "GCBYDW" "YFCIHJ" "GTLA8R" "ZPS15A" "IH1KPA" "1FAZ0K" "WI38KZ" "Q8U9LB"
#> [25] "LN1DLY" "1VP3UC"
#> 
#> [[6]]
#>  [1] "XYRDKV" "80F2MI" "G8MCV7" "W6MDVK" "XEC0M5" "QWKFBH" "WLMGS1" "3GECJJ"
#>  [9] "6F9FB8" "MKY9TK" "3SKITJ" "2F6J3U" "W0GUKI" "KZM9RB" "Y6DB6L" "EZ2F8A"
#> [17] "Y0TCYX" "0XTZQ1" "HE0SCR" "AP1YLW" "0HYZ23" "ZQXZYB" "Z904TJ" "GAS52W"
#> [25] "SXSVEH"
#> 
#> [[7]]
#>   [1] "WTE53B" "1SPLS8" "HLQ9SY" "6X6BG9" "B2CKHA" "FB5L3N" "GDXWJ1" "JSAP3H"
#>   [9] "MB6NYQ" "TR5L57" "WK89I9" "XC304E" "AEP5EG" "BW10CL" "CFD12A" "CHJ9D2"
#>  [17] "D33J06" "FTVE03" "IRFJ09" "KXHGRH" "LMJWTN" "M9PVG5" "Q9LWGX" "R6HV9A"
#>  [25] "RNQU14" "W5WIRP" "09LFE4" "38K2SR" "3QHAFI" "55BPSE" "5BPBUI" "72LYDE"
#>  [33] "83HQBN" "8IG767" "9FRCIE" "DH9WJQ" "ER464J" "F7I2ED" "FFGPS4" "FG6L7S"
#>  [41] "NHWTJ9" "P7RBPI" "S5H1GC" "TBCE78" "YI16QD" "1SSCJC" "4LHK19" "59NYZE"
#>  [49] "5IYDXN" "6KLWVC" "8TV4MT" "A98D7P" "AZ4D19" "CHSCFG" "DI4AHD" "EEGLWY"
#>  [57] "FX9E4X" "G91ZM6" "I5CI33" "I8ABC7" "J1R2EW" "KZY6PD" "LDND6J" "MPIQ4N"
#>  [65] "MQT080" "MTCAIG" "NSIC4I" "PHB6TE" "QRWYQZ" "RY1AZM" "WHQLH5" "WQUN84"
#>  [73] "XL658N" "XX0GYV" "YP910X" "0IIAEN" "0V4SAC" "0X1RZ9" "3YHBC1" "55VDSQ"
#>  [81] "653J82" "6MEP2C" "76DIT4" "80KACX" "92UG4N" "9P0DES" "B2YJJP" "CMMUKU"
#>  [89] "E3JP0C" "E5Q33K" "F45799" "GM371F" "IZDV8K" "MEUZ85" "PA9F3J" "QQMBT1"
#>  [97] "S7IWWA" "TJN1AD" "WJXIH9" "WNKKW3" "XY2CK7" "XZH41H" "YDRD81" "ZDRSG0"
#> [105] "7D09WH" "DGZLV3" "S63QDN" "ZW2X4N"
#> 
```
