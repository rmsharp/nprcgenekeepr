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
  groups. Defaults to `list(character(0L))`, a list with a single empty
  element regardless of `numGp`, assuming no groups are prepopulated.

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
  formation. Pairwise kinships involving an animal younger than this age
  (by the `age` column of `ped`) are ignored; an animal exactly this old
  is not ignored. Default is 1 year.

- iter:

  Integer indicating the number of times to perform the random group
  formation process. Default value is 1000 iterations.

- numGp:

  Integer value indicating the number of groups that should be formed
  from the list of IDs. Default is 1.

- harem:

  Logical variable when set to `TRUE`, the formed groups have a single
  male at least `minAge` old. A harem's sire is held to the same rules
  as every other animal: animals related to him at or above `threshold`
  (and, with `ancestryRules`, animals a block rule bars from him) are
  not placed in his group, and when that leaves no one the group is the
  sire alone. A group whose seed animals (`currentGroups`) include a
  male at least `minAge` old keeps him as its sire; a group with no
  seeded male is given a sire chosen at random from `candidates`. It
  cannot be combined with a non-zero `sexRatio`; the call stops with a
  message naming both settings.

- sexRatio:

  Numeric value indicating the number of non-males (females and animals
  of other or unknown sex) per male. Values from 0.5 to 20 in steps of
  0.5 are typical, but the range is not enforced. A non-zero `sexRatio`
  cannot be combined with `harem = TRUE`; the call stops with a message.

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

