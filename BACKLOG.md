# Backlog

*Open, actionable work only. Completed history → `CHANGELOG.md`; feature inventory &
future plans → `ROADMAP.md`. (Methodology file model — see `SESSION_RUNNER.md` Phase 0.)*

## Up Next

- [ ] **Resolve the PED_GV audit's remaining findings -- triage first (owner-directed
      2026-09-24 for the next session; READY, Effort L; strict TDD for every fix)** --
      `PED_GV_AUDIT_2026-05-30.md` (repo root) holds 61 confirmed findings in ~24 deduped roots
      (`:218`) and 63 distinct `PED-`/`NEW-` ids in all; the ledger (`CHANGELOG.md` plus
      `docs/archive/CHANGELOG-*.md`) records only 22 of those ids, but **ledger-absent does not
      mean unresolved** (NEW-53 was fixed in `5f40b7af` and had no entry until 2026-09-24). So
      the FIRST deliverable is a triage table, one row per ledger-absent id (41): still present
      in today's code / already fixed (cite the commit) / moot / refuted, judged against the
      current source, never the 2026-05-30 line numbers. Start with the correctness and
      robustness block (audit `:64-141`), whose six ledger-absent ids are **NEW-31/NEW-32**
      (`getRecordStatusIndex()` returns `integer(0)` when `recordStatus` is absent, so
      `removeUnknownAnimals()` silently yields a 0-row pedigree), **NEW-38** (the "U"-prefix id
      scheme in `addUIds()`/`removeAutoGenIds()` can collide with or wrongly strip real `U...`
      ids), **NEW-41** (`getAncestors()` recurses with no cycle guard or dedup; no test),
      **NEW-58** (`getAnimalsWithHighKinship()`'s `tapply` collapse drops animals with no
      qualifying partner; no test) and **NEW-59** (`makeGeneticSummaryTable()`'s unnamed
      `rep(NA, 6)` fallback). A quick look on 2026-09-24 (a lead, NOT a triage) found the
      structures for NEW-31/32, NEW-41 and NEW-58 still visible (`R/getRecordStatusIndex.R:14`,
      `R/getAncestors.R:53`/`:60`, `R/getAnimalsWithHighKinship.R:57`) and no `rep(NA, 6)` in
      `R/makeGeneticSummaryTable.R`. The other 35 ids are the lower-severity duplication /
      extensibility / complexity findings (tables at `:147` and `:178`). **Ledger-absent ids:**
      NEW-14 18 19 21 24 26 27 28 31 32 33 35 36 38 39 41 42 43 44 50 51 54 55 56 57 58 59 60 61
      62 63; PED-2 3 4 5 6 7 8 9 10 11. **Owner decisions after triage:** which "overhaul"
      roots are worth doing at all, and whether a fixed-but-unrecorded id gets a ledger backfill
      entry (the NEW-53 precedent says yes). The audit's own refuted findings are at `:251`, its
      test gaps at `:263` and its sequencing at `:298`.

- [ ] **(Optional, owner decision) Stop the four push workflows from running on pushes that
      change only build-ignored files** (raised 2026-09-24; DECISION NEEDED, Effort S) -- lint,
      pkgdown, R-CMD-check and test-coverage run on every push to `master` with no `paths-ignore`,
      so a push of only `BACKLOG.md`/`CHANGELOG.md`/`HANDOFFS.md`/`SESSION_NOTES.md` still costs a
      ~25-minute R-CMD-check that cannot say anything new. The owner's rule (2026-09-24: "if all
      files edited are in .rbuildignore, there is no reason to ever run CI") is followed today
      only by not waiting for the run. Options: a `paths-ignore` list mirroring `.Rbuildignore`
      in each workflow, or `[skip ci]` in such commits' messages. Caveat for the first: some
      ignored files ARE read by tests (`.github/workflows/*`, `_pkgdown.yml`,
      `.quality-gates.json`, `.Rbuildignore`; e.g. `test_r_cmd_check_workflow_chrome_setup.R` and
      `test_shinytest2_workflow_coverage.R` read the workflow files), so the list must exclude
      those. Not done: it edits CI config, which the owner has not asked for.

