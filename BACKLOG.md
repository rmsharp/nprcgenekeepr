# Backlog

*Open, actionable work only. Completed history → `CHANGELOG.md`; feature inventory &
future plans → `ROADMAP.md`. (Methodology file model — see `SESSION_RUNNER.md` Phase 0.)*

## Up Next

- [ ] **`getAncestors()` fails cryptically on an id or parent that is absent from the tree, and
      cannot resolve a very deep acyclic chain (found S783, 2026-09-26, DECISION NEEDED, Effort
      S)** -- both left out of the F4 (cycle) slice by the owner's decision at its Pre-RED gate.
      Probes (S783, hand-built trees; not run through `createPedTree()` of a raw pedigree with a
      dangling parent): (1) `getAncestors("K", list(K = list(sire = "GONE", dam = NA)))` and
      `getAncestors("NOPE", tree)` both stop with "argument is of length zero"
      (`ptree[[id]]$sire` is `NULL`, so `is.na()` is `logical(0)` in `R/getAncestors.R:85-88`);
      (2) an acyclic single-parent chain resolves up to 2,218 generations and aborts with
      R's "evaluation nested too deeply" beyond that (997 before the S783 change; `options(expressions)`
      is 5000; the cause of the increase was not investigated). Real pedigrees are a few dozen
      generations deep, so (2) is recorded for completeness, not as a defect to fix. **Decision
      for the owner on (1):** stop with a message naming the absent id (matches F4's wording
      style), or treat an absent parent as a founder (returns fewer ancestors silently; a behavior
      change for the exported `getAncestors()`, `findLoops()` and `countLoops()`). Callers: only
      `R/makesLoop.R:29-30` and `R/countLoops.R:50`, neither reached from the app.

- [ ] **`convertRelationships()` given exactly one id returns a nonsense row, and
      `makeRelationClassesTable()` stops when no non-Self pair is left (found S918, DECISION
      NEEDED, Effort S)** -- both left alone by NEW-19 (no output change). Probes (S918, bundled
      `smallPed`): (1) `convertRelationships(kmat, smallPed, "A")` gives one row with
      `id1 = "kinMatrix"`, `id2 = 1`, `kinship = 0.5`, `relation = "Full-Siblings"`; cause read
      in the code: `filterKinMatrix()` (`R/filterKinMatrix.R`) is `kmat[rows, cols]` with no
      `drop = FALSE`, so one id collapses the matrix to a single number. (2)
      `makeRelationClassesTable()` of a table with only Self pairs, or with no rows, stops with
      `'names' attribute [2] must be the same length as the vector [1]` (recorded as today's
      behaviour in `test_makeRelationsClasses.R`). The app calls `convertRelationships()`
      without `ids` (`R/modSummaryStats.R:424`) and `kinship()` itself fails on a one-animal
      pedigree (`'dimnames' applied to non-array`), so the app reaches neither; the other
      caller, `R/markerRealizedRelatednessVariance.R:119`, passes `ids` through. **Decision for
      the owner:** for (1), stop with a message ("give at least two ids") or keep a 1 x 1
      matrix and return the Self pair; for (2), return an empty table with its two columns or
      keep stopping with a clearer message.

- [ ] **Move the version to 3.0.0 just before release (READY at release time, Effort S)** --
      the owner decided (S855) the next release is **3.0.0**. Until then `DESCRIPTION`, the
      `NEWS.Rmd`/`NEWS.md` heading, `README.md` and `ROADMAP.md` stay at 2.0.0.9000 on purpose.
      At release prep: set `DESCRIPTION` to 3.0.0, retitle the `NEWS.Rmd` dev block to 3.0.0 and
      re-knit `NEWS.md`, reinstall the package and re-render `README` (Learning 376), and update
      the 2.0.0.9000 cites in `ROADMAP.md`. The paper-dependency item below also waits on a
      released 3.0.0.

