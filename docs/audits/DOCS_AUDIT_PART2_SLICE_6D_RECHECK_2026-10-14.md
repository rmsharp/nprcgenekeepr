# Docs audit, part 2: the 21 slice 6d code candidates, re-checked against today's code (2026-10-14, S991)

Read-only audit. Nothing in the repo was changed except this report and the session records. No fix was made: every
fix below is a code, comment or help-text change and needs your ruling and its own session.

## Audit summary

- **Scope:** the 21 "code candidates" of docs-audit slice 6d (S840, `DOCS_STALENESS_AUDIT_SLICE6D_2026-10-01.md`, the
  "Shiny application and modules" man pages): CA1-CA5, CB1-CB5, CC1-CC5, CD1-CD6. `BACKLOG.md` has carried them
  without a re-check since S870 (S986 recounted 21 rows; the item once said 22). **Not covered:** the 8 moderate and 34
  minor *wording* findings of the same slice (the RA, RB, RC and RD ids); they were fixed in S841 and are not re-audited here.
  Slice 6e (46 candidates) and slices 7b and 8 stay open in `BACKLOG.md`.
- **Criterion:** is the behavior the slice described still what the code does; can a colony manager reach it through the
  app or only from a script; do the help pages say so; does a test pin it? Severity: **moderate** = reachable from the
  app and shows a wrong result or a stop; **minor** = documented, script-only, cosmetic or visible only to the test harness.
- **Method:** read each site in today's `R/` and its callers (`R/appServer.R`); ran probes from scratch scripts outside the
  repo, started from the project root so renv is active. The chain behind CA2 and CA3 was run **module by module with the
  app's own wiring** (Pedigree Browser with focal animals, then the Genetic Value report, the Breeding Groups pool and
  the Genetic Diversity module, on `qcPed`, 280 animals, 89 living). CD5 was also run **in the real app** (headless Chrome,
  `shinytest2`, the installed package; its pyramid module and UI, `getPyramidPlot()` and `getPyramidAgeDist()` deparse identically to the source, compared across two R processes). `git log` dated every candidate a later
  session touched.
- **Not done:** no browser click-through for CA2, CA3, CC1 or CC5 (module-level runs and reading only). CB3, CB4, CD4 and
  CA5 are read, not run. "My own list" was not run for CA2 (the same reading applies). The three `downloadButton`s of the
  Summary Statistics tab that do not carry the CD4 sentence were not checked. A zero-row studbook through
  `modPedigreeServer` ended the test session in an observer error; not followed up (CC2).
- **Result: 5 of 21 are closed by later sessions, 16 are still true.** Of the 16: **0 critical, 2 moderate (CA2, CD5),
  14 minor**. Seven of the 16 are already told truthfully by today's help (CA2, CA3, CA5, CB1, CC1, CC2, CC3), so what is left
  for them is a build or an acceptance, not wording. **One new minor finding (N1)**: a help sentence that was true when
  slice 6d fixed it and became false five days later, when S928 fixed CA4. Two of the slice's own impact claims do not hold
  today (CC2's "never FALSE" is not reproduced; CD3's "silently recomputes without the shared overrides" is wrong in the app).

## What changed since slice 6d (the five closed)

| ID | Slice 6d said | Today | Closed by |
|---|---|---|---|
| CA1 | "Upload list" has no upload control and acts like "All available" | the Source box is "Top ranked", "All available", "My own list"; "My own list" shows an "Animal IDs:" box (`R/modBreedingGroups.R:40-52`) | S970 (removed), S973 (built) |
| CA4 | a group member with no birth date stops `getKinshipWithMaleStatus()` ("subscript out of bounds") | module run, `qcPed` (47 undated animals): three groups of 12 living animals, **34 of the 36 members undated**, then 36 of 36: `stats()` returns 3 rows, `heatmap()` a ggplot, and the note under the map says "36 of the 36 animals ... have no birth date" | S928 (`79e54d7d4`, 2026-10-06) |
| CB2 | the `calcGenomeUniqueness` and `calcMeanKinship` check boxes are read nowhere | both names are gone from `R/modGeneticValue.R` (grep empty) | S969 |
| CC4 | `.currentEdgeStyle()` returns "rectilinear" but its comment says "direct" | the comment at `R/modPedigree.R:465-468` says "rectilinear (the default since S574)" | S882 (`67c83def8`, 2026-10-03) |
| CD6 | `pyramidStats` counts `sex == "M"` and `"F"` literally | `R/modPyramid.R:121-122` uses `sexCodes[["male"]]` and `sexCodes[["female"]]` | S876 (`01600af88`, 2026-10-02) |

