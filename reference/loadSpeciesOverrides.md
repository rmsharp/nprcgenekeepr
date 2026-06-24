# Load user-configurable species reproductive-parameter overrides

Reads the optional species-override settings from the user's site
configuration file (`~/.nprcgenekeepr_config`, or
`~/_nprcgenekeepr_config` on Windows) and assembles the override tables
and fallbacks consumed by the Genetic Value Analysis (issue \#73 Part
2). The configuration may carry up to three optional keys, each looked
up softly (the `getConfigApiKey` pattern – absent keys are not an error
and never touch the fixed-schema
[`getSiteInfo`](https://github.com/rmsharp/nprcgenekeepr/reference/getSiteInfo.md)
parser):

- `speciesOverridesPath` – path to a CSV with the four
  [`speciesGestation`](https://github.com/rmsharp/nprcgenekeepr/reference/speciesGestation.md)
  columns (`species`, `gestation`, `minMaleBreedingAge`,
  `minFemaleBreedingAge`; header required, matched by name). A colony
  lists only the rows (species) it wants to change; the CSV is **merged
  onto** the bundled table, so every unlisted species keeps its bundled
  value (not replaced).

- `minBreedingAgeDefault` – numeric fallback (years) for a species
  absent from the table (bundled built-in 2.0).

- `gestationDefault` – integer fallback (days) for a species absent from
  the table (bundled built-in 210).

## Usage

``` r
loadSpeciesOverrides()
```

## Value

A named list with elements `breedingTable`, `gestationTable` (each the
merged
[`speciesGestation`](https://github.com/rmsharp/nprcgenekeepr/reference/speciesGestation.md)-shaped
data.frame, or `NULL` when no CSV is configured), `breedingAgeDefault`
(numeric or `NULL`), and `gestationDefault` (integer or `NULL`). A
`NULL` element means "use the bundled value / built-in default".

## Details

Like
[`loadSiteConfig`](https://github.com/rmsharp/nprcgenekeepr/reference/loadSiteConfig.md),
this never crashes the application on boot: a missing configuration
file, a missing override key, or a missing/malformed CSV all fall back
to the bundled values (a warning is raised for an unreadable CSV).

## See also

[`loadSiteConfig`](https://github.com/rmsharp/nprcgenekeepr/reference/loadSiteConfig.md),
[`getSpeciesMinBreedingAge`](https://github.com/rmsharp/nprcgenekeepr/reference/getSpeciesMinBreedingAge.md),
[`getSpeciesGestation`](https://github.com/rmsharp/nprcgenekeepr/reference/getSpeciesGestation.md),
[`reportGV`](https://github.com/rmsharp/nprcgenekeepr/reference/reportGV.md)