- [ ] **Audit the internal and user-facing documentation for stale information and stale
      diagrams** (owner-requested 2026-09-26; READY, Effort L -- one audit report per session,
      so expect several slices) -- the owner noticed that two article PDFs showed stale figures.
      **Method** (each slice is its own report, `docs/audits/DOCS_STALENESS_AUDIT_SLICE*`, per
      `AUDIT_WORKSTREAM.md`): check every claim, number, screenshot and diagram against today's
      code or output (regenerate the figure from the current source and compare; count, don't
      recall); list each stale item with its source path; fix it or file it. Related, not
      duplicated: the deferred `a2interactive` pass and the `inst/doc/` slimming item.
      **Slices audited, and their wording findings FIXED** (each has a `CHANGELOG.md` entry that
      carries the counts, and a report): 1 (S820) PDFs and article images -- the untracked PDF is
      gone (`3a8c026bb`, S831), the tracked one was deleted and the one stale kinship2 image
      regenerated (S884), two stale code comments fixed (S882, S883); 2 (S821) screenshots, NOT
      fixed, see below; 3 (S822) article prose, fixed S823; 4 (S824) user manual, in-app guidance
      pages and README, fixed S825-S828 and S830; 5 (S832) `a2interactive.Rmd`, fixed S833;
      6a-6e (S834-S842) all 267 `man/` pages, fixed S835, S837, S839, S841, S844; 7a (S845)
      `NEWS.Rmd`, fixed S846-S847; 7b (S852) living internal docs, 33 of 35 fixed S853; 7c (S860)
      live `docs/planning/` plans, fixed S861, and a header sweep of all 84 plans (31 bannered),
      S862; 8 (S868) `docs/research/` and older `docs/audits/`, a status banner on 26 files, S870.
      **Still open.** (1) *Slice 2* (S821, `DOCS_STALENESS_AUDIT_SLICE2_2026-09-30.md`) was never
      acted on, and no slice is scoped to act on it: 31 of 38 regenerable `shiny_app_use/` images
      differ from the app (Pedigree Browser family +147 px; Home, Input, Summary Statistics,
      Breeding Groups, GVA); the colony script's tail fails identically every run (diagnose
      first, then regenerate by module); 12 images have no generator; `pb_unknown_displayed.png`
      is an orphan. The owner decides whether to scope a regeneration slice. S921 added a legend row
      ("Same animal, again") that `pb_diagram_legend.png` (`colony-manager-guide.qmd:347`,
      `pedigree-diagram.qmd:40`) does not show; whether it is one of the 31 was not checked. When it is
      regenerated, add a sentence naming that entry to the article's dashed-line paragraph
      (`pedigree-diagram.qmd:50-55`); the manual (`_pedigree_browser.Rmd:91-92`) already does.
      (2) *Owner decisions about code, found by slices 6-8* (DECISION NEEDED, Effort S each;
      reword the docs if the code changes; carried as recorded S870 and not re-checked against
      today's code, except where a present-day check is named; the ids are in each slice's
      report): 6a MC1 (`filterKinMatrix` lacks `drop = FALSE`) and MB3 (unknown-sex founder
      kinship), and MA3/MB14 cite only `e1071` for `type = 2` from recall, not a run (neither
      `moments` nor `e1071` is installed here); 6b PB4, PB7, PB11 (docs untouched), and PB13, PA4,
      PD12, PD1 (S837 documented today's behavior); 6c 8 candidates (`markerExpectedHeterozygosity`
      He = 1.0 for an all-NA locus, `computeGenomicROH` silent locus drop, `hasGenotype`
      `First`/`Second`, `checkSequenceGenotypeFile` sidecar not reconciled, plus candidates 5-8);
      6d 22 candidates CA1-CA5, CB1-CB5, CC1-CC5, CD1-CD6 (esp. RA3/RA4/RA6 (CA1, CA3), RA8
      (CA2), RB10 (CB1), RC7 (CC1)), and the R `helpText` at `R/modGeneticValue.R:88` still says
      "Summary Statistics relationship table" (present S890); 6e 46 candidates CE-CL, and
      `R/makeGroupNum.R` still says `numGp` "Default is 1" while the examples in
      `R/fillGroupMembersWithSexRatio.R` and `R/groupAddAssign.R` still pass deprecated
      `minParentAge` (all three present S890); 7b/8 CV1 and CV2 (`getGeneticDiversityStats()`
      exports with no `@examples`; the `savePlotToFile` example uses `\dontrun`); 8 four likely
      code defects (candidate "Upload list" uploads nothing; no-op GU/MK checkboxes;
      `groupAddAssign` roxygen "average"/"or younger" wording; silent `allele_1/2` genotype drop).
      (3) *Left unsettled by the doc slices:* RO8 (Quarto slices 3-4 status) and the other ids in
      RO3 were reworded "not recorded" / "not re-checked"; AR3's "about 53" is attributed to
      Learning 347, not re-counted; slice 8 left open whether to replace stale `file:line` cites
      in the plans and gap analysis with function names, and D's six parent-to-union edges that
      still differ in row.