## Findings: still true

### Finding 1 (CA2): the Genetic Diversity tab stops when a group holds a living animal outside the Genetic Value population (moderate; reachable from the app; documented in the help)

- **Location:** `R/appServer.R:441-446` passes `gvResults$kinshipMatrix`; `R/modGeneticValue.R:552-555` returns
  `fullResults()$kinship`, which `reportGV()` builds for the **proband** animals only (`R/reportGV.R:208-209`; the probands
  are `ped$population`, `R/modGeneticValue.R:302`); `R/modBreedingGroups.R:548-558` draws the "All available" pool from every
  **living** animal of the pedigree; `R/modGeneticDiversity.R:99-111` calls `getGeneticDiversityStats()` with no catch;
  the stop is `R/getKinshipWithMaleStatus.R:56-60`.
- **Evidence (module chain, `qcPed`):** focal animals UG5VGC and UDY8AD with the trim on: the Pedigree Browser's analysis
  pedigree has 5 animals, 2 flagged population, 3 living. The Genetic Value kinship matrix is **2 x 2**. The Breeding
  Groups "All available" pool is the 3 living animals, **1 outside the matrix** (Q0RGP7). `modGeneticDiversityServer`'s
  `stats()` then stops: **"kmat is missing kinship for group member(s): Q0RGP7"**. With the full-pedigree matrix instead
  (the shared one, `R/appServer.R:346-361`) the same groups score: a 2-row table, no error. The tab shows the stop in the
  heat map and the guidance box (the help already says the reactives error instead of returning `NULL`).
- **Why the old report's example changed:** the slice said dead animals caused it ("All available" with dead animals).
  Since S938 the pool is living animals only, so the trigger is now the focal-animal choice. With no focal animals the
  population is the living animals (`R/modPedigree.R:363-371`) and the matrix covers every group member: no error.
  "Top ranked" draws from the report's own ids: no error.
- **Reach:** from the app: choose focal animals on the Pedigree Browser, run Genetic Value, form groups from "All
  available" (or "My own list", read not run) with a living animal that is not a focal animal, open Genetic Diversity.
- **Also stale:** the comment at `R/appServer.R:438-440` says the module gets "the full kinship matrix". It gets the
  population-filtered one.
- **Not examined:** what such an animal's `Value` column counts as when it has no row in the Genetic Value report (the
  full-matrix probe ran, giving `Value` 1 for the one-animal group; whether that is right was not looked at).
- **Your ruling:** (a) give the module `sharedKinshipMatrix` (one argument, `R/appServer.R:446`, plus a test), after a
  first look at that `Value` column; (b) keep the matrix and replace the stop with a plain message ("these groups include
  animals outside the Genetic Value population; use Top ranked or clear the focal animals"); (c) leave it (documented).
  **Recommended: (a).** It is what the comment at `:438-440` says the code does, and the shared matrix is what the other
  consumers already get.

### Finding 2 (CD5): with no pedigree loaded, Download Plot on the Age-Sex Pyramid tab saves a pyramid of the packaged example (moderate; reachable from the app; measured by a click)

- **Location:** `R/modPyramid.R:136-153` (the handler: `png()`, `getPyramidPlot(ped = pedigreeData(), ...)`, `dev.off()`, no
  `req()`); the plot, the stats table and the height box each have `req(pedigreeData())` (`:104`, `:116`, `:129`);
  `R/getPyramidPlot.R:43-44` (`ped = NULL` means the packaged example, documented at its help `:14`); the app feeds
  `reactive(shared$currentPedigree)`, which starts `NULL` (`R/appServer.R:51`, `:326-329`).
- **Evidence (real app, headless Chrome, nothing loaded, Age-Sex Pyramid tab open):** the Download Plot button is visible; its
  URL answers `200 image/png`; `get_download("pyramid-downloadPlot")` saved a **45,680 B** PNG headed
  **"Total on 2026-Oct-14: 46"**, "Male = 11", "Female = 35" (the 46 living animals with a birth date in the packaged `qcPed` example, counted). Nothing on the picture
  says it is example data. (With the module alone and the default slider values the file was 27,115 B; the size follows the
  inputs.) The tab's own plot area is blank in the same state.
- **The `on.exit` half of the slice's note is code-only:** the handler has no `on.exit(dev.off())`, so a draw error between
  `png()` and `dev.off()` would leave a device open. I could not make the draw fail from the tab's inputs (a pedigree with
  no `birth` column, a zero-row pedigree and `NULL` all drew in the handler; at function level a bin width of 0 or -5
  drew, while `NA` and a non-numeric value stop `getPyramidPlot()` ("missing value where TRUE/FALSE needed"), which the
  slider cannot send). Open devices after every handler probe: 0.