- [ ] **Mate-pair ancestry guardrails -- residue after issue #169 (found S776-S777,
      2026-09-24; DECISION NEEDED -- the owner picks which to pursue, each Effort S)**
      -- #169 shipped and closed S777 (kernel, module, override gate, Ancestry tab,
      committed e2e, article). Four small things it left, none started: (1) **`a2interactive`
      demonstration (READY, the deferred documentation pass per `CLAUDE.md`)** -- add a
      section to `vignettes/a2interactive.Rmd` for
      `reportMatePairs(ancestryRules, overriddenRules)`: the `ancestryRule` /
      `ancestrySeverity` / `ancestryStatus` columns, `ancestryCoverage`, and the excluded
      reason "ancestry rule". (2) **Zero-rule table (DECISION NEEDED)** -- a valid rules
      table with zero rules makes `.buildAncestryOverrideManifest()` stop ("no rules in
      effect"), so Download Audit Manifest errors on BOTH Mate Pair and Breeding Groups;
      decide whether a zero-rule table should read as "inactive" or the manifest should
      say so. (3) **The Excluded tab has no export (DECISION NEEDED)** -- plan section 7
      dragon 8: a curator cannot get the list of blocked pairs as a file (the manifest
      carries per-rule COUNTS only). (4) **Duplicated gate code (READY refactor)** -- the
      override select-choices builder and the confirm-gate modal are duplicated between
      `R/modBreedingGroups.R` and `R/modMatePair.R` (S776's REFACTOR shared only
      `.emptyAncestryOverrides()` and `.overridableAncestryRules()`); the shared shape is a
      choices builder plus a modal constructor taking the warning text and the namespace.
      **Known, accepted:** an unhandled click-time error ends the Shiny session
      (Learning 786).

- [ ] **`NEWS.Rmd` release-state sweep — rewrite entries that describe in-progress
      milestones (owner-directed S774, 2026-09-23; READY, Effort M)** -- the owner
      ruled that NEWS entries state the finished state at release relative to the
      PRIOR release (2.0.0), never a point between releases (Learning 785). A
      heuristic grep of the development section (pattern list: first/final step,
      "continued)", groundwork, "later step(s)", "arrive(s) in") found four feature
      clusters: the MHC haplotype-frequency entry (`NEWS.Rmd:308`), the four #168
      ancestry entries (`:376-410`: "Groundwork...", "...continued" x2, "...final
      step" — merge into one release-state entry), and the two #167 longitudinal
      entries (`:460-468`, `:478-488`: "arrives in later steps/the next step"). The grep
      is a floor, not a census: the pickup should read the whole development section
      once. Plain-language criterion (S628) still applies. `NEWS.md` was last
      re-rendered S716, so it lags `NEWS.Rmd` and needs a render at release. Open,
      the owner's call: adding the rule to `CLAUDE.md`'s NEWS checklist (its
      "matching existing style" wording conflicts with it).

- [ ] **Blank ancestry cells become OTHER, not UNKNOWN, on the Shiny upload path
      (found S776, 2026-09-24, DECISION NEEDED, Effort S-M)** -- the Input module reads
      CSV/text uploads with no `na.strings` (`R/modInput.R:324-331`), while the script
      path `getPedigree()` reads with `na.strings = c("", "NA")` (`R/getPedigree.R:34`).
      Measured: `qcStudbook()` maps a true `NA` ancestry to UNKNOWN but an empty string
      to OTHER, and the live app's Mate Pair coverage table shows the fixture's blank
      ancestry animal as OTHER (OTHER 2, UNKNOWN 0) where a script user gets UNKNOWN.
      Consequences: an UNKNOWN-vs-OTHER rule (the S769 article tells centers to name
      both) matches different animals depending on how the file was loaded, and
      `vignettes/articles/colony-manager-guide.qmd:552` ("a truly blank entry becomes
      UNKNOWN") is wrong for app uploads. Decision for the owner: align the app read
      with `getPedigree()` (a behavior change for EVERY blank character cell in an
      upload -- audit QC effects on blank sire/dam/other columns first; not measured
      yet) versus documenting the difference. Needs its own investigation and Pre-RED
      gate; not part of #169.
      **Pins that move with it:** the committed e2e
      `tests/testthat/test-e2e-mate-pair-analysis-module-ancestry.R` (S777) pins the LIVE
      numbers -- coverage table OTHER 2 / UNKNOWN 0 (group A5), manifest pair counts
      INDIAN-UNKNOWN 0 / INDIAN-OTHER 3 (A6b, A12) and census nOther 2 / nUnknown 0
      (A6c) -- so aligning the read moves them on purpose; change those expectations in
      the same commit (the file's header comment says so).

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
      `docs/planning/issue167-longitudinal-monitoring-plan.md` §5 Slice 5 / §7 Dragon 1
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
      (`R/modPedigree.R:675-790`: legend/image-export/tooltips) into a script-callable
      visNetwork renderer (the unique value per the gap doc's ecosystem observation; the one
      substantive new-work item); parity closers IN — export the shrink helpers + `bitSize`
      (tested internals, `R/shrinkPedigree.R:227-380`), port `familycheck` + `ibdMatrix`
      (the two full absences), and user-suppliable layout hints (autohint's override half —
      real engine-surface design); OUT — block-sparse `makekinship` (dense whole-colony
      matrices are current practice); API shape (data-frame-as-is vs kinship2-compat layer)
      DELIBERATELY OPEN — decide at plan time with a prototype in hand. When unblocked, the
      pickup is a planning session (package boundary/plan doc in `docs/planning/`,
      evidence-based inventory); step 0's prep is complete — D-1 landed S744:
      `makePedigreeMatingLayout(kinshipMatrix = )` (`R/makePedigreeDiagramData.R:1685`)
      is exactly the injectable boundary the package needs; D-2 landed S745: no test
      file outside the layout core's own reaches `.buildMatingUnitForest()` any more
      (the two `test_modPedigree.R` reaches now derive union/duplicate ids from the
      exported return's `nodes$id` / `duplicateToReal`); D-3 landed S746: all 13
      `R/positionTreeApportion.R` functions carry `@noRd` roxygen (title + `@param` +
      `@return`, house style), so the engine's contract is readable in place
      (`@noRd` generates no `.Rd`, `man/`/`NAMESPACE` verified byte-identical).
      (Prep-step origin context: the owner accepted the S667 recommendation NOT to
      split the layout core into its own package — disposition recorded S738 in
      `CHANGELOG.md`; the prep steps hardened the boundary in place and stand
      whether or not a split ever happens.)
- [ ] **(Optional, owner decision) Slim `inst/doc/` by moving the three `html_document`
      vignettes to `rmarkdown::html_vignette`** (extracted S728, 2026-09-19, from the completed
      tarball build-hygiene item — its still-open step 4; DECISION NEEDED, Effort M, its own
      session) -- `inst/doc/` is 4.38 MB uncompressed = 86% of CRAN's 5 MB documentation
      guideline and 38% of the tarball; `a2interactive`/`gvaConvergence`/`simulatedKValues`
      declare `output: html_document` (`vignettes/a2interactive.Rmd:4-7`,
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
      the chromote CDP-timeout fallback fix below, READY, Effort M -- research only, not
      required) -- the practical problem is FULLY resolved: `macos-latest` reverts to ambient/
      unpinned Chrome (`R-CMD-check.yaml`, `if: matrix.config.os != 'macos-latest'` on the 3
      Chrome-provisioning steps), verified green on real CI. What remains unexplained: raising
      chromote's `default_timeout` to 60s did NOT resolve the pinned binary's hang (same exact
      failure, wall time roughly doubled, confirming the session is genuinely wedged, not merely
      slow) -- direct source inspection confirmed the timeout-governed call is
      `ChromoteSession$new()`'s own internal `Runtime.evaluate("window.devicePixelRatio", ...)`
      bootstrap probe (`private$get_pixel_ratio()`, chromote 0.5.1), but WHY that specific probe
      never gets a response on the pinned macOS ARM64 binary specifically (vs. the SAME pinned
      binary working fine on ubuntu-latest/windows-latest, and vs. ambient Chrome working fine on
      macos-latest) is unconfirmed. A research workflow found a plausible but NOT Chromium-
      confirmed analog (Mozilla Bugzilla #1893921 -- Firefox's own content-process spawn hitting a
      5s AppKit/IOKit sandbox-denial stall specific to GitHub's *virtualized* macOS ARM64 hosts,
      fixed by widening Firefox's own sandbox allowlist) but found no matching Chromium tracker
      entry. Only worth pursuing if pinned-Chrome reproducibility on macOS specifically becomes
      valuable later (e.g. `xattr -l` on the extracted `.app` on a live failing runner to rule
      out/in Gatekeeper quarantine, which the same research found NOT evidenced for
      `browser-actions/setup-chrome`'s actual download/unzip pipeline; or filing a new
      `rstudio/chromote` upstream issue, since no existing issue there matches this exact
      macOS+GHA+live-CDP-timeout signature).
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
      the canonical design's own deferred H4 remedy (`docs/planning/ledger-trimmer-design.md`
      §10.2, "the lever is receipt size, and the mechanism would be a norm plus a check, not
      an archiver") is worth adopting for `CHANGELOG.md` specifically.
- [ ] **`BACKLOG.md`'s own ledger-size housekeeping -- editorial compression, not a
      `methodology_trim.py` config** (found S518, 2026-08-11, READY, Effort L; RECURRING --
      last pass 2026-09-24, ad hoc; last numbered-session pass S752, 2026-09-21) -- `BACKLOG.md` is one of the
      dashboard's HIGH-risk ledger-size items but does not fit `methodology_trim.py`'s chronological-record model: its `##` sections
      are standing *topical* categories that accumulate resolved-item narrative indefinitely, not
      dated newest-on-top records. The file's own header states the remedy ("Open, actionable work
      only... for history see `CHANGELOG.md`"). Sections **regrow** as later sessions append their
      own progress narrative (S606 found the S531 "fully RESOLVED" claim was only a snapshot), so
      this is a recurring maintenance pass, never a one-time fix.
      **Pass history** (per-pass detail in `CHANGELOG.md`): S529 Housekeeping section (263 lines
      removed; its inventory found 2 items with NO ledger entry -- the `inst/extdata/` reorg
      S415-418 and the non-portable-filename fix S497, a real FM #27 gap -- and both were
      backfilled before compressing); S530 "Pedigree diagram vs kinship2" (896->286 lines); S531
      "Genetic-metrics PDF audit follow-ups" (753->267; file total 2,501->1,173 across the three
      passes); S606 re-compressed Genetic-metrics after regrowth (304->80) and fixed 2 stale claims
      found in the same pass; **S752** (2026-09-21) re-compressed Genetic-metrics again (regrown to
      91 lines by the issue #148 chain, all 14 issues now closed -> 62 lines incl. the extracted
      open item), condensed this item's own pass history (91 -> 38 lines), extracted the
      Genetic-metrics section's one buried open thread as its own item, and ran the
      S606-requested regrowth check on "Pedigree diagram vs kinship2": **NOT regrown**
      (286->156 lines; S686's completed-item removals shrank it, and what remains is S530's own
      ratified summary).
      **2026-09-24** (ad hoc, owner-picked from a staleness review; each cited session, Learning
      and issue checked against the ledger, `PROJECT_LEARNINGS.md` and `gh issue view` first):
      removed 2 completed items (the REUSE-badge registration -- the live badge now reads
      "compliant" -- and the empty `untitled folder`), fixed 4 stale statements, merged the
      duplicate `## Up Next` and dropped the empty/resolved headings, and compressed the LabKey
      item (44 -> 15 lines) and the kinship2 section's S435-S500 DONE narrative (84 -> 20 lines;
      the owner ratified this deeper cut at the pick). The LabKey item was compressed in place and
      the QC'd-copy Diagram item rewritten with its measured cause; every other open item is
      byte-identical. **Later the same day**, at the owner's direction ("if the work really was
      done, it should be in `CHANGELOG.md`"), the last three resolved sections -- `## Architecture
      (issue #122 ...)`, `## Audit follow-ups` and the Genetic-metrics section, 58 lines -- were
      deleted after checking each against the ledger (issue #122: 7 tagged entries;
      Genetic-metrics: 14 issues closed, 69 tagged entries; Audit follow-ups: 7 of its 8 items
      recorded, and the eighth, NEW-53, fixed 2026-05-31 in `5f40b7af`, backfilled). The file now
      ends at `## Outreach`.
      **Method (every pass, all steps):** before compressing anything to a pointer, (1) verify
      `CHANGELOG.md` + `docs/archive/CHANGELOG-*.md` carry an entry heading for every session
      number cited AND that the load-bearing facts are inside those entries (a heading alone proves
      little); (2) confirm every cited Learning / doc path resolves and every issue state via
      `gh issue view`, not prose; (3) extract any buried open thread as its own item first; (4)
      replace whole line ranges mechanically (Learning 537: a partial `old_string` leaves later
      paragraphs duplicated beside the new bullet); (5) leave open items byte-untouched; (6)
      re-read the compressed result end to end.
      **Candidates for the next pass (measured 2026-09-24; re-grep, sizes not anchors):** none --
      no resolved-narrative section or stub remains, and every remaining `##` section holds open
      items. Regrowth check: 378 lines now; the file was 480 lines after S752 and 561 before this
      pass. The next pass is a regrowth check, not a known cut.

## Pedigree diagram vs kinship2 audit follow-ups (from ISSUE_129_KINSHIP2_FEATURE_COMPARISON_2026-07-30.md)
*S435's capability comparison of the issue #129 pedigree diagram against kinship2's drawing
feature set (`docs/audits/ISSUE_129_KINSHIP2_FEATURE_COMPARISON_2026-07-30.md`) produced 8
recommendations; S436 (2026-07-30, owner direction) filed all 8 as GitHub issues #131-#138 in an
owner-set priority order that inverts the audit's own. **All are shipped and closed except #138**
(full-colony rendering beyond the 1,500-node cap: `low priority` label, needs its own scoping
session first; tracked on GitHub, not here). Implementation followed
`docs/audits/PEDIGREE_DIAGRAM_BACKLOG_SEQUENCING_AUDIT_2026-08-08.md` (S480). **Tier 1**
(S481-S484): the dangling-parent crash fixes (issue #154); the issue #145 verification spike --
kinship2 v1.9.6.2 implements neither a hard male-left invariant nor a sex-aware
crossing-minimizing default (`docs/research/issue-145-kinship2-sire-dam-placement-spike-2026-08-08.md`);
and a refresh of `docs/planning/pedigree-diagram-kinship2-reference-comparison.qmd`. **Tier 2**
(S485-S500): #133 (affected status, closed S487), #136 (name labels, S490), #137 (twin/zygosity,
S494) and #145 (sire/dam placement, S500, simple-pair scope), each from a ratified plan in
`docs/planning/` and one to three strict-TDD slices with the citation / tutorial / `NEWS.Rmd` /
`a2interactive.Rmd` checklists applied; kinship2's `affected` and `relation` argument conventions
were adopted in #133 and #137. None reopens issue #129 or the visNetwork-vs-kinship2 technology
decision (D2), which stands as ratified. Session-by-session record: `CHANGELOG.md`; technical
findings: `PROJECT_LEARNINGS.md` Learnings 410, 411, 485, 488-499. The open items below are the
section's live work.*

- [ ] **Candidate C's connector/dogleg visual-signposting idea** (found S473,
      designing the issue #144 plan; not adopted for #144 itself, Effort
      unknown, low priority) -- extends the existing D2 mate-line "dogleg"
      (issue #142) to `edgeStyle="direct"` (which currently gets zero
      compensating treatment for any cross-generation connector) and adds
      dashed/colored/titled styling to both edge styles so a
      multi-generation-spanning mate-line reads as intentional rather than a
      positioning bug. Fully validated (including a real ~37%
      `edgeStyle="rectilinear"` performance regression found and fixed during
      design) but requires its own fresh, explicit owner product-level
      sign-off to pursue -- independently valuable as a diagram-readability
      enhancement, decoupled from #144's own resolution (which does not need
      it). See `docs/planning/issue144-anchor-row-mismatch-fix-plan.md` §5/§8.
      **Also considered and again not adopted for the kinship2-fidelity remediation plan's
      Track 4 (design S572, implemented S573, 2026-08-14)** -- Track 4 ratified and shipped
      Candidate A (gen-aware D2 anchor selection) instead, see
      `docs/planning/pedigree-diagram-track4-gen-aware-anchor-plan.md` §3/§8. Live-rendered
      (S573, both `edgeStyle` values, zero console errors) with the redistribution this decision
      predicted (duplicate nodes 128->102, multi-anchor individuals 2->22, max 5). Still not
      precluded -- remains open as a future, separately-scoped enhancement if the owner judges,
      from that live render, that remaining cross-generation mate-lines still benefit from
      signposting for legibility.
- [ ] **The live app's uploaded/QC'd copy of `obfuscated_rhesus_mhc_ped.csv` gets a different
      Diagram layout than the same CSV read directly -- cause found (row order); decision open**
      (found S472, cause measured 2026-09-24, low priority, Effort S) -- the S472 figures (739
      live vs 740 offline nodes; 50 vs 51 projection nodes) no longer reproduce, since the layout
      has changed since (e.g. Track 4, S573), and the original hypothesis -- that `qcStudbook()`
      drops or merges a row -- is REFUTED: it keeps all 375 rows and ids (none lost or added, 0
      duplicates), and `makePedigreeDiagramData()` returns the same 375 nodes / 502 edges for
      both inputs. What differs is row ORDER -- `qcStudbook()` reorders the rows -- and the mating
      layout depends on it: `makePedigreeMatingLayout()` gives 782 nodes for both inputs under
      `edgeStyle = "direct"`, but **1456 (raw order) vs 1412 (QC order)** under `"rectilinear"`,
      and the raw content re-ordered to QC's row order gives exactly 1412 (so order alone
      reproduces QC's count; QC also normalizes some id/sire/dam/sex cells, not characterized).
      Consequence: the app's rectilinear diagram of an uploaded file can carry a different
      number of waypoint nodes than a script user's diagram of the same data, depending only on
      row order. A future session should decide whether that row-order dependence is acceptable,
      and whether the bundled-fixture tests (`test-e2e-pedigree-module.R`, etc.) should assert the
      QC'd count rather than the raw-CSV count as a proxy for what the live app renders.
- [ ] **`data-raw/rhesusPedigree.R`'s docstring claims
      `rhesusPedigree_fromCenter.csv` is an independent raw/pre-obfuscation
      source for `obfuscated_rhesus_mhc_ped.csv`, but the two shipped fixtures
      are byte-identical on every shared column** (found S470, incidental to
      the founder-positioning audit above, Effort S, low priority) -- confirmed
      via `identical()` on `id`/`sire`/`dam`/`sex`/`gen`/`birth`/`exit`/`age`
      between the two files; `rhesusPedigree_fromCenter.csv` differs only by
      one added `fromCenter` column (all `TRUE`). The documented `obfuscatePed()`
      id/date-obfuscation transform was evidently never applied to produce this
      particular fixture, or produced a no-op. Not fixed this session (reported
      per `PROJECT_LEARNINGS.md` Learning 382's "report, don't fix mid-session"
      precedent -- out of the founder-positioning audit's own scope). A future
      session should reconcile the docstring against the shipped fixture (or
      regenerate `rhesusPedigree_fromCenter.csv` to match the documented
      provenance). See `docs/audits/FOUNDER_POSITIONING_DEFECT_AUDIT_2026-08-03.md`
      Finding #4, `PROJECT_LEARNINGS.md` Learning 468.
- [ ] **`highlightNearest` degree=6 mitigation for the rectilinear style is
      bounded, not a full fix** (found S468, Effort M, low priority) -- a
      very wide sibship's D1 sibship-bar chain can exceed 6 hops (chain
      length scales with the number of children in one mating unit), so a
      hover on an individual in a very large family could still light up
      nothing visible. A full fix would need either a custom JS
      `highlightNearest` reimplementation that specifically skips through
      invisible waypoint nodes regardless of hop count, or a data-layer
      change that keeps degree-1 semantics correct (e.g. tagging waypoint
      edges so a custom traversal treats them as zero-cost hops). Not
      designed this session -- the degree=6 mitigation was explicitly
      scoped as a quick, bounded fix, owner-directed via `AskUserQuestion`.
      A future session should measure the real fixture's own maximum
      sibship size to gauge how often 6 hops is actually insufficient in
      practice before deciding whether a full fix is warranted.

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
