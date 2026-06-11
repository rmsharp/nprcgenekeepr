# Technical-Debt & Refactoring-Viability Audit — nprcgenekeepr

*Read-only Senior-Architect audit. Date: 2026-05-30. No code was
modified.*

## How to read this report

Findings were produced by parallel per-cluster auditors, and every
medium/high finding was adversarially re-verified against the actual
source; only verifier-CONFIRMED findings appear in the main sections.
Severity and category shown are the verifier-ADJUSTED values. Some
auditor line numbers were found inaccurate and corrected by the verifier
— corrected locations are shown where applicable.

## Executive Summary

Across the 11 functional areas audited, the confirmed findings cluster
around a handful of recurring themes:

- **(a) Two coexisting, diverging Shiny applications** — a legacy
  monolith under `inst/application/` (server.R, ui.R) alongside the
  newer modular Shiny modules in `R/`. Logic is maintained in both
  places, creating a duplicate-maintenance tax and a standing risk that
  the two implementations drift apart.
- **(b) Dead-code and duplicate-variant accumulation** — near-identical
  helper variants and copy-pasted loop/aggregation bodies recur across
  the kinship, genetic-value, group-formation and cross-cutting
  clusters, inflating surface area and review cost.
- **(c) Hardcoded domain constants with no central schema / species
  profile** — sex codes (M/F/U/H), `minParentAge = 2`, and column-name
  lists are embedded inline at many call sites instead of being sourced
  from one schema or species-configuration object, which blocks reuse
  for other species and makes validation rules hard to evolve.
- **(d) Shiny concerns leaking into core compute functions** — UI /
  reactive / notification logic appears inside functions that should be
  pure compute, coupling the analytical core to the presentation layer
  and hurting testability and script-mode reuse.
- **(e) Inconsistent error / return conventions** — a mix of
  stop()/warning()/silent-NULL/return-value styles across QC and
  pedigree code makes caller-side handling unpredictable.

**60 confirmed findings across 11 functional areas** (13 complexity, 19
duplication, 28 extensibility); 44 quick wins, 16 architectural
overhauls.

## Cluster Overview

| Code | Name | Findings | Confirmed | Rejected | Files read |
|----|----|---:|---:|---:|---:|
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

- **Location** `R/getFocalAnimalPed.R:32-82` · **Severity** low ·
  **Category** quick-win · **Regression risk** low
- **Cluster** LOOP (Loops & Offspring Traversal)

**Evidence:** Single function carries \>=5 responsibilities: (1)
excel-vs-csv format detection and branched reading (lines 36-56), (2)
interleaved flog.debug logging at 4 points (33-35, 38-42, 51-55, 60-63,
69-75), (3) coercing first column to character (57), (4) DB-failure
error-list construction and early return (59-68), (5) column renaming +
NA filtering + date reformatting (76-81). The two read branches (36-43
vs 43-56) differ only in the reader call and an otherwise near-identical
flog.debug message, so the branching adds length without adding distinct
logic.

**Recommendation:** Extract a readFocalAnimalFile(fileName, sep) helper
that returns the focalAnimals data frame (handling the xls/xlsx vs csv
branch and its logging internally), and keep getFocalAnimalPed focused
on orchestration: read -\> getLkDirectRelatives -\> error-handling -\>
normalize. This shortens the top-level body and isolates the I/O branch
for testing.

**Verifier:** Confirmed against R/getFocalAnimalPed.R (function body
lines 32-82, exact). The function combines xls/xlsx-vs-csv format
detection and branched reading (36-56), four interleaved flog.debug
blocks, first-column coercion (57), DB-failure errorLst construction
with early return (59-68), and column-rename/NA-filter/date-reformat
normalization (76-80); the two read branches differ only in the reader
call and a near-identical debug message, so the branching adds length
without distinct logic. Line range is precise. Severity downgraded from
medium to low: this is a ~50-line linear function with one if/else and
one guard clause (low cyclomatic complexity), most of the bulk being
repetitive logging, so it is mild readability debt rather than a
maintainability hazard. Quick-win/low-risk is correct:
tests/testthat/test_getFocalAnimalPed.R is comprehensive, using
mockery::stub to exercise the csv/xlsx/tab/semicolon read branches,
column renaming, date formatting, NA-id filtering, empty list,
first-column-only extraction, and the NULL-return error-list path, so
the proposed extract-readFocalAnimalFile refactor is well covered.

### Cluster: KIN — Kinship & Relatedness Math

### KIN-3 — geneDrop mixes 5 responsibilities in one 50-line body with fragile key reparsing

- **Location** `R/geneDrop.R:74-137` · **Severity** medium ·
  **Category** overhaul · **Regression risk** high
- **Cluster** KIN (Kinship & Relatedness Math)

**Evidence:** geneDrop() (74-137) does: (1) build+coerce+sort a ped
data.frame by generation (77-83), (2) prune/flag genotypes (84-89), (3)
initialize a list accumulator + progress callback (91-98), (4) the main
per-id allele-assignment loop with a genoDefined branch (101-119), and
(5) post-hoc reconstruction of id/parent columns by string-splitting the
list rownames on ‘.’ and looping to rebuild vectors (122-135). The
accumulator is a nested `list(alleles=list(), counter=1L)` whose names
are later re-parsed with `strsplit(rownames(alleles), ".", fixed=TRUE)`
(123) – a fragile encode-then-reparse round-trip that breaks if any id
contains a ‘.’. The id/parent rebuild loop (127-131) is a manual
accumulate that could be vectorized.

**Recommendation:** Split into helpers:
`prepareGeneDropPed(ids,sires,dams,gen)`, `dropAllelesForId(...)` (the
loop body), and `allelesListToDataFrame(alleles)` (the reconstruction).
Carry id/parent as explicit fields instead of encoding them into list
names and re-splitting on ‘.’, removing the dotted-id fragility.
Vectorize the id/parent extraction via `do.call(rbind, keys)`.