- [ ] **Create a tutorial for prospective contributors** (owner-requested 2026-09-26; DECISION
      NEEDED, Effort M) -- there is no contributor guide today: measured 2026-09-26, no
      `CONTRIBUTING.md` or `CODE_OF_CONDUCT` at the repo root or in `.github/` (which holds only
      `workflows/`). Candidate contents, from what this project's own docs already say: getting set
      up (clone, `renv::restore()`, `pkgload::load_all()`); where things live (`R/` functions, the
      modular Shiny app `appUI.R` + `appServer.R` + `mod*.R`, `tests/testthat/`, the Quarto
      articles under `vignettes/articles/`, `inst/extdata/`); running tests (the fast single-file
      command, the full suite, `devtools::check()`); the write-tests-first workflow; lint;
      roxygen / `man/` / `_pkgdown.yml` and `NEWS.Rmd` expectations; and how to propose a change.
      **Decisions the pickup needs from the owner first:** (a) form and home -- a
      `CONTRIBUTING.md` plus a pkgdown article, or a Quarto article alone; (b) how much of this
      project's internal discipline (strict RED/GREEN/REFACTOR phase gates, the session protocol)
      is asked of outside contributors versus kept internal; (c) audience -- R developers,
      colony managers who script, or both. The tutorial/article documentation checklist in
      `CLAUDE.md` applies; take the commands from its "Build / Test / Verify" section and re-check
      them rather than copying them from here.

- [ ] **The shipped `deidentified_jmac_ped.csv` still does not load: 67 "Parent age too young"
      errors (split out S800 from the blank-cells item, which S800 fixed; DECISION NEEDED,
      Effort S)** -- since S800 the app reads its 2,789 blank sire cells as unknown parents,
      so the old "appears as both a sire and a dam" error is gone, but the pedigree check
      still stops on 67 parent-age errors, on the app path and the `getPedigree()` path
      alike (measured S800, `qcStudbook(getPedigree(f), reportErrors = TRUE)$suspiciousParents`,
      67 rows): 65 dams aged 3.43-3.99 years at the birth, under the 4-year female floor
      `getSpeciesMinBreedingAge("JAPANESE MACAQUE", "F")` returns, and 2 sires with
      negative ages (sire `3A34N` of `82I5M`, -37.10 years; sire `NX5RM` of `8PPD8`, -34.77:
      born after their offspring, a data error in the file).
      **Decide:** (1) leave the file as a QC example and say in its documentation that it
      loads only with Minimum Dam Age lowered and still shows the 2 sire errors; (2) correct
      the 2 impossible sire records in the example; (3) review the 4-year Japanese macaque
      dam floor (5 for sires) against the literature -- a species-table change moves every
      Japanese macaque result. The pinned test is
      `tests/testthat/test_modInput_blankCells.R` (last test: exactly 67 errors, all
      "Parent age too young"), which moves with (2) or (3).

- [ ] **Harem-sire conflict enforcement hole — kinship AND ancestry (found S764,
      2026-09-22, DECISION NEEDED — closing it is a behavior change needing its own
      design gate, Effort M)** -- a harem's sampled sire is seeded into the group
      before the fill loop (`initializeHaremGroups()`), and the loop applies
      `kin[[id]]` exclusions only for animals it places itself
      (`R/fillGroupMembers.R:60-77`), so the sire's own conflicts are never
      enforced against his group: a female with 0.25 kinship to the sire can join
      his harem today (M-F pairs are not F-F-exempt, yet go unenforced), and #168
      ancestry blocking inherits the identical hole (owner-ratified S764 as
      "inherit + document": pinned by
      `tests/testthat/test_groupAddAssignAncestry.R`'s harem-limitation test,
      documented in `groupAddAssign()`'s `ancestryRules` roxygen and the NEWS
      caveat). The candidate fix — filtering each group's `available` by its
      pre-seeded members' `kin` entries after `makeGroupMembers()` — changes
      no-rules harem results (a D7-class zero-change violation if done casually)
      and alters `sample()` streams, so it needs its own Pre-RED design gate
      deciding kinship-side scope, RNG posture, and whether `currentGroups` seeds
      in position >1 share the fix. Full mechanics: Learning 778; the S764 harem
      scope gate recorded the "inherit + document" decision.

