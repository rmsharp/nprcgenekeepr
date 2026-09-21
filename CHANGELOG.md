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

**Archived 31 record(s), 2026-09-19 → 2026-09-19** into [`docs/archive/CHANGELOG-through-2026-09-19-2.md`](docs/archive/CHANGELOG-through-2026-09-19-2.md) — same format, same order, frozen.
Losslessness is proved by [`docs/archive/CHANGELOG-through-2026-09-19-2.md.verify.sh`](docs/archive/CHANGELOG-through-2026-09-19-2.md.verify.sh), which re-derives L1/L2/L3 from git; run it rather
than trusting this sentence. Written by `methodology_trim.py` v1.5.0.

### 2026-09-21 · [ad hoc] S751 close-out: session records (handoff, S750 evaluation 9/10, receipt complete, self 9/10, Learning 774)
- `SESSION_NOTES.md` handoff written (S750 evaluation: 9/10 — every
  checked claim held exactly: 6 unpushed, 0 undocumented on both
  frontiers, growth run 27/10, byte-identical ratchet citation, current
  anchors after re-grep; the transient-504 CI flake was not a knowable
  claim). `HANDOFFS.md` receipt complete. `PROJECT_LEARNINGS.md` Learning
  774 appended: diagnose a red R-CMD-check at failed-STEP granularity
  before reacting — setup-step 504s are infrastructure; `gh run rerun
  --failed` keeps run id + headSha so `--commit` structural verification
  is unchanged; the both-attempts wall duration is not comparable to the
  single-attempt band. Reduction check (FM #28): none this session — no
  mandated-read file got smaller (said plainly). Runtime smoke: n/a —
  docs-only push; package evidence is CI green on the pushed sha across
  all 5 R-CMD-check platform jobs. Ratchet at pushed HEAD `a7613044`:
  1/1 pass · 0 fail · 0 unmeasured · results e7499ae4e4a9 · manifest
  aa983075d6a2 (3,489,091 B ≤ 5,000,000 B, read from the results file;
  −20 B vs S750 is build-metadata noise — touched files `.Rbuildignore`d).

### 2026-09-21 · [ad hoc] S751 deliverable: pushed `589cf73c..a7613044` (7 commits, ALL docs-only); all 4 workflows green ON THE PUSHED SHA after one transient-infra rerun
- Push: 7 commits (6 carried S750/S749 records + the claim riding the
  push); 0 unpushed confirmed by recount. Filter smoke-tested before
  arming (`gh run list --commit <full-40-char-sha>`, `headSha` echoed).
  **First attempt: R-CMD-check `failure` — transient infrastructure, not
  the package:** failures confined to setup steps (windows
  `setup-pandoc@v2`: pandoc 3.8.3 download HTTP 504 ×2 then fatal; macos
  `setup-r@v2`: gfortran download 504 ×2 then fatal; 14:49–14:50 UTC);
  all 3 ubuntu check jobs passed; `--log-failed` showed zero package
  output on the failed platforms. Fixed as found per the S636 CI-break
  convention (no GitHub issue): `gh run rerun 35614709050 --failed` —
  same run id + headSha, ubuntu successes retained; rerun `success`.
  Final structural verification: all 4 `completed success` with `headSha`
  = `a761304410c079847d09de422cba73814574408b` echoed per run — lint
  4m56s (35614708951), pkgdown 6m52s (35614708967), test-coverage 10m3s
  (35614708970), R-CMD-check 41m49s wall across both attempts
  (35614709050). CI is now current through `a7613044`.

### 2026-09-21 · [ad hoc] S751 claim: push to `origin/master` + CI verification (in progress)
- Routine operational pick (S726–S749 precedent), owner-picked via the
  Phase 0 picker over BACKLOG compression, inst/doc slimming, and
  kinship2-standalone. 6 unpushed docs-only commits measured at Orient
  (`9410a558..1f8a32f0` + S750's four); this claim rides the push
  (7 expected). CI current through `589cf73c`, no code changed since —
  records-currency, not code verification. Close-out records the rest.

### 2026-09-21 · [ad hoc] S750 close-out sha: `HANDOFFS.md` receipt's `commit:` field set to the records commit `5e280761`; carries its own entry, so no self-reference gap is left for Phase 0
- Final S750 commit. S750 total: 4 commits (claim `aa029ae6`, deliverable
  `cc6d5d6b`, records `5e280761`, this one). Ahead of `origin/master` by 6
  after close-out, ALL docs-only; CI is current through `589cf73c` and no
  code has changed since. Expect 0 undocumented commits past the frontier
  at next Phase 0; measure it.

### 2026-09-21 · [ad hoc] S750 close-out: session records (handoff, S749 evaluation 8/10, receipt complete, self 9/10, Learning 773)
- `SESSION_NOTES.md` handoff written (S749 evaluation: 8/10 — every
  measured claim held exactly (2 unpushed, clean frontiers, growth run
  26/10, byte-identical ratchet citation, current anchors), but next step
  (A) relayed the WORDLIST item's stale premise unverified — a one-grep
  computable claim, Learning #13's rule). `HANDOFFS.md` receipt complete.
  `PROJECT_LEARNINGS.md` Learning 773 appended: sweep-style fixes silently
  satisfy BACKLOG items they never looked at — re-measure an item's
  premise as the first research step; grep `BACKLOG.md` after any bulk
  fix; also records the WORDLIST case-insensitive-ordering fact.
  Reduction check (FM #28): REAL — `BACKLOG.md` net −39 lines. Runtime
  smoke: n/a — docs-only; the package-level evidence is this session's
  full `devtools::check()` (0 errors / 0 warnings / 0 notes, tests OK).
  quality_ratchet at `cc6d5d6b`: 1/1 pass · 0 fail · 0 unmeasured ·
  results ab63a9bfe821 · manifest aa983075d6a2 (3,489,111 B ≤ 5,000,000 B,
  read from the results file — the run table rounded to 3.48911e+06; the
  +71 B vs S749 is build-metadata noise, all touched files being
  `.Rbuildignore`d).

### 2026-09-21 · [ad hoc] S750 deliverable: WORDLIST 10-word drift Housekeeping item CLOSED as already-satisfied — `devtools::check()` verified 0 errors / 0 warnings / 0 notes
- The item (found S465, count grown S490/S642) was stale: all 10 words were
  already in `inst/WORDLIST` — 8 of them (`sibship`, `waypoint`,
  `duplicateToReal`, `js's`, `makePedigreeMatingLayout`, `discoverable`,
  `js`, `unshaded`) hand-added 2026-08-12 by `250b33d0` ("hand-add 76
  verified words + permanent guard test"), `vis` earlier (`562536cf`), and
  `comparator` 2026-09-08 by S680's `741b2764`. No session closed the item;
  S748's forward-carry updated its expectation without noticing. Closure
  evidence, all measured this session: (1) all 10 words present
  (`grep -cx` = 1 each); (2) fresh
  `spelling::spell_check_package(vignettes = TRUE)` clean ("No spelling
  errors found"); (3) `test_wordlist_coverage.R` guard passes
  (`NOT_CRAN=true`); (4) full `devtools::check()`: 0 errors / 0 warnings /
  0 notes (5m34s) — exceeds the item's "vignette-engine note only"
  criterion (even that note is gone), with the spelling test's
  `spelling.Rout` comparison OK inside the check. Incidental, report-only:
  `inst/WORDLIST` is ordered case-insensitively, not in the strict
  `LC_ALL=C` byte order the item's instructions named (`LC_ALL=C sort -c`
  flags `:6`); both spelling tools are order-indifferent, so not a
  defect — noted here for any future session reading the S230 convention
  literally. Nothing hand-added; no package file touched. BACKLOG block
  (was `:180-218`) REMOVED per the completed-item checklist. No GitHub
  issue named by the item — no issue close owed.

### 2026-09-21 · [ad hoc] S750 claim: close the WORDLIST 10-word drift Housekeeping item *(in progress)*
- Owner-picked via the Phase 0 picker (over BACKLOG editorial compression,
  inst/doc slimming, kinship2-standalone). Plan: hand-add the 10 drifted
  words (`BACKLOG.md:181` names them) to `inst/WORDLIST` in `LC_ALL=C`
  byte order — never `spelling::update_wordlist()` (S230 convention) —
  then re-verify `devtools::check()` drops to the vignette-engine note
  only (the item's own closure criterion, expectation updated S748).
  Phase mapping to be owner-ratified at the TDD gate before any edit.

### 2026-09-21 · [ad hoc] S749 close-out sha: `HANDOFFS.md` receipt's `commit:` field set to the records commit `dcf51299`; carries its own entry, so no self-reference gap is left for Phase 0
- Final S749 commit. S749 total: 3 commits (claim `589cf73c` — rode the
  push, deliverable was the push itself, records `dcf51299`, this one).
  Ahead of `origin/master` by 2 after close-out (records + this sha
  commit), ALL docs-only; CI is current through `589cf73c` and no code has
  changed since `5d281ad5`. Expect 0 undocumented commits past the frontier
  at next Phase 0; measure it.

### 2026-09-21 · [ad hoc] S749 close-out: session records (handoff, S748 evaluation 9/10, receipt complete, self 9/10)
- `SESSION_NOTES.md` handoff written (S748 evaluation: 9/10 — 6-unpushed and
  clean-frontier claims held exactly; growth-run trajectory exact (25/10
  measured); ratchet citation byte-identical; its push+CI guidance was the
  execution plan as written; nothing found wrong). `HANDOFFS.md` receipt
  complete. No new `PROJECT_LEARNINGS.md` entry (routine clean push+CI —
  12th consecutive, extending S747's 11th). Reduction check (FM #28): none
  this session — no mandated-read file got smaller; said plainly. Runtime
  smoke: n/a — push-only; the CI runs are the runtime evidence.
  quality_ratchet at `589cf73c`: 1/1 pass · 0 fail · 0 unmeasured · results
  b740dd347d67 · manifest aa983075d6a2 (3,489,040 B ≤ 5,000,000 B, read
  from the results file — the run table rounded to 3.48904e+06; the +167 B
  vs S748 is build-metadata noise, all touched files being
  `.Rbuildignore`d, verified `:72/:76/:79/:154`).

### 2026-09-21 · [ad hoc] S749 deliverable: pushed `5d281ad5..589cf73c` to `origin/master`; all 4 workflows `completed success` on the pushed sha
- Records-currency push (S726–S747 precedent): 7 commits (S747–S748
  records/sha + the S749 claim riding the push), ALL docs-only; no code
  changed since `5d281ad5`, which was already CI-confirmed. 0 unpushed
  after the push (recount). Filter smoke-tested against in-flight runs
  BEFORE arming the single 30-min monitor (no re-arm; completions lint →
  pkgdown → test-coverage → R-CMD-check, all success). Structural
  verification via `gh run list --commit <full-40-char-sha>` with `headSha`
  echoed back per run: lint 3m46s (id 35562052225), pkgdown 6m13s
  (35562052219), test-coverage 10m9s (35562052322), R-CMD-check 21m37s
  (35562052190) — inside the established 17m39s–22m17s band. CI is now
  current through `589cf73c`.

### 2026-09-21 · [ad hoc] S749 claim: push to `origin/master` + CI verification (in progress)
- Session claimed (stub + pending receipt + this entry). Phase 0 was clean:
  0 undocumented commits on both frontiers at `cb44c898`; S748 receipt
  complete, its ratchet citation byte-identical to
  `.quality-gates-results.json`; CI 10/10 green, current through `5d281ad5`;
  6 unpushed measured (matching the S748 prediction), ALL docs-only;
  dashboard 96/100; context budget WARN = the known `CLAUDE.md` warn band,
  growth run 25/10; the 5 known untracked files unchanged. Owner picked
  push+CI via the Phase 0 picker (over WORDLIST drift, BACKLOG compression,
  inst/doc slimming). Plan: push (this claim rides), smoke-test the
  full-40-char-sha `--commit` filter against in-flight runs BEFORE arming a
  single monitor, then verify all 4 workflows `completed success` with
  `headSha` echoed back on the pushed sha.

### 2026-09-21 · [ad hoc] S748 close-out sha: `HANDOFFS.md` receipt's `commit:` field set to the records commit `7ad303fc`; carries its own entry, so no self-reference gap is left for Phase 0
- Final S748 commit. S748 total: 4 commits (claim `f4f4442e`, deliverable
  `73107bc8`, records `7ad303fc`, this one). Ahead of `origin/master` by 6
  after close-out (S747's 2 records/sha + this session's 4), ALL docs-only;
  CI is current through `5d281ad5` and no code has changed since. Expect
  0 undocumented commits past the frontier at next Phase 0; measure it.

### 2026-09-21 · [ad hoc] S748 close-out: session records (handoff, S747 evaluation 9/10, receipt complete, self 9/10)
- `SESSION_NOTES.md` handoff written (S747 evaluation: 9/10 — 2-unpushed and
  clean-frontier claims held exactly; growth-run prediction 24/10 exact;
  ratchet citation byte-identical; its iCloud-close guidance was the
  execution plan as written; nothing found wrong). `HANDOFFS.md` receipt
  complete. No new `PROJECT_LEARNINGS.md` entry (the session's one
  working-tree slip — replacing the committed claim entry's heading instead
  of prepending, caught by diff re-read before committing — is covered by
  the existing never-edit rule; named plainly in the self-assessment).
  Reduction check (FM #28): REAL — `BACKLOG.md` net −20 lines. Runtime
  smoke: n/a — docs-only. quality_ratchet at `73107bc8`: 1/1 pass · 0 fail ·
  0 unmeasured · results 443e4de1cd50 · manifest aa983075d6a2 (3,488,873 B ≤
  5,000,000 B, read from the results file — the run table rounded to
  3.48887e+06; the −78 B vs S747 is build-metadata noise, `BACKLOG.md`
  being `.Rbuildignore`d).

### 2026-09-21 · [ad hoc] S748 deliverable: iCloud duplicate-`.R`-files Housekeeping item CLOSED per its own closure condition; BACKLOG block removed
- The item (found S461, recurred S462; `PROJECT_LEARNINGS.md` Learning 454):
  iCloud sync left `R/appServer 2.R` and `R/modMarkerGenetics 2.R` in `R/`,
  where `pkgload::load_all()`/`devtools::document()` sourced them like any
  other `.R` file, silently merging their stale roxygen into
  `man/appServer.Rd`, `man/modMarkerGeneticsServer.Rd`, and
  `man/modMarkerGeneticsUI.Rd` (corruption confirmed twice S461, recurred
  S462 after an owner-side local rebuild; each time reverted via
  `git checkout --`). Closure condition (the item's own text): the owner
  relocates the repo outside iCloud's purview and the duplicates no longer
  reappear after local rebuilds.
- Closure evidence (measured this session): (1) `pwd` =
  `~/Development/nprcgenekeepr` — no iCloud path component (the S462-era
  blocker "relocation had NOT yet happened" is resolved); (2) `ls R/ |
  grep ' 2\.'` empty — second consecutive session-check (S746, S748) with
  owner-side local rebuilds in between; (3) no `*conflicted copy*` file
  anywhere in the repo; (4) the 3 previously-corrupted `.Rd` files are
  clean in git; (5) only ` 2.*` residue repo-wide is 7 stale `.pper` files
  under `.Rproj.user/` — gitignored (`.gitignore:1`), 0 tracked, never
  sourced by package tooling: inert iCloud-era residue, not a recurrence.
- BACKLOG block (was `BACKLOG.md:180-201`) REMOVED per the completed-item
  checklist. Forward-carry: the WORDLIST-drift item's verification target
  updated in place — `devtools::check()` should now drop to the
  vignette-engine note only, since the co-present duplicate-file warning
  died with this item. No GitHub issue named by the item, so no issue
  close owed. Learning 454 stays as the frozen historical record.

### 2026-09-21 · [ad hoc] S748 claim: close the iCloud duplicate-`.R`-files Housekeeping item per its own closure condition (in progress)
- Owner-picked via the Phase 0 picker (over BACKLOG compression, inst/doc
  slimming, kinship2-standalone). Session claimed: `SESSION_NOTES.md` stub +
  `HANDOFFS.md` pending receipt + this entry. Phase 0 reconcile was clean
  (0 undocumented on both frontiers at `01f1b030`; S747 receipt complete,
  ratchet citation matched the results file byte-for-byte). Pre-check
  already run at Orient: `ls R/ | grep ' 2\.'` returns nothing — the
  closure condition is met, pending the item-removal + records work.

### 2026-09-21 · [ad hoc] S747 close-out sha: `HANDOFFS.md` receipt's `commit:` field set to the records commit `f976d94f`; carries its own entry, so no self-reference gap is left for Phase 0
- Final S747 commit. S747 total: 3 commits (claim `5d281ad5` — rode the push,
  records `f976d94f`, this one). Ahead of `origin/master` by 2 after close-out
  (records + this one), both docs-only; CI is current through `5d281ad5`.
  Expect 0 undocumented commits past the frontier at next Phase 0; measure it.

### 2026-09-21 · [ad hoc] S747 close-out: session records (handoff, S746 evaluation 9/10, receipt complete, self 9/10)
- `SESSION_NOTES.md` handoff written (S746 evaluation: 9/10 — 14-unpushed and
  clean-frontier claims held exactly; growth-run prediction 23/10 exact;
  ratchet citation byte-identical; its push+CI guidance was the execution
  plan, R-CMD-check 17m42s inside the predicted band; nothing found wrong).
  `HANDOFFS.md` receipt complete. No new `PROJECT_LEARNINGS.md` entry
  (routine clean push+CI, 11th consecutive, extending S743's 10th). Reduction
  check (FM #28): NONE this session — no mandated-read file got smaller;
  stated plainly rather than left unsaid. Runtime smoke: n/a — push-only; the
  runtime evidence IS the deliverable (4/4 workflows green on the pushed
  sha). quality_ratchet at pushed HEAD `5d281ad5`: 1/1 pass · 0 fail ·
  0 unmeasured · results 44c6e83894b6 · manifest aa983075d6a2 (3,488,951 B ≤
  5,000,000 B, read from the results file — the run table rounded to
  3.48895e+06; the +7 B vs S746 is build-metadata noise, the claim commit's
  three touched files are all `.Rbuildignore`d, verified). 2 unpushed
  expected after close-out (records + sha); CI current through `5d281ad5`.

### 2026-09-21 · [ad hoc] S747 deliverable: owner-directed push to `origin/master` + CI verification — DONE
- Pushed `59f1888e..5d281ad5` (15 commits: 14 carried S744–S746 close-out/
  claim/deliverable commits + the S747 claim riding the push, S726–S743
  precedent). All 4 push-triggered workflows `completed success` ON THE
  PUSHED SHA `5d281ad5`, verified structurally via
  `gh run list --commit <full-40-char-sha>` with `headSha` echoed back:
  lint 4m51s (id 35559402091), pkgdown 6m14s (35559402167), test-coverage
  8m42s (35559402158), R-CMD-check 17m42s (35559402194) — inside the
  established 17m39s–22m17s band; filter smoke-tested against in-flight runs
  BEFORE arming the single 30-min Monitor; no re-arm. First remote CI
  confirmation for all THREE prep deliverables (`44bb4481` D-1, `eb896c2e`
  D-2, `a5a9bf42` D-3). 0 unpushed after the push.

### 2026-09-21 · [ad hoc] S747 claim: owner-directed push to `origin/master` + CI verification *(in progress)*
- Phase 0 clean: 0 undocumented on both frontiers at `8b9a0148`; S746 receipt
  complete, ratchet citation matched `.quality-gates-results.json`
  byte-for-byte; CI 10/10 green (current only through S743's push `59f1888e`);
  dashboard 96/100; context budget WARN = CLAUDE.md warn band, growth run
  23/10 (as S746 predicted); 14 unpushed measured (= S746's prediction).
  Owner picked the push via the Phase 0 picker. This claim rides the push
  (S726–S743 precedent). THREE deliverables never seen by CI: `44bb4481`
  (D-1, R/+tests), `eb896c2e` (D-2, tests), `a5a9bf42` (D-3, comment-only).

### 2026-09-21 · [BL-prep-D-3] S746 close-out sha: `HANDOFFS.md` receipt's `commit:` field set to the records commit `70ed987b`; carries its own entry, so no self-reference gap is left for Phase 0
- Final S746 commit. S746 total: 4 commits (claim `19de9c64`, deliverable
  `a5a9bf42`, records `70ed987b`, this one). Ahead of `origin/master` by
  14 after close-out; THREE deliverables (`44bb4481`, `eb896c2e`,
  `a5a9bf42`) have never been seen by CI, so a push+CI session is the top
  routine next pick. Expect 0 undocumented commits past the frontier at
  next Phase 0; measure it.

### 2026-09-21 · [BL-prep-D-3] S746 close-out: session records (handoff, S745 evaluation 9/10, receipt complete, self 9/10)
- `SESSION_NOTES.md` handoff written (S745 evaluation: 9/10 — 10-unpushed and
  clean-frontier claims held exactly; growth-run prediction exact; the D-3
  guidance was the execution plan; nothing found wrong). `HANDOFFS.md`
  receipt complete. No NEWS.Rmd entry owed (no exported function or
  user-facing change); no WORDLIST risk (`@noRd` text never reaches
  `.Rd`/vignettes). No new `PROJECT_LEARNINGS.md` entry (routine clean
  REFACTOR session). Reduction check (FM #28): NONE this session —
  BACKLOG.md net 0 lines (D-3 block removed, equal bytes carried forward
  into the kinship2 item); stated plainly rather than left unsaid. Runtime
  smoke: n/a — comment-only; quality_ratchet at deliverable HEAD `a5a9bf42`:
  1/1 pass · 0 fail · 0 unmeasured · results b7c4dc700aa7 · manifest
  aa983075d6a2 (3,488,944 B ≤ 5,000,000 B, read from the results file — the
  run table rounded to 3.48894e+06, re-confirming the S745 gotcha; +2,386 B
  vs S745 is the roxygen riding in `R/` sources, expected). 14 unpushed
  expected after close-out (recount); THREE deliverables (`44bb4481`,
  `eb896c2e`, `a5a9bf42`) never seen by CI — push+CI is the top routine
  next pick. Incidental finding: the iCloud duplicate `.R` files are GONE
  from `R/` — the Housekeeping item is closable-on-confirmation by a future
  session.

### 2026-09-21 · [BL-prep-D-3] S746 deliverable: prep D-3 — all 13 `R/positionTreeApportion.R` functions now carry `@noRd` roxygen blocks
- REFACTOR-only (owner-gated PRE-RED→REFACTOR with the exact edits): one
  house-style block per function (title + `@param` + `@return` + `@noRd`,
  matching `R/shrinkPedigree.R`'s internal-doc convention); diff is exactly
  160 added `#'` lines, 0 deletions, no code touched; no line over 80 chars.
  Verification: `devtools::document()` byte-identical no-op on `man/` +
  `NAMESPACE` (`@noRd` generates nothing — and the iCloud duplicate `.R`
  files are confirmed GONE from `R/`, so the S461 corruption trap did not
  apply); `test_positionTreeApportion.R` passes; full silent suite 0 failed /
  0 error / 184 skipped (7054 passed); lint 0 on the touched file (package
  loaded first). BACKLOG D-3 block REMOVED in this commit (completed-item
  checklist); the kinship2-standalone item's blocker updated: prep steps ALL
  DONE (D-1 S744, D-2 S745, D-3 S746) — only the S738 revisit conditions
  remain, with the D-3 fact and prep-origin context carried into the item.

### 2026-09-21 · [BL-prep-D-3] S746 claim: prep D-3 — `@noRd` roxygen blocks for `R/positionTreeApportion.R`'s 13 functions (in progress)
- Phase 0 clean: 0 undocumented on both frontiers at `41c43c35`; S745 receipt
  complete, ratchet citation matches `.quality-gates-results.json` exactly;
  CI 10/10 green but current only through S743's push (`44bb4481`/`eb896c2e`
  still unpushed, 10 ahead); dashboard 96/100; context budget WARN =
  CLAUDE.md warn band, growth run 22/10 (predicted exactly); 5 known
  untracked files unchanged. Owner picked D-3 via the Phase 0 picker.
  Stub + pending receipt ride this commit.

### 2026-09-21 · [BL-prep-D-2] S745 close-out sha: `HANDOFFS.md` receipt's `commit:` field set to the records commit `b528b8bd`; carries its own entry, so no self-reference gap is left for Phase 0
- Final S745 commit. S745 total: 4 commits (claim `d6dc0852`, deliverable
  `eb896c2e`, records+trim `b528b8bd`, this one). Ahead of `origin/master` by
  10 after close-out; TWO code deliverables (`44bb4481`, `eb896c2e`) have
  never been seen by CI, so a push+CI session is the top routine next pick.
  Expect 0 undocumented commits past the frontier at next Phase 0; measure it.

### 2026-09-20 · [ad hoc] Ledger trim: `SESSION_NOTES.md` → `docs/archive/SESSION_NOTES-through-2026-09-20-2.md` (13 record(s), 61,388 B → 13,607 B)

**Written by:** `methodology_trim.py` v1.5.0 — a tool action, not a session's judgment.
Moved the oldest **13** record(s) (2026-09-02 → 2026-09-20) out of [`SESSION_NOTES.md`](SESSION_NOTES.md) into
[`docs/archive/SESSION_NOTES-through-2026-09-20-2.md`](docs/archive/SESSION_NOTES-through-2026-09-20-2.md). Losslessness is asserted by L1 (records-zone concatenation), L2 (zone
pinning) and L3 (record partition), and is **re-derivable** — run [`docs/archive/SESSION_NOTES-through-2026-09-20-2.md.verify.sh`](docs/archive/SESSION_NOTES-through-2026-09-20-2.md.verify.sh)
rather than trusting a digest printed here. Live file 61,388 B → 13,607 B (−77.8%).

### 2026-09-21 · [BL-prep-D-2] S745 close-out: session records (handoff, S744 evaluation 9/10, receipt complete, self 9/10)
- `SESSION_NOTES.md` handoff written (S744 evaluation: 9/10 — 6-unpushed and
  clean-frontier claims held exactly; growth-run prediction exact; the D-2
  guidance was the execution plan; ONE immaterial finding — its ratchet
  citation's measured size was 3 B off the results file, root-caused this
  session to the run table's rounded display: cite from
  `.quality-gates-results.json`, never the table). `HANDOFFS.md` receipt
  complete. No NEWS.Rmd entry owed (no exported function or user-facing
  change). No new `PROJECT_LEARNINGS.md` entry (routine clean REFACTOR
  session). Reduction check (FM #28): BACKLOG.md net −3 lines — a
  mandated-read file got smaller. Runtime smoke: n/a — test-only refactor;
  quality_ratchet at deliverable HEAD `eb896c2e`: 1/1 pass · 0 fail ·
  0 unmeasured · results cb8622ee3020 · manifest aa983075d6a2 (3,486,558 B ≤
  5,000,000 B, read from the results file). 10 unpushed after close-out
  (recount); TWO code deliverables (`44bb4481`, `eb896c2e`) never seen by
  CI — push+CI is the top routine next pick.

### 2026-09-21 · [BL-prep-D-2] S745 deliverable: Prep D-2 DONE — the two test-only reaches into `.buildMatingUnitForest()` now derive ids through the exported surface
- REFACTOR-only, the owner-ratified phase mapping (same as D-3's; two gates
  ran via AskUserQuestion: approach — REFACTOR-only over a RED→GREEN boundary
  guard test and over a new exported accessor — then PRE-RED→REFACTOR with
  exact planned edits). `tests/testthat/test_modPedigree.R`: the union-click
  no-op test (was `:1669`) now takes `grep("^__union_", layout$nodes$id,
  value = TRUE)[1L]` from `makePedigreeMatingLayout()`'s return (the `^`
  anchor matters — waypoint ids like `__drop___union_1` contain but do not
  start with the prefix); the duplicate-click test (was `:1706`) now uses
  `duplicateToReal` for length/id/realId. Equivalence proven empirically
  BEFORE editing: on the fixture, the public return's union-id set and dup
  mapping are identical to the internal forest's. Zero functional
  `.buildMatingUnitForest` calls remain outside the layout core's own test
  files (S667 §2.4/D6 closed). Verification: full `test_modPedigree.R` pass;
  full silent suite 0 failed / 0 error / 184 skipped (7054 passed); lint 0 on
  the touched file (package loaded first). No production code touched; no
  NEWS.Rmd entry owed (no exported function or user-facing change). BACKLOG
  D-2 item REMOVED (completed-item checklist); the BLOCKED kinship2-build
  item's blocker updated to D-3 only, with the D-2 boundary fact carried into
  the item.

### 2026-09-21 · [BL-prep-D-2] S745 claim: Prep D-2 — remove the two test-only reaches into `.buildMatingUnitForest()` *(in progress)*
- Owner pick via the Phase 0 picker (over push+CI, prep D-3, BACKLOG
  compression). Phase 0 findings: 0 undocumented on both frontiers at
  `d1a34d0d`; S744 receipt complete (one 3-byte transcription slip in its
  measured-size figure — 3,486,350 vs the results file's 3,486,353 B; hashes
  match, gate outcome unaffected); CI 10/10 green but current only through
  `59f1888e` (the S744 code deliverable `44bb4481` is unpushed); dashboard
  96/100; context budget WARN = CLAUDE.md warn band, growth run 21/10 (as S744
  predicted); 6 unpushed measured (= S744's ~6). CODE session — full TDD
  gates; the RED/GREEN phase mapping (the deliverable IS a test rewrite) gets
  agreed with the owner before anything is written.

### 2026-09-21 · [BL-prep-D-1] S744 close-out sha: `HANDOFFS.md` receipt's `commit:` field set to the records commit `63a645bf`; carries its own entry, so no self-reference gap is left for Phase 0
- Final S744 commit. S744 total: 4 commits (claim `1dc5d9bd`, deliverable
  `44bb4481`, records `63a645bf`, this one). Ahead of `origin/master` by 6
  after close-out; the deliverable touches `R/` + `tests/`, so the next push's
  CI run is the first remote confirmation of the new code. Expect 0
  undocumented commits past the frontier at next Phase 0; measure it.

### 2026-09-21 · [BL-prep-D-1] S744 close-out: session records (handoff, S743 evaluation 9/10, receipt complete, self 9/10)
- `SESSION_NOTES.md` handoff written (S743 evaluation: 9/10 — 2-unpushed and
  clean-frontier claims held exactly; ratchet citation byte-identical;
  growth-run prediction exact; D-1 was its named pick and its guidance was the
  execution plan). `HANDOFFS.md` receipt complete. NEWS.Rmd plain-language
  entry rides this records commit (5-file cap kept the deliverable commit at
  5). No new `PROJECT_LEARNINGS.md` entry (routine clean TDD session).
  Reduction check (FM #28): BACKLOG.md net −7 lines — a mandated-read file got
  smaller. Runtime smoke: script-level both-paths-agree on `smallPed`
  (`identical` TRUE); quality_ratchet at deliverable HEAD `44bb4481`: 1/1 pass
  · 0 fail · 0 unmeasured · results bd0b6b4bcfcf · manifest aa983075d6a2
  (3,486,350 B ≤ 5,000,000 B). ~6 unpushed after close-out (recount); the
  deliverable touches R/ + tests/, so a push+CI session is the natural next
  routine pick.

### 2026-09-21 · [BL-prep-D-1] S744 deliverable: Prep D-1 DONE — `makePedigreeMatingLayout()` gains an optional `kinshipMatrix` argument; the layout core's one genetics back-reference is now injectable
- Full TDD cycle, every gate owner-approved via AskUserQuestion (approach:
  `kinshipMatrix = NULL` over pair-flags/`kinshipFn`; PRE-RED→RED; RED→GREEN;
  GREEN→REFACTOR). RED: 7 tests appended
  (`tests/testthat/test_makePedigreeMatingLayout.R:1689+` — identity vs default,
  bypass proof via all-zero matrix, injected-marker proof, partial-matrix safe
  FALSE, invalid-input errors, twinRelations interplay, issue-#164 empty
  contract), failing on `unused argument` with all 222 pre-existing passing.
  GREEN: signature + up-front validation (matrix/Matrix with dimnames) at
  `R/makePedigreeDiagramData.R:1685-1699`, injection branch at `:1785` (default
  path computes `kinship(..., twinRelations = twinRelations)` byte-identically —
  threading preserved; injected matrix is the SOLE consanguinity source,
  documented in roxygen `@param`); `devtools::document()` touched only
  `man/makePedigreeMatingLayout.Rd`. File 243/0/0; full suite 0 failed / 0 error /
  184 skipped (baseline held). REFACTOR: 0 lints on both touched files, no edits
  needed. NEWS.Rmd plain-language entry added (Pedigree Diagram section).
  BACKLOG D-1 item block REMOVED in this commit (completed-item removal
  checklist); the BLOCKED kinship2-build item's blocker line updated to
  D-2/D-3 (D-1 DONE S744) with the boundary pointer carried forward.
  a2interactive demonstration: deferred by standing checklist (S450/S478 —
  new-parameter passes are a dedicated later session). No pkgdown change owed
  (no new export).

### 2026-09-21 · [BL-prep-D-1] S744 claim: Prep D-1 — invert the `kinship()` dependency in `makePedigreeMatingLayout()` *(in progress)*
- Owner picked Prep D-1 via the Phase 0 picker (`BACKLOG.md:71`). Scope: add an
  optional argument accepting a precomputed kinship matrix (or consanguinity
  flags) to `makePedigreeMatingLayout()`, defaulting to computing via
  `kinship()` exactly as today so no caller changes; preserve `twinRelations`
  threading semantics. CODE session — full TDD gates. Claim stub + pending
  receipt ride this commit.

### 2026-09-21 · [ad hoc] S743 close-out sha: `HANDOFFS.md` receipt's `commit:` field set to the records commit `b7689145`; carries its own entry, so no self-reference gap is left for Phase 0
- Final S743 commit. S743 total: 3 commits (claim `59f1888e` — rode the push,
  records `b7689145`, this one). Ahead of `origin/master` by 2 after close-out
  (records + this one), both docs-only; CI is current through `59f1888e`. Expect
  0 undocumented commits past the frontier at next Phase 0; measure it.

### 2026-09-21 · [ad hoc] S743 close-out: session records (handoff, S742 evaluation 9/10, receipt complete, self 9/10)
- `SESSION_NOTES.md` handoff written (S742 evaluation: 9/10 — 11-unpushed and
  clean-frontier claims held exactly; ratchet citation byte-identical; growth-run
  prediction exact; its natural-next-pick call was the owner's pick).
  `HANDOFFS.md` receipt complete. No new `PROJECT_LEARNINGS.md` entry (routine
  clean push, 10th consecutive). Reduction check (FM #28): nothing removed from a
  mandated-read file — stated explicitly; `SESSION_NOTES.md` ~45 KB, next trim
  likely 1–2 sessions out. quality_ratchet at the pushed HEAD `59f1888e`: 1/1 pass
  · 0 fail · 0 unmeasured · results 0ddf7e4d90f7 · manifest aa983075d6a2
  (3,483,919 B ≤ 5,000,000 B). 2 unpushed after close-out (estimate: records +
  sha); CI current through `59f1888e`.

### 2026-09-21 · [ad hoc] S743 deliverable: owner-directed push to `origin/master` + CI verification — DONE
- Pushed `889f9896..59f1888e` (12 commits: 11 carried docs-only S737–S742
  close-out/claim commits + the S743 claim riding the push, S726–S740 precedent).
  All 4 push-triggered workflows `completed success` ON THE PUSHED SHA `59f1888e`,
  verified structurally via `gh run list --commit <full-40-char-sha>` with
  `headSha` echoed back: lint 4m22s (id 35552846756), pkgdown 5m02s (35552846743),
  test-coverage 9m47s (35552846748), R-CMD-check 21m41s (35552846742) — inside the
  established 17m39s–22m17s band; filter smoke-tested against in-flight runs
  BEFORE arming the single 30-min Monitor (S736 lesson); no re-arm. 0 unpushed
  after the push.

### 2026-09-21 · [ad hoc] S743 claim: owner-directed push to `origin/master` + CI verification *(in progress)*
- Phase 0 clean: 0 undocumented on both frontiers at `ef0f34bb`; S742 receipt
  complete, ratchet citation matched `.quality-gates-results.json`; CI 10/10 green
  (latest 4 on `889f9896`); dashboard 96/100; context budget WARN = CLAUDE.md warn
  band, growth run 19/10 (as S742 predicted); 11 unpushed measured (= S742's ~11).
  Owner picked the push via the Phase 0 picker. This claim rides the push
  (S726–S740 precedent).

### 2026-09-21 · [ad hoc] S742 close-out sha: `HANDOFFS.md` receipt's `commit:` field set to the records commit `9a8325c2`; carries its own entry, so no self-reference gap is left for Phase 0
- Final S742 commit. S742 total: 4 commits (claim `222f0c5e`, deliverable
  `4697f66c`, records `9a8325c2`, this one). Ahead of `origin/master` by 11 after
  close-out (7 carried + these 4), all docs-only; CI is current through `889f9896`.
  Expect 0 undocumented commits past the frontier at next Phase 0; measure it.

### 2026-09-21 · [ad hoc] S742 close-out: session records (handoff, S741 evaluation 9/10, receipt complete, self 9/10)
- `SESSION_NOTES.md` handoff written (S741 evaluation: 9/10 — 7-unpushed and
  clean-frontier claims held exactly; its step-2 pickup guidance was effectively
  this session's execution plan). `HANDOFFS.md` receipt complete. No new
  `PROJECT_LEARNINGS.md` entry (routine decision/records session; the durable
  record is the deliverable entry + the BACKLOG item). Reduction check (FM #28):
  `BACKLOG.md` net +6 lines by disposition-recording — stated explicitly; the
  editorial-compression item remains the counterweight. quality_ratchet at the
  deliverable HEAD `4697f66c`: 1/1 pass · 0 fail · 0 unmeasured · results
  966c2a067d51 · manifest aa983075d6a2 (3,483,942 B ≤ 5,000,000 B). ~11 unpushed
  after close-out (estimate: 7 carried + claim + deliverable + records + sha);
  CI current through `889f9896`; a push+CI session is the natural next pick.

### 2026-09-21 · [ad hoc] S742 deliverable: kinship2 standalone-package disposition — COMMITTED but DEFERRED, scope ratified (owner discussion, step 2 of the S739 item)
- Owner briefed from `docs/research/kinship2-feature-gap-analysis-2026-09-20.md`
  (Findings #1/#2/#4, Structural Observations 2/3, Recommendations) with the
  question, S738-lesson style; decisions via one 4-question `AskUserQuestion`:
  1. **Disposition: "Not now — defer, gates stand"** (prep D-1/D-2/D-3 + the S738
     revisit conditions, scoping doc §6), **with the owner's free-text intent
     recorded: the package WILL be built.** Owner (near-verbatim): creation of a
     separate package will be done and may eventually be used by nprcgenekeepr,
     "but that is not the primary goal. The primary goal is to have a standalone
     near equivalent package that has the enhanced features offered with
     nprcgenekeepr and particularly the pedigree drawing, annotation ability, and
     interactivity." So: plan a sibling product first; nprcgenekeepr adoption is
     secondary/optional.
  2. **API shape: DELIBERATELY OPEN** — data-frame-as-is vs kinship2-compat layer
     decided at plan time with a prototype in hand.
  3. **Drawing surface: IN** — lift the module-bound decorations
     (`R/modPedigree.R:675-790`) into a script-callable visNetwork renderer.
  4. **Parity closers: IN** — export shrink helpers + `bitSize`
     (`R/shrinkPedigree.R:227-380`), port `familycheck` + `ibdMatrix`, add
     user-suppliable layout hints; **OUT** — block-sparse `makekinship`.
- Records: the S739 two-step discussion item (`BACKLOG.md:95`) REMOVED per the
  completed-item removal checklist; its still-open thread extracted as a new
  BLOCKED item "Build a kinship2-similar standalone pedigree package" carrying the
  full ratified scope + purpose statement forward. Step-1 gap-doc counts
  (15 EQ / 8 PARTIAL / 2 ABSENT, kinship2 1.9.6.2) unchanged.

### 2026-09-21 · [ad hoc] S742 claim: kinship2 standalone-package step 2 — owner discussion / packaging disposition (in progress)
- Session claimed via the Phase 0 `AskUserQuestion` picker (owner pick over push+CI
  and prep D-1/D-2). Plan: brief the owner from
  `docs/research/kinship2-feature-gap-analysis-2026-09-20.md` (Finding #4,
  Structural Observation 2, Recommendations), pose the Recommendation-1 packaging
  choices (a: df API vs compatibility layer; b: lift drawing decorations to a
  script-callable renderer; c: export shrink internals + `bitSize`) via
  `AskUserQuestion`, record the disposition in `BACKLOG.md` + this ledger.
  Decision/records session — no TDD phases expected. Phase 0 was clean: 0
  undocumented on both frontiers at `0cf0696e`; CI 10/10 green (latest 4 on
  `889f9896`); dashboard 96/100; context budget WARN = CLAUDE.md warn band, growth
  run 18/10; 7 unpushed measured (= S741's estimate); 5 known untracked files
  unchanged.

### 2026-09-21 · [ad hoc] S741 close-out sha: `HANDOFFS.md` receipt's `commit:` field set to the records commit `27238ad3`; carries its own entry, so no self-reference gap is left for Phase 0
- Final S741 commit. S741 total: 4 commits (claim `c9457ec7`, deliverable
  `11f436cd`, records `27238ad3`, this one). Ahead of `origin/master` by 7 after
  close-out (3 carried + these 4), all docs-only; CI is current through `889f9896`.
  Expect 0 undocumented commits past the frontier at next Phase 0; measure it.

### 2026-09-21 · [ad hoc] S741 close-out: session records (handoff, S740 evaluation 9/10, receipt complete, self 9/10)
- `SESSION_NOTES.md` handoff written (S740 evaluation: 9/10 — 3-unpushed and
  clean-frontier claims held exactly; its "measure the growth run rather than
  predict" guidance was exactly right: 17/10, the trim did not reset it).
  `HANDOFFS.md` receipt complete. No new `PROJECT_LEARNINGS.md` entry (routine
  research session; the durable record is the doc + the deliverable entry).
  Reduction check (FM #28): `BACKLOG.md` net −10 lines. quality_ratchet at the
  deliverable HEAD `11f436cd`: 1/1 pass · 0 fail · 0 unmeasured · results
  c0835d09d7dc · manifest aa983075d6a2 (3,483,909 B ≤ 5,000,000 B). ~7 unpushed
  after close-out (estimate: 3 carried + claim + deliverable + records + sha);
  CI current through `889f9896`; push at owner's call.

### 2026-09-21 · [ad hoc] S741 deliverable: kinship2 feature-gap analysis — 15 equivalent / 8 partial / 2 absent across kinship2's 25 live-enumerated exports
- `docs/research/kinship2-feature-gap-analysis-2026-09-20.md`: kinship2 1.9.6.2's
  surface enumerated live from the installed package (`getNamespaceExports` — 25
  exports, 11 S3 registrations, 3 datasets; the BACKLOG item's embedded list was
  indeed an incomplete hint, 11 of 25). Every nprcgenekeepr-side claim verified
  against live source with file:line evidence this session. Headline: capability
  parity is effectively done — the compute core was already deliberately ported
  (`kinship()` incl. `chrtype="x"`/MZ twins, `shrinkPedigree()` + 5 internal
  helpers), the S435 drawing gaps all closed via issues #131–#137/#145 (states
  re-verified via `gh issue view`), and the only fully absent items are two minor
  utilities (`familycheck`, `ibdMatrix`). Six of eight partials are shrink
  internals one export away from equivalent; the two substantive partials are
  user-suppliable layout hints (`autohint`) and block-sparse multi-family kinship
  (`makekinship`). Finding #4 names the real step-2 question: drawing decorations
  live in the Shiny module (`R/modPedigree.R:675-790`), not the exported surface.
  `BACKLOG.md` item updated in place (step 1 DONE → step 2 DECISION NEEDED,
  −10 lines net). Step 2 (owner discussion) deliberately not started.

### 2026-09-21 · [ad hoc] S741 claim: kinship2 feature-gap analysis — per-feature gap table in `docs/research/` *(in progress)*
- Session claimed via the Phase 0 picker. Scope: step 1 of the S739
  kinship2-similar-package BACKLOG item (`BACKLOG.md:95`) — enumerate kinship2's
  exported surface at analysis time (installed package / CRAN reference manual, per
  the item's own caveat that its embedded list is an unverified hint), classify each
  feature equivalent/partial/absent in nprcgenekeepr, and ship the gap table to
  `docs/research/`. Step 2 (the owner discussion) stays out of scope. Close-out
  records the rest.

### 2026-09-21 · [ad hoc] S740 close-out sha: `HANDOFFS.md` receipt's `commit:` field set to the records commit `f8605f07`; carries its own entry, so no self-reference gap is left for Phase 0
- Final S740 commit. S740 total: 4 commits (claim `889f9896` — rode the push, trim
  `4876094d`, records `f8605f07`, this one). Ahead of `origin/master` by 3 after
  close-out (trim + records + this), all docs-only; CI is current through
  `889f9896`. Expect 0 undocumented commits past the frontier at next Phase 0;
  measure it.

### 2026-09-21 · [ad hoc] S740 close-out: session records (handoff, S739 evaluation 9/10, receipt complete, self 9/10)
- `SESSION_NOTES.md` handoff written (S739 evaluation: 9/10 — 15-unpushed and
  clean-frontier claims held exactly; the full-sha gotcha prevented a repeat of the
  S736 silent arm). `HANDOFFS.md` receipt complete. No new `PROJECT_LEARNINGS.md`
  entry (routine clean push, 9th of its kind). Reduction check: 12 records removed
  from a mandated-read file (the trim). quality_ratchet at the pushed HEAD
  `889f9896`: 1/1 pass · 0 fail · 0 unmeasured · results 2cb2faa00809 · manifest
  aa983075d6a2 (3,483,874 B ≤ 5,000,000 B). ~2 unpushed after close-out (estimate:
  records + sha); CI current through `889f9896`.

### 2026-09-21 · [ad hoc] S740 deliverable: push `2628cd02..889f9896` (16 commits) + CI verification — all 4 workflows green on the pushed sha
- Pushed the 15 unpushed docs-only S737–S739 commits + the S740 claim riding the push
  (S726–S736 precedent); 0 unpushed after the push. All 4 push-triggered workflows
  `completed success` on `889f9896` (headSha echoed structurally): lint 4m37s
  (id 35548502389), pkgdown 6m13s (35548502366), test-coverage 9m54s (35548502412),
  R-CMD-check 22m07s (35548502318) — inside the 17m39s–22m17s post-S732-fix band;
  single 30-min Monitor arm, no re-arm. The `--commit` filter was smoke-tested against
  the in-flight runs with the FULL 40-char sha BEFORE the monitor was armed (the S736
  lesson applied); conclusions verified from the JSON, not inferred from the stream.

### 2026-09-20 · [ad hoc] Ledger trim: `SESSION_NOTES.md` → `docs/archive/SESSION_NOTES-through-2026-09-20.md` (12 record(s), 55,049 B → 17,713 B)

**Written by:** `methodology_trim.py` v1.5.0 — a tool action, not a session's judgment.
Moved the oldest **12** record(s) (2026-09-20 → 2026-09-20) out of [`SESSION_NOTES.md`](SESSION_NOTES.md) into
[`docs/archive/SESSION_NOTES-through-2026-09-20.md`](docs/archive/SESSION_NOTES-through-2026-09-20.md). Losslessness is asserted by L1 (records-zone concatenation), L2 (zone
pinning) and L3 (record partition), and is **re-derivable** — run [`docs/archive/SESSION_NOTES-through-2026-09-20.md.verify.sh`](docs/archive/SESSION_NOTES-through-2026-09-20.md.verify.sh)
rather than trusting a digest printed here. Live file 55,049 B → 17,713 B (−67.8%).

### 2026-09-20 · [ad hoc] S740 claim: owner-directed push to `origin/master` + CI verification (in progress)
- Session claimed via the Phase 0 picker. Scope: push the 15 unpushed docs-only
  commits (measured at Orient, = S739's corrected count) + this claim commit riding
  the push (S726–S736 precedent); verify all 4 push-triggered workflows on the pushed
  sha with `gh run list --commit <full-40-char-sha>`. Close-out records the rest.

### 2026-09-20 · [ad hoc] S739 correction: unpushed-count claim in notes + receipt fixed ~12 → 14 measured (arithmetic slip forgot the records + sha commits themselves)
- The sha-commit ledger entry below already carried the correct 14; the receipt's
  `next_steps`/`gotchas` and the notes' matching lines were the wrong forward-looking
  claims and are now corrected (a wrong prediction is worse than none — Phase 3D).
  Fifth and final S739 commit.

### 2026-09-20 · [ad hoc] S739 close-out sha: `HANDOFFS.md` receipt's `commit:` field set to the records commit `3471ac36`; carries its own entry, so no self-reference gap is left for Phase 0
- Final S739 commit. S739 total: 4 commits (claim `e2671de1`, deliverable `7b10ac3d`,
  records `3471ac36`, this one). Ahead of `origin/master` by 14 after close-out (6
  carried pre-S738 + 4 S738 + these 4), all docs-only; CI is current through
  `2628cd02` — push is the owner's call and increasingly the natural next pick.
  Expect 0 undocumented commits past the frontier at next Phase 0; measure it.

### 2026-09-20 · [ad hoc] S739 close-out: session records (handoff, S738 evaluation 9/10, receipt complete, self 9/10)
- `SESSION_NOTES.md` handoff written (S738 evaluation: 9/10 — 10-unpushed and
  clean-frontier claims held exactly; lightly exercised same-conversation).
  `HANDOFFS.md` receipt complete. No new `PROJECT_LEARNINGS.md` entry (routine
  grooming session). Reduction check: nothing removed from a mandated-read file;
  `BACKLOG.md` grew +36 lines by owner directive — stated explicitly; the
  editorial-compression item is the standing counterweight. quality_ratchet at the
  deliverable HEAD `7b10ac3d`: 1/1 pass · 0 fail · 0 unmeasured · results 060a3da9b4b6 ·
  manifest aa983075d6a2 (3,483,920 B ≤ 5,000,000 B). ~12 unpushed after close-out
  (estimate); push is the owner's call and increasingly the natural next pick.

### 2026-09-20 · [ad hoc] S739 deliverable: BACKLOG item added — discuss a kinship2-similar standalone package built from this repo's code; step 1 = kinship2 feature-gap analysis
- New Up Next item placed directly after the S738 prep items (D-1/D-2/D-3), which are
  step 0 of any extraction path. Two explicit steps: step 1 (READY, Effort M) a
  research session producing a per-feature gap table in `docs/research/` — enumerate
  kinship2's exported surface at analysis time and classify each feature as
  equivalent/partial/absent here; step 2 (DECISION NEEDED) the owner discussion on
  whether and at what scope to build it. Cross-referenced rather than merged: the
  mostly-DONE "Pedigree diagram vs kinship2 audit follow-ups" section (drawing-only,
  stale — #131–#137/#145 closed most of its gaps) is prior art for step 1, and the
  item is framed as the concrete path to the S738 disposition's revisit condition 3
  (the "ecosystem argument", S667 doc §6/§2.7). Combination judgment (the owner said
  "perhaps combining with other backlog item"): adjacency + cross-references chosen
  over merging into the historical follow-ups section, which is a triage record, not
  a live item.

### 2026-09-20 · [ad hoc] S739 claim: BACKLOG item — kinship2-similar package discussion, step 1 = feature-gap analysis *(in progress)*
- Session claimed (stub + pending receipt + this entry), same conversation as S738.
  Abbreviated re-orient per S735 precedent (state minutes old): tree clean, both
  ledger frontiers at `e3370b82`, 0 undocumented, 10 unpushed (= S738's estimate).
  Owner directive: add a BACKLOG item (perhaps combining with an existing one) to
  discuss making a package similar to kinship2 from code within this repository;
  first step is identifying kinship2 features not available in this codebase.

### 2026-09-20 · [ad hoc] S738 close-out sha: `HANDOFFS.md` receipt's `commit:` field set to the records commit `0dec1c09`; carries its own entry, so no self-reference gap is left for Phase 0
- Final S738 commit. S738 total: 4 commits (claim `f9b1f2a3`, deliverable `9d80dde6`,
  records `0dec1c09`, this one). Ahead of `origin/master` by 10 after close-out (6
  carried + these 4), all docs-only; CI is current through `2628cd02`, so no urgency —
  push is the owner's call, though the unpushed backlog is growing. Expect 0
  undocumented commits past the frontier at next Phase 0; measure it.

### 2026-09-20 · [ad hoc] S738 close-out: session records (handoff, S737 evaluation 9/10, receipt complete, self 9/10)
- `SESSION_NOTES.md` handoff written (S737 evaluation: 9/10 — every checked claim held:
  6 unpushed, 0 undocumented, ratchet citation, growth-run prediction all exact).
  `HANDOFFS.md` receipt complete. No new `PROJECT_LEARNINGS.md` entry (routine
  decision/records session; the durable record is the deliverable ledger entry + the
  three prep items). Reduction check: `BACKLOG.md` net −2 lines. quality_ratchet at the
  deliverable HEAD `9d80dde6`: 1/1 pass · 0 fail · 0 unmeasured · results 847588b5cc75 ·
  manifest aa983075d6a2 (3,483,940 B ≤ 5,000,000 B). ~10 unpushed after close-out
  (estimate); push is the owner's call.

### 2026-09-20 · [ad hoc] S738 deliverable: package-split disposition — owner ACCEPTED "do not split now" and queued the three S667 prep steps
- The owner accepted the S667 scoping recommendation
  (`docs/research/pedigree-diagram-package-split-scoping-2026-09-02.md` §6): the
  pedigree-diagram layout core stays in `nprcgenekeepr`; no standalone package now. The
  three revisit conditions stand as written in the doc — (1) fidelity priority lifted AND
  engine stable (single-digit commits/60 days), (2) next CRAN release accepted, (3) a
  named second consumer. Re-measured at decision time (S738): condition 1 half-met
  (priority retired S699, but 67 commits/60 days · 27/30 on the core), conditions 2
  (`DESCRIPTION` 2.0.0.9000) and 3 (no consumer on record) not met — the recommendation
  holds on its own test. Context carried from the closed item: coupling is one consumer
  (`modPedigreeServer()`) through one function and one back-reference (`kinship()`, now
  `R/makePedigreeDiagramData.R:1755`); the Shiny module cannot move (calls 8 package
  functions); size is NOT an argument for splitting (S727: the feature's named R sources
  are 205 KB uncompressed; S737: 14.1% of `R/` lines, tarball weight mostly widget
  payload). The 2026-08-19 BACKLOG item's block REMOVED (completed-item removal
  checklist); its still-open sub-threads extracted as three new Up Next items — prep
  D-1 (invert the `kinship()` call), D-2 (remove the two `test_modPedigree.R:1669/:1706`
  internal reaches), D-3 (`@noRd` blocks for `R/positionTreeApportion.R`) — each its own
  small TDD session, worthwhile split or not.

### 2026-09-20 · [ad hoc] S738 claim: package-split disposition — owner accept/reject of the S667 "do not split now" recommendation *(in progress)*
- Session claimed (stub + pending receipt + this entry). Owner picked the item via the
  Phase 0 picker; Phase 0 reconcile was clean (0 undocumented on both frontiers at
  `a4b62e16`; S737 receipt complete, ratchet citation matches results file); CI 10/10
  green on master; dashboard 96/100; 6 unpushed measured (= S737's estimate); context
  budget WARN = CLAUDE.md warn band + growth run 15/10 (as S737 predicted), both synced
  files `canonical ok`. Close-out records the disposition.

### 2026-09-20 · [ad hoc] S737 close-out sha: `HANDOFFS.md` receipt's `commit:` field set to the records commit `0dc52bc7`; carries its own entry, so no self-reference gap is left for Phase 0
- Final S737 commit. S737 total: 4 commits (claim `0528da0e`, deliverable `6346cbde`,
  records `0dc52bc7`, this one). Ahead of `origin/master` by 6 after close-out (2
  carried S736 close-out commits + these 4), all docs-only; CI is current through
  `2628cd02`, so no urgency — push is the owner's call. Expect 0 undocumented commits
  past the frontier at next Phase 0; measure it.

### 2026-09-20 · [ad hoc] S737 close-out: session records (handoff, S736 evaluation 9/10, receipt complete, self 9/10)
- `SESSION_NOTES.md` handoff written (S736 evaluation: 9/10 — every checked claim held;
  the picked item's own pointers made discovery near-zero). `HANDOFFS.md` receipt
  complete. No new `PROJECT_LEARNINGS.md` entry (routine audit-workstream session; the
  durable findings live in the audit + the enriched BACKLOG item). Reduction check:
  `BACKLOG.md` shrank net this session (item block removed). quality_ratchet at the
  deliverable HEAD `6346cbde`: 1/1 pass · 0 fail · 0 unmeasured · results 2efb342d66ad ·
  manifest aa983075d6a2 (3,483,914 B ≤ 5,000,000 B). ~4 unpushed after close-out
  (estimate); push is the owner's call.

### 2026-09-20 · [ad hoc] S737 deliverable: pedigree-drawing feature growth audit — the feature is 25.4–30.5% of shipped-source growth, 43% of R+test line growth, and ~51–61% of compressed-tarball growth since CRAN 2.0.0
- `docs/audits/PEDIGREE_DRAWING_FEATURE_GROWTH_AUDIT_2026-09-20.md` written; the
  owner-requested `BACKLOG.md` item (mid-S721, ±20% accepted) is DONE and its block
  removed in this commit. Headline: shipped source grew 4,323,677 → 7,551,980 B
  (+74.7%) since pre-feature `fc358df4` (2026-07-29); the feature owns
  821,174–983,984 B of that (strict wholly-owned → +partial/twin brackets), i.e. the
  package is ~19–23% larger in source bytes because of the feature. Lines: 15,582
  feature lines = 43.0% of R+test line growth (test:source 2.6:1). Compressed: clean
  tarball rebuilt this session 3,483,939 B (matches the S728 gate figure); feature
  share ≈ 0.55–0.65 MB ≈ 16–19% of the tarball, dominated not by the feature's own
  code but by the vis-network + html2canvas payload its two live widgets embed in
  `inst/doc/a2interactive.html` (~0.29 MB compressed) — carried forward into the open
  inst/doc-slimming item's description as hard numbers. Marker-genetics context: its
  single 1,247,940 B example CSV outweighs the feature's entire tracked source.

### 2026-09-20 · [ad hoc] S737 claim: pedigree-drawing feature growth measurement *(in progress)*
- Owner pick via the Phase 0 picker: the `BACKLOG.md:117` item (owner-requested
  mid-S721, ±20% accepted). Deliverable: one measurement report in `docs/audits/`
  quantifying package growth attributable to the pedigree-drawing feature. Stub +
  pending receipt committed with this entry; close-out records the rest.

### 2026-09-20 · [ad hoc] S736 close-out sha: `HANDOFFS.md` receipt's `commit:` field set to the records commit `953ca78a`; carries its own entry, so no self-reference gap is left for Phase 0
- Final S736 commit. S736 total: 3 commits (claim `2628cd02` — rode the push, records
  `953ca78a`, this one). Ahead of `origin/master` by 2 after close-out, both docs-only;
  CI is current through `2628cd02`, so no urgency — push is the owner's call. Expect 0
  undocumented commits past the frontier at next Phase 0; measure it.

### 2026-09-20 · [ad hoc] S736 close-out: session records (handoff, S735 evaluation 9/10, receipt complete, self 8/10)
- `SESSION_NOTES.md` handoff written (S735 evaluation: 9/10 — every checked claim
  held; gap was the carried monitor mechanics never saying `gh run list --commit`
  needs the full sha). `HANDOFFS.md` receipt complete. No new `PROJECT_LEARNINGS.md`
  entry (routine clean push, 8th: S717/S726/S729/S731/S733/S734/S735). quality_ratchet
  at the pushed HEAD `2628cd02`: 1/1 pass · 0 fail · 0 unmeasured · results
  847588b5cc75 · manifest aa983075d6a2 (3,483,944 B ≤ 5,000,000 B). ~2 unpushed after
  close-out (estimate); push is the owner's call.

### 2026-09-20 · [ad hoc] S736 deliverable: push `3b29f498..2628cd02` + CI 4/4 green on the pushed sha — `origin/master` fully current; monitor short-sha blindness found and recorded
- Pushed 3 commits (the 2 unpushed S735 close-out commits — records `1296c6e6`, sha
  `dd8ea5a7` — + the S736 claim `2628cd02` riding the push, S726–S735 precedent). All
  4 push-triggered workflows `completed success` ON THE PUSHED SHA `2628cd02`
  (verified with the FULL sha, `headSha` echoed back structurally): lint 4m56s
  (id 35541807254), pkgdown 7m01s (35541807276), test-coverage 10m02s (35541807240),
  R-CMD-check 17m39s (35541807302) — fastest post-S732-fix figure yet (prior band
  21m28s–22m17s). **Gotcha found:** `gh run list --commit <short-sha>` silently
  returns an empty list — the first Monitor arm was blind for 30 min while CI ran
  green underneath it; poll with the full 40-char sha (`git rev-parse`). Durations
  are createdAt→updatedAt (include queue; seconds ±).

### 2026-09-20 · [ad hoc] S736 claim: owner-directed push to `origin/master` (stub + pending receipt + in-progress ledger entry) *(in progress)*
- Owner picked the push of the 2 unpushed S735 close-out commits (records `1296c6e6`,
  sha `dd8ea5a7`) via the Phase 0 picker. Full 8-step orient ran clean: 0 undocumented
  on both frontiers at `dd8ea5a7`; S735 receipt complete, ratchet citation matches
  results file; CI 4/4 green on `3b29f498`; dashboard 96/100; context budget WARN =
  CLAUDE.md warn band + growth run 13/10 — and the `SESSION_RUNNER.md`/`SAFEGUARDS.md`
  differs-from-canonical flags are GONE this run (both now `synced / canonical ok`;
  working tree clean, no local change — the checker's canonical reference caught up).
  The claim rides the push (S726–S735 precedent) so CI runs on it.

### 2026-09-20 · [ad hoc] S735 close-out sha: `HANDOFFS.md` receipt's `commit:` field set to the records commit `1296c6e6`; carries its own entry, so no self-reference gap is left for Phase 0
- Final S735 commit. S735 total: 3 commits (claim `3b29f498` — rode the push, records
  `1296c6e6`, this one). Ahead of `origin/master` by 2 after close-out, both docs-only;
  CI is current through `3b29f498`, so no urgency — push is the owner's call. Expect 0
  undocumented commits past the frontier at next Phase 0; measure it.

### 2026-09-20 · [ad hoc] S735 close-out: session records (handoff, S734 evaluation 9/10, receipt complete, self 9/10)
- `SESSION_NOTES.md` handoff written (S734 evaluation: 9/10 — every checked claim held
  exactly; lightly exercised, same-conversation pickup). `HANDOFFS.md` receipt
  complete. No new `PROJECT_LEARNINGS.md` entry (routine clean push, 7th:
  S717/S726/S729/S731/S733/S734). quality_ratchet at the pushed HEAD `3b29f498`:
  1/1 pass · 0 fail · 0 unmeasured · results 0c58d203ae28 · manifest aa983075d6a2
  (3,483,951 B ≤ 5,000,000 B). ~2 unpushed after close-out (estimate); push is the
  owner's call.

### 2026-09-20 · [ad hoc] S735 deliverable: push `75d2b049..3b29f498` + CI 4/4 green on the pushed sha — `origin/master` fully current; post-fix R-CMD-check figure confirmed a third time
- Pushed 3 commits (the 2 unpushed S734 close-out commits — records `be4f41ce`, sha
  `12218ad2` — + the S735 claim `3b29f498` riding the push, S726/S729/S731/S733/S734
  precedent). All 4 push-triggered workflows `completed success` ON THE PUSHED SHA
  `3b29f498` (`gh run list --commit`, sha match structural): lint 5m14s
  (id 35539906766), pkgdown 6m04s (35539906763), test-coverage 9m51s (35539906801),
  R-CMD-check 21m28s (35539906788) — the ~21–22 min post-S732-fix figure confirmed
  three times running; single 30-min Monitor arm, no re-arm. Durations are
  createdAt→updatedAt (include queue; seconds ±).

### 2026-09-20 · [ad hoc] S735 claim: owner-directed push to `origin/master` (stub + pending receipt + in-progress ledger entry) *(in progress)*
- Owner directed the push of the 2 unpushed S734 close-out commits (`be4f41ce`,
  `12218ad2`) in the same conversation, immediately after the S734 report. Quick
  mechanical re-orient (state seconds old): ahead 2 confirmed, both ledger frontiers
  reconcile clean. The claim rides the push (S726/S729/S731/S733/S734 precedent) so CI
  runs on it. Phase 3F records the outcome.

### 2026-09-20 · [ad hoc] S734 close-out sha: `HANDOFFS.md` receipt's `commit:` field set to the records commit `be4f41ce`; carries its own entry, so no self-reference gap is left for Phase 0
- Final S734 commit. S734 total: 3 commits (claim `75d2b049` — rode the push, records
  `be4f41ce`, this one). Ahead of `origin/master` by 2 after close-out, both docs-only;
  CI is current through `75d2b049`, so no urgency — push is the owner's call. Expect 0
  undocumented commits past the frontier at next Phase 0; measure it.

### 2026-09-20 · [ad hoc] S734 close-out: session records (handoff, S733 evaluation 9/10, receipt complete, self 9/10)
- `SESSION_NOTES.md` handoff written (S733 evaluation: 9/10 — every checked claim held;
  only gap was two context-budget signals not itemized: growth run 12/10 and
  `SESSION_RUNNER.md`/`SAFEGUARDS.md` "differs from canonical," this session verified
  NOT local edits — both last touched by the S719 forced sync `b773ddb6`, tree clean;
  report-only). `HANDOFFS.md` receipt complete. No new `PROJECT_LEARNINGS.md` entry
  (routine clean push, 6th of its kind: S717/S726/S729/S731/S733). quality_ratchet at
  the pushed HEAD `75d2b049`: 1/1 pass · 0 fail · 0 unmeasured · results 84231b1581ab ·
  manifest aa983075d6a2 (3,483,934 B ≤ 5,000,000 B). ~2 unpushed after close-out
  (estimate); push is the owner's call.

### 2026-09-20 · [ad hoc] S734 deliverable: push `5ed0da83..75d2b049` + CI 4/4 green on the pushed sha — post-fix R-CMD-check duration confirmed a second time
- Pushed 4 commits (the 3 unpushed S733 close-out commits — trim `484c46de`, records
  `6fb68007`, sha `c09d7b5a` — + the S734 claim `75d2b049` riding the push,
  S726/S729/S731/S733 precedent). All 4 push-triggered workflows `completed success`
  ON THE PUSHED SHA `75d2b049` (`gh run list --commit`, sha match structural): lint
  5m11s (id 35536061548), pkgdown 6m03s (35536061442), test-coverage 10m35s
  (35536061510), R-CMD-check 22m17s (35536061496) — the ~21–22 min post-S732-fix
  figure confirmed twice now; single 30-min Monitor arm, no re-arm. Durations are
  createdAt→updatedAt (include queue; seconds ±).

### 2026-09-20 · [ad hoc] S734 claim: owner-directed push to `origin/master` (stub + pending receipt + in-progress ledger entry) *(in progress)*
- Owner picked the push at Phase 0 (AskUserQuestion). 3 unpushed docs-only S733
  close-out commits at claim time; the claim rides the push (S726/S729/S731/S733
  precedent) so CI runs on it. Phase 3F records the outcome.

### 2026-09-20 · [ad hoc] S733 close-out sha: `HANDOFFS.md` receipt's `commit:` field set to the records commit `6fb68007`; carries its own entry, so no self-reference gap is left for Phase 0
- Final S733 commit. S733 total: 4 commits (claim `5ed0da83` — rode the push, trim
  `484c46de`, records `6fb68007`, this one). Ahead of `origin/master` by 3 after
  close-out, all docs-only; CI is current through `5ed0da83`, so no urgency — push is
  the owner's call. Expect 0 undocumented commits past the frontier at next Phase 0;
  measure it.

### 2026-09-20 · [ad hoc] S733 close-out: session records (handoff, S732 evaluation 9/10, receipt complete, self 9/10)
- `SESSION_NOTES.md` handoff written (S732 evaluation: 9/10 — only miss was the ~6
  unpushed estimate undercounting its own trim commit; measured 7); `HANDOFFS.md` receipt
  complete. No new `PROJECT_LEARNINGS.md` entry (routine clean push, 5th of its kind:
  S717/S726/S729/S731); the `methodology_trim.py --cut N` = keep-newest-N semantics note
  and the CHANGED CI-wait mechanics (R-CMD-check now ~21–22 min post-fix, fits one
  30-min Monitor arm) live in the handoff gotchas. quality_ratchet at the pushed HEAD
  `5ed0da83`: 1/1 pass · 0 fail · 0 unmeasured · results 7ced9faa4709 · manifest
  aa983075d6a2 (3,483,941 B ≤ 5,000,000 B). ~3 unpushed after close-out (estimate);
  push is the owner's call.

### 2026-09-20 · [ad hoc] S733 deliverable: push `3b688ae2..5ed0da83` + CI 4/4 green on the pushed sha — first remote validation of the S732 CRAN check-time fix
- Pushed 8 commits (the 7 unpushed S732 commits incl. fix `ba088d0d` touching
  `.R`/`.Rd`, + the S733 claim riding the push — S726/S729/S731 precedent). All 4
  push-triggered workflows `completed success` ON THE PUSHED SHA `5ed0da83`
  (`gh run list --commit`, sha match structural): lint 3m56s (id 35534412900), pkgdown
  6m13s (35534413059), test-coverage 10m33s (35534412911), **R-CMD-check 21m28s
  (35534412936) — down from 33m37s on the previous push `3b688ae2`: the S732 example
  shrink confirmed remote-side, −12 min of CI per push.** The expected 30-min-cap
  monitor re-arm never fired because the check now fits one arm. Durations are
  createdAt→updatedAt (include queue; seconds ±).

### 2026-09-20 · [ad hoc] Ledger trim: `SESSION_NOTES.md` → `docs/archive/SESSION_NOTES-through-2026-09-19-3.md` (14 record(s), 56,599 B → 10,583 B)

**Written by:** `methodology_trim.py` v1.5.0 — a tool action, not a session's judgment.
Moved the oldest **14** record(s) (2026-09-19 → 2026-09-19) out of [`SESSION_NOTES.md`](SESSION_NOTES.md) into
[`docs/archive/SESSION_NOTES-through-2026-09-19-3.md`](docs/archive/SESSION_NOTES-through-2026-09-19-3.md). Losslessness is asserted by L1 (records-zone concatenation), L2 (zone
pinning) and L3 (record partition), and is **re-derivable** — run [`docs/archive/SESSION_NOTES-through-2026-09-19-3.md.verify.sh`](docs/archive/SESSION_NOTES-through-2026-09-19-3.md.verify.sh)
rather than trusting a digest printed here. Live file 56,599 B → 10,583 B (−81.3%).

### 2026-09-20 · [ad hoc] S733 claim: owner-directed push to `origin/master` + CI verification *(in progress)*
- Session claimed after full Phase 0 (reconcile clean: 0 undocumented on both frontiers at
  `ee7cb230`; S732 receipt complete, ratchet citation matches `.quality-gates-results.json`;
  CI 4/4 green on `3b688ae2` + scheduled shinytest2 green; dashboard 96/100; context budget
  WARN = `CLAUDE.md` warn band only; 7 unpushed measured vs S732's ~6 estimate — the delta
  is the S732 HANDOFFS trim commit). Owner picked the push via the Phase 0 picker. Claim
  rides the push so CI runs on it (S726/S729/S731 precedent). Phase 3F records the rest.

### 2026-09-20 · [ad hoc] S732 close-out sha: `HANDOFFS.md` receipt's `commit:` field set to the records commit `e6439a20`; carries its own entry, so no self-reference gap is left for Phase 0
- Final S732 commit. S732 total: 5 commits (claim `e7fe4713`, fix `ba088d0d`, records
  `e6439a20`, trim `e33a7b41`, this one). Ahead of `origin/master` by 6 after close-out —
  the fix commit touches `.R`/`.Rd`, so the next push gets it remote R-CMD-check
  validation; push is the owner's call. Expect 0 undocumented commits past the frontier
  at next Phase 0; measure it.

### 2026-09-20 · [ad hoc] Ledger trim: `HANDOFFS.md` → `docs/archive/HANDOFFS-through-2026-09-19-2.md` (9 record(s), 69,215 B → 28,548 B)

**Written by:** `methodology_trim.py` v1.5.0 — a tool action, not a session's judgment.
Moved the oldest **9** record(s) (2026-09-19 → 2026-09-19) out of [`HANDOFFS.md`](HANDOFFS.md) into
[`docs/archive/HANDOFFS-through-2026-09-19-2.md`](docs/archive/HANDOFFS-through-2026-09-19-2.md). Losslessness is asserted by L1 (records-zone concatenation), L2 (zone
pinning) and L3 (record partition), and is **re-derivable** — run [`docs/archive/HANDOFFS-through-2026-09-19-2.md.verify.sh`](docs/archive/HANDOFFS-through-2026-09-19-2.md.verify.sh)
rather than trusting a digest printed here. Live file 69,215 B → 28,548 B (−58.8%).

### 2026-09-20 · [ad hoc] S732 close-out: fix verified (§7 re-measure — Status OK, >5 s table EMPTY, check CPU 1,032 → 291.6 s); session records
- **Verification at the fix commit `ba088d0d`** (audit §7 clean-export recipe, `NOT_CRAN`
  unset): **Status OK, zero NOTEs, the >5 s examples table is EMPTY** (worst remaining Rd:
  `groupAddAssign` 1.98 s elapsed); examples 743.0 → 9.8 s elapsed over 202 Rd files;
  whole check 1,032 → 291.6 s CPU (4.9 min, −72%), matching the audit's ~5 min
  prediction. Wall 518.8 s (8.6 min) is contention-inflated (load avg 50+, external VM +
  5 Chromium processes; CPU/wall 0.56 vs S730's 0.995) — an upper bound; the CRAN-surface
  test suite ran 0-fail inside the check. T1–T4 cleared. The Finding-4 `skip_on_cran()`
  lever deliberately NOT taken (audit holds it if CRAN's farm ever crowds 10 min).
  Gotcha for §7 reuse: capture `R_LIBS` with `... | tail -1` — renv's out-of-sync banner
  can land on stdout and a polluted `R_LIBS` kills the check in 4 s ("quadprog not
  available"; cost one failed run this session). **Completed BACKLOG item removed**
  (`BACKLOG.md:117`, S686 convention) in this commit. `SESSION_NOTES.md` handoff written
  (S731 evaluation: 9/10; self: 9/10); `HANDOFFS.md` receipt complete. No new
  `PROJECT_LEARNINGS.md` entry (routine Effort-S fix). quality_ratchet at close-out:
  cited in the receipt. ~6 unpushed after close-out (estimate); push is the owner's call.

### 2026-09-20 · [ad hoc] S732 deliverable: CRAN check-time fix — `makePedigreeMatingLayout` example input `examplePedigree` → `smallPed`
- `R/makePedigreeDiagramData.R:1659-1662` roxygen `@examples` + regenerated
  `man/makePedigreeMatingLayout.Rd` (`devtools::document()`, never hand-edited). Input
  choice measured in-session across all shipped pedigrees with the required columns:
  `smallPed` (17 rows) 0.03 s, ZERO warnings/messages — beats the item's named candidate
  `pedWithGenotype` (0.93 s, 5-collision warning), `qcPed` (0.91 s, same warning), and
  `rhesusPedigree` (2.91 s, 72-collision warning); `smallPed` is also the established
  fixture idiom in 13 other roxygen examples. Lint: 0 on the touched file (package
  loaded). Verification = the audit §7 clean-export re-measure, run AFTER this commit
  (the recipe builds from `git archive HEAD`); results in the close-out entry. BACKLOG
  item removal follows the re-measure passing, not this commit.

### 2026-09-20 · [ad hoc] S732 claim: apply the CRAN check-time fix (in progress)
- Session claimed after full Phase 0 (reconcile clean: 0 undocumented on both frontiers at
  `400e226e`; CI 4/4 green on `3b688ae2`; dashboard 96/100; context budget warn-band only;
  2 unpushed docs-only as S731 predicted). Owner picked the `BACKLOG.md:117` READY/S item
  via the Phase 0 picker: shrink the `makePedigreeMatingLayout` roxygen example input
  (`R/makePedigreeDiagramData.R:1659-1662`) + `devtools::document()` + audit §7
  clean-export re-measure. TDD N/A (doc-only `.Rd` example change; the re-measure is the
  verification gate per the item). Close-out records the rest.
- Final S731 commit. S731 total: 3 commits (claim `3b688ae2` — rode the push, records
  `f5656164`, this one) + the push itself (a non-commit action, its own entry below). Ahead
  of `origin/master` by 2 after close-out — both docs-only, push is the owner's call. Expect
  0 undocumented commits past the frontier at next Phase 0; measure it.

### 2026-09-20 · [ad hoc] S731 close-out: session records (handoff, S730 evaluation 9/10, receipt complete, self 9/10)
- `SESSION_NOTES.md` handoff written (evaluation of S730: 9/10; self-assessment: 9/10);
  `HANDOFFS.md` receipt overwritten to `status: complete` with the six requirements filled.
  quality_ratchet at the pushed HEAD `3b688ae2`: 1/1 pass · 0 fail · 0 unmeasured ·
  results 24c0d9475ec1 · manifest aa983075d6a2 (tarball 3,483,933 B ≤ 5,000,000 B). No new
  `PROJECT_LEARNINGS.md` entry (routine push session, S729 precedent). No BACKLOG item
  consumed. Next natural pickup: the READY/S apply-the-CRAN-check-time-fix item
  (`BACKLOG.md:117`). ~2 unpushed after close-out (estimate at write time); push is the
  owner's call.

### 2026-09-20 · [ad hoc] S731 deliverable: push to origin/master + CI verification — 4/4 workflows green on the pushed sha
- **Pushed `0572767b..3b688ae2`** (9 commits: the 8 unpushed S730 docs-only commits + the
  S731 claim riding the push — S729/S726/S717 precedent). All 4 push-triggered workflows
  `completed success` ON THE PUSHED SHA `3b688ae2` (verified via
  `gh run list --commit <sha>`): lint 4m26s (id 35490394639), test-coverage 8m41s
  (35490394613), pkgdown 18m05s (35490394612), R-CMD-check 33m37s (35490394609). Puts the
  S730 CRAN check-time audit and full S730 close-out record set on the remote. The push is
  a non-commit action; this entry is its ledger record.

### 2026-09-19 · [ad hoc] S731 claim: owner-directed push to origin/master (stub + pending receipt + in-progress ledger entry)
- Session claimed. Deliverable (in progress): push the 8 unpushed docs-only S730 commits to
  `origin/master` (this claim commit rides the push, making 9 — S729/S726/S717 precedent, so
  CI runs on the pushed sha) and verify all 4 push-triggered workflows `completed success` on
  that sha. Phase 3F records the rest. Until close-out, this entry is the crash breadcrumb.

### 2026-09-19 · [ad hoc] S730 close-out sha: `HANDOFFS.md` receipt's `commit:` field set to the records commit `fcf6790b`; carries its own entry, so no self-reference gap is left for Phase 0
- Final S730 commit. S730 total: 4 commits (claim `c8397845`, deliverable `e8a0eca7`, records
  `fcf6790b`, this one). Ahead of `origin/master` by 8 after close-out — all docs-only, push
  is the owner's call. Expect 0 undocumented commits past the frontier at next Phase 0;
  measure it.

### 2026-09-19 · [ad hoc] S730 close-out: session records (handoff, S729 evaluation 9/10, receipt complete, self 9/10)
- `SESSION_NOTES.md` handoff written (evaluation of S729: 9/10; self-assessment: 9/10);
  `HANDOFFS.md` receipt overwritten to `status: complete` with the six requirements filled.
  quality_ratchet at the deliverable HEAD `e8a0eca7`: 1/1 pass · 0 fail · 0 unmeasured ·
  results 10bcea6e4007 · manifest aa983075d6a2 (tarball 3,485,180 B ≤ 5,000,000 B). No new
  `PROJECT_LEARNINGS.md` entry (routine measurement session; forward-carrying homes are the
  audit + the rewritten `BACKLOG.md:117` item). Next natural pickup: the READY/S
  apply-the-fix item. ~8 unpushed after close-out (estimate at write time); push is the
  owner's call.

### 2026-09-19 · [ad hoc] S730 deliverable: CRAN check-time audit — one example is 71% of the whole check
- **`docs/audits/CRAN_CHECK_TIME_AUDIT_2026-09-19.md`.** Full `R CMD check --timings` of the
  clean-export tarball (3,485,111 B at `c8397845`), CRAN surface (no `NOT_CRAN`): **Status OK,
  1,037 s wall / 1,032 s CPU (17.3 min)** on M2 Max / R 4.6.1 — of which **734.1 s is the single
  `makePedigreeMatingLayout` Rd example** (full 3,694-row `examplePedigree`; ~147× the 5 s
  per-Rd threshold; the app's own diagram cap is 750, `R/modPedigree.R:406`). Other 201 timed
  examples: 8.9 s combined. Tests: 215 s under check, 0 fail; identical-currency comparison
  measured ~14% of local test blocks staying home on CRAN (2,437/184 baseline reproduced
  exactly vs 2,141/200 CRAN-surface). Verified at source: CRAN policy rev 6875; the 5 s
  threshold and `\donttest`-still-runs-at-incoming in `tools/R/check.R`; the 10-min incoming
  "Overall checktime" NOTE (R-pkg-devel). Measured remedy: `pedWithGenotype` input → 1.0 s
  (~17.3 min → ~5 min total). Research only — no remedy applied, no `.R`/`man/` change; TDD
  N/A; lint N/A. BACKLOG: measure-first item removed (complete), replaced by the READY/S
  apply-the-fix item carrying the numbers (S686 convention).

### 2026-09-19 · [ad hoc] S730 claim: CRAN check-time measurement audit (in progress)
- Session claimed for the `BACKLOG.md:117` item (owner-requested mid-S729). Measurement/research
  only: `R CMD check --timings` per-Rd example times + a suite run WITHOUT `NOT_CRAN=true` so
  `skip_on_cran()` exclusions match CRAN's; remedies weighed in the audit report, none applied.
  Stub + pending `HANDOFFS.md` receipt ride this commit; close-out records the rest.

### 2026-09-19 · [ad hoc] S729 close-out sha: `HANDOFFS.md` receipt's `commit:` field set to the records commit `2b6ccc45`; carries its own entry, so no self-reference gap is left for Phase 0
- Final S729 commit. S729 total: 5 commits (claim `0572767b`, pushed and CI-validated; filing
  `c9c946f7`; records `2b6ccc45`; trim `10016a8e`; this one). Ahead of `origin/master` by 4
  after close-out (the trim made it 4, not the ~3 the handoff estimated) — all docs-only,
  push is the owner's call. Expect 0 undocumented commits past the frontier at next Phase 0;
  measure it.

### 2026-09-19 · [ad hoc] Ledger trim: `CHANGELOG.md` → `docs/archive/CHANGELOG-through-2026-09-19-2.md` (31 record(s), 66,352 B → 33,624 B)

**Written by:** `methodology_trim.py` v1.5.0 — a tool action, not a session's judgment.
Moved the oldest **31** record(s) (2026-09-19 → 2026-09-19) out of [`CHANGELOG.md`](CHANGELOG.md) into
[`docs/archive/CHANGELOG-through-2026-09-19-2.md`](docs/archive/CHANGELOG-through-2026-09-19-2.md). Losslessness is asserted by L1 (records-zone concatenation), L2 (zone
pinning) and L3 (record partition), and is **re-derivable** — run [`docs/archive/CHANGELOG-through-2026-09-19-2.md.verify.sh`](docs/archive/CHANGELOG-through-2026-09-19-2.md.verify.sh)
rather than trusting a digest printed here. Live file 66,352 B → 33,624 B (−49.3%).

### 2026-09-19 · [ad hoc] S729 close-out: push DONE (13 commits, 4/4 CI green on `0572767b` — first remote validation of S728 incl. the first quality-gate manifest) + session records
- **Deliverable:** pushed `9006b567..0572767b`; all 4 push-triggered workflows `completed
  success` on the pushed sha exactly (jq `headSha` filter): lint 4m49s (35485603669),
  test-coverage 9m39s (35485603670), pkgdown 18m32s (35485603680), R-CMD-check 33m54s
  (35485603672). Background poller from the first attempt (35 polls, ~35 min).
- **Records:** `SESSION_NOTES.md` S729 handoff + S728 evaluation (9/10 — the push decision
  named with the exact recount command, measured 12 vs predicted ~12; the ratchet-after-commit
  gotcha applied cleanly); `HANDOFFS.md` receipt complete (self 9/10 — abbreviated Phase 0
  re-verification recorded honestly as the main minus); no new learning (routine clean push,
  S726 precedent).
- **Receipt citation** (run at `c9c946f7`): quality_ratchet: 1/1 pass · 0 fail · 0 unmeasured
  · results `a39b6c231e42` · manifest `aa983075d6a2` (gate measured 3,485,202 B).
- **Post-append measurements** (`--budget-bytes 65536`): SESSION_NOTES 36,997 B and HANDOFFS
  56,465 B — no trigger; CHANGELOG was 64,861 B BEFORE this entry (~675 B from its trigger),
  so the trigger state is re-checked after this append and any owed trim lands as its own
  commit (S727 precedent). context_budget: no file over ceiling (`CLAUDE.md` warn band,
  documented headroom).

### 2026-09-19 · [ad hoc] S729 mid-session owner request filed (not acted on — 1-and-done, S726 precedent): BACKLOG item to see if example/test code can run shorter for CRAN submission needs
- New Up Next item (READY, Effort M): measure-first mandate on the CRAN-visible surface —
  `R CMD check --timings` for per-Rd example times (incoming checks NOTE > 5 s), and a suite
  run WITHOUT `NOT_CRAN=true` so `skip_on_cran()` exclusions match CRAN's, with per-file wall
  times; remedy candidates (`\donttest{}`, smaller example inputs, `skip_on_cran()` on tests
  that duplicate CI coverage, shared fixtures) explicitly deferred to after measurement.
  Filed while the S729 push's CI verification poller runs.

### 2026-09-19 · [ad hoc] S729 claim: owner-directed push to origin/master + CI verification (stub + pending receipt + this in-progress entry)
- Deliverable (in progress): push the 12 unpushed S726–S728 docs/config commits + this claim
  (13 total; the claim rides the push so CI runs on it — S717/S726 precedent), then verify all
  4 push-triggered workflows green on the pushed sha exactly. First remote validation of the
  S728 build-hygiene work (ignore entries + the first `.quality-gates.json` manifest).

### 2026-09-19 · [ad hoc] S728 close-out sha: `HANDOFFS.md` receipt's `commit:` field set to the records commit `facc4df1`; carries its own entry, so no self-reference gap is left for Phase 0
- Final S728 commit. S728 total: 4 commits (claim `f82f978a`; deliverable `2570645b`; records
  `facc4df1`; this one). Ahead of `origin/master` by 12 after close-out (8 pre-existing + these
  4) — all docs/config-only, push is the owner's call; the push also puts the first quality-gate
  manifest on the remote. Expect 0 undocumented commits past the frontier at next Phase 0;
  measure it.

### 2026-09-19 · [ad hoc] S728 close-out: tarball build-hygiene DONE + session records (handoff, S727 evaluation 9/10, receipt, Learning 772)
- **Records:** `SESSION_NOTES.md` S728 handoff + S727 evaluation (9/10 — its next-step (A) WAS
  this session's deliverable, the `BACKLOG.md:100` block was the execution plan verbatim, and
  every checked claim held); `HANDOFFS.md` receipt complete (self 9/10);
  `PROJECT_LEARNINGS.md` Learning 772 (gate-author mechanics: a gate measuring
  `git archive HEAD` measures the last commit, so run `--run` AFTER committing; the 600 s
  per-gate timeout fits a build gate; a self-tagged extract marker survives chatty tooling).
- **Receipt citation** (run at the deliverable HEAD `2570645b`): quality_ratchet: 1/1 pass ·
  0 fail · 0 unmeasured · results `ef8070eeb6c7` · manifest `aa983075d6a2` — the new gate's
  first citation-of-record, measured 3,485,027 B against the 5,000,000 B threshold.
- **Post-append measurements** (`--budget-bytes 65536`): no trigger fires — SESSION_NOTES
  31,480 B, HANDOFFS 52,085 B, CHANGELOG 61,770 B pre-entry (CHANGELOG is ~3.7 KB from its
  trigger — expect it to fire within a session or two). context_budget: no file over ceiling
  (`CLAUDE.md` warn band, documented headroom).

### 2026-09-19 · [ad hoc] S728 deliverable: tarball build-hygiene follow-ups DONE — leak closed in both ignore files, testthat debris ignored, 5 MB clean-export size gate live (first declared quality gate)
- **`.Rbuildignore`:** the owner's pending `^scratchpad$` line committed (owner-directed via
  picker; the measured fix for the 19.7 MB working-tree leak, S727 audit Finding 1), plus
  `^tests/testthat/_problems$` and `^tests/testthat/testthat-problems\.rds$` (Finding 2).
- **`.gitignore`:** `scratchpad/` (owner accepted the documented ghost-check tradeoff) plus the
  two testthat-debris paths.
- **`.quality-gates.json`:** first gate declared — `tarball_size_clean_export`, max 5,000,000 B
  measured on a `git archive HEAD` clean-export `pkgbuild::build()` (audit §7 recipe, Finding 5
  remedy). Exercised in-session at `f82f978a`: **1/1 pass, measured 3,485,137 B** (results
  `16f2d705768f` · manifest `aa983075d6a2`).
- **Verification:** `git check-ignore -v` resolves all three paths to the new `.gitignore`
  lines; `tools:::inRbuildignore` TRUE on each real path (`scratchpad`,
  `tests/testthat/_problems`, `tests/testthat/testthat-problems.rds` — directory matches prune
  contents, the semantics S727's 3.56 MB working-tree build measured); `git status` untracked
  noise now only the 5 known planning/article files. No `.R` files touched — TDD N/A, lint N/A,
  suite baseline 2437/0/0/184/0 carries forward (Learning 764 scope rule).
- **BACKLOG:** completed item's block removed in this commit (S686 convention); its still-open
  step 4 (optional `inst/doc` slimming via `html_vignette`, Effort M) extracted as its own
  DECISION-NEEDED item in place.

### 2026-09-19 · [ad hoc] S728 claim: tarball build-hygiene follow-ups (stub + pending receipt + this in-progress entry)
- Deliverable (in progress): `BACKLOG.md:100` steps 1–3 — commit the owner's `.Rbuildignore`
  `+^scratchpad$` line (owner-directed via Phase 0/1 picker), git-ignore `scratchpad/`
  (owner: yes, accepting the documented ghost-check tradeoff), add the testthat-debris paths
  (`tests/testthat/_problems/`, `testthat-problems.rds`) to `.Rbuildignore`/`.gitignore`,
  and declare a clean-export tarball-size gate (≤5 MB) in `.quality-gates.json` (owner: yes).
  Step 4 (inst/doc slimming) stays deferred — its own session per the item.

### 2026-09-19 · [ad hoc] S727 close-out sha: `HANDOFFS.md` receipt's `commit:` field set to the records commit `66d4116b`; carries its own entry, so no self-reference gap is left for Phase 0
- Final S727 commit. S727 total: 5 commits (claim `f8ffa40b`; deliverable `6d221ddc`; trim
  `1a5f345e`; records `66d4116b`; this one). Ahead of `origin/master` by 8 after close-out
  (3 pre-existing S726 + these 5) — all docs-only, push is the owner's call. The owner's
  `.Rbuildignore` `+^scratchpad$` edit remains uncommitted by design. Expect 0 undocumented
  commits past the frontier at next Phase 0; measure it.

### 2026-09-19 · [ad hoc] S727 close-out: tarball-size audit DONE + session records (handoff, S726 evaluation 9/10, receipt, Learning 771)
- **Records:** `SESSION_NOTES.md` S727 handoff + S726 evaluation (9/10 — its measure-first
  mandate was this session's method and its self-assessment honestly flagged the ~19 MB as
  unmeasured; nobody S721–S726 connected the long-carried `scratchpad` check NOTE to the
  artifact); `HANDOFFS.md` receipt complete (self 8/10); `PROJECT_LEARNINGS.md` Learning 771
  (a top-level-directory check NOTE means the directory ships; three artifacts share one
  name; compressed bytes are the currency).
- **Why the trim entry below exists:** the handoff took `SESSION_NOTES.md` to 57,111 B — past
  `context_budget.py`'s 25,000-token read cap (56,750 B at 2.27 B/token; hook-enforced) while
  the trimmer at `--budget-bytes 65536` reported NOTHING_TO_DO. Trimmed with an explicit
  `--cut 5` (budget flag still passed, no `--force`), on the committed pre-handoff state.
  **Finding, report-only:** the two `SESSION_NOTES.md` ceilings differ in practice (56,750 B
  vs 65,536 B); `CLAUDE.md`'s "deliberately the same number" holds for `max_bytes` only.
  Owner decision: align the trim budget to 56,750 B, or keep the explicit-cut workaround.
- **Post-append measurements** (`--budget-bytes 65536`): no trigger fires —
  SESSION_NOTES 24,540 B, HANDOFFS 46,707 B, CHANGELOG 56,646 B pre-entry (CHANGELOG is
  ~9 KB from its trigger). context_budget: no file over ceiling (`CLAUDE.md` warn band,
  unchanged 26,360 B). quality_ratchet: 0/0 pass · 0 fail · 0 unmeasured · results
  4f53cda18c2b · manifest 4f53cda18c2b.
- **Non-commit actions this session:** none (no push, no issue/PR/tag activity). Read-only
  outside the repo: `../nprcgenekeepr_2.0.0.9000.tar.gz` and `../nprcgenekeepr.Rcheck/00check.log`
  were listed/grepped, never modified; CRAN policy page and the CRAN 2.0.0 tarball header
  fetched; CI run 35481710058's log read via `gh`.
- **Still uncommitted, deliberately:** the owner's `.Rbuildignore` `+^scratchpad$` line.
  Unpushed after close-out: ~8 docs-only commits — owner push decision.

### 2026-09-19 · [ad hoc] Ledger trim: `SESSION_NOTES.md` → `docs/archive/SESSION_NOTES-through-2026-09-19-2.md` (10 record(s), 49,225 B → 15,427 B)

**Written by:** `methodology_trim.py` v1.5.0 — a tool action, not a session's judgment.
Moved the oldest **10** record(s) (2026-09-19 → 2026-09-19) out of [`SESSION_NOTES.md`](SESSION_NOTES.md) into
[`docs/archive/SESSION_NOTES-through-2026-09-19-2.md`](docs/archive/SESSION_NOTES-through-2026-09-19-2.md). Losslessness is asserted by L1 (records-zone concatenation), L2 (zone
pinning) and L3 (record partition), and is **re-derivable** — run [`docs/archive/SESSION_NOTES-through-2026-09-19-2.md.verify.sh`](docs/archive/SESSION_NOTES-through-2026-09-19-2.md.verify.sh)
rather than trusting a digest printed here. Live file 49,225 B → 15,427 B (−68.7%).

### 2026-09-19 · [ad hoc] S727 deliverable: tarball-size audit — the "~19 MB tarball" is a `scratchpad/` leak; the real package builds to 3.49 MB (`docs/audits/TARBALL_SIZE_AUDIT_2026-09-19.md`)
- **Headline (all measured, none estimated):** clean `git archive HEAD` build =
  **3,485,185 B** (35% of CRAN's 10 MB line; CRAN 2.0.0 = 2,419,329 B, so +1.07 MB / +44%
  since release). The owner's `../nprcgenekeepr_2.0.0.9000.tar.gz` = 19,732,245 B and lists
  252 `scratchpad/` entries (19.99 MB uncompressed; untracked dir, 250 files, 16.3 MB
  compressed — two 5.6 MB `.rds` captures + 65 PNGs). Controlled reproduction (clean export
  + `scratchpad/` + untracked testthat debris, committed `.Rbuildignore`) = 19,714,510 B —
  matches to 0.1%. `git log -S'scratchpad' -- .Rbuildignore` is empty: it was never excluded.
  Current working tree (with the owner's UNCOMMITTED `+^scratchpad$`) = 3,564,041 B; the
  +78,856 B over clean is `tests/testthat/_problems/` + `testthat-problems.rds` (untracked,
  neither git- nor build-ignored).
- **Inventory:** 997 entries, 12.01 MB uncompressed. Compressed shares: `inst/doc` 1.37 MB
  (38% — three `html_document` vignettes; `a2interactive.html` alone 855 KB), `tests` 0.66,
  `inst/extdata/examples` 0.46, `R` 0.39, `man` 0.31, `data` 0.14. CRAN sub-limits: data
  2.66 MB pass; documentation 4.38 MB `inst/doc` = 86% of the 5 MB guideline (borderline);
  installed size 8.9 MB local / 9.5–10.2 MB on CI run 35481710058 (`INFO`).
- **Findings:** 0 critical · 2 moderate (scratchpad leak; doc-guideline headroom) · 3 minor
  (testthat debris ships; installed size; no mechanical size gate). Policy text verified at
  source (CRAN Repository Policy rev. 6875). No remedy applied — research-only deliverable.
- **BACKLOG:** the S726 Effort-L "reduce tarball size" item REMOVED (premise refuted by
  measurement) and replaced by a DECISION-NEEDED Effort-S build-hygiene follow-up item
  carrying the ranked actions; package-split item's cross-ref rewritten ("size is not an
  argument for splitting" — all of `R/` is 0.39 MB compressed); pedigree-growth item given
  the +1.07 MB upper bound. Stale-reference sweep of `BACKLOG.md`/`ROADMAP.md`: none left.
- No `.R` files touched (no TDD phases, lint N/A). The owner's uncommitted `.Rbuildignore`
  edit was left untouched and is not in this commit. All builds ran in the session scratch
  directory; nothing written to the repo or `..` besides the three files in this commit.

### 2026-09-19 · [ad hoc] S727 claim: tarball-size audit (in progress)
- Owner picked "Tarball-size research" from the Phase 0 4-option picker. Deliverable: one
  audit report — a measured `R CMD build` contents inventory (bytes attributed to files
  that actually ship) + ranked remedy candidates; no remedies applied this session.
  Pre-existing uncommitted `.Rbuildignore` change (`^scratchpad$`, not session-made) left
  untouched and excluded from this commit. Close-out adds its own entry.

### 2026-09-19 · [ad hoc] S726 close-out sha: `HANDOFFS.md` receipt's `commit:` field set to the records commit `211f8786`; carries its own entry, so no self-reference gap is left for Phase 0
- Final S726 commit. S726 total: 4 commits (claim `9006b567` — pushed, CI-validated;
  BACKLOG filing `f8970edc`; records `211f8786`; this one). Ahead of `origin/master` by 3
  after close-out — push is the owner's call, all docs-only. Expect 0 undocumented commits
  past the frontier at next Phase 0; measure it.

### 2026-09-19 · [ad hoc] S726 close-out: push DONE (33 commits `4565c39d..9006b567`, 4/4 CI green on the pushed sha) + session records
- **Deliverable verified:** all 4 push-triggered workflows `completed success` filtered on
  `headSha == 9006b567` (R-CMD-check 31m53s, pkgdown 13m47s, test-coverage 10m4s, lint
  4m37s; run ids 35481709978–35481710058). First remote validation of S720–S725: the
  warning-free suite, the Suggests trim + renv re-snapshot, the context-budget adoption,
  the CLAUDE.md reduction, the `~$` guards.
- **Records:** SESSION_NOTES S726 handoff + S725 evaluation (9/10, one superseded-at-write
  gotcha noted, self-corrected by S725's own addendum entry); HANDOFFS receipt complete;
  no new PROJECT_LEARNINGS entry (routine clean push; the tarball-inventory insight lives
  in the filed BACKLOG item, its forward-carrying home).
- **Post-append trigger measurements** (`--budget-bytes 65536`): no trim fires on
  SESSION_NOTES/HANDOFFS/CHANGELOG. quality_ratchet: 0/0 pass · 0 fail · 0 unmeasured ·
  results 4f53cda18c2b · manifest 4f53cda18c2b.
- Unpushed after close-out: ~3 docs-only commits (BACKLOG filing + records + sha) — owner
  push decision; expect 0 undocumented commits past the frontier at next Phase 0.

### 2026-09-19 · [ad hoc] S726 mid-session owner request: tarball-size-reduction item filed in `BACKLOG.md` Up Next (READY, Effort L)
- Owner reports the source tarball at ~19 MB vs CRAN policy's ≤10 MB ("should, if
  possible"; data ≤5 MB, documentation ≤5 MB generally) and steers that slimming
  examples/test data may beat the package split; extensive code research required first.
- Item filed with a measure-first mandate (`R CMD build` + `tar tzvf` inventory — on-disk
  sizes mislead because `.Rbuildignore` already excludes `docs/`, `vignettes/articles/`,
  and several reference files), S726 quick size anchors, the remedy candidate list, and
  cross-references both ways with the package-split investigation item (S667 scoping rec
  "do not split now", owner disposition pending) and the pedigree-growth measurement item.
- Filed only, not acted on (1-and-done; S721 `ede5289e` precedent for mid-session filings).

### 2026-09-19 · [ad hoc] S726 claim: owner-directed push to `origin/master` (in progress)
- Owner picked "Push to origin" from the Phase 0 4-option picker. 32 unpushed commits
  (S720–S725) at claim time; this claim commit rides the push, so CI runs on it (S717
  precedent). Deliverable: push + all 4 push-triggered workflows green. Close-out adds
  its own entry.

### 2026-09-19 · [ad hoc] S725 post-close-out, owner-directed: recurring Word lock file `inst/extdata/reference/~$e Compounding Loop.html` deleted; standing `~$` guards added to `.Rbuildignore` and `.gitignore`
- Owner picked "delete + Rbuildignore guard" from the close-out `AskUserQuestion`. The file
  was a 162-byte Microsoft Word owner/lock file (contents: just the Office username) for the
  local-only `The Compounding Loop.html`; first deleted S568, recreated 2026-08-18 by a later
  Word open, and flagged by local `devtools::check()` as a non-portable filename because
  `R CMD build` copies the working tree (never committed — `git log --all` on the path is
  empty, so the `rm` is a non-commit action recorded here).
- **Guards (the new part beyond S568's plain delete):** `.Rbuildignore` gains unanchored
  `~\$` (paren-free per the file's own regex-safety rule); `.gitignore` gains `~$*` in the
  same reference-file section, mirroring the S497/S567/S568 pairing precedent.
- **Verified on a probe lock file** (`~$probe.txt`, created then removed):
  `git check-ignore -v` matched `.gitignore:91:~$*`, and R's own `tools:::inRbuildignore()`
  — the code path `R CMD build` uses — returned TRUE. The next local `devtools::check()`
  should drop the non-portable-filename warning; the known warn/exit-1 gotcha recorded in
  S724/S725 handoffs is thereby expected to clear (next check run confirms).

### 2026-09-19 · [ad hoc] S725 close-out sha: `HANDOFFS.md` receipt's `commit:` field set to the records commit `6d890617`; carries its own entry, so no self-reference gap is left for Phase 0
- Final S725 commit. S725 total: 4 commits (claim `1ef168b8`, deliverable `c8512d0d`,
  records `6d890617`, this one); ahead of `origin/master` by 31 including the 27
  pre-existing — push is the owner's call. Expect 0 undocumented commits past the
  frontier at next Phase 0; measure it.

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

