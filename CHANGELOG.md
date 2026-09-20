# Changelog — Authoritative Action Ledger

Development / process history for the **nprcgenekeepr** project, following the
[methodology](https://github.com/rmsharp/methodology) model: `BACKLOG.md` holds open
work, **this file** holds completed history, and `ROADMAP.md` holds the feature
inventory and future plans. Per canonical v3.1+, this file is the cumulative,
append-only record of **actions taken** in this repository — the authoritative answer
to *"what was done here, ever?"* Every session records its actions here at close-out
(`SESSION_RUNNER.md` Phase 3F); Phase 0 reconciles it against `git log` and backfills
anything a crashed or out-of-band session missed. Taking an action and not recording
it is failure mode #27.

> **Note:** User-facing R-package release notes (the CRAN / pkgdown "Changelog") live in
> `NEWS.md` / `NEWS.Rmd`. This file tracks the development *process* and methodology
> history, not package releases.

**The rules** — how to add an entry, source tags, reading and archiving — are in
[§The Action Ledger](docs/methodology/FRAMEWORK_APPARATUS.md#the-action-ledger), which `bin/sync`
keeps current. ledger-format: 2 — keep this marker; `bin/status` reads it.

## 2026-08

## 2026-09

**Archived 328 record(s), 2026-08-14 → 2026-09-17** into [`docs/archive/CHANGELOG-through-2026-09-17.md`](docs/archive/CHANGELOG-through-2026-09-17.md) — same format, same order, frozen.
Losslessness is proved by [`docs/archive/CHANGELOG-through-2026-09-17.md.verify.sh`](docs/archive/CHANGELOG-through-2026-09-17.md.verify.sh), which re-derives L1/L2/L3 from git; run it rather
than trusting this sentence. Written by `methodology_trim.py` v1.1.2.

**Archived 40 record(s), 2026-09-17 → 2026-09-18** into [`docs/archive/CHANGELOG-through-2026-09-18.md`](docs/archive/CHANGELOG-through-2026-09-18.md) — same format, same order, frozen.
Losslessness is proved by [`docs/archive/CHANGELOG-through-2026-09-18.md.verify.sh`](docs/archive/CHANGELOG-through-2026-09-18.md.verify.sh), which re-derives L1/L2/L3 from git; run it rather
than trusting this sentence. Written by `methodology_trim.py` v1.1.2.

**Archived 35 record(s), 2026-09-18 → 2026-09-19** into [`docs/archive/CHANGELOG-through-2026-09-19.md`](docs/archive/CHANGELOG-through-2026-09-19.md) — same format, same order, frozen.
Losslessness is proved by [`docs/archive/CHANGELOG-through-2026-09-19.md.verify.sh`](docs/archive/CHANGELOG-through-2026-09-19.md.verify.sh), which re-derives L1/L2/L3 from git; run it rather
than trusting this sentence. Written by `methodology_trim.py` v1.5.0.

### 2026-09-19 · [ad hoc] S725 close-out: session records (SESSION_NOTES handoff + S724 evaluation 9/10, HANDOFFS receipt complete) and post-append verification measurements
- **Trigger states, measured AFTER the handoff/receipt text was appended**, all under
  `--budget-bytes 65536`: `SESSION_NOTES.md` 42,524 B, `HANDOFFS.md` 36,925 B,
  `CHANGELOG.md` 46,092 B — none fires; no trim owed this session. `context_budget.py`:
  no file over its ceiling (`CLAUDE.md` 26,360 B, warn band = documented headroom).
- **Close-out checklists:** no `.R` files touched → lint N/A; no new exports/statistics/
  Shiny features → NEWS/pkgdown/citation/tutorial/`a2interactive` N/A; completed BACKLOG
  item names no GitHub issue → issue close-out N/A; CI green all session (on the S719
  push); quality_ratchet 0/0 (manifest empty by design); runtime smoke N/A — docs-only.
  Learning 770 doubles as the session learning (its point 6 records the reduction method).
- **Owner mid-session report, triaged not fixed (S723 precedent):** the untracked
  `inst/extdata/reference/~$e Compounding Loop.html` is a 162-byte Microsoft Word
  owner/lock file (contents: just the Office username) left behind on 2026-08-18 when the
  local-only `The Compounding Loop.html` reference file was opened in Word; never
  committed; its 3 parent files are individually `.Rbuildignore`d (lines 125-127) but the
  lock file is not, so `R CMD build` copies it into the check tarball → the non-portable-
  filename warning. Remedy (delete + optional `.Rbuildignore` `~$` guard) posed to the
  owner at close-out; not acted on inside this session's deliverable.
- Sha self-reconcile commit follows with its own entry; expect 0 undocumented commits past
  the frontier at next Phase 0.

### 2026-09-19 · [ad hoc] S725 deliverable: `CLAUDE.md` reduction campaign — 43,348 B → 26,360 B, under the 28,000 B ceiling; BACKLOG item removed (completed record here)
- **Method (per the item):** each Adaptations block classified sentence-by-sentence into
  operative rule vs incident narrative; rules kept (verbatim or tightened) with origins
  compressed to Learning pointers; narrative that existed nowhere else moved into the new
  `PROJECT_LEARNINGS.md` Learning 770 (the relocation record — S545 rejected alternatives,
  S436 origin, NEWS.Rmd drift history, `methodology_trim.py` provenance, the S325/S546/S547
  legacy-history decision chain); the full pre-reduction text is archived as
  `git show 1ef168b8:CLAUDE.md`. Kept intact per the item: SESSION PROTOCOL header, the
  `budget:protected` Project Overview fence, the TDD contract (incl. Phase-gate format),
  Build/Test/Verify. Hand-maintained learnings count replaced with its computing command
  (Compute remedy); two sentences the reduction itself falsified were updated (the
  context-budget check's expected state; the trilogy's "no file has moved yet").
- **Verification:** `wc -c CLAUDE.md` = 26,360 B (≤ 28,000; warn band ≥ 24,000 is headroom,
  documented as such); `python3 context_budget.py` reports no file over its ceiling,
  resident total 26,360/34,000 green, `budget:protected` fence intact;
  `grep -c '^#### Learning '` = 770, matching the new relocation record's number; every
  Learning number cited by a new pointer verified present (382/433/435/475/477/478/479/
  495/506/533/544/547/549/554/586/587/669/740). No `.R` files touched → lint checklist N/A;
  no TDD phases (docs-only, S720–S724 precedent).

### 2026-09-19 · [ad hoc] S725 claim: `CLAUDE.md` reduction campaign — move Adaptations incident narratives to `PROJECT_LEARNINGS.md`, keep rules + pointers, bring the file under its 28,000 B ceiling *(in progress)*
- Owner-picked from the Phase 0 4-option picker. Phase 0: reconcile clean (0 undocumented
  commits on both frontiers, predicted 0 by S724 — measured 0); CI 10/10 green (still on
  the S719 push; the 27 unpushed commits have never seen CI); dashboard 96/100;
  context-budget reds by-design only (`CLAUDE.md` 43,348 B — this session's target);
  untracked files all long-standing/known. Stub + pending receipt ride this commit.

### 2026-09-19 · [ad hoc] S724 close-out sha: `HANDOFFS.md` receipt's `commit:` field set to the records commit `da52bd49`; carries its own entry, so no self-reference gap is left for Phase 0
- Final S724 commit. S724 total: 4 commits (claim `1bd5ef9c`, deliverable `eb3573bc`,
  records `da52bd49`, this one); ahead of `origin/master` by 27 including the 23
  pre-existing — push is the owner's call, and the 0-warning suite reaches CI only once
  pushed (CI's R-CMD-check runs this same suite). Expect 0 undocumented commits past the
  frontier at next Phase 0; measure it.

### 2026-09-19 · [ad hoc] S724 close-out: session records (SESSION_NOTES handoff + S723 evaluation 9/10, HANDOFFS receipt complete, `PROJECT_LEARNINGS.md` Learning 769) and post-append verification measurements
- **Trigger states, measured AFTER the handoff/receipt/learning text was appended**, all under
  `--budget-bytes 65536`: `SESSION_NOTES.md` 37,239 B, `HANDOFFS.md` 32,489 B, `CHANGELOG.md`
  41,926 B — none fires; no trim owed this session.
- **`context_budget.py` post-append run:** exactly the documented expected state — `CLAUDE.md`
  43,348 B / resident total over (red by design, remedy filed), `SESSION_NOTES.md` ok.
- **Close-out checklists:** lint DONE (3 touched test `.R` files, 0 lints, package loaded
  first); no new exports/statistics/Shiny features → NEWS/pkgdown/citation/tutorial/
  `a2interactive` N/A; BACKLOG item completed but names no GitHub issue → issue close-out N/A;
  CI green all session (on the S719 push), no CI break found; quality_ratchet cited in the
  receipt (0/0, manifest empty by design); runtime smoke N/A — test-only, no runtime surface.
- Sha self-reconcile commit follows with its own entry; expect 0 undocumented commits past the
  frontier at next Phase 0.

### 2026-09-19 · [ad hoc] S724 deliverable: baseline-warnings cleanup — suite warning count 40 → 0 via 16 `suppressWarnings()` wraps on triggering test calls; BACKLOG item removed (completed record here)
- **Inventory re-derived from a fresh full-suite run** (the item's own mandate — and it was
  right to demand it): the 40 warnings were NOT all one class. 37 are the `markerKinship()`
  NA-path (`R/markerKinship.R:131-139`, working as designed) across 14 blocks, all in
  `test_modMarkerGenetics.R` — the 3 known 5-warning blocks (2 cross-center + the issue #155
  candidate-parent block) plus **11** two-warning blocks from the `i152_roh_genotype.csv`
  fixture (pairs I1/I3, I2/I3; the item's stale list knew only 2 of these). The other 3 are
  out-of-class: `test_appServer_server.R` "wires child-module outputs into shared state"
  (2: `findGeneration` unplaced-id + empty-`max()` `-Inf`, from the 1-row toy pedigree) and
  `test_modPedigree_processing.R` "trimPedigree works with examplePedigree" (1:
  `makePedigreeMatingLayout()` 2-collision residual, the accepted render-quality warning).
- **Remedy:** owner picked "suppress all 16 sites" via `AskUserQuestion` (Learning 273(d) —
  suppress the incidental warning, not the branch; fixture-completion option declined). The
  16 wraps: 14 `setInputs(genotypeFile=...)` (2 centerA, 1 flaggedSlot, 11 i152_roh), 1
  `session$flushReact()` (appServer), 1 `setInputs(trimPedigree=TRUE)`. Test assertions and
  production code untouched; diff is exactly the 16 wraps.
- **Verification:** all 3 touched files individually 0 failed/0 error/0 warning; full clean
  regression read `blocks=2437 failed=0 error=0 skipped=184 warning=0` — block and skip
  counts equal the S718–S723 baseline exactly, warnings 40 → 0; `lintr::lint_package()` 0
  lints (package loaded first, Learning 224). The suite is back to the 0-warning state of
  CRAN v2.0.0 — the owner's "we had zero at last release" report (S487) that opened the item.
- No TDD phases (test-hygiene: no new tests, no assertion or production change; the remedy
  choice was the session's gate, posed with the inventory in hand).

### 2026-09-19 · [ad hoc] S724 claim: baseline-warnings cleanup — re-derive the warning-block inventory, then clean the ~40 markerKinship() NA-path suite warnings *(in progress)*
- The `BACKLOG.md:233` Housekeeping item (found S487, annotated S723; count 10 → 15 → 40,
  block list stale twice). Plan: fresh-suite inventory grouped by test block first; remedy
  (Learning 273(d) `suppressWarnings()` on triggering calls vs. fixture completion with
  expected-value re-verification) gated by `AskUserQuestion` with the inventory in hand.
  Owner picked this from the Phase 0 four-option picker. Stub + pending receipt in this commit.

### 2026-09-19 · [ad hoc] S723 close-out sha: `HANDOFFS.md` receipt's `commit:` field set to the records commit `77a832e0`; carries its own entry, so no self-reference gap is left for Phase 0
- Final S723 commit. S723 total: 5 commits (claim `3980cc31`, deliverable `d2a43162`,
  BACKLOG annotation `e2a91424`, records `77a832e0`, this one); ahead of `origin/master`
  by 23 including the 18 pre-existing — push is the owner's call, and the warning fix
  reaches other clones only once pushed. Expect 0 undocumented commits past the frontier
  at next Phase 0; measure it.

### 2026-09-19 · [ad hoc] S723 close-out: session records (SESSION_NOTES handoff + S722 evaluation 9/10, HANDOFFS receipt complete, `PROJECT_LEARNINGS.md` Learning 768) and post-append verification measurements
- **Trigger states, measured AFTER the handoff/receipt/learning text was appended**, all under
  `--budget-bytes 65536`: `SESSION_NOTES.md` 30,599 B (does not fire), `HANDOFFS.md` does not
  fire, `CHANGELOG.md` does not fire — no trim owed this session.
- **`context_budget.py` post-append run:** exactly the documented expected state — `CLAUDE.md`
  43,348 B / resident total over (red by design, remedy filed), `SESSION_NOTES.md` ok.
- **Close-out checklists:** lint DONE (touched `.R` file clean, package loaded first); no new
  exports/statistics/Shiny features → NEWS/pkgdown/citation/tutorial/`a2interactive` N/A (a
  roxygen comment on a `@noRd` internal changes no user-facing surface); no BACKLOG item
  completed and none names a GitHub issue → issue close-out N/A; CI green all session, no CI
  break found; quality_ratchet cited in the receipt (0/0, manifest empty by design).
- Sha self-reconcile commit follows with its own entry; expect 0 undocumented commits past the
  frontier at next Phase 0.

### 2026-09-19 · [ad hoc] S723: BACKLOG baseline-warnings item annotated — owner-reported RStudio test warnings triaged to it; block list marked stale (10 → 15 → 40), re-derive-the-inventory instruction added
- Mid-session owner report: `markerKinship()` "share no heterozygous locus" warnings at
  `test_modMarkerGenetics.R:1649`/`:1712` (issue #152 sequence-export-preview tests, S535's
  `i152_roh_genotype.csv` fixture, pair `'I2'`/`'I3'`) — 2 blocks not in the item's 3-block
  list. Source confirmed `R/markerKinship.R:135`, the documented NA path; suite green.
  Annotation only — no fix, per 1-and-done and the item's own "report, don't fix
  mid-session" lineage; the item stays READY (Effort S) for a dedicated cleanup session.

### 2026-09-19 · [ad hoc] S723: roxygen unresolved-link warning fixed — `R/makePedigreeDiagramData.R:2414` `[0, 1]` escaped to `\[0, 1\]`; `document()`/RStudio-Install runs now warning-free
- **Trigger:** the owner's RStudio-button Install (S722 follow-up A) succeeded end-to-end —
  verifying S722's fix on the live GUI surface — with this pre-existing `@noRd` cosmetic
  warning the only remaining output noise; owner picked this fix via `AskUserQuestion`.
- **Fix:** one comment-line edit — roxygen2's markdown mode parsed `[0, 1]` in
  `.bezierPointAt()`'s `@param t` prose as a link to a topic named "0, 1"; the escaped
  `\[0, 1\]` reads identically and resolves nothing. `@noRd`, so no `.Rd` output was ever
  affected — the warning was pure noise on every `document()`/Install run.
- **Verified:** (1) pre/post stash test — the warning reproduces on unfixed HEAD via
  `devtools::document(roclets = c("rd","collate","namespace"))` and is absent with the fix
  (the first post-fix check was re-run without `suppressMessages()`, which would have hidden
  the very warning line under test); (2) zero collateral — `man/`/`NAMESPACE` untouched,
  diff is exactly the one comment line; (3) lint clean on the touched file (package loaded
  first, Learning 224); (4) full clean regression read `blocks=2437 failed=0 error=0
  skipped=184 warning=40` — equals the S718–S722 baseline exactly.
- Mid-session owner report (markerKinship NA warnings in RStudio test runs) triaged to the
  existing BACKLOG Housekeeping baseline-warnings item — annotation follows as its own
  commit, not folded into this fix.

### 2026-09-19 · [ad hoc] S723 claim: fix the roxygen unresolved-link warning at `R/makePedigreeDiagramData.R:2414` (`[0, 1]` parsed as a markdown link to topic "0, 1") *(in progress)*
- Owner-picked via `AskUserQuestion` after reporting their RStudio-button Install (S722
  follow-up A): the Install now succeeds end-to-end (all 4 vignettes rebuilt including
  `a2interactive.Rmd`, `R CMD INSTALL` DONE) — S722's fix is verified on the live RStudio
  surface — with this pre-existing `@noRd` cosmetic warning the only remaining output noise.
  Planned fix: escape the brackets (`\[0, 1\]`). Docs-only roxygen comment edit, no TDD
  phases (S720–S722 precedent); lint close-out checklist applies (tracked `.R` file touched).

### 2026-09-19 · [ad hoc] Ledger trim: `CHANGELOG.md` → `docs/archive/CHANGELOG-through-2026-09-19.md` (35 record(s), 67,636 B → 33,652 B)

**Written by:** `methodology_trim.py` v1.5.0 — a tool action, not a session's judgment.
Moved the oldest **35** record(s) (2026-09-18 → 2026-09-19) out of [`CHANGELOG.md`](CHANGELOG.md) into
[`docs/archive/CHANGELOG-through-2026-09-19.md`](docs/archive/CHANGELOG-through-2026-09-19.md). Losslessness is asserted by L1 (records-zone concatenation), L2 (zone
pinning) and L3 (record partition), and is **re-derivable** — run [`docs/archive/CHANGELOG-through-2026-09-19.md.verify.sh`](docs/archive/CHANGELOG-through-2026-09-19.md.verify.sh)
rather than trusting a digest printed here. Live file 67,636 B → 33,652 B (−50.2%).

### 2026-09-19 · [ad hoc] S722 close-out sha: `HANDOFFS.md` receipt's `commit:` field set to the records commit `36990de9`; carries its own entry, so no self-reference gap is left for Phase 0
- Final S722 commit. S722 total: 5 commits (claim `f93a6ce2`, deliverable `10934a2f`, records
  `36990de9`, trim `34b0a10e`, this one); ahead of `origin/master` by 18 including the 13
  pre-existing — push is the owner's call, and the fix reaches other machines only once
  pushed. Expect 0 undocumented commits past the frontier at next Phase 0; measure it.

### 2026-09-19 · [ad hoc] S722 close-out: session records (SESSION_NOTES handoff + S721 evaluation 9/10, HANDOFFS receipt complete, `PROJECT_LEARNINGS.md` Learning 767) and post-append verification measurements
- **Trigger states, measured AFTER the handoff/receipt/learning text was appended**, all under
  `--budget-bytes 65536`: `SESSION_NOTES.md` 24,174 B (does not fire), `HANDOFFS.md` does not
  fire, **`CHANGELOG.md` FIRES** — the routine trim S721's heads-up predicted is owed and is
  executed as this close-out's own next commit (FM #28 reduction performed, not deferred).
- **`context_budget.py` post-append run:** exactly the documented expected state — `CLAUDE.md`
  43,348 B / resident total over (red by design, remedy filed), `SESSION_NOTES.md` ok.
- **Close-out checklists:** no `.R` files touched → lint N/A; no new exports/statistics/Shiny
  features → NEWS/pkgdown/citation/tutorial/`a2interactive` N/A (the fix is developer-workflow
  metadata, not a user-facing package change); the completed BACKLOG item named no GitHub
  issue → issue close-out N/A; CI green all session, no CI break found.
- **Report-only finding (not fixed, Learning 382 precedent):** `HANDOFFS.md` carries a
  pre-existing truncated duplicate S720 stub block (an unclosed `handoff` fence holding only
  session/date/status lines) directly above the real S720 receipt — a future session should
  repair it deliberately.
- Trim commit and sha self-reconcile commit follow, each with its own entry; expect 0
  undocumented commits past the frontier at next Phase 0.

### 2026-09-19 · [ad hoc] S722: RStudio-Install vignette-encoding fix DONE — `%\VignetteEncoding{UTF-8}` added to all 5 built vignettes; RStudio's exact roclet call now succeeds end-to-end (BACKLOG Up Next item removed this commit)
- **Fix:** one line added inside each `vignette:` block — `vignettes/a2interactive.Rmd`,
  `a3manual.Rmd`, `gvaConvergence.Rmd`, `simulatedKValues.Rmd` (the 4 tracked files).
  `vignettes/a3manual.md` (the item's 5th file) is gitignored (`.gitignore:18` — it is the
  `knitr::knitr` intermediate) and regenerates WITH the line from the `.Rmd`'s YAML —
  verified post-run at its line 14, so the durable fix is the 4 tracked files.
- **Mechanism verification (seconds, no rebuild):** `tools:::.getVignetteEncoding()` on
  `a2interactive.Rmd` returns `'non-ASCII'` on the pre-fix HEAD copy (exactly the state that
  trips `tools::buildVignette()`'s stop) and `'UTF-8'` on the fixed working copy.
- **End-to-end verification (RStudio's exact call):** `devtools::document(roclets = c('rd',
  'collate','namespace','vignette'))` exited 0 — all 4 `.Rmd` vignettes rebuilt including the
  previously-failing `a2interactive.Rmd` (its `.html` produced for the first time; its absence
  among the leftover build products was the failure fingerprint). `man/` untouched — zero
  collateral `.Rd` churn. One pre-existing, warning-only roxygen finding surfaced, unrelated
  to this diff: `R/makePedigreeDiagramData.R:2414`'s `@param t ... in [0, 1].` parses as a
  markdown link to topic "0, 1" (the function is `@noRd`, so no rendered output is affected)
  — reported, not fixed (Learning 382 precedent).
- **Regression read:** `blocks=2437 failed=0 error=0 skipped=184 warning=40` — equals the
  S718–S721 baseline exactly.
- **Cleanup:** the 8 gitignored in-place build products (`*.html`/`*.R` × 4 vignettes) removed
  from `vignettes/` per the item's own verification recipe.
- **Owner follow-up owed (from the item):** restart R, Install from the RStudio button, re-run
  the appServer tests; if anything still fails, capture that output as its own finding (most
  likely collateral of the stale installed copy, already refreshed by S721's terminal install).

### 2026-09-19 · [ad hoc] S722 claim: RStudio-Install vignette-encoding fix (BACKLOG Up Next item, filed post-close-out S721) — stub + pending receipt + this entry *(in progress)*
- Deliverable: add `%\VignetteEncoding{UTF-8}` to the 5 built vignettes; verify with RStudio's
  exact `devtools::document(roclets = c('rd','collate','namespace','vignette'))` call plus the
  standard clean regression read. Close-out records the rest.

### 2026-09-19 · [ad hoc] S721 post-close-out: owner-reported RStudio Install break root-caused (vignette-encoding defect, dormant since S541 `95609eeb`) and DEFERRED to a `BACKLOG.md` Up Next item per owner direction — no fix applied
- Owner reported "appserver tests failing in RStudio," then "a simple Install fails in
  RStudio," after S721's close-out. Diagnosis (read-only, plus two terminal installs as
  reproduction attempts): RStudio's Install runs `devtools::document()` with the `vignette`
  roclet (`.Rproj` `PackageRoxygenize`), whose per-file `tools::buildVignette()` call has no
  `DESCRIPTION` `Encoding:` fallback — `a2interactive.Rmd`'s non-ASCII `r²` (since S541,
  2026-08-12) + no `%\VignetteEncoding{UTF-8}` declaration in any vignette = every
  RStudio-button Install failing since then, while terminal/CI/`R CMD check` paths stay green
  via `tools::buildVignettes()`'s package-encoding fallback. Unrelated to S721's `Suggests:`
  change. Owner directed the fix to its own future session; filed with full root cause,
  fix options, verification recipe, and the appServer-tests follow-up (likely stale-installed-
  copy collateral; the installed copy was refreshed by this diagnosis's terminal
  `devtools::install()`). Side effect kept: that refreshed installed copy.

### 2026-09-19 · [ad hoc] S721 close-out sha: `HANDOFFS.md` receipt's `commit:` field set to the records commit `32c647c1`; carries its own entry, so no self-reference gap is left for Phase 0
- Final S721 commit. S721 total: 5 commits (claim `05943cd5`, owner-requested backlog item
  `ede5289e`, deliverable `cd748874`, records `32c647c1`, this one); ahead of `origin/master`
  by 12 including the 7 pre-existing — push is the owner's call. Expect 0 undocumented commits
  past the frontier at next Phase 0; measure it.

### 2026-09-19 · [ad hoc] S721 close-out: session records (SESSION_NOTES handoff + S720 evaluation 9/10, HANDOFFS receipt complete, `PROJECT_LEARNINGS.md` Learning 766) and post-append verification measurements
- **Trigger states, measured AFTER the handoff/receipt/learning text was appended**, all under
  `--budget-bytes 65536`: `SESSION_NOTES.md` 17,138 B, `HANDOFFS.md` 19,135 B,
  `CHANGELOG.md` 60,188 B (before this entry) — none fire. **Heads-up:** `CHANGELOG.md` is
  within ~5 KB of the trigger and will likely fire within a session or two; the trim then owed
  is routine (`--budget-bytes 65536`). No FM #28 reduction owed this session — stated
  explicitly rather than left unsaid.
- **`context_budget.py` post-append run:** exactly the documented expected state — `CLAUDE.md`
  43,348 B / resident total over (red by design, remedy filed), `SESSION_NOTES.md` ok.
- **Close-out checklists:** no `.R` files touched → lint N/A; no new exports/features →
  NEWS/pkgdown/citation/tutorial/`a2interactive` N/A; the completed BACKLOG item named no
  GitHub issue → issue close-out N/A; CI green all session, no CI break found. Verification
  evidence (full regression at exact baseline, `devtools::check()` 0 new findings) recorded in
  the deliverable entry below.
- Sha self-reconcile commit follows with its own entry; expect 0 undocumented commits past the
  frontier at next Phase 0.

### 2026-09-19 · [ad hoc] S721: `Suggests:` audit DONE — 6 entries relocated/removed from `DESCRIPTION`, new `Config/Needs/dev` group, `renv.lock` re-snapshotted; 0 new `devtools::check()` warnings/notes (BACKLOG Housekeeping item removed this commit)
- **Audit method:** grep-based inventory of all 22 `Suggests:` entries across `R/`, `tests/`,
  `vignettes/` (real vignettes vs `articles/` distinguished), `man/`, `inst/`, `data-raw/`,
  with every thin hit READ for code-vs-comment before classification.
- **Stayed (16, each with a real load site):** chromote/shinytest2/mockery/testthat/withr/
  htmltools/htmlwidgets/spelling (test code), pkgdown (**real test code** —
  `pkgdown::as_pkgdown()` in `test_pkgdown_reference_config.R:25`; the item's own
  "pkgdown-belongs-in-Config/Needs/website" suspicion REFUTED), dplyr (roxygen `@examples` +
  tests), kinship2 + shinyBS (package `R/` code), knitr (`VignetteBuilder` + engines),
  rmarkdown (vignette engines/outputs), **markdown (`a3manual.{Rmd,md}` use the
  `knitr::knitr` engine, which renders through the markdown package — NOT unused)**,
  kableExtra (`gvaConvergence.Rmd`/`simulatedKValues.Rmd`).
- **Removed (6, owner-ratified via two `AskUserQuestion` gates, both recommended options
  picked):** devtools + roxygen2 → new `Config/Needs/dev: devtools, roxygen2` (their only
  tests/vignettes hits are comments and `eval = FALSE` install instructions that tangle to
  commented lines, `vignettes/a3manual.R:5-10`; both also remain in
  `Config/renv/profiles/dev/dependencies`; roxygen2's `(>= 8.0.0)` constraint superseded by
  `Config/roxygen2/version: 8.0.0`); quarto → dropped (already `Config/Needs/website`;
  `pkgdown.yaml` already passes `needs: website`, CI-safe); grid + png + shinyWidgets →
  deleted outright (zero uses anywhere; vestiges of `c1138a6e`/`22f5914d`-era features).
- **`renv.lock`:** `renv::snapshot(dev = TRUE)` per the standing CLAUDE.md rule and the S637
  precedent (`526c7fec`) — 21 packages dropped (the 5 removed + transitive closures incl.
  usethis/pak/rcmdcheck/profvis); `renv::status(dev = TRUE)` now "No issues found". Matches
  the S615 covr precedent (covr likewise absent from the lock, CI installs it itself).
- **Verification:** full clean regression read `blocks=2437 failed=0 error=0 skipped=184
  warning=40` — equals the S718–S720 baseline exactly. Full `devtools::check()` (21m52s):
  0 errors; all dependency gates OK (unstated deps in examples/tests/vignettes, deps in R
  code, vignette rebuild incl. the `knitr::knitr`→markdown path); the 1 WARNING
  (non-portable `inst/extdata/reference/~$e Compounding Loop.html`) and 1 NOTE (top-level
  `scratchpad/`) both name UNTRACKED working-tree clutter present since before this session
  (in the session-start `git status`), unreachable by this diff — **0 new warnings/notes**.

### 2026-09-19 · [ad hoc] S721: filed owner-requested BACKLOG item — measure package growth attributable to the pedigree-drawing feature (rough ±20% estimate sufficient)
- Owner request arrived mid-session (during the `Suggests:` audit's research phase); recorded
  as a `BACKLOG.md` Housekeeping item (READY, Effort S) for a future session, not acted on
  now (1-and-done: this session's deliverable remains the `Suggests:` audit).

### 2026-09-19 · [ad hoc] S721 claim: `Suggests:` audit (BACKLOG Housekeeping item, owner-picked via `AskUserQuestion`) — SESSION_NOTES stub + pending HANDOFFS receipt committed *(in progress)*
- Phase 0 reconcile was clean: 0 undocumented commits past both frontiers (`ba09899c`), exactly
  as S720's close-out entry predicted. CI 10/10 green; dashboard 96/100; `context_budget.py`
  showed only the documented by-design reds (no new findings).

### 2026-09-19 · [ad hoc] S720 close-out sha: `HANDOFFS.md` receipt's `commit:` field set to the records commit `7e8ebc5f`; carries its own entry, so no self-reference gap is left for Phase 0
- Final S720 commit. Post-trim state at write time, all under `--budget-bytes 65536`:
  `SESSION_NOTES.md` 10,295 B, `HANDOFFS.md` ~15 KB, `CHANGELOG.md` ~55 KB — none firing.
  Expect 0 undocumented commits past the frontier at next Phase 0; measure it. S720 total:
  6 commits (claim `572562f1`, adoption `bc6be1d0`, SESSION_NOTES trim `c079c27a`, records
  `7e8ebc5f`, HANDOFFS trim `d05e8573`, this one); ahead of `origin/master` by 7 including
  S719's pre-existing `c0002e04` — push is the owner's call.

### 2026-09-19 · [ad hoc] Ledger trim: `HANDOFFS.md` → `docs/archive/HANDOFFS-through-2026-09-19.md` (11 record(s), 66,229 B → 14,869 B)

**Written by:** `methodology_trim.py` v1.5.0 — a tool action, not a session's judgment.
Moved the oldest **11** record(s) (2026-09-18 → 2026-09-19) out of [`HANDOFFS.md`](HANDOFFS.md) into
[`docs/archive/HANDOFFS-through-2026-09-19.md`](docs/archive/HANDOFFS-through-2026-09-19.md). Losslessness is asserted by L1 (records-zone concatenation), L2 (zone
pinning) and L3 (record partition), and is **re-derivable** — run [`docs/archive/HANDOFFS-through-2026-09-19.md.verify.sh`](docs/archive/HANDOFFS-through-2026-09-19.md.verify.sh)
rather than trusting a digest printed here. Live file 66,229 B → 14,869 B (−77.5%).

### 2026-09-19 · [ad hoc] S720 close-out: session records (SESSION_NOTES handoff + S719 evaluation 9/10, HANDOFFS receipt complete) and the post-append verification results
- **Trigger states, measured AFTER the handoff/receipt text was appended** (the S718 lesson —
  a pre-append check certifies the wrong content): under `--budget-bytes 65536`,
  `SESSION_NOTES.md` 10,295 B does not fire, `CHANGELOG.md` 53,422 B (before this entry) does
  not fire, **`HANDOFFS.md` 66,229 B FIRES** — the receipt pushed it over, exactly as the
  handoff's gotcha (4) anticipated. Its trim follows this commit (dry run already clean:
  L1–L3 OK, 11 of 12 records to `docs/archive/HANDOFFS-through-2026-09-19.md`, 66,229 →
  14,869 B, S720 receipt retained) — FM #28 close-out reduction, not a second deliverable.
- **`context_budget.py` post-append run:** exactly the documented expected state —
  `CLAUDE.md` 43,348 B / resident total over (red by design, remedy filed), `SESSION_NOTES.md`
  10,295 B ok, both sync-drift checks ok.
- **Full suite (close-out insurance; zero package files touched):** blocks=2437 failed=0
  error=0 skipped=184 warning=40 — equals the S718/S719 baseline exactly. Close-out checklists:
  no `.R` files → lint N/A; no exports/features → NEWS/pkgdown/citation/tutorial N/A; completed
  BACKLOG item removed in the adoption commit (its record is the adoption entry below).
- Sha self-reconcile commit follows with its own entry, so expect 0 undocumented commits past
  the frontier at next Phase 0.

### 2026-09-19 · [ad hoc] Ledger trim: `SESSION_NOTES.md` → `docs/archive/SESSION_NOTES-through-2026-09-19.md` (21 record(s), 79,738 B → 3,500 B)

**Written by:** `methodology_trim.py` v1.5.0 — a tool action, not a session's judgment.
Moved the oldest **21** record(s) (2026-09-17 → 2026-09-19) out of [`SESSION_NOTES.md`](SESSION_NOTES.md) into
[`docs/archive/SESSION_NOTES-through-2026-09-19.md`](docs/archive/SESSION_NOTES-through-2026-09-19.md). Losslessness is asserted by L1 (records-zone concatenation), L2 (zone
pinning) and L3 (record partition), and is **re-derivable** — run [`docs/archive/SESSION_NOTES-through-2026-09-19.md.verify.sh`](docs/archive/SESSION_NOTES-through-2026-09-19.md.verify.sh)
rather than trusting a digest printed here. Live file 79,738 B → 3,500 B (−95.6%).

### 2026-09-19 · [ad hoc] S720: `context_budget.py` ADOPTED with honest ceilings (owner-ratified via `AskUserQuestion`, over freeze-at-current and delete); trim budget SETTLED at the old 65,536 B cadence (over the 196,608 B default and a one-off trim)
- **Evaluation findings that drove the decision:** `CLAUDE.md` (41,622 B pre-edit) is the one
  Phase-0 mandated read nothing gated — over the seed's 28,000 B ceiling and its own stated
  ~25 KB target, invisible to the dashboard (under the 56,750 B one-read cap) and structurally
  out of the trimmer's reach. `--calibrate` on this project's transcripts was REJECTED: 0.60
  B/token with a −6,015-token intercept (n=119, R²=0.73), physically implausible/confounded;
  the dashboard's measured densest density (2.27 B/token) adopted instead. Seed misfits fixed:
  `SESSION_NOTES.md` structure patterns rewritten for this file's real layout (the seed's
  `^## ` expect_min 2 was instrument-failed here; note — `max: 0` is a literal bound, not a
  disable), `max_lines` 400→1,000 (aligned to the 65,536 B cadence at the measured ~69 B/line,
  eliminating a standing two-trigger disagreement), `max_bytes` set to the SAME 65,536 as the
  trimmer cadence so a red means a trim is owed; the unmappable `LEARNINGS.md` entry dropped
  (`PROJECT_LEARNINGS.md`, 2,888,991 B, is on-demand — a whole-file ceiling is the wrong unit).
- **Executed:** `.context-budget.json` rewritten with derivations in `_` keys; `budget:protected`
  fence added around `CLAUDE.md`'s Project Overview (tool-verified present); per-clone no-growth
  pre-commit hook installed (`install-hook`; refuses only growth of an over-ceiling file);
  Phase 0 check + red-by-design expectations recorded in `CLAUDE.md` (Additional Phase 0 steps);
  the S719 "open owner decision" trigger-budget paragraph resolved (`--budget-bytes 65536` on
  every run); `BACKLOG.md` item removed (this entry is its completed record) and the successor
  "CLAUDE.md reduction campaign" item filed (READY, M). `--selftest` passes; post-config run
  shows exactly the intended reds: `CLAUDE.md`/resident (by design, until the reduction lands)
  and `SESSION_NOTES.md` (the owed trim, executed next this session). Sync-drift checks: both
  `ok`. History file stays gitignored (S719 decision, kept). **This commit itself grows
  `CLAUDE.md`, so it lands via `--no-verify` — the hook's first recorded bypass, legitimate
  growth ratified by the adoption itself.** Dashboard note: its HIGH flag for `SESSION_NOTES.md`
  says "the trimmer answers NO_CONFIG" — untrue under this project's local trimmer extension
  (Class A, config present); the dashboard hardcodes stock-trimmer classes by design, so the
  flag text overstates, though the >one-read-cap fact it flags is real until the trim.

### 2026-09-19 · [ad hoc] S720 claim: `context_budget.py` adoption evaluation + trim-budget decision (`BACKLOG.md:119`) *(in progress)*
- Owner-picked via `AskUserQuestion` at Phase 0 (over the `Suggests:` audit, the
  package-split disposition, and the chromote research item). Phase 0 reconcile found 0
  undocumented commits past both frontiers (S719's gotcha predicted 0; measured 0); CI
  10/10 green on `4565c39d`; dashboard 96/100. Stub + pending `HANDOFFS.md` receipt ride
  this commit. Docs/process tooling — no TDD phases; close-out adds its own entries.

### 2026-09-19 · [ad hoc] S719 push to `origin/master` DONE (owner: "push") — 16 commits (`4cfe2dad..4565c39d`), all 4 on-push CI workflows green on the pushed head
- Pushed after `git fetch` confirmed 16 ahead / 0 behind (only `gh-pages`, CI's own branch,
  had moved). The 16 are S718's 5 commits plus S719's 11. CI on `4565c39d`, watched to
  completion: `lint` 4m39s, `test-coverage` 10m36s, `pkgdown` 18m08s, `R-CMD-check` 33m02s
  (run ids 35466135572 / 35466135534 / 35466135549 / 35466135548), all `completed success`;
  `R-CMD-check` green on all 5 platforms (ubuntu release/devel/oldrel-1, macOS release,
  Windows release). This is the first CI validation of P10's build patterns and new root
  files; the handoff's "estimate green" is now a measurement (`R-CMD-check` runs
  `error-on: "warning"`, so no warning was raised). Only this entry's own commit is left
  unpushed — the owner's call.

### 2026-09-19 · [ad hoc] S719 close-out sha: `HANDOFFS.md` receipt's `commit:` field set to the records commit `a095f4be`; carries its own entry, so no self-reference gap is left for Phase 0
- Under the current rules every commit carries its own entry, so this self-reconcile commit is
  recorded here instead of being left for the next Phase 0 to backfill (S717/S718's recurring
  1-commit shape). **Count note (correction of the close-out entry above, which is not edited):**
  that entry's "37 → 45 / 24 → 32" was measured before this entry existed; the final counts are
  `### ` 46 and the anchored audit 33 (+9 from the claim commit, all `[ad hoc]`). The handoff's
  gotcha predicting a 1-commit gap at next Phase 0 is updated to expect 0.

### 2026-09-19 · [ad hoc] S719 close-out: BL-57 P10 DONE for this project — session records (SESSION_NOTES handoff + S718 evaluation 8/10, HANDOFFS receipt complete) and the verification results
- **Verification:** `bin/status` reads `present` for `CHANGELOG.md` and `HANDOFFS.md` (only
  `methodology_trim.py` stays `locally modified`, by design). §9.8 with bounds `62 117
  HANDOFFS.md` printed *only the block changed*; the `CHANGELOG.md` step is insertion-only
  (13 ins / 0 del, all 540 old lines in order). `methodology_trim.py --cut 1 --force` (dry run)
  prints `L1_OK`–`L3_OK` on all three ledgers (43 / 11 / 20 records). `R CMD build` ships none of
  the tooling or ledger files; the full suite equals the S718 baseline (2,437 blocks, 0 failed,
  0 error, 184 skipped, 40 warning, 4.3 min). `quality_ratchet.py --run`: 0/0 gates declared.
  Entry counts: `### ` 37 → 45 and the anchored audit 24 → 32 from the claim commit, i.e. +8 =
  the entries this phase adds (steps 2–7, the BACKLOG follow-through, this one), all `[ad hoc]`,
  none using bare `[BL]`.
- **Correction to S718's entry (a committed entry is never edited, so it is named here):** S718's
  close-out entry and handoff say all three trim-managed ledgers were "verified trigger-not-firing
  at close-out". On the committed close-out head (`312996b0`) trimmer 1.1.2 reports
  `SESSION_NOTES.md` FIRES (70,138 B against 65,536 B; re-run in an isolated worktree this
  session); `HANDOFFS.md` and `CHANGELOG.md` did not fire. Likely the check ran before the
  handoff text was appended — an estimate, not recorded. No consequence here: the sync replaced
  the trimmer and its budget.
- **Deviations from the launch prompt's facts:** the source version printed `v3.7-964-gce14b3f`
  (one docs-only fork commit past the prompt's `c20d6ab`, touching no distributed file);
  `bin/_manifest.py` lists `methodology_trim.py` at `:50`, not `:45`; the claim entry lacks the
  *(in progress)* marker the newly synced rules ask for (they arrived after the claim). FM #28
  reduction: none this session — stated, not silent; a `SESSION_NOTES.md` trim is left as an
  owner decision (`BACKLOG.md:119`). No new learning appended (routine application of a decided
  route; the durable knowledge is in `CLAUDE.md:277`, not a row). No push (owner's call).

### 2026-09-19 · [ad hoc] S719 BL-57 P10 follow-through: `BACKLOG.md`'s `context_budget.py` evaluation item re-scoped — its "never adopted, `bin/status` reports missing/absent" premise was made false by the sync
- The item (found S617) said the tool and its seed config were absent from this project. The S719
  forced sync installed both (plus `quality_ratchet.py` and an empty `.quality-gates.json`), so the
  item now records the real state — installed, build-ignored, uncalibrated, never run; seed ceilings
  are the fork's own and `CLAUDE.md` is far over the seed's — and the remaining decision
  (calibrate and adopt, or delete; whether to track `.context-budget-history.jsonl`). It also
  carries the `methodology_trim.py` byte-budget decision (1.5.0 default 196,608 B vs 1.1.2's
  65,536 B; S719 took the default) so the owner sees it in one place. Text edit in place; no item
  added or removed (the S686 removal convention is for *completed* items).

### 2026-09-19 · [ad hoc] S719 BL-57 P10 step 7: `CLAUDE.md` updated — `methodology_trim.py` checklist corrected, ledger legacy forms and the trigger-budget choice recorded
- The `methodology_trim.py` local-customization paragraph said the tool was project-owned and
  that a sync "never reaches" it; the fork's `main` now distributes it (`bin/_manifest.py`
  lists `starter-kit/methodology_trim.py`) and the S719 sync rewrote it (1.1.2 → 1.5.0). It
  now states the actual per-sync procedure: save the extension patch, `--force`, re-apply,
  confirm `L1_OK`–`L3_OK` (the re-apply commit `63b3286f` is itself the patch). A new
  paragraph records the two legacy ledger shapes left as written — 13 bare `[BL]` headings
  the anchored audit does not count, and the empty `## 2026-08` above `## 2026-09` — plus
  the rule for new entries. Budget: the tool default (196,608 B) is taken instead of the old
  65,536 B; measured at this commit `SESSION_NOTES.md` is 71,192 B (fires only under the old
  budget), `HANDOFFS.md` 57,509 B and `CHANGELOG.md` 43,018 B (under both). Left as an open
  owner decision in the handoff. Each claim in the new text was checked against a run
  first (plain dry-run sync exits 2 on `methodology_trim.py`; bare-`[BL]` count is 13).

### 2026-09-19 · [ad hoc] S719 BL-57 P10 step 6: `HANDOFFS.md` brought to handoffs-format 2 — its `## Size, and when to archive` section replaced with the current seed's
- Old `:62`–`:117` (56 lines) replaced by the seed's `:89`–`:148` (56 lines; its `:91` is the
  `handoffs-format: 2` marker, now at `:64`); 17 insertions, 13 deletions. Everything else is
  unchanged: front matter, the four-backtick worked example, the shard pointer blocks, the
  regenerated "currently holds 2 receipt(s)" sentence and every receipt. The new section
  states no size of its own and defers to the trimmer's trigger, which is the reason the
  budget is left at the tool's default. The seed also carries two later sections (`Three
  files, three questions, one shared key`; `Citing the gate run`) and a longer front matter;
  the P10 steps do not ask for them, so they are not brought across.

### 2026-09-19 · [ad hoc] S719 BL-57 P10 step 5: `CHANGELOG.md` brought to ledger-format 2 — the current seed's pointer-and-marker paragraph inserted
- Three lines (the seed's "**The rules** … ledger-format: 2 — keep this marker; `bin/status`
  reads it.", copied from `starter-kit/CHANGELOG.md:10-12`) plus one blank, placed after the
  intro and its Note and before `## 2026-08`. A pure insertion; no existing line changed.
  The rules block that once lived in this file was already in the frozen shard
  `docs/archive/CHANGELOG-through-2026-09-17.md` (`## How to add an entry`) after S700/S710's
  trims, so it stays there. The rules now live in the synced
  `docs/methodology/FRAMEWORK_APPARATUS.md#the-action-ledger`.

### 2026-09-19 · [ad hoc] S719 BL-57 P10 step 4: re-apply the local `SESSION_NOTES.md` extension to the synced `methodology_trim.py` (v1.5.0), 49 lines
- `git apply` of the patch saved before the sync (`git diff 18d8e3c7 HEAD --
  methodology_trim.py`; `--check` passed first): `_session_notes_date` plus the
  `"SESSION_NOTES.md": LedgerSpec(...)` entry, 49 lines added, 0 removed. Before: `--check` on
  `SESSION_NOTES.md` answered `NO_CONFIG`. After: it reads the ledger, and
  `--file SESSION_NOTES.md --cut 1 --force` (dry run) prints `L1_OK`, `L2_OK`, `L3_OK`, 20
  records, would archive 19, 71,192 B → 4,018 B. The file stays locally modified against
  canonical, so every later plain sync refuses it until the framework settles that (BL-32
  in the fork); `CLAUDE.md` already prescribes the re-add. Byte budget is now the tool's
  default 196,608 B (was 65,536 B under 1.1.2) — recorded in `CLAUDE.md` in the `CLAUDE.md`
  commit of this phase.

### 2026-09-19 · [ad hoc] S719 BL-57 P10 step 3: forced framework sync from the methodology fork (`v3.7-964-gce14b3f`, local source) — 13 files written, 2 created
- `python3 ../methodology/bin/sync --force .` (forced because `methodology_trim.py` carried
  this project's 49-line `SESSION_NOTES.md` extension, which the plain sync refuses to
  overwrite). Written: `SESSION_RUNNER.md`, `FRAMEWORK_LEARNINGS.md`, `SAFEGUARDS.md`,
  `BOOTSTRAP.md`, `methodology_dashboard.py`, `methodology_trim.py` (1.1.2 → 1.5.0),
  `context_budget.py`, `quality_ratchet.py`, `docs/methodology/{ITERATIVE_METHODOLOGY,
  HOW_TO_USE,FRAMEWORK_APPARATUS}.md`, `docs/methodology/workstreams/{DEVELOPMENT,AUDIT}_WORKSTREAM.md`;
  created `.context-budget.json`, `.quality-gates.json`. The four seeds
  (`SESSION_NOTES.md`, `CHANGELOG.md`, `HANDOFFS.md`, `ROADMAP.md`) were left as they are.
  The extension is deliberately absent from this commit; it is re-applied in the next one
  from the patch saved before the sync (`git diff 18d8e3c7 HEAD -- methodology_trim.py`).

### 2026-09-19 · [ad hoc] S719 BL-57 P10 step 2: build and ignore files for the tools the sync installs — 6 `.Rbuildignore` patterns, 2 `.gitignore` entries
- `.Rbuildignore`: `context_budget.py`, `quality_ratchet.py`, `.context-budget.json`,
  `.quality-gates.json` (the sync installs them) and `.context-budget-history.jsonl`,
  `.quality-gates-results.json` (written when the tools run) — none matched an existing
  pattern, so `R CMD check` would have noted them. Committed before the sync so no commit
  ships the new files into the package build. `FRAMEWORK_APPARATUS.md` is covered by
  `^docs$`. `.gitignore`: both run-time outputs ignored, matching this project's own
  `dashboard_history.jsonl`; the methodology repo tracks `.context-budget-history.jsonl`
  for its growth-run trigger, which this project has not adopted (BACKLOG carries the
  `context_budget.py` evaluation), so that choice is left to the evaluation.

### 2026-09-19 · [ad hoc] S719 claim: BL-57 P10 — bring this project's ledgers to the current methodology's rules (operator-picked via `AskUserQuestion` at Phase 0)
- Docs/process session, no TDD phases, no push. Source is the methodology
  fork's `changelog-rules-contradictions-plan.md` (P10 row) and its launch
  prompt; route decided by the operator at the fork's S194: forced sync, then
  re-apply the local `SESSION_NOTES.md` extension to `methodology_trim.py` in
  its own commit. Planned commits: build/ignore files, forced sync, extension
  re-apply, `CHANGELOG.md` migration, `HANDOFFS.md` migration, `CLAUDE.md`,
  close-out. Stub + pending receipt committed with this entry. (Tag is
  `[ad hoc]` because `BL-57` is the methodology fork's backlog id, not this
  project's.)

### 2026-09-19 · [ad hoc] Backfilled (reconcile-on-read): undocumented commit `312996b0` — S718's close-out self-reference commit (recorded the records-commit sha in its own `HANDOFFS.md` receipt, 1 line changed), the documented recurring 1-commit shape; backfilled by the next session's Phase 0 reconcile