- [ ] **(Optional, owner decision) Retrospective colony-snapshot backfill for
      longitudinal genetic-health monitoring** (deferred S760, 2026-09-22, from the
      closed issue #167's plan §5 Slice 5, DECISION NEEDED, Effort L, its own scoping
      session first) -- issue #167's v1 (schema + history IO, snapshot generation,
      trend/delta computation, the Genetic-Health Trends tab; Slices 1-4, all shipped
      and closed) is prospective-only: snapshots are recorded from the analysis state
      a user is looking at when they generate one. A future, clearly-caveated feature
      could reconstruct APPROXIMATE historical snapshots from birth/exit dates alone,
      giving an immediate trend from a single studbook rather than waiting for
      prospective series to accumulate. **Never ratified as v1 scope** (plan §3 D5,
      §5 Slice 5) -- the caveat model is the design problem, not an implementation
      detail: as-of-date reconstruction cannot recover historical breeder flags or
      focal-population designations, so `neSexRatio`/`neVariance` and focal-rule
      snapshots would be silently wrong, not merely approximate, unless the design
      session solves that. Requires its own fresh Pre-RED design gate (a new GitHub
      issue, since #167 itself is closed) before any implementation. See
      `docs/planning/issue167-longitudinal-monitoring-plan.md` §5 Slice 5 and D5 (§7
      Dragon 1 is the no-seed-in-`reportGV()` point, not this caveat list)
      for the full caveat inventory.

- [ ] **Act on the LabKey integration research recommendations** (BLOCKED -- remainder
      needs a live LabKey server to test/observe, Effort M) — research pass DONE
      (`docs/research/labkey-integration-options-2026-06-19.md`, S143); Recs #1-#5 all DONE,
      S144-S152 (S155 added richer file-read errors), see `CHANGELOG.md`: `setLabKeyDefaults()`
      (optional API-key auth), `Rlabkey (>= 3.2.0)`, `defaultSiteParams()`, the internal
      `getPedigreeSource()` (`labkey`/`dataframe`/`file`), `getLkDirectRelatives()` delegating its
      walk to `getPedDirectRelatives()` (a deliberate, owner-accepted behavior change: it now
      returns the full connected component), and the exported `getFileDirectRelatives()` and
      `getFocalAnimalPedFromFile()` (the Shiny focal-animal workflow now runs offline). The live
      ONPRC/SNPRC server version (doc §8.1) is still unobserved. **Still deferred:** a
      non-LabKey other-EHR provider on the same seam; server-side filtering / `executeSql` /
      consuming the centers' `study.Pedigree`/`ehr.kinship` (the research doc defers this until
      pull size is measured and per-center query availability/permissions are confirmed; it needs
      a live LabKey server to test/observe, and a naive focal-id server filter is incompatible
      with the client-side connected-component walk).