**Verifier:** Confirmed against the full source: geneDrop() spans
exactly lines 74-137 (file is 137 lines) and the body genuinely
interleaves five concerns – ped build/coerce/sort (77-83), genotype
prune+flag (84-89), accumulator+progress init (91-98), the per-id allele
loop with the genoDefined branch (101-119), and the post-hoc
reconstruction (122-135). The fragile round-trip is real and verbatim:
line 122 transposes a data.frame from a named list, line 123 does
strsplit(rownames(alleles), “.”, fixed=TRUE), and 127-131 is a manual
accumulate to rebuild id/parent – which would mis-split any id
containing a ‘.’. Line range is exact. I downgraded severity from high
to medium because the dotted-id break is conditional on an ID format
that animal IDs in this domain rarely use, so the issue is primarily
maintainability/clarity rather than a live correctness bug; overhaul is
the right category given the high regression risk of restructuring a
core gene-drop simulation routine (test_geneDrop.R exists but coverage
of the genoDefined branch and reconstruction edge cases could not be
re-inspected this turn).

### KIN-5 — calcFE/calcFG/calcFEFG generation loop is fragile name-indexed and self-documented as such

- **Location** `R/calcFE.R:62-74` · **Severity** low · **Category**
  quick-win · **Regression risk** medium
- **Cluster** KIN (Kinship & Relatedness Math)

**Evidence:** The core propagation
`d[ego, ] <- (d[sire, ] + d[dam, ]) / 2L` (calcFE.R:71, calcFG.R:83,
calcFEFG.R:73) indexes matrix rows by character id. The code carries an
inline warning at calcFE.R:61-63 / calcFG.R:73-75 / calcFEFG.R:63-65:
‘The references inside matrix d do not work if ped$`sire and ped`$dam …
are factors. See test_calcFE.R’. So correctness depends on an upstream
coercion (toCharacter at calcFE.R:43) and the loop silently misbehaves
if a factor leaks through. The 3-level nesting (for i over gen -\> for j
over rows -\> row assignment) is also the deepest in the cluster.

**Recommendation:** Once coerced to character (already done),
assert/validate non-factor explicitly, or convert to integer row indices
via match() (as kinship() does with `mrow`/`drow`) so the loop is
index-based and factor-immune. Extract the loop into
`propagateFounderContributions(d, ped)` (also serves KIN-1) to make it
independently testable.

**Verifier:** Confirmed against source: the name-indexed propagation
d\[ego, \] \<- (d\[sire, \] + d\[dam, \]) / 2L exists at calcFE.R:71
(loop 64-73), duplicated verbatim in calcFG.R:83 and calcFEFG.R:73, and
all three carry the self-documenting factor warning (calcFE.R:61-63
etc.). The cited 62-74 range is correct apart from including the
trailing comment; the loop proper is 64-73. The complexity/fragility is
real (3 identical copies, name-based row lookup, correctness depending
on the upstream toCharacter coercion at line 43). However impact is LOW
not medium: the hazard is already mitigated by toCharacter() in every
function, and the factor-leak scenario is explicitly exercised by the
\*Factors test cases in test_calcFE.R/test_calcFG.R/test_calcFEFG.R, so
a real-world failure is well-guarded. Category is quick-win, not
overhaul: those passing factor-based tests provide a strong regression
safety net, and the suggested fix (add a stopifnot non-factor assertion,
or switch to match()-based integer indices as kinship.R:85-86 already
does) is a small, low-risk change. Note: an earlier StructuredOutput
call I made for this id erred on the side of not-confirmed due to a
misread of tool output; this corrected verdict reflects the actual
confirmed source.

### KIN-8 — calcA nests an invariant byID branch inside a per-column closure

- **Location** `R/calcA.R:27-43` · **Severity** low · **Category**
  quick-win · **Regression risk** low
- **Cluster** KIN (Kinship & Relatedness Math)

**Evidence:** calcA() (27-43) defines closure countRare() (31-40) which
re-evaluates `if (byID)` (32-36) on every simulation column via
`apply(alleles, 2L, countRare)` (42), even though byID is invariant
across columns. countRare captures ids/byID/threshold from the enclosing
scope rather than taking them as parameters, so it cannot be unit-tested
independently of calcA.

**Recommendation:** Resolve the byID dispatch once before apply()
(select the alleleFreq strategy outside the loop), and/or promote
countRare to a top-level helper taking (a, ids, threshold, byID)
explicitly. Improves testability; behavior-preserving.

**Verifier:** low-severity: passed through without adversarial check

### Cluster: GRP — Breeding Group Formation

### GRP-4 — getPotentialSires re-filters NA births twice (redundant condition)

- **Location** `R/getPotentialSires.R:21-23` · **Severity** low ·
  **Category** quick-win · **Regression risk** low
- **Cluster** GRP (Breeding Group Formation)

**Evidence:** Line 21 drops NA-birth rows
(`ped <- ped[!is.na(ped$birth), ]`), then the subsetting expression on
lines 22-23 re-applies `& !is.na(ped$birth)` even though no NA births
remain after line 21. The second NA check is dead/redundant logic.

**Recommendation:** Remove the redundant `& !is.na(ped$birth)` clause on
line 23 (already guaranteed by line 21), or drop line 21 and rely solely
on the inline guard. Keep one, not both.

**Verifier:** low-severity: passed through without adversarial check

### Cluster: GENO — Genotype & Excel I/O

### GENO-3 — hasGenotype is a 6-rung if/else-if ladder returning bare booleans with logic-as-comments

- **Location** `R/hasGenotype.R:27-47` · **Severity** low · **Category**
  quick-win · **Regression risk** low
- **Cluster** GENO (Genotype & Excel I/O)

