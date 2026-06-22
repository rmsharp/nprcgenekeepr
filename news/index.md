# Changelog

## nprcgenekeepr (development version)

- Changes
  - [`getLkDirectRelatives()`](https://github.com/rmsharp/nprcgenekeepr/reference/getLkDirectRelatives.md)
    now returns the full connected pedigree component for the focal
    animals (ancestors, descendants, and collaterals such as siblings,
    mates, and their lineages) by delegating its pedigree walk to
    [`getPedDirectRelatives()`](https://github.com/rmsharp/nprcgenekeepr/reference/getPedDirectRelatives.md).
    Previously it returned only the strict ancestor/descendant lineage
    and omitted collateral relatives. Pedigrees built from the
    LabKey/EHR path (via
    [`getFocalAnimalPed()`](https://github.com/rmsharp/nprcgenekeepr/reference/getFocalAnimalPed.md))
    are now more complete and consistent with the in-memory
    [`getPedDirectRelatives()`](https://github.com/rmsharp/nprcgenekeepr/reference/getPedDirectRelatives.md).
- New features
  - Added the exported
    [`setLabKeyDefaults()`](https://github.com/rmsharp/nprcgenekeepr/reference/setLabKeyDefaults.md),
    which configures `Rlabkey` authentication for the session: it
    prefers an API key (from the `NPRCGENEKEEPR_LABKEY_APIKEY`
    environment variable, then an `apiKey` configuration-file token),
    falls back to a `.netrc`/`_netrc` file, and otherwise stops with a
    clear `No LabKey credential found` error.
    [`getDemographics()`](https://github.com/rmsharp/nprcgenekeepr/reference/getDemographics.md)
    now configures authentication automatically before querying, so a
    missing credential fails fast instead of producing an opaque error
    later.
  - Added the exported
    [`getFileDirectRelatives()`](https://github.com/rmsharp/nprcgenekeepr/reference/getFileDirectRelatives.md),
    a file-sourced sibling of
    [`getLkDirectRelatives()`](https://github.com/rmsharp/nprcgenekeepr/reference/getLkDirectRelatives.md):
    it reads a pedigree file (CSV or Excel) via
    [`getPedigree()`](https://github.com/rmsharp/nprcgenekeepr/reference/getPedigree.md)
    and returns the full connected pedigree component (ancestors,
    descendants, and collaterals) for the focal animals, reusing the
    source-agnostic
    [`getPedDirectRelatives()`](https://github.com/rmsharp/nprcgenekeepr/reference/getPedDirectRelatives.md)
    walk. It is fully offline and deterministic, and (unlike the
    fail-soft LabKey source) errors on a missing or invalid file. This
    wires the `getPedigreeSource()` `"file"` provider to a first-class
    caller, giving file pedigrees the same direct-relatives entry point
    LabKey already has.
  - Added the exported
    [`getFocalAnimalPedFromFile()`](https://github.com/rmsharp/nprcgenekeepr/reference/getFocalAnimalPedFromFile.md),
    a file-sourced sibling of
    [`getFocalAnimalPed()`](https://github.com/rmsharp/nprcgenekeepr/reference/getFocalAnimalPed.md):
    it reads a list of focal animal Ids from one file and builds the
    full connected pedigree component for those focal animals from a
    separate pedigree file via
    [`getFileDirectRelatives()`](https://github.com/rmsharp/nprcgenekeepr/reference/getFileDirectRelatives.md),
    so the focal-animal workflow can run entirely offline with no
    LabKey/EHR connection. The Shiny input module (`modInput`) now
    offers an optional pedigree-file input on the focal animals path;
    when a pedigree file is supplied the pedigree is built from that
    file, otherwise the LabKey/EHR path is used as before. Being the
    application boundary, the function is fail-soft: rather than
    throwing, it returns a classed error whose message names WHY the
    read failed (an unreadable focal-id list file; a missing, not-found,
    unreadable, or wrong-column pedigree file; or no focal IDs found in
    the pedigree), and the app surfaces that message as the specific
    File Read Error detail instead of a generic one.
- Documentation
  - The example configuration file
    (`inst/extdata/example_nprcgenekeepr_config`) now documents that
    `lkPedColumns` is center-specific: SNPRC uses the flat `dam`/`sire`
    columns (direct columns) while ONPRC uses the `Id/parents/dam`
    lookup-traversal form (curated parentage).
- Internal changes
  - The LabKey pedigree fetch used by
    [`getLkDirectRelatives()`](https://github.com/rmsharp/nprcgenekeepr/reference/getLkDirectRelatives.md)
    is now obtained through an internal data-source adapter
    (`getPedigreeSource()`), isolating the LabKey pull behind a single
    seam and enabling offline, deterministic tests of the pedigree walk.
    No change to behavior.
  - The internal `getPedigreeSource()` adapter gained a `"file"` source
    that reads a pedigree file (CSV or Excel) via
    [`getPedigree()`](https://github.com/rmsharp/nprcgenekeepr/reference/getPedigree.md),
    alongside the existing `"labkey"` and `"dataframe"` sources. This
    makes LabKey one pluggable provider among several and extends the
    offline, deterministic test seam.
  - The offline focal-animal path no longer prints a benign
    `cannot open file ...` warning when the focal-id list file is
    missing or unreadable.
    [`getFocalAnimalPedFromFile()`](https://github.com/rmsharp/nprcgenekeepr/reference/getFocalAnimalPedFromFile.md)
    already reported the failure as a classed error; the underlying
    [`read.csv()`](https://rdrr.io/r/utils/read.table.html) warning that
    leaked to the console ahead of the caught error is now muffled at
    the read site, so the fail-soft path is silent. The returned value
    and the reported error are unchanged.

## nprcgenekeepr 2.0.0 (20260618)

- Major changes
  - **(breaking)**
    [`qcStudbook()`](https://github.com/rmsharp/nprcgenekeepr/reference/qcStudbook.md)
    and
    [`geneDrop()`](https://github.com/rmsharp/nprcgenekeepr/reference/geneDrop.md)
    now reject `id`, `sire`, or `dam` values containing a period
    (offenders returned in `errorLst$invalidIdChars`); auto-generated
    IDs remain period-free.
  - **(breaking)**
    [`runModularApp()`](https://github.com/rmsharp/nprcgenekeepr/reference/runModularApp.md)
    is the new Shiny entry point and the monolithic application was
    retired;
    [`runGeneKeepR()`](https://github.com/rmsharp/nprcgenekeepr/reference/runGeneKeepR.md)
    is now a soft-deprecated alias (zero-argument calls still work), and
    the unused exports `getLogo()`, `shouldShowErrorTab()`,
    `modMinimalTestUI()`, and `modMinimalTestServer()` were removed.
    ([\#27](https://github.com/rmsharp/nprcgenekeepr/issues/27))
  - New **Potential Parents** tab listing candidate sires and dams for
    in-colony animals with at least one unknown parent, screened by
    estimated conception date (wiring in the exported
    [`getPotentialParents()`](https://github.com/rmsharp/nprcgenekeepr/reference/getPotentialParents.md));
    dam selection now uses a `maxGestationalPeriod`-driven exclusion
    window (was a fixed +/- 182.5-day window).
    ([\#48](https://github.com/rmsharp/nprcgenekeepr/issues/48),
    [\#31](https://github.com/rmsharp/nprcgenekeepr/issues/31))
  - New **ORIP Reporting** tab with ONPRC colony summaries for the NIH
    Office of Research Infrastructure Programs (site information, a
    colony table with founder counts, genetic-diversity metrics, and CSV
    exports); shown only at ONPRC.
    ([\#47](https://github.com/rmsharp/nprcgenekeepr/issues/47),
    [\#49](https://github.com/rmsharp/nprcgenekeepr/issues/49))
  - The Pedigree Browser “trim based on focal animals” option now
    includes descendants as well as ancestors, via the new exported
    [`getDescendantPedigree()`](https://github.com/rmsharp/nprcgenekeepr/reference/getDescendantPedigree.md).
    ([\#35](https://github.com/rmsharp/nprcgenekeepr/issues/35))
  - Added the exported founder helpers
    [`isFounder()`](https://github.com/rmsharp/nprcgenekeepr/reference/isFounder.md)
    and
    [`getFounders()`](https://github.com/rmsharp/nprcgenekeepr/reference/getFounders.md).
  - Added the exported
    [`getAutoIdFormat()`](https://github.com/rmsharp/nprcgenekeepr/reference/getAutoIdFormat.md)
    and
    [`setAutoIdFormat()`](https://github.com/rmsharp/nprcgenekeepr/reference/setAutoIdFormat.md),
    making the auto-generated placeholder-ID format configurable
    (default `"U%04d"`).
    ([\#44](https://github.com/rmsharp/nprcgenekeepr/issues/44),
    [\#38](https://github.com/rmsharp/nprcgenekeepr/issues/38))
  - Genetic Value Analysis tab parity: the genome-uniqueness threshold
    is now a user control (default 4), a subset filter and “Export
    Subset” download were added, the default gene-drop iterations
    changed to 1000, and an inert “Minimum breeding age” slider was
    removed.
  - Improved visualizations: educational box-plot popovers
    ([`getBoxWhiskerDescription()`](https://github.com/rmsharp/nprcgenekeepr/reference/getBoxWhiskerDescription.md)),
    plot export to PNG, PDF, and SVG
    ([`savePlotToFile()`](https://github.com/rmsharp/nprcgenekeepr/reference/savePlotToFile.md)),
    and an enhanced age-sex pyramid
    ([`getPyramidPlot()`](https://github.com/rmsharp/nprcgenekeepr/reference/getPyramidPlot.md)).
- Minor changes
  - Fixed a startup crash that occurred when a documented-format site
    configuration file was present, via the new tolerant
    [`loadSiteConfig()`](https://github.com/rmsharp/nprcgenekeepr/reference/loadSiteConfig.md).
    ([\#50](https://github.com/rmsharp/nprcgenekeepr/issues/50))
  - The **About** panel now shows the installed package version
    dynamically (it previously displayed a hard-coded “Version 1.0.8”).
  - [`geneDrop()`](https://github.com/rmsharp/nprcgenekeepr/reference/geneDrop.md)
    now reports duplicate animal IDs with a clear error instead of the
    base-R `duplicate 'row.names' are not allowed` message.
  - Reading a file whose final line lacks a trailing newline no longer
    emits the spurious “incomplete final line” warning.
    ([\#4](https://github.com/rmsharp/nprcgenekeepr/issues/4))
  - [`addGenotype()`](https://github.com/rmsharp/nprcgenekeepr/reference/addGenotype.md)
    now coerces its allele columns to character, so the integer allele
    encoding is consistent whether they are supplied as character or
    factor.
  - Re-exported the bundled `rhesusPedigree` and `rhesusGenotypes` data
    sets with canonical column types (character `id`, `sire`, and `dam`
    and `Date` `birth` and `exit` in `rhesusPedigree`; all-character
    columns in `rhesusGenotypes`), preserving every value.
  - [`summarizeKinshipValues()`](https://github.com/rmsharp/nprcgenekeepr/reference/summarizeKinshipValues.md)
    now reports the `secondQuartile` column as the lower hinge
    (`fivenum()[2]`) instead of duplicating `min`.
  - New dependencies: `bslib`, `DT`, and `ggplot2` (Imports);
    `shinytest2` (Suggests).
  - Replaced the magrittr pipe (`%>%`) with the base R native pipe
    (`|>`) in vignettes and examples; `magrittr` is no longer used.
  - Documentation: extensive help-page and dataset-documentation
    corrections, including the genetic-value `@return` and parameter
    descriptions, dataset titles and descriptions, and the `@examples`
    for
    [`getPedDirectRelatives()`](https://github.com/rmsharp/nprcgenekeepr/reference/getPedDirectRelatives.md),
    [`cumulateSimKinships()`](https://github.com/rmsharp/nprcgenekeepr/reference/cumulateSimKinships.md),
    and
    [`getIdsWithOneParent()`](https://github.com/rmsharp/nprcgenekeepr/reference/getIdsWithOneParent.md).

## nprcgenekeepr 1.0.8 (20250723)

CRAN release: 2025-07-26

- Minor changes
  - Added returned value descriptions for all functions within R
    directory where formerly missing.
  - Changed unit test for
    [`get_elapsed_time_str()`](https://github.com/rmsharp/nprcgenekeepr/reference/get_elapsed_time_str.md)
    to use a mocked version of
    [`proc.time()`](https://rdrr.io/r/base/proc.time.html)

## nprcgenekeepr 1.0.7 (20250506)

CRAN release: 2025-04-24

- Minor changes
  - Added returned value descriptions for all functions where formerly
    missing.
  - Removed extraneous spaces from DESCRIPTION file.
  - Exposed all examples in roxygen2 comments by removing and and . The
    example with
    [`runGeneKeepR()`](https://github.com/rmsharp/nprcgenekeepr/reference/runGeneKeepR.md)
    is protected with `if (interactive()) {}`.

## nprcgenekeepr 1.0.6 (20241215)

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
  - Made
    [`getVersion()`](https://github.com/rmsharp/nprcgenekeepr/reference/getVersion.md)
    more robust.
  - Abstracted out removal of auto generated Ids in preparation of
    allowing the user to define how auto generated Ids will be formed.
  - Added some quality assurance badges to README.
  - Added CRAN status badge to README.
  - Stopped using travis-ci and started using GitHub Actions with
    Rhub.yaml file for checking on Rhub.

## nprcgenekeepr 1.0.5.9004 (20221213)

- Minor changes
  - Changed method used to test class of object to use inherits().
  - Corrected `getPedDirectRelative()` so that all direct relatives are
    found. Supplemented unit tests for more direct relative types.
  - Added unit tests for
    [`trimPedigree()`](https://github.com/rmsharp/nprcgenekeepr/reference/trimPedigree.md).
  - Changed call `as.character(date_object)` to `format(date_object)` in
    getDatedFileName.R to prepare for newer code in development version
    of
    18. 
  - Technical edits of R code based on `lintr::lint_dir("R")`

## nprcgenekeepr 1.0.5.9003 (20220625)

- Minor changes
  - Removed dependency on gdata.
  - Removed `getMinParentAge()` as it was never used.
  - Starting to replace [`rbind()`](https://rdrr.io/r/base/cbind.html)
    with `rbindlist()` from `data.table` were possible.

## nprcgenekeepr 1.0.5.9002 (20220425)

- Minor changes
  - Added use of data.table in an effort to reduce memory use and CPU
    use for estimation of kinship values.
  - Functions were refactored and the ability to handle larger
    simulations resulted.

## nprcgenekeepr 1.0.5.9001 (20210830)

- Major changes
  - Added ability to use simulation to estimate the kinship values of
    animals with incomplete parental information that are known to have
    been born within the colony. These animals may have 0 or 1 known
    parents but have a value in the pedigree file or database for the
    *fromcenter* or *fromCenter* field of “Y”, “YES”, “T”, or “TRUE”.
- Minor changes
  - Increase unit test coverage primarily to include more rare events
    and events that should not happen and are trapped and result in
    errors.
  - Changed to travis-ci.com

## nprcgenekeepr 1.0.5 (20210328)

CRAN release: 2021-03-31

- Major changes – none
- Minor changes
  - CRAN submission primarily in response to a change in `shiny 1.6`
    that removed an internal `shiny` function (`shiny:::%OR%`) and
    replaced it with `rlang::%||%`
  - Stale URL in historical documentation that were causing notes to be
    generated in automated tests have been removed.
  - A URL referring to Terry Therneau’s page was updated from “http” to
    “https”.
  - I have incremented the version from 1.0.4 (github.com only version)
    to 1.0.5, updated NEWS to reflect the changes, and updated all
    documentation to reflect the version change.

## nprcgenekeepr 1.0.4.9003 (20210318)

- Major changes – none
- Minor changes
  - Testing .travis.yml code change to get textshaping to build on all
    systems..
  - Cleaned up .travis.yml in response to syntax checking on travis.org.
  - Added `markdown` to suggest due to new changes in `knitr`.

## nprcgenekeepr 1.0.4 (20210318)

- Major changes – none
- Minor changes
  - Added suppression of warnings from DT at beginning of server.R since
    it is unlikely for anyone to call affected functions in the
    controlled environment.
  - Changed call to shiny:::`%OR%` to rlang::`%||%` in server.R since
    the update to 1.6 of shiny broke the code. Thanks to Dan Metzger of
    Wisconsin National Primate Research Center.

## nprcgenekeepr 1.0.3 (20200526)

CRAN release: 2020-06-02

- Major changes – none
- Minor changes
  - CRAN re-submission: responded to the two requests provided by
    reviewer
    - I have removed the capitalization from “Genetic Tools for Colony
      Management” and “Genetic Value Analysis Reports” within
      DESCRIPTION.
    - I have removed the conditional installation of DT from the ui.R
      file.
  - I have incremented the version from 1.0.2 to 1.0.3, updated NEWS to
    reflect the changes, and updated all documentation to reflect the
    version change.

## nprcgenekeepr 1.0.2 (20200517)

- Major changes – none
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
      - [`getFocalAnimalPed()`](https://github.com/rmsharp/nprcgenekeepr/reference/getFocalAnimalPed.md),
        which is dependent on a valid LabKey instance, a proper
        configuration file, and a .netrc or \_netrc authentication file.
    - I have exchanged dontrun for donttest for the following examples:
      - [`create_wkbk()`](https://github.com/rmsharp/nprcgenekeepr/reference/create_wkbk.md)
      - [`createPedTree()`](https://github.com/rmsharp/nprcgenekeepr/reference/createPedTree.md)
      - [`findLoops()`](https://github.com/rmsharp/nprcgenekeepr/reference/findLoops.md)
      - [`countLoops()`](https://github.com/rmsharp/nprcgenekeepr/reference/countLoops.md)
      - All 11 examples in data.R
      - [`makeExamplePedigreeFile()`](https://github.com/rmsharp/nprcgenekeepr/reference/makeExamplePedigreeFile.md)

## nprcgenekeepr 1.0.1 (20200510)

- Major changes – none
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
    - Checking (–as-cran –run-donttest) Duration: 2m 21.8s on my system.
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

## nprcgenekeepr 1.0 (20200415)

- Major changes – none
- Minor changes
  - CRAN submission

## nprcgenekeepr 0.5.43 (20200414)

- Major changes – none
- Minor changes
  - Final preparation for CRAN submission

## nprcgenekeepr 0.5.42.9012 (20200412)

- Major changes – none
- Minor changes
  - Updated unit test for dataframe2string to account for change in age
    of a sire from 8.67 to 8.66 years.
  - Renamed tutorials.

## nprcgenekeepr 0.5.42.9011 (20200409)

- Major changes – none
- Minor changes
  - Build failed on Travis-ci due to unit test failure but the test has
    never failed and does not fail on other builds. Removed set_seed()
    to see if that helps.
  - Fixed GitHub issue 3
  - Added additional explanatory text from Matt Schultz edits for the
    Colony Manager version of the Shiny tutorial.

## nprcgenekeepr 0.5.42.9010 (20200405)

- Major changes – none
- Minor changes
  - Added code to address issue 1 (GitHub). See comment 1 for details,
    but more should be done.
  - Refreshed Shiny_app_use.Rmd to reflect changes since November 2019.

## nprcgenekeepr 0.5.42.9009 (20200402)

- Major changes – none
- Minor changes
  - Wrapped example for `makeExamplePedigreeFile` with `\dontrun{}`
    because R 4.0.0 alpha was leaving the side effect of the dataframe
    stored in a CSV file named as the text of the next line.

## nprcgenekeepr 0.5.42.9008 (20200321)

- Major changes – none
- Minor changes
  - Changed dependency to R \>= 3.6 since caTools is not available for R
    \< 3.6.

## nprcgenekeepr 0.5.42.9007 (20200319)

- Major changes – none
- Minor changes
  - Changed warnings unit test for getLkDirectAncestors to work with
    Windows.

## nprcgenekeepr 0.5.42.9006 (20200319)

- Major changes – none
- Minor changes
  - Completed examples in function documentation
  - Corrected spelling of several word throughout found with
    `spelling::spell_check_package(".")`.

## nprcgenekeepr 0.5.42.9005 (20200201)

- Major changes – none
- Minor changes
  - Added examples to function documentation
  - Added ColonyManagerTutorial.Rmd initial draft, which is copy of
    shiny_app_use.Rmd. It is to be converted for use by colony managers.

## nprcgenekeepr 0.5.42.9004 (20200201)

- Major changes – none
- Minor changes
  - Added examples to function documentation
  - Added obfuscated rhesus pedigree and rhesus haplotypes to use in
    examples

## nprcgenekeepr 0.5.42.9003

- Major changes – none
- Minor changes
  - Renamed local and remote repositories from nprcmanager to
    nprcgenekeepr.

## nprcgenekeepr 0.5.42.9002

- Major changes
  - Changed name of package to nprcgenekeepr. This required changing of
    many of the supporting files and functions. Having good unit test
    coverage of the functions (739 test with \> 90 percent coverage)
    made this possible.
  - This is the last version under the nprcmanager repository name.
  - Conversion worked
    - Running the build check had OK: 739; Failed: 0; Warnings: 0;
      Skipped: 0
- Minor changes – none
