# The App's Kinship Memory: Design (Phase 8 of the Performance and Memory Campaign)

**Session:** S1062, 2026-10-25. A design session: nothing under `R/` or `tests/` changed.
**Status:** RULED by the owner, S1062 (2026-10-25), each as recommended:
- **D5:** option (c), each tab computes its own kinship (section 6);
- **findings F2-F4:** filed as their own `BACKLOG.md` items (section 9);
- **the scripted app session:** committed in Phase 9 (F6).

Phase 9 is next.
**Plan:** `docs/planning/performance-memory-campaign-plan.md`: Phase 8 (`:626-636`), D5 (`:349-357`),
H6 (`:203-217`), Phase 9 (`:638-644`).
**Code read:** HEAD `d750f818e` (the `R/` and `tests/` trees of `37997db3f`).
**Inputs:** Phase 0's app memory table (`docs/audits/PERF_BASELINE_2026-10-24.md` section 4), Phase 6's
numbers (S1059), and this session's measurements. The scratch scripts are summarized in Appendix A.

---

## 1. In plain words

- **What the app keeps today.** The app builds one table of kinship between every pair of
  animals in the loaded pedigree, and keeps it for the whole session (`R/appServer.R:353-367`).
  - For the example's 3,694 animals that table is 104.6 MB.
  - For a 10,000-animal colony (synthetic) it is 764.2 MB. It takes 4.07 s to build, and memory
    peaks at 1,148.7 MB while it is built.
- **When it is built.** At upload, before any tab is opened. The Genetic Diversity tab's
  readiness check reads the table before it checks whether any groups exist
  (`R/modGeneticDiversity.R:119`, `:188`). Upload holds about 170 MB more because of it (section 2.2).
- **Who reads it.** Five tabs read it, in seven ways (section 3):
  - Three need only a few animals: Breeding Groups (20 by default), Genetic Diversity (the group
    members) and Mate Pair (its population).
  - Four need every animal: two Summary Statistics downloads (the kinship CSV and the relationship
    files), and two Marker Genetics results.
- **The values stay the same.** A pair's kinship depends only on the two animals' ancestors. So a
  tab can compute kinship for its own animals plus their ancestors and get exactly today's values.
  This was measured with `identical()` on 12 sets of animals, twins included. Two rules are needed:
  - twins are kept by group, not by pair;
  - overrides are cut to the set before they are applied (section 4).
- **Recommendation (D5 option c).** Nothing of the whole colony's size is kept between clicks.
  - Each tab computes the kinship it needs when the user asks.
  - The four every-animal actions build the full table at that moment and let it go. On the
    example each takes 0.42 s more; on the synthetic colony, 4.07 s.
- **Two larger costs, outside D5.**
  - Mate Pair's default run, "All alive", pairs the example's 1,704 animals with no exit date:
    +1,079 MB of app memory, 11.3 s.
  - Marker Genetics' Realized Relatedness table holds all 6,824,665 pairs: +716 MB, 13.5 s, when
    its tab is opened.

  Each is bigger than the kinship table itself (section 9).

## 2. What the app holds today (measured)

### 2.1 The shared matrix

`sharedKinshipMatrix` is a `reactive()` (`R/appServer.R:353-367`). It is computed once from
`shared$currentPedigree`, with the twin declarations and the Genetic Value tab's kinship
overrides. It is cached until one of those three changes, so it lives for the whole session.

| Pedigree | Animals | Build time | Peak while built | Held for the session |
|---|---|---|---|---|
| example (`ExamplePedigree.csv`, after QC) | 3,694 | 0.42 s | 153.8 MB | 104.6 MB |
| synthetic 10,000 (`synthColony(10000, seed = 1)`, after QC) | 10,000 | 4.07 s | 1,148.7 MB | 764.2 MB |
| 20,000 animals | 20,000 | | | about 3.2 GB (arithmetic, n² x 8 B) |

