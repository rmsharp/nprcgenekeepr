# Run quality control on a studbook or pedigree

Main pedigree curation function that performs basic quality control on
pedigree information

## Usage

``` r
qcStudbook(
  sb,
  minSireAge = NULL,
  minDamAge = NULL,
  minParentAge = lifecycle::deprecated(),
  reportChanges = FALSE,
  reportErrors = FALSE
)
```

## Arguments

- sb:

  A dataframe containing a table of pedigree and demographic
  information.

  The function recognizes the following columns (optional columns will
  be used if present, but are not required):

  - `id` — Character vector with Unique identifier for all individuals

  - `sire` — Character vector with unique identifier for the father of
    the current id

  - `dam` — Character vector with unique identifier for the mother of
    the current id

  - `sex` — Factor (levels: "M", "F", "U") Sex specifier for an
    individual

  - `birth` — Date or `NA` (optional) with the individual's birth date

  - `departure` — Date or `NA` (optional) an individual was sold or
    shipped from the colony

  - `death` — date or `NA` (optional) Date of death, if applicable

  - `status` — Factor (levels: ALIVE, DECEASED, SHIPPED, UNKNOWN)
    (optional) Status of an individual (see `convertStatusCodes`)

  - `origin` — Character or `NA` (optional) Facility an individual
    originated from, if other than ONPRC

  - `ancestry` — Character or `NA` (optional) Geographic population to
    which the individual belongs

  - `spf` — Character or `NA` (optional) Specific pathogen-free status
    of an individual

  - `vasxOvx` — Character or `NA` (optional) Indicator of the
    vasectomy/ovariectomy status of an animal; `NA` if animal is intact,
    assume all other values indicate surgical alteration

  - `condition` — Character or `NA` (optional) Indicator of the
    restricted status of an animal. "Nonrestricted" animals are
    generally assumed to be naive.

  - `placeholder` — Logical or `NA` (optional) `TRUE` marks a made-up
    stand-in for an unknown parent, `FALSE` a real animal. `TRUE`,
    `true`, `True`, `T` and `1` count as `TRUE`; `FALSE`, `false`,
    `False`, `F` and `0` as `FALSE`; a blank as unmarked. Any other
    value is an error (listed in `errorLst$invalidPlaceholderRows` with
    `reportErrors == TRUE`, otherwise the function throws an error
    naming the rows).

