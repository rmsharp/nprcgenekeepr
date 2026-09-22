# Backlog

*Open, actionable work only. Completed history → `CHANGELOG.md`; feature inventory &
future plans → `ROADMAP.md`. (Methodology file model — see `SESSION_RUNNER.md` Phase 0.)*

## Up Next

- [ ] **Replace the broken x86_64 `/usr/local/bin/pandoc` on this machine** (found S756,
      2026-09-21, DECISION NEEDED / owner action, Effort S) -- the root-owned
      `/usr/local/bin/pandoc` (x86_64, Mar 2023) now fails with "Bad CPU type in
      executable" on this arm64 machine (Rosetta unavailable at Darwin 27), which crashes
      `rmarkdown::find_pandoc()` outright ("subscript out of bounds" -- discovery probes
      every candidate incl. PATH and dies on the un-executable binary, so `RSTUDIO_PANDOC`
      alone cannot rescue it) and with it every local vignette build, including the
      `tarball_size_clean_export` ratchet gate. S755 measured the gate cleanly earlier the
      same day -- this is a between-sessions environment change, not a repo regression.
      Fix (owner, needs sudo): `sudo rm /usr/local/bin/pandoc` (RStudio's bundled arm64
      pandoc 3.10 then serves) or install an arm64 pandoc (`brew install pandoc`).
      Session workaround until then (used S756, recorded in its receipt):
      `PATH=/Applications/RStudio.app/Contents/Resources/app/quarto/bin/tools/aarch64:$PATH`
      before any ratchet/vignette run. Blast radius grew (found S757): the break also
      errors 3 chromote live-render tests in the local full suite
      (`test_positionMatingUnitForest.R` -- htmlwidgets' self-contained render shells out
      to pandoc); the same PATH workaround clears them (212/212 clean re-run), so a local
      "3 errors" suite read on that file is this environment break, not a regression.
      NOTE: the pandoc swap (2.x x86_64 → 3.10 arm64)
      shifted the measured tarball to 3,468,810 B (−20,307 B vs S755) -- toolchain
      artifact, not content change.

## Active

## Architecture follow-ups (from TECH_DEBT_AUDIT_2026-05-30.md, re-verified 2026-07-11)
*Resolves the former "Tracker reconciliation" decision item (S365) --
`docs/audits/XARCH_TRACKER_RECONCILIATION_AUDIT_2026-07-11.md` re-verified all 8
XARCH-1..8 findings against current source rather than trusting the six-week-old
audit text. XARCH-1/3/7 are fully RESOLVED (no further tracking). XARCH-2 (implicit/
inconsistent module contract) and XARCH-5 (string-column-keyed pipeline, no
validated seam) are STILL OPEN and owner-directed to GitHub issues #122 and #123
respectively -- track them there, not here. XARCH-4 (sex-code literal
centralization) is now also fully RESOLVED -- S367 (2026-07-12): see
`CHANGELOG.md`. XARCH-6 (`qcStudbook()`/`modInput.R` multi-call redundancy) is
now also fully RESOLVED -- S368 (2026-07-12): see `CHANGELOG.md`. XARCH-8's
narrower remaining gap is now also fully RESOLVED -- S369 (2026-07-12): see
`CHANGELOG.md`. The `man/filterPairs.Rd` staleness this recurring collateral
regen left behind (S367 origin, flagged S368/S369) is now also RESOLVED --
S370 (2026-07-12): see `CHANGELOG.md`. No items remain in this section.*