- **Tests:** `test_modPyramid_coverage.R:27` pins that the handler writes a PNG with an explicit height; none covers no pedigree.
- **Your ruling:** (a) add `req(pedigreeData())` to the handler, as the three outputs beside it have (the browser then reports
  a failed download); (b) hide or disable the button until a pedigree is loaded; (c) leave and say so in the module help.
  **Recommended: (a)**, one line and a test with no pedigree first; add `on.exit(dev.off(), add = TRUE)` in the same edit.

### Finding 3 (N1, new): the Genetic Diversity help still says a missing birth date makes the reactives error (minor; help only)

- **Location:** `R/modGeneticDiversity.R:80-83`: "Errors raised inside `getGeneticDiversityStats` (a group member missing from the
  kinship matrix, **or a group member with a missing birth date**) are not caught". Written S841 (`8b2e51b54`, 2026-10-01),
  true then; **false since S928 (`79e54d7d4`, 2026-10-06)**, which changed the code and the module's observer but not this sentence.
- **Evidence:** CA4's run above: 34 of 36, then 36 of 36 group members undated, no error; the module shows a note instead
  (`R/modGeneticDiversity.R:139-150`).
- **Your ruling:** drop the clause, leaving "(a group member missing from the kinship matrix)". One sentence, one wording gate.

### The 14 minor findings still true

