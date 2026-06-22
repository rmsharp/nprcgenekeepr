NEWS
================
R. Mark Sharp, Ph.D.
2026-01-26

# nprcgenekeepr (development version)

- Changes
  - File-based pedigree ingestion now treats `species` as a first-class
    column: `getPossibleCols()` recognizes it and places it immediately
    after `sex` in the canonical column order, and `qcStudbook()` types
    it as character. Previously a `species` column survived only as a
    trailing, untyped extra column. Studbooks that include a `species`
    column now have it consistently ordered and typed.
  - `getPotentialParents()` now derives its gestation-based conception
    window per focal animal from the animal's `species` rather than from
    a single fixed value. The `maxGestationalPeriod` argument is now
    optional (default `NULL`): when it is omitted, the window for each
    focal animal is looked up by species via the new
    `getSpeciesGestation()`; when an explicit value is supplied it is
    used for all animals, preserving the previous behavior, so existing
    callers are unaffected. The shipped species table currently defines
    only rhesus macaque (210 days) and falls back to 210 for other
    species, so results on existing data are unchanged; adding species
    rows enables per-species windows.
  - In the Potential Parents tab, the "Maximum Gestational Period
    (days)" input now defaults to the value looked up from the loaded
    pedigree's species (via `getSpeciesGestation()`) rather than to a
    fixed 210, keeping the Shiny application consistent with the
    species-keyed `getPotentialParents()` window. The user can still
    edit the value, and a manual edit is preserved when the pedigree is
    reloaded. As with `getPotentialParents()`, the shipped species table
    defines only rhesus macaque (210 days) and falls back to 210, so the
    default is unchanged on existing data until species rows are added.
  - `getLkDirectRelatives()` now returns the full connected pedigree
    component for the focal animals (ancestors, descendants, and
    collaterals such as siblings, mates, and their lineages) by
    delegating its pedigree walk to `getPedDirectRelatives()`.
    Previously it returned only the strict ancestor/descendant lineage
    and omitted collateral relatives. Pedigrees built from the
    LabKey/EHR path (via `getFocalAnimalPed()`) are now more complete
    and consistent with the in-memory `getPedDirectRelatives()`.
  - The exported convenience function `makeGrpNum()` has been renamed to
    `makeGroupNum()` for naming consistency with the sibling export
    `makeGroupMembers()`. The old name `makeGrpNum()` is kept as a
    deprecated alias: it still works but now emits a deprecation warning
    and delegates to `makeGroupNum()`. Prefer `makeGroupNum()` in new
    code; `makeGrpNum()` may be removed in a future release.
- New features
  - Added the exported `setLabKeyDefaults()`, which configures `Rlabkey`
    authentication for the session: it prefers an API key (from the
    `NPRCGENEKEEPR_LABKEY_APIKEY` environment variable, then an `apiKey`
    configuration-file token), falls back to a `.netrc`/`_netrc` file,
    and otherwise stops with a clear `No LabKey credential found` error.
    `getDemographics()` now configures authentication automatically
    before querying, so a missing credential fails fast instead of
    producing an opaque error later.
  - Added the exported `getFileDirectRelatives()`, a file-sourced
    sibling of `getLkDirectRelatives()`: it reads a pedigree file (CSV
    or Excel) via `getPedigree()` and returns the full connected
    pedigree component (ancestors, descendants, and collaterals) for the
    focal animals, reusing the source-agnostic `getPedDirectRelatives()`
    walk. It is fully offline and deterministic, and (unlike the
    fail-soft LabKey source) errors on a missing or invalid file. This
    wires the `getPedigreeSource()` `"file"` provider to a first-class
    caller, giving file pedigrees the same direct-relatives entry point
    LabKey already has.
  - Added the exported `getFocalAnimalPedFromFile()`, a file-sourced
    sibling of `getFocalAnimalPed()`: it reads a list of focal animal
    Ids from one file and builds the full connected pedigree component
    for those focal animals from a separate pedigree file via
    `getFileDirectRelatives()`, so the focal-animal workflow can run
    entirely offline with no LabKey/EHR connection. The Shiny input
    module (`modInput`) now offers an optional pedigree-file input on
    the focal animals path; when a pedigree file is supplied the
    pedigree is built from that file, otherwise the LabKey/EHR path is
    used as before. Being the application boundary, the function is
    fail-soft: rather than throwing, it returns a classed error whose
    message names WHY the read failed (an unreadable focal-id list file;
    a missing, not-found, unreadable, or wrong-column pedigree file; or
    no focal IDs found in the pedigree), and the app surfaces that
    message as the specific File Read Error detail instead of a generic
    one.
  - Added the exported `getSpeciesGestation()`, which returns the
    maximum gestation period (in days) for one or more species by
    looking them up in the new `speciesGestation` table. Matching is
    case- and whitespace-insensitive, and unknown, missing, or empty
    species fall back to a default (210 days, the rhesus macaque value).
    This is the per-species lookup that `getPotentialParents()` uses
    when `maxGestationalPeriod` is not supplied.
  - Added the exported `speciesGestation` data set, a
    species-to-gestation lookup table (in days) seeded with rhesus
    macaque (210). It is the extensible home for per-species gestation
    lengths; add a row to support an additional species.
