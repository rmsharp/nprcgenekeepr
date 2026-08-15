# Backlog

*Open, actionable work only. Completed history → `CHANGELOG.md`; feature inventory &
future plans → `ROADMAP.md`. (Methodology file model — see `SESSION_RUNNER.md` Phase 0.)*

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

## Housekeeping
- [ ] (found S584, 2026-08-15, incidental to running the build equivalent during close-out,
      **READY, Effort S**) **`devtools::check()` -- the project's own documented build equivalent --
      is RED on `master` and has been since S573, with no session reporting it.** Final line:
      `1 error | 0 warnings | 1 note`. The error is `test_wordlist_coverage.R:121` failing because
      `inst/WORDLIST` does not cover 2 words `spelling::spell_check_package()` flags: **`matings`**
      (`NEWS.md:232`) and **`visNetwork's`** (`NEWS.md:208`). Both entered `NEWS.md` in `c9860f4b`
      (S573, 2026-08-14 14:34). The note is the long-known `vignettes/figure/` knitr leftover
      (already tracked elsewhere in this file). Under the `test_dir` clean-regression read the same
      test flags **4** words (`matings`, `Rectilinear's`, `runnable`, `visNetwork's`) rather than 2,
      because that read sees the vignette `.qmd` sources while the built package under `check()`
      sees only `NEWS.md` -- so a fix must cover all 4, not just the 2 `check()` reports.
      **Fix is expected to be a one-line `inst/WORDLIST` addition** (all 4 are legitimate domain or
      package-name terms, not misspellings), plus a re-run of the build equivalent to confirm it
      returns to `0 errors`. Not fixed in S584 (a second deliverable, out of that session's
      diagnose-the-CI-failure scope -- `PROJECT_LEARNINGS.md` Learning 382's report-don't-fix
      precedent). **Worth a moment's care when picking this up:** S581's own handoff reports
      `devtools::check()` as "0 errors/0 warnings/1 pre-existing NOTE" at a close-out ~9 hours AFTER
      `c9860f4b` landed. S584 could not reconstruct why that run differed and deliberately drew no
      conclusion; a session fixing this should note that `test_wordlist_coverage.R:113` calls
      `skip_on_cran()`, so whether the test runs at all depends on `NOT_CRAN`, which differs between
      a bare `R CMD check` and `devtools::check()` (the latter sets it) -- that is the most likely
      explanation to check first, and it also determines whether CI's own `R-CMD-check.yaml` is
      currently masking this failure. See `CHANGELOG.md`.
- [x] (found S584, 2026-08-15, incidental to diagnosing the red scheduled `shinytest2.yaml` run,
      **RESOLVED S584 -- owner directed "push" in-session; the unpushed state was NOT deliberate.**
      Pushed `7021c6f7..7436a7a9`, 148 commits, clean fast-forward, no force. `master` and
      `origin/master` now in sync. The 4 push-triggered workflows fired automatically;
      `shinytest2.yaml` was additionally dispatched by hand (`gh workflow run shinytest2.yaml
      --ref master`, run `31868762486`) because it has no push trigger -- exactly as this item
      predicted. Outcome of those 5 runs is recorded in `CHANGELOG.md`. Original finding, kept for
      the record:) **Local `master` was 145
      commits ahead of `origin/master` and unpushed, so every scheduled CI workflow is testing a
      snapshot from Session 545 (`7021c6f7`, 2026-08-13) rather than current work.** Confirmed from
      the failing run's own log (`Commit: 7021c6f7...`, `git checkout ... refs/remotes/origin/master`)
      and `git rev-list --count origin/master..master` = 145. Two live consequences, both hit during
      S584's diagnosis: **(a)** the nightly `shinytest2.yaml` red/green signal says nothing about the
      code actually being written -- S584's own fix for the genuine defect it found is verified
      locally but CANNOT be observed green in CI until a push happens, since that workflow is
      `schedule`/`workflow_dispatch` only (no push trigger); **(b)** CI logs from a stale snapshot
      produce false defect signals -- S584 initially read a missing `^e2e-twin-relations-` module
      group in the CI log as a possible Learning-312 partition-drift defect, when in fact both that
      test file and its group regex were added together in the unpushed `c91f7c49` and are correct
      at `HEAD`. The 4 push-triggered workflows (`R-CMD-check`, `lint`, `pkgdown`, `test-coverage`)
      are likewise reporting on 145-commit-old code, and have not run against any work since S545.
      **Not acted on unilaterally** -- a push of 145 commits is an owner call, not a housekeeping
      decision a session should make on its own (and `master` carries no branch protection, so a
      push is immediately live). The owner then directed the push in the same session, which is why
      this item opened and closed within S584. See `PROJECT_LEARNINGS.md` Learning 592 and
      `CHANGELOG.md`.
- [x] (found S579, 2026-08-14, incidental to this session's own post-close-out ledger re-check;
      **RESOLVED S580**. **`HANDOFFS.md`'s own archive trigger fired** (line headroom 4 records,
      125,404 B against the 65,536 B budget). `--write` (dry run) refused with `SRF_RED` (SRF
      1.1566 against the most-recent archive `306a4b4` vs. 0.1201 against the largest-drop
      boundary `d07814a`, 9.63x spread) -- the same recurring shape Learnings 549/550/586
      diagnosed, now confirmed on this file too (`PROJECT_LEARNINGS.md` Learning 587). Pulled
      absolute byte deltas for both boundaries (116,204 B genuine regrowth in ~1 day vs. `306a4b4`,
      driven by 10 receipts averaging ~12.5 KB each); surfaced via `AskUserQuestion`
      (force/hold/raise-budget) -- owner chose **force**. Dry-run preview with `--force` confirmed
      L1/L2/L3 losslessness (21 of 22 records, 125,404 B -> 9,682 B) before writing; ran
      `--write --force`; the new shard's own `verify.sh` confirmed OK; post-trim `--check` clears
      both triggers (9,682 B, SRF non-positive against both boundaries). See `CHANGELOG.md`.)
