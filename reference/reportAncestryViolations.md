# Report ancestry-rule violations within formed groups

Issue \#168 Slice 2: the script-callable flag/inspection half of the
ancestry guardrails. Given any list of formed groups (for example the
`group` element returned by
[`groupAddAssign`](https://github.com/rmsharp/nprcgenekeepr/reference/groupAddAssign.md),
excluding its final unused-animals element), a pedigree carrying an
`ancestry` column, and a rules table in
[`checkAncestryRules`](https://github.com/rmsharp/nprcgenekeepr/reference/checkAncestryRules.md)'s
shape, it reports every within-group pair matching a rule – `block` and
`flag` severities alike – plus a rule-coverage summary so permissive
silence is visible (a level no rule names participates in no conflict;
the summary says how many animals sit at each level and whether any rule
covers it).

## Usage

``` r
reportAncestryViolations(groups, ped, rules, overriddenRules = NULL)
```

## Arguments

- groups:

  list of character vectors of animal IDs, one vector per formed group.
  `NA` entries (the empty unused-animals marker
  [`groupAddAssign`](https://github.com/rmsharp/nprcgenekeepr/reference/groupAddAssign.md)
  can produce) are ignored.

- ped:

  data frame with at least `id` and `ancestry` columns. Ancestry values
  are coerced with `toupper(trimws())`, so a
  post-[`qcStudbook`](https://github.com/rmsharp/nprcgenekeepr/reference/qcStudbook.md)
  pedigree and a hand-built frame both work.

- rules:

  data frame of ancestry compatibility rules; validated here via
  [`checkAncestryRules`](https://github.com/rmsharp/nprcgenekeepr/reference/checkAncestryRules.md).

- overriddenRules:

  optional data frame with `ancestry1` and `ancestry2` columns naming
  the rules overridden for this run (unordered match, case-insensitive).
  Default `NULL`: no overrides.

## Value

A list with two data.frames:

- violations:

  One row per violating within-group pair: `group` (integer index into
  `groups`), `id1`, `id2`, `ancestry1`, `ancestry2` (the two animals'
  own levels), `rule` (the matched rule's unordered pair as a sorted
  `"LEVEL-LEVEL"` string), `severity` (`"block"` or `"flag"`), and
  `status` (`"violation"` or `"overridden"`). Zero rows, same columns,
  when nothing violates.

- coverage:

  One row per standardized ancestry level (CHINESE, INDIAN, HYBRID,
  JAPANESE, OTHER, UNKNOWN): `ancestry`, `n` (animals in `groups` at
  that level), and `covered` (`TRUE` when at least one rule names the
  level).

## Details

A rule listed in `overriddenRules` still reports its violating pairs –
with `status` `"overridden"` rather than `"violation"`, never silently
absent. An `overriddenRules` row that matches no rule in `rules` is an
error, so a typo cannot silently disable nothing.

## Examples

``` r
library(nprcgenekeepr)
ped <- qcStudbook(
  read.csv(
    system.file("extdata", "examples", "example_ancestry_pedigree.csv",
      package = "nprcgenekeepr"
    ),
    stringsAsFactors = FALSE, na.strings = c("", "NA")
  ),
  minParentAge = 2, reportChanges = FALSE, reportErrors = FALSE
)
rules <- checkAncestryRules(readAncestryRules(
  system.file("extdata", "examples", "example_ancestry_rules.csv",
    package = "nprcgenekeepr"
  )
))
reportAncestryViolations(list(c("I1", "C1"), c("I2", "U1")), ped, rules)
#> $violations
#>   group id1 id2 ancestry1 ancestry2           rule severity    status
#> 1     1  I1  C1    INDIAN   CHINESE CHINESE-INDIAN    block violation
#> 2     2  I2  U1    INDIAN   UNKNOWN INDIAN-UNKNOWN     flag violation
#> 
#> $coverage
#>   ancestry n covered
#> 1  CHINESE 1    TRUE
#> 2   INDIAN 2    TRUE
#> 3   HYBRID 0    TRUE
#> 4 JAPANESE 0   FALSE
#> 5    OTHER 0    TRUE
#> 6  UNKNOWN 1    TRUE
#> 
```
