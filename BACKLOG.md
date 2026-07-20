# Backlog

*Open, actionable work only. Completed history → `CHANGELOG.md`; feature inventory &
future plans → `ROADMAP.md`. (Methodology file model — see `SESSION_RUNNER.md` Phase 0.)*

## Active
- [ ] (none in progress)

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
- [ ] (none remaining)

## Up Next
- [ ] (none remaining -- the "verify + likely fix the same low-contrast Mermaid defect in
      colony-manager-guide.qmd" item (flagged S401) is RESOLVED: verified S403 (2026-07-19) --
      NOT affected (the diagram is a plain `flowchart LR` with zero `subgraph` blocks; the actual
      defect is scoped to subgraph/cluster CSS, not a blanket pkgdown-mixed-mode issue -- see
      `PROJECT_LEARNINGS.md` Learning 371, which corrects Learning 369's root-cause claim).
      `format: html: mermaid: theme: default` applied to this file's frontmatter anyway, owner
      directed, as a defensive/future-proofing measure. See `CHANGELOG.md`.)
- [ ] (none remaining -- the "fix broken 'Read deeper' links in the colony-manager-guide
      article" item (issue [#124](https://github.com/rmsharp/nprcgenekeepr/issues/124), filed
      S400) is RESOLVED on the `fix/figure2-contrast-engineering-2.0.0-release` branch --
      fixed S404 (2026-07-20): all 10 `.qmd` hrefs retargeted directly to `.html`
      (`vignettes/articles/colony-manager-guide.qmd:26,50,99-103,374,534`). Pre-work
      verification found Learning 368's "pkgdown's mixed-mode build doesn't perform the
      rewrite" framing was incomplete -- a bare local `quarto render` of the same project
      (no pkgdown involved) produces the identical unrewritten `.qmd` href, because the
      rewrite is a `type: website`/`book` Quarto project feature this directory's
      `_quarto.yml` never enables (see `PROJECT_LEARNINGS.md` Learning 372, which corrects
      Learning 368). All 7 distinct link targets confirmed live at the fixed relative path
      (HTTP 200) before editing; rendered output re-verified to contain zero remaining
      `.qmd` hrefs. **Issue #124 stays open** -- the fix is on the unmerged/unpushed branch
      below, not yet live on the published site. See `CHANGELOG.md`.)