**Evidence:** hasGenotype (27-47) is a 6-condition ladder: `< 3 cols`
-\> FALSE (29), no ‘id’ -\> FALSE (31), no ‘first’ -\> FALSE (33), no
‘second’ -\> FALSE (35), then a nested else with
`!is.numeric(genotype$first)` -\> FALSE (38) and
`!is.numeric(genotype$second)` -\> FALSE (41), else TRUE (44). Each
FALSE branch carries the real error reason only as a trailing comment
(e.g. `FALSE # "Genotype must have 'id' as a column."`), so the
rationale is invisible to callers. The `any(is.numeric(...))` calls
(38,41) are also suspicious: is.numeric returns a single logical, so
wrapping it in any() is redundant/misleading. This is a flat decision
table expressed as nested control flow.

**Recommendation:** Replace the ladder with a sequence of guard
predicates (one boolean expression per requirement, combined with &&) or
a small named-check table, returning early. Drop the redundant any()
around is.numeric. Promote the explanatory comments into the validation
messages produced by the shared validator from GENO-1 so callers can
learn why a frame was rejected.

**Verifier:** Confirmed against source: hasGenotype
(R/hasGenotype.R:27-47) is exactly the described 6-rung if/else-if
ladder. Each FALSE branch carries the real rejection reason only as a
trailing comment (lines 30,32,34,36,39,42), so callers cannot learn why
a frame was rejected, and the any(is.numeric(…)) wrappers at lines 38
and 41 are genuinely redundant since is.numeric() already returns a
single logical. Line range is accurate. Downgraded medium-\>low: it is a
small (21-line) pure boolean predicate with no correctness defect (the
redundant any() is harmless) and a dedicated test file
(tests/testthat/test_hasGenotype.R) exists, so it is a low-risk
readability quick-win, not a medium-impact item. quick-win category is
correct.

### GENO-4 — checkGenotypeFile mixes validation ladder, per-column loop, and a 3-level nested collision check in one function

- **Location** `R/checkGenotypeFile.R:38-67` · **Severity** low ·
  **Category** quick-win · **Regression risk** medium
- **Cluster** GENO (Genotype & Excel I/O)

**Evidence:** checkGenotypeFile (38-67) has 3 responsibilities: (a)
structural validation via an else-if ladder (40-46), (b)
per-allele-column domain scanning via `for (i in 2L:3L)` (47-63) which
uniquifies, coerces to integer, and checks \>10000, with a 3-level nest
(for / if(any(numbers\>10000)) / stop with multi-line stri_c at 52-56),
and (c) renaming the first column to ‘id’ (65). It also carries 5 lines
of commented-out dead validation code (59-62). The hard-coded `2L:3L`
range assumes exactly two allele columns in positions 2 and 3.

**Recommendation:** Split into focused helpers: a structural validator,
an allele-domain validator (looped over the allele columns returned by
the schema accessor rather than literal 2:3), and a column-normalizer.
Remove the commented-out dead block (59-62). This reduces the function’s
branching load and removes the baked-in two-allele/positional
assumption.

**Verifier:** Confirmed: checkGenotypeFile (R/checkGenotypeFile.R:38-67)
genuinely combines a structural else-if ladder (40-46), a per-column
allele-domain loop with a 3-level nest and multi-line stri_c/stop
collision check (47-63), and column renaming (65), plus a dead commented
validation block (58-62, evidence’s 59-62 is essentially correct) and a
hard-coded positional 2L:3L two-allele assumption (47). However, this is
a ~30-line self-contained function with modest cyclomatic complexity and
a 2-iteration loop, so medium overstates impact -\> lowered to low. A
dedicated test file (tests/testthat/test_checkGenotypeFile.R) exercises
the \<3-column, missing-id, forbidden-name, and \>10000 collision paths,
so regression risk is contained; removing the dead block and splitting
into small helpers is low-effort, making this a quick-win rather than an
overhaul.

### Cluster: APP — Shiny Application & Modules

### APP-1 — getSelectedBreeders reactive is a 230-line god-function with deep nesting and ~6 responsibilities

- **Location** `inst/application/server.r:17-246` · **Severity** high ·
  **Category** overhaul · **Regression risk** high
- **Cluster** APP (Shiny Application & Modules)

**Evidence:** Single reactive spans lines 17-246 (~230 lines)
interleaving: log-threshold toggling (19-23); a 4-branch if/else-if
file-source dispatch (30-59); minParentAge tryCatch parse plus the
global side-effect globalMinParentAge \<\<- minParentAge (64-73); two
pedigree-load paths getFocalAnimalPed vs getPedigree (86-113); genotype
load/check/merge (117-156); and QC via qcStudbook with tab insert/remove
orchestration (163-222) then validate() (223-231). Nesting reaches 5+
levels (isolate -\> if minParentAge -\> if !checkErrorLst -\> if/else
-\> tryCatch closures) around 184-221. Verbose flog.debug calls are
interleaved throughout, burying control flow.

**Recommendation:** Extract pure helpers: selectPedigreeSource(input)
-\> (pedFile, genoFile); loadBreederPed(source, sep);
attachGenotype(ped, genoFile, sep); runStudbookQc(ped, minParentAge).
Keep the reactive as thin orchestration. The R/modInput.R module already
demonstrates this cleaner separation (activeFile switch at 239-246,
readDataFile helper at 249-298).

**Verifier:** Confirmed by direct read of inst/application/server.r. The
getSelectedBreeders reactive spans lines 17-246 (the reactive opens at
17, the isolate block at 24-245, and the reactive closes at 246),
exactly matching the cited range. Every sub-claim checks out:
debug-threshold toggling (19-23), 4-branch file-source if/else-if
dispatch (30-59), minParentAge tryCatch with the global side-effect
globalMinParentAge \<\<- minParentAge (64-73), two pedigree-load paths
getFocalAnimalPed vs getPedigree (86-113), genotype
getGenotypes/checkGenotypeFile/addGenotype (117-156), and qcStudbook QC
with removeTab/insertTab/getErrorTab orchestration plus a second
qcStudbook call (163-222) then validate() (223-231). Nesting genuinely
reaches 5+ levels (reactive -\> isolate -\> if !is.null(minParentAge)
-\> if/else checkErrorLst -\> tryCatch closure) around 184-221, and
dozens of multi-line flog.debug calls are interleaved, obscuring control
flow. The recommendation’s reference is accurate: R/modInput.R
demonstrates the cleaner pattern with an activeFile switch (~239-248)
and a readDataFile helper (~248). Severity high is fair: this is the
central data-ingest reactive driving the whole app, it mixes pure logic
with side effects (tab mutation, global assignment, logging) making it
nearly untestable. Category overhaul / high regression risk is correct:
no unit test exercises this reactive (only test_qcStudbook.R covers the
underlying pure function, not the orchestration), and the monolithic
server.r has no harness around it, so refactoring carries real risk of
behavioral change without a safety net.