- [ ] **Work with LabKey (Josh Eckels) to update the LabKey integration** (owner-requested
      2026-09-26; BLOCKED -- needs the owner to make contact, and the deferred technical work also
      needs a live LabKey server; Effort M, not a coding task until scoped) -- companion to
      "Act on the LabKey integration research recommendations" above, which records what is DONE
      (Recs #1-#5), what is unobserved (the live ONPRC/SNPRC server version) and what was
      deferred pending per-center confirmation (server-side filtering / `executeSql`, consuming
      the centers' `study.Pedigree` / `ehr.kinship` queries, a non-LabKey EHR provider). Nothing
      in this repository records any contact with LabKey yet. **Suggested first step (the
      owner's):** talk with Josh Eckels about the current LabKey API and `Rlabkey` direction and
      what he would change or add on the LabKey side, using the deferred questions from that item
      as the agenda; then decide which package changes follow and file each as its own item.
      Research base: `docs/research/labkey-integration-options-2026-06-19.md`.

- [ ] **Build a kinship2-similar standalone pedigree package from this repository's code —
      committed, deferred** (disposition S742, 2026-09-20; BLOCKED -- prep steps ALL DONE
      (D-1 S744, D-2 S745, D-3 S746); the remaining blocker is the S738 revisit conditions
      only, scoping doc §6: engine churn calms + an
      accepted CRAN release; Effort L, its own planning session first when unblocked) --
      owner disposition closing the S739 two-step discussion item (step 1: gap analysis
      DONE S741, `docs/research/kinship2-feature-gap-analysis-2026-09-20.md`, 15 EQ /
      8 PARTIAL / 2 ABSENT; step 2: this decision — full record in `CHANGELOG.md` S742).
      **The package WILL be built; only the timing is deferred ("gates stand").
      Purpose (owner-stated): a standalone near-equivalent of kinship2 carrying
      nprcgenekeepr's enhanced features — particularly the pedigree drawing, annotation
      ability, and interactivity; nprcgenekeepr may eventually consume it, but that is NOT
      the primary goal** (i.e. plan a sibling product first, not an extraction nprcgenekeepr
      must immediately depend on). **Ratified scope (S742, so the plan session doesn't
      re-derive):** drawing surface IN — lift the module-bound decorations
      (`R/modPedigree.R`, about `:689-890`: legend, image export, tooltips) into a script-callable
      visNetwork renderer (the unique value per the gap doc's ecosystem observation; the one
      substantive new-work item); parity closers IN — export the shrink helpers + `bitSize`
      (tested internals in `R/shrinkPedigree.R`: `.bitSizeOf`, `.findUnavailable`, `.findAvailAffected`), port `familycheck` + `ibdMatrix`
      (the two full absences), and user-suppliable layout hints (autohint's override half —
      real engine-surface design); OUT — block-sparse `makekinship` (dense whole-colony
      matrices are current practice); API shape (data-frame-as-is vs kinship2-compat layer)
      DELIBERATELY OPEN — decide at plan time with a prototype in hand.
      When unblocked, the pickup is a planning session (package boundary/plan doc in
      `docs/planning/`, evidence-based inventory). **Prep is done** (D-1 S744, D-2 S745, D-3 S746;
      each is in `CHANGELOG.md`): `makePedigreeMatingLayout(kinshipMatrix = )`
      (`R/makePedigreeDiagramData.R`) is the injectable boundary the package needs, and the 13
      `R/positionTreeApportion.R` functions carry `@noRd` roxygen. **One prep claim has drifted
      (found S896):** D-2 took every test outside the layout core's own files off
      `.buildMatingUnitForest()`, but `tests/testthat/test_newsReleaseState.R:234,248` has called it
      directly since S790-S791 (NEWS release-state counts; it is not one of the scoping doc's 9
      core test files), so the planning session must re-run the grep and decide where that test
      lives. (The owner accepted S667's recommendation NOT to split the layout core, recorded S738;
      the prep steps stand whether or not a split ever happens.)
- [ ] **(Optional, owner decision) Slim `inst/doc/` by moving the three `html_document`
      vignettes to `rmarkdown::html_vignette`** (extracted S728, 2026-09-19, from the completed
      tarball build-hygiene item — its still-open step 4; DECISION NEEDED, Effort M, its own
      session) -- `inst/doc/` is 4.38 MB uncompressed = 86% of CRAN's 5 MB documentation
      guideline and 38% of the tarball; `a2interactive`/`gvaConvergence`/`simulatedKValues`
      declare `output: html_document` (`vignettes/a2interactive.Rmd:4-6`,
      `gvaConvergence.Rmd:6-8`, `simulatedKValues.Rmd:6-8`). Est. 0.4-0.9 MB compressed saved
      — an ESTIMATE needing its own before/after clean-export build measurement
      (`docs/audits/TARBALL_SIZE_AUDIT_2026-09-19.md` Finding 3 + §7 recipe); `df_print: paged`
      does not exist under `html_vignette` and must become `knitr::kable()`; optionally replace
      `a2interactive`'s two live `visNetwork` widgets with static images — now quantified
      (S737, `docs/audits/PEDIGREE_DRAWING_FEATURE_GROWTH_AUDIT_2026-09-20.md` Obs. 2): the
      widgets' vis-network + html2canvas payload is ~1.23 MB uncompressed ≈ 0.29 MB compressed
      inside `inst/doc/a2interactive.html`, so that one step alone removes most of the drawing
      feature's tarball footprint. Buys
      documentation-guideline headroom, not tarball-limit compliance (already met: clean build
      3.49 MB vs 10 MB); the S728 `tarball_size_clean_export` gate (`.quality-gates.json`,
      <=5 MB) will show any saving mechanically. **Not worth doing on size grounds (measured
      S727):** shrinking example/test data (`inst/extdata/examples/` 0.46 MB compressed,
      `tests/` 0.66 MB), recompressing `data/` (0.14 MB), or the package split. Always build
      release tarballs from a clean export, never the working tree.
- [ ] **(Optional, low priority) Root-cause why the pinned Chrome-for-Testing binary hangs on
      `macos-latest`'s `ChromoteSession$new()` bootstrap** (found S619, 2026-08-20, incidental to
      the chromote CDP-timeout fallback fix (see `CHANGELOG.md`), READY (optional), Effort M -- research only, not
      required) -- the practical problem is FULLY resolved: `macos-latest` reverts to ambient/
      unpinned Chrome (`R-CMD-check.yaml`, `if: matrix.config.os != 'macos-latest'` on the 3
      Chrome-provisioning steps), verified green on real CI.
      **Unexplained:** why the bootstrap probe `Runtime.evaluate("window.devicePixelRatio", ...)`
      (`private$get_pixel_ratio()`, chromote 0.5.1) never gets a response on the pinned macOS ARM64
      binary, though the same binary works on ubuntu-latest/windows-latest and ambient Chrome works
      on macos-latest (raising `default_timeout` to 60s changed nothing: the session is wedged, not
      slow). The only plausible analog found is Mozilla Bugzilla #1893921 (Firefox's content-process
      spawn hitting a 5s sandbox-denial stall on GitHub's *virtualized* macOS ARM64 hosts); no
      matching Chromium tracker entry exists. Only worth pursuing if pinned-Chrome reproducibility
      on macOS becomes valuable: `xattr -l` on the extracted `.app` on a live failing runner (the
      research found Gatekeeper quarantine NOT evidenced for `browser-actions/setup-chrome`), or a
      new `rstudio/chromote` upstream issue (none matches this macOS+GHA+live-CDP-timeout
      signature).
- [ ] **Shard verify scripts that FAIL on lossless trims: reported upstream as `KJ5HST/methodology#93`;
      waiting on a fix and a way to regenerate old scripts (BLOCKED -- on upstream #93, Effort S once
      it ships)** -- S901 characterized all 10 red scripts (of 54: HANDOFFS 2 of 15, CHANGELOG 1 of 16,
      SESSION_NOTES 7 of 23) and diffed the records: **none is a real loss.** Three causes: (1) 7 scripts
      (v1.5.0): the trim shares a commit with the session's own close-out, so record 0 (a claim stub or a
      `status: pending` receipt) differs, and BL-27 keeps that a loud FAIL; (2) 1 script (v1.1.2): a
      baked-in `INJECTED=0`, fixed upstream since v1.2.0 but frozen scripts never benefit; (3) 2 scripts:
      the L2 "leak" test is a substring test, so a mid-line backtick quote of a front-matter line counts.
      Causes 1 and 3 are still in the current `main` of both `rmsharp/methodology` and `KJ5HST/methodology`
      (byte-identical, v1.5.0). The fork has issues disabled, so the owner chose `KJ5HST/methodology`;
      posted 2026-10-04 (https://github.com/KJ5HST/methodology/issues/93). Evidence and the posted text:
      `docs/audits/SHARD_VERIFY_SCRIPT_FAILURES_2026-10-04.md` (the issue starts at its line 150).
      **New at S917's Phase 0:** a comment on #93 (2026-10-05 16:32 UTC, from the `rmsharp` account, not
      recorded before) re-ran the 54 proofs from a clone at `2563a6ee0` and got the same counts. It says:
      cause 2 is fixed safely by testing whole lines instead of substrings (both shards go green, none
      turns red across 54 here and 103 in its own archive); cause 3 is not independent of cause 1 (the
      v1.1.2 `SESSION_NOTES-through-2026-08-15` shard still fails for cause 1's reason once regenerated);
      all 8 cause-1 shards have a claim stub or a `status: pending` receipt as record 0 and nothing
      else missing; and a `--reverify` would have to lift the record grammar from the frozen script,
      because the canonical `LEDGERS` table has no `SESSION_NOTES.md` entry. It proposes no patch yet.
      S917's own `HANDOFFS.md` trim was committed apart from its close-out and its verify script passes.
      **What is left:** read upstream's answer (`gh api repos/KJ5HST/methodology/issues/93/comments`;
      `gh issue view --comments` fails here); when
      a fix and a regenerate path ship, sync the trimmer (re-apply this project's `SESSION_NOTES.md`
      patch, per the `CLAUDE.md` checklist) and regenerate the 10 scripts; if upstream declines, decide
      whether to patch them here (a second local modification to `methodology_trim.py`, which the owner
      rejected S898). Until then do not quote front-matter command lines verbatim in receipts (Learning 797e).

- [ ] **`CHANGELOG.md`'s own ~4-entries-per-session ledger convention (claim, Phase 0
      reconcile, deliverable, close-out) may be a `CHANGELOG.md`-side analogue of the
      already-diagnosed `HANDOFFS.md` "Receipt Inflation" (H4) rate problem** (found S543,
      2026-08-12, Effort unknown, not investigated) -- incidental to the `SRF_RED`
      investigation: the tagged region regrew ~105,000 B in roughly a day during an active
      multi-session stretch (S536-S542), and a `grep -c '^### 2026-08-12'` on the pre-trim
      file showed a large share of that region was same-day, multiple-entries-per-session
      housekeeping (claim/reconcile/close-out entries) rather than deliverable-content
      entries. Not confirmed as causal, and not investigated further this session (out of
      the `SRF_RED` decision's own scope, per `PROJECT_LEARNINGS.md` Learning 382's "report,
      don't fix mid-session" precedent). A future session could measure the actual
      housekeeping-vs-deliverable entry-byte split and decide whether a norm analogous to
      the canonical design's own deferred H4 remedy (recorded as `docs/planning/ledger-trimmer-design.md`
      §10.2, a file that is not in this repo; "the lever is receipt size, and the mechanism would be a norm plus a check, not
      an archiver") is worth adopting for `CHANGELOG.md` specifically. **Measured S897
      (2026-10-04):** `CHANGELOG.md` went from 37,593 B (its 2026-09-27 trim) to 258,724 B in 7
      days, which is what raised the trimmer's `SRF_RED` (7.9455); the owner-approved `--force`
      trim left it at 25,172 B. The owner's choice of lever (shorter claim/close-out entries and
      receipts) is still open.