- Documentation
  - The example configuration file
    (`inst/extdata/example_nprcgenekeepr_config`) now documents that
    `lkPedColumns` is center-specific: SNPRC uses the flat `dam`/`sire`
    columns (direct columns) while ONPRC uses the `Id/parents/dam`
    lookup-traversal form (curated parentage).
- Internal changes
  - The LabKey pedigree fetch used by `getLkDirectRelatives()` is now
    obtained through an internal data-source adapter
    (`getPedigreeSource()`), isolating the LabKey pull behind a single
    seam and enabling offline, deterministic tests of the pedigree walk.
    No change to behavior.
  - The internal `getPedigreeSource()` adapter gained a `"file"` source
    that reads a pedigree file (CSV or Excel) via `getPedigree()`,
    alongside the existing `"labkey"` and `"dataframe"` sources. This
    makes LabKey one pluggable provider among several and extends the
    offline, deterministic test seam.
  - The offline focal-animal path no longer prints a benign
    `cannot open file ...` warning when the focal-id list file is
    missing or unreadable. `getFocalAnimalPedFromFile()` already
    reported the failure as a classed error; the underlying `read.csv()`
    warning that leaked to the console ahead of the caught error is now
    muffled at the read site, so the fail-soft path is silent. The
    returned value and the reported error are unchanged.

# nprcgenekeepr 2.0.0 (20260618)