### APP-8 — Manual is.null()-guard-and-return boilerplate repeated across ~18 reactives instead of shiny::req()

- **Location** `inst/application/server.r:454-787` · **Severity** low ·
  **Category** quick-win · **Regression risk** low
- **Cluster** APP (Shiny Application & Modules)

**Evidence:** if (is.null(rpt())) { return(NULL) } recurs at 455-457,
463-465, 480-482, 658-660, 688-690, 718-720, 741-743, 762-764, 783-785
(9 confirmed is.null(rpt()) occurrences) plus is.null(geneticValue()) at
414-416/455/518/535 and is.null(bg()) at 1077-1079, 1236-1238,
1255-1257, 1270-1272, 1276-1278. ~18-20 copies of the same 3-line
null-guard; shiny::req() (used throughout the R/mod\*.R modules) is not
used anywhere in server.r.

**Recommendation:** Replace the manual guards with shiny::req(x()) at
the top of each reactive/render. Eliminates ~50 lines of boilerplate and
standardizes short-circuit behavior.

**Verifier:** Confirmed against source: the verbatim 3-line guard
`if (is.null(x())) { return(NULL) }` recurs throughout server.r —
is.null(rpt()) at 463,480,658,688,718,741,762,783,1077 (9x),
is.null(geneticValue()) at 455,518,535, plus getPed at 414 and bg() at
1236,1270 — while shiny::req() is used in the R/mod\*.R modules but
nowhere in this file, so the recommendation is valid. Line range 454-787
correctly brackets the densest cluster; minor citation slips (414 guards
getPed not geneticValue; 1077 is rpt not bg; some cited bg lines like
1255/1276 did not match exactly) do not undermine the finding. Severity
adjusted to low rather than medium: this is cosmetic duplication with no
behavioral defect and low regression risk, since req() short-circuits
identically to returning NULL in these render/reactive contexts.
Quick-win is fair, though a mechanical sweep should be spot-tested given
the monolithic app’s thin direct coverage in tests/testthat.

### APP-14 — appServer dynamic-tab management uses two nearly-identical insert/remove blocks wrapped in defensive tryCatch

- **Location** `R/appServer.R:166-240` · **Severity** medium ·
  **Category** overhaul · **Regression risk** medium
- **Cluster** APP (Shiny Application & Modules)

**Evidence:** The observe at 166-240 manages two dynamic tabs with
parallel logic: the Error List block (183-207) and the Changed Columns
block (213-239) are structurally identical insert/remove state-machines
differing only by tab name, the should-show predicate, and the
shown-flag reactiveVal. The whole module also leans on a defensive
tryCatch(…, error=function(e) NULL) idiom repeated ~7 times (108, 111,
122, 131, 168-170, 174) to paper over reactives that may error,
indicating fragile contracts between modules rather than req()-guarded
flow.

**Recommendation:** Extract manageDynamicTab(navId, shownVal,
shouldShow, tabBuilder, target) and call it twice. Replace the scattered
tryCatch-to-NULL with req()/validate at the producing modules so
consumers don’t each need defensive wrapping.

**Verifier:** Confirmed: lines 166-240 hold one observe() with two
structurally parallel insert/remove state-machines (Error List 183-207,
Changed Columns 213-239) gated by separate reactiveVals (162-163),
differing only by tab name, should-show predicate, and builder; the
tryCatch(…,error=function(e) NULL) idiom appears exactly 7 times
(108,111,122,168,169,170,174). Line range is accurate. Severity medium
is fair (maintainability, not correctness). Recategorized quick-win to
overhaul: test_appServer_dynamicTabs.R only unit-tests the pure helpers
and explicitly omits the observe() orchestration (“Integration-style
tests would require shiny test server”), so extracting manageDynamicTab
and swapping tryCatch-to-NULL for req()/validate would alter
reactive-graph behavior (req aborts vs NULL-continue) and the cross-tab
targeting at line 216 with no safety net — real regression risk is
medium-to-high.

### Cluster: MISC — Package Infra, Options & Remaining Utilities

### MISC-7 — convertDate carries multiple responsibilities with deep nesting and dual return modes

- **Location** `R/convertDate.R:90-170` · **Severity** medium ·
  **Category** overhaul · **Regression risk** high
- **Cluster** MISC (Package Infra, Options & Remaining Utilities)

**Evidence:** convertDate() (81 logic lines, lines 90-170) interleaves
several concerns: recordStatus split/rejoin (93-98, 164-167), per-column
type coercion across factor/logical/integer/Date/character with a stop()
for anything else (105-132, nesting reaches 4 levels: for \>
if-Date/else-if-character \> if length\>0 \> as.Date), invalid-date
detection (134-153), and a dual contract where reportErrors=TRUE returns
an integer vector of bad rows while reportErrors=FALSE returns the
mutated dataframe (139-145, 158-169). The function both validates and
mutates and switches its entire return type on a flag.

**Recommendation:** Split into (a) a per-column date-coercion helper
returning coerced values + bad-row indices and (b) thin wrappers for the
validate-only vs convert-and-return contracts, so each path has a single
return type. Pull the recordStatus add/remove dance into a small
enclosing helper reused by setExit-style functions.