- [ ] **Decide branch-merge strategy for `fix/figure2-contrast-engineering-2.0.0-release`**
      (DECISION NEEDED -- owner-only, Effort S) -- 10 commits (S401 Figure 2 contrast fix,
      S402 Figure 2 subgraph-title/node-box overlap fix, S403 colony-manager-guide Mermaid
      theme defensive fix, S404 colony-manager-guide "Read deeper" link fix), still unmerged
      to `master` and unpushed to `origin` as of S404 (owner explicitly scoped S404 to stay
      off `master`). All four fixes are independently verified and complete. Owner should
      decide: open a PR/merge now, or keep accumulating "other aspects of the article" work
      on this branch first. First flagged in S402's handoff, carried through S403 and S404
      without being tracked in `BACKLOG.md` itself until now.
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
- [ ] **CRAN resubmission of v2.0.0** (BLOCKED -- awaiting CRAN's manual
      reviewer response to the 2026-07-17 submission, no engineering action
      open, Effort: N/A. The prior "DECISION NEEDED -- owner-only:
      `devtools::submit_cran()`" tag is now stale -- that decision was made
      and acted on S397/owner action below; flagged stale S398, corrected
      S399.) S395 (2026-07-17) re-opened the effort S392-394 had closed as
      exhausted, with owner authorization to change test structure and
      previously-protected iteration counts. Landed 2 more real,
      verified-safe levers (Shiny testServer stub-completeness/
      fixture-hoisting across `test_appServer_*`/`test_reportGV.R`, and a
      fixture-size fix to `test_addAnimalsWithNoRelative.R` -- ~5.85s ->
      ~0.01s locally, the session's single biggest genuinely-CRAN-relevant
      win). Caught and corrected one false lead before it shipped: the
      session's other headline number (`test_pkgdown_reference_config.R`)
      turned out CRAN-irrelevant once verified against a real `R CMD check`
      on the built tarball (`_pkgdown.yml` is `.Rbuildignore`'d, so that file
      already skips on every real CRAN check) -- kept as a harmless
      local-dev-loop speedup only, not counted toward the checktime goal.
      Real local `R CMD check --as-cran --timings`: `tests` 59s /
      `examples` 22s / `vignette-rebuild` 17s, `0 errors | 0 warnings |
      1 note`. **Win-builder Windows-devel re-check dispatched -- S396
      (2026-07-16):** `devtools::check_win_devel()` run from the project
      root (clean, in-sync tree confirmed before and after); results due to
      `rmsharp@me.com` by ~10:46 PM 2026-07-16. Deliberately scoped to this
      single check (not the fuller S390 pattern of x3 win-builder + R-hub),
      matching this item's own Effort S next-step scope. **Result processed
      -- S397 (2026-07-17): confirms real savings, first result under the
      10-minute mark, thin margin.** `checking tests` `245s -> 200s` (-45s);
      `examples` 80s and `vignette rebuild` 65s essentially unchanged (no
      further safe lever, per S395). Win-builder's own reported totals
      (email footer): Installation time 30s, **Check time 588s** -- down
      from the S392-394 cycle's 655-656s, and under CRAN's 600s mark by
      **12s**. `Status: 1 NOTE` (incoming feasibility only, same flags as
      every prior cycle, no WARN/ERROR). Caveat: win-builder's "Check time"
      is the best available proxy for CRAN's own "Overall checktime" (the
      real incoming-pipeline figure that rejected S392's submission,
      extrapolated at ~720s) but not proven identical, and S394 already
      measured several seconds of run-to-run VM-load noise -- 12s of margin
      on a proxy metric is real progress but not a guarantee against a
      repeat rejection. win-builder R-release/R-oldrelease and R-hub are
      still the Session 390/391 results, now stale relative to the S392-395
      fixes (not expected at risk from the checktime-specific issue, which
      is Windows-r-devel-specific, but unconfirmed against current code).
      Full detail in `cran-comments.md`'s "Test environments" section (the
      dated "2026-07-17 update note" this line previously cited was removed
      by the S397 addendum trim to code-changes-only content, commit
      `3c7486b9` -- stale cross-reference caught and fixed S399). **Owner
      decision (S397, 2026-07-17, via `AskUserQuestion`): resubmit now.**
      **Submitted -- owner ran `devtools::submit_cran()` 2026-07-17;
      package uploaded successfully to the CRAN submission team, and the
      maintainer-email confirmation link was clicked the same day.**
      **CRAN's own incoming-pretest auto-check confirmed clean -- S399
      (2026-07-18):** the real submission (not a manually-triggered
      win-builder pretest) auto-processed with `Status: 1 NOTE` on both
      Windows r-devel and Debian (the standard incoming-feasibility note
      only -- new submission, archived-package history, DESCRIPTION
      spelling flags -- no WARN/ERROR). Verified against the actual
      `00check.log` files (not just the email summary), per this project's
      own established practice: Windows `checking tests` 205s / `examples`
      79s / `re-building of vignette outputs` 65s; Debian `tests` 89s /
      `examples` 43s / `vignette outputs` 29s -- consistent with the
      S392-395 fixes holding on the real submission, not just the
      pre-submission pretest. **Reconciled the checktime caveat:** the
      email footer reported "Check time in seconds: 604" (4s over the 600s
      mark that caused the prior S392 archival-class rejection), but the
      actual check log contains no "Overall checktime" flag anywhere --
      the only "Tested elapsed times" occurrence is quoted historical
      metadata from the 2025-07-29 CRAN db override, not a fresh flag on
      this submission. This is a second data point (after S397's 588s)
      that the win-builder-style footer "Check time" figure is not the
      same measure as CRAN's own incoming-pipeline "Overall checktime" gate
      -- a submission whose footer exceeded 600s was NOT auto-rejected.
      Email states the package is "pending a manual inspection," typical
      response within 10 working days. Now
      fully in CRAN's review queue -- awaiting CRAN's actual review outcome,
      asynchronous and owner-only, no further engineering action open
      unless CRAN rejects it again. CRAN responded 2026-07-09 to the PRIOR
      (S329) attempt:
      the v2.0.0 submission (S329, `devtools::submit_cran()`, `CRAN-SUBMISSION` sha
      `8ca8bb24`) was archived before publication because `appServer()` unconditionally
      wrote `~/nprcgenekeepr.log` on every boot, violating CRAN Policy. **Fixed in
      S349** (`R/appServer.R`: the file appender is now gated behind the "Debug on"
      checkbox's already-tested `debugMode` reactive, never written unconditionally;
      see `CHANGELOG.md` 2026-07-10 S349 entry for full verification detail incl. a
      live-browser Phase 3E smoke test). **Local pre-submission gate re-confirmed --
      S359 (2026-07-11):** `R CMD build .` + `R CMD check --as-cran --timings` on
      current `master` (134 commits since the archived sha, 9 touching
      `R/`/`tests/`/`DESCRIPTION`/`NAMESPACE`) -- `0 errors | 0 warnings | 1 note`
      (the expected incoming-feasibility note only; the local HTML-manual note is
      gone). **Important:** the win-builder/R-hub results that were on file in
      `cran-comments.md` predated the S349 fix (captured the day before, on the
      exact sha that was archived) -- reset to placeholders; see
      `docs/planning/cran-2.0.0-phase5-runbook.md`'s refreshed top note for the
      full ancestry check. Next (owner action, unchanged): re-run the win-builder /
      R-hub pre-submission checks (now genuinely required, not just stale-by-time)
      and resubmit via `devtools::submit_cran()`. No version bump is required (the
      prior 2.0.0 attempt was archived before publication) unless the owner
      prefers one. **Win-builder x3 + R-hub triggered -- S361 (2026-07-11):** per
      owner's explicit scoping (not `submit_cran()`, which stays owner-only).
      **Results processed -- S362 (2026-07-11): all clean.** win-builder:
      0 errors | 0 warnings on all three R versions (1 note each -- the expected
      incoming-feasibility note; R-oldrelease also flagged the known
      `groupAddAssign` >10s timing note on slower hardware, not a failure).
      R-hub (`occupational-burro`,
      https://github.com/rmsharp/nprcgenekeepr/actions/runs/29171440079):
      `Status: OK` on linux/windows/macos, 0 test failures. The Windows
      `WriteXLS` CI failure S361 flagged as a likely blocker did NOT reproduce on
      either external check -- it was a GitHub-Actions-runner-specific flake, not
      present on CRAN's own win-builder infrastructure. **Root-caused and fixed
      S363 (2026-07-11):** `create_wkbk()` now writes `.xlsx` via `openxlsx`
      instead of `WriteXLS`, removing the Perl-on-Windows dependency entirely;
      see `CHANGELOG.md`. Results folded into
      `cran-comments.md`'s "Test environments" section. **Pre-submission gate is
      now clean across every environment actually run this cycle.** **Local gate
      re-verified S388 (2026-07-16):** 25 commits touched `R/`/`tests/`/
      `DESCRIPTION`/`NAMESPACE` since the S359 confirmation -- `R CMD build .` +
      `R CMD check --as-cran --timings` re-run on current `master` (`79380fba`)
      still returns `0 errors | 0 warnings | 1 note` (timings unchanged within
      noise). `cran-comments.md`'s existing prose numbers remain accurate, no
      edit needed. Owner scoped this re-verify to local-only; win-builder/R-hub
      results on file are still from S361/362, now also 25 commits stale --
      re-triggering them (owner-scoped, outward-facing) is still open before
      submission. See `docs/planning/cran-2.0.0-phase5-runbook.md` and
      `PROJECT_LEARNINGS.md` Learning 358. **Owner-run win-builder finding fixed
      S389 (2026-07-16):** owner ran `devtools::check_win_devel()` after S388 and
      it returned a second NOTE not previously on file -- `checking R code for
      possible problems` flagged deprecated `structure(..., .Names = ...)` usage
      in `tests/testthat/test_getParamDef.R:27` (an R-devel-specific check; local
      R 4.6.1 does not reproduce it, so S388's local re-verify could not have
      caught it). Fixed by dropping the redundant `structure()` wrapper entirely
      (the list's names were already set by the inline `list(param=...,
      tokenVec=...)` construction, so `.Names=` was dead re-assertion, not a
      second names-setting). Confirmed no other live-code `.Names` occurrence
      exists (`R/data.R:337`'s is inside non-`@examples` roxygen prose, never
      parsed as code). Full regression suite re-run clean (0 failed/0 error/0
      warning, 3238 passed, 169 skipped baseline unchanged). **Not yet confirmed
      against win-builder itself** -- local R can't reproduce this specific
      check; confirmation awaits the next win-builder run.
      **Win-builder x3 + R-hub re-triggered -- S390 (2026-07-16):** owner
      picked this item from the Phase 0 priorities list and explicitly scoped
      the session (via `AskUserQuestion`) to trigger now. Found `origin/master`
      5 commits behind local, including S389's actual `.Names=` fix (unpushed)
      -- R-hub checks GitHub's copy, so pushed first (confirmed via
      `AskUserQuestion`) to avoid silently re-testing pre-fix code. Dispatched
      `check_win_devel/release/oldrelease()` and
      `rhub::rhub_check(platforms=c("linux","windows","macos"))` (run
      "hillocked-veery"). **Results processed -- S391 (2026-07-16): all
      clean.** Win-builder: `0 errors | 0 warnings | 1 note` on all three R
      versions (the expected incoming-feasibility note; verbatim `00check.log`
      confirms `checking R code for possible problems ... OK` on all three,
      confirming S389's fix resolved the NOTE on R-devel itself). R-oldrelease's
      prior timing note did not recur. Only one URL (thoughtco.com) flagged
      this cycle vs. two previously (PMC's automated-checker flag appears
      intermittent). R-hub: all three platforms `Status: OK` (zero notes),
      `[ FAIL 0 | WARN 0 | SKIP 221 | PASS 3140 ]` -- fully clean, improving on
      the S361/362 cycle's 1 WARN (the `WriteXLS` Windows flake, confirmed
      absent, consistent with S363's `openxlsx` migration). **The CRAN
      pre-submission gate is now clean across every environment run this
      cycle** (local macOS, win-builder x3, R-hub x3) -- see
      `cran-comments.md` and `docs/planning/cran-2.0.0-phase5-runbook.md` for
      full detail. Next (owner action, unchanged): `devtools::submit_cran()`
      and click the maintainer-email confirmation link -- still owner-only per
      SAFEGUARDS and the runbook's HARD STOP.
      **Real CRAN submission REJECTED -- S392 (2026-07-16):** the owner ran the
      submission out-of-session (evidenced by the uncommitted `CRAN-SUBMISSION`
      dated 2026-07-16 06:17 UTC, SHA matching the S391 close-out commit). CRAN's
      actual incoming automatic check (distinct from the win-builder pretests
      above) rejected it: Windows r-devel flagged "Overall checktime 12 min >
      10 min" -- the same failure class ("Tested elapsed times") that archived
      this package in 2025. Verbatim `00check.log` fetch (not the email summary)
      showed the note is NOT in the check log itself -- it's a separate wall-clock
      summary CRAN's incoming pipeline computes only for real submissions, driven
      by `checking tests ... [334s]` (the dominant cost), `checking examples ...
      [79s]`, and `checking re-building of vignette outputs ... [79s]`; Debian's
      equivalent totals stayed under 5 min, so this is Windows-VM-speed-specific,
      not a universal regression. **Fixed:** `skip_on_cran()` on the 10
      true convergence-stress `test_that` blocks in `test_gvaConvergence.R` /
      `test_gvaConvergence_kinshipOverrides.R` (nMax = 3000L/800L blocks; local
      dev-mode profiling misleadingly counted 4 other "slow" files that never
      actually run on CRAN -- 3 are `rmsharp`-username-gated,
      `test_pkgdown_reference_config.R` skips once `_pkgdown.yml` is absent from
      the built tarball, confirmed via `.Rbuildignore`); `guIter` 100L->20L at the
      ~23 `test_reportGV.R` call sites whose assertions don't depend on gu
      magnitude (verified via full regression + spot-checked deterministic
      properties); `nMax` 3000L->1600L in `vignettes/gvaConvergence.Rmd` (re-
      rendered clean, `recommendedIter`/`converged`/`nRankable` all unchanged).
      **Reverted, not applied:** lowering `guIter` in the `reportGV()`/
      `groupAddAssign()` roxygen `@examples` and in
      `vignettes/a2interactive.Rmd` -- empirically confirmed this introduces a
      NEW `checkFgDegeneracy` warning ("Founder genome equivalents undefined") on
      that fixture at guIter <= 30, which would make the check worse, not
      better; left at the original guIter = 50/50L. Full regression: 0 failed/0
      error/0 warning in both dev and CRAN mode; local CRAN-relevant test-file
      total dropped from ~70s to ~43s (~38%) in `pkgload::load_all()`-based
      profiling (not an official `R CMD check --as-cran` run -- that hung on
      this machine, apparently on `renv` project auto-activation, both with and
      without `R_PROFILE_USER` disabled; abandoned after ~30 min, worked around
      via `NOT_CRAN`-controlled `testthat::test_dir()` profiling instead). Next:
      a fresh win-builder Windows-devel trigger to confirm the real checktime
      drops with margin, before any resubmission attempt.

## Housekeeping
- [ ] (none remaining -- the "clean up stale untracked leftover files" item (filed
      S383) is RESOLVED: 18 confirmed-dead untracked files deleted -- S384
      (2026-07-15). See `CHANGELOG.md`.)

## Architecture (issue #122 / XARCH-2 -- module contract)
*Resolved -- S372 planning session through S377 execution (Phases 1-5, all DONE); see
`CHANGELOG.md` for the per-phase detail (S373 vocabulary-composition fix, S374 kinship
dedup, S375 vocabulary collapse, S376 dead-surface pruning, S377 contract doc + guard
test). The living contract is `docs/architecture/module-contract.md`; it is enforced by
`tests/testthat/test_moduleContract.R`. `modInput` is the reference implementation.*
- [ ] (none remaining)
- [ ] (none remaining -- the former "4 remaining unguarded `getSiteInfo()` call sites"
      item is now fully resolved: `R/getPedigreeSource.R:83`/`R/getLkDirectAncestors.R:26`
      guarded S382 (see `CHANGELOG.md`); `R/modORIPReporting.R:148`/`:244`,
      `R/appServer.R:124` guarded S380. The remaining 2 sites now stand as their own item
      below, since they need a genuinely different design decision.)
- [ ] (none remaining -- the "`setLabKeyDefaults()`/`getDemographics()` unguarded
      `getSiteInfo()` call sites" design-decision item is RESOLVED: decline, no code
      change -- S383 (2026-07-15). See `CHANGELOG.md`.)
- [ ] (none remaining -- issue #123 (XARCH-5) Phase 1 implementation (S386) and the
      follow-up GitHub issue comment reflecting partial, scoped closure (S387,
      2026-07-15, https://github.com/rmsharp/nprcgenekeepr/issues/123#issuecomment-4986749021)
      are both done; the issue is left OPEN, per the plan's own §10 decision 5, pending
      the escalation triggers it names. See `CHANGELOG.md`.)

## Documents (v1.0.8 -> v2.0.0 write-up)
- [ ] (none remaining -- Document 2 (`docs/planning/document2-colony-manager-guide-plan.md`)
      is fully executed: planning DONE (S345), Phase A DONE (S346), Phase B DONE (S347),
      Phase C DONE (S348), **Phase D DONE (S398, 2026-07-17)** -- full claim-source audit,
      `pkgdown`/`R CMD build` verification, and the `ColonyManagerTutorial.Rmd`
      retire/redirect decision. See `CHANGELOG.md`.)

## Audit follow-ups
*(From `PED_GV_AUDIT_2026-05-30.md`; all audit follow-up items are now resolved — see
`CHANGELOG.md`. Per-item reachability notes and traps live in `CLAUDE.md` "Project-specific
Learnings".)*
- [ ] (none remaining)
