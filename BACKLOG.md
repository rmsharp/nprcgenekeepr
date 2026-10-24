# Backlog

*Open, actionable work only. Completed history → `CHANGELOG.md`; feature inventory &
future plans → `ROADMAP.md`. (Methodology file model — see `SESSION_RUNNER.md` Phase 0.)*

## Up Next

- [ ] **Performance and memory campaign: the owner approves the plan and rules D1-D4, then Phase 0
      (owner-directed S1050; DECISION NEEDED, then READY; Effort M per phase, 12 phases, each its own
      strict-TDD session)** -- plan: `docs/planning/performance-memory-campaign-plan.md` (S1050,
      `0bc77f06a`). Measured on the example at the app's defaults: the Genetic Value analysis takes
      about 3.5 s, 2.9 s of it in `calcGU()` + `calcGUSE()` (the same rare-allele count built twice);
      the two relationship downloads do not finish (600 animals take 65 s, about 10x per doubling,
      and the example has 3,694); Breeding Groups at 1,000 trials takes 23.6 s; the Diagram at 708
      animals 13.9 s; the app caches one full-pedigree kinship matrix (104.6 MB, n x n x 8 B) for six
      tabs. **Decisions first (plan section 6, each with a recommendation):** D1 exact results
      (`identical()` for the same seed), D2 plain R first (no Rcpp), D3 exported functions unchanged,
      D4 opt-in budget tests plus ratchet gates. Then Phase 0: the measuring harness (`tools/perf/`),
      the baselines doc and the gates, with no package behavior change; Phase 1 (genome uniqueness)
      after it. D5-D8 are asked in their own phases.

- [ ] **Move the version to 3.0.0 just before release (READY at release time, Effort S)** --
      the owner decided (S855) the next release is **3.0.0**. Until then `DESCRIPTION`, the
      `NEWS.Rmd`/`NEWS.md` heading, `README.md` and `ROADMAP.md` stay at 2.0.0.9000 on purpose.
      At release prep: set `DESCRIPTION` to 3.0.0, retitle the `NEWS.Rmd` dev block to 3.0.0 and
      re-knit `NEWS.md`, reinstall the package and re-render `README` (Learning 376), and update
      the 2.0.0.9000 cites in `ROADMAP.md`. The paper-dependency item below also waits on a
      released 3.0.0.

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

- [ ] **Earlier-snapshots follow-ups after #170 (two threads left, extracted S1040 when the
      #170 block came off; #170 is closed; the tutorial thread was done S1042, the trend chart's
      console notice and the notice's 200-character cut S1049)** -- design and what was built:
      `docs/planning/retrospective-snapshot-backfill-plan.md` sections 5.3-5.4.
      (1) **Build cost on a larger colony** (BLOCKED --
      needs a studbook above 3,694 rows from the owner, Effort S): the cost line's 4 seconds per
      1,000 iterations (`describeBackfillCost()`, `R/modSnapshotTrends.R`) is measured up to
      100 iterations on a 3,694-row colony, so a bigger colony at 1,000 iterations is unmeasured.
      (2) **A script word in the panel's notice** (DECISION NEEDED, Effort S): the function's
      failed-dates warning says "listed in 'skipped'" and the panel shows it as is, while its
      table is headed "Dates not built"; reword the message for both readers, or leave it.

- [ ] **Tutorial leftovers after the S1043 inventory pass: twin-corrected kinship, and a guard for
      omitted exports** (DECISION NEEDED, Effort S; found S1043) -- the pass named the six functions
      and the two parameters it had left (the next pass compares against this pass's commit
      `649389386`, not S541): 170 of the 236 exports are still never named, which is not a gap
      (the tutorial is a walkthrough, not a reference). Three things are open. (1) **`twinRelations`**
      is used in a call only on `makePedigreeMatingLayout()`; the `reportGV()` argument list names it
      and points to `?reportGV`, and the "Passing a Kinship Matrix You Already Have" section says
      `kinship()` takes it, but no output shows a twin-corrected kinship matrix (`kinship()`,
      `reportGV()`, `gvaConvergence()`, `createSimKinships()` and `cumulateSimKinships()` accept it).
      `checkTwinRelations()` wants a same-sex pair for an MZ call and the tutorial's pair is a
      mixed-sex UZ pair, so a demo needs its own pair; whether one belongs is a decision. (2) **No
      guard notices a new exported function the tutorial omits**; one would need an allow-list of the
      never-named set (170 today), so whether it is worth the upkeep is a decision. **Method for the
      next inventory:** formals at the old commit from a scratch `git worktree` through
      `pkgload::load_all()` run in the main checkout (renv), against today's; search each name with a
      boundary that ignores `_` (the tutorial writes `__fn__`, and `\b` treats `_` as a word
      character, so it misses them: S1043's first total of 182 was 176) and confirm every "unnamed"
      claim with `grep -F` on the committed text. Pattern for a section:
      `tests/testthat/test_inventoryTutorialSections.R` (the shared readers `insideChunk()`,
      `sectionProse()` and `chunkOptionText()` are in `helper-pageText.R`).
      (3) **A new parameter since the pass** (S1045, `3ba3fd51b`): `plotSnapshotTrends()` takes
      `ncol`, the number of panel columns. The tutorial's chart has 3 panels, where the default
      grid is right, so whether the tutorial shows `ncol` is a decision.

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
      not anchors):** this item's own history (41 lines) and the paper item (24). The
      standalone-package item is still 34 lines but is nearly all ratified-scope open text;
      leave it. Regrowth, for scale: 378 lines on 2026-09-24, 599 at S853, 552 before S890,
      514 after S896.

- [ ] **Take the methodology files the S1032 sync held back (BLOCKED -- on a fix to `close_out_report.py` in the
      methodology repo, Effort S once it ships)** (found S1032, 2026-10-22) -- the sync copied 7 of 10 files and, at the
      owner's word, held back `SESSION_RUNNER.md` (2 versions behind), `SAFEGUARDS.md` (1 behind) and the new
      `close_out_report.py` (not installed). The newest runner (commit `8f63492b`) makes section 3G run
      `python3 close_out_report.py` and print its output as the last message; v1.2.0 reads the example box in
      `HANDOFFS.md`'s front matter as the newest receipt and refuses (`refused: newest receipt (S<N>) is <pending |
      complete>`), here and on the blank seed. The runner's Oct 12 commit `95005e87` (its subject: a gate run that reads
      unmeasured gates is repaired and repeated, or each gate is named) is held with it. Evidence, a tested 4-line fix and
      the draft upstream report, **not posted anywhere** (where to post it is the owner's call):
      `docs/audits/CLOSE_OUT_REPORT_EXAMPLE_BOX_2026-10-22.md`. **What is left:** when the script reads this ledger, sync
      again (`bin/sync --force`, then the trimmer patch per `docs/conventions/CLOSEOUT_CHECKLISTS.md`) and, before keeping
      the script, print a report from a ledger whose newest receipt is complete; `bin/status` lists these three files
      until then.

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
      the NIH grant acknowledgment). Natural dependency, the owner's call: a released 3.0.0 to
      cite (`DESCRIPTION` reads 2.0.0.9000 today); the documentation audit is finished (S1027,
      `CHANGELOG.md`), so the papers' figures match the software.