- Major changes
  - **(breaking)** `qcStudbook()` and `geneDrop()` now reject `id`,
    `sire`, or `dam` values containing a period (offenders returned in
    `errorLst$invalidIdChars`); auto-generated IDs remain period-free.
  - **(breaking)** `runModularApp()` is the new Shiny entry point and
    the monolithic application was retired; `runGeneKeepR()` is now a
    soft-deprecated alias (zero-argument calls still work), and the
    unused exports `getLogo()`, `shouldShowErrorTab()`,
    `modMinimalTestUI()`, and `modMinimalTestServer()` were removed.
    (#27)
  - New **Potential Parents** tab listing candidate sires and dams for
    in-colony animals with at least one unknown parent, screened by
    estimated conception date (wiring in the exported
    `getPotentialParents()`); dam selection now uses a
    `maxGestationalPeriod`-driven exclusion window (was a fixed +/-
    182.5-day window). (#48, \#31)
  - New **ORIP Reporting** tab with ONPRC colony summaries for the NIH
    Office of Research Infrastructure Programs (site information, a
    colony table with founder counts, genetic-diversity metrics, and CSV
    exports); shown only at ONPRC. (#47, \#49)
  - The Pedigree Browser "trim based on focal animals" option now
    includes descendants as well as ancestors, via the new exported
    `getDescendantPedigree()`. (#35)
  - Added the exported founder helpers `isFounder()` and
    `getFounders()`.
  - Added the exported `getAutoIdFormat()` and `setAutoIdFormat()`,
    making the auto-generated placeholder-ID format configurable
    (default `"U%04d"`). (#44, \#38)
  - Genetic Value Analysis tab parity: the genome-uniqueness threshold
    is now a user control (default 4), a subset filter and "Export
    Subset" download were added, the default gene-drop iterations
    changed to 1000, and an inert "Minimum breeding age" slider was
    removed.
  - Improved visualizations: educational box-plot popovers
    (`getBoxWhiskerDescription()`), plot export to PNG, PDF, and SVG
    (`savePlotToFile()`), and an enhanced age-sex pyramid
    (`getPyramidPlot()`).
- Minor changes
  - Fixed a startup crash that occurred when a documented-format site
    configuration file was present, via the new tolerant
    `loadSiteConfig()`. (#50)
  - The **About** panel now shows the installed package version
    dynamically (it previously displayed a hard-coded "Version 1.0.8").
  - `geneDrop()` now reports duplicate animal IDs with a clear error
    instead of the base-R `duplicate 'row.names' are not allowed`
    message.
  - Reading a file whose final line lacks a trailing newline no longer
    emits the spurious "incomplete final line" warning. (#4)
  - `addGenotype()` now coerces its allele columns to character, so the
    integer allele encoding is consistent whether they are supplied as
    character or factor.
  - Re-exported the bundled `rhesusPedigree` and `rhesusGenotypes` data
    sets with canonical column types (character `id`, `sire`, and `dam`
    and `Date` `birth` and `exit` in `rhesusPedigree`; all-character
    columns in `rhesusGenotypes`), preserving every value.
  - `summarizeKinshipValues()` now reports the `secondQuartile` column
    as the lower hinge (`fivenum()[2]`) instead of duplicating `min`.
  - New dependencies: `bslib`, `DT`, and `ggplot2` (Imports);
    `shinytest2` (Suggests).
  - Replaced the magrittr pipe (`%>%`) with the base R native pipe
    (`|>`) in vignettes and examples; `magrittr` is no longer used.
  - Documentation: extensive help-page and dataset-documentation
    corrections, including the genetic-value `@return` and parameter
    descriptions, dataset titles and descriptions, and the `@examples`
    for `getPedDirectRelatives()`, `cumulateSimKinships()`, and
    `getIdsWithOneParent()`.

# nprcgenekeepr 1.0.8 (20250723)

- Minor changes
  - Added returned value descriptions for all functions within R
    directory where formerly missing.
  - Changed unit test for `get_elapsed_time_str()` to use a mocked
    version of `proc.time()`

# nprcgenekeepr 1.0.7 (20250506)

- Minor changes
  - Added returned value descriptions for all functions where formerly
    missing.
  - Removed extraneous spaces from DESCRIPTION file.
  - Exposed all examples in roxygen2 comments by removing and and . The
    example with `runGeneKeepR()` is protected with
    `if (interactive()) {}`.

# nprcgenekeepr 1.0.6 (20241215)

- Minor changes
  - Update version in preparation for CRAN submission
  - Added article demonstrating Simulated Kinships with Partial
    Parentage
  - Added use of CICD pipeline as GitHub Actions
    - lintr pipeline
    - R CMD check pipeline with multiple R environments and versions
    - pkgdown pipeline
  - Added several unit tests
  - Cleaned up code based on lintr feedback
  - Added example deidentified pedigree data
    2022-05-02_Deidentified_Pedigree.xlsx,
    2022-05-02_Deidentified_Pedigree_focal_animals.csv,
    deidentified_jmac_ped.csv (text, except for dates, are in double
    quotes), deidentified_jmac_ped_edited.csv (edited to remove double
    quotes).
  - Made `getVersion()` more robust.
  - Abstracted out removal of auto generated Ids in preparation of
    allowing the user to define how auto generated Ids will be formed.
  - Added some quality assurance badges to README.
  - Added CRAN status badge to README.
  - Stopped using travis-ci and started using GitHub Actions with
    Rhub.yaml file for checking on Rhub.

# nprcgenekeepr 1.0.5.9004 (20221213)

- Minor changes
  - Changed method used to test class of object to use inherits().
  - Corrected `getPedDirectRelative()` so that all direct relatives are
    found. Supplemented unit tests for more direct relative types.
  - Added unit tests for `trimPedigree()`.
  - Changed call `as.character(date_object)` to `format(date_object)` in
    getDatedFileName.R to prepare for newer code in development version
    of
    18. 
  - Technical edits of R code based on `lintr::lint_dir("R")`

# nprcgenekeepr 1.0.5.9003 (20220625)

- Minor changes
  - Removed dependency on gdata.
  - Removed `getMinParentAge()` as it was never used.
  - Starting to replace `rbind()` with `rbindlist()` from `data.table`
    were possible.

# nprcgenekeepr 1.0.5.9002 (20220425)

- Minor changes
  - Added use of data.table in an effort to reduce memory use and CPU
    use for estimation of kinship values.
  - Functions were refactored and the ability to handle larger
    simulations resulted.

# nprcgenekeepr 1.0.5.9001 (20210830)

- Major changes
  - Added ability to use simulation to estimate the kinship values of
    animals with incomplete parental information that are known to have
    been born within the colony. These animals may have 0 or 1 known
    parents but have a value in the pedigree file or database for the
    *fromcenter* or *fromCenter* field of "Y", "YES", "T", or "TRUE".
- Minor changes
  - Increase unit test coverage primarily to include more rare events
    and events that should not happen and are trapped and result in
    errors.
  - Changed to travis-ci.com

# nprcgenekeepr 1.0.5 (20210328)

- Major changes -- none
- Minor changes
  - CRAN submission primarily in response to a change in `shiny 1.6`
    that removed an internal `shiny` function (`shiny:::%OR%`) and
    replaced it with `rlang::%||%`
  - Stale URL in historical documentation that were causing notes to be
    generated in automated tests have been removed.
  - A URL referring to Terry Therneau's page was updated from "http" to
    "https".
  - I have incremented the version from 1.0.4 (github.com only version)
    to 1.0.5, updated NEWS to reflect the changes, and updated all
    documentation to reflect the version change.

# nprcgenekeepr 1.0.4.9003 (20210318)

- Major changes -- none
- Minor changes
  - Testing .travis.yml code change to get textshaping to build on all
    systems..
  - Cleaned up .travis.yml in response to syntax checking on travis.org.
  - Added `markdown` to suggest due to new changes in `knitr`.

# nprcgenekeepr 1.0.4 (20210318)

- Major changes -- none
- Minor changes
  - Added suppression of warnings from DT at beginning of server.R since
    it is unlikely for anyone to call affected functions in the
    controlled environment.
  - Changed call to shiny:::`%OR%` to rlang::`%||%` in server.R since
    the update to 1.6 of shiny broke the code. Thanks to Dan Metzger of
    Wisconsin National Primate Research Center.

# nprcgenekeepr 1.0.3 (20200526)

- Major changes -- none
- Minor changes
  - CRAN re-submission: responded to the two requests provided by
    reviewer
    - I have removed the capitalization from "Genetic Tools for Colony
      Management" and "Genetic Value Analysis Reports" within
      DESCRIPTION.
    - I have removed the conditional installation of DT from the ui.R
      file.
  - I have incremented the version from 1.0.2 to 1.0.3, updated NEWS to
    reflect the changes, and updated all documentation to reflect the
    version change.

# nprcgenekeepr 1.0.2 (20200517)

- Major changes -- none
- Minor changes
  - CRAN re-submission: responded to all requests provided by reviewer
    - I have not changed the capitalization of `Shiny` in the
      description section of the DESCRIPTION file as it is the name of
      the type of application and is not being used as the name of the
      package. The use of the capitalization is consistent with the
      capitalization used within the documentation for the `shiny`
      package (?shiny, See the Details section, first sentence where it
      is used as the type of tutorial.) and all documentation and
      tutorials provided by the author and RStudio where it is
      capitalized everywhere except when referring to the package.
    - I have continued to use dontrun for the following examples:
      - `runGeneKeepr()`, which starts the Shiny application
      - `getFocalAnimalPed()`, which is dependent on a valid LabKey
        instance, a proper configuration file, and a .netrc or \_netrc
        authentication file.
    - I have exchanged dontrun for donttest for the following examples:
      - `create_wkbk()`
      - `createPedTree()`
      - `findLoops()`
      - `countLoops()`
      - All 11 examples in data.R
      - `makeExamplePedigreeFile()`

# nprcgenekeepr 1.0.1 (20200510)

- Major changes -- none
- Minor changes
  - CRAN re-submission: responded to all requests provided by reviewer
    - Reduced the time required for unit test from over 12 minutes to
      21.6 seconds by skipping those test dependent on stochastic
      creation of simulated pedigrees and breeding groups when not
      running on my system.
    - Reduced the time to run examples and create vignettes by reducing
      the number of stochastic modeling iterations by orders of
      magnitude without reducing the examples provided for user-facing
      functions.
    - Checking (--as-cran --run-donttest) Duration: 2m 21.8s on my
      system.
    - The files with the Rd-tag of `\arguments` missing do not take
      arguments.
    - Corrected private referencing (`:::`) for exported functions.
    - Exported all functions used in examples to remove private
      referencing (`:::`).
    - Removed all single quotes on names, abbreviations, initialisms,
      and, acronyms.
    - The phrase Electronic Health Records (EHR) is the name of a module
      within LabKey, which this software can use as a source of pedigree
      information so the capitalization is appropriate.
    - Two exported functions used by server.R to call `tabpanel()` do
      not have examples.

# nprcgenekeepr 1.0 (20200415)

- Major changes -- none
- Minor changes
  - CRAN submission

# nprcgenekeepr 0.5.43 (20200414)

- Major changes -- none
- Minor changes
  - Final preparation for CRAN submission

# nprcgenekeepr 0.5.42.9012 (20200412)

- Major changes -- none
- Minor changes
  - Updated unit test for dataframe2string to account for change in age
    of a sire from 8.67 to 8.66 years.
  - Renamed tutorials.

# nprcgenekeepr 0.5.42.9011 (20200409)

- Major changes -- none
- Minor changes
  - Build failed on Travis-ci due to unit test failure but the test has
    never failed and does not fail on other builds. Removed set_seed()
    to see if that helps.
  - Fixed GitHub issue 3
  - Added additional explanatory text from Matt Schultz edits for the
    Colony Manager version of the Shiny tutorial.

# nprcgenekeepr 0.5.42.9010 (20200405)

- Major changes -- none
- Minor changes
  - Added code to address issue 1 (GitHub). See comment 1 for details,
    but more should be done.
  - Refreshed Shiny_app_use.Rmd to reflect changes since November 2019.

# nprcgenekeepr 0.5.42.9009 (20200402)

- Major changes -- none
- Minor changes
  - Wrapped example for `makeExamplePedigreeFile` with `\dontrun{}`
    because R 4.0.0 alpha was leaving the side effect of the dataframe
    stored in a CSV file named as the text of the next line.

# nprcgenekeepr 0.5.42.9008 (20200321)

- Major changes -- none
- Minor changes
  - Changed dependency to R \>= 3.6 since caTools is not available for R
    \< 3.6.

# nprcgenekeepr 0.5.42.9007 (20200319)

- Major changes -- none
- Minor changes
  - Changed warnings unit test for getLkDirectAncestors to work with
    Windows.

# nprcgenekeepr 0.5.42.9006 (20200319)

- Major changes -- none
- Minor changes
  - Completed examples in function documentation
  - Corrected spelling of several word throughout found with
    `spelling::spell_check_package(".")`.

# nprcgenekeepr 0.5.42.9005 (20200201)

- Major changes -- none
- Minor changes
  - Added examples to function documentation
  - Added ColonyManagerTutorial.Rmd initial draft, which is copy of
    shiny_app_use.Rmd. It is to be converted for use by colony managers.

# nprcgenekeepr 0.5.42.9004 (20200201)

- Major changes -- none
- Minor changes
  - Added examples to function documentation
  - Added obfuscated rhesus pedigree and rhesus haplotypes to use in
    examples

# nprcgenekeepr 0.5.42.9003

- Major changes -- none
- Minor changes
  - Renamed local and remote repositories from nprcmanager to
    nprcgenekeepr.

# nprcgenekeepr 0.5.42.9002

- Major changes
  - Changed name of package to nprcgenekeepr. This required changing of
    many of the supporting files and functions. Having good unit test
    coverage of the functions (739 test with \> 90 percent coverage)
    made this possible.
  - This is the last version under the nprcmanager repository name.
  - Conversion worked
    - Running the build check had OK: 739; Failed: 0; Warnings: 0;
      Skipped: 0
- Minor changes -- none

# nprcmanager 0.5.42.9001

- Major changes -- none
- Minor changes
  - Adding small executable examples in `roxygen2` comments that will go
    into the Rd-files. Since I have tests, I am wrapping the examples in
    .
  - Added code prior to changing `par()` in *getPyramidPlot.R* to reset
    `par()` with  
    `opar <- par(no.readonly =TRUE)`  
    `on.exit(par(opar))`  
  - Removed the word "Implements" from the title.
  - Reworded the first sentence of the Description element and therein
    removing "implements" and "nprcmanager" as unnecessary words.
  - Added single quotes around all package, software, and API names
    within the Description element of the DESCRIPTION file.

# nprcmanager 0.5.42.9000

- Major changes
  - Added ability to export genetic summary statistic plots
- Minor changes -- none

# nprcmanager 0.5.42 (20191208)

- CRAN submission
- Move output of suspicious parent list from the user's home directory
  to the result of `tempdir()`.

# nprcmanager 0.5.41 (20191130)

- CRAN submission.

# nprcmanager 0.5.40.9002 (20191119)

- Tried to get vignette for shiny application to find images on all
  building platforms by adding "./" to relative path.

# nprcmanager 0.5.40.9001 (20191115)

- Added unit test for **create_wkbk** from
  github.com/rmsharp/rmsutilityr
- Fixed bug in Genetic Value Analysis tab were failure to remove all
  white space in Filter View Id window did not clear filter.
- Changed minimum parent age default from 4 to 2 years.
- Added ability to download founders in a *maleFounders.csv* file and a
  *femaleFounders.csv* file.
- Added **createExampleFiles** and **saveDataframesAsFiles** to allow
  the user to generate all of the example pedigrees and other files used
  in testing and in tutorials.
- Removed **Development_Plans.Rmd** from build because it has has been
  replaced by adding issues on our GitHub issue tracker.

# nprcmanager 0.5.40.9000 (20191115)

- Corrected bug in **addIdRecords** to handle *NA* characters; amended
  its unit tests to check for correct behavior
- Changed name of **sexRatioWithAddions** to
  **getSexRatioWithAdditions**

# nprcmanager 0.5.39 (20191115)

- Moved vignettes to expose them in GitHub Pages.
- Removed more unneeded files from package.

# nprcmanager 0.5.38 (20191113)

- Changed **getBreederPed** function to **getFocalAnimalPed** and
  animals read in by that function from **breeders** to **focalAnimals**

# nprcmanager 0.5.37 (20191108)

- Working on updating documentation

# nprcmanager 0.5.36 (20191106)

- Added colorIndex to list returned by getIndianOriginStatus(),
  getProductionStatus(), and getProportionLow(). Updated related unit
  tests
- Changed getSiteInfo() to reflect ONPRC's query structure
- Changed .Rbuildignore to leave out .png image files needed for Shiny
  tutorial.

# nprcmanager 0.5.35 (20191013)

- Corrected calculateSexRatio and updated unit test
- Modified getProductionStatus to match new definition and added unit
  tests

# nprcmanager 0.5.34 (20191006)

- Added code to filter out animals no longer at institution and without
  birth date.

# nprcmanager 0.5.33 (20191006)

- Broke up LICENSE contents into LICENSE and LICENSE.md for CRAN
  compliance

# nprcmanager 0.5.32 (20191004)

- Corrected ancestry to sexCodes in test_convertSexCodes()

# nprcmanager 0.5.31 (20191003)

- Added more tutorial notes
- Removed undefined elements in DESCRIPTION file including Displaymode:
  Showcase, which is recommended in a Shiny example by RStudio. This was
  removed based on RHUB feedback.
- Added more code for genetic diversity dashboard.

# nprcmanager 0.5.30 (20190829)

- Began adding code for the genetic diversity dashboard. This includes
  the functions **getIndianOriginStatus** and **getProportionLow**, and
  a rudimentary **makeGeneticDiversityDashboard** function.
- Added another obfuscation function **mapIdsToObfuscated** to further
  facilitate creation of obfuscated data. This was specifically used to
  obfuscate haplotype data Ids.

# nprcmanager 0.5.29 (20190810)

- Copied rmsutilityr functions into nprcmanager to make Publication on
  the RStudio Shiny application hosting site possible

# nprcmanager 0.5.28 (20190714)

- Added to interactive tutorial
- Enhance algorithm for creating the desired sex ratio in groups.

# nprcmanager 0.5.27 (20190713)

- Added to interactive tutorial
- Minor corrections of function documentation
- Moved *updateProgress* parameter to end of list for
  **groupAddAssign()**.

# nprcmanager 0.5.26 (20190707)

- Updated and corrected *\_software_development.Rmd*
- Corrected summary statistics descriptions
- Added expectConfigFile argument to **getSiteInfo()** and associated
  unit test to allow user to avoid a warning when configuration file is
  not expected to be present.

# nprcmanager 0.5.25 (20190701)

- Removed animals with exit dates from pyramid plots
- Added ability to retain novel column names
- Increased the number of column names understood for display in
  pedigree browser.

# nprcmanager 0.5.24 (20190630)

- Renamed resetPopulation to setPopulation
- Added sections to interactive_use_tutorial

# nprcmanager 0.5.23 (20190624)

- Added weak unit test for getGenotypes function

# nprcmanager 0.5.22 (20190624)

- Corrected and augmented unit tests for print_summary_nprcmanagGV and
  summary.nprcmanagGV

# nprcmanager 0.5.21 (20190624)

- Added unit tests for print_summary_nprcmanagGV and summary.nprcmanagGV

# nprcmanager 0.5.20 (20190622)

- Added unit test for getPedigree.

# nprcmanager 0.5.19 (20190622)

- Replaced examplePedigree which I an failed to obfuscate with an
  obfuscated version
- Added the ability to retrieve the map of original IDs to the new
  aliases to obfuscatePed.

# nprcmanager 0.5.18 (20190622)

- Replaced actual unpublished pedigree objects with obfuscated pedigree
  objects so they can be shared
- Updated unit tests that were dependent on replaced pedigree objects

# nprcmanager 0.5.17 (20190619)

- Removed old pedigree files in preparation for new custom built
  demonstration pedigrees
- Removed old, no longer used logos

# nprcmanager 0.5.16 (20190615)

- Added functions used to obfuscate pedigrees. This changes the IDs, all
  dates and age calculations while maintaining internal relational
  consistency (parent IDs correspond) and date, though different are
  similar.

# nprcmanager 0.5.15 (20190602)

- Added ability to create an example pedigree file using the
  **examplePedigree** data structure.
- Added **summary.nprcmanagGV** and **print.summary.nprcmanagGV**
  functions
- Added description of age-sex pyramid plot to the *summary of major
  functions*.

# nprcmanager 0.5.14 (20190518)

- Added ability to use Excel files as input
  - Added getGenotypes, getPedigree, getBreederPed,
    readExcelPOSIXToCharacter,
  - Added selection of Excel or Text file to uitpInput.R and modified
    other aspects to separate out the delimiter selection logic.
  - Default file type is Excel.
  - If a user selects and Excel file and an Excel file is detected, all
    file type and delimiter selections are ignored and the Excel file is
    used and no error or warning is given.
- Improved checkRequiredCols, toCharacter and getDatedFileName functions
- Exported set_seed. This will be moved into rmsutilityr
- Removed erroneous toCharacter documentation
- Added set_seed
  - Tried unsuccessfully to use the RNGkind function and the sample.kind
    argument to set.seed, but found neither existed prior to R 3.6.
  - Created a R version sensitive version of set_seed that duplicates
    the pre-R version 3.6 set.seed function. This is only useful for
    creating data structures for testing purposes and should not be used
    to set seeds for large simulations

# nprcmanager 0.5.13 (20190508)

- Updated unit tests that were using set.seed to use a R version
  sensitive set.seed wrapper.

# nprcmanager 0.5.12 (20190507)

- Updated nprcmanager.R to add **Pedigree Testing** and **Plotting**
  function lists.

# nprcmanager 0.5.11 (20190430)

- Changed wording and format above Suspicious Parent table in ErrorTab
- Removed row label from Suspicious Parent table
- Updated meeting notes

# nprcmanager 0.5.10 (20190428)

- Corrected roxygen2 comment "@export" in getAnimalsWithHighKinship().
- Added unit test for fillGroupMembersWithSexRatio()

# nprcmanager 0.5.09 (20190428)

- Corrected bug where parents with suspicious dates were not being
  reported.
- Improved display of parents with suspicious dates by outputing HTML
  table to the ErrorTab.

# nprcmanager 0.5.08 (20190418)

- Minor rewording of option label on breeding group formation tab

# nprcmanager 0.5.07 (20190408)

- Rearranged and reformatted breeding group formation tab

# nprcmanager 0.5.06 (20190407)

- Changed spelling of gu.iter and gu.thresh to guIter and guThresh

# nprcmanager 0.5.05 (20190406)

- Fixed all but one bug associated with having multiple dynamically
  generated seed animal groups.
- Added global definition of MAXGROUPS, which is current set as 10 and
  allows up to six seed animal groups.
- Corrected test_fillBins, which was erroneously using a current date
  instead of a fixed date for calculating age.

# nprcmanager 0.5.04 (20190225)

- Adding ability to have up to six seed animal groups.
- Added conditional appearance of Make Groups action button that is
  dependent on the user having select on of the optional group formation
  workflows.

# nprcmanager 0.5.03 (20190215)

- Adding new version of breeding group formation UI and related server
  code.

# nprcmanager 0.5.02 (20190103)

- Added ability to specify sex ratio in increments of 0.5 (Female/Male)
  from 0.5 to 10 in increments of 0.5.

# nprcmanager 0.5.01 (20181230)

- Correction of some bugs in harem creation and provided additional unit
  tests for harem creation to prevent regression.

# nprcmanager 0.5.00 (20181228)

- First draft with harem group creation working.
  - Fails if more than one potential sire (male and at least of minimum
    age) is in the current group.
  - Fails if there are insufficient males to have one per breeding group
    being formed.
  - Requires the user to provide males in the candidate set that are
    appropriate for breeding as the current code does not check to
    ensure the animals are still alive. This could easily be added.
  - Males are selected for each group randomly at each iteration just as
    are all other members. The only difference between animal selection
    for harems is that sex is part of the selection process.
  - This required the creation of a few functions and modification of
    others. Unit tests were updated to reflect changes, but not
    additions. New unit tests are needed.
  - The format of the breeding group creation page must be improved.
  - The changes made and the new unit tests will serve to simplify
    adding the sex ratio criterion to breeding group formation.

# nprcmanager 0.4.23 (20181226)

- Added code to detect LabKey connection failure and report it on an
  Error tab

# nprcmanager 0.4.22 (20181224)

- Minor text changes to Input tab. Refactored groupAddAssign function to
  have a function create the return list.

# nprcmanager 0.4.20 (20181222)

- Refactor of **groupAddAssign** function by extracting much of the
  function into separate functions. One such function,
  **fillGroupMembers** isolates the group formation code to allow adding
  the ability to satisfy sex ratio requirements and harem creation.

# nprcmanager 0.4.19 (20181217)

- All minor interface changes
  - Substituted hovertext for description of minimum parental age
  - Added meeting notes for 20181210 meeting
  - Changed label on button controlling reading of pedigree information
  - Updated logo
- Added code of conduct file.
- Corrected license text

# nprcmanager 0.4.18 (20181210)

- Added unit test for removing animals added to pedigree because they
  are unknown parents

# nprcmanager 0.4.17 (20181208)

- Changed error reporting so as not to report as an error the wrong sex
  when animals are added into the pedigree and appear as both a sire and
  dam without an ego record. The error report now indicates these are
  both a sire and a dam. Done 20181208
- Made a combined logo for Oregon and SNPRC. Have ONPRC on top using
  blue and green. Done 20181208
- Additional unit tests to cover all of the new functions created to
  handle the PEDSYS and military formatted dates (YYYYMMDD) have been
  made. Done 20181112
- Corrected breeding groups formation, which was including unknown
  animals that had been added as placeholders for unknown parents. Done
  20181119
- Hardened LabKey code by trapping a bad base URL in the configuration
  file with a tryCatch function and send a message to the log file. This
  needs to be tested with a working LabKey system.