- updateProgress:

  Function or NULL. If this function is defined, it will be called
  during each iteration to update a
  [`shiny::Progress`](https://rdrr.io/pkg/shiny/man/Progress.html)
  object.

## Value

A list with list items `group`, `score`, `candidates` and optionally
`groupKin`. The list item `group` contains a list of the best group(s)
produced during the simulation (an alias for `candidates[[1]]$group`,
kept for backward compatibility). It has `numGp` groups plus a final
element holding the IDs of the unused candidates, or a bare `NA` if none
remain. The same holds for each `candidates[[i]]$group`. The list item
`score` provides the score associated with the group(s) (an alias for
`candidates[[1]]$score`); it ignores that final element. The list item
`candidates` is a list of up to `maxCandidates` distinct candidate
solutions (default 5; issue \#125, configurable per issue \#146 Slice
1), each a list with its own `group`, `score` and, when
`withKin = TRUE`, `groupKin`, ordered best-scoring first. Candidates are
deduplicated by partition content, not by score – two trials with the
same score but different membership both count as distinct candidates;
two trials with identical membership count once. The list item
`groupKin` contains the subset of the kinship matrix that is specific
for each group formed in the best candidate (an alias for
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
group is desired, it finds the set of groups with the largest minimum
group size (the score is the size of the smallest group).

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
#>  [1] "5XVTVH" "IH1KPA" "G25E3F" "HE0SCR" "92UG4N" "MFKT9C" "MYUMMX" "AP1YLW"
#>  [9] "3DTD2N" "8JUUJ9" "5BPBUI" "S3EBGZ" "S056D5" "3YJIMV" "MX4J7G" "7RA57Q"
#> [17] "PVY432" "WI38KZ" "N79QXB" "C18V6I" "DRXMW4" "Y6DB6L" "TEACA3" "CS23RV"
#> [25] "DPXEQE" "G58RGY" "5EDIEE" "D4B0RM" "0SGJ12" "GTLA8R" "FJS7RQ" "TXZUKC"
#> 
#> [[2]]
#>  [1] "9FRCIE" "ZQXZYB" "J3F6PD" "SCFSBF" "WJXIH9" "S7IWWA" "1SPLS8" "AZ3L0D"
#>  [9] "XEC0M5" "PU7RSG" "0XTZQ1" "WNEAS6" "W6MDVK" "0X4W26" "2F6J3U" "QRZK48"
#> [17] "RJ4JPC" "NN3GDQ" "MTCAIG" "B228Q6" "PYPM1W" "EMV4P6" "WLMGS1" "I5CI33"
#> [25] "YLRNIK" "7NE2UT" "GIIEUD" "NK802Y" "ZH3YG1"
#> 
#> [[3]]
#>  [1] "B2CKHA" "414N7M" "7B9CA6" "6KWVRI" "1SSCJC" "0HYZ23" "967Y3D" "LYSLPP"
#>  [9] "465ERA" "QCENKM" "QWKFBH" "ZATMEE" "W0GUKI" "Q8U9LB" "FL170P" "EX5K0S"
#> [17] "AW400C" "XFWVVX" "ILVQVB" "SHG3RB" "GAS52W" "BCJJKN" "DI4AHD" "YTJ2UL"
#> [25] "K3TNHP" "321LLB" "D9P18Y" "LVYYNY" "83HQBN"
#> 
#> [[4]]
#>  [1] "AEP5EG" "01QRQ4" "E5Q33K" "YFCIHJ" "5IAFMK" "RVHVTZ" "DH9WJQ" "BKWE4D"
#>  [9] "B1WVCN" "N4NV8B" "MPIQ4N" "EZ2F8A" "Y0TCYX" "JLFKV8" "DKIM6U" "5W621W"
#> [17] "1GF3GM" "MB6NYQ" "N5QBWD" "6F9FB8" "Z904TJ" "FB5L3N" "3SKITJ" "BS3RLE"
#> [25] "H2J6UA" "9MG040" "QW2Z3R" "1CZM30" "13B1QL" "ZPS15A" "38K2SR" "DHNQ1W"
#> [33] "D33J06" "5ERY5Z" "MKY9TK" "KX0RJ3" "W5WIRP" "QQMBT1"
#> 
#> [[5]]
#>  [1] "3MMZD4" "R5AYJK" "B134XZ" "AIHJ8Z" "LS184H" "GCBYDW" "2Z4YLY" "30J3CQ"
#>  [9] "ESUIAF" "I8ABC7" "XYRDKV" "46ZHKN" "AFZKBS" "72LYDE" "KEA4QG" "CMMUKU"
#> [17] "M9PVG5" "S222R3" "CLSVU6" "7ZNY75" "F7I2ED" "VWC5ZH" "QCA36T" "5EDLL7"
#> [25] "Q7U139" "G8MCV7" "DCJJYS" "3GECJJ" "0IIAEN" "S5H1GC" "MH88T6" "6X6BG9"
#> [33] "87AQLF"
#> 
#> [[6]]
#>  [1] "ER464J" "PJ72W1" "KZY6PD" "T3QPW5" "5KWNMZ" "FG0SFA" "CRPXY7" "WTE53B"
#>  [9] "1KJ2MG" "99BMJW" "PI4VHT" "1VP3UC" "SH3FB7" "X694YR" "TQEMY6" "1CIRC9"
#> [17] "Q17CG3" "1QVS67" "50D77I" "PBAFJF" "1FAZ0K" "TYEWF1" "F45799" "AR5U44"
#> [25] "AR17R5" "9P0DES" "CHK1ZX" "WKY2SZ" "WK89I9"
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
#>  [1] "BKWE4D" "P7RBPI" "JLFKV8" "01QRQ4" "HE0SCR" "B228Q6" "38K2SR" "WI38KZ"
#>  [9] "MTCAIG" "FJS7RQ" "5W621W" "QWKFBH" "BCJJKN" "NHWTJ9" "0X4W26" "87AQLF"
#> [17] "6X6BG9" "WK89I9" "CHK1ZX" "W0GUKI" "Z904TJ" "XYRDKV" "1GF3GM" "X694YR"
#> [25] "ZW2X4N"
#> 
#> [[2]]
#>  [1] "MYUMMX" "GM371F" "D4B0RM" "EMV4P6" "I8ABC7" "QQMBT1" "LS184H" "YTJ2UL"
#>  [9] "G25E3F" "VWC5ZH" "9P0DES" "ESUIAF" "C18V6I" "FFGPS4" "IH1KPA" "Q17CG3"
#> [17] "9MG040" "1SSCJC" "3GECJJ" "W5WIRP" "Q7U139" "N4NV8B" "3SKITJ" "S5H1GC"
#> [25] "3MMZD4" "PU7RSG" "DHNQ1W" "MB6NYQ" "1CZM30" "321LLB" "5BPBUI" "1SPLS8"
#> [33] "PVY432" "AFZKBS"
#> 
#> [[3]]
#>  [1] "ZPS15A" "A98D7P" "MPIQ4N" "0HYZ23" "M9PVG5" "F7I2ED" "G58RGY" "WLMGS1"
#>  [9] "0XTZQ1" "ILVQVB" "7RA57Q" "Q8U9LB" "MFKT9C" "A6A1M1" "6KWVRI" "I5CI33"
#> [17] "5EDLL7" "3YJIMV" "WNEAS6" "CLSVU6" "GIIEUD" "967Y3D" "46ZHKN" "GCBYDW"
#> [25] "IZDV8K" "AIHJ8Z" "CRPXY7" "7ZNY75" "3DTD2N" "SH3FB7" "Y6DB6L" "83HQBN"
#> [33] "1CIRC9" "72LYDE" "KZM9RB"
#> 
#> [[4]]
#>  [1] "FL170P" "BTTHAJ" "1QVS67" "FB5L3N" "QCA36T" "KX0RJ3" "YFCIHJ" "WJXIH9"
#>  [9] "WTE53B" "7B9CA6" "GAS52W" "5EDIEE" "5KWNMZ" "SXSVEH" "T3QPW5" "TXZUKC"
#> [17] "99BMJW" "ZATMEE" "NN3GDQ" "LYSLPP" "KZY6PD" "N5QBWD" "AR17R5" "DH9WJQ"
#> [25] "CFD12A" "K3TNHP" "G8MCV7" "W6MDVK" "MH88T6" "DCJJYS"
#> 
#> [[5]]
#>  [1] "QW2Z3R" "LMJWTN" "6F9FB8" "414N7M" "RVHVTZ" "DRXMW4" "AR5U44" "ZH3YG1"
#>  [9] "DPXEQE" "D9P18Y" "5ERY5Z" "XEC0M5" "13B1QL" "R6HV9A" "PJ72W1" "S222R3"
#> [17] "SHG3RB" "B1WVCN" "AZ3L0D" "PBAFJF" "1FAZ0K" "AW400C" "BS3RLE" "S7IWWA"
#> [25] "JSAP3H" "YLRNIK" "ZQXZYB" "30J3CQ" "2Z4YLY" "D33J06" "2F6J3U" "EX5K0S"
#> [33] "MX4J7G" "N79QXB"
#> 
#> [[6]]
#>  [1] "PI4VHT" "EEGLWY" "8JUUJ9" "KEA4QG" "EZ2F8A" "MKY9TK" "DKIM6U" "0SGJ12"
#>  [9] "CMMUKU" "TYEWF1" "GTLA8R" "DI4AHD" "TQEMY6" "K7900I" "S3EBGZ" "AP1YLW"
#> [17] "R5AYJK" "PYPM1W" "F45799" "B134XZ" "WKY2SZ" "50D77I" "1KJ2MG" "92UG4N"
#> [25] "G2GYST"
#> 
#> [[7]]
#>  [1] "5IAFMK" "HLQ9SY" "XFWVVX" "B2CKHA" "GDXWJ1" "RJ4JPC" "TR5L57" "XC304E"
#>  [9] "Z7NBA2" "1E8KD1" "5KFB90" "5PW7WT" "AEP5EG" "BW10CL" "CHJ9D2" "FTVE03"
#> [17] "IRFJ09" "J3F6PD" "KXHGRH" "LVYYNY" "Q9LWGX" "RNQU14" "SCFSBF" "TEACA3"
#> [25] "Y0TCYX" "09LFE4" "3QHAFI" "55BPSE" "5XVTVH" "8IG767" "9FRCIE" "ER464J"
#> [33] "FG6L7S" "H2J6UA" "QCENKM" "TBCE78" "YI16QD" "1VP3UC" "2F1IV1" "4LHK19"
#> [41] "59NYZE" "5IYDXN" "6KLWVC" "7NE2UT" "80F2MI" "8TV4MT" "AZ4D19" "CHSCFG"
#> [49] "FG0SFA" "FX9E4X" "G91ZM6" "J1R2EW" "LDND6J" "LN1DLY" "MQT080" "NK802Y"
#> [57] "NSIC4I" "PHB6TE" "QRWYQZ" "RY1AZM" "S056D5" "WHQLH5" "WQUN84" "XL658N"
#> [65] "XX0GYV" "YHHVC7" "YP910X" "0IIAEN" "0V4SAC" "0X1RZ9" "3YHBC1" "465ERA"
#> [73] "55VDSQ" "653J82" "6MEP2C" "76DIT4" "80KACX" "B2YJJP" "CS23RV" "E3JP0C"
#> [81] "E5Q33K" "FLIZQI" "MEUZ85" "PA9F3J" "QRZK48" "T38W6H" "TJN1AD" "WNKKW3"
#> [89] "XY2CK7" "XZH41H" "YDRD81" "Z25D52" "ZDRSG0" "3P9BX6" "7D09WH" "DGZLV3"
#> [97] "S63QDN"
#> 
```