| ID | Today (file:line) and evidence | Reach | Help says it? | Test? | Proposed ruling |
|---|---|---|---|---|---|
| CA3 | `breedingGroups()` ends with the "Unused" bucket (`R/modBreedingGroups.R:873`, returned `:1157`); the Breeding Groups tabs call it "Unused animals" (`:1067-1073`, S961). **Real run** (`qcPed`, 2 groups asked, threshold 0.01): `hasUnused` TRUE, `groups()` and `nGroups()` both 3 (sizes 35, 33, 21); the heat-map stats label the rows **Group 1, Group 2, Group 3**, the Unused bucket included. `getGeneticDiversityStats()` already takes the labels from `names(groups)` (`R/getGeneticDiversityStats.R:44`, `:92`), but the list the app passes is unnamed | app | yes, `R/modGeneticDiversity.R:63-65` ("scores it as another group") | the bucket's treatment elsewhere is pinned; not the heat map | (a) name the last element "Unused animals" like the other tabs (the module that forms the groups knows `hasUnused`; the groups list is read by other tabs too, so its own session, PRE-RED first); (b) leave it out of the map; (c) leave. **Recommended (a)** |
| CA5 | the alerts say confirming will "unlock downloads" / "unlock exports" (`R/modDeidentifiedExport.R:289-293`, `R/modCrossCenterIdentity.R:377-380`); no download handler reads `confirmed()` (`:296-322`, `:383-421`); the merged-pedigree download still halts on `isClean()` (`:309-312`) | app | yes, "not hard-gated" (`modDeidentifiedExport.R:185-188`) | the reactive's flips are pinned (`test_modDeidentifiedExport.R:219-238`), not the download | (a) reword each alert to say what it does, e.g. "Confirm the export on the Configure & Preview tab before you share these files." and "Confirm the merge on the Preview tab before you share these exports."; (b) gate the downloads (changes the design ratified as "not hard-gated"); (c) leave. **Recommended (a)** |
| CB1 | separate-file mode: `tryCatch(checkGenotypeFile(genotype), warning = NULL, error = NULL)` drops a bad genotype file with no message (`R/modInput.R:490-507`) | app (Input tab, "separate pedigree and genotype files") | yes, `R/modInput.R:256-258` | a bad-file case is exercised, `test_modInput_qcStudbook.R:705-725` | (a) say why in the QC Summary, as S971 did for a one-file pedigree; (b) leave. **Recommended (a)** |
| CB3 | with the "categorical" ranking scheme `gvResults` returns at `R/modGeneticValue.R:370-372`, before the `setDataReady` message at `:389` | the E2E ready flag only; no user effect | no | none found | leave |
| CB4 | the `is.null(rawData)` read-error path returns at `R/modInput.R:468-485` without `setDataReady`; the other two error paths send it (`:428-432`, `:455-459`) | the E2E ready flag only | no | none found for the flag | leave |
| CB5 | `isReady = reactive(!is.null(comparison()))` (`R/modMarkerGenetics.R:1340`) is not read through `safeRead`. **Run:** a shared genotype file with a short row: `isReady()` and `comparisonTable()` both throw "line 3 did not have 3 elements". The data-ready observer is safe since S709 (`:1318-1328`); the module comment says a malformed upload is meant to surface as a real error (`:527-533`) | app (Marker Genetics upload) | the help says `isReady` is "TRUE once `comparisonTable` has a value" (`:479`) | the MHC case is pinned as a real error (`test_modMarkerGenetics.R:1397`) | (a) read `comparison()` through `safeRead` inside `isReady` only (one line, a test); (b) leave. **Recommended (a)**: a name that says "ready" should not throw |
| CC1 | `twinRelationsData()` validates against `pedigreeData()`, the focal-trimmed, unknown-hidden view (`R/modPedigree.R:526-544`) and exports the result app-wide (`:956-958`). **Run (`qcPed`):** a pair of full sibs is valid on the whole pedigree; with one member removed the call stops "Twin relation id(s) not found in the pedigree: SFDEWY", and a sidecar with a second, valid pair stops the same way, so **both pairs go**. The code comment (`:521-524`) says such a pair is "treated as unknown/ignored": false | app (twin file, then a focal trim that leaves one member out); an error notification names the id, not the trim | yes, `R/modPedigree.R:236-239` ("one id outside ... the whole sidecar becomes `NULL`") | the module's twin tests exist; none for the trimmed case | (a) validate against the whole studbook the module received, not the view (needs a probe of the layout builder with pairs outside the view first); (b) drop only the pairs with a member outside and say so; (c) leave. **Recommended (a)** |
| CC2 | `isReady` is `!is.null(pedigreeData()) && nrow(pedigreeData()) > 0L` (`R/modPedigree.R:949-951`). **Run:** with no studbook `isReady()` and `nAnimals()` raise a silent `req` error (class `shiny.silent.error`), not FALSE and 0. The slice's "can never return FALSE" is **not reproduced**: only a zero-row view would give FALSE, and I could not build one the module survives | the Pedigree Browser's return value, read by `appServer` | yes, `R/modPedigree.R:231-233` | none found | leave |
| CC3 | the default `pedigree = NULL` of `modPotentialParentsServer` is unusable: `observeEvent(pedigree(), ...)` (`R/modPotentialParents.R:253`) fails **"could not find function \"pedigree\""** (run). `appServer` always passes a reactive (`R/appServer.R:502-504`) | script only | yes, `R/modPotentialParents.R:196-198` | none for the default | leave, or (b) drop the default so the call fails at once with the argument's name; **recommended: leave** |
| CC5 | "Export Demographics" writes the whole pedigree as it is (`R/modORIPReporting.R:339-351`; button `:69`). The tab's own list of what is not built names breeding success, founder contribution and PDF reports | ONPRC site configuration only (`R/appServer.R:409`) | no | **yes, as intended**: `test_modORIPReporting_server.R:282` is named "downloadDemographics writes the pedigree" | your call (what ORIP wants is yours to say): (a) rename the button and file to say "pedigree"; (b) build the demographics summary; (c) leave |
| CD1 | the help text is styled `color: darblue` (`R/modPyramid.R:46`); a browser ignores an unknown color, so the line shows in the page's default color, bold | app, cosmetic | n/a | none | fix the spelling (one word; a test that the style names a real color) in the housekeeping session |
| CD2 | the comment at `R/modSummaryStats.R:393-395` says "the path the app always takes since appServer passes kinshipMatrix=NULL"; `appServer` passes `sharedKinshipMatrix` (`R/appServer.R:374-382`, since issue #122 Phase 2) | comment only | n/a | `test_appServer_server.R` names the shared reactive | reword the comment (housekeeping) |
| CD3 | `tryCatch(kinshipMatrix(), error = function(e) NULL)` (`R/modSummaryStats.R:386-391`) swallows any error from the supplied reactive. **The slice's impact claim does not hold in the app today:** the fallback recompute applies the same twin relations and overrides (`:409-413`; `appServer` passes both, `R/appServer.R:380-381`), so a swallowed error gives the same matrix, only recomputed | invisible | no | the shared-kinship fallback is pinned for Breeding Groups; none found here | leave |
| CD4 | ten export popovers say "to the user selected directory" (`R/modSummaryStats.R:60, 70, 80, 90, 139, 151, 164, 180, 192, 205`); they are `downloadButton`s, so the file goes to the browser's download folder; 13 `downloadButton`s in the file | app, wording | n/a | none | one phrase, ten places; the housekeeping session, your sentence (e.g. "... to a CSV file your browser saves to its download folder.") |

## Items audited

| ID | Status | Reached from the app? | Finding |
|---|---|---|---|
| CA1 | closed S970, S973 | n/a | table above |
| CA2 | still true | yes (focal animals) | 1 (moderate) |
| CA3 | still true | yes | minor table |
| CA4 | closed S928 | n/a | table above; N1 follows from it |
| CA5 | still true | yes | minor table |
| CB1 | still true | yes | minor table |
| CB2 | closed S969 | n/a | table above |
| CB3 | still true | test harness only | minor table |
| CB4 | still true | test harness only | minor table |
| CB5 | still true | yes | minor table |
| CC1 | still true | yes | minor table |
| CC2 | still true (claim not reproduced) | yes | minor table |
| CC3 | still true | no (script) | minor table |
| CC4 | closed S882 | n/a | table above |
| CC5 | still true | yes (ONPRC only) | minor table |
| CD1 | still true | yes | minor table |
| CD2 | still true | comment | minor table |
| CD3 | still true, impact claim wrong | no | minor table |
| CD4 | still true | yes | minor table |
| CD5 | still true | yes, **clicked** | 2 (moderate) |
| CD6 | closed S876 | n/a | table above |
| N1 (new) | true now | help text | 3 (minor) |

Coverage: 21 of 21 candidates examined; 5 closed, 16 open. CA2, CA3, CB5, CC1, CC2, CC3 and CD5 were run; CD5 also in the
real app; CA4 was run to show it closed; the other nine were read in today's code and their callers.

## Structural observations

- **Findings 1 and 3 and CA4 are one mechanism:** the module's help names a failure ("a missing birth date errors"), a later
  session fixes the failure in code, and no search for the help's wording follows. S928 fixed CA4 and edited the module's
  observer in the same file, five lines from the sentence it left standing. A fix that removes a documented limitation
  should grep `R/` and `man/` for the limitation's words in the same session (the S970 session did exactly this for the
  "Upload list" choice and caught four comments: Learning 936).