Each row with a measured time comes from one call in a fresh R process (`p8/cost.R`, Appendix A).
"Synthetic" is a generated colony: no real studbook above 3,694 animals is in the repository
(`BACKLOG.md:51`).

**When it is built.** `kinship()` and `convertRelationships()` were traced in the running app
(`p8/app/app.R`, `p8/drive.R`). On the example, each call is shown with the step that made it:

| Step | App memory (RSS) | Kinship work done in that step |
|---|---|---|
| app started | 422.9 MB | |
| upload + QC | 687.7 MB | `kinship()` on 3,694 animals, called from Genetic Diversity's `diversityPlot()` > `diversityStats()` |
| open Genetic Diversity (no groups) | 689.9 MB | none |
| Genetic Value run (1,000 iterations) | 858.7 MB | `kinship()` on 708 animals (`reportGV()`'s own) |
| open Summary Statistics | 861.1 MB | none |
| Breeding Groups: Form Groups (defaults) | 866.8 MB | none (reuses the shared matrix) |
| open Genetic Diversity (groups formed) | 867.2 MB | none |
| Mate Pair: Find Eligible Pairs (defaults) | 1,946.3 MB | none (reuses it); the step's own pair work, section 9 |
| open Marker Genetics | 1,946.3 MB | none |
| open its Linkage and LD Block Metrics tab | 2,662.4 MB | `convertRelationships()` on 3,694 animals (Realized Relatedness) |

The cause is `R/modGeneticDiversity.R:115-127`. `diversityStats()` reads the groups, the pedigree,
the report and the kinship matrix (`:119`) before it checks whether any of them is missing. Its
readiness observer (`:188-194`) runs as soon as a pedigree is loaded, so the observer builds the
whole matrix and then discards the result, because there are no groups yet.

### 2.2 What the early build costs at upload

The same short session, run twice with today's code and twice with Genetic Diversity changed so
that it asks for kinship only once groups exist. The change was made in the scratch app
(`p8/app_lazy/app.R`), not in the package.

| Step | Today, run 1 | Today, run 2 | Groups first, run 1 | Groups first, run 2 |
|---|---|---|---|---|
| app started | 422.3 MB | 417.5 MB | 417.0 MB | 422.8 MB |
| upload + QC | 687.4 MB | 682.1 MB | 512.6 MB | 519.0 MB |
| Genetic Value run | 846.2 MB | 842.5 MB | 622.6 MB | 627.5 MB |
| open Summary Statistics | 864.8 MB | 855.2 MB | 678.4 MB | 684.3 MB |
| Breeding Groups: Form Groups | 870.6 MB | 861.3 MB | 808.3 MB | 814.1 MB |
| open Genetic Diversity (groups formed) | 871.1 MB | 861.7 MB | 808.7 MB | 814.4 MB |

**Two findings from these runs:**

- **At upload:** the app holds 163 to 175 MB less when the early build is gone.
- **Waiting alone does not save it:** with the early build gone, Form Groups builds the full
  matrix instead (+130 MB in that step, traced as `getKinshipMatrix`).

So waiting until a tab asks saves memory only in a session that never forms groups or runs a
kinship tab. Resident memory seldom falls when R frees memory (Phase 0's note), so these are
high-water marks, not live sizes.

### 2.3 Other kinship copies the app keeps

- **Genetic Value tab:** `reportGV()` computes kinship on the analysis pedigree (the population
  plus its ancestors) and keeps the probands' block (`R/reportGV.R:209-213`; exposed at
  `R/modGeneticValue.R:563-566`). That is 708 animals computed and 332 kept on the example (0.9 MB);
  6,090 computed and 2,981 kept on the synthetic colony (68.2 MB). It already works the way
  option (c) proposes.
- **Breeding Groups:** keeps the matrix it was handed in its results
  (`R/modBreedingGroups.R:814-815`). Today that is the shared matrix itself, which R shares
  rather than copies, so it adds nothing until the shared matrix is replaced. It is read only for
  the selected group's kinship table (`:1191-1196`).
- **Pedigree Diagram:** computes its own kinship to mark consanguineous matings
  (`R/makePedigreeDiagramData.R:1860`). It covers at most 750 animals, about 4.5 MB, and is not
  part of D5.

## 3. The consumers: what each reads, and when

Five modules receive `sharedKinshipMatrix` (`R/appServer.R:378,426,453,466,481`). The plan's
summary says "handed to six tabs"; the code hands it to five, read in seven ways:

| # | Tab | Result | Animals it needs | When it asks | Needs every animal? |
|---|---|---|---|---|---|
| 1 | Summary Statistics | the kinship CSV download (`R/modSummaryStats.R:840-845`) | every animal | the download click | yes: the file is the whole matrix |
| 2 | Summary Statistics | the relationships and relationship-classes downloads (`:423-436`, `:878-894`; `convertRelationships()` on the whole matrix) | every pair | the download click | yes: every pair is a row |
| 3 | Breeding Groups | group formation: `groupAddAssign()` cuts the matrix to the candidates and seed animals (`R/groupAddAssign.R:206`); the group kinship table (`R/modBreedingGroups.R:1191-1196`) | candidates plus seed animals (20 by default) | Form Groups | no |
| 4 | Genetic Diversity | the heat map's inbreeding index: `getKinshipWithMaleStatus()` per group (`R/getGeneticDiversityStats.R:134-136`) | the formed groups' members | today at upload (section 2.1); by intent, once groups exist | no |
| 5 | Marker Genetics | Kinship Comparison: each genotyped animal's pedigree mean kinship, `meanKinship(pedKmat)[ids]` (`R/modMarkerGenetics.R:576-580`), the mean over every animal in the pedigree (`R/meanKinship.R:30-32`) | every animal, to keep one number per genotyped animal | a genotype file upload | yes, for the whole computation; only the means are kept |
| 6 | Marker Genetics | Realized Relatedness: `markerRealizedRelatednessVariance()` (`:716-729`, shown at `:1072-1076`), which calls `convertRelationships()` on the whole matrix (`R/markerRealizedRelatednessVariance.R:119`) | every pair | opening the "Linkage and LD Block Metrics" tab (`R/modMarkerGenetics.R:227`) | yes: every pair is a row |
| 7 | Mate Pair | `reportMatePairs()` cuts the matrix to the population (`R/reportMatePairs.R:196`), then builds its pairs (`:207`) | the population: "All alive (no recorded exit)" by default (`R/modMatePair.R:39-45`), 1,704 animals on the example | Find Eligible Pairs | no |

Notes:

- **What "needs" means.** Only rows 1, 2 and 6 need every pair. Row 5 needs every animal's
  kinship with the genotyped animals, and the existing `kinship()` gets that only by computing the
  whole matrix.
- **Fallbacks.** Summary Statistics and Breeding Groups each keep a fallback that recomputes the
  whole matrix when no matrix is handed in (`R/modSummaryStats.R:384-417`,
  `R/modBreedingGroups.R:357-381`). In the app the shared matrix is always handed in, so the
  fallbacks run only in scripts and tests.
- **Plain matrices only.** `reportMatePairs()` stops on anything but a base matrix
  (`R/reportMatePairs.R:185`); `write.csv()`, `colMeans()` and `convertRelationships()` also take
  base matrices.

## 4. Exactness: the same values from a smaller pedigree

### 4.1 Why the values are the same

`kinship()` fills animals generation by generation (`R/kinship.R:203-253`). Each animal's row is
the average of its parents' rows, and its own cell is half of one plus its parents' kinship.

- **Animals outside the set change nothing in it.** Take a set of animals together with all of
  their ancestors. Every cell between two animals of that set is computed from cells between
  animals of the same set. An animal outside it writes only its own row and column.
- **Order does not change any bit.** The values are sums of powers of one half, which a double
  holds exactly at these depths. So even a different fill order gave identical bits: two
  shuffled-order cases below.

### 4.2 Measured (`p8/exact.R`, the example's 3,694 animals after QC)

Each row compares `filterKinMatrix(ids, full)` with `filterKinMatrix(ids, kinship of ids plus
ancestors)` using `identical()`.

| Set | Animals asked for | Computed on | identical() |
|---|---|---|---|
| first 20 living (Breeding Groups' top-20 shape) | 20 | 75 | TRUE |
| all living (`isLivingAnimal()`) | 332 | 708 | TRUE |
| 100 drawn from the whole pedigree, dead included | 100 | 346 | TRUE |
| no exit date (Mate Pair's "All alive") | 1,704 | 1,898 | TRUE |
| every animal | 3,694 | 3,694 | TRUE |
| all living, rows shuffled before `kinship()`, put back after | 332 | 708 | TRUE |
| 100 drawn, rows shuffled the same way | 100 | 346 | TRUE |
| MZ pair A-B, both twins in the set | 22 | 79 | TRUE |
| MZ pair A-B, one child of each twin in the set | 2 | 28 | TRUE |
| MZ pair A-B, only A and A's children in the set | 3 | 39 | TRUE |
| MZ chain A-B, B-C, set {A, C}, twin rows kept by **pair** | 2 | 12 | **FALSE** (off by 0.25) |
| the same, twin rows kept by **group** | 2 | 12 | TRUE |
| MZ chain, one child of A and one of C, by **pair** | 2 | 39 | **FALSE** (off by 0.0625) |
| the same, by **group** | 2 | 39 | TRUE |
| overrides, only the rows whose two animals are in the set | 15 | | TRUE |
| overrides, every row passed | 15 | | TRUE, but with a false warning |

The twins are stand-ins: three full siblings that each have offspring (F0FUD5, N755BM, R6HV9A),
declared MZ. `kinship()` checks only that both ids are present (`R/kinship.R:163-166`), so any
pair can be declared.

### 4.3 Three rules for the subset computation

1. **Trim with `getProbandPedigree()`.** It keeps the pedigree's own row order
   (`R/getProbandPedigree.R:27`, `ped[ped$id %in% probands, ]`). `filterKinMatrix()` returns rows
   in the matrix's order, not in the order the ids were asked for (`R/filterKinMatrix.R:27-29`), so
   every consumer's rows come out in today's order.
2. **Keep MZ twins by group, not by pair.** `kinship()` corrects a whole chain of MZ declarations
   at once (A-B and B-C make A-C identical too; `R/kinship.R:157-191`). Dropping each declaration
   that names an animal outside the set loses the A-C correction. So form the groups on the full
   declaration list first, then chain the group members that are in the set. DZ and UZ rows
   change no value (`R/kinship.R:36-38`); keep only those whose two animals are in the set.
3. **Cut the overrides to the set after the pedigree check, before applying them.** If every row
   is passed, `applyKinshipOverridesToMatrix()` (`R/applyKinshipOverridesToMatrix.R:22-43`) warns
   "Dropping 1 kinship override row(s) referencing id(s) not in the analysis set: Y3CJ5A, 01QRQ4."
   That is false: both animals are in the pedigree. Today it warns only about animals missing
   from the pedigree.
   - Keep that warning by checking against the pedigree first, with today's wording.
   - Then pass on only the rows inside the set.
   - Its message "N kinship override(s) applied." will then count only the set's overrides.

## 5. The options (D5), with measured costs

The numbers come from sections 2 and 4. "Held" means memory kept between clicks.

| | (a) Today | (a') Today, built when a tab first asks | (b) One sparse full matrix | (c) Each tab computes its own animals | (d) (c) for the three small consumers, one cached full matrix for the four every-animal ones |
|---|---|---|---|---|---|
| Built at upload | yes, 104.6 MB (example), 764.2 MB (synthetic) | no | yes | no | no |
| Held after Form Groups | the full matrix | the full matrix | the sparse matrix | the candidates' block: under 0.1 MB at 20 animals, 0.9 MB at the example's 332 living | as (c) |
| Held after an every-animal action | the full matrix | the full matrix | the sparse matrix | nothing of kinship (the table the action built, section 9) | the full matrix |
| Breeding Groups default click | 0 s (cached) | 0.42 s the first time | densify a block | under 0.01 s (75 animals) | under 0.01 s |
| Each every-animal click | 0 s (cached) | 0.42 s / 4.07 s the first time | densify the whole | 0.42 s / 4.07 s every time, peak 153.8 / 1,148.7 MB | 0.42 s / 4.07 s the first time |
| Same values | yes | yes | yes | yes, measured (section 4) | yes |
| Code change | none | Genetic Diversity's order of checks | every consumer densifies, plus a new build | one helper, five modules, `appServer()` | as (c), plus a cache |

**Why not (b), sparse.** On the example, 92.7% of the cells are 0, so the sparse matrix would be
11.9 MB. But:

- **Slow to build.** `kinship(sparse = TRUE)` takes 45.43 s on the 3,694 animals (Phase 0,
  `kinshipSparse-all`) against 0.42 s dense (section 2.1).
- **Converting costs more memory than today.** A dense-to-sparse conversion briefly took 1,415 MB
  at 6,090 animals (plan, D5).
- **Small saving on dense colonies.** The synthetic colony's 6,090-animal analysis set is only
  54.5% zeros: 97.4 MB sparse against 283.7 MB dense (plan, section 1).
- **Plain tables still needed.** Every consumer needs a plain matrix (section 3, notes), so each
  click would rebuild a dense block, and the four every-animal actions would rebuild the whole.

**Why not (a'), on its own.** It is the smallest change, and it saves the 170 MB at upload. But
the first Form Groups or Mate Pair click builds the whole matrix and keeps it (section 2.2).

**Why (c) over (d).** (d) makes a second every-animal click faster: 0 s instead of 0.42 s on the
example, or instead of 4.07 s on the synthetic colony. In exchange it keeps 104.6 or 764.2 MB for
the rest of the session. These actions are downloads and an analysis tab, used now and then.

## 6. Recommendation and the owner's ruling

**Recommended: (c).** Every tab computes kinship for the animals it uses, plus their ancestors,
when the user asks. Nothing of the whole colony's size is kept between clicks.

**Owner's ruling (D5), S1062 (2026-10-25): option (c), "Each tab computes its own", as
recommended.** Phase 9 builds section 6.1.

### 6.1 The shape of the change (for Phase 9; names are proposals, renamed only before RED)

- **One internal helper,** `kinshipForAnimals(ped, ids = NULL, twinRelations = NULL, overrides = NULL)`:
  - `ids = NULL` means every animal.
  - Otherwise it trims with `getProbandPedigree()` and keeps the twin rows by group.
  - It warns about override ids missing from the pedigree, in today's words, then applies the
    rows inside the set.
  - It uses the pedigree's `gen` column when present, as `sharedKinshipMatrix` does
    (`R/appServer.R:356-358`).
  - It returns a base matrix in pedigree order.
- **`appServer()`** replaces `sharedKinshipMatrix` with a provider: a function of `ids` that
  reads `shared$currentPedigree`, `shared$twinRelations` and the overrides, and calls the helper.
  Called inside a consumer's `reactive()` or handler, it takes the same reactive dependencies the
  shared matrix has today.
- **The five module servers** (exported) gain one optional argument, `kinshipFor = NULL`.
  - `kinshipMatrix` stays: a caller that hands in a matrix gets today's behavior, so scripts and
    the module tests that pass one keep working.
  - Order: a handed-in `kinshipMatrix` first, then `kinshipFor`, then the module's own fallback
    (Summary Statistics and Breeding Groups only).
- **Each consumer:**
  - **Breeding Groups:** asks for `union(candidateIds, unlist(currentGroups))` at Form Groups.
    Its results keep that block only.
  - **Genetic Diversity:** checks the groups, the pedigree and the report first. Only then does
    it ask, for `unique(unlist(groups))`.
  - **Mate Pair:** asks for `popIds` at Find Eligible Pairs.
  - **Summary Statistics, three downloads:** ask for every animal inside each download handler.
  - **Marker Genetics:** asks for every animal inside `comparison()` and keeps only the means.
    Realized Relatedness asks for every animal too.
- **Unchanged:** the Genetic Value tab, the Pedigree Diagram, and every exported analysis
  function's arguments and results (D3).

## 7. The tests

### 7.1 New bit-identity tests (Phase 9's RED)

In a new `tests/testthat/test_kinshipForAnimals.R`, each with `identical()` against
`filterKinMatrix(ids, kinship(<whole pedigree>))`:

1. **The sets of section 4.2** on the example after QC: the first 20 living, all living, 100
   drawn with dead included, no exit date, every animal. Also on `qcPed` and `lacy1989Ped`.
2. **Twins: the five MZ cases of section 4.2.** The pair: both twins; one child of each; one
   twin and its children only. The chain A-B, B-C: the set {A, C}; one child of A and one of C.
   Plus `test_kinship.R`'s fam1 (8 and 9 MZ, 10 a child of 8, as reused at
   `tests/testthat/test_appServer_server.R:274-289`) with sets holding 10 and 9 but not 8.
3. **DZ and UZ rows:** one naming an animal outside the set changes nothing and raises no error.
4. **Overrides,** applied to the whole matrix and then cut, against the helper:
   - one inside the set;
   - one naming an animal of the pedigree outside the set (no warning);
   - one naming an id absent from the pedigree (today's warning, same count and ids).
5. **Row order and names:** the result's dimnames are the pedigree's order.
6. **Each consumer, before and after.** The module under `testServer()` given today's full
   matrix, against the same module given `kinshipFor`:
   - Breeding Groups: the whole `groupAddAssign()` result for seeds 1, 7 and 2026, plain and
     harem;
   - Genetic Diversity: `stats()`;
   - Mate Pair: the report;
   - Summary Statistics: the three downloads' file bytes;
   - Marker Genetics: the comparison and Realized Relatedness tables.

   These are equal by `identical()`.

Mutation check, as each phase does: a helper that keeps twins by pair, or that does not cut the
overrides, must make tests 2 and 4 fail.

### 7.2 Existing tests that must pass unchanged

- **Kinship values:** `test_kinship.R`, `test_kinshipMemoryEquivalence.R`.
- **Twins in the tabs:** `test_modBreedingGroups_twinRelations.R`, `test_modSummaryStats_twinRelations.R`.
- **What the Genetic Diversity tab shows and when it waits:**
  `tests/testthat/test_appServer_server.R:815`, `:839`, `:856`.
- **The consumer modules:** `test_modGeneticDiversity.R`, `test_modMatePair.R`,
  `test_modMatePair_ancestry.R`, `test_modMatePair_ancestryOverrides.R`, `test_modMarkerGenetics.R`,
  `test_modSummaryStats.R`, `test_modSummaryStats_relationships.R`,
  `test_modSummaryStats_kinshipOverrides.R`, `test_moduleContract.R`.
- **The browser tier:** `test-e2e-breeding-groups-*.R` (5 files), `test-e2e-mate-pair-analysis-module*.R`
  (2), `test-e2e-summary-statistics-*.R` (2), `test-e2e-marker-genetics-ld-block-module.R` and
  `test-e2e-twin-relations-cross-tab.R`.

If any of these changes, that is a finding to put to the owner, not an edit to make.

### 7.3 Existing tests that pin today's wiring and change by design

- **`tests/testthat/test_appServer_server.R:632-684`** ("appServer passes the SAME shared
  kinship reactive to both ..."). It asserts that Summary Statistics and Breeding Groups get the
  same reactive object (`:684`) and that its value is the whole pedigree's kinship. It becomes:
  both get the same provider, and the provider with `ids = NULL` gives that value.
- **`tests/testthat/test_appServer_server.R:292-345`** reads `sharedKinshipMatrix()` by name
  (`:317`) to check that the twin declarations reach it. It becomes the same check through the
  provider.
- **`tests/testthat/test_appServer_server.R:778-813`** asserts that Genetic Diversity gets the
  same reactive object as Summary Statistics (`:810`) and that its rows are every pedigree animal
  (`:812`). It becomes: the same provider. The tests that follow, `:815`, `:839` and `:856`,
  check what the tab shows and when it waits, including S993's rule: a group holding a living
  animal outside the focal population. They must pass unchanged.
- **`tests/testthat/test_modBreedingGroups_sharedKinship.R:19` and `:49`** call the module's
  internal `getKinshipMatrix()` with today's three arguments. The behavior they pin stays: a
  handed-in matrix is used as is, and with none the fallback recomputes the whole pedigree. They
  change only if Phase 9 changes that helper's arguments, so Phase 9 re-reads them before RED.

## 8. Phase 9 under (c): scope, sessions, DONE and surface

- **Sessions.** The change touches 7 `R/` files (the helper, `appServer.R`, five modules) and
  their tests. That is past the 5-file cap, so it needs checkpoint commits. The plan allows one or
  two sessions; two are proposed:
  - **9a:** the helper and its tests (7.1, items 1 to 5), then Breeding Groups, Genetic Diversity
    and Mate Pair through the provider.
  - **9b:** the four every-animal reads, then `sharedKinshipMatrix` removed, then the app memory
    table re-measured.
- **The scripted app session joins `tools/perf/` (owner, S1062, F6).** This is the session of
  `docs/audits/PERF_BASELINE_2026-10-24.md` Appendix A, plus this design's Genetic Diversity,
  Mate Pair and Marker Genetics steps and its `kinship()` trace (Appendix A here).
  - It needs Chrome and an installed copy, so it is not a ratchet gate. Its test checks only that
    it parses and lists its steps.
  - It is committed in 9a, so that 9a's "before" numbers come from the committed tool.
- **DONE when:**
  - the 7.1 tests pass, and the 7.2 tests pass unchanged;
  - the full suite gives 0 failed and 0 errors, lint gives 0, and `devtools::check()` is clean;
  - the browser tier's kinship tabs pass;
  - the app memory table of section 2.2 is re-measured before and after.

  Expected: upload + QC about 170 MB lower, and no step builds a 3,694-animal `kinship()` except
  the four every-animal actions (the trace shows each call).
- **Surface.** The running app on this Mac, through `shinytest2`: resident memory per step, plus
  the `kinship()` trace. Unit-level object sizes cannot show what a session holds. CI's three
  platforms show the bit-identity tests. Neither shows a real colony above 3,694 animals.

## 9. Findings outside D5

**Owner's ruling, S1062:** F2, F3 and F4 are filed as their own `BACKLOG.md` items, each with
the decision it needs. Phase 9 stays about how kinship is held.

- **F1. The early build at upload** (section 2.1). Options (a'), (c) and (d) all remove it. Under
  (a) it stays.
- **F2. Mate Pair's default run is the largest step measured: +1,079 MB and 11.3 s on the
  example.** "All alive (no recorded exit)" is 1,704 animals here (the 332 `isLivingAnimal()`
  animals are a stricter rule). `reportMatePairs()` builds the long form of every pair among them
  (`R/reportMatePairs.R:207`) and then screens it. The kinship block itself is 22.4 MB. This is
  that tab's own work, and the same under every D5 option.
- **F3. Marker Genetics' Realized Relatedness table holds every pair.** That is 6,824,665 rows on
  the example (the page said "Showing 1 to 10 of 6,824,665 entries"). Building it took 8.31 s with
  a 707.6 MB peak, and the table is 390.9 MB (`p8/reltable.R`). Opening the tab cost +716 MB of
  app memory and 13.5 s. The table is kept while the tab shows it. Under every D5 option it still
  needs every pair, unless its scope changes: related pairs only, as D8 asks for the download.
- **F4. Summary Statistics keeps the relationship table after a download.** `relationshipData()`
  is a cached `reactive()` (`R/modSummaryStats.R:423-430`): 6,824,665 rows, 234.7 MB, built in
  3.21 s with a 693.5 MB peak. It serves both relationship downloads and is kept until the
  pedigree changes.
- **F5. The plan's count of consumers.** H6 and the summary say six. The code hands the matrix to
  five modules, which read it seven ways (section 3).
- **F6. Phase 0's scripted app session** (`docs/audits/PERF_BASELINE_2026-10-24.md`, Appendix A)
  is not committed. Phase 0 left to Phase 8 whether it joins `tools/perf/`. This session's
  `p8/drive.R` extends it with the Genetic Diversity, Mate Pair and Marker Genetics steps and the
  `kinship()` trace. **Ruled S1062:** it joins `tools/perf/` in Phase 9 (section 8).

## 10. Alternatives considered

- **Reuse the Genetic Value tab's proband matrix for the three small consumers.** Rejected.
  - It exists only after an analysis is run, and the tabs must work before one (the module-contract
    plan's Dragon 3).
  - It covers only the focal population. Groups and seeds can hold other living animals (S993,
    docs-audit CA2; `tests/testthat/test_appServer_server.R:815`).
- **A kinship strip** (every animal against the genotyped animals only) for Marker Genetics'
  comparison. Not proposed. `kinship()` fills the whole matrix, and a strip needs a new algorithm
  with its own exactness proof. The full computation is kept only long enough to take the means.
- **Fixing only F1** is option (a'), covered in section 5.

## 11. What this design cannot show

- **No real large colony.** There is no real studbook above 3,694 animals; the 10,000-animal
  numbers are synthetic.
- **(c)'s end-of-session memory is estimated, not measured.** The scratch runs measured today and
  "groups first" (a'). Under (c) the Form Groups step would not build the whole matrix, so the
  session should end near the "groups first" runs' level before that step: about 680 MB against
  today's 862 to 871 MB on the example. That is an estimate; Phase 9 measures it.
- **Other machines.** Windows, Linux and the browser's own memory are not measured.

## Appendix A. The scratch measurements (S1062; not committed)

All ran from this session's scratch folder against the working tree at `d750f818e`, on an Apple M2
Max with R 4.6.1. The load average was 4.2 to 5.8.

- **`p8/exact.R`** (section 4.2): `appAnalysisPed(examplePedigree, trim = FALSE)` from
  `tools/perf/harness.R`. Each set is trimmed with `getProbandPedigree()`, its kinship computed,
  and `filterKinMatrix(ids, ...)` compared with the full matrix by `identical()`. The group rule
  forms MZ groups by union over the full declaration list, then chains each group's kept members.
- **`p8/cost.R <scenario>`** (sections 2.1 and 5): one `measure()` of `kinship()` per fresh
  `Rscript` process (Phase 0's procedure: `gc(reset = TRUE)`, then "max used" minus the starting
  use).
- **`p8/app/app.R` + `p8/drive.R`** (section 2.1): a scratch `app.R` that runs
  `pkgload::load_all()` on the working tree and `trace()`s `kinship()` and `convertRelationships()`
  in the namespace, logging each call's size and the module functions on the call stack. The
  driver starts the app with `shinytest2::AppDriver`, uploads `ExamplePedigree.csv`, takes the
  steps of the table, and reads the app process's resident memory (`ps -o rss=`) after each.
  It was run with `R_LIBS=<renv library>`, `RENV_CONFIG_AUTOLOADER_ENABLED=false` and
  `NOT_CRAN=true`, from a folder outside the project.
- **`p8/app_lazy/app.R`** (section 2.2): the same app, with `modGeneticDiversityServer` wrapped by
  `assignInNamespace()` so that its kinship reactive returns `NULL` until groups exist.
- **`p8/reltable.R`** (section 9): one `measure()` each of `convertRelationships()` and
  `markerRealizedRelatednessVariance(nChr = 20, mapLength = 28)` on the example's full matrix.
