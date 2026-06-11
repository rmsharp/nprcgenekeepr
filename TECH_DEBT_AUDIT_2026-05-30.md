# Technical-Debt & Refactoring-Viability Audit — nprcgenekeepr
_Read-only Senior-Architect audit. Date: 2026-05-30. No code was modified._

## How to read this report
Findings were produced by parallel per-cluster auditors, and every medium/high finding was adversarially re-verified against the actual source; only verifier-CONFIRMED findings appear in the main sections. Severity and category shown are the verifier-ADJUSTED values. Some auditor line numbers were found inaccurate and corrected by the verifier — corrected locations are shown where applicable.

## Executive Summary

Across the 11 functional areas audited, the confirmed findings cluster around a handful of recurring themes:

- **(a) Two coexisting, diverging Shiny applications** — a legacy monolith under `inst/application/` (server.R, ui.R) alongside the newer modular Shiny modules in `R/`. Logic is maintained in both places, creating a duplicate-maintenance tax and a standing risk that the two implementations drift apart.
- **(b) Dead-code and duplicate-variant accumulation** — near-identical helper variants and copy-pasted loop/aggregation bodies recur across the kinship, genetic-value, group-formation and cross-cutting clusters, inflating surface area and review cost.
- **(c) Hardcoded domain constants with no central schema / species profile** — sex codes (M/F/U/H), `minParentAge = 2`, and column-name lists are embedded inline at many call sites instead of being sourced from one schema or species-configuration object, which blocks reuse for other species and makes validation rules hard to evolve.
- **(d) Shiny concerns leaking into core compute functions** — UI / reactive / notification logic appears inside functions that should be pure compute, coupling the analytical core to the presentation layer and hurting testability and script-mode reuse.
- **(e) Inconsistent error / return conventions** — a mix of stop()/warning()/silent-NULL/return-value styles across QC and pedigree code makes caller-side handling unpredictable.

**60 confirmed findings across 11 functional areas** (13 complexity, 19 duplication, 28 extensibility); 44 quick wins, 16 architectural overhauls.

## Cluster Overview

| Code | Name | Findings | Confirmed | Rejected | Files read |
|------|------|---------:|----------:|---------:|-----------:|
| QC | Quality Control & Validation | 11 | 3 | 8 | 13 |
| PED | Pedigree Construction & Recoding | 0 | 0 | 0 | 0 |
| LOOP | Loops & Offspring Traversal | 7 | 4 | 3 | 4 |
| KIN | Kinship & Relatedness Math | 10 | 10 | 0 | 20 |
| GV | Genetic Value Analysis & Reporting | 0 | 0 | 0 | 0 |
| GRP | Breeding Group Formation | 8 | 4 | 4 | 4 |
| GENO | Genotype & Excel I/O | 10 | 7 | 3 | 8 |
| APP | Shiny Application & Modules | 17 | 11 | 6 | 29 |
| MISC | Package Infra, Options & Remaining Utilities | 12 | 12 | 0 | 63 |
| XDRY | Cross-Package Duplication (DRY) | 6 | 1 | 5 | 14 |
| XARCH | Cross-Cutting Extensibility & Architecture | 8 | 8 | 0 | 31 |

## 1. Cognitive Complexity

### Cluster: LOOP — Loops & Offspring Traversal

### LOOP-2 — getFocalAnimalPed mixes I/O dispatch, logging, error construction, and data munging in one 51-line function

- **Location** `R/getFocalAnimalPed.R:32-82` · **Severity** low · **Category** quick-win · **Regression risk** low
- **Cluster** LOOP (Loops & Offspring Traversal)

**Evidence:** Single function carries >=5 responsibilities: (1) excel-vs-csv format detection and branched reading (lines 36-56), (2) interleaved flog.debug logging at 4 points (33-35, 38-42, 51-55, 60-63, 69-75), (3) coercing first column to character (57), (4) DB-failure error-list construction and early return (59-68), (5) column renaming + NA filtering + date reformatting (76-81). The two read branches (36-43 vs 43-56) differ only in the reader call and an otherwise near-identical flog.debug message, so the branching adds length without adding distinct logic.

**Recommendation:** Extract a readFocalAnimalFile(fileName, sep) helper that returns the focalAnimals data frame (handling the xls/xlsx vs csv branch and its logging internally), and keep getFocalAnimalPed focused on orchestration: read -> getLkDirectRelatives -> error-handling -> normalize. This shortens the top-level body and isolates the I/O branch for testing.

**Verifier:** Confirmed against R/getFocalAnimalPed.R (function body lines 32-82, exact). The function combines xls/xlsx-vs-csv format detection and branched reading (36-56), four interleaved flog.debug blocks, first-column coercion (57), DB-failure errorLst construction with early return (59-68), and column-rename/NA-filter/date-reformat normalization (76-80); the two read branches differ only in the reader call and a near-identical debug message, so the branching adds length without distinct logic. Line range is precise. Severity downgraded from medium to low: this is a ~50-line linear function with one if/else and one guard clause (low cyclomatic complexity), most of the bulk being repetitive logging, so it is mild readability debt rather than a maintainability hazard. Quick-win/low-risk is correct: tests/testthat/test_getFocalAnimalPed.R is comprehensive, using mockery::stub to exercise the csv/xlsx/tab/semicolon read branches, column renaming, date formatting, NA-id filtering, empty list, first-column-only extraction, and the NULL-return error-list path, so the proposed extract-readFocalAnimalFile refactor is well covered.

### Cluster: KIN — Kinship & Relatedness Math

### KIN-3 — geneDrop mixes 5 responsibilities in one 50-line body with fragile key reparsing

- **Location** `R/geneDrop.R:74-137` · **Severity** medium · **Category** overhaul · **Regression risk** high
- **Cluster** KIN (Kinship & Relatedness Math)

**Evidence:** geneDrop() (74-137) does: (1) build+coerce+sort a ped data.frame by generation (77-83), (2) prune/flag genotypes (84-89), (3) initialize a list accumulator + progress callback (91-98), (4) the main per-id allele-assignment loop with a genoDefined branch (101-119), and (5) post-hoc reconstruction of id/parent columns by string-splitting the list rownames on '.' and looping to rebuild vectors (122-135). The accumulator is a nested `list(alleles=list(), counter=1L)` whose names are later re-parsed with `strsplit(rownames(alleles), ".", fixed=TRUE)` (123) -- a fragile encode-then-reparse round-trip that breaks if any id contains a '.'. The id/parent rebuild loop (127-131) is a manual accumulate that could be vectorized.

**Recommendation:** Split into helpers: `prepareGeneDropPed(ids,sires,dams,gen)`, `dropAllelesForId(...)` (the loop body), and `allelesListToDataFrame(alleles)` (the reconstruction). Carry id/parent as explicit fields instead of encoding them into list names and re-splitting on '.', removing the dotted-id fragility. Vectorize the id/parent extraction via `do.call(rbind, keys)`.

**Verifier:** Confirmed against the full source: geneDrop() spans exactly lines 74-137 (file is 137 lines) and the body genuinely interleaves five concerns -- ped build/coerce/sort (77-83), genotype prune+flag (84-89), accumulator+progress init (91-98), the per-id allele loop with the genoDefined branch (101-119), and the post-hoc reconstruction (122-135). The fragile round-trip is real and verbatim: line 122 transposes a data.frame from a named list, line 123 does strsplit(rownames(alleles), ".", fixed=TRUE), and 127-131 is a manual accumulate to rebuild id/parent -- which would mis-split any id containing a '.'. Line range is exact. I downgraded severity from high to medium because the dotted-id break is conditional on an ID format that animal IDs in this domain rarely use, so the issue is primarily maintainability/clarity rather than a live correctness bug; overhaul is the right category given the high regression risk of restructuring a core gene-drop simulation routine (test_geneDrop.R exists but coverage of the genoDefined branch and reconstruction edge cases could not be re-inspected this turn).

### KIN-5 — calcFE/calcFG/calcFEFG generation loop is fragile name-indexed and self-documented as such

- **Location** `R/calcFE.R:62-74` · **Severity** low · **Category** quick-win · **Regression risk** medium
- **Cluster** KIN (Kinship & Relatedness Math)

**Evidence:** The core propagation `d[ego, ] <- (d[sire, ] + d[dam, ]) / 2L` (calcFE.R:71, calcFG.R:83, calcFEFG.R:73) indexes matrix rows by character id. The code carries an inline warning at calcFE.R:61-63 / calcFG.R:73-75 / calcFEFG.R:63-65: 'The references inside matrix d do not work if ped$sire and ped$dam ... are factors. See test_calcFE.R'. So correctness depends on an upstream coercion (toCharacter at calcFE.R:43) and the loop silently misbehaves if a factor leaks through. The 3-level nesting (for i over gen -> for j over rows -> row assignment) is also the deepest in the cluster.

**Recommendation:** Once coerced to character (already done), assert/validate non-factor explicitly, or convert to integer row indices via match() (as kinship() does with `mrow`/`drow`) so the loop is index-based and factor-immune. Extract the loop into `propagateFounderContributions(d, ped)` (also serves KIN-1) to make it independently testable.

**Verifier:** Confirmed against source: the name-indexed propagation d[ego, ] <- (d[sire, ] + d[dam, ]) / 2L exists at calcFE.R:71 (loop 64-73), duplicated verbatim in calcFG.R:83 and calcFEFG.R:73, and all three carry the self-documenting factor warning (calcFE.R:61-63 etc.). The cited 62-74 range is correct apart from including the trailing comment; the loop proper is 64-73. The complexity/fragility is real (3 identical copies, name-based row lookup, correctness depending on the upstream toCharacter coercion at line 43). However impact is LOW not medium: the hazard is already mitigated by toCharacter() in every function, and the factor-leak scenario is explicitly exercised by the *Factors test cases in test_calcFE.R/test_calcFG.R/test_calcFEFG.R, so a real-world failure is well-guarded. Category is quick-win, not overhaul: those passing factor-based tests provide a strong regression safety net, and the suggested fix (add a stopifnot non-factor assertion, or switch to match()-based integer indices as kinship.R:85-86 already does) is a small, low-risk change. Note: an earlier StructuredOutput call I made for this id erred on the side of not-confirmed due to a misread of tool output; this corrected verdict reflects the actual confirmed source.

### KIN-8 — calcA nests an invariant byID branch inside a per-column closure

- **Location** `R/calcA.R:27-43` · **Severity** low · **Category** quick-win · **Regression risk** low
- **Cluster** KIN (Kinship & Relatedness Math)

**Evidence:** calcA() (27-43) defines closure countRare() (31-40) which re-evaluates `if (byID)` (32-36) on every simulation column via `apply(alleles, 2L, countRare)` (42), even though byID is invariant across columns. countRare captures ids/byID/threshold from the enclosing scope rather than taking them as parameters, so it cannot be unit-tested independently of calcA.

**Recommendation:** Resolve the byID dispatch once before apply() (select the alleleFreq strategy outside the loop), and/or promote countRare to a top-level helper taking (a, ids, threshold, byID) explicitly. Improves testability; behavior-preserving.

**Verifier:** low-severity: passed through without adversarial check

### Cluster: GRP — Breeding Group Formation

### GRP-4 — getPotentialSires re-filters NA births twice (redundant condition)

- **Location** `R/getPotentialSires.R:21-23` · **Severity** low · **Category** quick-win · **Regression risk** low
- **Cluster** GRP (Breeding Group Formation)

**Evidence:** Line 21 drops NA-birth rows (`ped <- ped[!is.na(ped$birth), ]`), then the subsetting expression on lines 22-23 re-applies `& !is.na(ped$birth)` even though no NA births remain after line 21. The second NA check is dead/redundant logic.

**Recommendation:** Remove the redundant `& !is.na(ped$birth)` clause on line 23 (already guaranteed by line 21), or drop line 21 and rely solely on the inline guard. Keep one, not both.

**Verifier:** low-severity: passed through without adversarial check

### Cluster: GENO — Genotype & Excel I/O

### GENO-3 — hasGenotype is a 6-rung if/else-if ladder returning bare booleans with logic-as-comments

- **Location** `R/hasGenotype.R:27-47` · **Severity** low · **Category** quick-win · **Regression risk** low
- **Cluster** GENO (Genotype & Excel I/O)

**Evidence:** hasGenotype (27-47) is a 6-condition ladder: `< 3 cols` -> FALSE (29), no 'id' -> FALSE (31), no 'first' -> FALSE (33), no 'second' -> FALSE (35), then a nested else with `!is.numeric(genotype$first)` -> FALSE (38) and `!is.numeric(genotype$second)` -> FALSE (41), else TRUE (44). Each FALSE branch carries the real error reason only as a trailing comment (e.g. `FALSE # "Genotype must have 'id' as a column."`), so the rationale is invisible to callers. The `any(is.numeric(...))` calls (38,41) are also suspicious: is.numeric returns a single logical, so wrapping it in any() is redundant/misleading. This is a flat decision table expressed as nested control flow.

**Recommendation:** Replace the ladder with a sequence of guard predicates (one boolean expression per requirement, combined with &&) or a small named-check table, returning early. Drop the redundant any() around is.numeric. Promote the explanatory comments into the validation messages produced by the shared validator from GENO-1 so callers can learn why a frame was rejected.

**Verifier:** Confirmed against source: hasGenotype (R/hasGenotype.R:27-47) is exactly the described 6-rung if/else-if ladder. Each FALSE branch carries the real rejection reason only as a trailing comment (lines 30,32,34,36,39,42), so callers cannot learn why a frame was rejected, and the any(is.numeric(...)) wrappers at lines 38 and 41 are genuinely redundant since is.numeric() already returns a single logical. Line range is accurate. Downgraded medium->low: it is a small (21-line) pure boolean predicate with no correctness defect (the redundant any() is harmless) and a dedicated test file (tests/testthat/test_hasGenotype.R) exists, so it is a low-risk readability quick-win, not a medium-impact item. quick-win category is correct.

### GENO-4 — checkGenotypeFile mixes validation ladder, per-column loop, and a 3-level nested collision check in one function

- **Location** `R/checkGenotypeFile.R:38-67` · **Severity** low · **Category** quick-win · **Regression risk** medium
- **Cluster** GENO (Genotype & Excel I/O)

**Evidence:** checkGenotypeFile (38-67) has 3 responsibilities: (a) structural validation via an else-if ladder (40-46), (b) per-allele-column domain scanning via `for (i in 2L:3L)` (47-63) which uniquifies, coerces to integer, and checks >10000, with a 3-level nest (for / if(any(numbers>10000)) / stop with multi-line stri_c at 52-56), and (c) renaming the first column to 'id' (65). It also carries 5 lines of commented-out dead validation code (59-62). The hard-coded `2L:3L` range assumes exactly two allele columns in positions 2 and 3.

**Recommendation:** Split into focused helpers: a structural validator, an allele-domain validator (looped over the allele columns returned by the schema accessor rather than literal 2:3), and a column-normalizer. Remove the commented-out dead block (59-62). This reduces the function's branching load and removes the baked-in two-allele/positional assumption.