- [ ] **`BACKLOG.md`'s own ledger-size housekeeping -- editorial compression, not a
      `methodology_trim.py` config** (found S518, 2026-08-11, READY, Effort L; RECURRING --
      last pass S896, 2026-10-04) -- `BACKLOG.md` is one of the dashboard's HIGH-risk
      ledger-size items but does not fit `methodology_trim.py`'s chronological-record model:
      its `##` sections are standing *topical* categories that accumulate resolved-item
      narrative indefinitely, not dated newest-on-top records. The file's own header states the
      remedy ("Open, actionable work only... for history see `CHANGELOG.md`"). Sections
      **regrow** as later sessions append their own progress narrative (S606 found the S531
      "fully RESOLVED" claim was only a snapshot), so this is a recurring maintenance pass,
      never a one-time fix.
      **Pass history** (each pass has its own `CHANGELOG.md` entry; S890 checked the figures
      quoted here against those entries): S529 Housekeeping section (652 -> 389 lines; its
      inventory found 2 items with no ledger entry, a real FM #27 gap, backfilled before
      compressing); S530 "Pedigree diagram vs kinship2" (896 -> 286); S531 "Genetic-metrics PDF
      audit follow-ups" (753 -> 267); S606 re-compressed Genetic-metrics after regrowth (304 ->
      80); S752 (2026-09-21) again (91 -> 62), condensed this history, found "Pedigree diagram vs
      kinship2" NOT regrown (286 -> 156); **2026-09-24** (ad hoc, owner-picked): removed 2
      completed items, fixed 4 stale statements, compressed the LabKey item (44 -> 15) and the
      kinship2 DONE narrative (84 -> 20), deleted the 3 resolved sections (55 lines; file 432 ->
      378; the NEW-53 ledger gap found there was backfilled); **S890** (2026-10-03): condensed the
      docs-audit item (55 -> 48) and this history (50 -> 38); file 552 -> 533 lines (58,228 ->
      46,731 B); **S896** (2026-10-04): compressed the four S890 candidates (PED_GV 20 -> 13 lines,
      standalone-package 37 -> 34, chromote 23 -> 17, kinship2 preamble 20 -> 13); its checks
      corrected a stale `:1661` line reference and a drifted D-2 claim, and recomputed the PED_GV
      count of 9 from the triage table; file 533 -> 514 lines (46,731 -> 43,766 B).
      **Method (every pass, all steps):** before compressing anything to a pointer, (1) verify
      `CHANGELOG.md` + `docs/archive/CHANGELOG-*.md` carry an entry heading for every session
      number cited AND that the load-bearing facts are inside those entries (a heading alone proves
      little); (2) confirm every cited Learning / doc path resolves and every issue state via
      `gh issue view`, not prose; (3) extract any buried open thread as its own item first; (4)
      replace whole line ranges mechanically (Learning 537: a partial `old_string` leaves later
      paragraphs duplicated beside the new bullet); (5) leave open items byte-untouched; (6)
      re-read the compressed result end to end.
      **Candidates for the next pass (measured S896, line counts after this pass; re-grep, sizes
      not anchors):** the docs-audit item (47 lines; S890 already compressed it, so check for
      regrowth first), this item's own history (41 lines), the paper item (24), the `inst/doc/`
      slimming item (21) and the trim verify-script item (20, now longer after S898). The
      verify-script item was one of the 7 parked Effort-S items; the owner kept all 7 open (S898),
      so it may be compressed (Candidate C, another of the 7, was closed S910). The standalone-package
      item is still 34 lines but is nearly all ratified-scope open text; leave it. Regrowth, for
      scale: 378 lines on 2026-09-24, 599 at S853, 552 before S890, 514 after S896.