- **Seven of the 16 open candidates are already told truthfully by the help** (CA2, CA3, CA5, CB1, CC1, CC2, CC3), because
  S841 wrote what the code does. For those, the audit's question is no longer "is the page right" but "should the code
  change"; five of them (CA2, CA3, CA5, CB1, CC1) are visible to a colony manager who uses the feature in a particular order.
- **Only two of the 16 are wrong results rather than a stop or a missing sentence:** CD5 (a picture of other data) and CC1
  (the twin correction lost app-wide, with a toast naming the id). CA2 is a stop.
- **Four candidates never reach a user:** CB3, CB4 (the test harness's ready flag), CC3 (script) and CD3 (same matrix either
  way). They are the "leave" group.
- **Closed by other work, not by an audit:** CA1, CB2, CC4 and CD6 were closed by sessions that each had their own reason (a
  removal ruling, a dead control, a stale comment, a `sexCodes` adoption); CA4 by a bug fix. This list shrank without anyone
  working from it, which is why it needed this re-check before any ruling.

## Comparison with slice 6d

| Slice claim (2026-10-01) | 2026-10-14 |
|---|---|
| CA1: "Upload list" has no upload control | closed; "My own list" has one |
| CA2: the diversity matrix may lack group members; dead animals trigger it | still true; the trigger is now focal animals (living animals only since S938); documented |
| CA3: the Unused bucket is scored as a group | still true; labelled "Group N" on the map; documented |
| CA4: a missing birth date stops the stats | closed S928; the help sentence about it is now stale (N1) |
| CA5: alerts say "unlock", downloads are not gated | still true; documented |
| CB1: a bad separate genotype file is dropped silently | still true; documented |
| CB2: two dead check boxes | closed S969 |
| CB3, CB4: ready flag not sent on two paths | still true; harness only |
| CB5: `isReady` can throw | still true; run |
| CC1: twin sidecar validated against the trimmed view | still true; run; documented; a code comment still says the opposite |
| CC2: `isReady` never FALSE | not reproduced; documented |
| CC3: default `pedigree = NULL` unusable | still true; run; documented |
| CC4: edge-style comment says "direct" | closed S882 |
| CC5: "Export Demographics" writes the pedigree | still true; a test says it is meant to |
| CD1: `darblue` | still true |
| CD2: stale comment | still true |
| CD3: swallowed error, lost overrides | swallowed yes, overrides lost no |
| CD4: "user selected directory" | still true, ten places |
| CD5: no `req`, no `on.exit` | `req` half is a real wrong-data download in the app; `on.exit` half is code-only |
| CD6: literal "M"/"F" | closed S876 |