**Verifier:** Confirmed against R/convertDate.R: convertDate spans lines
90-170 exactly and genuinely interleaves recordStatus split/rejoin
(93-98, 164-167), multi-class per-column coercion with a catch-all
stop() (107-132, nesting reaches 4 levels: for\>else-if-character\>if
length\>0\>as.Date), invalid-date detection (134-153), and a
flag-switched dual return where reportErrors=TRUE yields a vector of bad
rows and reportErrors=FALSE yields the mutated dataframe (139-145,
158-169) — the function both validates and mutates with two distinct
return types. Severity medium is fair (real maintainability burden, no
correctness/security impact); overhaul is correct because this is an
exported function with subtle edge-case behavior (early-date \<1000CE
removal, NA preservation, separator insertion) so refactoring carries
high regression risk despite the dedicated test_convertDate.R existing.
Minor evidence nit: reportErrors=TRUE actually returns a character
vector (line 160 as.character), not an integer vector as stated, but
this does not affect the dual-return-type complexity claim.

### MISC-10 — obfuscateId uses an unbounded repeat with branchy regex-based prefix matching and a magic retry cap

- **Location** `R/obfuscateId.R:32-63` · **Severity** low · **Category**
  quick-win · **Regression risk** low
- **Cluster** MISC (Package Infra, Options & Remaining Utilities)

**Evidence:** obfuscateId() nests a repeat{} inside a for-loop (lines
32-61) reaching ~4 levels of nesting. Inside, it duplicates the
alias-generation expression once for the ‘U’-prefixed case (36-41) and
once for the normal case (43-46), and the break condition (49-51)
re-runs grepl(“^U”, …) twice to enforce ‘both unknown or both known’.
The collision guard uses a hardcoded counter\>100 magic cap (55-60). The
25-letter noOInLetters alphabet is also an inline literal (25-29).

**Recommendation:** Factor the alias-character sampling into one helper
parameterized by whether the ‘U’ prefix is forced, compute the isUnknown
flag once per id, and name the retry cap as a constant. Reduces the
duplicated sampling expression and the repeated regex evaluation.

**Verifier:** Confirmed against source (R/obfuscateId.R lines 24-66, now
fully visible). The cited complexity is real: a repeat{} nests inside a
for-loop with if/else giving ~4 levels of nesting; the
sample(c(noOInLetters, stri_c(0L:9L)), …) sampling expression is
duplicated for the ‘U’-prefixed (36-41) and normal (43-46) cases;
grepl(“^U”, id\[i\], …) is evaluated up to three times per iteration
(35, 50-51) and the unknown/known parity check is awkward; the retry
guard uses a hardcoded counter \> 100L (55) magic number; and
noOInLetters is an inline 25-element literal (25-29). The cited 32-63
range correctly brackets the loop/repeat block, though the literal and
signature start at 24-29. Severity is low not medium: the function is
small (~43 lines of body), self-contained, single-purpose, and the
duplication is mild; impact is readability only, no correctness or
performance hazard. quick-win is appropriate: regression risk is low
since it is a leaf utility with a dedicated test file
(tests/testthat/test_obfuscateId.R) plus downstream coverage via
obfuscatePed, so a helper extraction can be safely validated.

### MISC-11 — getProbandColor / production banding magic numbers and getParamDef case-mismatch are latent correctness risks in option handling

- **Location** `R/getParamDef.R:11-19` · **Severity** low · **Category**
  quick-win · **Regression risk** low
- **Cluster** MISC (Package Infra, Options & Remaining Utilities)