- [ ] **Two kinship2 drawing features the Diagram tab still lacks (found S847, 2026-10-01; DECISION
      NEEDED -- which pedigree column marks "deceased", Effort M for each; strict TDD for both)**
      -- checked in the source S847 (`R/makePedigreeDiagramData.R`, `R/modPedigree.R`): (1) **Deceased
      marker:** no diagonal slash is drawn over a deceased animal's symbol, as kinship2 does for a
      deceased `status`. The pedigree already carries `death`, `exit` and `status` columns, so the
      decision is which of them (or a new one) marks an animal deceased, and whether `exit` for a
      transfer must be told apart from death. (2) **More than one affected condition:** `affected`
      is one logical column (`R/makePedigreeDiagramData.R:73-85`, one fill color); kinship2 shades
      up to four conditions per animal as separate sections of the symbol, with a matching legend.
      The decision is the input shape (several logical columns, or a matrix) and the legend text.
      Each is its own session; the Diagram section of `NEWS.Rmd` (lines 33-35) says "A deceased marker and more than one affected
      condition are not drawn" until both ship.

## Pedigree diagram vs kinship2 audit follow-ups (from ISSUE_129_KINSHIP2_FEATURE_COMPARISON_2026-07-30.md)
*S435's capability comparison of the issue #129 pedigree diagram against kinship2's drawing
feature set (`docs/audits/ISSUE_129_KINSHIP2_FEATURE_COMPARISON_2026-07-30.md`) produced 8
recommendations, filed S436 as GitHub issues #131-#138. **All are shipped and closed except
#138** (full-colony rendering beyond the 1,500-node cap: `low priority` label, needs its own
scoping session first; tracked on GitHub, not here). The order they shipped in is the sequencing
audit's status line (`docs/audits/PEDIGREE_DIAGRAM_BACKLOG_SEQUENCING_AUDIT_2026-08-08.md`). None
reopens issue #129 or the visNetwork-vs-kinship2 technology decision (D2), which stands as
ratified; the
`docs/planning/pedigree-diagram-kinship2-reference-comparison.qmd` refresh (S484) has since gone
stale again and carries a status note. Session-by-session record: `CHANGELOG.md`; technical
findings: `PROJECT_LEARNINGS.md` Learnings 410, 411, 485, 488-499. No live item remains here: S921 shipped
the last one (the legend row for the dashed repeat-appearance link; see `CHANGELOG.md`).*