- [x] (found S575, 2026-08-14, owner review of a published live-comparison artifact; **DESIGN
      RATIFIED S576, 2026-08-14; IMPLEMENTED S578, 2026-08-14 -- DONE**) **Pedigree Diagram:
      children are frequently rendered far from their own parent union -- a real, widespread
      legibility gap, distinct from and not caught by Track 5's diagonal-edge measurement.**
      Root cause: a mating unit's final x was the midpoint of its 2 real parents' positions,
      decoupled from where its own child was positioned during the earlier recursive descent.
      Design: `docs/planning/pedigree-diagram-track6-child-centered-union-position-plan.md`
      (Extended Candidate A -- recompute the union's x from its own children's final span,
      recompute the duplicate-parent node's x from the new union x, broaden the existing
      de-collision pass to cover duplicates). **Implementation (S578):** Pre-RED empirical
      validation found 2 corrections beyond the ratified design doc's own §2.1 snippet: (1)
      `finalUnitX`/`dupX` must be computed AFTER the `orderBySex` block, not at its
      literally-described pre-orderBySex location, or the invariant breaks for any union whose
      child is also swapped as a parent in a deeper union (measured 19/251 >200-unit violations
      without the reorder vs. the ratified 9/251 with it); (2) 3 real-individual x values (not
      just union/duplicate) shift as a side effect of removing duplicates from Track 3's sweep
      pool -- a real, non-epsilon consequence (`9VGCCV`, 0.5 units) the design doc's own §5
      Impact Analysis table did not state. Implemented with the reorder; re-measured on the real
      375-individual fixture: violating edges 100/251 -> 9/251 (91% reduction), worst-case
      offset 10,687 -> 4,121.37 (matches ratified figures), duplicate-to-union distance 61.94/
      120.12 -> 48.00/48.00 (exact match), 0 exact x/gen coincidences post-fix (including 1
      pre-existing duplicate/union coincidence unrelated to this decision, closed as a side
      effect). Full clean regression 1 pre-existing failure unrelated (`test_wordlist_coverage.R`,
      confirmed via the full suite run before vs. after); `lintr::lint_package()` 0 lints on
      touched files. Live/visual verification: rendered + chromote-screenshotted the small
      GA204Z/8LKBV9 fixture (both `edgeStyle` values) and the full real fixture (both values,
      0 console errors) -- visually confirmed a union now sits close to its own child (matches
      the fix's intent) and the duplicate dashed-connector convention is unaffected.
      **`devtools::check()`** (run as its own separate build-equivalent step, not skipped as
      redundant with the already-green `test_dir()` regression) **found a genuinely PRE-EXISTING
      latent defect this session's own change first exposed:** the de-collision pass's `order()`
      tie-break on node id strings is locale-dependent (`LC_COLLATE`), so which of 2 exactly-tied
      nodes absorbs the 1e-3 epsilon nudge could differ between an interactive session's locale
      and `R CMD check`'s own build environment -- reproduced directly via `LC_ALL=C`. Fixed with
      `method = "radix"` (locale-independent byte-order) on both affected `order()` calls;
      re-verified both locales now produce identical, matching output. See `PROJECT_LEARNINGS.md`
      Learning 585. See `CHANGELOG.md`.
- [x] (found S578, 2026-08-14, a broader grep sweep after fixing the locale-dependent `order()`
      defect above, **RESOLVED S581**. **The same locale-dependent `order()` tie-break class
      (`PROJECT_LEARNINGS.md` Learning 585) existed more broadly across the package.** Fresh
      `grep -n "order(" R/*.R` (26 call sites) classified all: 17 not locale-sensitive (numeric/
      index sort keys), 2 already `method="radix"` (Track 6). Of the 6 initially flagged as real
      hits (character-column sorts), empirical verification (RED-phase divergence testing,
      `withr::with_locale`) corrected 2 to FALSE POSITIVES: `kinshipMatrixToKValues.R:107`
      (protected by `data.table`'s own `[.data.table]` auto-substitution to `forder()`, confirmed
      via `datatable.verbose`) and `computeGenomicROH.R:112` (the intermediate `fullMeta` row
      order IS locale-sensitive, but the returned value is provably invariant -- `split()` groups
      by chrom regardless of inter-group order, same-chrom tie-breaking uses the numeric `pos`
      key; confirmed identical output across `LC_COLLATE="C"` vs. `"en_US.UTF-8"`). Explanatory
      comments left in both files documenting why, so a future session re-running this grep
      doesn't re-derive the investigation. **4 real hits fixed** (`method = "radix"` added,
      RED->GREEN->REFACTOR): `orderReport.R:81,93` (imports/noParentage tiers),
      `qcStudbook.R:323` (`order(gen, id)`), `modBreedingGroups.R:690` `bgGroupView` (Ego ID,
      no prior test coverage of this reactive existed -- new `shiny::testServer()` test added).
      Verification: 4 targeted RED tests GREEN; full clean regression 1 pre-existing failure
      unrelated (`test_wordlist_coverage.R`), 0 errors; 0 lints on touched files
      (`lintr::lint_package()`, project's own `.lintr` config); `devtools::check()` 0 errors/0
      warnings/1 pre-existing NOTE; live E2E (`NPRC_RUN_E2E=true`) confirmed all 3 affected
      runtime paths -- `test-e2e-mate-pair-analysis-module.R` (qcStudbook), `test-e2e-genetic-
      value-tutorial.R` (orderReport/reportGV), `test-e2e-breeding-groups-module.R` (bgGroupView)
      -- all pass. See `PROJECT_LEARNINGS.md` Learning 588. See `CHANGELOG.md`.
- [ ] (found S576, 2026-08-14, incidental to Track 6's own empirical validation of the
      child-centered union-position design, READY, Effort unknown -- not scoped) **Pedigree
      Diagram: sibling subtree-width asymmetry -- 2-3 direct children of the same mating unit can
      land far apart in x purely because their own descendant-subtree sizes differ, independent of
      where the union itself is positioned.** Distinct from (and not resolved by) Track 6's own
      child-centered union-position fix: even a union perfectly centered between its children
      cannot keep both edges short when the children themselves are positioned far apart. Measured
      on the real 375-individual fixture as Track 6's own residual: 9/251 (3.6%) child edges still
      exceed a 200-scaled-unit offset after Track 6's fix lands, concentrated in unions with only
      2-3 children. Concrete example: `__union_15` (gen 0)'s 2 children sit at raw x 29.88 and
      98.56 -- a 68.68-unit gap between direct siblings, more than half the entire fixture's own
      raw-x range. Root cause is one level down the same recursive contour-merge pattern Track 6
      addresses at the union level (D3, `docs/planning/pedigree-diagram-option2-layout-design-plan.md`):
      an individual's x is the centroid of their OWN full descendant subtree, so 2 siblings with
      very differently-sized subtrees (one prolific branch, one sparse/childless) end up far apart
      regardless of any parent-level positioning choice. Not investigated further this session (no
      candidate fix evaluated) -- likely needs its own design session given the change surface (the
      same core recursive positioning algorithm). See
      `docs/planning/pedigree-diagram-track6-child-centered-union-position-plan.md` §1.4/§8 for the
      full measurement and reasoning.
- [ ] (found S583, 2026-08-15, incidental to a user question about the just-reshot
      `pb_diagram_legend.png` screenshot, READY, Effort unknown -- not scoped, likely needs its
      own design session before any fix) **Pedigree Diagram: a mating union with a single child (or
      whose children's own midpoint happens to fall outside the parents' span) can be positioned
      entirely OUTSIDE its own two parents' x-range, not merely off-center between them --
      diverges from kinship2's own convention, which always centers the union symbol between the
      two spouses regardless of where children end up.** Distinct from the S576 sibling
      subtree-width item directly above: S576 measures how far a union ends up from ITS OWN
      CHILDREN; this finding is about how far the union can end up from ITS OWN PARENTS -- an axis
      Track 6's own verification (`docs/planning/pedigree-diagram-track6-child-centered-union-
      position-plan.md` §1.4/§2.4) never measured, because `finalUnitX[U] ==
      (min(x[C]) + max(x[C])) / 2` (unconditional midpoint of a union's children) has no term for
      the union's own parents at all. For a union with exactly one child, this collapses to
      `finalUnitX[U] == x[thatChild]` -- zero centering benefit (nothing to center between) while
      actively decoupling the union from its parents' span if that one child's own x has been
      pulled elsewhere by ITS OWN later descendants. **Concrete, reproduced example** (the real
      `obfuscated_rhesus_mhc_ped.csv` fixture, `trimPedigree(c("8LKBV9","FJIB3R","GA204Z"), ped)`,
      the same 6-animal subgraph `pb_diagram_legend.png` depicts): `5A6DFT` (sire) x = -60,
      `8DKELJ` (dam) x = 60, their union (`__union_1`, sole child `8LKBV9`) x = **120** -- entirely
      outside the `[-60, 60]` parent span, past the dam, because `8LKBV9`'s own x is pulled right
      by his own 2 further-generation matings (verified live via `makePedigreeMatingLayout()`,
      exact coordinates reproduced from the live layout function, not estimated). Built the
      identical 6-subject pedigree in `kinship2::pedigree()`/`plot.pedigree()` as a direct
      side-by-side reference: kinship2 draws the descent line from the exact midpoint between
      `5A6DFT` and `8DKELJ`, never displaced outside their span, confirming this is a real
      divergence from kinship2 parity, not a stylistic difference this project has already
      accepted. Not investigated further this session (no candidate fix evaluated) -- likely needs
      its own design session, since a fix must decide how to reconcile "center on children" (Track
      6's own stated goal, still valid for multi-child unions) with "never leave the parents' own
      span" (kinship2's invariant) without reopening Track 6's already-ratified formula wholesale.
- [x] (found S574, 2026-08-14, incidental to Track 2's default-flip documentation pass,
      **RESOLVED S582**. **`shiny_app_use/pb_diagram_legend.png` (used in both
      `vignettes/articles/colony-manager-guide.qmd` and `vignettes/articles/pedigree-diagram.qmd`)
      visibly showed the "Direct" radio button pre-selected** -- accurate when captured, but Track 2
      (S574) flipped the Diagram tab's own zero-interaction default to "Rectilinear", so the
      screenshot's own radio-button state (and its diagonal-line routing) no longer matched what a
      fresh session actually rendered (mirrors the S461/S544 stale-screenshot pattern already
      resolved once for this same image, S560). **Fixed (S582):** recaptured via the live app
      (`shinytest2`/chromote), same fixture/focal-animal set the canonical
      `vignettes/articles/pedigree-diagram-screenshots.R` script's own "Base fixture" step uses
      (`obfuscated_rhesus_mhc_ped.csv`, focal ids `8LKBV9`/`FJIB3R`/`GA204Z`, selector
      `#pedigree-moduleContainer`) -- deliberately no `pedigreeEdgeStyle` interaction, so the shot
      captures whatever the app's own zero-interaction default renders (confirmed live via
      `R/modPedigree.R`'s `.currentEdgeStyle()`, which now returns `"rectilinear"` when
      `input$pedigreeEdgeStyle` is `NULL`). New screenshot confirmed showing "Rectilinear
      (kinship2-style)" pre-selected with right-angle edge routing, diffed visually against the
      prior committed image (extracted via `git show 2b3e8ef6:...`) to confirm only the intended
      radio-button/routing state changed. Build-equivalent verification: `pkgdown::build_article()`
      for both `articles/pedigree-diagram` and `articles/colony-manager-guide` rendered clean via
      `quarto render`, and the built HTML's embedded image was MD5-confirmed identical to the new
      source PNG (not a stale cached copy); render litter (`pkgdown_site/`, `pkgdown/`) removed
      before commit. Neither article's surrounding prose needed a text change -- both already said
      "under the default Rectilinear edge style" (already updated by Track 2's own S574 pass), so
      only the image itself was stale. One incidental finding, not fixed (out of this item's scope,
      matching `PROJECT_LEARNINGS.md` Learning 382's "report, don't fix mid-session" precedent):
      `vignettes/articles/pedigree-diagram-screenshots.R`'s other 3 non-base-fixture screenshots
      (`diagram_show_names.png`, `diagram_affected_shading.png`, `diagram_twin_connectors.png`)
      also never set `pedigreeEdgeStyle` before capture, so they may have gone stale by the exact
      same default-flip mechanism -- not verified either way this session, a future session should
      check.
- [ ] (found S582, 2026-08-14, incidental to the `pb_diagram_legend.png` reshoot above, READY,
      Effort S -- not verified) **`vignettes/articles/pedigree-diagram-screenshots.R`'s other 3
      non-base-fixture screenshots may have gone stale by the same default-flip mechanism as
      `pb_diagram_legend.png` above.** `diagram_show_names.png`, `diagram_affected_shading.png`,
      and `diagram_twin_connectors.png` are each captured without ever setting
      `pedigreeEdgeStyle` (see the script's own "3.", "4.", "5." sections) -- like
      `pb_diagram_legend.png` before this session's fix, each therefore renders whatever the app's
      zero-interaction default is, which Track 2 (S574) changed from "direct" to "rectilinear". If
      any of these 3 committed images still show diagonal (`direct`-style) edge routing, they are
      stale in the same way `pb_diagram_legend.png` was. Not checked this session (out of the
      pb_diagram_legend.png item's own scope) -- a future session should open each and confirm,
      reshooting via the same script/technique if stale.
- [ ] (found S508, 2026-08-10, re-surfaced S559, 2026-08-13, **RESOLVED S561**.
      **`HANDOFFS.md`'s declared `methodology_trim.py` regenerated field ("retained
      receipt count") had no matching "This file currently holds **N**" sentence in the
      file's own front matter**, so the tool's own `apply_regenerated()` printed a soft
      `FRONTMATTER_FIELD_ABSENT` finding on every real archive `--write` (not, it turns
      out, on every `--check` too -- corrected finding below). Owner picked the "add the
      sentence" remedy via `AskUserQuestion`, over removing the `regenerated` config
      entry. Added "This file currently holds **3** receipt(s)." to `HANDOFFS.md`'s front
      matter, immediately after the last "Archived N record(s)..." pointer block,
      matching `SESSION_NOTES.md`'s/`CHANGELOG.md`'s own bold-number pointer convention.
      Verified two ways since the live archive trigger doesn't fire this session (20-record
      headroom, well under the byte budget): (1) a direct unit-check importing
      `methodology_trim`'s own `LEDGERS["HANDOFFS.md"].regenerated[0]` regex against the
      new sentence confirms it matches and extracts the correct old value; (2) a dry-run
      `--cut @<sha>` (no `--write`) confirms the live file's own record parser counts
      exactly 3 records, matching the sentence. **Correction to the original finding's own
      framing:** re-reading `methodology_trim.py`'s control flow shows `--check` returns
      immediately after reporting the trigger status and never reaches
      `apply_regenerated()` at all -- only a real `--write` that actually builds an
      archive plan (trigger fires, or an explicit `--cut`) does. The "every check/write
      run" framing in the original S508 finding was inaccurate (or true only of an older
      tool version); the field was absent only on the 3 real archive `--write` passes to
      date, not on ordinary `--check` calls. See `CHANGELOG.md`.)
- [ ] (found S555, incidental to the consanguineous-marker PRE-RED
      investigation above, **FIXED S556**. **A dangling (no-own-row)
      parent anywhere in a pedigree silently widened
      `.positionMatingUnitForest()`'s `genOf` from integer to double,
      which could spuriously trigger `.addRectilinearWaypoints()`'s D2
      "dogleg" reroute on OTHER, unrelated, correctly-matched mate-line
      edges elsewhere in the same diagram.** Root cause: the dangling-
      parent gen fallback used `vapply(danglingIds, ..., numeric(1L))` --
      forcing a double even though the value it returns
      (`matingUnits$gen`) was already integer -- and `genOf <- c(genOf,
      ...)` then silently widened the WHOLE `genOf` vector via R's own
      type-promotion rule, corrupting `.addRectilinearWaypoints()`'s
      strict, type-sensitive `identical(side$gen, Ugen)` comparison.
      Fixed: `numeric(1L)` -> `integer(1L)` (matches the value's actual
      source type). Empirically confirmed on a 5-row reproduction fixture
      (an unrelated, already-on-row union spuriously doglegged purely
      because a second, unrelated union referenced a dangling parent --
      0 spurious nodes after the fix). Scope was `edgeStyle =
      "rectilinear"`-only; the bundled 375-individual real fixture has no
      dangling parents and was never affected. 4 new/updated unit tests
      (3 `expect_type(pos$gen, "integer")` assertions added to existing
      `test_positionMatingUnitForest.R` dangling-parent tests -- existing
      `expect_equal()`-based assertions are type-blind to this class of
      bug, `PROJECT_LEARNINGS.md` Learning 562 -- plus 1 new end-to-end
      regression test in `test_addRectilinearWaypoints.R`). `devtools::
      check()` 0 errors/1 pre-existing warning/1 pre-existing note (both
      unrelated); full clean regression 0 failed/0 error; live E2E
      (`test-e2e-pedigree-module.R`) 15/15, 0 regressions;
      `lintr::lint_package()` 0 lints. Not filed as a GitHub issue.)
- [ ] (found S552, **RESOLVED S558**. **Repository branch cleanup, all 12 stale branches
      now deleted.** S557 deleted 7 confirmed-safe branches (0 commits ahead of `master`,
      prior PR merged) via mechanical mergedness/PR-history checks. The remaining 5 --
      `module`, `issue8`, `issue8-fix`, `marks-broken-issue8`, `nprcmanager-master` -- each
      had real unmerged commits and no PR history, so mergedness alone couldn't establish
      "safe." S558 read each branch's actual diff content (commit history, diffstats,
      merge-bases, and targeted function/file cross-checks against `master`) rather than
      relying on mergedness status: `module`'s merge-base with `master` sits exactly where
      master's own modularization work began (`3773e63b`, 2025-12-30) -- master went on to
      independently complete that same effort more thoroughly (incl. a `feat!: Phase 9`
      commit deleting the legacy `inst/application` app that `module` never got); of
      `module`'s 120 files absent from `master`, none were a substantial unique capability
      (mostly the legacy app, superseded sample data, and small 21-110-line scratch
      helpers/test modules with modern equivalents already on `master`, e.g.
      `nprcgenekeeper.R` -> `R/nprcgenekeepr-package.R`). `issue8`/`issue8-fix`/
      `marks-broken-issue8` all shared the same ancient 2021-04-21 merge-base;
      `issue8-fix`/`marks-broken-issue8` were near-duplicates of each other (8 files
      differ); every named function traceable from their commits
      (`createSimKinships`/`cumulateSimKinships`/`getPotentialParents`/
      `summarizeKinshipValues`/`countKinshipValues`/`kinshipMatrixToKValues`/
      `combinerKinshipTriangles`) already exists on `master` today, complete with `man/`
      docs and `tests/testthat/` coverage. `nprcmanager-master` shared **no merge-base at
      all** with `master` (a disjoint root) -- the project's literal first 8 commits under
      its original "nprcmanager" name (2017). Findings presented to the owner via
      `AskUserQuestion`; all 5 approved for deletion. Deleted: `module` (local+remote),
      `issue8`/`issue8-fix`/`marks-broken-issue8`/`nprcmanager-master` (remote only).
      `git branch -a` now shows only `master` and `gh-pages` (the live `pkgdown.yaml`
      deploy target, confirmed live and excluded from cleanup by S557). See
      `CHANGELOG.md`.)
- [ ] (found S545, **verified S549** -- see
      `docs/audits/KINSHIP2_SUPPLEMENT_REPRODUCIBILITY_AUDIT_2026-08-13.md`. **Verify the
      results in `inst/extdata/reference/NIHMS593658-supplement-supplement_1.pdf` (kinship2's
      supplementary material) can be reproduced with `nprcgenekeepr`'s own exported
      functions.** Scope caveat found first: the full 17-subject `fam1` pedigree cannot be
      exactly reconstructed from this repo's materials (its Figure 1 lives in the kinship2
      *main* paper, not this supplement, not among the repo's other reference PDFs, and not
      shipped in any installed `kinship2` dataset) -- audited the fully-specified 10-subject
      Figure S1 subset instead, reconstructed from Table S1's own kinship values (verified,
      not guessed from the figure). Result: `kinship()`'s autosomal matrix reproduces Table S1
      **exactly** except cells touching the pedigree's one MZ-twin pair (a real, if
      narrow-trigger, capability gap -- see the 2 new items below); pedigree-diagram structure
      (nodes/edges/generations/twin-connector) is correct via `makePedigreeDiagramData()`/
      `makePedigreeMatingLayout()`; kinship2's `pedigree.shrink()` (bit-size-driven,
      availability/affected-status trimming) has no `nprcgenekeepr` equivalent, judged a
      capability-fit non-issue (different problem domain, not this package's mission); no
      X-chromosome-specific kinship computation exists (also judged out of current scope). See
      the audit doc for the full evidence, including a `kinship2`-reproduced side-by-side
      confirming the MZ-twin gap's mechanism precisely. **Note, RESOLVED S567:** the PDF's
      copyright/licensing classification (untracked in git, absent from
      `.gitignore`/`.Rbuildignore` unlike its copyrighted siblings in the same directory) was
      unresolved since S545. Owner decision (via `AskUserQuestion`, 2026-08-14): gitignore it,
      matching the S479/S497 precedent -- it is an NIHMS/PMC deposit (free reading access under
      NIH's public-access policy) but that is not confirmed to carry third-party redistribution
      rights, so it is excluded from this PUBLIC repo out of the same caution as the other 3
      files, not because it fails their "no open-access marking" test. `.gitignore`/
      `.Rbuildignore` both updated; verified by an actual `R CMD build` that the file is now
      excluded from the built tarball (the file remains on local disk, still usable by
      `data-raw/kinship2FidelityValidation.R`). See `CHANGELOG.md`.)
- [ ] **Thread `twinRelations` into `kinship()`'s computation, not just diagram rendering**
      (found S549, Finding #1 of the above audit; design RATIFIED S550; **all 3 slices DONE
      S551-S553, RESOLVED**, see `docs/planning/twin-relations-kinship-computation-plan.md`)
      -- `nprcgenekeepr` already had a twin-declaration data
      model (`checkTwinRelations()`, issue #137) but it feeds only the Diagram tab; every
      kinship-driven calculation silently treats a declared monozygotic-twin pair as ordinary
      full siblings, understating their kinship and understating every relative reached
      through either twin (transitively, not just the direct pair -- kinship2's own behavior).
      Ratified design: extend `kinship()`'s own signature with a new `twinRelations = NULL`
      parameter (porting kinship2's `mzgrp`/`mzindex` in-loop-correction mechanism directly --
      a post-hoc single-pass patch on the finished matrix was proven mathematically
      insufficient, since it cannot correctly propagate to a twin's descendants); `kinship()`
      trusts a pre-validated `twinRelations` (documented precondition) rather than
      re-validating internally, since its flat-vector signature has no `sex` parameter to run
      `checkTwinRelations()`'s full rule set itself. **Slice 1 (core algorithm) DONE S551**:
      `kinship()` gained the `twinRelations` parameter, verified against `kinship2`'s own
      ground truth on the audit's 10-subject fixture (`kinship(8,9)=0.5`,
      `kinship(9,10)=0.28125`, exact matches) plus a 3-member transitive-group fixture and a
      DZ/UZ-coded zero-treatment fixture; `devtools::check()` 0 errors/0 warnings; full clean
      regression read 0 failed/0 error. `R/applyKinshipOverrides.R`'s "never modified" roxygen
      sentence updated per Dragon 2. **Slice 2 (the 4 script-callable functions) DONE S552**:
      `reportGV()`, `gvaConvergence()`, `createSimKinships()`, `cumulateSimKinships()` each
      gained their own `twinRelations = NULL` parameter passed straight through to their
      internal `kinship()` call; `test_gvaConvergence.R` was confirmed to already exist
      (Dragon 4 resolved, no new file needed). Verified: `reportGV()`'s returned `$kinship`
      matches Slice 1's own ground truth exactly with twins declared; `gvaConvergence()`
      accepts the parameter and threads it without error (its own convergence-curve output has
      no kinship-observable surface at this fixture's scale -- the same documented limitation
      `test_gvaConvergence_kinshipOverrides.R` already establishes for the analogous
      `kinshipOverrides` parameter); `createSimKinships()`/`cumulateSimKinships()` both
      directly reproduce the twin-corrected values in every simulated/mean matrix.
      `devtools::check()` 0 errors/0 warnings/1 pre-existing unrelated NOTE; full clean
      regression read 0 failed/0 error; `lintr::lint_package()` 0 lints on all 8 touched files.
      One combined `NEWS.Rmd` entry added covering Slices 1-2 together (the plan's own §8
      item 3 open question, resolved this session). **Slice 3 (full Shiny wiring) DONE S553,
      closing this item:** `modPedigreeServer()`'s return list gained a `twinRelations`
      reactive (the raw, ungated `twinRelationsData()`, unaffected by the "Show Twin
      Connectors" toggle); `R/appServer.R` gained `shared$twinRelations`, wired into
      `sharedKinshipMatrix`'s own `kinship()` call and threaded through to
      `modGeneticValueServer`/`modBreedingGroupsServer`/`modSummaryStatsServer` (each gained
      a matching `twinRelations` parameter on their own fallback `kinship()` recompute path).
      Dragon 1 (the tab-order UX question) resolved via Pre-RED `AskUserQuestion`: a single
      upload point (Diagram tab only) -- Shiny's reactive graph runs every module from
      session start, not gated by tab visibility, so "regardless of tab visit order" is
      satisfied mechanically without a second, duplicate upload control; decision recorded in
      the plan document's own §6 Dragon 1. Verified live end-to-end (Phase 3E, new
      `test-e2e-twin-relations-cross-tab.R`): a `twinRelations` file uploaded on the Diagram
      tab is reflected in the Summary Statistics kinship export for the declared MZ pair
      without ever visiting Genetic Value Analysis; the pre-existing
      `test-e2e-pedigree-module.R` twin-connector suite (13 tests/45 assertions) re-confirmed
      unaffected. `devtools::check()` 0 errors/0 warnings/1 pre-existing unrelated NOTE; full
      clean regression 0 failed/0 error (2,155 test blocks); `lintr::lint_package()` 0 lints on
      all touched files. Fixed 3 pre-existing test-double staleness gaps the full regression
      (not the targeted run) surfaced in untouched files:
      `test_appServer_logging.R`'s own local `modPedigreeServer` stub, `test_modGeneticValue.R`'s
      2 `local_mocked_bindings(reportGV = ...)` signatures, and `test_moduleContract.R`'s
      `modPedigreeServer` return-name whitelist -- see `PROJECT_LEARNINGS.md` Learning 559.
      `NEWS.Rmd` entry extended (one combined Slices 1-3 entry); tutorial/article checklist
      applied (`vignettes/manual_components/_pedigree_browser.Rmd` gained a paragraph on the
      app-wide kinship correction). Not yet filed as a GitHub issue.
- [ ] (found S549, Finding #2 of the above audit, **FIXED S555 for `edgeStyle = "direct"`**.
      **Add a visual marker for consanguineous matings in the Pedigree Diagram tab** --
      kinship2 draws a doubled/thickened mate-line for a blood-related couple;
      `makePedigreeMatingLayout()` rendered every mating unit identically regardless of
      `kinship(sire, dam)`. Distinct from issue #134 (verified layout *doesn't break* for
      consanguineous loops, closed S453 -- a robustness check, not a visual-signaling one)
      and from the "Candidate C" cross-generation dogleg item below (a geometry-signposting
      problem, not a blood-relation one). Fixed: a mating unit whose sire/dam pair has
      `kinship(sire, dam) > 0` (computed via the function's own already-validated
      `twinRelations` parameter too, for correctness parity with the twinRelations-into-
      `kinship()` work above) now renders its 2 spouse-to-union edges with a distinct color/
      width (`"#D55E00"` Okabe-Ito vermillion, width 4) -- always on, no new UI toggle, since
      sire/dam are required columns (a structural fact of the pedigree), unlike the optional
      name/twinRelations sidecars. `edges` gains `color`/`width` columns unconditionally once
      any mating unit exists. 6 new/updated unit tests (`test_makePedigreeMatingLayout.R`);
      new live E2E test confirms 56 marked edges (28 genuinely consanguineous unions x 2) at
      width 4 on the bundled 375-individual fixture. `devtools::check()` 0 errors/0 warnings/
      1 pre-existing NOTE; full clean regression 0 failed/0 error; `lintr::lint_package()` 0
      lints. Not filed as a GitHub issue.
      **Deferred follow-up (owner-directed hold, S555):** `edgeStyle = "rectilinear"`
      propagation -- a marked mate edge whose parent sits at a different gen than its own
      mating unit (the D2 "dogleg" reroute; empirically confirmed live to require an anchor
      who anchors 2+ differently-gen'd units, a real but narrow-trigger scenario, e.g.
      cross-generation consanguineous matings) currently falls back to the generic routing-
      blue color/default width on its 2 replacement projection edges instead of inheriting
      the marker. `.addRectilinearWaypoints()` already defensively guards `width`/`color`
      column presence (no crash), but does not yet propagate a dropped mate edge's own
      color/width onto its replacement edges. A future session should extend the D2 dogleg
      loop in `R/makePedigreeDiagramData.R` (`.addRectilinearWaypoints()`) to look up the
      original edge's color/width before dropping it and stamp both onto its 2 new
      projection edges, falling back to the generic blue/default only when absent -- mirrors
      the color-preservation precedent already established there for KEPT edges (issue #137
      D10). A verified 12-row fixture forcing this exact scenario (an anchor double-anchoring
      2 different-gen units, one of them consanguineous) was constructed empirically this
      session and is a ready-made starting point (see S555's own `PROJECT_LEARNINGS.md`
      entry for the fixture and the reasoning that got there).
      **FIXED S563** (Track C of the kinship2 supplement full-reproduction plan below,
      `docs/planning/kinship2-supplement-full-reproduction-plan.md` §5): S555's own
      12-row fixture code was never committed, so a fresh, independently-verified 9-row
      equivalent (a consanguineous full-sib mating forced to dogleg by its anchor also
      anchoring an unrelated, higher-gen union) was constructed and confirmed live this
      session. `.addRectilinearWaypoints()`'s D2 loop now looks up a dropped mate edge's
      own color/width (keyed by the dogleg's `projId`) and stamps both onto its 2
      replacement projection edges via a post-hoc override after the existing generic
      fallback assignment, applied only when a marker was present -- mirrors the
      KEPT-edges precedent exactly, no other edges affected. 1 new `test_that()` block
      (`tests/testthat/test_makePedigreeMatingLayout.R`, 5 assertions) confirmed RED
      against unmodified source, then GREEN. `devtools::check()` 0 errors / 1 warning +
      1 note (both confirmed pre-existing/unrelated: the untracked "Compounding Loop"
      clutter files' non-portable names, and a pre-existing `vignettes/figure/` knitr
      leftover); full clean regression 1 pre-existing failure unrelated to this change
      (`test_wordlist_coverage.R`, confirmed via `git stash`); `lintr::lint_package()` 0
      lints on touched files. Not filed as a GitHub issue.
- [ ] **Fully reproduce kinship2 supplementary-material PDF's results** (owner-directed
      follow-up to the S549 audit above -- "duplicate the work done in that PDF,"
      overriding that audit's own "no action" verdict on 2 of its 4 findings; plan
      RATIFIED S562, READY, Effort L overall) -- plan complete:
      `docs/planning/kinship2-supplement-full-reproduction-plan.md`. 3 independently
      session-sliceable tracks, no shared code: **Track A** (X-chromosome kinship,
      Table S2 -- `kinship()` gains `chrtype`/`sex` params, ratified scope is the core
      algorithm only, Effort M) -- **DONE S564**, see below; **Track B** (a
      `pedigree.shrink()` equivalent -- new `shrinkPedigree()` function, script-callable
      only, deterministic tie-break [diverges from kinship2's own `runif()`
      non-determinism by design, ratified], the most novel of the 3, Effort L -- 2 of
      kinship2's own internal helpers [`excludeUnavailFounders`/`excludeStrayMarryin`]
      were not yet deparsed by the plan, left as an explicit Pre-RED item) -- **DONE
      S565**, see below; **Track C**
      (finish the `edgeStyle="rectilinear"` consanguineous-marker color/width
      propagation from the deferred item directly above -- smallest of the 3, Effort S,
      no open design question) -- **DONE S563**, see the deferred-follow-up item above
      and `CHANGELOG.md`. Plan's own §6.2 suggests C -> A -> B pickup order
      (smallest/lowest-risk first) but does not force it. **All 3 tracks are now
      DONE** (C: S563, A: S564, B: S565). Verification caveat carried from the S549
      audit: the full 17-subject `fam1` pedigree still isn't reconstructible from
      this repo, and Track B additionally had no PDF-printed worked example to check
      against at all (the PDF only names *which* subjects a shrink would trim, never
      their relationships) -- Track B verified against the installed
      `kinship2::pedigree.shrink()` directly instead. **RESOLVED S566:** filed and
      closed 3 GitHub issues (#156 Track A, #157 Track B, #158 Track C), each citing
      its implementing commit and verification evidence; published a new numeric+
      graphic fidelity validation article,
      [`vignettes/articles/kinship2-fidelity-validation.qmd`](../vignettes/articles/kinship2-fidelity-validation.qmd)
      (matching the `fg-se-validation.qmd` precedent), running the SAME fixture from
      each track's own committed test file through both packages, live, side by
      side: Track A's autosomal and X-linked kinship matrices are bit-for-bit
      identical to kinship2's own output (max abs diff = 0 across 200 compared
      cells); Track B's `shrinkPedigree()` reproduces kinship2's exact surviving
      subject set and exact `bitSize` trajectory on a 16-subject fixture, shown as
      before/after pedigree diagrams from both packages; Track C's consanguineous
      marker flags the same union kinship2 flags under both edge styles. Generated
      by `data-raw/kinship2FidelityValidation.R` (kinship2 installed locally,
      offline, matching the established "no new Suggests dependency" precedent) --
      see that script's own header for the reproduction command. See `CHANGELOG.md`.
- [ ] (**Track A above, DONE S564.** `kinship()` gained `chrtype = c("autosome", "x")`
      and `sex` arguments -- X-chromosome kinship (kinship2 supplement Table S2), core
      algorithm only per ratified D-A2 Option A (no propagation to
      `reportGV()`/`gvaConvergence()`/`createSimKinships()`/`cumulateSimKinships()` or
      the Shiny app). `chrtype = "autosome"` (the default) is byte-identical to every
      prior call site -- pinned by an `expect_identical()` regression test. Full 10x10
      Table S2 transcribed directly from
      `inst/extdata/reference/NIHMS593658-supplement-supplement_1.pdf` via
      `pdftotext -layout` (not read visually) and cross-validated by hand-porting
      kinship2's own deparsed X-linked algorithm, run live against the installed
      `kinship2` 1.9.6.2. PRE-RED finding beyond the plan's own framing: Table S2's
      printed values already embed the MZ-twin correction (Figure S1 declares subjects
      8/9 identical twins), so one fixture (the existing `fam1`/`twins` pair already in
      `tests/testthat/test_kinship.R`, extended with a `sex` column) satisfies both
      "reproduce Table S2" and the plan's separately-listed "combined X-linked +
      MZ-twin" coverage requirement. 6 new `test_that()` blocks (Table S2 reproduction;
      twin-correction isolation; backward-compat `expect_identical()` pin; `sex`
      validation; invalid-`chrtype` validation; unknown-sex NA propagation), all
      confirmed failing for the right reason against unmodified source before GREEN.
      `devtools::check()` 0 errors, 1 warning + 1 note, both confirmed pre-existing/
      unrelated via `git stash` (the untracked "Compounding Loop" files' non-portable
      names; a pre-existing `vignettes/figure/` knitr leftover) -- matching Track C's
      own S563 findings exactly. Full clean regression 1 pre-existing failure
      (`test_wordlist_coverage.R`), confirmed via `git stash` unrelated (`matings`/
      `runnable`, from `.qmd` articles, untouched by this diff); this session's own
      2 new spelling flags (`Schaid`/`Sinnwell`, from a new roxygen `@references`
      citation) were fixed via `inst/WORDLIST` additions, not left as new debt.
      `lintr::lint_package()` 0 new lints (2 introduced by new camelCase variable names
      `sexNum`/`founderDiag` suppressed via `# nolint: object_name_linter`, matching
      the file's own established convention and the 5 pre-existing lints already in
      this file, confirmed via `git stash`, left untouched). Not filed as a GitHub
      issue, matching Track C's own precedent. See `CHANGELOG.md`.)
- [ ] (**Track B above, DONE S565.** New `R/shrinkPedigree.R`:
      `shrinkPedigree(ped, genotyped, affected = NULL, maxBits = 16L)`, a
      `kinship2::pedigree.shrink()` equivalent over this package's own
      `id`/`sire`/`dam` data-frame pedigree representation. All 8 of kinship2's own
      internal helpers (`pedigree.shrink`, `bitSize`, `findUnavailable`,
      `excludeUnavailFounders`, `excludeStrayMarryin`, `findAvailNonInform`,
      `findAvailAffected`, `pedigree.trim`) were deparsed directly from the installed
      namespace (1.9.6.2) at Pre-RED -- including the 2 the plan itself flagged as
      not yet deparsed. 4 findings beyond the plan's own framing, all documented in
      the function's own roxygen: (1) `excludeStrayMarryin` ignores `genotyped`
      entirely -- any childless founder is removed unconditionally; (2)
      `excludeUnavailFounders`'s real criterion requires the founder couple have
      exactly one child together *and* neither parent married to anyone else,
      confirmed by a live negative-case test; (3) kinship2's own
      `all(x == 0, na.rm = TRUE)` non-informative-affected check treats `NA` the
      same as unaffected; (4) a real, empirically-confirmed divergence -- kinship2's
      own `pedigree()` constructor forbids a single-known-parent individual
      ("Subjects must have both a father and mother, or have neither"), so its
      algorithm never has to define that case, but this package's pedigrees allow
      partial parentage as ordinary data (`getIdsWithOneParent()`); a literal port
      would divide a zero-length vector and error, so `shrinkPedigree()` never marks
      such an individual non-informative instead (documented, tested, no crash). A
      5th finding: kinship2's own `idTrimmed`/`idList$affect` record only the single
      trial candidate per affected-priority round even when its removal cascades
      further (confirmed live: a fixture exists where kinship2's own `pedSizeFinal`
      drops by 2 in one round but `idTrimmed` names only 1) -- `shrinkPedigree()`
      deliberately fixes this, recording every id actually removed each round, so
      `pedSizeOriginal - pedSizeFinal` always equals `length(idTrimmed)` (does not
      change which individuals survive, only audit-trail completeness). Deterministic
      lowest-id (string-sorted) tie-break (D-B2) confirmed against a fixture proven
      live to be a genuine ~50/50 tie in kinship2's own `runif()`-based reference.
      14 `test_that()` blocks (20 expectation markers incl. a 5-iteration
      determinism-repeat loop) in new `tests/testthat/test_shrinkPedigree.R`, every
      hardcoded expected value (id sets, `bitSize` trajectories, `idList` groupings)
      independently verified live against the installed `kinship2` 1.9.6.2 this
      session (not hand-derived), confirmed failing for the right reason against
      unmodified source before GREEN -- including one test added mid-GREEN after the
      idTrimmed-completeness finding above surfaced. `devtools::check()` 0 errors, 1
      warning + 1 note, both confirmed pre-existing/unrelated via `git stash`
      (matching Track A/C's own findings exactly). Full clean regression 1
      pre-existing failure (`test_wordlist_coverage.R`, `matings`/`runnable` from
      `.qmd` articles, confirmed via `git stash`); this session's own new spelling
      flag (`orchestrator`, from roxygen prose) fixed via `inst/WORDLIST`, not left
      as new debt. `lintr::lint_package()` 0 lints (no suppressions needed -- an
      earlier speculative round of `# nolint: object_name_linter` comments was found
      unnecessary, since this project's `.lintr` already allows camelCase, and was
      removed). `_pkgdown.yml` reference-coverage checklist: added to both the
      "Primary interactive functions" curated group and the "All exposed functions"
      catch-all (a real gap `test_pkgdown_reference_config.R` caught). **All 3 tracks
      of the kinship2 supplement full-reproduction plan are now DONE** (C: S563, A:
      S564, B: S565). None filed as a GitHub issue, matching the established
      "recommend, don't unilaterally file" precedent -- the owner may wish to file
      one (or three) before further related work. See `CHANGELOG.md`.)
- [ ] (found S552, owner-reported live, **FIXED S554**. **Pedigree Diagram tab's
      affected-status shading fills unaffected individuals too, counter to standard
      pedigree drawing convention** -- issue #133's `.affectedColor()`
      (`R/makePedigreeDiagramData.R`) set `color.background` to `"#CC79A7"` when
      `affected == TRUE` and left it `NA_character_` otherwise; in visNetwork an `NA`
      `color.background` does not render as an *open/unfilled* node -- it falls back to
      the library's own default fill, so unaffected/unknown-affected individuals still
      rendered solid-filled. Fixed: `FALSE`/`NA` now get an explicit `"#FFFFFF"`
      (open/unfilled), matching kinship2's own "unfilled if 0/NA" convention (verified
      against the issue #133 plan document's own kinship2-source research). 6 existing
      unit-test assertions updated (`test_makePedigreeDiagramData.R`,
      `test_makePedigreeMatingLayout.R`); new live E2E test confirms the actual rendered
      color for a known TRUE/FALSE/NA triple via the bundled
      `obfuscated_rhesus_mhc_ped_affected.csv` fixture. `devtools::check()` 0 errors/0
      warnings/1 pre-existing NOTE; full clean regression 0 failed/0 error (2,156 test
      blocks); `lintr::lint_package()` 0 lints. Not filed as a GitHub issue.)
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
- [ ] (found S461, **RESOLVED S560**. **Stale `pb_diagram_legend.png` screenshot and its
      surrounding pre-Option-2 prose in `colony-manager-guide.qmd`.** Regenerated the
      screenshot against a small, legible, real 6-animal subgraph (the Option 2
      mating-unit/duplicate-node convention, incl. a consanguineous marker); rewrote the
      paragraph's opening sentence to describe the mating-unit convention and the
      `edgeStyle` toggle, and added a twin-connectors mention. See `CHANGELOG.md`.)
- [ ] (owner-directed, found S544, **RESOLVED S560**. **New dedicated article,
      `vignettes/articles/pedigree-diagram.qmd`, covering the Pedigree Diagram tab's full
      current feature set** (node shapes/legend, `edgeStyle` direct vs. rectilinear,
      consanguineous marker, affected-status shading, name labels, twin/zygosity
      relations and their app-wide kinship correction, hover/click/search/PNG-export
      interaction, and the script-callable `makePedigreeMatingLayout()`/
      `visNetwork::visNetwork()` equivalent) -- matches the established per-tab-article
      convention (`age-sex-pyramid.qmd`, `genetic-value-analysis.qmd`,
      `breeding-group-formation.qmd`), with 5 freshly-captured live-app screenshots via a
      new `shinytest2::AppDriver` script (`pedigree-diagram-screenshots.R`). Cross-linked
      from `colony-manager-guide.qmd`'s function-group table and `a2interactive.Rmd`'s own
      "Pedigree Diagram" section. Subsumes the stale-screenshot item above. See
      `CHANGELOG.md`.)
- [ ] **iCloud "conflicted copy" duplicate `.R` files corrupt
      `devtools::document()`/`R CMD check` output** (found S461, Effort S,
      not a code defect) -- `R/appServer 2.R` and `R/modMarkerGenetics 2.R`
      (carried forward many sessions as passive noise) are SOURCED by
      `pkgload::load_all()`/`devtools::document()` like any other `.R` file,
      silently merging their own stale roxygen comments into the SAME
      generated `.Rd` page as the current source -- confirmed twice this
      session (`man/appServer.Rd`, `man/modMarkerGeneticsServer.Rd`,
      `man/modMarkerGeneticsUI.Rd`, each reverted via `git checkout --`
      immediately). See `PROJECT_LEARNINGS.md` Learning 454. The owner is
      relocating this repository outside iCloud's purview specifically
      because of this and other iCloud-latency issues (same session,
      out-of-band) -- once moved, this item should self-resolve; a future
      session should confirm the 2 duplicate files no longer reappear and,
      if so, close this item without further action.
      **Recurred again S462 (2026-08-03):** the owner rebuilt the package
      locally (outside this session's own tool calls) while reviewing a
      screenshot, which re-corrupted the same 3 `.Rd` files the same way;
      reverted again via `git checkout --`. As of this session's Orient, the
      planned repository relocation had NOT yet happened (`pwd` still
      resolves to the original iCloud-synced path) -- this item cannot be
      closed until the move actually completes.
- [ ] **`devtools::check()`'s spelling NOTE has drifted again -- 6 new words,
      not caught by any session since S461** (found S465, Effort S,
      incidental -- confirmed pre-existing, not caused by this session's own
      diff via a stash test) -- `man/makePedigreeMatingLayout.Rd:40`
      ("sibship", "waypoint") and `vignettes/a2interactive.Rmd:355,371,429,
      437,440,441` ("duplicateToReal", "js's", "makePedigreeMatingLayout",
      "vis") are flagged in `devtools::check()`'s `spelling.R` test diff
      (comparing fresh `spelling.Rout` against the committed
      `spelling.Rout.save`) but are not yet in `inst/WORDLIST`. Mirrors the
      S443/S448/S452 spelling-gap pattern (Learning 426, `CLAUDE.md`'s own
      "Additional close-out checks" precedent) -- a future session should
      hand-add these 6 words to `inst/WORDLIST` in `LC_ALL=C` byte-order
      position (not via `spelling::update_wordlist()`, per S230 convention)
      and re-verify `devtools::check()` drops to the pre-existing iCloud
      duplicate-file warning + vignette-engine note only.
      **Count grown to 9 words as of S490 (2026-08-09), still not fixed** --
      incidental to issue #136 Slice 2's own `devtools::check()` verification
      pass. The original 6 (`sibship`/`waypoint`/`duplicateToReal`/`js's`/
      `makePedigreeMatingLayout`/`vis`) are joined by 3 more: `discoverable`
      (`NEWS.md:140`), a bare `js` (`a2interactive.Rmd:533`, distinct token
      from `js's`), and `unshaded` (`_pedigree_browser.Rmd:55`) -- all 3
      confirmed via `git blame`/`git log -S` to trace to commit `100741ae`
      (S487, 2026-08-08, issue #133 Slice 2's own NEWS/tutorial/article
      commit), not this session's diff. A future session fixing this item
      should hand-add all 9 words, not just the original 6.
- [ ] **The "10 pre-existing baseline warnings" carried in every full-regression
      report since S448 have never been root-caused, and were introduced by a
      test-fixture gap, not a real production-code issue** (found S487,
      incidental to issue #133 Slice 2's own regression read; Effort S, low
      priority) -- the owner asked directly ("we had zero at last release")
      after seeing `warning: 10` in this session's clean regression read, which
      no prior session had actually traced. Root cause: both
      `tests/testthat/test_modMarkerGenetics.R` "cross-center" tests (added by
      commit `a319e0c5`, S447, 2026-08-01, implementing issue #130 Slice 5)
      upload a hand-derived 2-locus toy fixture (Center A n=4, Center B n=6)
      chosen for exact-fraction Fst arithmetic, not for kinship completeness.
      `modMarkerGeneticsServer`'s reactive graph incidentally also computes
      marker-based kinship (the Slice 1 feature) on any uploaded Center-A file,
      and in this fixture `'CA1'`/`'CA2'` share no heterozygous locus --
      `markerKinship()` correctly warns and returns `NA` for that pair (working
      as designed, not a bug), 5x per test x 2 tests = 10. **Confirmed CRAN
      v2.0.0 (released 2026-07-26) predates S447 (2026-08-01) and genuinely
      shipped with a clean, 0-warning suite** -- the owner's recollection was
      correct. S447's own close-out reported "0 failed/0 error" but never
      actually stated a warning count; S448 (the very next session)
      independently found S447's self-reported `devtools::check()` "0/0/0"
      also didn't hold up under re-verification (a missed spelling gap) --
      the same kind of unverified self-report, in the same session, is the
      most likely origin of this gap too, though this was never directly
      confirmed against S447's own raw test output (not preserved). Every
      session from S448 through S486 (~40 sessions) carried "10 pre-existing
      ... warnings" forward as an accepted baseline without investigating what
      it was. Not fixed this session (`PROJECT_LEARNINGS.md` Learning 382's
      "report, don't fix mid-session" precedent -- out of scope for a Slice 2
      legend/documentation TDD session; owner directed file-and-continue via
      `AskUserQuestion`). A future session should either (a) wrap the
      `session$setInputs(genotypeFile = ...)` calls in these 2 tests with
      `suppressWarnings()` (matching the established `PROJECT_LEARNINGS.md`
      Learning 273(d) precedent: "a degenerate out-of-contract input ... often
      misbehaves further downstream -- suppress the incidental warning, not
      the branch"), or (b) adjust the 2-locus fixture so `CA1`/`CA2` share a
      heterozygous locus -- but only after re-verifying the exact-fraction Fst
      values (`58/1001`, `139/308`, `614/2233`) still hold, since the fixture
      was hand-derived specifically to produce those numbers.
      **Count grown from 10 to 15, found incidentally S504 (2026-08-10), still
      not fixed** -- a full clean regression read during issue #149 Slice 1
      showed `warning: 15`, confirmed via a `git stash` comparison to be
      pre-existing (identical on unmodified `HEAD`), unrelated to that
      session's own diff. The 3rd 5-warning source is
      `test_modMarkerGenetics.R`'s "candidate-parent-assignment table is
      non-empty for a real (non-mocked) recorded-but-wrong-parent fixture
      (issue #155)" block, added S502 (2026-08-10) -- a live, non-mocked
      genotype-file upload that incidentally triggers the same
      `markerKinship()` NA-warning path as the 2 original cross-center tests.
      A future session fixing this item should address all 3 test blocks, not
      just the original 2.

- [ ] **`BACKLOG.md`'s own ledger-size housekeeping -- editorial compression, not a
      `methodology_trim.py` config** (found S518, 2026-08-11, READY, Effort L) -- `BACKLOG.md`
      itself is one of the dashboard's 3-file HIGH-risk ledger-size items but does not fit
      `methodology_trim.py`'s chronological-record model: it has 10 `##` sections, each a large
      *standing topical category* that accumulates resolved-item narrative indefinitely, not dated
      newest-on-top records. The file's own header already states the right remedy: "Open,
      actionable work only... for history see `CHANGELOG.md`."
      **Housekeeping section DONE -- S529 (2026-08-12):** an inventory pass (background agent, full
      read of all 2,501 then-current lines) found 62 top-level items file-wide, 48 fully resolved,
      ~1,500 compressible lines total, concentrated in 3 oversized sections (Housekeeping,
      "Pedigree diagram vs kinship2," "Genetic-metrics PDF audit"). Scoped to Housekeeping only for
      this session (owner-picked via `AskUserQuestion`, over top-15-file-wide / single-biggest-item
      / prep-only alternatives) -- self-contained, bounded by clean section headers. All 17 of its
      19 fully-resolved items compressed to the file's own established short-pointer convention; the
      8 genuinely-open items (incl. this one) left untouched. **2 items had NO existing
      `CHANGELOG.md` entry at all** (a real ledger gap, FM #27 -- not just verbose narrative): the
      `inst/extdata/` reorg (Sessions 415-418) and the non-portable-filename fix (Session 497).
      Backfilled proper `CHANGELOG.md` entries for both before compressing, rather than compress to
      a dangling pointer that would have destroyed the only detailed record. Net: Housekeeping
      147→389 lines (263 removed); file total 2,501→2,238 (263 removed). Zero information loss
      verified by re-reading the full compressed section end-to-end before close-out.
      **"Pedigree diagram vs kinship2 audit follow-ups" section DONE -- S530 (2026-08-12):** the
      2nd of the item's 2 remaining sections. Compressed all 12 fully-resolved bulleted items (issues
      #131/#134/#135/#139, Option 2 layout feasibility/design/3 implementation slices, the
      duplicate-node-arc fix, issues #143/#144) to the file's own short-pointer convention, and
      condensed the ~375-line unbulleted S480-S500 Progress-narrative chain (Tier 1 crash-bug fixes +
      #145 spike + doc refresh; Tier 2 issues #133/#136/#137/#145, all closed) into one ~50-line
      consolidated summary retaining every session number, design-doc path, and Learning
      cross-reference. Verified `CHANGELOG.md` (+ its `docs/archive/CHANGELOG-through-*.md` shards)
      actually carries an entry for all 31 session numbers cited before compressing to a pointer --
      0 gaps found this time (unlike the Housekeeping section's 2). All Learning cross-references and
      all 11 cited `docs/planning|audits|research/*` file paths confirmed to resolve. The 4 genuinely
      -open items (Candidate C's connector idea; the 3 dangling-parent-crash-bugs and free-pass-filter
      pointers, both already short; the node-count-off-by-one gap; the docstring-mismatch gap; the
      `highlightNearest` degree=6 bound) left untouched. Net: section 896->286 lines (610 removed);
      file total 2,254->1,658 (596 removed, after this session's own S518-item progress notes added
      lines back elsewhere in the file). Zero information loss verified by re-reading the full
      compressed section end-to-end before close-out.
      **"Genetic-metrics PDF audit follow-ups" section DONE -- S531 (2026-08-12):** the 3rd and
      last of the item's 3 oversized sections. Compressed 8 fully-resolved issue chains
      (#126/#127/#129/#130's shared sequencing-decision bullet, plus the individually-tracked
      #147/#149/#146/#151/#150/#153 design->slice narrative chains) to the file's own short-pointer
      convention; also condensed the S479-S483 re-audit/sequencing context note (still relevant --
      it names the still-open items) without losing any issue number, tier assignment, or audit-doc
      pointer. Left the still-open issue #152 chain (design S517, Slice 1 S525, Slice 2 S526, Slice
      3 next) fully untouched, matching the S529/S530 "leave open items untouched" precedent. An
      early compression pass left a real duplication defect -- the #153 chain's design paragraph was
      replaced but its 3 slice-by-slice progress paragraphs (S520/S521-523/S524) were missed and
      briefly duplicated the new compressed bullet -- caught by this session's own end-to-end re-read
      before close-out and fixed by removing the now-redundant paragraphs. Verified `CHANGELOG.md`
      (+ both `docs/archive/CHANGELOG-through-*.md` shards) carries an entry for all 39 session
      numbers cited before compressing to a pointer -- 0 gaps found. All Learning cross-references
      and all 13 cited `docs/planning|audits/*` file paths confirmed to resolve. Net: section
      753->267 lines (486 removed); file total 1,658->1,173 (485 removed, some absorbed by this
      item's own progress-note growth). Zero information loss verified by re-reading the full
      compressed section end-to-end before close-out.
      **The S518 item is now fully RESOLVED -- all 3 oversized sections compressed across 3
      sessions:** Housekeeping (S529, 147->389 lines), "Pedigree diagram vs kinship2" (S530,
      896->286 lines), "Genetic-metrics PDF audit follow-ups" (S531, 753->267 lines). File total:
      2,501 lines (S529 start) -> 1,173 lines (S531 end), a 1,328-line/53% reduction across 3
      sessions, with zero information loss at any step (each session's own end-to-end re-read plus
      CHANGELOG.md/Learning/file-path cross-reference verification). See `CHANGELOG.md`.
- [ ] (found S566, 2026-08-14, incidental to adding the kinship2 fidelity validation article to
      `_pkgdown.yml`'s `articles:` `contents:` list, Effort S, not fixed this session) **`_pkgdown.yml`'s
      explicit `articles: contents:` navbar-order list (added S409) is missing
      `articles/pedigree-diagram`** -- every other article under `vignettes/articles/` (including the one
      this session added) is listed; `pedigree-diagram.qmd` (added S560) is not, despite that session's own
      close-out narrative claiming it followed "the established per-tab-article convention." Unclear whether
      pkgdown still discovers and builds the page (just missing from the pinned navbar order) or drops it
      from the site entirely -- not verified this session (out of scope, "report, don't fix mid-session"
      precedent). A future session should confirm the actual site behavior (a local `pkgdown::build_site()`
      or checking the live gh-pages deploy for the page) and, if missing from the navbar, add
      `articles/pedigree-diagram` to the `contents:` list in the same alphabetical-ish position its
      neighbors already establish.
- [ ] (found S567, 2026-08-14, incidental to a `pkgbuild::build()`/tarball-content check while
      resolving the kinship2 PDF's `.Rbuildignore` classification, **RESOLVED S568**.
      **The untracked "Compounding Loop" files were bundled into every built package tarball**,
      unlike the reference PDFs this project deliberately `.gitignore`/`.Rbuildignore`s. Investigated
      before presenting the decision: the 3 real files (`.html`/`.pdf`/`.webarchive`) turned out to be
      a saved Claude Artifact about this project's own `SESSION_RUNNER.md`/`SAFEGUARDS.md` methodology
      (`github.com/KJ5HST/methodology`) -- personal reference material, not genetics/package content,
      but also not the same as the existing 4 gitignored files (those are copyrighted scientific
      papers). The 4th file, `~$e Compounding Loop.html`, was confirmed via byte inspection to be a
      content-less Microsoft/LibreOffice editor lock file (162 B, just the owner's own name in the
      binary lock-file format), not reference material at all. Presented via `AskUserQuestion`: owner
      picked "gitignore + `.Rbuildignore` in place," matching the established precedent (over moving
      the files out of `inst/extdata/reference/` entirely, tracking+shipping them, or deleting them
      outright); the lock file was deleted unconditionally (never committed, confirmed via
      `git log -- <file>` returning empty, zero content value). Verified via an actual
      `pkgbuild::build()` + tarball-content inspection that all 3 real files are now excluded (the
      NIHMS precedent and the 1 tracked exception both re-confirmed unaffected);
      `git check-ignore -v` confirms all 3 match the new `.gitignore` rule. `devtools::check()`: 0
      errors, 0 warnings, 0 notes -- this also resolved the long-standing "checking for portable
      file names" WARNING every recent session had been carrying forward as pre-existing (these
      exact files were its cause). Incidental finding logged, not fixed: an empty
      `inst/extdata/reference/untitled folder` directory (dated the same day as the Compounding Loop
      files) surfaced during this session's own build-log inspection -- new Housekeeping item below.
      See `CHANGELOG.md`.)
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
- [ ] (feasibility planning DONE -- S457, 2026-08-02, see
      `docs/planning/pedigree-diagram-mating-lines-plan.md`. **Pedigree Diagram
      tab does not visually indicate mating/couple relationships** (owner-observed
      S456, citing kinship2-convention references) -- confirmed empirically (3
      `visNetwork` POCs via `chromote`) that a true kinship2-style mate-line +
      sibship-bar convention is achievable inside the ratified visNetwork (D2)
      choice via invisible union/waypoint nodes with hand-computed coordinates.
      Owner ratified **Option 2 -- full kinship2-parity layout on visNetwork**
      via `AskUserQuestion`, over reopening D2/switching to kinship2 or a
      smaller partial-repositioning step. See `CHANGELOG.md`.)
- [ ] (design DONE -- S458, 2026-08-02, see
      `docs/planning/pedigree-diagram-option2-layout-design-plan.md`.
      **Pedigree Diagram: full kinship2-parity layout (Option 2 design
      session)** -- designed and owner-ratified a mating-unit/individual
      -duplication transformation (CraneFoot-derived) resolving
      crossing-minimization ordering, multi-mate/half-sib fan-out, and
      inbreeding-loop safety via one mechanism; a simplified
      Reingold-Tilford/Walker contour-merge algorithm (not an off-the-shelf
      package -- `igraph`/`ggraph` are GPL) computes final coordinates. Owner
      ratified via `AskUserQuestion` with one editorial direction:
      non-human-centric terminology (`sire`/`dam`/`mate`/`mating`). See
      `CHANGELOG.md`.)

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
*S419's capability-comparison audit (`docs/audits/GENETIC_METRICS_PDF_CAPABILITY_AUDIT_2026-07-29.md`)
compared the package against the 2015 NHP Genetics and Genomics Working Group PDF and found 12
missing / 9 partial findings (of 37 total). Triaged S422 (2026-07-29) via owner `AskUserQuestion`
picks -- all 6 findings/clusters owner-directed to file as GitHub issues, tracked there, not here:
**#125** (configurable ranking-priority scheme + surface multiple breeding-group candidates,
Dimensions 1 & 2), **#126** (kinship/genome-uniqueness distribution shape statistics -- skewness,
kurtosis, Dimension 3), **#127** (surface `correctUnknownParentMeanKinship()`'s silently-dropped
`flagged` list, Dimension 4), **#128** (breeding-group exclusion is top-N rank-based, not a
genetic-value floor, Dimension 2), **#129** (pedigree-diagram/tree visualization, currently
table-only, Dimension 7), **#130** (marker-based kinship/heterozygosity/parentage-verification +
cross-center identity resolution, Dimensions 5 & 6). 1 finding (NGS/whole-genome/MHC-specific/
linkage-disequilibrium methods, Dimension 5) declined, no action -- the source PDF itself frames
these as speculative future work even in 2015, matching the audit's own Recommendation #5. The
remaining findings (PMX/MateRx/Pedscope/PedSys tool-comparison notes, the "make pedigree available
to researchers" governance recommendation) are descriptive or already-adequately-served, not gaps
requiring tracking. See `CHANGELOG.md`.*

**Second-generation re-audit and issue-sequencing (S479-S483, 2026-08-05 to 2026-08-08):** a ghost
session (reconciled S479, `PROJECT_LEARNINGS.md` Learning 479) produced 2 further capability audits
(`docs/audits/GENETIC_METRICS_PDF_CAPABILITY_AUDIT_2026-08-05.md`, `..._2026-08-06.md`) and filed 8
new GitHub issues: **#146** (configurable/exhaustive breeding-group candidate retention), **#147**
(likelihood-based candidate-parent assignment), **#148** (MHC haplotype-specific frequency
reporting), **#149** (cross-center identity-mapping workflow with provenance export), **#150**
(de-identified pedigree export workflow), **#151** (individual mate-pair analysis), **#152**
(whole-genome/whole-exome sequence input + sequence-based metrics), **#153** (linkage-aware/
haplotype-block metrics). Sequencing ratified S483
(`docs/audits/GENETIC_METRICS_ISSUES_SEQUENCING_AUDIT_2026-08-08.md`, owner-directed, 8-agent
codebase-grounded workflow): Tier 1 #147; Tier 2 #149 > #146 > #151; Tier 3 (policy-gated) #150;
Deferred (design-only) #152 > #153 > #148, with #148 flagged as needing its own scope-narrowing
conversation first (filed broader than the audit recommends). **Also found, still not filed as of
this compression:** 2 audit-table High-priority rows -- "Longitudinal genetic-health monitoring" and
"Ancestry guardrails in breeding decisions" -- have no corresponding GitHub issue, despite ranking
above every Medium/Deferred item in this batch (Finding #1/Recommendation 2); a future triage session
should file both. **Every Tier 1/2/3 item (#147, #149, #146, #151, #150) plus Deferred-tier #153 are
now fully shipped and closed** -- see the compressed entries below. #152 (Deferred) is in progress
(Slice 3 next). #148 remains unstarted, still needing its scope-narrowing conversation. See
`CHANGELOG.md`.

**Progress (S517, 2026-08-11):** the Deferred/scientific tier's first item -- issue #152's own
design/architecture document (whole-genome/whole-exome sequence input + sequence-based genetic
metrics) -- is DONE and RATIFIED: see
`docs/planning/issue152-sequence-input-genetic-metrics-plan.md`. Two parallel background research
agents (a codebase-inventory `Explore` agent; a domain-research `general-purpose` agent) plus direct
verification of the single most load-bearing prior decision (issue #130 plan's D2, the ratified
Bioconductor-Imports decline) grounded the design. Central findings: `markerKinship()`'s O(n²·L)
nested-pair loop and `markerParentageLikelihood()`'s O(F·C·L·n) redundant per-candidate
allele-frequency rescan are the real scale bottlenecks (independent of the biallelic-only question);
a directly-applicable captive-pedigreed-macaque-colony precedent (Bimber et al. 2016, ~22,455-marker
GBS panel + pedigree-aware imputation) grounds a realistic scope-tier ceiling; raw VCF ingestion is
infeasible on pure file-size grounds (144 GB-900 TiB class); summary statistics computed from
genotype data are not an automatic privacy safe-harbor (Homer et al. 2008), so any sequence-derived
export (raw or derived) must route through the same curator-controlled gate issue #150 already
shipped. Ten design decisions (D1-D10); four genuine judgment calls (D1 scope tier, D3
`locusMetadata` sidecar timing, D6 initial metric set, D8 module boundary) ratified via a single
`AskUserQuestion` round -- owner selected this document's own recommended option in all four:
sparse/GBS-scale tier (~50,000-locus ceiling, declining to reopen the Bioconductor decline); build
the `locusMetadata` (`locus, chrom, pos[, cM]`) sidecar now, as shared vocabulary for sibling issue
#153; genome-wide F_ROH (new, Ceballos et al. 2018) plus genome-scale reruns of the existing
kinship/heterozygosity/Fst functions, explicitly ceding effective-population-size-from-LD to #153; a
new tab inside the existing `modMarkerGenetics.R`, not a dedicated new module. Scoped as 5 future
vertical slices (ingestion+fixture; a required `markerKinship()`/`markerParentageLikelihood()`
performance rewrite; the new F_ROH metric; a new de-identification primitive; the full module tab +
documentation), each its own future session. No code changed this session -- design/planning only,
matching the #133/#136/#137/#145/#146/#147/#149/#150/#151 precedent. Issue #152 intentionally left
open. **Next in the ratified Deferred-tier order: #153 (linkage-aware/haplotype-block metrics), which
can now reuse this session's own `locusMetadata` vocabulary; #148 (MHC) still needs its own
scope-narrowing conversation first, per the sequencing audit's Finding #4.** See `CHANGELOG.md`.

**Progress (S525, 2026-08-11):** Issue #152 Slice 1 -- sequence ingestion + fixture -- is now
DONE, per `docs/planning/issue152-sequence-input-genetic-metrics-plan.md` §5 Slice 1. Full strict
TDD PRE-RED->RED->GREEN cycle (REFACTOR: a real candidate was identified -- a 3rd copy of
`checkMarkerGenotypeFile()`'s structural-check logic -- but declined via `AskUserQuestion` as
out of this slice's pre-declared file scope, matching the S521-S524 precedent of deferring
cross-file refactors; noted for a future session). New `checkSequenceGenotypeFile()` (D2/D4):
same structural rules as `checkMarkerGenotypeFile()`, plus two new rules this design adds -- a
literal `"."` (VCF missing-genotype placeholder) allele value is rejected before the biallelic
count check runs (so the error is specific, not misleadingly "more than two alleles"), and a
locus count above a `maxLoci` parameter (default `50000L`, D1's scope-tier ceiling) triggers a
`warning()`, not a `stop()`. A genuine PRE-RED discovery: the plan's own §5 Slice 1 deliverable
"a new locusMetadata validation helper" (D3) was **already shipped** -- issue #153 Slice 1
(S520) built `checkLocusMetadata()` against this exact schema, crediting #152's own design
decision as its origin -- so this slice reuses it directly rather than reimplementing it.
Also, per PRE-RED `AskUserQuestion` (4 decisions, all recommended options chosen): returns the
checked dataframe (not `TRUE` invisibly, the plan's literal but since-superseded wording) to
match the actual 3-for-3 sibling-validator convention; `maxLoci` is a parameter, not a hardcoded
constant; the literal-`"."` case is a hard `stop()`, not a silent `NA` coercion. New
`data-raw/generate_sequence_fixtures.R` (seeded `set_seed(152L)`) generates a 50-individual x
1,000-locus synthetic biallelic SNP panel across 20 chromosomes with ~2% missingness, plus a
100%-"full"-coverage `locusMetadata` sidecar (deliberately not the sparse mix #153's own STR
fixture models -- this fixture's stated purpose is scale/performance exercise, Slice 2, and
reuse by the future F_ROH metric, Slice 3, which needs position data for every locus) --
committed as `inst/extdata/examples/example_sequence_genotypes.csv` /
`example_sequence_locus_metadata.csv`. 18 new `test_that` blocks, 0 regressions. Full clean
regression 5,408 passed/0 failed/0 error (17 pre-existing warnings, all traced to 4 unrelated,
already-known pre-existing test blocks); `devtools::check()` 0 errors/0 warnings/3 NOTEs, all 3
independently confirmed pre-existing (top-level files; vignettes/figure leftover; the known
~69-70-word spelling-WORDLIST gap -- direct diff confirmed zero flagged words trace to this
session's own new files); `lintr::lint_package()` 0 lints on touched files (1 line-length + 1
`stopifnot_all_linter` finding fixed). `_pkgdown.yml` reference-coverage guard fixed (new export
added to the "All exposed functions" catch-all group). `inst/WORDLIST` gained 5 new entries
(`GBS`, `VCF`, `VCF's`, `VCFtools`, `Danecek`) for this session's own new citation/vocabulary --
the Danecek et al. 2011 VCF citation was trimmed to first-author-plus-"et al." (matching this
codebase's own `MacCluer JW, et al.` precedent) rather than listing all ~12 co-authors, avoiding
4 additional WORDLIST entries for names with no other use in this package. `NEWS.Rmd`/`NEWS.md`
terse entry added (deliberately matching the pre-1.0.8 style this file's own flagged
verbosity-drift item, above, asks future entries to return to). Citation checklist (issue #120)
and tutorial/article checklist (Session 436) do NOT yet apply -- no UI/displayed statistic this
slice, matching the #146/#149/#150/#151/#153-Slice-1 precedent. Runtime smoke test: n/a --
script-callable only, no Shiny wiring this slice (matches the `resolveCrossCenterIds()` Slice 4
precedent). **Issue #152 stays open -- Slice 2 (the `markerKinship()`/
`markerParentageLikelihood()` performance rewrite, D5) is the next planned slice**, a separate
future session per the plan's own session-boundary requirement. See `CHANGELOG.md`.

**Progress (S526, 2026-08-11):** Issue #152 Slice 2 -- the `markerKinship()`/
`markerParentageLikelihood()` performance rewrite (D5) -- is now DONE, per
`docs/planning/issue152-sequence-input-genetic-metrics-plan.md` §5 Slice 2. Full strict TDD
PRE-RED->RED->GREEN cycle (REFACTOR: a real candidate was identified -- the
alphabetically-first-observed-allele-as-reference idiom now exists independently in 3 places
(`markerFst.R`, `markerParentageLikelihood.R`, the new `markerKinship.R`) -- declined via
`AskUserQuestion` as touching `markerFst.R`, outside this slice's pre-declared file scope,
matching the S521-S525 precedent). This slice is fundamentally a refactor (unchanged public
signatures/output), so PRE-RED's own `AskUserQuestion` round first resolved how RED applies:
golden-master regression tests (dput()-captured current output, `expect_identical()`) pass
immediately as a characterization safety net; two new precedent-setting `system.time()`
benchmark tests (no new dependency) are the slice's actual RED, gated at thresholds tighter
than this session's own measured current runtime on the committed Slice 1 fixture
(`markerKinship()` ~0.12-0.13s warm / 0.08s threshold; `markerParentageLikelihood()`
~0.84-0.88s warm / 0.5s threshold, explicit id/role/candidates call, no new fixture). A real
PRE-RED finding: a plain `dput()` does not always round-trip a double exactly (found
`-0.3` printing for an actual `-0.30000000000000004`) -- both golden-master literals use
`dput(x, control = c(..., "digits17"))` instead. `markerKinship()` rewritten as vectorized
matrix algebra (integer-count matrix products via `Hz`/`Gz`/`Z0`/`Z2` indicator matrices),
achieving ~0.07-0.09s (a ~2x speedup) while preserving the original's per-pair
undefined-kinship warning and ordering exactly. `markerParentageLikelihood()` rewritten to
precompute every locus's allele-frequency table once per call (was: once per
(offspring, candidate, locus) triple), achieving ~0.35-0.39s (a ~2.4x speedup) for the
10-candidate benchmark scenario. Both new benchmark tests include an untimed warm-up call
before timing -- PRE-RED found the naive (no-warm-up) version flakes between ~0.12s and
~0.26s depending on JIT warm-up state/test execution order -- plus the MEDIAN of 3 timed reps
rather than a single call, added after a single-call design still flaked once (system-noise
variance, not JIT) in a full `test_dir()` run despite passing 5/5 isolated `test_file()`
reruns (`markerKinship()`'s threshold loosened 0.08s -> 0.10s accordingly; both fixes are
`PROJECT_LEARNINGS.md` Learning 532's final form). 4 new `test_that` blocks (2
golden-master, 2 benchmark) across the 2 existing test files; 0 regressions. Full clean
regression 5,417 passed/0 failed/0 error (17 pre-existing warnings, unchanged), re-confirmed
clean across 2 further solo full-suite reruns after the median-of-3 fix;
`devtools::check()` 0 errors/0 warnings/3 NOTEs, all 3 confirmed pre-existing (top-level
files; vignettes/figure leftover; the known ~77-word spelling-WORDLIST gap, up from ~69-70 --
zero flagged words trace to this session's own touched files; note the 3rd NOTE does not
appear as its own `❯` bullet in `devtools::check()`'s printed summary, only in the raw
`Status:` line -- this session independently reproduced the exact undercounting risk
`BACKLOG.md`'s own S521 finding above already documents); `lintr::lint_package()` found and
fixed 9 `implicit_integer_linter` findings in the new `markerKinship.R` matrix-algebra code
(`0`/`2`/`4` -> `0L`/`2L`/`4L`), 0 lints remaining. `_pkgdown.yml` unaffected (no new export --
both functions already listed). `NEWS.Rmd`/`NEWS.md` terse entry added. Citation checklist
(issue #120) and tutorial/article checklist (Session 436) N/A -- no new/displayed statistic,
no UI change this slice. Runtime smoke test: n/a -- script-callable only, no Shiny wiring
touched this slice. **Issue #152 stays open -- Slice 3 (the new F_ROH metric,
`R/computeGenomicROH.R`, D6) is the next planned slice**, a separate future session per the
plan's own session-boundary requirement. See `CHANGELOG.md`.

**Progress (S532, 2026-08-12):** Issue #152 Slice 3 -- the new `computeGenomicROH()` F_ROH
metric (D6) -- is now DONE, per `docs/planning/issue152-sequence-input-genetic-metrics-plan.md`
§5 Slice 3. Full strict TDD PRE-RED->RED->GREEN->REFACTOR cycle, gated by an `AskUserQuestion`
at every transition per `CLAUDE.md`'s Development Process Contract. Three genuine judgment
calls the design left open were ratified via a dedicated Pre-RED `AskUserQuestion` round
(all recommended options chosen): both a heterozygous AND a missing genotype end a
run-of-homozygosity; F_ROH's denominator (`genomeLength`) is a single value shared across
every individual -- summed per-chromosome full-coverage-locus span from `locusMetadata`,
Ceballos et al. (2018)'s L_autosome convention, not recomputed per individual (avoids
conflating an individual's own missingness with inbreeding); defaults `minSnp = 50L`,
`minBp = 1e6` (1 Mb matches PLINK's own `--homozyg-kb` default; 50 SNPs is scaled down from
PLINK's literal 100 for this package's sparser GBS-scale target tier, D1). New
`R/computeGenomicROH.R` reuses `checkLocusMetadata()`'s existing 3-tier coverage
classification to exclude any locus lacking full chrom+pos coverage from both the ordered
walk and the denominator (warned, not treated as a run-breaking gap) -- ~150 lines,
loop-based per individual/per chromosome (this slice is new code, not one of D5's two named
rewrite targets, so no vectorization requirement applied). 9 new `test_that` blocks in
`tests/testthat/test_computeGenomicROH.R` (40 expectations): a hand-derived 3-individual/
2-chromosome core fixture (exact-fraction expected values, matching `markerFst.R`'s own
convention) plus 8 focused edge cases (heterozygous break, missing break, locus-exclusion
+warning, dual-threshold both directions, a normal zero-segment case with no spurious warning,
absent/NULL `locusMetadata` -> `stop()`, a zero-`genomeLength` -> warning+`NA` case, and
confirmation of the `minSnp`/`minBp` defaults). RED confirmed (9/9 blocks failing, function not
found) before implementation; GREEN passed all 9 blocks (40/40 expectations) on the first
implementation attempt. REFACTOR: fixed 4 `implicit_integer_linter` findings (bare `0`/`1e6`
literals), 0 behavior change, re-confirmed 40/40 still passing. A real mid-close-out finding:
`devtools::check()` first reported only 2 NOTEs (not the expected 3, since the known
~69-77-word spelling-WORDLIST gap did not fire) -- direct `spelling::spell_check_package()`
verification (not assumed) found this session's own new content introduced 6 genuinely new
flagged words (`bp`, `Ceballos`, `gapless`, `Joshi`, `PLINK's`, `ROH`), hand-added to
`inst/WORDLIST` in `LC_ALL=C` byte-order position. Also found and fixed a `PROJECT_LEARNINGS.md`
Learning 530 violation this slice's own first draft made: the `@references Purcell et al.
2007` (PLINK) citation was copied verbatim from `checkLocusMetadata.R`'s existing 11-author
form rather than trimmed to "Purcell, S., et al. (2007)" per Learning 530's own >6-author
rule -- fixed, removing `computeGenomicROH.Rd` as a second independent source of 5
already-known WORDLIST-gap surnames (`Bakker`/`Ferreira`/`Maller`/`Neale`/`Sklar`, still
present via `checkLocusMetadata.R`'s own unchanged citation, out of this slice's scope to
fix). Citation checklist (issue #120): new "Genomic Runs of Homozygosity (F_ROH)" entry added
to `inst/extdata/ui_guidance/population_genetics_terms.html`, matching the file's established
per-metric style. `NEWS.Rmd`/`NEWS.md`: terse entry added (matching the Slice 1/2 entries'
own brevity, honoring this session's own flagged NEWS-verbosity-drift backlog item rather than
adding to it). `_pkgdown.yml`: new `computeGenomicROH` entry added at its correct alphabetical
position in the "All exposed functions" group. `devtools::document()` run, `NAMESPACE`/
`man/computeGenomicROH.Rd` regenerated. Full clean regression 5,457 passed/0 failed/0 error (0
non-baseline offenders); `devtools::check()` 0 errors/0 warnings/2 NOTEs, both confirmed
pre-existing (top-level files; vignettes/figure leftover -- the spelling NOTE is gone, not
hidden: independently re-verified via direct `spelling::spell_check_package()`, not the
abbreviated `❯`-bullet table `BACKLOG.md`'s own S521/S526 findings warn against trusting
alone); `lintr::lint_package()` 0 lints on touched files. Runtime smoke test: n/a --
script-callable only, no Shiny wiring touched this slice, matching the Slice 1/2 precedent.
**Issue #152 stays open -- Slice 4 (the new de-identification primitive,
`R/obfuscateGenotypeMatrix.R`, D7) is the next planned slice**, a separate future session per
the plan's own session-boundary requirement. See `CHANGELOG.md`.

**Progress (S533, 2026-08-12):** Issue #152 Slice 4 -- the new `obfuscateGenotypeMatrix()`
de-identification primitive (D7) -- is now DONE, per
`docs/planning/issue152-sequence-input-genetic-metrics-plan.md` §5 Slice 4. Full strict TDD
PRE-RED->RED->GREEN->REFACTOR cycle, gated by an `AskUserQuestion` at every transition per
`CLAUDE.md`'s Development Process Contract. D7 was already ratified at the design session
(folded into D8's own vote, §11), and the interface catalog (§4) fully specified the
function's shape, so this slice needed no fresh Pre-RED judgment-call round, unlike Slice 3's
3 open decisions. New `R/obfuscateGenotypeMatrix.R` mirrors `obfuscateTwinRelations()`'s/
`obfuscateLdBlocks()`'s established de-identification pattern exactly: reads
`rownames(genotypeMatrix)` as the ids, `stop()`s loudly (never silently drops) if any id is
absent from `map`, otherwise remaps rownames to their alias via `unname(map[ids])` --
genotype cell values, column names (loci), and row/column order are all untouched by
construction. 3 new `test_that` blocks in `tests/testthat/test_obfuscateGenotypeMatrix.R`:
remap-and-values-unchanged, stop-on-missing-id, and a round-trip through the real map
`obfuscatePed(ped, map = TRUE)` returns -- mirroring the established test shape for this
function family. RED confirmed (3/3 blocks failing, function not found) before
implementation; GREEN passed all 3 blocks on the first implementation attempt. REFACTOR: a
first lint pass mistakenly used `lintr::linters_with_defaults()` instead of the project's own
`.lintr` config, surfacing 4 false-positive-looking findings (camelCase naming, indentation)
this project's own config explicitly permits/disables -- caught before treating any of them
as real; re-run with the correct `lintr::lint_package()` (no override) found 0 lints, so no
refactor changes were needed. `PROJECT_LEARNINGS.md` Learning 539 records the near-miss.
`devtools::document()` regenerated `NAMESPACE`/`man/obfuscateGenotypeMatrix.Rd` plus the
`@family obfuscation` cross-reference in 6 sibling `.Rd` files (collateral, expected).
`NEWS.Rmd` gained a terse entry (rendered to `NEWS.md` via `rmarkdown::render()`, matching
this file pair's established regeneration convention); `_pkgdown.yml`'s "All exposed
functions" group gained the new export at its correct alphabetical position, confirmed via
`test_pkgdown_reference_config.R`. Citation checklist (issue #120) and tutorial/article
checklist (Session 436): N/A this slice, per the design doc's own §9 checklist mapping (Slice
4 is not a displayed statistic and ships no UI). Full clean regression 0 failed/0 error;
`devtools::check()` 0 errors/0 warnings/2 NOTEs, both confirmed pre-existing (vignettes/figure
leftover; top-level files -- `methodology_trim.py`, root-caused this session to the
`.Rbuildignore` typo above, not a mystery). A first `devtools::check(cran = FALSE)` call
misleadingly returned only 1 NOTE -- caught before accepting it, per Learning 538's own "a
lower NOTE count is not automatically good news" rule; `cran = FALSE` is a non-default
argument that suppresses the CRAN-incoming-style top-level-files check, and re-running with
the plain default (`cran` omitted, `= TRUE`) reproduced the documented 2-NOTE baseline
exactly. `PROJECT_LEARNINGS.md` Learning 539. Runtime smoke test: n/a -- script-callable
only, no Shiny wiring touched this slice, matching the Slice 1/2/3 precedent.
**Issue #152 stays open -- Slice 5 (the full module tab, wiring, curator-controlled export,
and documentation, D8/D9) is the next and final planned slice**, a separate future session per
the plan's own session-boundary requirement. See `CHANGELOG.md`.

**Progress (S535, 2026-08-12):** Issue #152 Slice 5 -- the full module tab, wiring,
curator-controlled export, and documentation (D8/D9) -- is now DONE, closing issue #152 (all 5
slices shipped). Per `docs/planning/issue152-sequence-input-genetic-metrics-plan.md` §5 Slice 5.
A dedicated Pre-RED `AskUserQuestion` round resolved 3 genuine judgment calls the interface
catalog left open (all recommended options chosen): genome-scale kinship/heterozygosity/Fst
reruns reuse the EXISTING `genotypeFile`/`genotypeFileB` inputs (validator swapped to the
confirmed-superset `checkSequenceGenotypeFile()`), not a dedicated duplicate tab; F_ROH's
`locusMetadata` sidecar reuses the EXISTING `locusMetadataFile` input already wired to issue
#153's own tab (D3's shared-vocabulary intent); the curator export covers exactly 3 artifacts
(de-identified genotype matrix, de-identified F_ROH table, manifest), not all 4-5 possible
tables. New `R/obfuscateGenomicROH.R` (`obfuscateGenomicROH()`, a new de-identification
primitive for computeGenomicROH()'s id-column table shape -- none of the existing `obfuscate*`
siblings fit). New "Genomic ROH (F_ROH)" tab in `R/modMarkerGenetics.R`: `sequenceRohTable`
reactive, curator confirm-gate export (Generate Preview -> Confirm -> Confirm-OK -> 3
downloads), `.buildSequenceExportManifest()` helper. 13 new tests (RED->GREEN->REFACTOR each
gated by `AskUserQuestion`); full clean regression 0 failed/0 error (2,127 blocks).
**A real bug found and fixed via this slice's own Phase 3E live verification** (not caught by
testServer alone): `sequenceRohTable` passed `locusMetadata()`'s ALREADY-checked output
(`checkLocusMetadata()` appends a `coverage` column) into `computeGenomicROH()`, which
internally re-runs `checkLocusMetadata()` expecting the raw 3/4-column shape -- silently
mislabeled `coverage` as `cM` on a 3-column fixture (no error, wrong data) and threw loudly on
a real 4-column (with `cM`) fixture, reproduced live against the actual committed Slice 1
fixture. Fixed by stripping the `coverage` column before the second check; a new regression
test (4-column, with-`cM` fixture) added. **A second finding, NOT a defect**: a live probe
found `shinytest2`/`chromote`'s headless browser never renders a `showModal()` modal's DOM for
EITHER this tab's export gate OR the already-shipped issue #153 LD-block export's identical
pattern -- a pre-existing harness limitation predating this slice, filed to this file's own
Housekeeping section (found S535) rather than attempted mid-session. The live E2E test
(`tests/testthat/test-e2e-marker-genetics-genomic-roh-module.R`) verifies everything through
Generate Preview against the real Slice 1 fixture at full 50x1,000-locus scale (zero console
errors); the Confirm-modal step is documented and gracefully skipped, with the server-side
confirm sequence proven correct by `testServer()`. `devtools::check()` 0 errors/0 warnings/2
NOTEs (both confirmed pre-existing: vignette/figure leftover; the separately-tracked
`inst/WORDLIST` gap) -- verified via the RAW `Status: N NOTEs` line, not the abbreviated
`❯`-bullet table alone, per Learning 538's own discipline; 1 genuinely new flagged word
(`computeGenomicROH`, this session's own new file) hand-added to `inst/WORDLIST`, matching the
Slice 1 precedent of adding only what the session's own new content is responsible for.
Citation checklist (issue #120): N/A, already satisfied at Slice 3. Tutorial/article checklist
(Session 436): DONE -- a new "Genomic ROH (F_ROH)" section added to
`vignettes/articles/colony-manager-guide.qmd` with a real screenshot from the live app.
`_pkgdown.yml` reference-coverage guard: DONE (`obfuscateGenomicROH` added). `a2interactive.Rmd`
checklist: deferred per its own standing rule, not this slice. `PROJECT_LEARNINGS.md` Learning
541. **Issue #152 closed** -- all 5 slices (ingestion+fixture, performance rewrite, F_ROH
metric, de-identification primitive, full module+export+docs) shipped across Sessions 525-535.
See `CHANGELOG.md`.