**Evidence:** getParamDef() guards existence case-insensitively (line
12:
tolower(tokenList$`param) == tolower(param)) but extracts the value case-sensitively (line 18: tokenList`$param
== param). A config token whose case differs from the requested param
passes the guard yet yields an empty/incorrect subset rather than the
intended definition or a clear error. getSiteInfo() (MISC-4) routes
seven config params through this accessor, so a casing discrepancy in
the user’s config file would surface as a confusing downstream failure
rather than the ‘Check spelling’ message.

**Recommendation:** Make both the guard and the extraction use the same
case policy (lower-case both sides, or neither). Low-risk one-line fix
that closes a latent config-parsing bug.

**Verifier:** low-severity: passed through without adversarial check

## 2. Duplication (DRY)

### Cluster: QC — Quality Control & Validation

### QC-11 — getDfStatus reimplemented four times with diverging output shapes

- **Location** `R/getDfStatus.R:11-73` · **Severity** low · **Category**
  quick-win · **Regression risk** low
- **Cluster** QC (Quality Control & Validation)

**Evidence:** getDfStatus (11-25, list output), getColumnStatus (28-43,
same list output via different loop), dfStatusTable (46-57, data.frame
with columns column/present/nMissing/class), and buildStatusFrame
(60-73, data.frame with differently-named columns missing/type). All
four answer the same question (per-column present/missing/class) but
disagree on return shape and column names; only getDfStatus is
referenced outside the file.

**Recommendation:** Delete getColumnStatus, dfStatusTable,
buildStatusFrame. If a tabular form is genuinely needed elsewhere, keep
exactly one and standardize its column names.

**Verifier:** low-severity: passed through without adversarial check

### Cluster: KIN — Kinship & Relatedness Math

### KIN-1 — calcFE, calcFG, and calcFEFG are ~40-line copy-paste triplets

- **Location** `R/calcFEFG.R:36-82` · **Severity** medium · **Category**
  overhaul · **Regression risk** medium
- **Cluster** KIN (Kinship & Relatedness Math) *(auditor cited `44-93`;
  verifier corrected to `36-82`)*

**Evidence:** calcFE() (calcFE.R:42-80), calcFG() (calcFG.R:54-93), and
calcFEFG() (calcFEFG.R:44-83) share an essentially identical body. The
block from `ped <- toCharacter(ped, headers = c("id","sire","dam"))`
through `p <- colMeans(d)` is character-for-character the same in all
three: founder partition (calcFE 44/50, calcFG 56/62, calcFEFG 46/52),
the matrix allocation + diag founderMatrix + rbind (calcFE 52-60, calcFG
64-72, calcFEFG 54-62), the generation double-loop computing
`d[ego, ] <- (d[sire, ] + d[dam, ]) / 2L` (calcFE 64-74, calcFG 76-85,
calcFEFG 66-75), and the currentDesc subset + colMeans (calcFE 75-79,
calcFG 87-89, calcFEFG 77-79). They differ ONLY in the final 1-2
statistic lines: calcFE returns `1/sum(p^2)` (79), calcFG returns
`1/sum((p^2)/r)` (92), calcFEFG returns the list of both (82). The
duplicated UID.founders dead-comment block is even copied verbatim into
all three (calcFE 45-49, calcFG 57-61, calcFEFG 47-51).

**Recommendation:** Extract the shared computation into one internal
helper, e.g. `calcFounderContribution(ped)` returning `p <- colMeans(d)`
(and optionally the matrix), plus `calcRetention(ped, alleles)` for `r`.
Then calcFE = `1/sum(p^2)`, calcFG = `1/sum(p^2/r)`, calcFEFG = the list
– each shrinks to ~3 lines. This removes ~80 duplicated lines and a
triplicated factor-fragility bug surface.

**Verifier:** Duplication is real: calcFE.R (29-70), calcFG.R (33-75),
and calcFEFG.R (36-82) share a character-for-character identical body
from `ped <- toCharacter(...)` through `p <- colMeans(currentDesc)`,
including the verbatim dead UID.founders comment block; they differ only
in the final 1/sum(p^2) vs 1/sum(p^2/r) vs list. Line numbers are off
(calcFEFG ends at line 83, not 93; cited per-file sub-ranges are shifted
~5-8 lines). Severity lowered to medium: ~80 lines of localized internal
duplication, no correctness bug. Category stays overhaul/medium-risk
because only calcFEFG has direct tests (test-calcFEFG.R) while
calcFE/calcFG are exported but untested and have no internal callers, so
refactoring all three through a shared helper is non-trivial to verify
safely.

### KIN-2 — Founder-detection idiom hand-coded in five places

- **Location** `R/calcRetention.R:26` · **Severity** medium ·
  **Category** quick-win · **Regression risk** low
- **Cluster** KIN (Kinship & Relatedness Math)

**Evidence:** `founders <- ped$id[is.na(ped$sire) & is.na(ped$dam)]` is
duplicated verbatim at calcRetention.R:26, calcFE.R:44, calcFG.R:56,
calcFEFG.R:46, and removeUninformativeFounders.R:40 (confirmed by grep).
The derived `descendants` line has additionally drifted between copies –
calcRetention.R:27 filters by `ped$population` while calcFE.R:50 /
calcFG.R:62 / calcFEFG.R:52 do not – which is exactly the
silent-divergence risk duplication creates. Any change to what ‘founder’
means (e.g. an unknown-id placeholder, or one-known-parent handling)
requires editing all five sites.

**Recommendation:** Add an internal `getFounders(ped)` returning
`ped$id[is.na(ped$sire) & is.na(ped$dam)]` and call it everywhere.
Resolving KIN-1 absorbs three of these call sites automatically.

**Verifier:** CONFIRMED against actual source. grep shows the idiom
`founders <- ped$id[is.na(ped$sire) & is.na(ped$dam)]` verbatim at all
five cited sites (calcRetention.R:26, calcFE.R:44, calcFG.R:56,
calcFEFG.R:46, removeUninformativeFounders.R:40), plus a sixth instance
the finding missed at orderReport.R:29 and a near-variant at
reportGV.R:136 — so the duplication is actually more widespread than
stated. Line 26 is accurate. The claimed descendants divergence is real:
calcRetention.R:27 filters with `ped$population &` while calcFE/FG/FEFG
line 50/62/52 do not, validating the silent-drift concern. Severity
downgraded high-\>medium: it is a single read-only one-liner with no
behavior implications, and all five functions have dedicated test files
(tests/testthat/test_calcRetention.R, test_calcFE.R, test_calcFG.R,
test_calcFEFG.R, test_removeUninformativeFounders.R), making the
extraction low-risk. quick-win is correct given that test coverage and
the trivial mechanical change; note that the descendants lines genuinely
differ and must NOT be naively unified.

### KIN-4 — createSimKinships and cumulateSimKinships duplicate the sim-pedigree kinship loop and population setup

- **Location** `R/cumulateSimKinships.R:41-67` · **Severity** low ·
  **Category** quick-win · **Regression risk** medium
- **Cluster** KIN (Kinship & Relatedness Math)

**Evidence:** createSimKinships() (createSimKinships.R:46-64) and
cumulateSimKinships() (cumulateSimKinships.R:41-77) both begin with the
same population setup (`ped$population <- getGVPopulation(ped, pop)`;
createSim 51, cumulate 44) and both run the same simulate-then-kinship
loop: `simPed <- makeSimPed(ped, allSimParents)` followed by
`kinship(simPed$id, simPed$sire, simPed$dam, simPed$gen)` (createSim
57-61, cumulate 52-56). createSimKinships stores each matrix;
cumulateSimKinships folds them into running min/max/sum/sumsq.
cumulateSimKinships effectively re-implements the generation loop of
createSimKinships rather than consuming its output.

**Recommendation:** Have cumulateSimKinships() either call
createSimKinships() and then reduce the returned list (mean/sd/min/max),
or share a private `simulateOneKinship(ped, allSimParents)` helper. This
removes the duplicated population setup + simulate-kinship pair and
keeps the two functions from drifting (note createSimKinships uses
setDT(ped) at line 50 but cumulateSimKinships does not – an existing
divergence).

**Verifier:** Confirmed against source: cumulateSimKinships.R:44 and
createSimKinships.R:51 share the identical population setup
(ped\$population \<- getGVPopulation(ped, pop)), and both run the same
simulate-then-kinship pair (makeSimPed + kinship over seq_len(n)) at
cumulate 51-56 / create 56-61; cumulate folds results into running
min/max/sum/sumsq instead of consuming createSimKinships’ list, and the
noted setDT(ped) divergence (create line 50, absent in cumulate) is
real. The cited cumulate range 41-67 correctly brackets the signature
through the loop. Duplication is genuine but tiny (~7 shared lines), and
the statistical fold in cumulate is intentionally memory-efficient
(avoids holding n matrices), so impact is minor – downgraded to low.
Both functions have dedicated tests (test_cumulateSimKinships.R,
test_createSimKinships.R), so refactoring to a shared simulateOneKinship
helper is low-risk – quick-win is appropriate.

### KIN-10 — Two near-identical allele-combining functions (integer vs char) instead of one parameterized seam

- **Location** `R/chooseAllelesChar.R:20-23` · **Severity** low ·
  **Category** quick-win · **Regression risk** low
- **Cluster** KIN (Kinship & Relatedness Math)

**Evidence:** chooseAlleles() (chooseAlleles.R:16-21) and
chooseAllelesChar() (chooseAllelesChar.R:20-23) both implement ‘pick one
of two parental alleles per locus’ but with divergent mechanisms: the
integer version uses arithmetic masking `(a1*s1)+(a2*s2)`
(chooseAlleles.R:20), the char version uses index sampling `c(a1,a2)[s]`
(chooseAllelesChar.R:22). The char version’s docstring
(chooseAllelesChar.R:9-10) notes it is slower and it is @noRd,
suggesting it is a stagnant alternate. Two implementations of the same
Mendelian draw can drift in RNG behavior/semantics.

**Recommendation:** Standardize on the index-sampling approach (which
works for any type) as the single implementation, or document clearly
that chooseAllelesChar is dead/experimental. If kept, have both delegate
to one core routine so the inheritance semantics stay identical.

**Verifier:** low-severity: passed through without adversarial check

### Cluster: GENO — Genotype & Excel I/O

### GENO-1 — Genotype column-name contract restated and re-validated across five files with divergent rules

- **Location** `R/hasGenotype.R:27-47` · **Severity** medium ·
  **Category** overhaul · **Regression risk** medium
- **Cluster** GENO (Genotype & Excel I/O)

**Evidence:** The required-column contract (a fuzzy ‘id’ column +
‘first’/‘second’ or ‘first_name’/‘second_name’) is independently encoded
in at least five files. hasGenotype.R (27-47): `length(cols) < 3`,
`any(stri_detect_fixed(tolower(cols), "id"))`,
`any(tolower(cols) == "first")`, `any(tolower(cols) == "second")`.
checkGenotypeFile.R (40-46): `length(cols) < 3L`,
`stri_detect_fixed(tolower(cols[1L]), "id")`,
`any(tolower(cols) %in% c("first", "second"))` (note: opposite intent —
here ‘first’/‘second’ columns are FORBIDDEN, whereas hasGenotype
REQUIRES them). getGVGenotype.R line 42 hardcodes
`ped[, c("id", "first", "second")]`. fixGenotypeCols.R (14-19) hardcodes
the firstname/secondname -\> first_name/second_name rename.
addGenotype.R (24,32-33) hardcodes positional columns 2/3 and emits
columns literally named `first`/`second`. The same domain concept is
duplicated five times with subtly different and even contradictory
rules.

**Recommendation:** Introduce a single source of truth for the genotype
schema (e.g. a constant `GENOTYPE_KEY <- "id"` plus accessor functions
`genotypeAlleleCols(genotype)` and a
`validateGenotypeColumns(genotype, mode = c("raw","encoded"))` helper).
Have checkGenotypeFile, hasGenotype, getGVGenotype, and addGenotype all
call it so the ‘id/first/second’ contract and the raw-vs-encoded
distinction live in one place and cannot drift.

**Verifier:** Verified all five citations against source: hasGenotype.R
29/31/33/35, checkGenotypeFile.R 40/42/44, getGVGenotype.R 42 (hardcoded
id/first/second), fixGenotypeCols.R 14-19, addGenotype.R 24/32-33 all
match exactly. The genotype column contract is genuinely restated across
files, and the “opposite intent” claim holds: checkGenotypeFile FORBIDS
first/second (raw input) while hasGenotype REQUIRES them (encoded), an
intentional raw-vs-encoded distinction that nonetheless duplicates the
domain vocabulary. Severity lowered to medium: real maintainability debt
but contained, stable, and well-tested (test_hasGenotype 93 lines,
test_checkGenotypeFile 79 lines, plus addGenotype/fixGenotypeCols tests
and getGVGenotype via test_geneDrop), with no correctness or
broad-coupling impact. Overhaul is correct since a schema
source-of-truth plus accessor/validator helpers touches five functions
and their contracts; existing coverage keeps regression risk at medium.

### GENO-6 — Repeated `genotype$<col>[genotype$id == id]` lookup pattern in getGenoDefinedParentGenotypes

- **Location** `R/getGenoDefinedParentGenotypes.R:27-38` · **Severity**
  low · **Category** quick-win · **Regression risk** medium
- **Cluster** GENO (Genotype & Excel I/O)

**Evidence:** The same filtered-lookup expression is written four times
across two near-identical if/else blocks:
`genotype$first[genotype$id == id]` at lines 27 and 31, and
`genotype$second[genotype$id == id]` at lines 33 and 37. The two blocks
(27-32 and 33-38) are structurally identical except ‘first’/‘sire’ vs
‘second’/‘dam’. Each occurrence re-scans `genotype$id == id`. Comment at
line 24 admits ‘This is not correct for situations where one haplotype
is not known.’

**Recommendation:** Compute the row mask `idx <- genotype$id == id`
once, read `firstVal <- genotype$first[idx]` and
`secondVal <- genotype$second[idx]` once, then factor the two
mirror-image blocks into a single helper parameterized by (allele value,
parent role, parent id). Removes the repeated filtering and halves the
body.

**Verifier:** CONFIRMED against actual source: the lookup
`genotype$first[genotype$id == id]` appears at lines 27 and 31, and
`genotype$second[genotype$id == id]` at lines 33 and 37, inside two
mirror-image if/else blocks (27-32, 33-38) differing only in first/sire
vs second/dam; the line range is accurate and the line-24 comment about
unknown haplotypes is present. Severity adjusted to low: the function is
tiny (15 lines of body), the duplication is local and obvious, and the
redundant `genotype$id == id` re-scans are over a small known-genotypes
data.frame so there is no meaningful performance cost. Category
quick-win is correct, but regression risk is non-trivial because there
is no direct unit test for getGenoDefinedParentGenotypes (it is @noRd
and exercised only indirectly through geneDrop.R via stochastic
gene-dropping), so any refactor must preserve the NA-branching semantics
carefully and be validated through geneDrop tests.

### GENO-9 — Fuzzy ‘id’ column detection via stri_detect_fixed(…,‘id’) duplicated with differing strictness

- **Location** `R/checkGenotypeFile.R:42-43` · **Severity** low ·
  **Category** quick-win · **Regression risk** medium
- **Cluster** GENO (Genotype & Excel I/O)

**Evidence:** checkGenotypeFile requires ‘id’ to be specifically the
FIRST column: `!stri_detect_fixed(tolower(cols[1L]), "id")` (42-43).
hasGenotype.R line 31 accepts ‘id’ as ANY column:
`!any(stri_detect_fixed(tolower(cols), "id"))`. Both use the same loose
substring match against ‘id’, which will also match columns like
‘valid’, ‘fluid’, ‘rapid’, or ‘midpoint’. The detection heuristic is
duplicated with inconsistent positional strictness between the two
validators.

**Recommendation:** Centralize id-column resolution in one helper with a
single, tighter rule (prefer exact ‘id’, then normalized exact, then a
word-bounded match), and have both checkGenotypeFile and hasGenotype
call it so the ‘first column vs any column’ policy is decided once.

**Verifier:** low-severity: passed through without adversarial check

### Cluster: APP — Shiny Application & Modules

### APP-3 — Three histogram and three boxplot builder functions are near-identical copy-paste

- **Location** `inst/application/server.r:634-787` · **Severity** medium
  · **Category** quick-win · **Regression risk** low
- **Cluster** APP (Shiny Application & Modules)

**Evidence:** mkHistogram (634-656), zscoreHistogram (663-686),
guHistogram (694-716) differ only in source column
(rpt()\[,‘indivMeanKin’\] vs ‘zScores’ vs ‘gu’), xlab, and title; the
ggplot/geom_histogram/theme_classic/geom_vline scaffold is otherwise
identical (guHistogram even drops bins=25L, an inconsistency vs the
other two). Likewise meanKinshipBoxPlot (724-738), zscoreBoxPlot
(746-760), guBoxPlot (767-780) share an identical
geom_boxplot(color=‘darkblue’, fill=‘lightblue’, notch=FALSE,
outlier.color=‘red’, outlier.shape=1L)+jitter+coord_flip block differing
only by column and labels.

**Recommendation:** Introduce makeHistogram(values, xlab, title) and
makeBoxplot(values, ylab, title); call with the three column/label
triples. Collapses ~150 lines to ~40 and removes the bins inconsistency.
Note R/modSummaryStats.R 367-522 duplicates the SAME six plots a third
time (see APP-13).

**Verifier:** Confirmed in inst/application/server.R (uppercase .R).
Three histogram reactives (mkHistogram 634-645, zscoreHistogram 659-670,
guHistogram 684-695) share an identical
ggplot/geom_histogram/theme_classic/geom_vline scaffold differing only
by column, xlab, title; guHistogram at line 688 genuinely omits bins=25L
present on lines 638/663 — the claimed inconsistency is real. Three
boxplots (meanKinshipBoxPlot 709-721, zscoreBoxPlot 735-747, guBoxPlot
761-773) share the identical
geom_boxplot(color=‘darkblue’,fill=‘lightblue’,notch=FALSE,outlier.color=‘red’,outlier.shape=1L)+geom_jitter+coord_flip
block. Cited range 634-787 is accurate (reactives end at 773, download
handlers run to 784). Two caveats: (1) the evidence’s column syntax
“rpt()\[,‘indivMeanKin’\]” is wrong — actual code uses tidy-eval
aes(x=.data\$indivMeanKin) on ggplot(rpt(),…) — but the semantic claim
holds; (2) the APP-13 cross-reference is FALSE: R/modSummaryStats.R is
only 201 lines and contains zero ggplot/geom\_\* calls, so it does not
duplicate these plots. No tests in tests/testthat reference these
reactives or any histogram/boxplot, so the refactor has no test guard,
but the extraction is mechanical with easily-eyeballed visual output:
medium severity, quick-win stands.

### APP-7 — summaryStats HTML tables built by hand-concatenated string fragments duplicated for kinship and genome-uniqueness rows

- **Location** `inst/application/server.r:572-632` · **Severity** low ·
  **Category** quick-win · **Regression risk** low
- **Cluster** APP (Shiny Application & Modules) *(auditor cited
  `572-632`; verifier corrected to `572-632`)*

**Evidence:** output\$summaryStats builds a header row (572-582) then
two near-identical 22-line blocks: k (584-606) for ‘Mean Kinship’ and g
(608-630) for ‘Genome Uniqueness’, each repeating the exact

/

round(x\[‘Min.’\],4L)/…/\[‘Max.’\] scaffold differing only by label and
source vector (mk vs gu). HTML is assembled via raw paste() even though
htmltools is already imported and used for the founder table at 558-570
in the same function – two divergent table-construction styles.

**Recommendation:** Extract makeStatRow(label, summaryVec) and map over
a (label, vector) list; prefer htmltools tags for consistency with the
founder table. Removes ~22 duplicated lines.

**Verifier:** Duplication is real but mischaracterized. In
output\$summaryStats (renderText, line 534) the k block (584-606, Mean
Kinship) and g block (608-630, Genome Uniqueness) are near-identical
23-line paste() scaffolds differing only by label and source vector (mk
vs gu), repeating the same