## Recommendations

1. **Finding 2 (CD5), Effort S, strict TDD:** the one finding where a click gives a plausible picture of someone else's data.
2. **Finding 1 (CA2), Effort S, strict TDD:** after a first look at the `Value` column for an animal outside the report.
3. **One housekeeping session, Effort S** (comments, one typo and wording; PRE-RED asks for your sentences): N1's help clause,
   CD1's `darblue`, CD2's comment, CC1's comment (`R/modPedigree.R:521-524`), the `R/appServer.R:438-440` comment, CD4's ten
   popovers, and CA5's two alert sentences if you take (a).
4. **Own sessions if you want them built:** CC1 (a), CB1 (a), CB5 (a), CA3 (a). Each is Effort S to M with a test first.
5. **Your call, no recommendation:** CC5 (what ORIP wants).
6. **Leave:** CB3, CB4, CC2, CC3, CD3.
7. Each build is its own session. No code was changed in S991.

## Rulings

None taken yet. The proposed rulings above are recommendations. This report is the S991 deliverable; the rulings are the next step.

**Update S992:** Finding 2 (CD5) was ruled (a), the recommended option, when the owner picked it at the S992 Phase 0 picker, and shipped S992 with the `on.exit` half (`R/modPyramid.R:141,146`, `NEWS.Rmd:445`). With nothing loaded a click now gets an HTTP 500 and a blank "An error has occurred!" page (measured on a stand-in in headless Chrome; Chrome's own display was not watched); with the example loaded it gets a PNG, "Total on 2026-Oct-14: 332". The other findings have no ruling yet.

**Update S993:** Finding 1 (CA2) was ruled (a), the recommended option, when the owner picked it at the S993 PRE-RED question (draw the heat map), and shipped S993: `R/appServer.R:448` hands the Genetic Diversity module `sharedKinshipMatrix`, the full-pedigree matrix Summary Statistics and Breeding Groups get, instead of `gvResults$kinshipMatrix`; the module help (`R/modGeneticDiversity.R:73-75`) and the comment above the call say so; `NEWS.Rmd:451`. The look at the `Value` column the report asked for: an animal with no row in the Genetic Value report is left out of the Value share of low-value animals, as an "Undetermined" one is (`R/getGeneticDiversityStats.R:105-106`); with 2 Low and 1 High assessed animals the group scores red and stays red after adding 1, 6 or 30 such animals, and a group of only such animals scores red (no assessed value, as the help already says). Real app (5 focal animals, 9 living non-focal in the trimmed pedigree): the stop text "kmat is missing kinship for group member(s): HLQ9SY, ..." became a 2-row heat map. Housekeeping list (Recommendation 3): the `R/appServer.R` comment is rewritten; CA5's two alert sentences stay in it; N1's clause is now at `R/modGeneticDiversity.R:81-84`. The other findings have no ruling yet.

**Update S994:** the housekeeping list (Recommendation 3) was done as the owner approved it at the S994 PRE-RED question (all seven sentences as proposed): N1's clause is gone (`R/modGeneticDiversity.R:82-84`), CD1 is spelled `darkblue` (`R/modPyramid.R:46`), the CD2 and CC1 comments say what the code does (`R/modSummaryStats.R:404-406`, `R/modPedigree.R:521-525`), the ten CD4 popovers say "your browser saves to its download folder" (one constant, `.browserSavesText`), and CA5's two alerts read "before you share these files / exports"; gate `tests/testthat/test_docsAuditHousekeepingWording.R` (10 blocks). Read in the real app (headless Chrome, RED commit against HEAD): the ten popovers and both alerts show the new sentences; **the CD1 line is gray before and after** (computed `rgb(149, 165, 166)`: the theme's `.text-muted, .help-text, .help-block { color: ... !important }` beats the inline color), so the spelling fix changes nothing on screen. Found on the way: every popover header reads "character(0)" (`BACKLOG.md`). The other findings have no ruling yet.

**Update S997:** CC1 was ruled and built. The owner chose "keep the pairs that fit, no message" (of three: that, the same with a note, or leave) at the S997 PRE-RED question. The probe the report asked for found that option (a) as written would have broken the diagram and every kinship tab: the layout builder and `kinship()` both stop with "All twinRelations id1/id2 values must be present in id" on a pair with an animal they do not hold, so each place is now handed only the pairs whose two animals it holds (`.twinPairsWithin`, `R/twinPairsWithin.R`; the diagram gets the pairs that fit the view, the returned `twinRelations` the pairs that fit the analysis pedigree, which the Display Unknown IDs box does not narrow). `twinRelationsData()` checks the file against `studbook()` (`R/modPedigree.R:530`); an id not in the studbook, or a pair that does not fit, still rejects the whole file. Real app on the bundled 375-animal example (focal E06FRB and 7U5NJD, trim on, 44 animals): before, a red error naming BRI2MW, HV7LZ3 and 677E7M and 0 connector edges in the diagram widget; after, no error and one DZ edge, 8GSXTQ-P844CW. With focal H16EC4 and 8GSXTQ the Summary Statistics kinship export of E06FRB/HV7LZ3 is 0.5 (0.125 before, no MZ correction). Gate `tests/testthat/test_modPedigree_twinRelationsTrimmed.R` (11 blocks); `NEWS.Rmd:89`. The other findings have no ruling yet.

**Update S998:** CB1 was ruled and built, wider than the row says. The row was right that a genotype file the check refuses is dropped with no message, but the line above its `tryCatch` was unguarded: `getGenotypes()` (`R/modInput.R:498` then) reads the file outside it, so a file that cannot be read at all (a short row: "line 2 did not have 3 elements") stopped the observer and, in the real app, ended the session (headless Chrome: the page greys out and Shiny's disconnected overlay appears; `shiny::testServer` shows only a warning and a blank red "Error rendering QC summary" box, so the module-level run understated it). Measured on the bundled 375-animal MHC pedigree in "separate files" mode: a good genotype file and a 2-column file gave the same QC Summary words (375 records, 0 errors, 1 warning, green "Data passed quality control"); the other three files the check refuses (first column not an id, a column named `first`, an allele of 20000) were dropped the same way. The owner chose "both cases, one sentence" (over the four refused cases only) at the S998 PRE-RED question and approved the NEWS sentence as written. Now the QC Summary says "The genotype file was not used, so no genotypes are used. Reason: <why>" in the blue box the one-file mode uses (`storedResults()$genotypeNote`), the reason being the condition's own message with a full stop added when it has none (no "Reason:" for an empty one); an error while reading, or an error or a warning from `checkGenotypeFile()`, drops the file; a warning while only reading does not. `readSeparateGenotypeFile()` (`R/readSeparateGenotypeFile.R`) holds the step; `R/modInput.R:488-504`; `NEWS.Rmd:525`. Real app after: the 2-column file shows the sentence with "Genotype file must have at least three columns.", the short-row file shows it with "line 2 did not have 3 elements." and the session stays up, a good file shows no line. Gate `tests/testthat/test_modInputSeparateGenotypeNote.R` (13 blocks, 84 expectations). The other findings (CB5, CA3, CC5) have no ruling yet.

**Update S999:** CB5 was ruled and built. The row was right that `isReady` throws, with a limit it did not state: nothing in `R/` reads the module's returned `isReady` (`R/appServer.R:477` takes only `markerKinshipMatrix`), so a colony manager cannot see the throw; only a script or app that calls `modMarkerGeneticsServer()` does. Tested at module level: a good file gives `isReady()` TRUE and `comparisonTable()` a data frame; a short row ("line 2 did not have 4 elements"), a three-column file ("must have exactly four columns") and an empty file ("no lines available in input") make both throw. The owner took the recommended option (a) at the S999 PRE-RED question: `isReady` reads the comparison through `safeRead()` (one name, `comparisonOrNull`, `R/modMarkerGenetics.R:595`, read by the data-ready observer at `:1331` and by `isReady` at `:1347`), so it answers FALSE, while `comparisonTable()` and the tab keep showing the real error, as the module's comment says. Real app (headless Chrome, scratch `app.R`, "before" a worktree of the RED sha, "after" HEAD): for the short-row file both runs show the same red "Error: line 2 did not have 4 elements" above the sub-tabs and in the Kinship Comparison panel (the two pictures are identical); for the three-column file both runs give the same guidance text ("must have exactly four columns"); no disconnected overlay at any step, and a good file uploaded afterwards fills the table (3 rows). The help says it (`R/modMarkerGenetics.R:479-481`, `man/modMarkerGeneticsServer.Rd`; gate `test_modMarkerGeneticsIsReadyHelp.R`) and `NEWS.Rmd` has a Minor bullet. The audit's remaining build is CA3.

**Update S1000:** CA3 was ruled and built. The owner took the recommended option (a), keep the leftover row and name it "Unused animals", and, at a second question, chose to leave `groups()` as the plain unnamed list and add one returned item. Measured first in the real app (bundled example, Top ranked, 1 group asked): the Breeding Groups Groups page read "Group 1 (18 animals)" and "Unused animals (2 animals)" while the heat map read "Group 1" and "Group 2" (the 2 leftover animals are males, so Production was gray and Inbreeding red). The row was right that the groups list is shared, with a limit it did not state: the only reader of the module's returned `groups()` in the app is the Genetic Diversity tab (`R/appServer.R:435` and `:445`); the other tabs read the module's own internal reactive. Naming only the last element would have done nothing, because `getGeneticDiversityStats()` uses `names(groups)` only when every group has a non-empty name (`R/getGeneticDiversityStats.R:91-94`), so every box is named: `modBreedingGroupsServer()` now returns `groupLabels` (`R/modBreedingGroups.R`, the reactive `boxLabels`, which also feeds the Groups, Statistics and Group Detail pages), and appServer attaches those names with `.nameBreedingGroups()` (`R/nameBreedingGroups.R`) when it hands the groups to the tab (`R/appServer.R:434-439`); a groups server that returns no names, or names that do not fit, leaves the numbered rows. Real app after (same driver, run against the GREEN and the REFACTOR tree): "Group 1" and "Unused animals", every cell colour as before; the before and after pictures are of different random runs (18 + 2 and 19 + 1 animals), and the longer label narrows the four columns by about 19 px (read from the pictures). The module help, the manual's Module Interface list, the guide's two paragraphs and `NEWS.Rmd` say it (gates `test_unusedAnimalsHeatMapWording.R`, `test_guideBreedingGroupsWording.R`). The four builds the report offered as their own sessions (CC1, CB1, CB5, CA3) are all built; CC5 stays the owner's call.
