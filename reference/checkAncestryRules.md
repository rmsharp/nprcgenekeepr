# Validate an ancestry compatibility rules table

Checks the structure and domain of a center-configurable ancestry
compatibility rules table (issue \#168). Each row is one unordered pair
of standardized ancestry levels plus a severity: `block` rules exclude
the pairing during breeding-group formation, `flag` rules annotate it
afterward. It mirrors
[`checkKinshipOverrides`](https://github.com/rmsharp/nprcgenekeepr/reference/checkKinshipOverrides.md):
it [`stop()`](https://rdrr.io/r/base/stop.html)s on structural or domain
errors and returns the coerced table when the input is acceptable. An
empty table (zero rules) is valid.

## Usage

``` r
checkAncestryRules(rules)
```

## Arguments

- rules:

  data.frame with columns `ancestry1` and `ancestry2` (standardized
  ancestry levels) and `severity` (`"block"` or `"flag"`); each row is
  one unordered level pair. Any extra columns are ignored.

## Value

The validated `rules` data.frame with `ancestry1` and `ancestry2`
coerced to uppercase character and `severity` to lowercase character.

## Details

Ancestry levels must come from
[`convertAncestry`](https://github.com/rmsharp/nprcgenekeepr/reference/convertAncestry.md)'s
standardized vocabulary: CHINESE, INDIAN, HYBRID, JAPANESE, OTHER,
UNKNOWN. Levels are coerced to uppercase and `severity` to lowercase
before validation, so a hand-edited file's casing never matters. A rule
may pair a level with itself (e.g. HYBRID with HYBRID); duplicated
unordered pairs are a data error the user must resolve. Because
[`convertAncestry`](https://github.com/rmsharp/nprcgenekeepr/reference/convertAncestry.md)
maps a blank ancestry to UNKNOWN but any unrecognized text – including a
literal re-standardized `"UNKNOWN"` string – to OTHER, a table that
names one of UNKNOWN/OTHER without the other draws a warning here: a
center wanting conservative treatment of animals without usable ancestry
information almost always wants both.

## Examples

``` r
rules <- data.frame(
  ancestry1 = c("INDIAN", "INDIAN"),
  ancestry2 = c("CHINESE", "HYBRID"),
  severity = c("block", "flag"), stringsAsFactors = FALSE
)
checkAncestryRules(rules)
#>   ancestry1 ancestry2 severity
#> 1    INDIAN   CHINESE    block
#> 2    INDIAN    HYBRID     flag
```