## Up Next
- [ ] **Act on the LabKey integration research recommendations** (BLOCKED -- remainder
      needs a live LabKey server to test/observe, Effort M) — research pass DONE
      (`docs/research/labkey-integration-options-2026-06-19.md`, S143). **Rec #3 (explicit optional
      API-key auth with `.netrc` fallback + clear error) DONE — S144, `setLabKeyDefaults()`.
      Rec #1 (`Rlabkey` version floor) DONE — S146, `Rlabkey (>= 3.2.0)` in `DESCRIPTION` (all four
      EHR-module repos target LabKey 26.6; the live ONPRC/SNPRC server version, doc §8.1, is still
      unobserved). See `CHANGELOG.md`.
      Rec #2 (config-ize the ONPRC defaults) DONE — S147: centralized into the internal
      `defaultSiteParams()` (single source of truth for `getSiteInfo()`'s no-config fallback; no
      behavior change) + documented the center-specific `lkPedColumns` form in the example config
      (flat `dam`/`sire` = SNPRC direct columns; `Id/parents/dam` = ONPRC curated lookup). All three
      quick wins (Rec #1/#2/#3) DONE.**
      Rec #4/#5 (formalize a data-source adapter on the `getPedDirectRelatives` seam + a deterministic
      mocked integration test) DONE (fetch-boundary slice) — S148: internal `getPedigreeSource()`
      (`labkey` | `dataframe`) now backs `getLkDirectRelatives()`'s fetch with the walk byte-identical,
      plus the first deterministic walk test. **Walk-unification DONE — S149:** `getLkDirectRelatives()`
      now delegates its pedigree walk to `getPedDirectRelatives()`, so the LabKey/EHR path returns the
      full connected pedigree component (collaterals included), consistent with the in-memory function —
      a deliberate, owner-accepted behavior change; the deterministic test now asserts the full
      component incl. the previously-excluded collateral sibling. **`file` provider DONE — S150:**
      `getPedigreeSource()` gained a `"file"` source (params `fileName`/`sep`) that reads a pedigree file
      (CSV or Excel) via the exported `getPedigree()`, alongside `"labkey"` and `"dataframe"`;
      offline-deterministic, validates id/sire/dam, errors loudly like the `dataframe` branch.
      **`"file"` provider WIRED to a first-class caller DONE — S151:** new exported
      `getFileDirectRelatives(ids, fileName, sep, unrelatedParents)`, a file-sourced sibling of
      `getLkDirectRelatives()` (reads via the `"file"` provider, then the source-agnostic
      `getPedDirectRelatives()` walk). The clean symmetric family is now `getPedDirectRelatives`
      (in-memory) / `getLkDirectRelatives` (LabKey) / `getFileDirectRelatives` (file).
      **Option C — file pedigree source through the focal-animal app pipeline DONE — S152:** new exported
      `getFocalAnimalPedFromFile(fileName, pedigreeFileName, sep)`, a file-sourced sibling of
      `getFocalAnimalPed()` (reads focal Ids from one file, builds the connected component from a separate
      pedigree file via `getFileDirectRelatives()`; fail-soft to a classed `nprcgenekeeprFileErr` whose
      `message` names WHY the read failed — bad focal-id list file, a missing/not-found/unreadable/
      wrong-column pedigree file, or no focal IDs matched — surfaced as the app's "File Read Error"
      detail (richer error messages added S155). `modInput`
      gained an optional pedigree-file input on the focal-animals path and dispatches to the offline
      function when supplied, else the unchanged LabKey path — so the Shiny focal-animal workflow can now
      run offline with no LabKey/EHR connection. (The focal-id read was factored into a shared internal
      `readFocalAnimalIds()`.) **Still deferred:**
      a non-LabKey other-EHR provider on the same seam; server-side filtering / `executeSql` / consuming
      the centers' `study.Pedigree`/`ehr.kinship` (research doc explicitly defers until pull size is
      measured + per-center query availability/permissions are confirmed; needs a live LabKey server to
      test/observe, and a naive focal-id server filter is incompatible with the client-side
      connected-component walk).
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
- [ ] **Register `rmsharp/nprcgenekeepr` with api.reuse.software so the REUSE badge renders its
      real compliance status** (found S607, 2026-08-18, DECISION NEEDED / owner action, Effort S)
      -- the badge added above currently renders gray **"unregistered,"** not green: hitting
      `https://api.reuse.software/badge/github.com/rmsharp/nprcgenekeepr` directly returns an
      "unregistered" SVG, and `https://api.reuse.software/info/...` returns "Project not
      registered." This REUSE API service requires a one-time manual registration at
      https://api.reuse.software/register (repo URL + an email address, confirmed via a
      confirmation email) before it will crawl and report a project's actual compliance state --
      this is not something a session can or should do on the owner's behalf (it ties an email
      address to the public registration and is a one-way "join the registry" action). The repo
      itself IS `reuse lint`-compliant now (1234/1234, verified locally); only the badge's live
      display is blocked on this registration step. A future session can verify the badge went
      green after the owner registers, but cannot perform the registration itself.
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
      last pass S752, 2026-09-21) -- `BACKLOG.md` is one of the dashboard's HIGH-risk ledger-size
      items but does not fit `methodology_trim.py`'s chronological-record model: its `##` sections
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
      **Method (every pass, all steps):** before compressing anything to a pointer, (1) verify
      `CHANGELOG.md` + `docs/archive/CHANGELOG-*.md` carry an entry heading for every session
      number cited AND that the load-bearing facts are inside those entries (a heading alone proves
      little); (2) confirm every cited Learning / doc path resolves and every issue state via
      `gh issue view`, not prose; (3) extract any buried open thread as its own item first; (4)
      replace whole line ranges mechanically (Learning 537: a partial `old_string` leaves later
      paragraphs duplicated beside the new bullet); (5) leave open items byte-untouched; (6)
      re-read the compressed result end to end.
      **Candidates for the next pass (measured S752; re-grep, sizes not anchors):** "Pedigree
      diagram vs kinship2" -- its ~30-line S436 triage intro + ~45-line "Tier 1/Tier 2 DONE" block
      are resolved narrative (~60-75 lines recoverable), but that is a DEEPER cut than S530
      ratified, so it needs fresh owner ratification, and its 4 open items stay untouched; the
      LabKey item -- ~44 lines, mostly DONE narrative for Recs #1-#5 (S143-S152) around an
      ~6-line open remainder; structural residue -- a duplicate empty `## Up Next` heading and
      an empty `## Active` heading near the top, an empty `## Documents` heading, and two
      fully-resolved section stubs (`## Architecture follow-ups`, ~15 lines;
      `## Architecture (issue #122 / XARCH-2 ...)`, ~6 lines).