- minSireAge:

  numeric minimum age in years for a male to have sired an offspring.
  `NULL` (default) looks up the floor for each sire's species via
  [`getSpeciesMinBreedingAge`](https://github.com/rmsharp/nprcgenekeepr/reference/getSpeciesMinBreedingAge.md)
  (falling back to 2 years when the species is missing or unknown); a
  supplied value overrides that floor.

- minDamAge:

  numeric minimum age in years for a female to have borne an offspring.
  `NULL` (default) looks up the floor for each dam's species via
  [`getSpeciesMinBreedingAge`](https://github.com/rmsharp/nprcgenekeepr/reference/getSpeciesMinBreedingAge.md)
  (falling back to 2 years when the species is missing or unknown); a
  supplied value overrides that floor.

- minParentAge:

  **\[deprecated\]** Deprecated scalar minimum parent age. Supplying it
  sets both `minSireAge` and `minDamAge`; use those sex-specific
  parameters instead.

- reportChanges:

  logical value that if `TRUE`, the `errorLst` contains the list of
  changes made to the column names. Default is `FALSE`.

- reportErrors:

  logical value if `TRUE` will scan the entire file and report back
  changes made to input and errors in a list of list where each sublist
  is a type of change or error found. Changes will include column names,
  case of categorical values (male, female, unknown), etc. Errors will
  include missing columns, invalid date rows, male dams, female sires,
  an ID that is both a sire and a dam, duplicated IDs, IDs with invalid
  characters, invalid `placeholder` values, and records with one or more
  parents below minimum age of parents.

  The following changes are made to the column names.

  - Column names are converted to all lower case

  - Spaces, periods (".") and underscores ("\_") within column names are
    removed

  - `egoid` and `ego` are converted to `id`

  - `sireid` is converted to `sire`

  - `damid` is converted to `dam`

  - `birthdate` and `deathdate` are converted to `birth` and `death`

  - `recordstatus`, `fromcenter` and `geographicorigin` are converted to
    `recordStatus`, `fromCenter` and `geographicOrigin`

  If the dataframe (`sb`) does not contain the five required columns
  (`id`, `sire`, `dam`, `sex`, and `birth`) and `reportErrors == FALSE`,
  the function throws an error by calling
  [`stop()`](https://rdrr.io/r/base/stop.html). With
  `reportErrors == TRUE` the missing names are returned in
  `errorLst$missingColumns`.

  Animal IDs (`id`, `sire`, `dam`) must not contain a period (".");
  other characters are accepted. Periods cause problems across software
  environments (R column-name and formula parsing, file-name extensions,
  programming-language namespaces, and regular expressions), so any
  `id`, `sire`, or `dam` value containing a period is treated as an
  error. With `reportErrors == TRUE` the offending values are returned
  in `errorLst$invalidIdChars`; otherwise the function throws an error.
  All automatically generated IDs (see `addUIds`) honor this rule.

  If the `id` field has the string *UNKNOWN* (any case), the record is
  removed. A record whose `sire` and `dam` are both `NA` or *UNKNOWN*
  (any case) is kept as a founder; *UNKNOWN* in either field becomes
  `NA`. If only one of the fields `sire` or `dam` is missing, the
  missing parent is replaced with a unique identifier with the form
  `Unnnn`, where `nnnn` represents one of a series of sequential
  integers representing the number of missing sires and dams right
  justified in a pattern of `0000`. See `addUIds` function.

  The function `addParents` is used to add records for parents missing
  their own record in the pedigree.

  The function `convertSexCodes` is used with `ignoreHerm == TRUE` to
  convert sex codes according to the following factors of standardized
  codes:

  - `F` – replacing "FEMALE" or "2"

  - `M` – replacing "MALE" or "1"

  - `H` – replacing "HERMAPHRODITE" or "4", if ignoreHerm == FALSE

  - `U` – replacing "HERMAPHRODITE" or "4", if ignoreHerm == TRUE

  - `U` – replacing "UNKNOWN" or "3"

  - `U` – replacing a missing, blank or unrecognized value

  Case and any spaces around a code are ignored. `qcStudbook` always
  uses the default `ignoreHerm == TRUE`, so `H` is never assigned,
  although the returned factor keeps the level `H`.

  The function `correctParentSex` is used to ensure no parent is both a
  sire and a dam. If this error is detected and `reportErrors == FALSE`,
  the function throws an error and halts the program (with
  `reportErrors == TRUE` the IDs are returned in `errorLst$sireAndDam`).
  It also recodes a female sire as male and a male dam as female; with
  `reportErrors == FALSE` this is silent, otherwise the IDs are reported
  in `errorLst$femaleSires` and `errorLst$maleDams`.

  The function `convertStatusCodes` converts status indicators to the
  following factors of standardized codes. Case of the original status
  value is ignored.

  - `"ALIVE"` — replacing "alive", "A" and "1"

  - `"DECEASED"` — replacing "deceased", "DEAD", "D", "2"

  - `"SHIPPED"` — replacing "shipped", "sold", "sale", "s", "3"

  - `"UNKNOWN"` — replacing is.na(status)

  - `"UNKNOWN"` — replacing "unknown", "U", "4"

  The function `convertAncestry` converts ancestry indicators using
  regular expressions such that the following conversions are made from
  character strings that match selected substrings to the following
  factors.

  - `"INDIAN"` — replacing "ind" and not "chin"

  - `"CHINESE"` — replacing "chin" and not "ind"

  - `"HYBRID"` — replacing "hyb" or "chin" and "ind"

  - `"JAPANESE"` — replacing "jap"

  - `"UNKNOWN"` — replacing `NA`

  - `"OTHER"` — replacing not matching any of the above

  The function `convertDate` converts character representations of dates
  in the columns `birth`, `death`, `departure`, and `exit` to dates
  using the `as.Date` function.

  The function `setExit` uses heuristics and the columns `death` and
  `departure` to set `exit` if it is not already defined.

  The function `calcAge` uses the `birth` and the `exit` columns to
  define the `age` column. The numerical value is rounded to the nearest
  0.1 of a year. If `exit` is not defined, the current system date
  ([`Sys.Date()`](https://rdrr.io/r/base/Sys.time.html)) is used.

  The function `findGeneration` is used to define the generation number
  for each animal in the pedigree.

  The function `removeDuplicates` checks for any duplicated records and
  removes the duplicates. It also throws an error and stops the program
  if an ID appears in more than one record where one or more of the
  other columns have a difference.

  The standard columns come first, followed by any unrecognized columns,
  which are retained. The rows are ordered by generation number and then
  ID.

  Finally the columns `id`, `sire`, and `dam` are coerced to character.

  The returned pedigree always has a logical `placeholder` column with
  no `NA`: `TRUE` for the stand-ins made here (see `addUIds`), the value
  the input gave for any other row that had one, and for the rest `TRUE`
  when the ID looks like a stand-in (see
  [`removeAutoGenIds`](https://github.com/rmsharp/nprcgenekeepr/reference/removeAutoGenIds.md)).
  A center can mark a real animal whose ID looks like a stand-in (for
  example `"U1234"`) as `FALSE`.

## Value

With `reportErrors == FALSE`, a data.frame with standardized and quality
controlled pedigree information. With `reportErrors == TRUE`, an
`nprcgenekeeprErr` list of the changes and errors found, or `NULL` when
there are no errors and no column changes to report.

## Examples

``` r
examplePedigree <- nprcgenekeepr::examplePedigree
ped <- qcStudbook(examplePedigree,
  minSireAge = 2.0, minDamAge = 2.0, reportChanges = FALSE,
  reportErrors = FALSE
)
names(ped)
#>  [1] "id"           "sire"         "dam"          "sex"          "gen"         
#>  [6] "birth"        "exit"         "age"          "ancestry"     "origin"      
#> [11] "status"       "recordStatus" "fromCenter"   "placeholder" 
```