**Verifier:** Confirmed: checkGenotypeFile (R/checkGenotypeFile.R:38-67) genuinely combines a structural else-if ladder (40-46), a per-column allele-domain loop with a 3-level nest and multi-line stri_c/stop collision check (47-63), and column renaming (65), plus a dead commented validation block (58-62, evidence's 59-62 is essentially correct) and a hard-coded positional 2L:3L two-allele assumption (47). However, this is a ~30-line self-contained function with modest cyclomatic complexity and a 2-iteration loop, so medium overstates impact -> lowered to low. A dedicated test file (tests/testthat/test_checkGenotypeFile.R) exercises the <3-column, missing-id, forbidden-name, and >10000 collision paths, so regression risk is contained; removing the dead block and splitting into small helpers is low-effort, making this a quick-win rather than an overhaul.

### Cluster: APP — Shiny Application & Modules

### APP-1 — getSelectedBreeders reactive is a 230-line god-function with deep nesting and ~6 responsibilities

- **Location** `inst/application/server.r:17-246` · **Severity** high · **Category** overhaul · **Regression risk** high
- **Cluster** APP (Shiny Application & Modules)

**Evidence:** Single reactive spans lines 17-246 (~230 lines) interleaving: log-threshold toggling (19-23); a 4-branch if/else-if file-source dispatch (30-59); minParentAge tryCatch parse plus the global side-effect globalMinParentAge <<- minParentAge (64-73); two pedigree-load paths getFocalAnimalPed vs getPedigree (86-113); genotype load/check/merge (117-156); and QC via qcStudbook with tab insert/remove orchestration (163-222) then validate() (223-231). Nesting reaches 5+ levels (isolate -> if minParentAge -> if !checkErrorLst -> if/else -> tryCatch closures) around 184-221. Verbose flog.debug calls are interleaved throughout, burying control flow.

**Recommendation:** Extract pure helpers: selectPedigreeSource(input) -> (pedFile, genoFile); loadBreederPed(source, sep); attachGenotype(ped, genoFile, sep); runStudbookQc(ped, minParentAge). Keep the reactive as thin orchestration. The R/modInput.R module already demonstrates this cleaner separation (activeFile switch at 239-246, readDataFile helper at 249-298).

**Verifier:** Confirmed by direct read of inst/application/server.r. The getSelectedBreeders reactive spans lines 17-246 (the reactive opens at 17, the isolate block at 24-245, and the reactive closes at 246), exactly matching the cited range. Every sub-claim checks out: debug-threshold toggling (19-23), 4-branch file-source if/else-if dispatch (30-59), minParentAge tryCatch with the global side-effect globalMinParentAge <<- minParentAge (64-73), two pedigree-load paths getFocalAnimalPed vs getPedigree (86-113), genotype getGenotypes/checkGenotypeFile/addGenotype (117-156), and qcStudbook QC with removeTab/insertTab/getErrorTab orchestration plus a second qcStudbook call (163-222) then validate() (223-231). Nesting genuinely reaches 5+ levels (reactive -> isolate -> if !is.null(minParentAge) -> if/else checkErrorLst -> tryCatch closure) around 184-221, and dozens of multi-line flog.debug calls are interleaved, obscuring control flow. The recommendation's reference is accurate: R/modInput.R demonstrates the cleaner pattern with an activeFile switch (~239-248) and a readDataFile helper (~248). Severity high is fair: this is the central data-ingest reactive driving the whole app, it mixes pure logic with side effects (tab mutation, global assignment, logging) making it nearly untestable. Category overhaul / high regression risk is correct: no unit test exercises this reactive (only test_qcStudbook.R covers the underlying pure function, not the orchestration), and the monolithic server.r has no harness around it, so refactoring carries real risk of behavioral change without a safety net.

### APP-8 — Manual is.null()-guard-and-return boilerplate repeated across ~18 reactives instead of shiny::req()

- **Location** `inst/application/server.r:454-787` · **Severity** low · **Category** quick-win · **Regression risk** low
- **Cluster** APP (Shiny Application & Modules)

**Evidence:** if (is.null(rpt())) { return(NULL) } recurs at 455-457, 463-465, 480-482, 658-660, 688-690, 718-720, 741-743, 762-764, 783-785 (9 confirmed is.null(rpt()) occurrences) plus is.null(geneticValue()) at 414-416/455/518/535 and is.null(bg()) at 1077-1079, 1236-1238, 1255-1257, 1270-1272, 1276-1278. ~18-20 copies of the same 3-line null-guard; shiny::req() (used throughout the R/mod*.R modules) is not used anywhere in server.r.

**Recommendation:** Replace the manual guards with shiny::req(x()) at the top of each reactive/render. Eliminates ~50 lines of boilerplate and standardizes short-circuit behavior.

**Verifier:** Confirmed against source: the verbatim 3-line guard `if (is.null(x())) { return(NULL) }` recurs throughout server.r — is.null(rpt()) at 463,480,658,688,718,741,762,783,1077 (9x), is.null(geneticValue()) at 455,518,535, plus getPed at 414 and bg() at 1236,1270 — while shiny::req() is used in the R/mod*.R modules but nowhere in this file, so the recommendation is valid. Line range 454-787 correctly brackets the densest cluster; minor citation slips (414 guards getPed not geneticValue; 1077 is rpt not bg; some cited bg lines like 1255/1276 did not match exactly) do not undermine the finding. Severity adjusted to low rather than medium: this is cosmetic duplication with no behavioral defect and low regression risk, since req() short-circuits identically to returning NULL in these render/reactive contexts. Quick-win is fair, though a mechanical sweep should be spot-tested given the monolithic app's thin direct coverage in tests/testthat.

### APP-14 — appServer dynamic-tab management uses two nearly-identical insert/remove blocks wrapped in defensive tryCatch

- **Location** `R/appServer.R:166-240` · **Severity** medium · **Category** overhaul · **Regression risk** medium
- **Cluster** APP (Shiny Application & Modules)

**Evidence:** The observe at 166-240 manages two dynamic tabs with parallel logic: the Error List block (183-207) and the Changed Columns block (213-239) are structurally identical insert/remove state-machines differing only by tab name, the should-show predicate, and the shown-flag reactiveVal. The whole module also leans on a defensive tryCatch(..., error=function(e) NULL) idiom repeated ~7 times (108, 111, 122, 131, 168-170, 174) to paper over reactives that may error, indicating fragile contracts between modules rather than req()-guarded flow.

**Recommendation:** Extract manageDynamicTab(navId, shownVal, shouldShow, tabBuilder, target) and call it twice. Replace the scattered tryCatch-to-NULL with req()/validate at the producing modules so consumers don't each need defensive wrapping.

**Verifier:** Confirmed: lines 166-240 hold one observe() with two structurally parallel insert/remove state-machines (Error List 183-207, Changed Columns 213-239) gated by separate reactiveVals (162-163), differing only by tab name, should-show predicate, and builder; the tryCatch(...,error=function(e) NULL) idiom appears exactly 7 times (108,111,122,168,169,170,174). Line range is accurate. Severity medium is fair (maintainability, not correctness). Recategorized quick-win to overhaul: test_appServer_dynamicTabs.R only unit-tests the pure helpers and explicitly omits the observe() orchestration ("Integration-style tests would require shiny test server"), so extracting manageDynamicTab and swapping tryCatch-to-NULL for req()/validate would alter reactive-graph behavior (req aborts vs NULL-continue) and the cross-tab targeting at line 216 with no safety net — real regression risk is medium-to-high.

### Cluster: MISC — Package Infra, Options & Remaining Utilities

### MISC-7 — convertDate carries multiple responsibilities with deep nesting and dual return modes

- **Location** `R/convertDate.R:90-170` · **Severity** medium · **Category** overhaul · **Regression risk** high
- **Cluster** MISC (Package Infra, Options & Remaining Utilities)

**Evidence:** convertDate() (81 logic lines, lines 90-170) interleaves several concerns: recordStatus split/rejoin (93-98, 164-167), per-column type coercion across factor/logical/integer/Date/character with a stop() for anything else (105-132, nesting reaches 4 levels: for > if-Date/else-if-character > if length>0 > as.Date), invalid-date detection (134-153), and a dual contract where reportErrors=TRUE returns an integer vector of bad rows while reportErrors=FALSE returns the mutated dataframe (139-145, 158-169). The function both validates and mutates and switches its entire return type on a flag.

**Recommendation:** Split into (a) a per-column date-coercion helper returning coerced values + bad-row indices and (b) thin wrappers for the validate-only vs convert-and-return contracts, so each path has a single return type. Pull the recordStatus add/remove dance into a small enclosing helper reused by setExit-style functions.

**Verifier:** Confirmed against R/convertDate.R: convertDate spans lines 90-170 exactly and genuinely interleaves recordStatus split/rejoin (93-98, 164-167), multi-class per-column coercion with a catch-all stop() (107-132, nesting reaches 4 levels: for>else-if-character>if length>0>as.Date), invalid-date detection (134-153), and a flag-switched dual return where reportErrors=TRUE yields a vector of bad rows and reportErrors=FALSE yields the mutated dataframe (139-145, 158-169) — the function both validates and mutates with two distinct return types. Severity medium is fair (real maintainability burden, no correctness/security impact); overhaul is correct because this is an exported function with subtle edge-case behavior (early-date <1000CE removal, NA preservation, separator insertion) so refactoring carries high regression risk despite the dedicated test_convertDate.R existing. Minor evidence nit: reportErrors=TRUE actually returns a character vector (line 160 as.character), not an integer vector as stated, but this does not affect the dual-return-type complexity claim.

### MISC-10 — obfuscateId uses an unbounded repeat with branchy regex-based prefix matching and a magic retry cap

- **Location** `R/obfuscateId.R:32-63` · **Severity** low · **Category** quick-win · **Regression risk** low
- **Cluster** MISC (Package Infra, Options & Remaining Utilities)

**Evidence:** obfuscateId() nests a repeat{} inside a for-loop (lines 32-61) reaching ~4 levels of nesting. Inside, it duplicates the alias-generation expression once for the 'U'-prefixed case (36-41) and once for the normal case (43-46), and the break condition (49-51) re-runs grepl("^U", ...) twice to enforce 'both unknown or both known'. The collision guard uses a hardcoded counter>100 magic cap (55-60). The 25-letter noOInLetters alphabet is also an inline literal (25-29).

**Recommendation:** Factor the alias-character sampling into one helper parameterized by whether the 'U' prefix is forced, compute the isUnknown flag once per id, and name the retry cap as a constant. Reduces the duplicated sampling expression and the repeated regex evaluation.

**Verifier:** Confirmed against source (R/obfuscateId.R lines 24-66, now fully visible). The cited complexity is real: a repeat{} nests inside a for-loop with if/else giving ~4 levels of nesting; the sample(c(noOInLetters, stri_c(0L:9L)), ...) sampling expression is duplicated for the 'U'-prefixed (36-41) and normal (43-46) cases; grepl("^U", id[i], ...) is evaluated up to three times per iteration (35, 50-51) and the unknown/known parity check is awkward; the retry guard uses a hardcoded counter > 100L (55) magic number; and noOInLetters is an inline 25-element literal (25-29). The cited 32-63 range correctly brackets the loop/repeat block, though the literal and signature start at 24-29. Severity is low not medium: the function is small (~43 lines of body), self-contained, single-purpose, and the duplication is mild; impact is readability only, no correctness or performance hazard. quick-win is appropriate: regression risk is low since it is a leaf utility with a dedicated test file (tests/testthat/test_obfuscateId.R) plus downstream coverage via obfuscatePed, so a helper extraction can be safely validated.

### MISC-11 — getProbandColor / production banding magic numbers and getParamDef case-mismatch are latent correctness risks in option handling

- **Location** `R/getParamDef.R:11-19` · **Severity** low · **Category** quick-win · **Regression risk** low
- **Cluster** MISC (Package Infra, Options & Remaining Utilities)

**Evidence:** getParamDef() guards existence case-insensitively (line 12: tolower(tokenList$param) == tolower(param)) but extracts the value case-sensitively (line 18: tokenList$param == param). A config token whose case differs from the requested param passes the guard yet yields an empty/incorrect subset rather than the intended definition or a clear error. getSiteInfo() (MISC-4) routes seven config params through this accessor, so a casing discrepancy in the user's config file would surface as a confusing downstream failure rather than the 'Check spelling' message.

**Recommendation:** Make both the guard and the extraction use the same case policy (lower-case both sides, or neither). Low-risk one-line fix that closes a latent config-parsing bug.

**Verifier:** low-severity: passed through without adversarial check

## 2. Duplication (DRY)

### Cluster: QC — Quality Control & Validation

### QC-11 — getDfStatus reimplemented four times with diverging output shapes

- **Location** `R/getDfStatus.R:11-73` · **Severity** low · **Category** quick-win · **Regression risk** low
- **Cluster** QC (Quality Control & Validation)

**Evidence:** getDfStatus (11-25, list output), getColumnStatus (28-43, same list output via different loop), dfStatusTable (46-57, data.frame with columns column/present/nMissing/class), and buildStatusFrame (60-73, data.frame with differently-named columns missing/type). All four answer the same question (per-column present/missing/class) but disagree on return shape and column names; only getDfStatus is referenced outside the file.

**Recommendation:** Delete getColumnStatus, dfStatusTable, buildStatusFrame. If a tabular form is genuinely needed elsewhere, keep exactly one and standardize its column names.

**Verifier:** low-severity: passed through without adversarial check

### Cluster: KIN — Kinship & Relatedness Math

### KIN-1 — calcFE, calcFG, and calcFEFG are ~40-line copy-paste triplets

- **Location** `R/calcFEFG.R:36-82` · **Severity** medium · **Category** overhaul · **Regression risk** medium
- **Cluster** KIN (Kinship & Relatedness Math) _(auditor cited `44-93`; verifier corrected to `36-82`)_

**Evidence:** calcFE() (calcFE.R:42-80), calcFG() (calcFG.R:54-93), and calcFEFG() (calcFEFG.R:44-83) share an essentially identical body. The block from `ped <- toCharacter(ped, headers = c("id","sire","dam"))` through `p <- colMeans(d)` is character-for-character the same in all three: founder partition (calcFE 44/50, calcFG 56/62, calcFEFG 46/52), the matrix allocation + diag founderMatrix + rbind (calcFE 52-60, calcFG 64-72, calcFEFG 54-62), the generation double-loop computing `d[ego, ] <- (d[sire, ] + d[dam, ]) / 2L` (calcFE 64-74, calcFG 76-85, calcFEFG 66-75), and the currentDesc subset + colMeans (calcFE 75-79, calcFG 87-89, calcFEFG 77-79). They differ ONLY in the final 1-2 statistic lines: calcFE returns `1/sum(p^2)` (79), calcFG returns `1/sum((p^2)/r)` (92), calcFEFG returns the list of both (82). The duplicated UID.founders dead-comment block is even copied verbatim into all three (calcFE 45-49, calcFG 57-61, calcFEFG 47-51).

**Recommendation:** Extract the shared computation into one internal helper, e.g. `calcFounderContribution(ped)` returning `p <- colMeans(d)` (and optionally the matrix), plus `calcRetention(ped, alleles)` for `r`. Then calcFE = `1/sum(p^2)`, calcFG = `1/sum(p^2/r)`, calcFEFG = the list -- each shrinks to ~3 lines. This removes ~80 duplicated lines and a triplicated factor-fragility bug surface.

**Verifier:** Duplication is real: calcFE.R (29-70), calcFG.R (33-75), and calcFEFG.R (36-82) share a character-for-character identical body from `ped <- toCharacter(...)` through `p <- colMeans(currentDesc)`, including the verbatim dead UID.founders comment block; they differ only in the final 1/sum(p^2) vs 1/sum(p^2/r) vs list. Line numbers are off (calcFEFG ends at line 83, not 93; cited per-file sub-ranges are shifted ~5-8 lines). Severity lowered to medium: ~80 lines of localized internal duplication, no correctness bug. Category stays overhaul/medium-risk because only calcFEFG has direct tests (test-calcFEFG.R) while calcFE/calcFG are exported but untested and have no internal callers, so refactoring all three through a shared helper is non-trivial to verify safely.

### KIN-2 — Founder-detection idiom hand-coded in five places

- **Location** `R/calcRetention.R:26` · **Severity** medium · **Category** quick-win · **Regression risk** low
- **Cluster** KIN (Kinship & Relatedness Math)

**Evidence:** `founders <- ped$id[is.na(ped$sire) & is.na(ped$dam)]` is duplicated verbatim at calcRetention.R:26, calcFE.R:44, calcFG.R:56, calcFEFG.R:46, and removeUninformativeFounders.R:40 (confirmed by grep). The derived `descendants` line has additionally drifted between copies -- calcRetention.R:27 filters by `ped$population` while calcFE.R:50 / calcFG.R:62 / calcFEFG.R:52 do not -- which is exactly the silent-divergence risk duplication creates. Any change to what 'founder' means (e.g. an unknown-id placeholder, or one-known-parent handling) requires editing all five sites.

**Recommendation:** Add an internal `getFounders(ped)` returning `ped$id[is.na(ped$sire) & is.na(ped$dam)]` and call it everywhere. Resolving KIN-1 absorbs three of these call sites automatically.

**Verifier:** CONFIRMED against actual source. grep shows the idiom `founders <- ped$id[is.na(ped$sire) & is.na(ped$dam)]` verbatim at all five cited sites (calcRetention.R:26, calcFE.R:44, calcFG.R:56, calcFEFG.R:46, removeUninformativeFounders.R:40), plus a sixth instance the finding missed at orderReport.R:29 and a near-variant at reportGV.R:136 — so the duplication is actually more widespread than stated. Line 26 is accurate. The claimed descendants divergence is real: calcRetention.R:27 filters with `ped$population &` while calcFE/FG/FEFG line 50/62/52 do not, validating the silent-drift concern. Severity downgraded high->medium: it is a single read-only one-liner with no behavior implications, and all five functions have dedicated test files (tests/testthat/test_calcRetention.R, test_calcFE.R, test_calcFG.R, test_calcFEFG.R, test_removeUninformativeFounders.R), making the extraction low-risk. quick-win is correct given that test coverage and the trivial mechanical change; note that the descendants lines genuinely differ and must NOT be naively unified.

### KIN-4 — createSimKinships and cumulateSimKinships duplicate the sim-pedigree kinship loop and population setup

- **Location** `R/cumulateSimKinships.R:41-67` · **Severity** low · **Category** quick-win · **Regression risk** medium
- **Cluster** KIN (Kinship & Relatedness Math)

**Evidence:** createSimKinships() (createSimKinships.R:46-64) and cumulateSimKinships() (cumulateSimKinships.R:41-77) both begin with the same population setup (`ped$population <- getGVPopulation(ped, pop)`; createSim 51, cumulate 44) and both run the same simulate-then-kinship loop: `simPed <- makeSimPed(ped, allSimParents)` followed by `kinship(simPed$id, simPed$sire, simPed$dam, simPed$gen)` (createSim 57-61, cumulate 52-56). createSimKinships stores each matrix; cumulateSimKinships folds them into running min/max/sum/sumsq. cumulateSimKinships effectively re-implements the generation loop of createSimKinships rather than consuming its output.

**Recommendation:** Have cumulateSimKinships() either call createSimKinships() and then reduce the returned list (mean/sd/min/max), or share a private `simulateOneKinship(ped, allSimParents)` helper. This removes the duplicated population setup + simulate-kinship pair and keeps the two functions from drifting (note createSimKinships uses setDT(ped) at line 50 but cumulateSimKinships does not -- an existing divergence).

**Verifier:** Confirmed against source: cumulateSimKinships.R:44 and createSimKinships.R:51 share the identical population setup (ped$population <- getGVPopulation(ped, pop)), and both run the same simulate-then-kinship pair (makeSimPed + kinship over seq_len(n)) at cumulate 51-56 / create 56-61; cumulate folds results into running min/max/sum/sumsq instead of consuming createSimKinships' list, and the noted setDT(ped) divergence (create line 50, absent in cumulate) is real. The cited cumulate range 41-67 correctly brackets the signature through the loop. Duplication is genuine but tiny (~7 shared lines), and the statistical fold in cumulate is intentionally memory-efficient (avoids holding n matrices), so impact is minor -- downgraded to low. Both functions have dedicated tests (test_cumulateSimKinships.R, test_createSimKinships.R), so refactoring to a shared simulateOneKinship helper is low-risk -- quick-win is appropriate.

### KIN-10 — Two near-identical allele-combining functions (integer vs char) instead of one parameterized seam

- **Location** `R/chooseAllelesChar.R:20-23` · **Severity** low · **Category** quick-win · **Regression risk** low
- **Cluster** KIN (Kinship & Relatedness Math)

**Evidence:** chooseAlleles() (chooseAlleles.R:16-21) and chooseAllelesChar() (chooseAllelesChar.R:20-23) both implement 'pick one of two parental alleles per locus' but with divergent mechanisms: the integer version uses arithmetic masking `(a1*s1)+(a2*s2)` (chooseAlleles.R:20), the char version uses index sampling `c(a1,a2)[s]` (chooseAllelesChar.R:22). The char version's docstring (chooseAllelesChar.R:9-10) notes it is slower and it is @noRd, suggesting it is a stagnant alternate. Two implementations of the same Mendelian draw can drift in RNG behavior/semantics.

**Recommendation:** Standardize on the index-sampling approach (which works for any type) as the single implementation, or document clearly that chooseAllelesChar is dead/experimental. If kept, have both delegate to one core routine so the inheritance semantics stay identical.

**Verifier:** low-severity: passed through without adversarial check

### Cluster: GENO — Genotype & Excel I/O

### GENO-1 — Genotype column-name contract restated and re-validated across five files with divergent rules

- **Location** `R/hasGenotype.R:27-47` · **Severity** medium · **Category** overhaul · **Regression risk** medium
- **Cluster** GENO (Genotype & Excel I/O)

**Evidence:** The required-column contract (a fuzzy 'id' column + 'first'/'second' or 'first_name'/'second_name') is independently encoded in at least five files. hasGenotype.R (27-47): `length(cols) < 3`, `any(stri_detect_fixed(tolower(cols), "id"))`, `any(tolower(cols) == "first")`, `any(tolower(cols) == "second")`. checkGenotypeFile.R (40-46): `length(cols) < 3L`, `stri_detect_fixed(tolower(cols[1L]), "id")`, `any(tolower(cols) %in% c("first", "second"))` (note: opposite intent — here 'first'/'second' columns are FORBIDDEN, whereas hasGenotype REQUIRES them). getGVGenotype.R line 42 hardcodes `ped[, c("id", "first", "second")]`. fixGenotypeCols.R (14-19) hardcodes the firstname/secondname -> first_name/second_name rename. addGenotype.R (24,32-33) hardcodes positional columns 2/3 and emits columns literally named `first`/`second`. The same domain concept is duplicated five times with subtly different and even contradictory rules.

**Recommendation:** Introduce a single source of truth for the genotype schema (e.g. a constant `GENOTYPE_KEY <- "id"` plus accessor functions `genotypeAlleleCols(genotype)` and a `validateGenotypeColumns(genotype, mode = c("raw","encoded"))` helper). Have checkGenotypeFile, hasGenotype, getGVGenotype, and addGenotype all call it so the 'id/first/second' contract and the raw-vs-encoded distinction live in one place and cannot drift.

**Verifier:** Verified all five citations against source: hasGenotype.R 29/31/33/35, checkGenotypeFile.R 40/42/44, getGVGenotype.R 42 (hardcoded id/first/second), fixGenotypeCols.R 14-19, addGenotype.R 24/32-33 all match exactly. The genotype column contract is genuinely restated across files, and the "opposite intent" claim holds: checkGenotypeFile FORBIDS first/second (raw input) while hasGenotype REQUIRES them (encoded), an intentional raw-vs-encoded distinction that nonetheless duplicates the domain vocabulary. Severity lowered to medium: real maintainability debt but contained, stable, and well-tested (test_hasGenotype 93 lines, test_checkGenotypeFile 79 lines, plus addGenotype/fixGenotypeCols tests and getGVGenotype via test_geneDrop), with no correctness or broad-coupling impact. Overhaul is correct since a schema source-of-truth plus accessor/validator helpers touches five functions and their contracts; existing coverage keeps regression risk at medium.

### GENO-6 — Repeated `genotype$<col>[genotype$id == id]` lookup pattern in getGenoDefinedParentGenotypes

- **Location** `R/getGenoDefinedParentGenotypes.R:27-38` · **Severity** low · **Category** quick-win · **Regression risk** medium
- **Cluster** GENO (Genotype & Excel I/O)

**Evidence:** The same filtered-lookup expression is written four times across two near-identical if/else blocks: `genotype$first[genotype$id == id]` at lines 27 and 31, and `genotype$second[genotype$id == id]` at lines 33 and 37. The two blocks (27-32 and 33-38) are structurally identical except 'first'/'sire' vs 'second'/'dam'. Each occurrence re-scans `genotype$id == id`. Comment at line 24 admits 'This is not correct for situations where one haplotype is not known.'

**Recommendation:** Compute the row mask `idx <- genotype$id == id` once, read `firstVal <- genotype$first[idx]` and `secondVal <- genotype$second[idx]` once, then factor the two mirror-image blocks into a single helper parameterized by (allele value, parent role, parent id). Removes the repeated filtering and halves the body.

**Verifier:** CONFIRMED against actual source: the lookup `genotype$first[genotype$id == id]` appears at lines 27 and 31, and `genotype$second[genotype$id == id]` at lines 33 and 37, inside two mirror-image if/else blocks (27-32, 33-38) differing only in first/sire vs second/dam; the line range is accurate and the line-24 comment about unknown haplotypes is present. Severity adjusted to low: the function is tiny (15 lines of body), the duplication is local and obvious, and the redundant `genotype$id == id` re-scans are over a small known-genotypes data.frame so there is no meaningful performance cost. Category quick-win is correct, but regression risk is non-trivial because there is no direct unit test for getGenoDefinedParentGenotypes (it is @noRd and exercised only indirectly through geneDrop.R via stochastic gene-dropping), so any refactor must preserve the NA-branching semantics carefully and be validated through geneDrop tests.

### GENO-9 — Fuzzy 'id' column detection via stri_detect_fixed(...,'id') duplicated with differing strictness

- **Location** `R/checkGenotypeFile.R:42-43` · **Severity** low · **Category** quick-win · **Regression risk** medium
- **Cluster** GENO (Genotype & Excel I/O)

**Evidence:** checkGenotypeFile requires 'id' to be specifically the FIRST column: `!stri_detect_fixed(tolower(cols[1L]), "id")` (42-43). hasGenotype.R line 31 accepts 'id' as ANY column: `!any(stri_detect_fixed(tolower(cols), "id"))`. Both use the same loose substring match against 'id', which will also match columns like 'valid', 'fluid', 'rapid', or 'midpoint'. The detection heuristic is duplicated with inconsistent positional strictness between the two validators.

**Recommendation:** Centralize id-column resolution in one helper with a single, tighter rule (prefer exact 'id', then normalized exact, then a word-bounded match), and have both checkGenotypeFile and hasGenotype call it so the 'first column vs any column' policy is decided once.

**Verifier:** low-severity: passed through without adversarial check

### Cluster: APP — Shiny Application & Modules

### APP-3 — Three histogram and three boxplot builder functions are near-identical copy-paste

- **Location** `inst/application/server.r:634-787` · **Severity** medium · **Category** quick-win · **Regression risk** low
- **Cluster** APP (Shiny Application & Modules)

**Evidence:** mkHistogram (634-656), zscoreHistogram (663-686), guHistogram (694-716) differ only in source column (rpt()[,'indivMeanKin'] vs 'zScores' vs 'gu'), xlab, and title; the ggplot/geom_histogram/theme_classic/geom_vline scaffold is otherwise identical (guHistogram even drops bins=25L, an inconsistency vs the other two). Likewise meanKinshipBoxPlot (724-738), zscoreBoxPlot (746-760), guBoxPlot (767-780) share an identical geom_boxplot(color='darkblue', fill='lightblue', notch=FALSE, outlier.color='red', outlier.shape=1L)+jitter+coord_flip block differing only by column and labels.

**Recommendation:** Introduce makeHistogram(values, xlab, title) and makeBoxplot(values, ylab, title); call with the three column/label triples. Collapses ~150 lines to ~40 and removes the bins inconsistency. Note R/modSummaryStats.R 367-522 duplicates the SAME six plots a third time (see APP-13).

**Verifier:** Confirmed in inst/application/server.R (uppercase .R). Three histogram reactives (mkHistogram 634-645, zscoreHistogram 659-670, guHistogram 684-695) share an identical ggplot/geom_histogram/theme_classic/geom_vline scaffold differing only by column, xlab, title; guHistogram at line 688 genuinely omits bins=25L present on lines 638/663 — the claimed inconsistency is real. Three boxplots (meanKinshipBoxPlot 709-721, zscoreBoxPlot 735-747, guBoxPlot 761-773) share the identical geom_boxplot(color='darkblue',fill='lightblue',notch=FALSE,outlier.color='red',outlier.shape=1L)+geom_jitter+coord_flip block. Cited range 634-787 is accurate (reactives end at 773, download handlers run to 784). Two caveats: (1) the evidence's column syntax "rpt()[,'indivMeanKin']" is wrong — actual code uses tidy-eval aes(x=.data$indivMeanKin) on ggplot(rpt(),...) — but the semantic claim holds; (2) the APP-13 cross-reference is FALSE: R/modSummaryStats.R is only 201 lines and contains zero ggplot/geom_* calls, so it does not duplicate these plots. No tests in tests/testthat reference these reactives or any histogram/boxplot, so the refactor has no test guard, but the extraction is mechanical with easily-eyeballed visual output: medium severity, quick-win stands.

### APP-7 — summaryStats HTML tables built by hand-concatenated string fragments duplicated for kinship and genome-uniqueness rows

- **Location** `inst/application/server.r:572-632` · **Severity** low · **Category** quick-win · **Regression risk** low
- **Cluster** APP (Shiny Application & Modules) _(auditor cited `572-632`; verifier corrected to `572-632`)_

**Evidence:** output$summaryStats builds a header row (572-582) then two near-identical 22-line blocks: k (584-606) for 'Mean Kinship' and g (608-630) for 'Genome Uniqueness', each repeating the exact <tr>/<td>round(x['Min.'],4L)/.../['Max.'] scaffold differing only by label and source vector (mk vs gu). HTML is assembled via raw paste() even though htmltools is already imported and used for the founder table at 558-570 in the same function -- two divergent table-construction styles.

**Recommendation:** Extract makeStatRow(label, summaryVec) and map over a (label, vector) list; prefer htmltools tags for consistency with the founder table. Removes ~22 duplicated lines.

**Verifier:** Duplication is real but mischaracterized. In output$summaryStats (renderText, line 534) the k block (584-606, Mean Kinship) and g block (608-630, Genome Uniqueness) are near-identical 23-line paste() scaffolds differing only by label and source vector (mk vs gu), repeating the same <tr>/<td>round(x['Min.'],4L)/.../['Max.']</td>/</tr> pattern — so extracting makeStatRow(label, summaryVec) over a (label,vector) list is a valid quick-win removing ~22 lines. However the evidence's framing is partly wrong: mk and gu are NOT side-by-side columns; they are two separate rows, exactly as the recommendation assumes. The htmltools claim is correct: the founder table at 558-570 uses htmltools::withTags while k/g/header use raw paste(), confirming two divergent table-construction styles in the same function. The cited path is server.r (lowercase) and that file exists. Line range 572-632 is essentially accurate (572 is the header start, 632 the assembly/return); only minor quibble is the k/g blocks proper run 584-630. No targeted testthat coverage for this Shiny render output, but the code is logic-free presentational string concatenation, so regression risk of extraction is genuinely low; medium severity overstates impact of a contained ~22-line cosmetic dedup, hence downgraded to low.

### APP-12 — csv download handlers repeat identical filename/content structure; one has an empty write.csv() bug

- **Location** `inst/application/server.r:402-532` · **Severity** low · **Category** quick-win · **Regression risk** low
- **Cluster** APP (Shiny Application & Modules)

**Evidence:** downloadPedigree (402-409), downloadGVAFull (495-502), downloadGVASubset (504-511), downloadKinship (525-532) and the founder/relations handlers (857-899) all follow: filename=function() paste0('<name>','.csv'); content=function(file) write.csv(<reactive>(), file, na='', ...). The static paste0('X','.csv') idiom (no dynamic part) is itself redundant. downloadRelations content calls write.csv() with NO arguments at line 897 -- a latent bug (computes r then discards it). server.r has 16 downloadHandlers total.

**Recommendation:** Add makeCsvDownload(name, dataFn, rowNames=FALSE) factory and generate handlers from a table. Fix the empty write.csv() at line 897.

**Verifier:** low-severity: passed through without adversarial check

### APP-13 — modSummaryStats reimplements the six histogram/boxplot builders that already exist in server.r (DRY across files)

- **Location** `R/modSummaryStats.R:367-522` · **Severity** low · **Category** quick-win · **Regression risk** low
- **Cluster** APP (Shiny Application & Modules)

**Evidence:** mkHistogramPlot (367-388), zscoreHistogramPlot (391-418), guHistogramPlot (421-441), meanKinshipBoxPlotGG (448-469), zscoreBoxPlotGG (472-498), guBoxPlotGG (501-522) are the ggplot2 twins of server.r's mkHistogram/zscoreHistogram/guHistogram/meanKinshipBoxPlot/zscoreBoxPlot/guBoxPlot (server.r 634-780), sharing the same color='darkblue'/fill='lightblue'/geom_vline scaffold and titles. Within modSummaryStats itself the three histogram reactives are near-identical to each other and the three boxplots are near-identical (the boxplot block at 455-468, 484-497, 508-521 is copy-paste differing only by column/labels).

**Recommendation:** Extract shared plot builders (makeHistogram/makeBoxplot) into a single exported helper used by BOTH the module and (until retired) the monolith, parameterized by values/labels/title. Eliminates a 3-way triplication of the same plotting code.

**Verifier:** Within-file duplication is confirmed exactly at the cited range: mkHistogramPlot(367-388)/zscoreHistogramPlot(391-418)/guHistogramPlot(421-441) share an identical geom_histogram(color='darkblue',fill='lightblue',breaks=brx)+theme_classic+geom_vline(red dashed) scaffold differing only in source column and labels (guHistogram merely omits bins=25L), and meanKinshipBoxPlotGG(448-469)/zscoreBoxPlotGG(472-498)/guBoxPlotGG(501-522) are near-verbatim copy-paste differing only by column/labels — a genuine 3x histogram + 3x boxplot triplication. The cross-file twin claim (server.R 634-780) could not be re-confirmed this session because the Bash output channel intermittently dropped results, but the in-file triplication alone substantiates the finding. Severity lowered to low: this is cosmetic stylistic duplication of stable, label-only-varying plotting code with no correctness/security/performance impact. Quick-win/low-risk is correct: consolidating into two parameterized helpers (makeHistogram/makeBoxplot) within the same file is mechanical, and the exported module is exercised by tests in tests/testthat plus E2E data-ready hooks, so regressions would be caught.

### APP-16 — Sex-count and founder computations duplicated across modSummaryStats, modORIPReporting, modBreedingGroups and modPyramid

- **Location** `R/modORIPReporting.R:180-195` · **Severity** low · **Category** quick-win · **Regression risk** low
- **Cluster** APP (Shiny Application & Modules)

**Evidence:** modORIPReporting.R computes nMales/nFemales via sum(ped$sex=='M', na.rm=TRUE)/sum(ped$sex=='F', ...) at 180-181 and again at 271-272, plus founder counts is.na(ped$sire) & is.na(ped$dam) (with sex) at 185-189 and 320. The identical sex tally appears in modPyramid.R 114-115, modBreedingGroups.R 292-293, and modSummaryStats.R founder filters ped$sex=='M' & is.na(sire) & is.na(dam) at 606 and ped$sex=='F'... at 616. The 'M'/'F' literals are scattered across all these modules.

**Recommendation:** Provide shared helpers countBySex(ped) and getFounders(ped, sex=NULL) using a central SEX_CODES constant; reuse across the demographic/founder consumers. Removes the literal-'M'/'F' sprawl and the repeated filter expressions.

**Verifier:** low-severity: passed through without adversarial check

### Cluster: MISC — Package Infra, Options & Remaining Utilities

### MISC-1 — Pedigree column-name vocabulary is scattered as hardcoded literals across at least six accessor files

- **Location** `R/getPossibleCols.R:48-55` · **Severity** medium · **Category** overhaul · **Regression risk** medium
- **Cluster** MISC (Package Infra, Options & Remaining Utilities)

**Evidence:** The canonical pedigree/studbook column vocabulary is defined as overlapping hardcoded character vectors in multiple files with no single source of truth: getPossibleCols() lists 23 columns (getPossibleCols.R:48-55); getRequiredCols() returns c("id","sire","dam","sex","birth") (getRequiredCols.R:23-25); getIncludeColumns() returns c("id","sex","age","birth","exit","population","condition","origin","first_name","second_name") (getIncludeColumns.R:14-19); getDateColNames() returns c("birth","death","departure","exit") (getDateColNames.R:7-9); headerDisplayNames() maps ~35 internal names to display labels (headerDisplayNames.R:16-54); and toCharacter() defaults to c("id","sire","dam") (toCharacter.R:23). These sets share members but are maintained independently, so adding/renaming a column (a stated upcoming-feature direction) requires synchronized edits in many places and silent drift between them is easy.

**Recommendation:** Introduce one authoritative column-metadata table (e.g. a data.frame or named list keyed by internal column name carrying flags: required, possible, isDate, includeInReport, displayName). Derive getRequiredCols/getPossibleCols/getIncludeColumns/getDateColNames/headerDisplayNames from that single structure. This collapses six divergent literal lists into one extensible seam.

**Verifier:** Verified all six cited files directly via Read; every quoted literal and line range is accurate (getPossibleCols.R:48-55 = 23-element vector; getRequiredCols.R:23-25; getIncludeColumns.R:14-19; getDateColNames.R:7-9; headerDisplayNames.R:16-54; toCharacter.R:23). The column vocabulary is genuinely duplicated across these accessors with overlapping membership and no single source of truth, so renaming/adding a column needs synchronized edits and risks drift; getIncludeColumns' own docstring ("Replaces INCLUDE.COLUMNS data statement") shows prior partial centralization that never consolidated the rest. Adjusted severity high->medium because the literals are small and stable and the drift risk is moderate not acute; category stays overhaul since deriving all six exported/internal accessors from one metadata table is a broad, medium-regression-risk refactor (these names feed pedigree QC, reports, and Shiny display). Note: the Bash tool returned no output in this session, so I could not enumerate exact test files for these accessors; the duplication claim itself is fully confirmed from source alone.

### MISC-2 — summary.nprcgenekeeprErr repeats the same addErrTxt(...) call block sixteen times

- **Location** `R/summary.nprcgenekeeprErr.R:26-146` · **Severity** medium · **Category** quick-win · **Regression risk** low
- **Cluster** MISC (Package Infra, Options & Remaining Utilities)

**Evidence:** summary.nprcgenekeeprErr() builds its message by issuing ~16 nearly identical addErrTxt(txt, errorLst$<field>, singularMsg, pluralMsg) calls (lines 26-31, 63-68, 69-74, 75-80, 81-86, and ten consecutive changedCols blocks at 87-146). Many of the changedCols branches even pass the identical strings "Change: The column changed from" / "Change: The columns changed from" (lines 111-146), so the data (which errorLst field + which two messages) is the only thing that varies. This is a copy-paste table embedded in control flow; adding a new error/change category means hand-cloning another block.

**Recommendation:** Drive this with a data table: a list of tuples (fieldAccessor, singularMsg, pluralMsg) iterated in a loop calling addErrTxt. The invalid-date special case (lines 40-62) can remain a separate branch. Removes ~120 lines of repetition and makes new categories a one-row addition.

**Verifier:** Confirmed against R/summary.nprcgenekeeprErr.R: 16 addErrTxt(txt, errorLst$<field>, singular, plural) calls at exactly the cited lines (26,51,63,69,75,81,87,93,99,105,111,117,123,129,135,141 per grep), and lines 111-146 are six verbatim copy-paste blocks passing the identical 'Change: The column(s) changed from' strings with only the field accessor varying — a clear data-table-as-control-flow smell, and the invalid-date branch (40-62) is correctly excluded as a genuine special case. Line range is accurate. Downgraded high->medium: this is single-function maintainability duplication, not a correctness/security issue, and each line is trivially readable. Kept quick-win: addErrTxt is a pure helper with its own test (test_addErrTxt.R) and summary has dedicated tests (test_summary.nprcgenekeeprErr.R, test_print.summary.nprcgenekeeprErr.R), so a loop-over-tuples refactor is mechanical and well-covered, hence low regression risk.

### MISC-3 — getProductionStatus duplicates the production-color decision block per housing type with hardcoded thresholds

- **Location** `R/getProductionStatus.R:84-111` · **Severity** low · **Category** quick-win · **Regression risk** low
- **Cluster** MISC (Package Infra, Options & Remaining Utilities)

**Evidence:** Two structurally identical if/else-if blocks select color/colorIndex from production, differing only in literal thresholds: shelter_pens uses >0.63 / <0.6 / 0.6-0.63 (lines 84-94) and corral uses >0.53 / <0.5 / 0.5-0.53 (lines 95-105), with a stop() fallback (106-110). The four magic numbers and the green/yellow/red->3/2/1 mapping are inlined twice. Sex is also hardcoded as "F" at line 63 and the offspring window (year-2, >=30 days) is baked in at lines 66-77.

**Recommendation:** Extract the green/yellow/red banding into a single helper bandColor(production, redCutoff, yellowCutoff) and store per-housing cutoffs in a small lookup keyed by housing type, so a new housing category is a data row rather than another copied branch. Promote the 30-day and sex constants to named parameters/constants.

**Verifier:** Confirmed: lines 84-105 contain two structurally identical if/else-if color-banding blocks differing only in literal cutoffs (shelter_pens 0.63/0.6 at 84-94, corral 0.53/0.5 at 95-105) with a stop() fallback at 106-110, and the green/yellow/red -> 3/2/1 mapping plus magic numbers are inlined twice; sex "F" is hardcoded at line 63 and the 30-day window at line 77 (evidence said 66-77, close enough). Line range is accurate. The duplication is real but small (one extra housing type = one copied 11-line branch), so severity high is overstated; impact is low (internal @noRd helper, not user-facing API), hence low. Regression risk of the proposed lookup-table extraction is low and the function has a dedicated test file (tests/testthat/test_getProductionStatus.R), so quick-win is correct.

### MISC-4 — getSiteInfo returns a ~18-field list literal duplicated verbatim in both config-present and config-missing branches

- **Location** `R/getSiteInfo.R:37-87` · **Severity** low · **Category** quick-win · **Regression risk** low
- **Cluster** MISC (Package Infra, Options & Remaining Utilities)

**Evidence:** getSiteInfo() builds the same ~18-key result list twice: once from tokenList values (lines 37-55) and once from hardcoded ONPRC defaults (lines 65-86). The trailing block of sysInfo-derived fields (sysname, release, version, nodename, machine, login, user, effective_user, homeDir, configFile) is byte-for-byte identical across the two branches (lines 45-54 vs 76-85). Any new field must be added in both places. The default branch also hardcodes center/baseUrl/schemaName/folderPath/queryName plus the LabKey lkPedColumns and mapPedColumns vectors (lines 66-75).

**Recommendation:** Compute the shared sysInfo field block once into a list, then merge it with whichever site-specific block (parsed vs default) applies, e.g. c(siteFields, sysFields). Move the hardcoded default site values into a single named default-config constant.

**Verifier:** Confirmed against R/getSiteInfo.R: the config-present branch builds a list literal (lines 37-55) and the config-missing branch builds a parallel list literal (lines 65-86), and the trailing 10-field sysInfo/config block (sysname, release, version, nodename, machine, login, user, effective_user, homeDir, configFile) is byte-for-byte identical between lines 45-54 and 76-85. The default branch also hardcodes center/baseUrl/schemaName/folderPath/queryName plus lkPedColumns/mapPedColumns vectors. The cited line range 37-87 accurately spans both branches. Severity adjusted down to low: only ~10 lines duplicated, the function is small and self-contained, and the recommended fix (c(siteFields, sysFields) plus a default-config constant) is mechanical. A dedicated test file tests/testthat/test_getSiteInfo.R exists, keeping regression risk low and supporting the quick-win category.

### MISC-8 — HTML report tables are built by inline string concatenation duplicated across table-builder files

- **Location** `R/makeGeneticSummaryTable.R:57-92` · **Severity** low · **Category** quick-win · **Regression risk** low
- **Cluster** MISC (Package Infra, Options & Remaining Utilities)

**Evidence:** makeGeneticSummaryTable() assembles an HTML table via a large paste0() of literal '<table>...</tr>...' fragments and repeats a 6-cell row twice (mean kinship row 72-79, genome uniqueness row 80-88) using an inline fmt() closure (51-54). makeFounderStatsTable() independently builds the same class of '<table class="table table-condensed ...">' markup by paste0 with per-field is.null defaulting (makeFounderStatsTable.R:67-88). The HTML structure, CSS classes, and N/A formatting are duplicated between the two files with no shared row/cell builder.

**Recommendation:** Provide small shared HTML helpers (e.g. htmlTable(headers, rows) and a formatValue helper) and have both table makers supply only data. Removes repeated markup and centralizes styling/escaping for future report tables.

**Verifier:** Confirmed: makeGeneticSummaryTable.R builds an HTML table via paste0() of literal '<table class="table table-condensed table-bordered">...</tr>' fragments (lines 57-91), with a local fmt() closure (51-54) and two near-identical 6-cell data rows (72-78 mean kinship, 80-88 genome uniqueness). makeFounderStatsTable.R independently builds the same class of '<table class="table table-condensed table-striped">' markup by paste0 (67-88) with per-field is.null defaulting (44-64) and inline ifelse is.na 'N/A' formatting (83-84); a third file makeRelationClassesTable.R repeats the same pattern. The duplication of structure, CSS classes, and N/A formatting with no shared row/cell helper is real. Severity lowered to low: pure cosmetic report markup, low blast radius, and the recommended htmlTable()/formatValue() helpers are a genuine quick-win. Note tests/testthat/test_modFounderStats.R exercises these builders, so a refactor is verifiable.

### Cluster: XDRY — Cross-Package Duplication (DRY)

### XDRY-6 — Factor/character coercion of date and id/parent columns scattered instead of using converters

- **Location** `R/qcStudbook.R:200-207` · **Severity** low · **Category** quick-win · **Regression risk** low
- **Cluster** XDRY (Cross-Package Duplication (DRY))

**Evidence:** qcStudbook.R:200-207 individually coerces ped$sire/ped$dam/ped$id via toCharacter and then re-coerces some via as.character (lines 206-207 repeat as.character on sire/dam already converted at 200-201), and convertDate.R:8-20 / calculateAge.R:24-28 each repeat the same is.factor->as.character defensive coercion before working with values. The 'if factor then as.character' guard is reimplemented inline in convertDate (12-14), calculateAge (via convertDate), toCharacter (13-14), and convertSexFactorToCharacter (9-10).

**Recommendation:** Route all factor->character defensive coercion through the existing toCharacter/convertSexFactorToCharacter helpers (or a shared asCharacterIfFactor scalar helper) and remove the redundant double-coercion in qcStudbook.R:206-207. Low risk, removes dead/duplicate coercion lines and one shared guard.

**Verifier:** low-severity: passed through without adversarial check

## 3. Extensibility

### Cluster: QC — Quality Control & Validation

### QC-9 — Magic year-length 365.25 duplicated for age math

- **Location** `R/checkParentAge.R:30-33` · **Severity** low · **Category** quick-win · **Regression risk** low
- **Cluster** QC (Quality Control & Validation)

**Evidence:** Parent-age computation divides day differences by the literal 365.25 at checkParentAge.R lines 31 and 33 (and again in the dead legacy copy at 84/96), and the same constant appears in addPedigreeYears.R line 45 (addPedigreeYearsWithAge). The minimum-age threshold itself is parameterized (minParentAge) but the days-per-year conversion factor is not centralized.

**Recommendation:** Define a single DAYS_PER_YEAR constant (or a yearsBetween() helper) and reuse it wherever ages are derived from date differences.

**Verifier:** low-severity: passed through without adversarial check

### QC-10 — LabKey schema/query and container filter baked into getApprovedSiteInfo

- **Location** `R/getApprovedSiteInfo.R:21-28` · **Severity** low · **Category** quick-win · **Regression risk** low
- **Cluster** QC (Quality Control & Validation)

**Evidence:** getApprovedSiteInfo hardcodes schemaName='study', queryName='Assignment', containerFilter='CurrentAndSubfolders' (lines 24-27), and the filter column 'Id' in makeApprovedFilter (line 34). The same literal block is repeated verbatim in the dead getApprovedSiteInfoInline (47-54) and getApprovedSiteInfoBatched (70-77). Supporting a different EHR layout or query requires editing the function body.

**Recommendation:** Promote schemaName/queryName/containerFilter/filter column to parameters (with current values as defaults) or read them from config, so the query target is configurable without code edits.

**Verifier:** low-severity: passed through without adversarial check

### Cluster: LOOP — Loops & Offspring Traversal

### LOOP-5 — findLoops boolean accumulation written as an if/else assigning literals instead of vectorized logical

- **Location** `R/findLoops.R:34-40` · **Severity** low · **Category** quick-win · **Regression risk** low
- **Cluster** LOOP (Loops & Offspring Traversal)

**Evidence:** for (id in ids) { if (makesLoop(id, ptree)) { loops[[id]] <- TRUE } else { loops[[id]] <- FALSE } } assigns the literal result of a predicate via a 5-line if/else. The else branch is pure boilerplate: loops[[id]] could simply receive makesLoop(id, ptree) directly. The pre-allocated list + per-element assignment also prevents vectorization and obscures that the output is just sapply over the predicate.

**Recommendation:** Replace the loop body with loops[[id]] <- makesLoop(id, ptree), or replace the whole function body with as.list(vapply(ids, makesLoop, logical(1), ptree = ptree)) (preserving names). Removes the redundant branch and clarifies intent.

**Verifier:** Lines 34-40 of R/findLoops.R contain exactly the claimed if/else assigning literal TRUE/FALSE from makesLoop(id, ptree); the else branch is pure boilerplate collapsible to loops[[id]] <- makesLoop(id, ptree). It is a genuine readability/extensibility nit (low impact, not medium — purely cosmetic, no behavioral or maintenance cost beyond a few redundant lines). Test coverage in test_findLoops.R and test_countLoops.R exercises findLoops and checks its named-list output, so a quick-win refactor carries low regression risk; vapply/as.list rewrite would need to preserve names, which the simpler in-loop assignment avoids.

### LOOP-6 — getOffspring docstring describes 'ancestor IDs' but function returns offspring (stale/misleading abstraction contract)

- **Location** `R/getOffspring.R:6-8` · **Severity** low · **Category** quick-win · **Regression risk** low
- **Cluster** LOOP (Loops & Offspring Traversal)

**Evidence:** The @return roxygen states 'A character vector containing all of the ancestor IDs for all of the IDs provided' (lines 6-8), but the implementation (lines 19-26) selects ped rows whose sire or dam is in ids, i.e. it returns OFFSPRING, not ancestors. The doc was apparently copy-pasted from getAncestors. This misdescribes the contract for any future caller relying on the documented behavior.

**Recommendation:** Correct the @return text to describe offspring IDs. Low code risk but it removes a documentation trap that increases the cost of correctly reusing this traversal primitive.

**Verifier:** low-severity: passed through without adversarial check

### LOOP-7 — getFocalAnimalPed hardcodes file-format strings and date format literal, limiting input-source extensibility

- **Location** `R/getFocalAnimalPed.R:36-80` · **Severity** low · **Category** quick-win · **Regression risk** low
- **Cluster** LOOP (Loops & Offspring Traversal)

**Evidence:** Format dispatch hardcodes c("xls", "xlsx") (line 36); read.csv hardcodes na.strings = c("", "NA") and check.names = FALSE (lines 48-49); date reformatting hardcodes format = "%Y-%m-%d" three times (lines 78-80). Adding a new input format (e.g. tab-delimited, parquet) or changing the date format requires editing this monolith in multiple spots; the date-format literal is repeated three times.

**Recommendation:** Hoist the date format string and NA-string set to named constants (or function args with defaults) and factor the format-dispatch into a lookup of {extension -> reader}. Keeps the assumptions in one declarative place and opens a seam for additional source types.

**Verifier:** low-severity: passed through without adversarial check

### Cluster: KIN — Kinship & Relatedness Math

### KIN-6 — Effective-number-of-founders statistic 1/sum(p^2) inlined instead of a shared seam

- **Location** `R/calcFEFG.R:82` · **Severity** low · **Category** quick-win · **Regression risk** low
- **Cluster** KIN (Kinship & Relatedness Math)

**Evidence:** The effective-number form `1/sum(p^2)` (FE) and `1/sum((p^2)/r)` (FG) are written inline at calcFE.R:79, calcFG.R:92, and calcFEFG.R:82. Because the formula is embedded in three function bodies rather than a named helper, a definitional refinement (e.g. excluding zero-contribution founders, or guarding sum==0) must be applied three times and cannot be unit-tested in isolation. KIN-1's duplication is the root; this is the specific arithmetic that should become the explicit extensibility seam.

**Recommendation:** Introduce `founderEquivalents(p) <- 1/sum(p^2)` and `founderGenomeEquivalents(p, r) <- 1/sum((p^2)/r, na.rm=TRUE)` and call them from all three functions. Single definition point for the diversity metrics.

**Verifier:** Confirmed. The effective-number forms are inlined exactly as claimed: calcFEFG.R:82 has `list(FE = 1L / sum(p^2L), FG = 1L / sum((p^2L) / r, na.rm = TRUE))`, calcFE.R:79 has `1L / sum(p^2L)`, and calcFG.R:92 has `1L / sum((p^2L) / r, na.rm = TRUE)`. All three cited line numbers are accurate. Extracting `founderEquivalents(p)`/`founderGenomeEquivalents(p, r)` is a genuine, low-risk single-point-of-definition improvement, and dedicated tests exist (test_calcFE.R, test_calcFG.R, test_calcFEFG.R) so refactoring is well-guarded, confirming quick-win. Severity lowered from medium to low: the finding self-identifies as a sub-aspect of KIN-1's duplication and the seam is a trivial one-line arithmetic expression with modest real impact. (Note: also fixes a doc/code mismatch where the legacy `1/sum(p^2)` differs cosmetically from the integer-literal `1L/sum(p^2L)` actually used.)

### KIN-7 — Mendelian 1/2 transmission factor is a bare magic literal repeated across the cluster

- **Location** `R/kinship.R:98` · **Severity** low · **Category** quick-win · **Regression risk** low
- **Cluster** KIN (Kinship & Relatedness Math)

**Evidence:** The diploid parental-contribution halving `/ 2L` appears unnamed in kinship.R:98-99 (`(kmat[mom,] + kmat[dad,]) / 2L` and `(1L + kmat[mom,dad]) / 2L`), calcFE.R:71 / calcFG.R:83 / calcFEFG.R:73 (`(d[sire,] + d[dam,]) / 2L`), and is implicit in chooseAlleles.R:17 (`sample(c(0L,1L), ..., replace=TRUE)`, a 50/50 draw). The genetic meaning (1/2 = probability a given parental allele is transmitted, diploid assumption) is opaque at each site and cannot be varied for non-diploid analyses.

**Recommendation:** Name the constant once (e.g. an internal `MENDELIAN_HALF <- 0.5` or a documented comment block) and reference it, or at minimum add a one-line comment at each recurrence explaining the /2 is the diploid transmission average. Low-risk readability + future-ploidy seam.

**Verifier:** CONFIRMED on re-read (correcting a prior erroneous "blocked" submission). Code at kinship.R:98-99 matches verbatim: `(kmat[mom,] + kmat[dad,]) / 2L` and `(1L + kmat[mom,dad]) / 2L`; the same bare `/ 2L` Mendelian halving also recurs at kinship.R:76 & :78 (uncited but supportive), and identically at calcFE.R:71, calcFG.R:83, calcFEFG.R:73, with the implicit 50/50 draw at chooseAlleles.R:17. None of these sites name or comment the diploid-transmission meaning, so the finding is real. Severity adjusted to low: 0.5 is a universally understood Mendelian constant and the "future non-diploid" seam is speculative for this rhesus-colony package, so impact is purely readability. Quick-win is correct: dedicated tests exist (test_kinship.R, test_calcFE.R, test_calcFG.R, test_calcFEFG.R, test_chooseAllelesChar.R) and a comment/named-constant change does not alter behavior, making regression risk low.

### KIN-9 — calcRetention hardcodes the target cohort to the ped$population column

- **Location** `R/calcRetention.R:27` · **Severity** low · **Category** quick-win · **Regression risk** low
- **Cluster** KIN (Kinship & Relatedness Math)

**Evidence:** calcRetention() selects descendants solely via `ped$population` (calcRetention.R:27) with no parameter to vary the cohort, while the docstring (lines 7-8) speaks generally of the population. There is no seam to compute retention against, e.g., living animals only or an arbitrary subset, and calcFG/calcFEFG (which call calcRetention at calcFG.R:91 / calcFEFG.R:81) inherit this rigidity.

**Recommendation:** Add an optional `target` parameter defaulting to `ped$population` so the cohort is injectable, and align the docstring with the `population`-column semantics. Low risk, additive.

**Verifier:** low-severity: passed through without adversarial check

### Cluster: GRP — Breeding Group Formation

### GRP-3 — Sex codes hardcoded as bare "M"/"F" literals in group-formation eligibility logic

- **Location** `R/getPotentialSires.R:22-23` · **Severity** low · **Category** quick-win · **Regression risk** medium
- **Cluster** GRP (Breeding Group Formation)

**Evidence:** getPotentialSires() filters with the bare literal `ped$sex == "M"` (line 22). Likewise groupAddAssign() defaults `ignore = list(c("F", "F"))` (line 123) to ignore female-female kinship. These literals are scattered rather than referenced from a single source of truth; the package separately has convertSexCodes.R, indicating multiple sex-code vocabularies exist. Supporting an alternate coding (LabKey 'male'/'female', numeric, or adding categories) requires editing each literal individually.

**Recommendation:** Introduce named constants (e.g. SEX_MALE <- "M", SEX_FEMALE <- "F") or a small lookup consulted by getPotentialSires and the groupAddAssign 'ignore' default, giving one normalization seam. Pairs with the existing convertSexCodes() ingest step.

**Verifier:** Confirmed: R/getPotentialSires.R line 22 contains the bare literal `ped$sex == "M"` in the eligibility filter, exactly as claimed, and convertSexCodes.R exists confirming a separate sex-code normalization vocabulary. The line number is accurate (the "M" literal is on line 22; line 23 is just the continuation of the same expression). Severity reduced from high to low: this is a maintainability/single-source-of-truth nit, not a correctness or behavioral defect — sex is normalized to "M"/"F" internally at ingest (the convertSexCodes seam), so the bare literal is consistent with the package's internal convention and an alternate coding would be handled at the ingest layer, not here. Category quick-win is correct: introducing a named constant touches one literal with low regression risk and group-formation/sex paths are covered by tests (test_groupAddAssign.R, test_convertSexCodes.R, test_modBreedingGroups_groupAddAssign.R). Note: the secondary claim about groupAddAssign() defaulting `ignore = list(c("F","F"))` at line 123 could not be independently confirmed because follow-up tool calls were blocked by plan-mode; the primary cited location stands on its own.

### GRP-5 — Magic kinship threshold and minAge defaults baked into signatures rather than centralized config

- **Location** `R/groupAddAssign.R:123-126` · **Severity** low · **Category** overhaul · **Regression risk** medium
- **Cluster** GRP (Breeding Group Formation)

**Evidence:** groupAddAssign() hardcodes default `threshold = 0.015625` (line 123, the third-degree-relative kinship cutoff), `minAge = 1.0` (line 124), `iter = 1000L` (line 124), and `sexRatio = 0.0` (line 126) directly in the parameter defaults. These genetics/management constants are duplicated in the Roxygen docs and are not drawn from a shared configuration, so a site or species needing different thresholds must override at every call site.

**Recommendation:** Centralize these defaults in a single config/getter (e.g. getParamDef-style, which already exists in the package) so the breeding-group thresholds have one authoritative source and can be made species-aware later.

**Verifier:** Confirmed: lines 123-126 of R/groupAddAssign.R hardcode threshold=0.015625, minAge=1.0, iter=1000L, and sexRatio=0.0 directly in the signature defaults, and these are repeated verbatim in the Roxygen docs (lines 43, 50, 52). The same 0.015625 / minAge defaults are duplicated across many sibling functions (filterThreshold.R, filterAge.R, getAnimalsWithHighKinship.R, fillGroupMembersWithSexRatio.R, addAnimalsWithNoRelative.R, getPotentialSires.R), so the duplication/extensibility concern is real and the getParamDef getter does exist in the package (getParamDef.R). However, severity is overstated: these are stable, well-documented genetics constants overridable at the call site, not a defect, so low is fairer than medium. Category overhaul is correct: centralizing would require touching ~6+ exported functions plus their Roxygen and the breeding-group test suite, carrying real regression risk -- not a quick win. Note getParamDef is a LabKey token-config helper, not a numeric-default registry, so the recommendation needs a new mechanism rather than reusing it as-is.

### GRP-7 — setPopulation overloads empty-ids to mean 'whole population is TRUE', an implicit baked-in convention

- **Location** `R/setPopulation.R:31-35` · **Severity** low · **Category** quick-win · **Regression risk** medium
- **Cluster** GRP (Breeding Group Formation)

**Evidence:** setPopulation() treats `length(ids) == 0L` as a signal to flag the ENTIRE pedigree as population (line 32: `ped$population <- TRUE`), otherwise flags only matching ids (line 34). This overloaded empty-input semantics is an implicit, undocumented-in-signature convention that downstream group-formation code depends on; a caller passing an empty candidate set silently gets the opposite of an empty population.

**Recommendation:** Make the 'empty means all' behavior explicit via a named argument (e.g. emptyMeansAll = TRUE) or a separate function, so the assumption is visible at the call site and can be changed without surprising group-formation callers.

**Verifier:** low-severity: passed through without adversarial check

### Cluster: GENO — Genotype & Excel I/O

### GENO-5 — Positional column access (cols[2:3], [,2L]/[,3L], 2L:3L) hardcodes column ORDER, not just names

- **Location** `R/addGenotype.R:24-34` · **Severity** medium · **Category** quick-win · **Regression risk** medium
- **Cluster** GENO (Genotype & Excel I/O)

**Evidence:** addGenotype derives the allele columns purely by position: `genotypeNames <- names(genotype)[2L:3L]` (24), then indexes `genotype[, 2L]`/`genotype[, 3L]` (32-33). checkGenotypeFile likewise loops `for (i in 2L:3L)` (47) and rebuilds names as `c("id", cols[2L:length(cols)])` (65). This assumes the two alleles are always physically columns 2 and 3 in that order. Any reordering, an extra metadata column inserted before the alleles, or a multi-marker file silently produces wrong encodings rather than an error.

**Recommendation:** Select allele columns by name (or by the schema accessor from GENO-1) rather than by ordinal position, and validate that the expected named columns exist before indexing. This decouples correctness from physical column order and is a prerequisite for supporting more than one marker.

**Verifier:** Confirmed against the actual R/addGenotype.R (full file returned with line numbers). Line 24 `genotypeNames <- names(genotype)[2L:3L]` selects allele columns purely by position, and lines 32-33 index `genotype[, 2L]`/`genotype[, 3L]` with hardcoded ordinals (not even via the named lookup), so reordering, an inserted metadata column, or a multi-marker file silently yields wrong integer encodings rather than an error. The 24-34 range accurately brackets the offending code (function body 23-37). Severity medium is fair (real extensibility/correctness issue, but mitigated within the intended pipeline since the docstring at lines 20-21 states genotype comes pre-validated from checkGenotypeFile). Quick-win is correct: the fix is name-based column selection plus an existence check, localized to one short function, with test_addGenotype.R present to guard regressions. Note: I could not re-read checkGenotypeFile.R (lines 47/65) under the read-only/plan-mode constraints, but those are corroborating detail; the primary cited evidence in addGenotype.R is fully verified.

### GENO-10 — readExcelPOSIXToCharacter detects date columns by substring-matching the class string 'POSIX'

- **Location** `R/readExcelPOSIXToCharacter.R:20-24` · **Severity** low · **Category** quick-win · **Regression risk** low
- **Cluster** GENO (Genotype & Excel I/O)

**Evidence:** Date/time columns are detected by collapsing each column's class vector to a string and substring-matching: `cols <- vapply(pedigree, function(col) stri_c(class(col), collapse = ""), character(1L))` (20-22), then `names(cols)[stri_detect_fixed(cols, "POSIX")]` (23). This is a stringly-typed, fragile way to identify temporal columns (and is moot given `col_types = "text"` on the read_excel call at 16, which already forces all columns to character — so the POSIX branch may never fire). The function name says 'pedigree' but it is the genotype Excel reader (called from getGenotypes line 24).

**Recommendation:** Detect temporal columns with `inherits(col, c("POSIXct", "POSIXt", "Date"))` instead of substring-matching a stringified class, and verify whether the POSIX conversion is reachable at all given col_types='text'; if unreachable, simplify the function. Consider renaming the internal variable from 'pedigree' to 'data' for accuracy.

**Verifier:** low-severity: passed through without adversarial check

### Cluster: APP — Shiny Application & Modules

### APP-9 — ONPRC-vs-other UI branched by duplicated navbarPageArgs lists instead of conditional tab assembly

- **Location** `inst/application/ui.r:16-42` · **Severity** low · **Category** quick-win · **Regression risk** low
- **Cluster** APP (Shiny Application & Modules)

**Evidence:** ui.r builds navbarPageArgs twice: the if (getSiteInfo()$center == 'ONPRC') branch (18-29) and the else branch (31-41) are identical tab lists except the ONPRC branch sources uitpOripReporting.R (17) and carries a commented-out reference (26). The hardcoded center string 'ONPRC' gates UI and the whole arg list is copy-pasted, so adding any new tab requires editing both branches.

**Recommendation:** Build one base list of tabs, then conditionally append site-specific tabs (e.g. if center == ONPRC append uitpOripReporting) before do.call(navbarPage, ...). Consider a site->tabs registry for additional centers.

**Verifier:** CONFIRMED after re-reading the source (my first StructuredOutput call was filed in error during a transient empty-output glitch). ui.r lines 16-42 build navbarPageArgs twice: the if (getSiteInfo()$center == "ONPRC") branch (18-29) sources uitpOripReporting.R at line 17 and carries a commented-out reference at line 26, while the else branch (31-41) is an otherwise identical tab list. The whole arg list is copy-pasted and gated on a hardcoded center string, so adding a tab requires editing both branches. Line range is exact. Notably the ONPRC-specific tab is itself commented out (line 26), so the two branches currently render identical UIs, which is why I lowered severity from medium to low. quick-win is correct: it is a ~25-line localized refactor with low regression risk; there is no test covering ui.r navbarPage assembly in tests/testthat (only modules and getSiteInfo/modSiteConfig), but the change is purely a list-construction simplification with no behavior change.

### APP-10 — globalMinParentAge mutated via <<- from inside a reactive, creating hidden global coupling; MAXGROUPS underused

- **Location** `inst/application/server.r:73-73` · **Severity** medium · **Category** overhaul · **Regression risk** medium
- **Cluster** APP (Shiny Application & Modules)

**Evidence:** Line 73 globalMinParentAge <<- minParentAge writes the global declared in inst/application/global.R line 3 (globalMinParentAge <- 3.0) from within getSelectedBreeders; it is later read in textMinParentAge (1064) and bg() (1141). Cross-reactive communication via a mutable global defeats Shiny's reactive graph, is order-dependent, and is untestable in isolation. global.R also defines MAXGROUPS (line 4); it is referenced only in the UI fragment uitpBreedingGroupFormation.R (lines 108, 191) while server loops use input$numGp (1020, 1038, 1203) -- the constant is not enforced server-side.

**Recommendation:** Replace the global with reactiveVal(minParentAge) in server scope and read it reactively; remove the <<-. Enforce MAXGROUPS as the numGp upper bound server-side or remove if redundant.

**Verifier:** Confirmed: line 73 mutates the package-global globalMinParentAge via <<- from inside the getSelectedBreeders reactive (defined in global.R as globalMinParentAge <- 3.0), and it is read elsewhere in server.r (textMinParentAge / bg), so state flows through a mutable global rather than the reactive graph -- order-dependent and not testable in isolation. This is a real extensibility/coupling defect. Severity medium is fair (functionally works today but couples reactives). Category overhaul is correct: there is no test coverage for these Shiny app server reactives in tests/testthat, the global is read from multiple sites, and converting to reactiveVal touches cross-reactive flow, so regression risk is non-trivial. The MAXGROUPS-underused observation is a secondary, weaker point but does not undermine the core <<- finding.

### APP-17 — inst/application/modPyramid.R is a dead placeholder stub diverging from the real R/modPyramid.R

- **Location** `inst/application/modPyramid.R:23-33` · **Severity** low · **Category** quick-win · **Regression risk** low
- **Cluster** APP (Shiny Application & Modules)

**Evidence:** modPyramidServer (23-33) does req(pedigree_data()); input$generate; plot(1:10, main='Age-Sex Pyramid Plot') -- it never uses the age_unit/age_bin inputs from its own UI (9-11) and never calls getPyramidPlot. The real, fully-wired implementation lives in R/modPyramid.R (84-153) using getPyramidPlot with binWidth/ageUnit/colorScheme/showCounts/ageLabelCex. The stub uses a different param name (pedigree_data vs pedigreeData) and is not referenced by ui.r's navbarPageArgs, so it is dead code that misleads about the pyramid path.

**Recommendation:** Delete inst/application/modPyramid.R (and example_1.R, which references a nonexistent create_sample_pedigree and pyramidResults$living_count) or reconcile them with R/modPyramid.R. Keeps a single authoritative pyramid implementation.

**Verifier:** low-severity: passed through without adversarial check

### Cluster: MISC — Package Infra, Options & Remaining Utilities

### MISC-5 — Code-standardization helpers hardcode synonym sets and output levels inline, one block per output value

- **Location** `R/convertSexCodes.R:33-47` · **Severity** low · **Category** quick-win · **Regression risk** medium
- **Cluster** MISC (Package Infra, Options & Remaining Utilities)

**Evidence:** convertSexCodes() assigns standardized values via one membership test per code: sex[sex %in% c("MALE","M","1")] <- "M" etc. (lines 37-45) with factor levels hardcoded at line 46. convertStatusCodes() follows the identical pattern (convertStatusCodes.R:25-34). getIndianOriginStatus() repeats length(origin[stri_detect_fixed(origin, "<CODE>")]) seven times (getIndianOriginStatus.R:18-24) then bands to red/yellow/green (35-44). convertAncestry() likewise hardcodes grepl token tests and levels (convertAncestry.R:22-44). Each new sex/status/ancestry synonym or category requires editing imperative code rather than a data map, and the M/F/U/H, ALIVE/DECEASED/SHIPPED/UNKNOWN, CHINESE/INDIAN/... vocabularies are embedded in three separate files.

**Recommendation:** Represent each standardization as a named synonym->canonical map (named character vector or list) plus a levels vector, and write one generic applyCodeMap(x, map, levels) helper reused by sex/status/ancestry. New synonyms become data edits; the banding-to-color logic (shared with MISC-3) can reuse the same bandColor helper.

**Verifier:** Confirmed against source: convertSexCodes.R lines 37-46 use one `sex[sex %in% c(...)] <- "X"` membership test per output code with hardcoded factor levels at line 46, and convertStatusCodes.R (25-34), getIndianOriginStatus.R (18-24,35-44), and convertAncestry.R (22-44) repeat the inline-vocabulary pattern, so the extensibility claim is real (the cited 33-47 is essentially the whole function body 33-48). Severity downgraded to low because the code is small, readable, the synonym/level vocabularies are stable biological domains, and a single applyCodeMap generic would over-generalize three genuinely different matching semantics (exact set membership in sex/status vs substring stri_detect in getIndianOriginStatus vs conjunctive grepl logic like chinese = 'chin' AND NOT 'ind' in convertAncestry). Category set to quick-win for the convert* functions specifically because dedicated tests exist (test_convertSexCodes.R, test_convertStatusCodes.R, test_convertAncestry.R, test_getIndianOriginStatus.R) and the functions are pure, making a per-function data-map refactor low-risk.

### MISC-6 — fixColumnNames is a long fixed sequence of gsub+colChange steps that hardcodes every alias mapping

- **Location** `R/fixColumnNames.R:19-67` · **Severity** low · **Category** overhaul · **Regression risk** medium
- **Cluster** MISC (Package Infra, Options & Remaining Utilities)

**Evidence:** fixColumnNames() is a 49-line straight-line pipeline that hand-codes each normalization step and stores its diff into a distinct errorLst$changedCols$<name> slot: case-lower, remove space/period/underscore, then nine literal gsub remaps (egoid->id, ego->id, sireid->sire, damid->dam, birthdate->birth, deathdate->death, recordstatus->recordStatus, fromcenter->fromCenter, geographicorigin->geographicOrigin) at lines 40-66, with two ad-hoc firstname/secondname fixups (31-36) interrupting the flow. Each new alias requires adding both a gsub line and a matching changedCols slot, and the slot names are tightly coupled to the ~16 addErrTxt blocks in summary.nprcgenekeeprErr.R (MISC-2).

**Recommendation:** Drive the alias remapping from a data table of (fromPattern, toName, changeSlotName) iterated in a loop that performs the gsub and records the colChange. This makes column aliases declarative and keeps fixColumnNames and the summary reporter in sync via a shared mapping.

**Verifier:** Confirmed against source read in full: R/fixColumnNames.R lines 19-67 are exactly the described 49-line straight-line pipeline (tolower at 20-21, three structural gsub at 22-28, nine literal alias gsub remaps egoid/ego/sireid/damid/birthdate/deathdate/recordstatus/fromcenter/geographicorigin at 40-66) each paired with a distinct errorLst$changedCols$<name> slot via colChange, with ad-hoc firstname/secondname fixups interrupting at 31-36. Every new alias indeed requires both a gsub line and a matching slot name, so the extensibility concern is real and the line range is accurate. Severity lowered to low: the duplication is bounded (~16 fixed colony-pedigree aliases that change very rarely), each step is self-contained and trivially correct, and there is no defect or perf cost — it is mild maintenance friction, not a medium-impact problem. Category overhaul is fair because the function is exported with roxygen examples and the slot names are consumed by the summary/changedCols reporting path, so a table-driven rewrite carries non-trivial regression risk (the firstname/secondname ordering quirk relative to underScoreRemoved at line 38 must be preserved).

### MISC-9 — getLogo has identical if/else branches, a dead conditional that pretends to be center-specific

- **Location** `R/getLogo.R:28-36` · **Severity** low · **Category** quick-win · **Regression risk** low
- **Cluster** MISC (Package Infra, Options & Remaining Utilities)

**Evidence:** getLogo() branches on getSiteInfo()$center == "SNPRC" but the if-block (lines 29-31) and the else-block (lines 33-35) assign exactly the same values: logo$file <- file.path("..", "nprcgenekeepr_2_color_logo.jpg"); height 200L; width 350L. The conditional is dead and misleadingly implies per-center logos; the filename and dimensions are hardcoded.

**Recommendation:** Drop the dead branch and assign the logo once; if per-center branding is intended, drive file/height/width from a per-center config map (re-using the site-info structure) rather than a no-op if/else.

**Verifier:** low-severity: passed through without adversarial check

### MISC-12 — Configuration file location hardcodes OS detection, HOME, and dotfile names with no override seam

- **Location** `R/getConfigFileName.R:15-23` · **Severity** low · **Category** quick-win · **Regression risk** low
- **Cluster** MISC (Package Infra, Options & Remaining Utilities)

**Evidence:** getConfigFileName() inlines the only config-location authority: Sys.getenv("HOME") for the home dir (line 16), a single stri_detect_fixed(toupper(sysname), "WIND") OS test (line 17), and the literal filenames "_nprcgenekeepr_config" (Windows, 18) vs ".nprcgenekeepr_config" (POSIX, 20). There is no environment-variable override (e.g. NPRCGENEKEEPR_CONFIG) and the package-name component of the filename is a string literal rather than derived, so supporting a new platform or an explicit config path requires editing this branch.

**Recommendation:** Honor an explicit env-var/argument override first, then fall back to the HOME-based default; express the platform->dotfile-prefix choice as a tiny lookup and derive the package name once. Single seam for future platforms and test overrides.

**Verifier:** low-severity: passed through without adversarial check

### Cluster: XARCH — Cross-Cutting Extensibility & Architecture

### XARCH-1 — Two coexisting, divergent Shiny apps (legacy monolith + modular) both shipped

- **Location** `R/runModularApp.R:38-44` · **Severity** high · **Category** overhaul · **Regression risk** high
- **Cluster** XARCH (Cross-Cutting Extensibility & Architecture)

**Evidence:** The package exports BOTH runGeneKeepR (R/runGenekeepr.R:18-29 -> shiny::runApp(system.file('application')) -> inst/application/server.R [1304 lines] + ui.R) and runModularApp (R/runModularApp.R:38-44 -> shinyApp(appUI(), appServer)). The same six feature areas exist twice: inline in the monolith and as mod* modules (modInput/modPedigree/modPyramid/modGeneticValue/modSummaryStats/modBreedingGroups). There is even a stale duplicate inst/application/server.r (lowercase) alongside server.R. Any new app feature or bug fix must be decided/applied in one of two worlds, and they have already drifted (e.g. monolith uses shinyBS popovers + insertTab on a navbarMenu 'tab_pages'; modular uses appServer dynamic-tab logic on 'mainNavbar').

**Recommendation:** Declare the modular app (runModularApp/appServer/appUI/mod*) canonical. Reach feature parity, add shinytest2 coverage (already in Suggests), then delete inst/application/server.R+ui.R (and the stray server.r/ui.r) and make runGeneKeepR a thin alias to runModularApp with a lifecycle deprecation. Removes the duplicate-maintenance tax that is the single biggest friction for adding features.

**Verifier:** Confirmed: R/runModularApp.R:38-44 launches shinyApp(appUI(), appServer) while R/runGenekeepr.R:18-29 exports runGeneKeepR launching the monolith at inst/application (server.R=1304 lines, ui.R=1631 lines); both are @export'ed. All six feature areas exist twice (modInput/modPedigree/modPyramid/modGeneticValue/modSummaryStats/modBreedingGroups vs inline monolith), the apps have genuinely drifted (monolith uses 24 shinyBS calls + insertTab on navbarMenu 'tab_pages'; modular uses insertTab on navbarPage id 'mainNavbar'), and the stray inst/application/server.r (a 49-line stale histogram demo) and ui.r (1631-line stale copy) both exist. Severity 'high' and category 'overhaul' are fair: deleting the monolith carries high regression risk, but it is mitigated since the modular path has broad tests (test-appServer.R, test-mod* for every module/helper) and shinytest2 is already in DESCRIPTION Suggests (line 58), while the monolith has essentially no direct test coverage.

### XARCH-2 — Module contract is implicit and inconsistent across mod*Server return shapes

- **Location** `R/appServer.R:100-287` · **Severity** medium · **Category** overhaul · **Regression risk** medium
- **Cluster** XARCH (Cross-Cutting Extensibility & Architecture)

**Evidence:** Modules follow modXUI(id)/modXServer(id, <reactives>) by convention, but the inter-module data shape is ad hoc and renamed at boundaries. modGeneticValueServer returns reportGV columns renamed (indivMeanKin->meanKinship, gu->genomeUniqueness) (modGeneticValue.R:262-267) specifically so modSummaryStatsServer can read them (modSummaryStats.R:534-536), while modBreedingGroupsServer re-derives kinship itself (modBreedingGroups.R:128-142) because kinshipMatrix is passed as NULL in appServer.R:278. appServer wraps every cross-module read in tryCatch(...) returning NULL (appServer.R:108-111, 122, 168-170) to defend against shape mismatches. No single document or helper defines what a module receives or returns.

**Recommendation:** Write one module contract: modXUI(id) returns a tagList; modXServer(id, <named reactive inputs>) returns a named list of reactives over a stable vocabulary (pedigree, gvReport, kinship, errors). Standardize column names once at the source (reportGV) instead of renaming per consumer, and pass the real kinship matrix to summary/breeding modules. Make modInput the reference implementation and capture the contract in an architecture note.

**Verifier:** All five code citations verified against source: appServer.R:278 passes kinshipMatrix=NULL to modSummaryStatsServer, lines 282-286 call modBreedingGroupsServer with no kinship arg, and lines 108-111/122/168-170 wrap every cross-module reactive read in tryCatch(...->NULL); modGeneticValue.R:261-268 renames indivMeanKin->meanKinship and gu->genomeUniqueness with the literal comment 'standard names expected by other modules', which modSummaryStats.R:533-536 consumes, while modBreedingGroups.R:128-142 re-derives kinship via a getKinshipMatrix fallback. The implicit, inconsistently-handled contract (two consumers handle the missing kinship matrix two different ways; renaming done at a consumer rather than at the source reportGV; blanket tryCatch silently swallows shape mismatches) is a genuine extensibility defect, and grep of tests/testthat found no tests asserting the column-name or kinship-passing contract, so overhaul (not quick-win) is correct given the uncaught regression risk. Severity lowered to medium: impact is confined to a 9-module internal Shiny app at a single research center with a small fixed module set, not a public extension surface, so 'high' overstates blast radius.

### XARCH-3 — Shiny progress callback leaks into core compute functions

- **Location** `R/reportGV.R:66-130` · **Severity** medium · **Category** quick-win · **Regression risk** low
- **Cluster** XARCH (Cross-Cutting Extensibility & Architecture)

**Evidence:** reportGV(ped, ..., updateProgress = NULL) and groupAddAssign(..., updateProgress = NULL) (groupAddAssign.R:119-127,181-183) accept a Shiny Progress closure and call it mid-computation (reportGV.R:98-130). The same callback threads further into geneDrop(), calcFG(), calcFEFG(), convertRelationships(). getMinParentAge.R is worse: a core helper calls shiny::renderText() on input$minParentAge (getMinParentAge.R body) and is marked @import shiny. This couples pure analysis code to the UI, contradicting the dual-use (script vs Shiny) design; a script caller must understand UI artifacts.

**Recommendation:** Replace updateProgress with a generic progress = function(value, message) hook defaulting to a no-op; adapt the Shiny Progress object to that hook in the module layer only. Delete getMinParentAge's shiny dependency (it should take a plain numeric, validated by the caller). Keep core R/ files free of any shiny:: reference so they stay testable and scriptable.

**Verifier:** Confirmed at cited locations: reportGV.R:66-67 accepts updateProgress=NULL and invokes the Shiny-oriented closure with named args (detail/value/reset) at lines 98-103, 109-114, 125-130, threading it into geneDrop(); groupAddAssign.R:127 and 181-183 do the same. getMinParentAge.R:9-16 is the worst offender: a core R/ helper marked @import shiny that takes a Shiny input and calls renderText(input$minParentAge), unusable from a script. Severity reduced high to medium because the progress callbacks are already a plain-function hook (grep confirms NO shiny:: symbol in reportGV.R or groupAddAssign.R; the module layer in modGeneticValue.R:121 and modBreedingGroups.R:192 already adapts Shiny to that contract), so the dual-use design is largely intact and a script caller can pass NULL/any function; and getMinParentAge appears unused in production (no caller in R/ or inst/application/). Quick-win is correct: changes are localized and covered by test_reportGV.R, test_groupAddAssign.R, test_convertRelationships.R, and test_getMinParentAge.R, giving low regression risk.

### XARCH-4 — Species parameters (sex codes, parent age) hardcoded across many files; no species profile

- **Location** `R/convertSexCodes.R:33-47` · **Severity** medium · **Category** overhaul · **Regression risk** medium
- **Cluster** XARCH (Cross-Cutting Extensibility & Architecture)

**Evidence:** Sex literals M/F/U/H are inline in convertSexCodes.R:37-46, getPotentialSires.R:22 (ped$sex == 'M'), calculateSexRatio.R:81, fillBins.R:23-27, filterPairs.R:33, modBreedingGroups.R:205 (ignore=list(c('F','F'))) and :292-293, modSummaryStats.R:606/616 (founder sex filters). The minimum-parent-age default 2 is repeated in qcStudbook.R:163, checkParentAge.R:38, modInput.R:337-342, and as the UI string '2.0' in modInput.R:121. There is no single species profile; supporting a new species (different sex coding, maturity age, gestation) requires editing roughly a dozen files and re-finding every literal.

**Recommendation:** Introduce one speciesProfile list (sexCodes, minParentAge, maxGestation, founderSexFilter) sourced from getParamDef/config, and have qcStudbook, checkParentAge, breeding-group, pyramid, and founder logic read from it. Thread minParentAge from a single source instead of re-defaulting it in three places.

**Verifier:** Confirmed. convertSexCodes.R:33-47 hardcodes the sex-code map (1/male->M, 2/female->F, default U) plus a hardcoded getValidSexValues c("M","F"); the cited range is accurate. The same M/F (and H) literals are independently inlined in getPotentialSires.R, calculateSexRatio.R, fillBins.R, filterPairs.R, modBreedingGroups.R (ignore=list(c("F","F")) and harem logic), and modSummaryStats.R founder filters. minParentAge default 2 is re-defaulted separately in qcStudbook.R, checkParentAge.R, modInput.R server, and as the UI string "2.0". No speciesProfile/getParamDef/config abstraction exists in R/ (only setPedigreeColumnDefaults.R, unrelated), so the coupling is real and unmitigated. Kept overhaul: the fix spans ~10 files including breeding-group/founder genetic logic. Lowered severity to medium: this is a single-species (rhesus) package with no second species on the roadmap, so the cost is latent extensibility rather than a current defect; relevant test files (convertSexCodes, checkParentAge, qcStudbook, fillBins, filterPairs, breeding groups) exist, which partially de-risks a future refactor.

### XARCH-5 — Rigid pipeline threads fat data frames keyed by string column names, no validated seam

- **Location** `R/qcStudbook.R:R/qcStudbook.R:24-56 (qcStudbook fn) and 168-191 (col helpers); getRequiredCols.R:15-17; getPossibleCols.R:15-22; getIncludeColumns.R:5-9; reportGV.R:70-77 (mergeReportColumns)` · **Severity** medium · **Category** overhaul · **Regression risk** medium
- **Cluster** XARCH (Cross-Cutting Extensibility & Architecture) _(auditor cited `163-276`; verifier corrected to `R/qcStudbook.R:24-56 (qcStudbook fn) and 168-191 (col helpers); getRequiredCols.R:15-17; getPossibleCols.R:15-22; getIncludeColumns.R:5-9; reportGV.R:70-77 (mergeReportColumns)`)_

**Evidence:** qcStudbook (276 lines) -> setPopulation/trimPedigree -> createPedTree.R:35-43 -> kinship.R + calcA.R -> reportGV.R -> groupAddAssign.R each assume the prior stage's exact columns (id/sire/dam/sex/birth/gen/population/pedNum). Coupling is purely by column-name string convention; getRequiredCols()/getPossibleCols()/getIncludeColumns() return three different hardcoded name lists (getRequiredCols.R:24, getPossibleCols.R:48-54, getIncludeColumns.R:14-18) that consumers must keep in sync by hand. reportGV.R:119 intersects getIncludeColumns() with names(ped) with no validation that required columns survived. Inserting a new analysis stage or swapping the kinship backend means touching every downstream caller.

**Recommendation:** Define a lightweight S3 'pedigree'/'gvReport' class carrying the data plus a columnMap and a validator; each stage accepts and returns it and validates at the boundary. Consolidate the three column-name lists into one schema definition. Gives clean, swappable seams without rewriting callers.

**Verifier:** Structural claim CONFIRMED: getRequiredCols/getPossibleCols/getIncludeColumns are three separate hand-maintained hardcoded lists, the pipeline (qcStudbook->setPopulation/trimPedigree->createPedTree->kinship/calcA->reportGV->groupAddAssign) couples purely via string-keyed ped$id/sire/dam/sex/gen/birth/population accesses with no S3 class or validated seam, and reportGV intersects getIncludeColumns() with names(ped) with no required-column validation. However the cited line numbers are wrong on nearly every reference: qcStudbook.R is 2580 lines (not 276) and the function is at 24-56 not 163-276; getRequiredCols at 15-17 not :24; getPossibleCols at 15-22 not :48-54; getIncludeColumns at 5-9 not :14-18; createPedTree is 27 lines (no :35-43); the reportGV intersection is at lines 71-72 not :119. Medium severity is fair (real extensibility friction, no acute bug). Overhaul is correct: the remediation touches every pipeline stage and consumer, and although each stage has tests, the broad blast radius makes regression risk medium as stated.

### XARCH-6 — Inconsistent error/return conventions force callers to special-case every function

- **Location** `R/qcStudbook.R:163-240` · **Severity** medium · **Category** overhaul · **Regression risk** medium
- **Cluster** XARCH (Cross-Cutting Extensibility & Architecture)

**Evidence:** qcStudbook returns either a cleaned data.frame OR an nprckeepErr/errorLst object depending on reportErrors (qcStudbook.R:271-275), and in non-report mode it writes a CSV to tempdir() and calls stop() on low parent age (qcStudbook.R:231-239) -- a side effect plus abort. Package-wide there are 46 stop(), 3 warning(), 20 return(NULL) sites. Consumers must handle all shapes: the monolith checks is.element('nprckeepErr', class(...)) (server.R:90) and wraps calls in tryCatch returning NULL (server.R:170-179); modInput.R:344-357 calls qcStudbook AND runQcStudbook separately and falls back to getEmptyErrorLst() on error/warning. Composing these functions for a new feature is high-friction.

**Recommendation:** Standardize on one result contract: return an object with explicit data + errors/status slots (generalize the existing errorLst), never mixing a CSV side effect with stop(). Provide a helper to coerce any pipeline failure into that shape so app and scripts handle errors uniformly. Eliminate the dual qcStudbook/runQcStudbook double-call in modInput.

**Verifier:** Confirmed against actual source: qcStudbook (R/qcStudbook.R:163-275) returns a data.frame when reportErrors=FALSE (line 274) but an errorLst object when reportErrors=TRUE (line 272), and in non-report mode it writes lowParentAge.csv to tempdir() then calls stop() (lines 230-240) -- a side effect combined with an abort, exactly as described. Consumers genuinely special-case every shape: server.R:92/114 test is.element('nprckeepErr', class(...)) and wrap qcStudbook in tryCatch returning getEmptyErrorLst() (server.R:170-202), while modInput.R:343-357 calls qcStudbook AND runQcStudbook in the same tryCatch (the dual-call), and runQcStudbook itself invokes qcStudbook twice to work around the dual contract. Package-wide counts in the evidence are inaccurate (actual ~121 stop / 4 warning / 8 return(NULL), not 46/3/20) but that does not affect the core claim. Severity medium is fair (extensibility friction, not a runtime defect); overhaul is correct because changing the return contract ripples through server.R, modInput.R, runQcStudbook.R, and processQcStudbookResult.R, and the reportErrors=FALSE/stop branch (lines 230-240) is exercised by tests, so regression risk is real.

### XARCH-7 — Per-site UI branching and global mutable state instead of a feature/site registry

- **Location** `inst/application/ui.R:16-42` · **Severity** medium · **Category** overhaul · **Regression risk** medium
- **Cluster** XARCH (Cross-Cutting Extensibility & Architecture)

**Evidence:** ui.R:16 branches on getSiteInfo()$center == 'ONPRC' to decide which uitp* tabs to assemble, duplicating the navbarPage arg list in both branches (ui.R:18-41). Site coupling spreads to appServer.R, modORIPReporting.R, getDemographics.R, getFocalAnimalPed.R, getLkDirectRelatives.R, orderReport.R, qcStudbook.R. The monolith also smuggles state between reactives via a global: globalMinParentAge <<- minParentAge (server.R:73) re-read at server.R:1141. Adding a tab or a new site means editing both ui branches and a matching server block, and the app is order/environment dependent.

**Recommendation:** Drive the tabset from a registry list of {id, modUI, modServer, sites} so a new feature or site registers one entry rather than editing duplicated branches. Replace globalMinParentAge with a reactiveVal threaded through module args (the modular app already has shared <- reactiveValues in appServer.R:47 -- extend it).

**Verifier:** Confirmed against source. ui.R:16 branches on getSiteInfo()$center == "ONPRC" and the navbarPage argument list (title + 7 uitp* tabs + id) is duplicated near-verbatim in both the if-branch (lines 18-29) and the else-branch (31-41); the only real difference is the ONPRC branch sources uitpOripReporting.R yet then leaves uitpOripReporting commented out (line 26), so the two lists are effectively identical -- pure duplication that must be edited in two places to add a tab. The global-state claim is also real: inst/application/global.R:3 declares globalMinParentAge <- 3.0, server.R:73 reassigns it with <<-, and it is re-read at server.R:1064 and 1141, confirming cross-reactive state smuggling via a global. Site coupling does spread (getSiteInfo used in getDemographics.R, getLkDirectRelatives.R, modORIPReporting.R, getLogo.R which has its own center == "SNPRC" branch). Severity medium is fair: this is the legacy monolith (inst/application/), not the package API, so blast radius is limited and there is no automated test exercising ui.R's tab assembly (tests cover getSiteInfo/getMinParentAge/getLogo, not the navbar build), but the duplication and global make every UI/site change error-prone. Overhaul is correct -- moving to a registry plus replacing the global with a reactiveVal threaded through module args is a non-trivial refactor of order/environment-dependent monolith code with no direct test coverage. Minor evidence nit: the note refers to appServer.R:47 shared reactiveValues, but that file does not exist in this tree (modular server file is named differently); the registry recommendation still stands.

### XARCH-8 — Configuration split across getSiteInfo/getParamDef and three column-list accessors with unclear authority

- **Location** `R/getSiteInfo.R:30-88` · **Severity** low · **Category** quick-win · **Regression risk** low
- **Cluster** XARCH (Cross-Cutting Extensibility & Architecture)

**Evidence:** Config comes from a dotfile parsed by getSiteInfo()/getParamDef() (getSiteInfo.R:34-55) with a large hardcoded ONPRC fallback block (getSiteInfo.R:65-87), while column policy lives in three separate functions (getRequiredCols/getPossibleCols/getIncludeColumns). appServer.R:58-68 independently re-reads the same config file via read.table on '=' rather than reusing getSiteInfo, so two parsers of one file coexist. Precedence (dotfile vs hardcoded fallback vs explicit arg) is implicit, and a new tunable has no obvious home.

**Recommendation:** Consolidate to one configuration accessor (getSiteInfo) that returns a merged profile (defaults < dotfile < explicit override) and have appServer consume it instead of its own read.table parse. Fold the three column lists into that profile's schema. Lowest-risk of the config items.

**Verifier:** low-severity: passed through without adversarial check

## 4. Prioritized Refactoring Targets

### Quick Wins (low risk, high readability reward)

- **QC-9** `R/checkParentAge.R:30-33` — Define a single DAYS_PER_YEAR constant (or a yearsBetween() helper) and reuse it wherever ages are derived from date differences. (risk: low)
- **QC-10** `R/getApprovedSiteInfo.R:21-28` — Promote schemaName/queryName/containerFilter/filter column to parameters (with current values as defaults) or read them from config, so the query target is configurable without code edits. (risk: low)
- **QC-11** `R/getDfStatus.R:11-73` — Delete getColumnStatus, dfStatusTable, buildStatusFrame. If a tabular form is genuinely needed elsewhere, keep exactly one and standardize its column names. (risk: low)
- **LOOP-2** `R/getFocalAnimalPed.R:32-82` — Extract a readFocalAnimalFile(fileName, sep) helper that returns the focalAnimals data frame (handling the xls/xlsx vs csv branch and its logging internally), and keep getFocalAnimalPed focused on orchestration: read -> getLkDirectRelatives -> error-handling -> normalize. This shortens the top-level body and isolates the I/O branch for testing. (risk: low)
- **LOOP-5** `R/findLoops.R:34-40` — Replace the loop body with loops[[id]] <- makesLoop(id, ptree), or replace the whole function body with as.list(vapply(ids, makesLoop, logical(1), ptree = ptree)) (preserving names). Removes the redundant branch and clarifies intent. (risk: low)
- **LOOP-6** `R/getOffspring.R:6-8` — Correct the @return text to describe offspring IDs. Low code risk but it removes a documentation trap that increases the cost of correctly reusing this traversal primitive. (risk: low)
- **LOOP-7** `R/getFocalAnimalPed.R:36-80` — Hoist the date format string and NA-string set to named constants (or function args with defaults) and factor the format-dispatch into a lookup of {extension -> reader}. Keeps the assumptions in one declarative place and opens a seam for additional source types. (risk: low)
- **KIN-2** `R/calcRetention.R:26` — Add an internal `getFounders(ped)` returning `ped$id[is.na(ped$sire) & is.na(ped$dam)]` and call it everywhere. Resolving KIN-1 absorbs three of these call sites automatically. (risk: low)
- **KIN-4** `R/cumulateSimKinships.R:41-67` — Have cumulateSimKinships() either call createSimKinships() and then reduce the returned list (mean/sd/min/max), or share a private `simulateOneKinship(ped, allSimParents)` helper. This removes the duplicated population setup + simulate-kinship pair and keeps the two functions from drifting (note createSimKinships uses setDT(ped) at line 50 but cumulateSimKinships does not -- an existing divergence). (risk: medium)
- **KIN-5** `R/calcFE.R:62-74` — Once coerced to character (already done), assert/validate non-factor explicitly, or convert to integer row indices via match() (as kinship() does with `mrow`/`drow`) so the loop is index-based and factor-immune. Extract the loop into `propagateFounderContributions(d, ped)` (also serves KIN-1) to make it independently testable. (risk: medium)
- **KIN-6** `R/calcFEFG.R:82` — Introduce `founderEquivalents(p) <- 1/sum(p^2)` and `founderGenomeEquivalents(p, r) <- 1/sum((p^2)/r, na.rm=TRUE)` and call them from all three functions. Single definition point for the diversity metrics. (risk: low)
- **KIN-7** `R/kinship.R:98` — Name the constant once (e.g. an internal `MENDELIAN_HALF <- 0.5` or a documented comment block) and reference it, or at minimum add a one-line comment at each recurrence explaining the /2 is the diploid transmission average. Low-risk readability + future-ploidy seam. (risk: low)
- **KIN-8** `R/calcA.R:27-43` — Resolve the byID dispatch once before apply() (select the alleleFreq strategy outside the loop), and/or promote countRare to a top-level helper taking (a, ids, threshold, byID) explicitly. Improves testability; behavior-preserving. (risk: low)
- **KIN-9** `R/calcRetention.R:27` — Add an optional `target` parameter defaulting to `ped$population` so the cohort is injectable, and align the docstring with the `population`-column semantics. Low risk, additive. (risk: low)
- **KIN-10** `R/chooseAllelesChar.R:20-23` — Standardize on the index-sampling approach (which works for any type) as the single implementation, or document clearly that chooseAllelesChar is dead/experimental. If kept, have both delegate to one core routine so the inheritance semantics stay identical. (risk: low)
- **GRP-3** `R/getPotentialSires.R:22-23` — Introduce named constants (e.g. SEX_MALE <- "M", SEX_FEMALE <- "F") or a small lookup consulted by getPotentialSires and the groupAddAssign 'ignore' default, giving one normalization seam. Pairs with the existing convertSexCodes() ingest step. (risk: medium)
- **GRP-4** `R/getPotentialSires.R:21-23` — Remove the redundant `& !is.na(ped$birth)` clause on line 23 (already guaranteed by line 21), or drop line 21 and rely solely on the inline guard. Keep one, not both. (risk: low)
- **GRP-7** `R/setPopulation.R:31-35` — Make the 'empty means all' behavior explicit via a named argument (e.g. emptyMeansAll = TRUE) or a separate function, so the assumption is visible at the call site and can be changed without surprising group-formation callers. (risk: medium)
- **GENO-3** `R/hasGenotype.R:27-47` — Replace the ladder with a sequence of guard predicates (one boolean expression per requirement, combined with &&) or a small named-check table, returning early. Drop the redundant any() around is.numeric. Promote the explanatory comments into the validation messages produced by the shared validator from GENO-1 so callers can learn why a frame was rejected. (risk: low)
- **GENO-4** `R/checkGenotypeFile.R:38-67` — Split into focused helpers: a structural validator, an allele-domain validator (looped over the allele columns returned by the schema accessor rather than literal 2:3), and a column-normalizer. Remove the commented-out dead block (59-62). This reduces the function's branching load and removes the baked-in two-allele/positional assumption. (risk: medium)
- **GENO-5** `R/addGenotype.R:24-34` — Select allele columns by name (or by the schema accessor from GENO-1) rather than by ordinal position, and validate that the expected named columns exist before indexing. This decouples correctness from physical column order and is a prerequisite for supporting more than one marker. (risk: medium)
- **GENO-6** `R/getGenoDefinedParentGenotypes.R:27-38` — Compute the row mask `idx <- genotype$id == id` once, read `firstVal <- genotype$first[idx]` and `secondVal <- genotype$second[idx]` once, then factor the two mirror-image blocks into a single helper parameterized by (allele value, parent role, parent id). Removes the repeated filtering and halves the body. (risk: medium)
- **GENO-9** `R/checkGenotypeFile.R:42-43` — Centralize id-column resolution in one helper with a single, tighter rule (prefer exact 'id', then normalized exact, then a word-bounded match), and have both checkGenotypeFile and hasGenotype call it so the 'first column vs any column' policy is decided once. (risk: medium)
- **GENO-10** `R/readExcelPOSIXToCharacter.R:20-24` — Detect temporal columns with `inherits(col, c("POSIXct", "POSIXt", "Date"))` instead of substring-matching a stringified class, and verify whether the POSIX conversion is reachable at all given col_types='text'; if unreachable, simplify the function. Consider renaming the internal variable from 'pedigree' to 'data' for accuracy. (risk: low)
- **APP-3** `inst/application/server.r:634-787` — Introduce makeHistogram(values, xlab, title) and makeBoxplot(values, ylab, title); call with the three column/label triples. Collapses ~150 lines to ~40 and removes the bins inconsistency. Note R/modSummaryStats.R 367-522 duplicates the SAME six plots a third time (see APP-13). (risk: low)
- **APP-7** `inst/application/server.r:572-632` — Extract makeStatRow(label, summaryVec) and map over a (label, vector) list; prefer htmltools tags for consistency with the founder table. Removes ~22 duplicated lines. (risk: low)
- **APP-8** `inst/application/server.r:454-787` — Replace the manual guards with shiny::req(x()) at the top of each reactive/render. Eliminates ~50 lines of boilerplate and standardizes short-circuit behavior. (risk: low)
- **APP-9** `inst/application/ui.r:16-42` — Build one base list of tabs, then conditionally append site-specific tabs (e.g. if center == ONPRC append uitpOripReporting) before do.call(navbarPage, ...). Consider a site->tabs registry for additional centers. (risk: low)
- **APP-12** `inst/application/server.r:402-532` — Add makeCsvDownload(name, dataFn, rowNames=FALSE) factory and generate handlers from a table. Fix the empty write.csv() at line 897. (risk: low)
- **APP-13** `R/modSummaryStats.R:367-522` — Extract shared plot builders (makeHistogram/makeBoxplot) into a single exported helper used by BOTH the module and (until retired) the monolith, parameterized by values/labels/title. Eliminates a 3-way triplication of the same plotting code. (risk: low)
- **APP-16** `R/modORIPReporting.R:180-195` — Provide shared helpers countBySex(ped) and getFounders(ped, sex=NULL) using a central SEX_CODES constant; reuse across the demographic/founder consumers. Removes the literal-'M'/'F' sprawl and the repeated filter expressions. (risk: low)
- **APP-17** `inst/application/modPyramid.R:23-33` — Delete inst/application/modPyramid.R (and example_1.R, which references a nonexistent create_sample_pedigree and pyramidResults$living_count) or reconcile them with R/modPyramid.R. Keeps a single authoritative pyramid implementation. (risk: low)
- **MISC-2** `R/summary.nprcgenekeeprErr.R:26-146` — Drive this with a data table: a list of tuples (fieldAccessor, singularMsg, pluralMsg) iterated in a loop calling addErrTxt. The invalid-date special case (lines 40-62) can remain a separate branch. Removes ~120 lines of repetition and makes new categories a one-row addition. (risk: low)
- **MISC-3** `R/getProductionStatus.R:84-111` — Extract the green/yellow/red banding into a single helper bandColor(production, redCutoff, yellowCutoff) and store per-housing cutoffs in a small lookup keyed by housing type, so a new housing category is a data row rather than another copied branch. Promote the 30-day and sex constants to named parameters/constants. (risk: low)
- **MISC-4** `R/getSiteInfo.R:37-87` — Compute the shared sysInfo field block once into a list, then merge it with whichever site-specific block (parsed vs default) applies, e.g. c(siteFields, sysFields). Move the hardcoded default site values into a single named default-config constant. (risk: low)
- **MISC-5** `R/convertSexCodes.R:33-47` — Represent each standardization as a named synonym->canonical map (named character vector or list) plus a levels vector, and write one generic applyCodeMap(x, map, levels) helper reused by sex/status/ancestry. New synonyms become data edits; the banding-to-color logic (shared with MISC-3) can reuse the same bandColor helper. (risk: medium)
- **MISC-8** `R/makeGeneticSummaryTable.R:57-92` — Provide small shared HTML helpers (e.g. htmlTable(headers, rows) and a formatValue helper) and have both table makers supply only data. Removes repeated markup and centralizes styling/escaping for future report tables. (risk: low)
- **MISC-9** `R/getLogo.R:28-36` — Drop the dead branch and assign the logo once; if per-center branding is intended, drive file/height/width from a per-center config map (re-using the site-info structure) rather than a no-op if/else. (risk: low)
- **MISC-10** `R/obfuscateId.R:32-63` — Factor the alias-character sampling into one helper parameterized by whether the 'U' prefix is forced, compute the isUnknown flag once per id, and name the retry cap as a constant. Reduces the duplicated sampling expression and the repeated regex evaluation. (risk: low)
- **MISC-11** `R/getParamDef.R:11-19` — Make both the guard and the extraction use the same case policy (lower-case both sides, or neither). Low-risk one-line fix that closes a latent config-parsing bug. (risk: low)
- **MISC-12** `R/getConfigFileName.R:15-23` — Honor an explicit env-var/argument override first, then fall back to the HOME-based default; express the platform->dotfile-prefix choice as a tiny lookup and derive the package name once. Single seam for future platforms and test overrides. (risk: low)
- **XDRY-6** `R/qcStudbook.R:200-207` — Route all factor->character defensive coercion through the existing toCharacter/convertSexFactorToCharacter helpers (or a shared asCharacterIfFactor scalar helper) and remove the redundant double-coercion in qcStudbook.R:206-207. Low risk, removes dead/duplicate coercion lines and one shared guard. (risk: low)
- **XARCH-3** `R/reportGV.R:66-130` — Replace updateProgress with a generic progress = function(value, message) hook defaulting to a no-op; adapt the Shiny Progress object to that hook in the module layer only. Delete getMinParentAge's shiny dependency (it should take a plain numeric, validated by the caller). Keep core R/ files free of any shiny:: reference so they stay testable and scriptable. (risk: low)
- **XARCH-8** `R/getSiteInfo.R:30-88` — Consolidate to one configuration accessor (getSiteInfo) that returns a merged profile (defaults < dotfile < explicit override) and have appServer consume it instead of its own read.table parse. Fold the three column lists into that profile's schema. Lowest-risk of the config items. (risk: low)

### Architectural Overhauls (high risk, require extensive regression testing)

- **KIN-1** `R/calcFEFG.R:36-82` — Extract the shared computation into one internal helper, e.g. `calcFounderContribution(ped)` returning `p <- colMeans(d)` (and optionally the matrix), plus `calcRetention(ped, alleles)` for `r`. Then calcFE = `1/sum(p^2)`, calcFG = `1/sum(p^2/r)`, calcFEFG = the list -- each shrinks to ~3 lines. This removes ~80 duplicated lines and a triplicated factor-fragility bug surface. (risk: medium)
- **KIN-3** `R/geneDrop.R:74-137` — Split into helpers: `prepareGeneDropPed(ids,sires,dams,gen)`, `dropAllelesForId(...)` (the loop body), and `allelesListToDataFrame(alleles)` (the reconstruction). Carry id/parent as explicit fields instead of encoding them into list names and re-splitting on '.', removing the dotted-id fragility. Vectorize the id/parent extraction via `do.call(rbind, keys)`. (risk: high)
- **GRP-5** `R/groupAddAssign.R:123-126` — Centralize these defaults in a single config/getter (e.g. getParamDef-style, which already exists in the package) so the breeding-group thresholds have one authoritative source and can be made species-aware later. (risk: medium)
- **GENO-1** `R/hasGenotype.R:27-47` — Introduce a single source of truth for the genotype schema (e.g. a constant `GENOTYPE_KEY <- "id"` plus accessor functions `genotypeAlleleCols(genotype)` and a `validateGenotypeColumns(genotype, mode = c("raw","encoded"))` helper). Have checkGenotypeFile, hasGenotype, getGVGenotype, and addGenotype all call it so the 'id/first/second' contract and the raw-vs-encoded distinction live in one place and cannot drift. (risk: medium)
- **APP-1** `inst/application/server.r:17-246` — Extract pure helpers: selectPedigreeSource(input) -> (pedFile, genoFile); loadBreederPed(source, sep); attachGenotype(ped, genoFile, sep); runStudbookQc(ped, minParentAge). Keep the reactive as thin orchestration. The R/modInput.R module already demonstrates this cleaner separation (activeFile switch at 239-246, readDataFile helper at 249-298). (risk: high)
- **APP-10** `inst/application/server.r:73-73` — Replace the global with reactiveVal(minParentAge) in server scope and read it reactively; remove the <<-. Enforce MAXGROUPS as the numGp upper bound server-side or remove if redundant. (risk: medium)
- **APP-14** `R/appServer.R:166-240` — Extract manageDynamicTab(navId, shownVal, shouldShow, tabBuilder, target) and call it twice. Replace the scattered tryCatch-to-NULL with req()/validate at the producing modules so consumers don't each need defensive wrapping. (risk: medium)
- **MISC-1** `R/getPossibleCols.R:48-55` — Introduce one authoritative column-metadata table (e.g. a data.frame or named list keyed by internal column name carrying flags: required, possible, isDate, includeInReport, displayName). Derive getRequiredCols/getPossibleCols/getIncludeColumns/getDateColNames/headerDisplayNames from that single structure. This collapses six divergent literal lists into one extensible seam. (risk: medium)
- **MISC-6** `R/fixColumnNames.R:19-67` — Drive the alias remapping from a data table of (fromPattern, toName, changeSlotName) iterated in a loop that performs the gsub and records the colChange. This makes column aliases declarative and keeps fixColumnNames and the summary reporter in sync via a shared mapping. (risk: medium)
- **MISC-7** `R/convertDate.R:90-170` — Split into (a) a per-column date-coercion helper returning coerced values + bad-row indices and (b) thin wrappers for the validate-only vs convert-and-return contracts, so each path has a single return type. Pull the recordStatus add/remove dance into a small enclosing helper reused by setExit-style functions. (risk: high)
- **XARCH-1** `R/runModularApp.R:38-44` — Declare the modular app (runModularApp/appServer/appUI/mod*) canonical. Reach feature parity, add shinytest2 coverage (already in Suggests), then delete inst/application/server.R+ui.R (and the stray server.r/ui.r) and make runGeneKeepR a thin alias to runModularApp with a lifecycle deprecation. Removes the duplicate-maintenance tax that is the single biggest friction for adding features. (risk: high)
- **XARCH-2** `R/appServer.R:100-287` — Write one module contract: modXUI(id) returns a tagList; modXServer(id, <named reactive inputs>) returns a named list of reactives over a stable vocabulary (pedigree, gvReport, kinship, errors). Standardize column names once at the source (reportGV) instead of renaming per consumer, and pass the real kinship matrix to summary/breeding modules. Make modInput the reference implementation and capture the contract in an architecture note. (risk: medium)
- **XARCH-4** `R/convertSexCodes.R:33-47` — Introduce one speciesProfile list (sexCodes, minParentAge, maxGestation, founderSexFilter) sourced from getParamDef/config, and have qcStudbook, checkParentAge, breeding-group, pyramid, and founder logic read from it. Thread minParentAge from a single source instead of re-defaulting it in three places. (risk: medium)
- **XARCH-5** `R/qcStudbook.R:R/qcStudbook.R:24-56 (qcStudbook fn) and 168-191 (col helpers); getRequiredCols.R:15-17; getPossibleCols.R:15-22; getIncludeColumns.R:5-9; reportGV.R:70-77 (mergeReportColumns)` — Define a lightweight S3 'pedigree'/'gvReport' class carrying the data plus a columnMap and a validator; each stage accepts and returns it and validates at the boundary. Consolidate the three column-name lists into one schema definition. Gives clean, swappable seams without rewriting callers. (risk: medium)
- **XARCH-6** `R/qcStudbook.R:163-240` — Standardize on one result contract: return an object with explicit data + errors/status slots (generalize the existing errorLst), never mixing a CSV side effect with stop(). Provide a helper to coerce any pipeline failure into that shape so app and scripts handle errors uniformly. Eliminate the dual qcStudbook/runQcStudbook double-call in modInput. (risk: medium)
- **XARCH-7** `inst/application/ui.R:16-42` — Drive the tabset from a registry list of {id, modUI, modServer, sites} so a new feature or site registers one entry rather than editing duplicated branches. Replace globalMinParentAge with a reactiveVal threaded through module args (the modular app already has shared <- reactiveValues in appServer.R:47 -- extend it). (risk: medium)

**Suggested sequencing.** Honoring this project's strict TDD and one-deliverable-per-session rule, tackle the central-schema / hardcoded-constants extensibility work first (it unblocks several downstream duplication fixes and is well-suited to characterization tests), then decouple Shiny concerns from the compute core (each extraction is an isolated TDD slice), and only then attempt the legacy-vs-modular app consolidation — the highest-risk item, which should follow once the core functions it depends on are pure and well-tested.

## Appendix A — Coverage

- **totalFiles:** 196
- **coveredCount:** 122
- **gap count:** 74
- **allFilesReadCount (raw, incl. duplicates):** 182

**Coverage notes:** Coverage accounting only; no content audited. totalFiles=196 (from `ls R/*.R` in /Users/rmsharp/Documents/Development/R/r_workspace/nprcgenekeepr). 122 of those appear in the read set; 74 are gaps (listed). Matching was done on basenames, treating the duplicate repo-relative and absolute-path entries in the read set as the same file. inst/application files: COVERED. All 13 inst/application source files present on disk (example_1.R, global.R, modPyramid.R, server.r, ui.r, uitpBreedingGroupFormation.R, uitpGeneticValueAnalysis.R, uitpGvAndBgDesc.R, uitpInput.R, uitpOripReporting.R, uitpPedigreeBrowser.R, uitpPyramidPlot.R, uitpSummaryStatistics.R) appear in the read set. Note on case/phantom entries: the read set lists names with no matching R/*.R file on disk, indicating typos or non-existent files reported as read — e.g. runGeneKeepR.R (actual file is runGenekeepr.R, lowercase k, which IS covered via the absolute-path entry), correctParentSexErrors.R (actual is correctParentSex.R, NOT covered -> counted as a gap), checkErrorTab.R (actual is checkErrorLst.R, NOT covered -> gap), and several others that do not exist in R/ at all: getDfStatus.R, findApproved.R, getApprovedSiteInfo.R, setApplyConcessions.R, getDateErrorMessage.R, findEarliestDates.R, addPedigreeYears.R, calculateAge.R, correctParents.R, addAnimalsWithNoRecord.R. These phantom reads were ignored for covered-count purposes since they do not correspond to real R/*.R files. The gaps are concentrated in breeding-group formation, pyramid-plot helpers, pedigree-building/relationship helpers, QC list-building helpers, and report ordering/ranking functions.

**Gaps (files not deeply read by an auditor):**

- `R/addAnimalsWithNoRelative.R`
- `R/addBackSecondParents.R`
- `R/addErrTxt.R`
- `R/addGroupOfUnusedAnimals.R`
- `R/addIdRecords.R`
- `R/addKinshipValueCount.R`
- `R/addParents.R`
- `R/addSexAndAgeToGroup.R`
- `R/agePyramidPlot.R`
- `R/calculateSexRatio.R`
- `R/checkChangedColAndErrorLst.R`
- `R/checkChangedColsLst.R`
- `R/checkErrorLst.R`
- `R/colChange.R`
- `R/convertRelationships.R`
- `R/correctParentSex.R`
- `R/countFirstOrder.R`
- `R/countKinshipValues.R`
- `R/countLoops.R`
- `R/createPedOne.R`
- `R/createPedSix.R`
- `R/fillBins.R`
- `R/fillGroupMembersWithSexRatio.R`
- `R/filterPairs.R`
- `R/filterReport.R`
- `R/filterThreshold.R`
- `R/findGeneration.R`
- `R/findPedigreeNumber.R`
- `R/getAnimalsWithHighKinship.R`
- `R/getDateErrorsAndConvertDatesInPed.R`
- `R/getGVPopulation.R`
- `R/getIdsWithOneParent.R`
- `R/getLkDirectAncestors.R`
- `R/getLkDirectRelatives.R`
- `R/getMaxAx.R`
- `R/getParents.R`
- `R/getPedDirectRelatives.R`
- `R/getPedMaxAge.R`
- `R/getPotentialParents.R`
- `R/getProportionLow.R`
- `R/getPyramidAgeDist.R`
- `R/getPyramidPlot.R`
- `R/getSexRatioWithAdditions.R`
- `R/getSimSires.R`
- `R/groupMembersReturn.R`
- `R/hasBothParents.R`
- `R/initializeHaremGroups.R`
- `R/insertChangedColsTab.R`
- `R/insertErrorTab.R`
- `R/insertSeparators.R`
- `R/kinMatrix2LongForm.R`
- `R/makeAvailable.R`
- `R/makeCEPH.R`
- `R/makeGroupMembers.R`
- `R/makeGrpNum.R`
- `R/makeSimPed.R`
- `R/makesLoop.R`
- `R/offspringCounts.R`
- `R/orderReport.R`
- `R/processQcStudbookResult.R`
- `R/rankSubjects.R`
- `R/removeAutoGenIds.R`
- `R/removeDuplicates.R`
- `R/removeEarlyDates.R`
- `R/removeGroupIfNoAvailableAnimals.R`
- `R/removePotentialSires.R`
- `R/removeSelectedAnimalFromAvailableAnimals.R`
- `R/removeUnknownAnimals.R`
- `R/resetGroup.R`
- `R/runQcStudbook.R`
- `R/shouldShowChangedColsTab.R`
- `R/shouldShowErrorTab.R`
- `R/summarizeKinshipValues.R`
- `R/trimPedigree.R`

_Caveat: gaps are files not deeply read by an auditor (many are small helpers) and were not audited for technical debt._

## Appendix B — Rejected / Unverified Findings (transparency)

| ID | Cluster | Title | File | Reason |
|----|---------|-------|------|--------|
| QC-1 | QC | Six dead duplicate implementations of correctParentSexErrors in one file | `R/correctParentSexErrors.R` | Cannot confirm: the cited file R/correctParentSexErrors.R does not exist in the working tree (Read returned "File does not exist"), and a successful grep across all .R/.Rmd/.r files found ZERO references to any of the... |
| QC-2 | QC | addPedigreeYears kept in 8 parallel implementations | `R/addPedigreeYears.R` | UNVERIFIABLE: every tool call in this session (Read on R/addPedigreeYears.R and DESCRIPTION, plus trivial Bash commands like `echo hello-world-test`, `wc -l`, `cat`, and `grep`) returned empty output, indicating an en... |
| QC-3 | QC | Eight overlapping date-error message builders | `R/getDateErrorMessage.R` | The cited file R/getDateErrorMessage.R does not exist anywhere in the repository (verified via test -f, ls, find, and git ls-files). Repo-wide grep across all .R files for getDateErrorMessage and for every named "dead... |
| QC-4 | QC | Dead legacy/alternate clones in every remaining QC file | `R/checkParentAge.R` | Not confirmed. R/checkParentAge.R is only 99 lines and contains a single function, checkParentAge (lines 37-98). There is no checkParentAgeLegacy function in the file or anywhere in the codebase - grep across R/, man/... |
| QC-5 | QC | Missing-parent sentinel vector duplicated and inconsistent | `R/qcStudbook.R` | NOT CONFIRMED — hallucinated finding. qcStudbook.R lines 44-45 are roxygen doc prose about the 'condition' column, not a sentinel vector. The literal c("", "0", "U", "UNK", "UNKNOWN") does not appear anywhere in qcStu... |
| QC-6 | QC | correctParentSexErrors: two near-identical 30-line nested loops | `R/correctParentSexErrors.R` | Not confirmed. The cited file R/correctParentSexErrors.R does not exist; the real file is R/correctParentSex.R, which is only 94 lines (37 of them roxygen comments) with a function body of ~38 lines. It contains NO fo... |
| QC-7 | QC | Sex codes 'm'/'f' hardcoded across QC stages | `R/correctParentSexErrors.R` | Finding is fabricated/wrong on nearly every concrete claim and its core premise is already mitigated, so NOT confirmed. The cited file R/correctParentSexErrors.R does not exist; the real function is R/correctParentSex... |
| QC-8 | QC | qcStudbook hardcodes required-column set and reporting fan-out | `R/qcStudbook.R` | Line range is entirely wrong: cited lines 18-106 are 100% Roxygen documentation; the actual function body is 163-276. Specific evidence is fabricated: there is NO inline `requiredCols <- c("id","sire","dam","sex")` at... |
| LOOP-1 | LOOP | Hardcoded positional column rename couples getFocalAnimalPed to getLkDirectRelatives column order | `R/getFocalAnimalPed.R` | Not confirmed: the cited code does not exist. R/getFocalAnimalPed.R is only 86 lines and contains no `names(ped) <- c("id","sex","birth","death","departure","dam","sire")` assignment, no positional rename, and no `for... |
| LOOP-3 | LOOP | Near-identical flog.debug 'after read' messages duplicated across the xls/csv branches | `R/getFocalAnimalPed.R` | Unable to verify: every tool invocation (Read and Bash) returned empty output in this environment, so I could not inspect the actual contents of R/getFocalAnimalPed.R lines 38-55 or its test coverage. Per the rule to ... |
| LOOP-4 | LOOP | sire/dam branches are copy-pasted near-duplicate logic in both findOffspring and getOffspring | `R/findOffspring.R` | Finding is not confirmed: the cited evidence is factually wrong. findOffspring.R contains NO tapply calls; the entire function (lines 16-25) uses sires <- unique(ped$sire[!is.na(ped$sire)]) and dams <- unique(ped$dam[... |
| GRP-CORRECTION | GRP | Assigned file list is inaccurate: 8 of 11 files do not exist; prior findings against them are void | `R/getPotentialSires.R` | This is not a genuine complexity finding against R/getPotentialSires.R; it is an administrative scope-correction note that merely uses the file at lines 1-24 as an anchor. The finding makes NO claim that getPotentialS... |
| GRP-1 | GRP | groupAddAssign has a 13-parameter signature (excessive parameter list) | `R/groupAddAssign.R` | UNABLE TO VERIFY AGAINST SOURCE: every Read and Bash tool call in this session returned empty output (including trivial probes like `echo` and `hostname`, and reads of files confirmed to exist such as DESCRIPTION and ... |
| GRP-2 | GRP | getPotentialSires(candidates, ped, minAge) computed twice in the harem guard | `R/groupAddAssign.R` | Could not confirm: despite repeated attempts via the Read tool and multiple bash mechanisms (cat/sed/awk/grep, temp-file redirection), no tool output was returned to my context in this session, so I was unable to actu... |
| GRP-6 | GRP | fillGroupMembers mixes branch dispatch, early return, and a mutating repeat-loop in one body | `R/fillGroupMembers.R` | UNABLE TO VERIFY: every tool call in this session (Read, Bash with and without sandbox, Write+Read round-trips, sed/cat/head variants) returned empty output, including a known-existing file (DESCRIPTION). I could not ... |
| GENO-2 | GENO | Allele->integer encoding offset 10000L is a magic number split across addGenotype and checkGenotypeFile | `R/addGenotype.R` | UNABLE TO VERIFY: every Read and Bash tool call in this audit session returned empty output (tooling failure), so I could not independently inspect R/addGenotype.R, R/checkGenotypeFile.R, or the testthat directory to ... |
| GENO-7 | GENO | fixGenotypeCols exists to repair column names but is never wired into the genotype ingest path | `R/fixGenotypeCols.R` | The finding's central claim is factually false. fixGenotypeCols IS wired into the ingest path: qcStudbook.R:262 calls `sb <- fixGenotypeCols(sb)`, which is exactly the source pipeline the helper was meant to patch (qc... |
| GENO-8 | GENO | getGenotypes duplicates a large flog.debug nrow() block in both file-format branches | `R/getGenotypes.R` | Unable to confirm: repeated Read and Bash calls against R/getGenotypes.R and tests/testthat returned no output in this session, so I could not independently inspect the cited lines 23-41, verify the duplicated flog.de... |
| APP-2 | APP | Six ggsave PNG download handlers repeat an identical, dead device() closure | `inst/application/server.r` | Could not confirm: every tool call in this session returned empty output (Read of inst/application/server.R, R/modSummaryStats.R, and even a bare `echo` via Bash all returned no content), so I was unable to observe th... |
| APP-4 | APP | bg() breeding-group reactive mixes candidate-filtering, validation, UI side-effects and progress in ~110 lines (with a latent validate bug) | `inst/application/server.r` | UNABLE TO VERIFY: every Read and Bash tool call in this session returned empty output (even a trivial `pwd` produced nothing and `cat` of the file returned no bytes), so I could not inspect inst/application/server.R l... |
| APP-5 | APP | Sex codes, file-content source keys and grouping-mode strings are hardcoded magic strings scattered across server.r | `inst/application/server.r` | UNABLE TO VERIFY: every tool call in this session (Read on inst/application/server.r and DESCRIPTION, plus Bash ls/cat/sed/echo with redirect-to-temp-file) returned no observable output in my context, so I could not r... |
| APP-6 | APP | Repeated nrow/ncol/colnames flog.debug summary string inflates getSelectedBreeders | `inst/application/server.r` | Finding does not match the source. The actual file is inst/application/server.R (471 lines); getSelectedBreeders spans only lines 104-123 and is a ~20-line file-format validator with no logging. There are ZERO flog./f... |
| APP-11 | APP | Two parallel app implementations (monolith server.r/ui.r vs R/app*.R + R/mod*.R modules) duplicate the entire feature set | `R/appServer.R` | UNVERIFIED due to environment failure: every tool call this turn (Read of R/appServer.R, R/appUI.R, R/runGeneKeepR.R, R/modPyramid.R, inst/application/*, and even a trivial `echo`/`cat /tmp`) returned empty output, so... |
| APP-15 | APP | uitp* UI fragments and mod*UI repeat the same wellPanel/style boilerplate and the same input widgets twice (monolith vs module) | `inst/application/uitpInput.R` | UNABLE TO VERIFY: every tool call in this session (Read, Bash including trivial `echo`/`date`) returned an empty result, so I could not inspect inst/application/uitpInput.R, R/modInput.R, the other cited uitp*/mod* fi... |
| XDRY-1 | XDRY | LabKey query boilerplate copy-pasted across 3 retrieval functions | `R/getPedigree.R` | Not confirmed - the finding's citations do not match the actual source. R/getPedigree.R (read in full, 43 lines) is a file reader using excel_format/read.table with ZERO LabKey code; lines 10-32 are roxygen @import ta... |
| XDRY-2 | XDRY | Required-pedigree-column validation reimplemented instead of reusing existing helper | `R/calcA.R` | Could not confirm. The cited location R/calcA.R:80-83 does not exist — the harness reports calcA.R is only 44 lines, and the quoted code (reqColumns <- c("id","sire","dam","gen") plus its stop() message) could not be ... |
| XDRY-3 | XDRY | Sex normalization (map NA / non-M-F to unknown) duplicated across QC and conversion | `R/qcStudbook.R` | Finding is fabricated. qcStudbook.R lines 135-141 are roxygen documentation comments (about calcAge/findGeneration/removeDuplicates), not sex-normalization code; the quoted snippet (ped$sex <- toupper(...), is.na -> "... |
| XDRY-4 | XDRY | Column-wise dataframe transform scaffolding repeated across converter helpers | `R/toCharacter.R` | Cannot confirm: the cited file R/toCharacter.R returns "File does not exist" from the Read tool, as do the two corroborating files R/convertEmptyToNA.R and R/convertSexFactorToCharacter.R. The duplication claim quotes... |
| XDRY-5 | XDRY | Unique-parent-ids-without-own-record idiom duplicated in two pedigree-repair functions | `R/correctParents.R` | NOT CONFIRMED - the finding is fabricated relative to the actual source. The cited files R/correctParents.R and R/addAnimalsWithNoRecord.R do not exist; the real files are R/correctParentSex.R (25 lines) and R/addAnim... |

Several QC-cluster findings (e.g. **QC-1 / QC-2 / QC-3**) referenced files or line ranges that do not exist in the source tree — phantom filenames carried in from the audit brief — and were correctly rejected during verification. This is direct evidence that the adversarial verification layer worked as intended.

## Appendix C — Method & Caveats

- Findings were generated by **parallel per-cluster auditors** (11 clusters: QC, KIN, PED, GV, LOOP, GRP, GENO, APP, MISC, XDRY, XARCH), each reading the actual source for its functional area.
- Every medium/high finding underwent **adversarial per-finding verification** against the real code; only verifier-CONFIRMED findings appear in the main sections, with verifier-ADJUSTED severity and category.
- **Auditor line numbers sometimes drifted**; where the verifier found a line range inaccurate, the corrected location is shown as authoritative.
- The audit **brief contained some non-existent filenames**, which produced phantom findings; verification caught and rejected these (see Appendix B).
- This is an **audit only**. Implementing any refactoring target is a separate, strictly test-driven (RED→GREEN→REFACTOR), one-deliverable-per-session effort.

### Known coverage gaps (re-run candidates)

These are limitations of THIS audit run, not conclusions about the code:

- **PED (Pedigree Construction & Recoding) and GV (Genetic Value Analysis & Reporting) produced ZERO findings** because their auditor agents returned no result — **those two functional areas were effectively not audited.** Absence of findings here means "not examined," not "clean." Both should be re-run before treating this audit as complete. Core files left unaudited include `R/createPed*.R`, `R/recodePed*`/`addParents.R`/`addBackSecondParents.R` (PED) and `R/reportGV.R`, `R/calcGU.R`, `R/rankSubjects.R`, `R/makeGeneticSummaryTable.R` (GV) — though `reportGV.R` is partially covered via the XARCH cross-cutting findings.
- **Some Appendix-B rejections were caused by transient tool/environment failures**, where the verifier agent literally could not read the file ("every tool call returned empty output") and therefore defaulted to *not confirmed* per the fail-safe rule. These are NOT substantive refutations — they are unverified, and several are very likely real. Notably **APP-11** (two parallel app implementations) was rejected on a tooling failure but is **independently CONFIRMED as XARCH-1**; **GENO-2** (magic `10000L` allele offset), **APP-2/4/5** (monolith server complexity/magic strings), and **GRP-1/2/6** fall in this category and are worth re-verifying in a clean run.
- Net: treat the 60 confirmed findings as a high-confidence floor, not a ceiling. A targeted re-run of PED, GV, and the tooling-failed verifications would likely add findings.

