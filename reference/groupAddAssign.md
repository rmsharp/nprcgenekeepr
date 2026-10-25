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
  0.5 are typical, but the range is not enforced. A male is placed only
  if he is at least `minAge` years old; a male younger than that, or
  with no birth date, is left out of the groups. A group stops being
  filled when it has no such male left, so it can end with fewer females
  than the ratio asks for. A non-zero `sexRatio` cannot be combined with
  `harem = TRUE`; the call stops with a message.

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
  minSireAge = 2, minDamAge = 2,
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
#>  [1] "KZM9RB" "K3TNHP" "VWC5ZH" "G8MCV7" "1SPLS8" "XEC0M5" "DKIM6U" "321LLB"
#>  [9] "T3QPW5" "FB5L3N" "5W621W" "Q7U139" "0HYZ23" "BKWE4D" "KX0RJ3" "38K2SR"
#> [17] "0IIAEN" "87AQLF" "GIIEUD" "5IAFMK" "1CZM30" "5EDLL7" "PYPM1W" "WK89I9"
#> [25] "ESUIAF" "GTLA8R" "1CIRC9" "QRZK48" "W5WIRP" "1KJ2MG"
#> 
#> [[2]]
#>  [1] "FFGPS4" "WLMGS1" "I5CI33" "XYRDKV" "MFKT9C" "99BMJW" "1SSCJC" "YLRNIK"
#>  [9] "6X6BG9" "2Z4YLY" "X694YR" "PBAFJF" "83HQBN" "S7IWWA" "30J3CQ" "PU7RSG"
#> [17] "EZ2F8A" "NK802Y" "QCENKM" "9MG040" "Y6DB6L" "7RA57Q" "IH1KPA" "AFZKBS"
#> [25] "PVY432" "7ZNY75" "0XTZQ1" "Q17CG3" "3GECJJ" "3YJIMV" "AIHJ8Z" "D4B0RM"
#> [33] "MYUMMX" "B134XZ" "MH88T6" "5BPBUI"
#> 
#> [[3]]
#>  [1] "ER464J" "YTJ2UL" "R5AYJK" "5KWNMZ" "ZATMEE" "1VP3UC" "RVHVTZ" "5EDIEE"
#>  [9] "S056D5" "W0GUKI" "6F9FB8" "6KWVRI" "NN3GDQ" "S222R3" "G25E3F" "DRXMW4"
#> [17] "B1WVCN" "WNEAS6" "1GF3GM" "RJ4JPC" "WKY2SZ" "KZY6PD" "XFWVVX" "GCBYDW"
#> [25] "WI38KZ" "MB6NYQ" "F45799" "DI4AHD" "FL170P" "3SKITJ"
#> 
#> [[4]]
#>  [1] "PHB6TE" "M9PVG5" "2F6J3U" "ILVQVB" "7NE2UT" "HE0SCR" "FJS7RQ" "1QVS67"
#>  [9] "TQEMY6" "50D77I" "N4NV8B" "CRPXY7" "QCA36T" "465ERA" "MTCAIG" "YFCIHJ"
#> [17] "92UG4N" "W6MDVK" "BCJJKN" "DPXEQE" "SH3FB7" "F7I2ED" "CS23RV" "J3F6PD"
#> [25] "DH9WJQ" "3DTD2N" "AZ3L0D" "DCJJYS" "MKY9TK" "8JUUJ9" "72LYDE" "967Y3D"
#> 
#> [[5]]
#>  [1] "FLIZQI" "ZH3YG1" "CHK1ZX" "N5QBWD" "7B9CA6" "S5H1GC" "WJXIH9" "AR5U44"
#>  [9] "BS3RLE" "D9P18Y" "SHG3RB" "LYSLPP" "TYEWF1" "EX5K0S" "AW400C" "ZPS15A"
#> [17] "B228Q6" "LS184H" "S3EBGZ" "KEA4QG" "PI4VHT" "DHNQ1W" "Q8U9LB" "MX4J7G"
#> [25] "WTE53B" "N79QXB" "EMV4P6" "5ERY5Z" "9P0DES"
#> 
#> [[6]]
#>  [1] "09LFE4" "LVYYNY" "JLFKV8" "13B1QL" "PJ72W1" "GAS52W" "AR17R5" "H2J6UA"
#>  [9] "MPIQ4N" "G58RGY" "E5Q33K" "01QRQ4" "FG0SFA" "QWKFBH" "QQMBT1" "QW2Z3R"
#> [17] "SCFSBF" "Y0TCYX" "Z904TJ" "D33J06" "0X4W26" "0SGJ12" "46ZHKN" "AP1YLW"
#> [25] "ZQXZYB" "TEACA3" "I8ABC7" "CLSVU6" "C18V6I" "1FAZ0K" "414N7M" "CMMUKU"
#> [33] "TXZUKC"
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
#>  [1] "IH1KPA" "B2CKHA" "YTJ2UL" "PVY432" "GCBYDW" "RVHVTZ" "DI4AHD" "FB5L3N"
#>  [9] "BKWE4D" "B134XZ" "ESUIAF" "ZATMEE" "EX5K0S" "1E8KD1" "G8MCV7" "YLRNIK"
#> [17] "1FAZ0K" "CRPXY7" "S056D5" "QCENKM" "0HYZ23" "WNEAS6" "S3EBGZ" "N5QBWD"
#> [25] "ZW2X4N"
#> 
#> [[2]]
#>  [1] "LYSLPP" "76DIT4" "0SGJ12" "92UG4N" "AFZKBS" "TEACA3" "S7IWWA" "KZY6PD"
#>  [9] "LS184H" "EZ2F8A" "W5WIRP" "83HQBN" "MYUMMX" "CFD12A" "QQMBT1" "MH88T6"
#> [17] "BS3RLE" "K3TNHP" "3YJIMV" "KX0RJ3" "2Z4YLY" "AIHJ8Z" "Y0TCYX" "QW2Z3R"
#> [25] "G2GYST"
#> 
#> [[3]]
#>  [1] "TXZUKC" "3QHAFI" "S222R3" "D33J06" "XEC0M5" "NK802Y" "QRZK48" "CMMUKU"
#>  [9] "465ERA" "967Y3D" "AR17R5" "ZH3YG1" "1CZM30" "WQUN84" "WI38KZ" "AR5U44"
#> [17] "ILVQVB" "JLFKV8" "AZ3L0D" "S5H1GC" "GTLA8R" "I5CI33" "VWC5ZH" "WJXIH9"
#> [25] "IZDV8K" "BCJJKN" "9P0DES"
#> 
#> [[4]]
#>  [1] "0X4W26" "KZM9RB" "7RA57Q" "6KWVRI" "GAS52W" "WKY2SZ" "DKIM6U" "ZQXZYB"
#>  [9] "FJS7RQ" "I8ABC7" "MPIQ4N" "1GF3GM" "SHG3RB" "GDXWJ1" "CHK1ZX" "PJ72W1"
#> [17] "30J3CQ" "M9PVG5" "Y6DB6L" "PI4VHT" "50D77I" "Q17CG3" "F7I2ED" "TQEMY6"
#> [25] "4LHK19"
#> 
#> [[5]]
#>  [1] "MX4J7G" "KXHGRH" "0XTZQ1" "WTE53B" "1QVS67" "87AQLF" "HE0SCR" "H2J6UA"
#>  [9] "FG0SFA" "DPXEQE" "5BPBUI" "B1WVCN" "Z904TJ" "JSAP3H" "5EDLL7" "AW400C"
#> [17] "D4B0RM" "5EDIEE" "TYEWF1" "321LLB" "B228Q6" "72LYDE" "414N7M" "2F6J3U"
#> [25] "R6HV9A" "F45799" "T3QPW5" "E5Q33K" "FL170P" "MFKT9C" "1SSCJC" "7ZNY75"
#> [33] "DCJJYS" "QWKFBH" "3MMZD4"
#> 
#> [[6]]
#>  [1] "W6MDVK" "55VDSQ" "XFWVVX" "Q7U139" "SH3FB7" "7NE2UT" "1SPLS8" "AP1YLW"
#>  [9] "GIIEUD" "NN3GDQ" "N4NV8B" "MB6NYQ" "46ZHKN" "A6A1M1" "CS23RV" "99BMJW"
#> [17] "PU7RSG" "DH9WJQ" "EMV4P6" "XYRDKV" "MTCAIG" "D9P18Y" "1CIRC9" "13B1QL"
#> [25] "LN1DLY" "PBAFJF"
#> 
#> [[7]]
#>   [1] "01QRQ4" "CLSVU6" "5IAFMK" "HLQ9SY" "6X6BG9" "RJ4JPC" "TR5L57" "WK89I9"
#>   [9] "XC304E" "Z7NBA2" "5ERY5Z" "5KFB90" "5PW7WT" "AEP5EG" "BW10CL" "CHJ9D2"
#>  [17] "FTVE03" "IRFJ09" "J3F6PD" "K7900I" "LMJWTN" "LVYYNY" "Q8U9LB" "Q9LWGX"
#>  [25] "RNQU14" "SCFSBF" "ZPS15A" "09LFE4" "1KJ2MG" "38K2SR" "3DTD2N" "3GECJJ"
#>  [33] "3SKITJ" "55BPSE" "5XVTVH" "6F9FB8" "7B9CA6" "8IG767" "9FRCIE" "ER464J"
#>  [41] "FFGPS4" "FG6L7S" "G25E3F" "N79QXB" "NHWTJ9" "P7RBPI" "R5AYJK" "TBCE78"
#>  [49] "YFCIHJ" "YI16QD" "1VP3UC" "2F1IV1" "59NYZE" "5IYDXN" "6KLWVC" "80F2MI"
#>  [57] "8JUUJ9" "8TV4MT" "9MG040" "A98D7P" "AZ4D19" "BTTHAJ" "CHSCFG" "DHNQ1W"
#>  [65] "DRXMW4" "EEGLWY" "FX9E4X" "G58RGY" "G91ZM6" "J1R2EW" "LDND6J" "MKY9TK"
#>  [73] "MQT080" "NSIC4I" "PHB6TE" "PYPM1W" "QRWYQZ" "RY1AZM" "WHQLH5" "WLMGS1"
#>  [81] "X694YR" "XL658N" "XX0GYV" "YHHVC7" "YP910X" "0IIAEN" "0V4SAC" "0X1RZ9"
#>  [89] "3YHBC1" "5KWNMZ" "5W621W" "653J82" "6MEP2C" "80KACX" "B2YJJP" "C18V6I"
#>  [97] "E3JP0C" "FLIZQI" "GM371F" "KEA4QG" "MEUZ85" "PA9F3J" "QCA36T" "SXSVEH"
#> [105] "T38W6H" "TJN1AD" "W0GUKI" "WNKKW3" "XY2CK7" "XZH41H" "YDRD81" "Z25D52"
#> [113] "ZDRSG0" "3P9BX6" "7D09WH" "DGZLV3" "S63QDN"
#> 
```