- [ ] (found S568, 2026-08-14, incidental to this session's own `pkgbuild::build()` verification,
      Effort S, not fixed this session) **An empty, untracked `inst/extdata/reference/untitled
      folder` directory** (dated 2026-08-13, the same day as the now-resolved "Compounding Loop"
      files) sits in the package source tree -- `R CMD build` silently drops it during staging
      ("Removed empty directory..."), so it has no build-correctness impact, but it's a stray Finder
      artifact with no content. A future session should confirm with the owner it's safe to delete
      and remove it (no `.gitignore`/`.Rbuildignore` entry needed for an already-build-dropped empty
      directory -- just a filesystem cleanup).

## Pedigree diagram vs kinship2 audit follow-ups (from ISSUE_129_KINSHIP2_FEATURE_COMPARISON_2026-07-30.md)
*S435's capability-comparison audit (`docs/audits/ISSUE_129_KINSHIP2_FEATURE_COMPARISON_2026-07-30.md`)
compared the just-shipped issue #129 pedigree-diagram feature against kinship2's pedigree-drawing
feature set (17-point checklist, 8 findings, 8 recommendations). Triaged S436 (2026-07-30) via
explicit owner direction (free-text, not per-item `AskUserQuestion` picks): **all 8 recommendations**
filed as GitHub issues, tracked there, not here -- including Recommendations 4-7, which the audit
itself scored "no action" (data-model-gated, or an already-ratified Dragon-P3 scope tradeoff);
filing tracks the idea for future consideration and does not reverse the audit's own assessment
(each issue body preserves the audit's original disposition text verbatim). Owner set an explicit
priority order that **inverts** the audit's own suggested ordering (which rated Finding #1 highest):
**#131** (diagram image/print export, Finding #3/Rec #2, priority 1) -- **#132** (in-app
shape-to-sex legend, Finding #6/Rec #3, priority 2, also resolves plan Dragon P5) -- **#133**
(affected/phenotype/genotype status encoding, Finding #2/Rec #4, priority 3, data-model gated) --
**#134** (verify inbreeding-loop/consanguinity rendering, Finding #1/Rec #1, priority 4, resolves
plan Dragon P2 / `PROJECT_LEARNINGS.md` Learning 410) -- **#135** (hover tooltips + search/highlight,
Rec #8, priority 5) -- **#136** (name labels instead of ID-only, Finding #8/Rec #7, priority 6,
data-model gated) -- **#137** (twin/zygosity encoding, Finding #5/Rec #5, priority unranked by the
owner, placed 7th as an inference not a stated decision) -- **#138** (full-colony rendering beyond
the 1,500-node cap, Finding #7/Rec #6, priority 8 -- explicitly deprioritized/delayed by the owner,
`low priority` GitHub label applied). Owner also directed (mid-session, 2026-07-30) a broader goal:
overlay kinship2's genetics-domain naming conventions onto the pedigree data model where applicable
when these are implemented, and build test pedigree fixtures with the corresponding added columns --
folded into #133 (kinship2's `affected` argument convention) and #137 (kinship2's `relation`
argument convention), the two data-model-adding items. Owner also directed that any plan
implementing one of #131-#138 must include a documentation phase (`vignettes/articles/
colony-manager-guide.qmd` and/or `vignettes/manual_components/_pedigree_browser.Rmd`), now recorded
as `CLAUDE.md`'s "Tutorial/article documentation checklist" -- checking whether this was already
true for the base feature found it was not: **issue #139** tracks that issue #129's already-shipped
Diagram tab has zero tutorial/article coverage today. See `PROJECT_LEARNINGS.md` Learning 411 and
`CHANGELOG.md` for the full S436 triage record. None imply reopening issue #129 or revisiting the
visNetwork-vs-kinship2 technology decision (D2), which stands as ratified.*

**Sequencing note (S480, 2026-08-08):** the items below through the `highlightNearest` degree=6
item, plus GitHub issues #133/#136/#137/#138/#141/#145, were jointly examined for implementation
order in `docs/audits/PEDIGREE_DIAGRAM_BACKLOG_SEQUENCING_AUDIT_2026-08-08.md` (kinship2-capability-
and nomenclature-reference-informed). Recommended order: (1) the two dangling-parent crash bugs
below + the free-pass-filter reachability check, (2) issue #145's verification spike, (3) refresh
the stale `.qmd` comparison doc below, (4) the owner's existing #133 > #136 > #137 > #138 order, (5)
#141 and Candidate C stay deferred pending new evidence/owner sign-off.

**Tier 1 -- DONE (S481, S482, S484):** the 2 dangling-parent crash bugs + the free-pass-filter
reachability check were filed and fixed as issue #154 (S481). Issue #145's verification spike (S482,
`docs/research/issue-145-kinship2-sire-dam-placement-spike-2026-08-08.md`) empirically confirmed
(kinship2 v1.9.6.2 source read + 5 synthetic-pedigree tests, not inferred from docs) that kinship2
implements **neither** a hard male-left invariant **nor** a sex-aware crossing-minimizing default --
once an individual has multiple mates, left/right is decided purely by pedigree-data discovery order;
the issue's own cited sources were found unreliable on this point. `docs/planning/pedigree-diagram-
kinship2-reference-comparison.qmd` was refreshed (S484) to reflect issues #143/#144's fixes and to
add a new Example 4 reproducing S482's own kinship2 counter-example directly (`quarto render` clean,
37 chunks).

**Tier 2 -- DONE (S485-S494, S499-S500): issues #133, #136, #137, and #145 are all now fully
implemented and closed.** Each followed design-document ratification (`AskUserQuestion`-gated
judgment calls) then 1-3 implementation slices, each slice a full strict-TDD PRE-RED->RED->GREEN
(->REFACTOR) cycle with clean regression + `devtools::check()` + live `shinytest2`/`chromote`
verification, plus the citation/tutorial/`NEWS.Rmd`/`a2interactive.Rmd` documentation checklists
applied per-slice:
- **Issue #133** (affected/phenotype status): design S485 (`docs/planning/issue133-affected-status-
  pedigree-diagram-plan.md` -- new `affected` logical column, `color.background` + tooltip, no new
  dependency). Slice 1 (data model + rendering) S486 -- found and fixed a gap where the rectilinear
  edge style would have silently erased the new coloring. Slice 2 (legend + docs) S487. **Closed
  S487.**
- **Issue #136** (name labels): design S488 (`docs/planning/issue136-name-labels-pedigree-diagram-
  plan.md` -- corrected 3 premises in the issue itself; found and closed a disclosure defect,
  `obfuscatePed()` would have left `name` unscrubbed). Slice 1 (data model + de-identification) S489.
  Slice 2 (label rendering + off-by-default toggle + docs) S490 -- found and fixed a real
  toggle-discarded-on-rerender defect via live verification (`PROJECT_LEARNINGS.md` Learning 490).
  **Closed S490.**
- **Issue #137** (twin/zygosity encoding): design S491 (`docs/planning/issue137-twin-zygosity-
  pedigree-diagram-plan.md` -- new sidecar `twinRelations` table, zero schema.R changes; a
  workflow-truncation tooling defect found and worked around, `PROJECT_LEARNINGS.md` Learning 491).
  Slice 1 (data model + de-identification, `checkTwinRelations()`/`obfuscateTwinRelations()`) S492.
  Slice 2 (core rendering, MZ/DZ/UZ connector styles) S493. Slice 3 (UI wiring, legend, docs) S494 --
  found and filed (not fixed) a Slice 2 color-wiring gap as its own Housekeeping item. **Closed
  S494.**
- **Issue #145** (sire/dam left-right placement, deferred from Tier 1's spike): design S499
  (`docs/planning/issue145-sire-dam-left-right-placement-plan.md` -- a 3-agent adversarial review
  refuted the first proposed mechanism, `orderBySex = TRUE` parameter ratified instead). Slice 1
  (core positioning) S500. **Closed S500** for the ratified simple-pair scope.

**Issue #138** (full-colony rendering beyond the 1,500-node cap) is the one item in the owner's Tier 2
order this cluster did not reach -- still open, tracked as its own GitHub issue (`low priority`
label), needing its own scoping session first, matching #133/#136/#137/#145's own precedent. See
`CHANGELOG.md` for the full session-by-session record and `PROJECT_LEARNINGS.md` Learnings 485,
488-499 for the individual technical findings.
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
- [ ] **The live app's uploaded/QC'd copy of `obfuscated_rhesus_mhc_ped.csv`
      produces one fewer node than reading the same bundled CSV directly**
      (found S472, incidental to issue #143's live verification, Effort
      unknown, low priority) -- `direct`-style Diagram node count is 739 live
      vs. 740 via `read.csv()` + `.buildMatingUnitForest()`/
      `.positionMatingUnitForest()` directly (a stable, already-tested
      figure, unaffected by this session's fix); the live rectilinear
      -style projection-node count is correspondingly 50 vs. an offline
      -computed 51. Not investigated further this session (out of the
      issue #143 fix's own scope, per `PROJECT_LEARNINGS.md` Learning 382's
      "report, don't fix mid-session" precedent) -- most likely explained by
      the upload/QC pipeline (`modInput.R`'s `qcStudbook()` or similar)
      dropping or merging exactly one row relative to a raw `read.csv()`,
      but this was not confirmed. A future session should identify which
      individual differs and why, and decide whether the app's own bundled
      -fixture test coverage (`test-e2e-pedigree-module.R`, etc.) should
      assert this QC'd count explicitly rather than relying on the
      raw-CSV-read count as a proxy for what the live app actually renders.
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

## Architecture (issue #122 / XARCH-2 -- module contract)
*Resolved -- S372 planning session through S377 execution (Phases 1-5, all DONE); see
`CHANGELOG.md` for the per-phase detail (S373 vocabulary-composition fix, S374 kinship
dedup, S375 vocabulary collapse, S376 dead-surface pruning, S377 contract doc + guard
test). The living contract is `docs/architecture/module-contract.md`; it is enforced by
`tests/testthat/test_moduleContract.R`. `modInput` is the reference implementation.*

## Documents (v1.0.8 -> v2.0.0 write-up)

## Audit follow-ups
*(From `PED_GV_AUDIT_2026-05-30.md`; all audit follow-up items are now resolved — see
`CHANGELOG.md`. Per-item reachability notes and traps live in `CLAUDE.md` "Project-specific
Learnings".)*

## Genetic-metrics PDF audit follow-ups (from GENETIC_METRICS_PDF_CAPABILITY_AUDIT_2026-07-29.md)
*Every GitHub issue this cluster produced (#125-#130, #146-#153) is shipped and closed -- all 14
confirmed CLOSED via `gh issue view` (S752, 2026-09-21); the one live thread is the open item at
the end of this section. Full session-by-session record: `CHANGELOG.md`; per-issue technical
findings: `PROJECT_LEARNINGS.md` (Learnings 479, 532, 538-542, cited below).*

**Origin and sequencing.** S419's capability audit
(`docs/audits/GENETIC_METRICS_PDF_CAPABILITY_AUDIT_2026-07-29.md`) compared the package against the
2015 NHP Genetics and Genomics Working Group PDF (37 findings: 12 missing / 9 partial); S422
(2026-07-29, owner `AskUserQuestion` picks) filed **#125** (ranking-priority scheme + multiple
breeding-group candidates), **#126** (distribution-shape statistics), **#127** (surface
`correctUnknownParentMeanKinship()`'s dropped `flagged` list), **#128** (genetic-value floor for
breeding-group exclusion), **#129** (pedigree diagram) and **#130** (marker-based kinship/
heterozygosity/parentage + cross-center identity). One finding (NGS/whole-genome/MHC/
linkage-disequilibrium methods) was declined -- the PDF itself frames it as speculative. A ghost
session (reconciled S479, Learning 479) then produced two re-audits
(`docs/audits/GENETIC_METRICS_PDF_CAPABILITY_AUDIT_2026-08-05.md`, `..._2026-08-06.md`) and filed
**#146** (candidate retention), **#147** (likelihood-based candidate-parent assignment), **#148**
(MHC haplotype reporting), **#149** (cross-center identity mapping), **#150** (de-identified
pedigree export), **#151** (mate-pair analysis), **#152** (sequence input + metrics) and **#153**
(linkage-aware metrics). Sequencing ratified S483 (owner-directed,
`docs/audits/GENETIC_METRICS_ISSUES_SEQUENCING_AUDIT_2026-08-08.md`): Tier 1 #147; Tier 2 #149 >
#146 > #151; Tier 3 (policy-gated) #150; Deferred (design-only) #152 > #153 > #148, with #148
needing its own scope-narrowing conversation first. All shipped, each slice strict TDD with the
citation / `NEWS.Rmd` / `_pkgdown.yml` / tutorial-article checklists applied per slice
(`a2interactive.Rmd` deferred per `CLAUDE.md`'s standing rule).

**Issue #152** (sequence input + metrics; closed S535) -- design S517
(`docs/planning/issue152-sequence-input-genetic-metrics-plan.md`: sparse/GBS-scale tier, ~50,000-
locus ceiling, a `locusMetadata` sidecar shared with #153, a new tab in `R/modMarkerGenetics.R`),
then 5 vertical slices S525/S526/S532/S533/S535: the `checkSequenceGenotypeFile()` validator +
synthetic fixtures (`data-raw/generate_sequence_fixtures.R`,
`inst/extdata/examples/example_sequence_*.csv`), `markerKinship()`/`markerParentageLikelihood()`
speedups (Learning 532), `computeGenomicROH()` F_ROH (Learning 538), `obfuscateGenotypeMatrix()`
(Learnings 539/540), and the "Genomic ROH (F_ROH)" tab + `obfuscateGenomicROH()` (Learning 541;
Learning 542 retracts S535's suspected chromote harness limitation -- the cause was a test
fixture missing `birth`).

**Issue #148** (MHC haplotype reporting; closed S708) -- scoping S703
(`docs/planning/issue148-mhc-haplotype-scoping-2026-09-17.md`, owner: design-first, same issue),
plan ratified S704 (`docs/planning/issue148-mhc-haplotype-reporting-plan.md`, D1-D10), then 4
strict-TDD slices S705-S708: the `checkMhcHaplotypeFile()` validator,
`mhcHaplotypeFrequency()`/`mhcHaplotypeCarriers()`, `obfuscateMhcHaplotypes()`, and the 8th Marker
Genetics tab "MHC Haplotype Reporting" with confirm-gate export.
