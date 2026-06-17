# Changelog

## nprcgenekeepr 1.1.0.9000 (20260126)

- Shiny application
  - New **Potential Parents** tab. For a loaded pedigree it identifies
    in-colony animals (`fromCenter`) that have at least one unknown
    parent and lists candidate sires and dams, screened by estimated
    conception date (birth minus the maximum gestational period). A
    numeric **Maximum Gestational Period (days)** input (default 210,
    the rhesus upper bound) is overridable per run; a **Find Potential
    Parents** button computes on the current pedigree; results display
    in a sortable table and download as CSV. The tab degrades gracefully
    when no pedigree is loaded, when the pedigree lacks the `fromCenter`
    colony-origin field, or when no animal has an unknown parent. This
    wires the exported
    [`getPotentialParents()`](https://github.com/rmsharp/nprcgenekeepr/reference/getPotentialParents.md)
    (including the gestation-derived dam-exclusion window) into the app.
    ([\#48](https://github.com/rmsharp/nprcgenekeepr/issues/48))
  - New **ORIP Reporting** tab. Provides formatted colony summaries for
    submission to the NIH Office of Research Infrastructure Programs
    (ORIP): site information, a colony summary table (totals by sex with
    founder counts via
    [`isFounder()`](https://github.com/rmsharp/nprcgenekeepr/reference/isFounder.md)),
    and genetic-diversity metrics (mean kinship and mean genome
    uniqueness) computed from the loaded pedigree and genetic-value
    results. Two **Export** buttons download the ORIP report and the
    demographics as CSV. This mounts the previously unwired
    `modORIPReporting` module pair into the application. The tab is
    **ONPRC-specific**: it is shown only when an actual site
    configuration file identifies the colony as ONPRC, and is hidden at
    other sites and when no configuration file is present.
    ([\#47](https://github.com/rmsharp/nprcgenekeepr/issues/47),
    [\#49](https://github.com/rmsharp/nprcgenekeepr/issues/49))
  - Fixed a startup crash. The application no longer fails to launch
    when a site configuration file written in the documented format
    (comment lines, blank lines, and multi-line / quoted /
    comma-separated values, as in `example_nprcgenekeepr_config`) is
    present in the user’s home directory. Configuration is now read
    through the same tolerant parser used by
    [`getSiteInfo()`](https://github.com/rmsharp/nprcgenekeepr/reference/getSiteInfo.md),
    via the new
    [`loadSiteConfig()`](https://github.com/rmsharp/nprcgenekeepr/reference/loadSiteConfig.md),
    which logs a warning and leaves the configuration unset (rather than
    aborting boot) if the file is missing or malformed. The previous
    loader used `read.table(sep = "=")`, which assumed a strict
    two-column table and stopped with “line N did not have 2 elements”.
    ([\#50](https://github.com/rmsharp/nprcgenekeepr/issues/50))
  - The **About** panel now shows the installed package version
    dynamically (via
    [`getVersion()`](https://github.com/rmsharp/nprcgenekeepr/reference/getVersion.md)),
    reading it from the package `DESCRIPTION` instead of a hard-coded
    string. The previous static “Version 1.0.8” had drifted out of date;
    deriving it at run time keeps it from going stale again.
- Data input / quality control
  - IDs may no longer contain a period (“.”).
    [`qcStudbook()`](https://github.com/rmsharp/nprcgenekeepr/reference/qcStudbook.md)
    and
    [`geneDrop()`](https://github.com/rmsharp/nprcgenekeepr/reference/geneDrop.md)
    now reject `id`/`sire`/`dam` values that contain a period; with
    `reportErrors = TRUE`, the offending values are reported in
    `errorLst$invalidIdChars`. Periods cause problems across software
    environments (R column-name/formula parsing, file extensions,
    namespaces, regular expressions). All automatically generated IDs
    remain period-free. (NEW-45)
  - [`geneDrop()`](https://github.com/rmsharp/nprcgenekeepr/reference/geneDrop.md)
    now rejects duplicate animal IDs with a clear error. Animal IDs
    uniquely identify animals (already enforced upstream by
    [`qcStudbook()`](https://github.com/rmsharp/nprcgenekeepr/reference/qcStudbook.md)
    via
    [`removeDuplicates()`](https://github.com/rmsharp/nprcgenekeepr/reference/removeDuplicates.md)
    and by
    [`kinship()`](https://github.com/rmsharp/nprcgenekeepr/reference/kinship.md));
    a duplicate id previously triggered the cryptic base-R error
    “duplicate ‘row.names’ are not allowed”. (NEW-46)
  - Reading an animal list or pedigree file whose final line has no
    trailing newline no longer emits the confusing “incomplete final
    line found by readTableHeader” warning. Every row, including the
    last, was always read correctly – the warning was harmless noise.
    [`getPedigree()`](https://github.com/rmsharp/nprcgenekeepr/reference/getPedigree.md),
    [`getGenotypes()`](https://github.com/rmsharp/nprcgenekeepr/reference/getGenotypes.md),
    [`getFocalAnimalPed()`](https://github.com/rmsharp/nprcgenekeepr/reference/getFocalAnimalPed.md),
    and the Shiny file upload now suppress only that one warning while
    letting every other read warning through.
    ([\#4](https://github.com/rmsharp/nprcgenekeepr/issues/4))
- Genetic value analysis
  - [`summarizeKinshipValues()`](https://github.com/rmsharp/nprcgenekeepr/reference/summarizeKinshipValues.md)
    now reports the `secondQuartile` column as the lower hinge
    (`fivenum()[2]`, approximately the first quartile) instead of
    silently duplicating `min` (`fivenum()[1]`). The `thirdQuartile`
    column (the upper hinge) was already correct. (NEW-16)
  - [`calcFE()`](https://github.com/rmsharp/nprcgenekeepr/reference/calcFE.md),
    [`calcFG()`](https://github.com/rmsharp/nprcgenekeepr/reference/calcFG.md),
    and
    [`calcFEFG()`](https://github.com/rmsharp/nprcgenekeepr/reference/calcFEFG.md)
    no longer duplicate the founder- contribution algorithm and the
    partial-parentage guard they shared verbatim; both now live in a
    single internal helper. Results, signatures, and error messages are
    unchanged. (NEW-13 / NEW-23)
- Pedigree curation
  - Added two exported helpers,
    [`isFounder()`](https://github.com/rmsharp/nprcgenekeepr/reference/isFounder.md)
    and
    [`getFounders()`](https://github.com/rmsharp/nprcgenekeepr/reference/getFounders.md),
    that identify pedigree founders (animals whose sire and dam are both
    unknown). `isFounder(ped)` returns the logical mask and
    `getFounders(ped)` returns the founder `id` values. The founder
    predicate had been written inline in a dozen places; it is now
    defined once and reused throughout the genetic-value and reporting
    functions. (PED-1 / NEW-17)
  - The Pedigree Browser’s “Trim pedigree based on focal animals” option
    now includes both the ancestors **and** the descendants of the focal
    animals (it previously included ancestors only). A new exported
    helper,
    [`getDescendantPedigree()`](https://github.com/rmsharp/nprcgenekeepr/reference/getDescendantPedigree.md),
    returns the transitive descendants of a set of probands – the
    downward mirror of
    [`getProbandPedigree()`](https://github.com/rmsharp/nprcgenekeepr/reference/getProbandPedigree.md).
    Trimming is strict-lineal: collateral relatives (siblings, cousins,
    mates) are not added. (NEW-47)
  - The format of the auto-generated placeholder IDs created for unknown
    parents (see
    [`addUIds()`](https://github.com/rmsharp/nprcgenekeepr/reference/addUIds.md))
    is now configurable from a single source of truth shared by ID
    generation and detection. Two new exported helpers,
    [`getAutoIdFormat()`](https://github.com/rmsharp/nprcgenekeepr/reference/getAutoIdFormat.md)
    and
    [`setAutoIdFormat()`](https://github.com/rmsharp/nprcgenekeepr/reference/setAutoIdFormat.md),
    read and set the `sprintf` format (default `"U%04d"`); with no
    configuration all existing behavior is unchanged. Detection is now
    centralized in one internal predicate used by
    [`removeAutoGenIds()`](https://github.com/rmsharp/nprcgenekeepr/reference/removeAutoGenIds.md),
    the Pedigree Browser display filter,
    [`reportGV()`](https://github.com/rmsharp/nprcgenekeepr/reference/reportGV.md)
    founder counts, and
    [`obfuscateId()`](https://github.com/rmsharp/nprcgenekeepr/reference/obfuscateId.md)
    – replacing eight scattered string literals and reconciling their
    formerly inconsistent case-handling to case-sensitive (matching the
    uppercase prefix that generation emits). (NEW-48 / issue
    [\#44](https://github.com/rmsharp/nprcgenekeepr/issues/44) /
    [\#38](https://github.com/rmsharp/nprcgenekeepr/issues/38))
  - [`getPotentialParents()`](https://github.com/rmsharp/nprcgenekeepr/reference/getPotentialParents.md)
    now selects candidate dams using a gestation-derived exclusion
    window driven by its existing `maxGestationalPeriod` parameter,
    replacing a fixed half-year window. A female who delivered another
    offspring within `maxGestationalPeriod` days of a focal animal’s
    birth is excluded as a candidate dam (a female bears one offspring
    at a time), so dam selection now responds to the species’ gestation
    length rather than a hard-coded +/- 182.5 days. Sire selection
    already used this parameter; the sire (presence at conception) / dam
    (presence at birth) exit-check asymmetry is intentional and now
    documented. (NEW-49 / issue
    [\#31](https://github.com/rmsharp/nprcgenekeepr/issues/31))
- Major changes
  - Architectural Changes
    - Modular Shiny Architecture
      - Refactored monolithic Shiny application into discrete, testable
        modules using shiny::moduleServer()  
      - New module files:
        - modInput.R - Data input and QC processing  
        - modPedigree.R - Pedigree browser with trim/filter
          capabilities  
        - modPyramid.R - Age-sex pyramid visualization  
        - modGeneticValue.R - Genetic value analysis (mean kinship,
          genome uniqueness)  
        - modSummaryStats.R - Summary statistics with interactive
          visualizations
        - modBreedingGroups.R - Breeding group formation using
          groupAddAssign()
        - modORIPReporting.R - ORIP reporting module  
      - New appServer.R and appUI.R orchestrate module communication via
        shared reactive values
      - runModularApp() provides entry point for modular application
      - **Monolith retired (Phase 9).** The legacy monolithic
        application (`inst/application/`) has been deleted.
        [`runGeneKeepR()`](https://github.com/rmsharp/nprcgenekeepr/reference/runGeneKeepR.md)
        is now a soft-deprecated alias that launches the modular
        application via
        [`runModularApp()`](https://github.com/rmsharp/nprcgenekeepr/reference/runModularApp.md);
        existing zero-argument calls continue to work. Also removed the
        now-unused exports `getLogo()`, `shouldShowErrorTab()`,
        `modMinimalTestUI()`, and `modMinimalTestServer()`, plus the
        unexported `getMinParentAge()`. (XARCH-1 / issue
        [\#27](https://github.com/rmsharp/nprcgenekeepr/issues/27))
  - New Features
    - Dynamic Tab Management
      - Error List and Changed Columns tabs appear/disappear dynamically
        based on QC results  
      - Uses insertTab()/removeTab() for cleaner UI when no errors
        present
    - Enhanced QC Pipeline
      - runQcStudbook() wrapper provides UI-friendly error reporting  
      - processQcStudbookResult() transforms QC output for display  
      - shouldShowChangedColsTab() helper function
    - Improved Visualizations
      - getBoxWhiskerDescription() provides educational popover content
        for box plots
      - savePlotToFile() supports PNG, PDF, and SVG export
      - Enhanced pyramid plots with getPyramidPlot()
    - Genetic Value Analysis tab parity (modular app)
      - Exposed the genome-uniqueness threshold as a user control with a
        default of 4, matching the legacy application. The modular app
        previously hard-coded a threshold of 1, so default
        genome-uniqueness values from
        [`runModularApp()`](https://github.com/rmsharp/nprcgenekeepr/reference/runModularApp.md)
        now match the legacy app. (The analytical
        [`reportGV()`](https://github.com/rmsharp/nprcgenekeepr/reference/reportGV.md)
        default, `guThresh = 1`, is unchanged.)
      - Added a subset filter (view by animal IDs) and an “Export
        Subset” download, matching the legacy “Filter View” / “Export
        Current Subset”.
      - Changed the default gene-drop iterations to 1000 for legacy
        parity (was 5000); removed an inert “Minimum breeding age”
        slider that had no effect on the analysis.
    - Utility Functions
      - safeExecute() - Error-handling wrapper for module operations  
      - logModuleEvent() - Structured logging with futile.logger
        integration
      - makeFounderStatsTable(), makeGeneticSummaryTable() - Table
        generators
  - Testing Improvements
    - Added shiny::testServer() unit tests  
    - ~145 new/modified test files with comprehensive module coverage  
    - Tests for edge cases: NULL inputs, empty pedigrees, single-animal
      scenarios
    - Strict TDD development process used for all new features  
- Minor changes
  - New Dependencies
    - Added to Imports: bslib, DT, ggplot2  
    - Added to Suggests: shinytest2
  - Bug Fixes
    - Fixed undefined global variables in ggplot2 aes() calls
    - Fixed column name expectations in genetic value tests
      (meanKinship/genomeUniqueness)
    - Network-dependent tests now skip gracefully
  - Documentation
    - Corrected the roxygen `@examples` for
      [`getPedDirectRelatives()`](https://github.com/rmsharp/nprcgenekeepr/reference/getPedDirectRelatives.md),
      [`cumulateSimKinships()`](https://github.com/rmsharp/nprcgenekeepr/reference/cumulateSimKinships.md),
      and
      [`getIdsWithOneParent()`](https://github.com/rmsharp/nprcgenekeepr/reference/getIdsWithOneParent.md)
      so each help example calls the function it documents. Previously
      each example demonstrated a different function; in particular
      [`getPedDirectRelatives()`](https://github.com/rmsharp/nprcgenekeepr/reference/getPedDirectRelatives.md)
      showed
      [`getLkDirectRelatives()`](https://github.com/rmsharp/nprcgenekeepr/reference/getLkDirectRelatives.md)
      and omitted its required `ped` argument.

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
  - Technical edits of R code based on `lintr::lint_dir(“R”)`

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