## Outreach
- [ ] **NPRC outreach & announcement plan** (DECISION NEEDED -- owner review/edit of
      drafts + send timing; Effort N/A, not a coding task) -- plan complete:
      `docs/planning/nprc-outreach-announcement-plan.md` (S413, owner-directed, not
      from this backlog). Covers audiences (the NPRC Genetics and Genomics Working
      Group, plus each of the 7 centers' colony-manager/veterinarian contacts), tailored
      messaging, channels, a sourced 7-center contact roster (director + colony-manager/
      head-veterinarian-equivalent + genetics contact per center, each with a source),
      a generic timeline, 5 named risks, and ready-to-edit draft materials (WG email,
      colony-manager/vet email, one-page feature summary, presentation outline). Two
      items remain genuinely unresolved after dedicated research, not just undone: the
      Working Group's current (2026) chair could not be confirmed (recommended action:
      ask `support@nhprc.org` directly, see the plan's §3/§8); and a colony-manager
      contact could not be named at 3 of 7 centers (Southwest, Tulane, Washington --
      the role is undocumented by name on each center's own site). **Next steps are
      owner-executed, real-world actions** (review/edit the drafts, confirm exact
      recipients, send) per the plan's own §7 -- pick this up in a future session only
      if the owner wants help drafting a specific follow-up, not as a general "send the
      emails" coding task. See `CHANGELOG.md`.

- [ ] **Develop paper(s) for peer-reviewed journals** (owner-requested 2026-09-26; DECISION
      NEEDED, Effort L, its own scoping session first; multi-session) -- the owner supplied a
      venue-fit summary (from an AI-assisted conversation) to start from. **Treat its journal
      assessments as unverified leads:** check each journal's current scope, article types and
      fees before committing. Its recommendation, in short: version 3.0 is more than an
      incremental update, so write **two complementary papers** that cite each other -- (1) a
      **software paper** for *The R Journal* or the *Journal of Open Source Software* (package
      architecture, workflows, reproducibility, new features; the canonical citation for the
      package; per the summary, JOSS is very short and citation-like, while *The R Journal* allows
      longer technical descriptions with code examples) and (2) an **applied genetics paper** for
      the *American Journal of Primatology* or the *Journal of Medical Primatology* (how the
      software improves genetic management of captive primate colonies, with realistic examples and
      best practices) -- and optionally (3) a **retrospective paper** on the evolution of
      computerized genetic management in NPRC colonies over past decades (historical and
      methodological, for readers interested in colony-management practice). The summary also
      grouped further candidates into tiers (computational-biology software, conservation
      genetics, statistical computing, and animal-colony-management journals), but **the journal
      names in those tiers were lost when it was pasted** -- only the four above survive -- so the
      pickup must get the original list from the owner. Open decisions: which papers, authorship,
      and what is new in 3.0 relative to the published reference (Vinson & Raboin 2015, *JAALAS*
      54(6):700-707, the package's key reference in `CLAUDE.md`, whose Project Overview also holds
      the NIH grant acknowledgment). Natural dependencies, the owner's call: a released 3.0.0 to
      cite (`DESCRIPTION` reads 2.0.0.9000 today) and the documentation audit above, so the
      papers' figures match the software.
