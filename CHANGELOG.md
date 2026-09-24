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

**Archived 172 record(s), 2026-09-19 → 2026-09-21** into [`docs/archive/CHANGELOG-through-2026-09-21.md`](docs/archive/CHANGELOG-through-2026-09-21.md) — same format, same order, frozen.
Losslessness is proved by [`docs/archive/CHANGELOG-through-2026-09-21.md.verify.sh`](docs/archive/CHANGELOG-through-2026-09-21.md.verify.sh), which re-derives L1/L2/L3 from git; run it rather
than trusting this sentence. Written by `methodology_trim.py` v1.5.0.

**Archived 52 record(s), 2026-09-21 → 2026-09-23** into [`docs/archive/CHANGELOG-through-2026-09-23.md`](docs/archive/CHANGELOG-through-2026-09-23.md) — same format, same order, frozen.
Losslessness is proved by [`docs/archive/CHANGELOG-through-2026-09-23.md.verify.sh`](docs/archive/CHANGELOG-through-2026-09-23.md.verify.sh), which re-derives L1/L2/L3 from git; run it rather
than trusting this sentence. Written by `methodology_trim.py` v1.5.0.

### 2026-09-24 · [ad hoc] Pushed `af4f1eca..59cb4406` to `origin/master` (6 docs-only commits); CI not awaited
- **Action:** `git push origin master` -- 6 commits: `c182511b` (removed `nprcgenekeepr_notes.txt`),
  `cb079f6b` (ledger entries for the previous push and that removal), and `c67a3106`, `ab50aed1`,
  `0cc75dc4`, `59cb4406` (the four `BACKLOG.md` passes, each with its own ledger entry).
  Owner-directed ("push;"), after the plan had been reviewed and picked from a menu. **Before the
  push:** `git fetch` showed origin at `af4f1eca`, an ancestor of HEAD (fast-forward); the outgoing
  diff was 3 files (`BACKLOG.md`, `CHANGELOG.md`, `nprcgenekeepr_notes.txt` deleted), +198/-261,
  with no secret-named files and no credential-shaped strings in the added lines. **After:** local
  and `origin/master` both at `59cb4406`.
- **CI:** the four push workflows (lint, pkgdown, R-CMD-check, test-coverage) run automatically on
  every push to master -- none has a `paths-ignore` filter. **Not awaited, at the owner's direction**
  ("do not wait for an uninformative CI"): every changed file is matched by `.Rbuildignore`
  (`^BACKLOG.*\.md$`, `^CHANGELOG.*\.md$`, `^nprcgenekeepr_notes\.txt$`) and no test or workflow
  reads any of them, so a green run could not say anything the previous one did not (`af4f1eca`, all
  four `success`). **State when this entry was written (one query, no waiting):** lint and pkgdown
  `completed success`; R-CMD-check and test-coverage `in_progress`.
- **Session:** none -- owner-directed, outside a numbered session (follows S778) · **Verified:** the
  pre-push checks above only; the local suite was not run (no package code changed).
- **Not pushed:** `8a616f15` (the `BACKLOG.md` cut and the NEW-53 backfill) and the commit carrying
  this entry are local.

### 2026-09-24 · [ad hoc] `BACKLOG.md`: deleted the three resolved sections (Architecture #122 stub, Audit follow-ups, Genetic-metrics)
- **Change:** `BACKLOG.md` now ends at `## Outreach` (432 -> 378 lines, 34,814 -> 30,875 B; 561
  lines and about 45 KB at the start of the day's review). Removed, at the owner's direction ("if the
  work really was done, it should be in `CHANGELOG.md`"): (1) **`## Architecture (issue #122 /
  XARCH-2 -- module contract)`**, 6 lines -- resolved; the full record is the 7 `[issue #122]`
  entries (plan S372, Phases 1-5 S373-S377, and the issue close, 2026-07-14); the living contract
  stays at `docs/architecture/module-contract.md`, referenced from
  `tests/testthat/test_moduleContract.R`, `R/modInput.R`, two other module tests and planning docs;
  (2) **`## Audit follow-ups`**, 4 lines -- born already resolved in the Session 10 split; 7 of the 8
  items it began with appear in the ledger (by ID or by name; mention counts, not each entry read),
  as do the two it gained later (NEW-22, NEW-46), and the eighth, NEW-53, is backfilled by the
  entry beside this one; its pointer to "`CLAUDE.md` Project-specific Learnings" was stale
  (`CLAUDE.md` holds 0 Learnings; they live in `PROJECT_LEARNINGS.md`); (3) **`## Genetic-metrics
  PDF audit follow-ups`**, 45 lines -- all 14 issues (#125-#130, #146-#153) CLOSED with 69
  `[issue #N]` ledger entries (#128 was implemented and closed in S427). Recoverable with
  `git show 59cb4406:BACKLOG.md`. The S518 housekeeping item's pass history and candidates were
  updated (candidates: none; the next pass is a regrowth check).
- **Commit:** this commit -- `BACKLOG.md` and this entry plus the NEW-53 backfill entry. **Local,
  not pushed.**
- **Session:** none -- owner-directed, outside a numbered session (follows S778) · **Verified:**
  `gh issue view` gives #122 and #125-#130, #146-#153 all CLOSED; the per-issue tagged-entry
  counts are #125=3, #126=2, #127=2, #128=2, #129=3, #130=6, #146=3, #147=3, #148=14, #149=3,
  #150=3, #151=3, #152=9, #153=13; every Learning the deleted text cited (479, 532, 538-542)
  resolves in `PROJECT_LEARNINGS.md` and the 7 docs it cited exist; the sessions it cited (S419,
  S422, S479, S483, S517, S525-S535, S703-S708) all appear in the ledger; the deleted region held
  no `- [ ]` item (asserted before deleting) and every remaining `##` section holds at least one.
  **Limits:** only 21 of the PED_GV audit's 63 finding IDs appear in the ledger, and most of the
  rest were never queued in `BACKLOG.md` -- this cut makes no claim about them; the "Audit
  follow-ups" history was scanned from the section's earliest versions, not every version. **Not
  run:** the test suite and `devtools::check()` -- no package code changed.

### 2026-09-24 · [ad hoc] Backfill: NEW-53 (sim/parent functions mutated the caller's pedigree) was fixed 2026-05-31 with no ledger entry
- **Change:** records an action the ledger was missing (failure mode #27). On 2026-05-31, commit
  `5f40b7af` replaced `data.table::setDT(ped)` with `ped <- data.table::as.data.table(ped)` in
  `makeSimPed()`, `getPotentialParents()` and `createSimKinships()`, so calling them no longer
  silently turns the caller's data.frame into a data.table (a value-semantics violation that
  changes the caller's later `[` behavior). The commit also found two of the audit's stronger
  claims empirically false -- "sire/dam overwritten" (`makeSimPed`) and "adds a population column
  in place" (`createSimKinships`): only the class leaked, content was preserved and
  `makeSimPed()`'s deterministic output stayed byte-identical. A caller-non-mutation regression
  test went into each function's test file, `@importFrom setDT` became `@importFrom as.data.table`
  and `NAMESPACE` was regenerated (one now-unused import dropped). Verification recorded in that
  commit's message: full suite 0 failed / 0 error / 1943 passed; lint 0.
- **Commit/PR:** `5f40b7af` (2026-05-31). This entry's own commit only adds the record.
- **Session:** none identified -- the fix sits between the Session 10 methodology update and the
  Session 13 close-out (`89fc37cf`, the same day); the ledger has entries for both and none for
  this fix. **Origin of the gap:** it was the NEW-53 item under `BACKLOG.md`'s "Audit follow-ups"
  section and was removed with no completion entry; found 2026-09-24 while checking that section
  against the ledger before deleting it. · **Verified today (read-only):** all three functions
  still use `as.data.table(ped)` and none uses `setDT`; the three regression tests still exist
  (`test_makeSimPed.R:122`, `test_getPotentialParents.R:108`, `test_createSimKinships.R:74`).
  **Not re-run:** the suite -- no code changed.

### 2026-09-24 · [ad hoc] `BACKLOG.md`: the "one fewer node" item rewritten with its measured cause (row order, not a dropped row)
- **Change:** the open item about the app's uploaded/QC'd copy of `obfuscated_rhesus_mhc_ped.csv`
  drawing a different Diagram than the same CSV read directly (found S472, "cause not
  investigated") now states what was measured, and stays open as a decision. **Refuted:** the
  hypothesis that `qcStudbook()` drops or merges a row -- it keeps all 375 rows and ids (none
  lost or added, 0 duplicates) and `makePedigreeDiagramData()` returns the same 375 nodes / 502
  edges for both inputs. **Found:** `qcStudbook()` reorders the rows, and the mating layout
  depends on row order -- `makePedigreeMatingLayout()` gives 782 nodes for both inputs under
  `edgeStyle = "direct"` but **1456 (raw order) vs 1412 (QC order)** under `"rectilinear"`, and
  the raw content re-ordered to QC's row order gives exactly 1412. The S472 figures (739 vs 740;
  50 vs 51) no longer reproduce because the layout changed since (e.g. Track 4, S573). Open for the
  owner: whether that row-order dependence is acceptable, and whether the bundled-fixture e2e
  tests should assert the QC'd count.
- **Commit:** this commit -- `BACKLOG.md` and this entry only. **Local, not pushed.**
- **Session:** none -- owner-directed, outside a numbered session (follows S778) · **Verified:**
  `Rscript` with `pkgload::load_all()`: the counts above were computed directly, on the bundled
  fixture, with `qcStudbook()`'s default arguments. **Limits, stated so the item is not
  over-read:** the cause is "order alone reproduces the QC'd count", not "order is the only
  difference" -- the re-ordered raw data is not `all.equal` to the QC'd data on
  id/sire/dam/sex (QC normalizes some cells; not characterized) and the node counts still match;
  the live Shiny app itself was not driven this time, so the claim is about the functions the app
  calls, not a fresh live render; the mating-layout collision warning fires for both orders.
  `git diff -U0` shows one hunk, in this item only. **Not run:** the test suite and
  `devtools::check()` -- no package code changed.

### 2026-09-24 · [ad hoc] `BACKLOG.md`: compressed the LabKey item and the kinship2 section's DONE narrative
- **Change:** `BACKLOG.md` 521 -> 433 lines (42,354 -> 34,503 B). (1) The **LabKey item**
  44 -> 15 lines: the Recs #1-#5 DONE narrative (S143-S152, S155) became a one-paragraph pointer
  to `CHANGELOG.md`; the BLOCKED tag and the still-deferred remainder are kept in full. (2) The
  **"Pedigree diagram vs kinship2" section's** S435-S436 triage intro, S480 sequencing note and the
  Tier 1 / Tier 2 DONE blocks, 84 -> 20 lines: what remains states the outcome (8 issues filed in an
  owner-set order, all closed except **#138**), the two tiers, and the pointers (audit, sequencing
  audit, spike, plan docs, Learnings 410/411/485/488-499). (3) The **S518 housekeeping item's** pass
  history and next-pass candidates were updated for this pass, with the regrowth measurement
  (480 lines after S752, 561 before this pass). The per-slice detail that is no longer in the file
  is in the ledger, the plan docs and the Learnings, and recoverable with
  `git show ab50aed1:BACKLOG.md`. **The owner ratified this deeper cut** by picking "Compress DONE
  narrative" (the S518 item had recorded it as needing fresh ratification).
- **Commit:** this commit -- `BACKLOG.md` and this entry only. **Local, not pushed.**
- **Session:** none -- owner-directed, outside a numbered session (follows S778) · **Verified:**
  the S518 method, before cutting anything. **Ledger:** every LabKey session (S143, S144, S146-S152,
  S155) has an entry heading naming it and all 8 load-bearing names are in the ledger
  (`setLabKeyDefaults`, `defaultSiteParams`, `getPedigreeSource`, `getFileDirectRelatives`,
  `getFocalAnimalPedFromFile`, `nprcgenekeeprFileErr`, `readFocalAnimalIds`, `Rlabkey (>= 3.2.0)`).
  **Disclosed deviation:** for the kinship2 sessions (S435-S500) only S482 has a heading that
  names its S-number -- the others are recorded inside entry bodies -- so step (1)'s "heading"
  wording could not be met literally; the load-bearing facts were verified instead (all 8 design
  and plan doc paths, `checkTwinRelations`, `obfuscateTwinRelations`, `orderBySex`, the
  dangling-parent/#154 fixes, and the #136 disclosure defect as "`name` scrubbed to `NA` (D8)"
  plus plan section D8). **Learnings** 410, 411, 485, 488-499 all resolve. **Issues** #131-#137,
  #139, #141, #143-#145 and #154 are CLOSED and only #138 is OPEN (`gh issue view`). **Untouched:**
  15 of the 16 open items are byte-identical before and after (a script compared each `- [ ]`
  block); the LabKey item is the one compressed in place. No test reads `BACKLOG.md`
  (`grep`), and `methodology_dashboard.py` runs without error against the new file. **Not run:**
  the test suite and `devtools::check()` -- no package code changed.

### 2026-09-24 · [ad hoc] `BACKLOG.md`: fixed stale statements and dropped resolved section stubs
- **Change:** (1) the Genetic-metrics section intro no longer points at "the open item at the end of
  this section" -- that item (the two unticketed High-priority audit gaps) became issues #167 and
  #168 and its block was removed in S753 (`c823a9f7`), so the pointer led nowhere; (2) removed the
  `## Architecture follow-ups` section -- its claim that XARCH-2 was "STILL OPEN" in #122 was wrong
  (#122 is CLOSED; `docs/architecture/module-contract.md` records the resolution) and it said "No
  items remain" itself; XARCH-5 stays tracked on GitHub as **#123 (open)**, and the detail stays in
  `docs/audits/XARCH_TRACKER_RECONCILIATION_AUDIT_2026-07-11.md` and the ledger; (3) dropped the
  empty `## Active` and `## Documents` headings and the duplicate `## Up Next`, so the file now has
  one `## Up Next`; (4) corrected the `NEWS.Rmd` release-state-sweep item's line references for the
  #167 entries (`:452-457`, `:476` drifted to `:460-468`, `:478-488`; `:308` and `:376-410` were
  re-checked and are unchanged); (5) updated the S518 housekeeping item's structural-residue
  clause to what remains. **Left as-is:** the `## Architecture (issue #122 / XARCH-2 ...)` stub
  (its pointer to the module-contract doc should be re-homed first) and the `## Audit follow-ups`
  stub -- both named in the S518 item as the next pass's candidates.
- **Commit:** this commit -- `BACKLOG.md` and this entry only. **Local, not pushed.**
- **Session:** none -- owner-directed, outside a numbered session (follows S778) · **Verified:**
  `gh issue view` gives #122 CLOSED and #123 OPEN; the new `NEWS.Rmd` references were read
  (line 460 opens the first #167 entry and 468 closes it; 478 opens the trends entry and 488
  closes it); `git diff -U0` shows exactly five hunks, all in the intended regions; `## Up Next`
  now appears once; every other open item is byte-identical. **Not run:** the test suite and
  `devtools::check()` -- no package code changed.

### 2026-09-24 · [ad hoc] `BACKLOG.md`: removed two completed items (REUSE-badge registration; empty `untitled folder`)
- **Change:** two open items that were already done are gone from `BACKLOG.md` (-21 lines): (1) **the
  api.reuse.software registration item** -- it said the README badge rendered gray "unregistered"
  pending an owner-only registration; the live badge now renders **"compliant"**, so the
  registration was made at some point (when is unrecorded; the README badge URL is unchanged);
  (2) **the empty untracked `inst/extdata/reference/untitled folder`** item -- the directory no
  longer exists. Both were found by a read-only staleness review of the whole file (the owner asked
  "are there items in BACKLOG.md that are stale?" and then picked the cleanups from a menu).
- **Commit:** this commit -- `BACKLOG.md` and this entry only. **Local, not pushed.**
- **Session:** none -- owner-directed, outside a numbered session (follows S778) · **Verified:** the
  live badge SVG text read "REUSE" / "compliant" (HTTP 200, fetched 2026-09-24 via the host's
  resolved address because `curl`'s own resolver failed in the shell; `dig` and `host` resolve it);
  `find inst -iname 'untitled*'` returns nothing; `git diff --stat` shows 21 deletions and no other
  change; the neighbouring items are byte-identical. **Not run:** the test suite and
  `devtools::check()` -- no package code changed.

### 2026-09-24 · [ad hoc] Removed the stale `nprcgenekeepr_notes.txt` CRAN-readiness scratch note
- **Change:** the 61-line "CRAN Submission Readiness Report" (a pasted checklist, unmodified since
  it entered history in `089e5213`) is no longer in the repo root. It was already `.Rbuildignore`d,
  so the built package is unaffected. Recover it with
  `git show 089e5213:nprcgenekeepr_notes.txt`. **Left as-is:** the now-dead `.Rbuildignore` line 86
  (`^nprcgenekeepr_notes\.txt$`) and five identical untracked, git-ignored copies under
  `.claude/worktrees/wf_*/`, none of which the owner named. The commit is **local** (not pushed).
- **Commit/PR:** `c182511b`
- **Session:** none -- owner-directed, outside a numbered session (follows S778) · **Verified:** the
  file was inspected first (tracked, unmodified vs `HEAD`, on `origin/master`); after the commit
  `git show 089e5213:nprcgenekeepr_notes.txt` still returns all 61 lines. **Not run:** the test
  suite and `devtools::check()` -- no package code changed and the file was build-ignored.

### 2026-09-24 · [ad hoc] Pushed `bec2a976..af4f1eca` to `origin/master`; CI green on all four push workflows
- **Action:** `git push origin master` -- 3 commits: `94974437` (S778 close-out records, which
  S778's own records said would stay local), `23f20f3a` (`.Rprofile` renv startup check) and
  `af4f1eca` (the ledger entry for `23f20f3a`). Owner-gated: the owner chose "Record in ledger,
  then push", then confirmed a second time after being told the outgoing set was 3 commits -- the
  choice's description had wrongly said origin was at `94974437` and 1 commit ahead. **Before the
  push:** `git fetch` showed origin at `bec2a976`, an ancestor of HEAD (fast-forward); the outgoing
  diff was inspected -- 4 files (`.Rprofile`, `CHANGELOG.md`, `HANDOFFS.md`, `SESSION_NOTES.md`),
  +171/-12, no secret-named files, no credential-shaped strings in added lines. **After:** local
  and `origin/master` both at `af4f1eca`.
- **CI (by exact SHA `af4f1eca`, push events):** `lint.yaml` run 36060621202, `pkgdown.yaml`
  36060621223, `R-CMD-check.yaml` 36060621264 and `test-coverage.yaml` 36060621306 all
  `completed success`.
- **Session:** none -- owner-directed, outside a numbered session (follows S778) · **Verified:**
  the CI results above; the local suite was not run (`.Rprofile` is build-ignored; the other
  changes are docs-only records).
- **Not pushed:** the commits made after this push (`c182511b` and the commit carrying this entry)
  are local; pushing them would need an entry of its own.

### 2026-09-24 · [ad hoc] `.Rprofile`: renv's plain startup sync check replaced by `renv::status(dev = TRUE)`
- **Change:** opening R in the package root no longer prints a false "The project is out-of-sync"
  message. Under `snapshot.type: "explicit"`, renv's automatic startup check (a plain
  `renv::status()`) counts only `Imports`/`Depends`/`LinkingTo` as used, so every `Suggests`-only
  package (dplyr, chromote, brio, callr, ...) read as installed and recorded but unused.
  `.Rprofile` now sets `options(renv.config.synchronized.check = FALSE)` before sourcing
  `renv/activate.R`, then runs `renv::status(dev = TRUE)` when `interactive()` and `DESCRIPTION`
  exists. `renv.lock` and `renv/settings.json` are untouched: the reported drift was not real. The
  edit is the owner's; this entry records the verification and commit.
- **Commit/PR:** `23f20f3a`
- **Session:** none -- owner-directed, outside a numbered session (follows S778) · **Verified:**
  `renv::status(dev = TRUE)` reports "No issues found"; `Rscript` startup no longer prints the
  out-of-sync line; a forced-interactive `R` start prints the `status(dev = TRUE)` result. **Not
  run:** the test suite and `devtools::check()` -- `.Rprofile` is `.Rbuildignore`d
  (`^\.Rprofile$`) and no package code changed.
- **Caveat:** non-interactive runs (`Rscript`, CI) and R sessions started outside the package root
  no longer get any startup sync check.

### 2026-09-24 · [ad hoc] S778 records: push + CI verification DONE, close-out records committed
- **Deliverable:** the push and CI verification recorded in the entry below. Ratchet **1/1** at
  `bec2a976` (3,565,165 B, +26 B vs S777 = noise on a docs-only diff; results `81564f726622`,
  manifest `aa983075d6a2`); the S777 citation was compared to the results file at Orient BEFORE
  the run. **Not run:** the local full suite and `devtools::check()` -- no package code changed;
  CI's R-CMD-check and test-coverage on the pushed head are the independent verification.
- **Records:** S777 handoff evaluated 9/10 (its next-step (B) listed a `SESSION_NOTES.md` archive
  as due although `methodology_trim.py --check` says that trigger does not fire); S778
  self-assessment 8/10; `HANDOFFS.md` receipt `status: complete`. Learnings: none appended
  (FM #28). Nothing removed from `SESSION_NOTES.md` (28,495 B before these records vs the
  56,750 B read cap: no reduction needed there).
- **Housekeeping, reported not repaired:** measured before these records, `HANDOFFS.md` is
  91,276 B and `CHANGELOG.md` 71,483 B, both over the 65,536 B trigger (`--check` fires) -- the
  archive pass is owed as its own deliverable (next-step B); these records grow both.
- **Disclosed:** the Phase 0 pick was taken as the go-ahead to push, with no second confirmation
  (S771 precedent); the records commit stays LOCAL (1 unpushed after close-out), as at S771.

### 2026-09-24 · [ad hoc] S778 push: `79206add..bec2a976` pushed to `origin/master`; CI green on all four push workflows
- **Action:** `git push origin master` -- 39 commits (Orient's 38, i.e. S771's close-out records,
  S772-S777 through issue #169 Slice 3b, plus the S778 claim `bec2a976`), owner-gated (the
  Phase 0 priorities pick "Push 38 commits", taken as the go-ahead). **Before the push:**
  fast-forward proven (remote tip `79206add` is an ancestor of HEAD); the outgoing diff was
  inspected -- 29 files, +6,371 / -773, no secret-named files, no credential-shaped strings in
  the added lines (the repo is PUBLIC). `origin/master` == local HEAD after (0 ahead).
- **CI, matched by exact head SHA `bec2a9762562a563ce727b2ff43a7b4fe6b7cc95`** (filter
  smoke-tested: 4 rows; independently re-queried at close-out): lint.yaml `36047211896` success
  (4m02s); pkgdown.yaml `36047211887` success; test-coverage.yaml `36047211913` success (10m);
  R-CMD-check.yaml `36047212074` success (23m18s, completed 19:41:27Z). The first CI
  verification of everything since `79206add`, including #169's Slices 3a/3b (module, override
  gate, Ancestry tab, the e2e file and helpers).
- **Not covered by this push's CI:** the live-e2e (shinytest2) tier runs nightly + manual
  dispatch only, so Slice 3b's ancestry e2e first runs at the next nightly (last five nightlies
  started 07:12-07:24Z; ~07:15Z 2026-09-25 is an estimate).
- **Observation, not fixed:** the CLAUDE.md-prescribed `gh run list --branch master --limit 10`
  returned a stale 09-08 window at Orient and again mid-session, then current data on every
  later call (plain and `--json`) -- intermittent, cause unexplained (gh 2.49.2); cross-checked
  with the unfiltered listing and `--commit <sha>`. Not filed as an issue or BACKLOG item: one
  session's evidence, no reproduction on demand.

### 2026-09-24 · [ad hoc] S778 claim: push to origin/master + CI verification *(in progress)*
- Owner-picked at the Phase 0 priorities gate (S777 next-steps (A)). Orient measured: 0
  undocumented on both ledger frontiers (both at `8666dc55` = HEAD), 38 unpushed
  (`origin/master` = `79206add`, confirmed with `git ls-remote`), CI green on every latest
  per-workflow run, the S777 receipt's ratchet citation matching
  `.quality-gates-results.json` byte-for-byte BEFORE any run. Stub + pending receipt ride
  this commit; close-out records the rest.

### 2026-09-24 · [issue #169] S777 records 2/2: Slice 3b DONE, issue #169 CLOSED, close-out records
- **Deliverable:** Slice 3b of issue #169 (the final slice: the committed live e2e, the
  colony-manager-guide documentation, the issue close) — DONE, recorded in the entries below:
  claim `bf004003`, RED `ad5dd344`, GREEN `8526e56b`, REFACTOR `2b59fde6`, records 1/2
  `5b2146c6`, RED addendum `98264764`, REFACTOR addendum `0f4ede78`. No product code changed.
- **Non-commit action — issue #169 CLOSED** (`gh issue close 169 --reason completed`,
  2026-09-24 18:10Z) under the project's GitHub-issue close-out checklist and the owner's
  "RED addendum, then close" choice at the gap gate; the comment cites these entries and the
  evidence (e2e 67/67 with its two siblings, 24 mutation seams, suite 352 files / 8,293
  expectations 0 / 0, `check()` 0 / 0 / 0, lint 0) and says the commits are local, not pushed.
- **Verification at the last product-tree commit `0f4ede78`:** ratchet **1/1** (3,565,139 B,
  results `1fda9fb28cef`, manifest `aa983075d6a2`; the S776 citation was compared to the
  results file BEFORE any run). Learnings **789** and **790** (records 1/2 carried 789).
  `HANDOFFS.md` receipt `status: complete` (self 8/10, S776 evaluated 9/10);
  `SESSION_NOTES.md` S777 record and the S776 handoff evaluation, with the S774/S775-era
  records removed by hand to fit (git holds them: `git show bf004003:SESSION_NOTES.md`).
- **Housekeeping, reported not repaired:** `CHANGELOG.md` crossed its 65,536 B trigger this
  session and `HANDOFFS.md` is far over it — an archive pass is owed as its own deliverable.
  **Ledger hygiene:** the S777 claim entry was stuck ABOVE its newer entries (each new entry
  went in above the previous one but below the claim); this commit moves it to the bottom of
  the S777 block — position only, no entry text was edited.

### 2026-09-24 · [issue #169] S777 addendum GREEN + REFACTOR: verification, and one local helper in the e2e *(no behavior change)*
- **Addendum GREEN (no commit, no product code):** the two new groups pass on the shipped
  build — the 3 ancestry e2e files on the real tree 67/67 (17 + 42 + 8, 0 skipped), the two
  static guards 4/3, clean regression read 352 files / 8,293 expectations 0 failed / 0 error,
  `devtools::check()` 0 / 0 / 0, ratchet **1/1 at `98264764`** (3,565,015 B, results
  `e89582e97c3a`, manifest `aa983075d6a2`). Owner gate: RED to GREEN "Yes".
- **REFACTOR (this commit):** owner-chosen again at the GREEN to REFACTOR gate ("Yes, proceed
  to REFACTOR", against my recommendation to skip). The two table-row serializers (A4b's
  Excluded rows, A5's coverage table) were the one real duplication; they now share ONE
  file-local `mpaTableRowsJs(tableSelector, dropFirstCell)` in the e2e file. Proved
  behavior-neutral first at the string level (the generated JS is byte-identical to both
  replaced expressions), then re-verified: e2e trio 67/67; the B2 and B6 mutant trees re-run
  fail the same 9 and 2 expectations as before (B7/B8 exercise only A4c, whose code did not
  change); static guards 4/3; suite 8,293 / 0 / 0; `check()` 0 / 0 / 0.

### 2026-09-24 · [issue #169] S777 RED addendum: two done-when clauses the e2e missed (tests only)
- **Commit:** RED addendum (this commit) — `test-e2e-mate-pair-analysis-module-ancestry.R`
  only. Found at close-out, before closing #169: the plan's done-when says "5 blocked pairs on
  Excluded with their rules, 3 flagged in Eligible" and the committed e2e asserted only the
  5 / 20 counts. Owner chose "Add them via a RED addendum". New groups (measured live first):
  **A4b** the 5 Excluded rows carry reason "ancestry rule" and their rule (CHINESE-INDIAN x3,
  HYBRID-INDIAN x2); **A4c** the run-1 Eligible Pairs CSV is 20 x 11 with exactly 3 flagged
  pairs (A1xU1, I1xU1, O1xI2: INDIAN-OTHER / flag / violation). The file now has 42
  expectations; it passes 42/42 unmutated on the real tree.
- **Mutation proof (three more throwaway trees, truncated after A4b):** B6 (excluded pair
  loses its rule + flagged pairs lose the "violation" status) fails A4b and A4c; B7 (flagged
  pairs carry no rule) fails A4c; B8 (flagged pairs carry no severity) fails A4c — each for its
  planted cause. Running total: 24 seams in 8 mutant builds. Owner gate: RED addendum chosen
  from three options (add / close-and-state-the-gap / leave open).

### 2026-09-24 · [issue #169] S777 records 1/2: plan Outcome, BACKLOG residue item, Learning 789
- Plan `docs/planning/mate-pair-ancestry-guardrails-plan.md`: **Outcome (S777)** paragraph
  after Slice 3's S776 one. `BACKLOG.md`: the Slice 3b block REMOVED (completed; record in
  the entries below) and replaced by one residue item carrying what #169 left (the
  `a2interactive` demonstration, the zero-rule manifest edge, an Excluded-tab export, the
  duplicated gate code); the blank-ancestry item now names the e2e pins that move with it.
  `PROJECT_LEARNINGS.md`: **Learning 789** (shinytest2 0.5.1 `load_all()`s the checkout from
  the working directory, so the "e2e runs the INSTALLED package" gotcha is false here and a
  scratch-installed mutant is never loaded; the mutation-proof-RED method). Measured at this
  commit: lint 0 findings; `CHANGELOG.md` 65,465 B before these records (71 B under the
  65,536 B trim trigger, so it crosses now) and `HANDOFFS.md` 83,216 B: both archive passes
  are owed as their own deliverable, reported not repaired.

### 2026-09-24 · [issue #169] S777 REFACTOR: hoist the e2e's five generic helpers into `helper-shinytest2.R` *(no behavior change)*
- **Commit:** REFACTOR (this commit) — owner-chosen at the GREEN to REFACTOR gate (my
  recommendation was to skip it; the owner said "Yes, proceed to REFACTOR"). The five
  file-local helpers of `test-e2e-mate-pair-analysis-module-ancestry.R` (`mpaSquash`,
  `mpaPollJs`, `mpaTextJs`, `mpaDtInfo`, `mpaDownload`) move to
  `tests/testthat/helper-shinytest2.R` as `squash_whitespace()`, `poll_js()`,
  `text_content_js()`, `poll_dt_info()` and `download_csv_expect()`, documented in that
  file's roxygen style, with `testthat::expect_true` qualified for the nightly's
  unattached `test_dir()` mode; 25 call sites renamed; the sixth local definition
  (`mpaDtInfoJs`) is inlined into `poll_dt_info()`; only `mpaRuleKeys()` (manifest-specific)
  stays local. The name-collision grep across `tests/` and `R/` was empty before the move.
- **Verification after the move (all identical to GREEN):** the three ancestry e2e files
  on the real tree 63/63 (0 skipped); the B1 and B5 throwaway mutant trees re-run with the
  moved helpers fail 11 and 8 expectations on the same groups as before; the two static
  e2e guards 4/3; clean regression read 352 files / 8,293 expectations, 0 failed / 0
  error; `devtools::check()` 0 / 0 / 0. Disclosure: the shared helper is loaded by every
  e2e file (about 30), which is the risk I named at the gate; none of them exercises the
  five new names.

### 2026-09-24 · [issue #169] S777 GREEN: Slice 3b colony-manager-guide documentation (no product code)
- **Commit:** GREEN (this commit) — `vignettes/articles/colony-manager-guide.qmd` only: a new
  "Ancestry guardrails on this tab" passage at the end of the Mate Pair Analysis section
  (four paragraphs: rules come from the Breeding Groups upload and are read at the click;
  block pairs go to Excluded with the reason "ancestry rule", flag pairs stay in Eligible
  Pairs and the CSV; the "Override rule..." confirm gate with a required reason, per tab,
  cleared on "Clear overrides" or a new rules file, applied at the next click; the Ancestry
  tab's coverage table and Download Audit Manifest, which always describes the displayed
  run). Every claim checked against `R/modMatePair.R` / `.ancestryStatusLine()` before
  commit (one sentence tightened: the extra zero-pairs message appears when no eligible pairs
  remain). Owner gate: RED to GREEN = "Yes, proceed to GREEN". No product code changed: the
  committed e2e already passes on the real build (the RED baseline, 38/38). Left as-is on
  purpose: line 552's "a truly blank entry becomes UNKNOWN" (wrong for app uploads; the
  open blank-ancestry item owns that decision) and `NEWS.Rmd:429` (already release-state).
- **Verification:** the article renders (Quarto 1.7.33, exit 0, in a scratch copy of
  `vignettes/articles/` so no tracked render output moved); the new section and both
  "Override rule…" occurrences are in the HTML. The article directory is build-ignored
  (`^vignettes/articles$`), so the tarball and the size ratchet are unaffected.

### 2026-09-24 · [issue #169] S777 RED: Slice 3b committed live-app e2e for the Mate Pair ancestry guardrails, mutation-proved *(tests only)*
- **Commit:** RED (this commit) — `tests/testthat/test-e2e-mate-pair-analysis-module-ancestry.R`
  only, no product code. One live-app block, 38 expectations in 13 tagged groups (A1-A13)
  pinning the LIVE-path numbers (status line; pre-run guidance; the override select offers
  the 2 block rules; 20 eligible / 5 excluded; coverage table; manifest 1 wording / pair
  counts 3-2-0-3 / census; modal wording; blank reason refused; override recorded; the
  displayed run's manifest NOT rewritten by a late override; 23 / 2 with a 23 x 11 CSV and
  3 `overridden` rows; manifest 2 reason / summary / counts; 0 console errors). Behavior
  failures FAIL; only upload/navigation infrastructure skips. It matches the
  `^e2e-mate-pair-analysis-module` CI group by name (the two static guards pass).
- **Owner gates:** Pre-RED approach = "Mutation-proof RED" (a characterization e2e cannot
  start red); PRE-RED to RED = "Yes, proceed to RED".
- **Mutation proof (throwaway trees in the scratchpad, never committed):** the unmutated
  harness passes 38/38 (0 failed, 0 skipped). 20 planted seams in 5 builds all fail the
  intended groups: B1 rules not passed at the click (11 failures: 25 eligible / 0 excluded,
  empty coverage, manifest 500, no 23 / 2); B2 override not applied + modal shows the
  Breeding Groups wording + status / guidance wording + coverage drops JAPANESE (9); B3 blank
  reason accepted + census wrong + pair counts inverted (5); B4 manifest read from LIVE
  overrides + reason not stored + manifest carries the Breeding Groups wording + select lists
  every rule + override-status wording (7); B5 no-override / override summary wording +
  overridden flag never set + overridden rule's counts dropped + severity forced + gate stays
  open (8). Every failing message was classified against its planted cause. **Not
  independently mutation-proved (stated, not skipped):** A13 (console errors), the manifest
  row count, "manifest 1 marks nothing overridden", and manifest 2's rule-row existence.
- **Incident, declared:** the first mutation round was INERT (5 runs, all 38/38) —
  shinytest2 0.5.1 loads the package from the CURRENT DIRECTORY tree via `pkgload::load_all()`
  in the app subprocess, so scratch-installed mutants were never loaded. Diagnosed with a
  preflight app printing `system.file(package=)`; re-aimed by running each mutant from its
  own mutated tree with the tests inside it; every re-run's preflight shows the mutant tree
  loaded. The inert round's results were discarded, not counted.

### 2026-09-24 · [issue #169] S777 claim: Slice 3b — committed Mate Pair ancestry e2e, colony-manager-guide docs, close #169 *(in progress)*
- Owner-picked at the Phase 0 priorities gate (S776 next-steps (A), `BACKLOG.md:8`).
  Orient measured: 0 undocumented on both ledger frontiers (both at `a6ee8c0d` = HEAD),
  30 unpushed (`origin/master` = `79206add`), CI green (all four push workflows on
  `79206add` plus nightlies through 2026-09-24 07:15Z), the S776 receipt's ratchet
  citation matched `.quality-gates-results.json` byte-for-byte BEFORE any run;
  `HANDOFFS.md` trim trigger FIRES (82,785 B vs 65,536 B) — reported, not this
  session's deliverable. Deliverable is Slice 3b of 3 (final); strict TDD,
  `AskUserQuestion`-gated phases. Stub + pending receipt ride this commit; close-out
  records the rest. Issue #169 closes at close-out.

### 2026-09-24 · [ad hoc] S776 records: Slice 3a of #169 DONE, close-out records committed
- **Deliverable:** Slice 3a of issue #169 (the Mate Pair override gate, the Ancestry tab
  and the audit-manifest download), recorded in the entries below: claim `a2e2be05`, RED
  `09b85a5a`, GREEN 1/2 `f65410f2`, GREEN 2/2 `15addc42`, REFACTOR `ae41927b`. The two
  records commits add: the plan's Slice 3 **Outcome (S776)** paragraph; the `BACKLOG.md`
  item rewritten forward-carrying at Slice 3b (live-measured numbers, driver traps, the
  strict-TDD wrinkle for a characterization e2e) plus a NEW item for the blank-ancestry
  read-path divergence; Learnings 787-788; the `HANDOFFS.md` S776 receipt
  (`status: complete`, self 8/10, S775 evaluated 9/10); the `SESSION_NOTES.md` S776 record
  and the S775 handoff evaluation, with the S769-S773-era records removed by hand to keep
  the file under the hook's token ceiling (git holds them: `git show
  a2e2be05:SESSION_NOTES.md`).
- **Verification (measured):** unfiltered clean regression read (`NOT_CRAN=true`,
  `load_all()` first) **351 files / 8,292 expectations, 0 failed / 0 error** after GREEN
  AND after the REFACTOR (identical; S775 was 349 / 8,105); `devtools::check()` **0 / 0 /
  0** both times; lint 0; ratchet **1/1 at `ae41927b`** (3,559,430 B, +10,763 B vs S775 =
  tests + docs; results `854128e69adc`, manifest `aa983075d6a2` unchanged; the citation
  was compared to the results file at Orient BEFORE the run). Runtime (3E): a
  scratch-installed build driven by shinytest2 twice with identical results (20/5 ->
  override -> 23/2, manifests, gate, 0 console errors).
- **Findings recorded, not fixed:** the Shiny upload path reads CSV/text with no
  `na.strings`, so a blank ancestry cell is OTHER live but UNKNOWN on the script path
  (`BACKLOG.md:83`); a valid zero-rule table makes the manifest builder stop (Breeding
  Groups identical); the whole-file Read of `SESSION_NOTES.md` counted 25,148 tokens for
  a file the hook's estimator counted as 24,579.
- **Not done, by design:** the committed shinytest2 e2e, the colony-manager-guide
  article and the explicit #169 close are Slice 3b; issue #169 stays open; nothing pushed.

### 2026-09-24 · [issue #169] S776 REFACTOR: shared override helpers between Breeding Groups and Mate Pair
- `ae41927b` (3 files): `.emptyAncestryOverrides()` and `.overridableAncestryRules()`
  added to `R/ancestryOverrides.R` and used by `R/modBreedingGroups.R`,
  `R/modMatePair.R` and `.checkAncestryOverrides()` in place of four copies of the
  zero-row overrides table and two copies of the "block rules not yet overridden"
  computation. Structure only (owner gate "one small REFACTOR"); the select-choices
  builder and the confirm-gate modal stay duplicated (not unit-covered). Verified
  identical before and after: full suite 351 files / 8,292 expectations 0/0, `check()`
  0/0/0, lint 0, the live smoke.

### 2026-09-24 · [issue #169] S776 GREEN: Slice 3a implemented (Mate Pair override gate + Ancestry tab + audit manifest)
- **GREEN 1/2 `f65410f2` (4 files):** `R/ancestryOverrides.R` gains
  `.matePairAncestryOverrideWarningText` (the owner-ratified wording, verbatim)
  and `.matePairAncestryReport()` (violations = the rule keys of every
  ancestry-matched pair from `pairs` UNION `excluded`; coverage passed through;
  `stop()` on a non-result or a result made without rules). `R/modMatePair.R`
  gains the per-rule override select + confirm-gate modal (required reason;
  blank refused with an error notification) inside the collapsed Ancestry
  Guardrails panel; per-tab `ancestryOverridesRV` reset when the rules reaching
  the module change; `overridableRules()` and the select-sync observer; a
  sibling `ancestryRun` snapshot (ORIGINAL rules + overrides) set beside
  `matchResults` at the click, with `overriddenRules` passed to the kernel
  (zero-row when the guardrails are inactive); `ancestryManifest()`,
  `ancestryTabGuidanceText()`; and the new Ancestry tab (guidance, coverage
  table, Download Audit Manifest as a dated `MatePairAncestryAuditManifest.csv`).
  `man/modMatePairUI.Rd` and `man/modMatePairServer.Rd` regenerated
  (`NAMESPACE` unchanged: every import already existed).
- **GREEN 2/2 (this commit):** `NEWS.Rmd` — the ONE #169 entry revised in place
  to the release-state description (Learning 785), now covering the override
  step, the Ancestry tab and the manifest download in plain language.
- All 22 RED blocks pass (187 expectations) with no test edits during GREEN;
  the sibling files that share the module or the primitives stay green; lint 0.
  Full-suite and `check()` numbers are recorded at close-out. The committed
  shinytest2 e2e, the colony-manager-guide article and the explicit #169 close
  are Slice 3b.

### 2026-09-24 · [issue #169] S776 RED: Slice 3a failing tests committed (Mate Pair override gate + Ancestry tab + audit manifest)
- Two new files, tests only — zero `R/`/`man/`/`NAMESPACE`/`NEWS` changes.
  `tests/testthat/test_matePairAncestryManifest.R` (8 blocks, not CRAN-skipped):
  the ratified gate wording pinned verbatim as `.matePairAncestryOverrideWarningText`
  (owner gate: "plan text verbatim"); the `.matePairAncestryReport(result)`
  manifest adapter (8 matches = CHINESE-INDIAN 3 / HYBRID-INDIAN 2 /
  INDIAN-OTHER 1 / INDIAN-UNKNOWN 2, unchanged under an override, coverage passed
  through, zero-row when nothing matches, errors on a result made without rules);
  adapter -> `.buildAncestryOverrideManifest` end to end (nPairs, census 2/3/1/2/1/1,
  nUncovered 2 / 9, reason on exactly the overridden rule's row).
  `tests/testthat/test_modMatePair_ancestryOverrides.R` (14 blocks, testServer,
  skip on CRAN): the Ancestry tab after Excluded and the override controls inside
  the collapsed panel; `overridableRules()`; the confirm gate via mocked
  `showModal`/`showNotification`/`removeModal` (verbatim text, reason box,
  Confirm/Cancel; never on a routine run; not opened when nothing is overridable,
  with a positive control); blank/missing reason; stored-trimmed override, status
  line, Clear; reset when the rules change; the run/snapshot contract (20/5 ->
  override -> displayed run and manifest unchanged -> re-run 23/2, three rows
  `overridden` with severity `block` = the Learning-780 observable, equal to a
  direct `reportMatePairs()` call); overrides recorded then the pedigree loses its
  `ancestry` column (no rules, no overrides passed, no error); rules-off zero
  change; guidance states and manifest lifecycle; coverage table; the dated
  `MatePairAncestryAuditManifest.csv` download.
- **RED audit (Learning 784):** every one of the 22 new blocks fails, each
  failing expectation for the intended cause (missing function/object, missing UI
  id or tab, gate never opens, missing output); the four error-path regexes do not
  match R's own "could not find function" text (no false pass); the negatives in
  the not-openable block are guarded by a positive control. Blocks that stop at the
  first missing symbol leave deeper expectations unexercised until GREEN; those
  numbers were cross-checked through the shipped kernel and manifest builder in
  scratch, and the mock mechanism was proven against the existing Breeding Groups
  gate. Lint 0 on both files.

### 2026-09-24 · [issue #169] S776 claim: Slice 3 — Mate Pair override gate, audit manifest, Ancestry tab, e2e, article *(in progress)*
- Owner-picked at the Phase 0 priorities gate (S775 next-steps (A),
  `BACKLOG.md:8`). Orient measured: 0 undocumented on both ledger frontiers
  (both at `ff53bf21` = HEAD), 23 unpushed (`origin/master` = `79206add`), CI
  20/20 green (four push workflows on `79206add` + nightlies through 09-23),
  S775 receipt-citation vs `.quality-gates-results.json` matched byte-for-byte
  BEFORE any ratchet run; `HANDOFFS.md` trim trigger FIRES (74,611 B vs 65,536
  B) and `SESSION_NOTES.md` exceeds the Read tool's 25,000-token cap despite
  S775's "under the cap" claim — both reported, not this session's
  deliverable. Deliverable is Slice 3 of 3 (scope may split 3a/3b at the
  Pre-RED gate; strict TDD, `AskUserQuestion`-gated phases). Stub + pending
  receipt ride this commit; close-out records the rest. Issue #169 closes at
  Slice 3 close-out.

### 2026-09-23 · [ad hoc] S775 records: Slice 2 of #169 DONE, close-out records committed
- **Deliverable:** Slice 2 of issue #169 (the Mate Pair module applies the ancestry rules loaded on Breeding
  Groups), recorded in the entries below: claim `8d722d6a`, RED `53e172d6`, RED correction `fdb705bd`, GREEN 1/2
  `402549a7`, GREEN 2/2 `e4401806`, REFACTOR `4be16a12`. The two records commits add: the plan's Slice 2
  **Outcome (S775)** paragraph (`docs/planning/mate-pair-ancestry-guardrails-plan.md`); the `BACKLOG.md`
  mate-pair item rewritten forward-carrying at Slice 3 (not removed — Slice 3 is open, issue #169 stays open);
  Learning 786 (`PROJECT_LEARNINGS.md`); the `SESSION_NOTES.md` S774 handoff evaluation (9/10) and completed
  S775 record (self 8/10); the completed `HANDOFFS.md` receipt.
- **Verification (measured):** clean unfiltered regression read (`NOT_CRAN=true`, `load_all()` first) 349 files /
  8,105 expectations, 0 failed / 0 error before AND after the refactor; `devtools::check()` 0 / 0 / 0 before AND
  after; lint 0; ratchet 1/1 at `4be16a12` (3,548,667 B, +9,285 B vs S774; results `9939380d9a6f`, manifest
  `aa983075d6a2` unchanged; the citation comparison ran at Orient BEFORE the run). **Runtime (Phase 3E):** a
  scratch-installed build driven by shinytest2 (one-off, not committed): live status across tabs, 20 eligible /
  5 excluded with the rule shown, an 11-column CSV, explainer hidden then visible, zero console errors; the two
  existing e2e files (mate-pair 8, BG-ancestry 17 expectations) pass locally. Slice 3 owns the committed e2e.
- **Non-commit actions:** none (no push, no issue comment, no tag; the ratchet run rewrote the untracked
  `.quality-gates-results.json`). Nothing removed from a mandated-read file this session (1-and-done): the draft
  `SESSION_NOTES.md` records pushed it over its 56,750 B read cap and were compressed back to 55,795 B before
  the commit (the installed pre-commit hook refuses growth of an over-ceiling file); `HANDOFFS.md` (74,358 B)
  is past its trim trigger — both trims are owed as their own deliverables.

### 2026-09-23 · [issue #169] S775 REFACTOR: one shared `.ancestryStatusLine()` for the Breeding Groups and Mate Pair status text
- Behavior-preserving (owner-gated "one small REFACTOR"; zero test edits): the loaded-state wording
  ("N block, M flag rule(s); K animal(s) uncovered.") and the no-ancestry-column inactive notice, which GREEN 1/2
  had duplicated verbatim in `modMatePairServer`, now live in one internal `@noRd` helper
  `.ancestryStatusLine(rules, ped)` next to `.ancestryCoverage()` in `R/reportAncestryViolations.R`; both modules
  call it. Each module keeps its own "no rules loaded" text (the Mate Pair one says where to load rules). Three
  `R/` files, no `man/` change. Same counts before and after on the 7 files exercising it (new module file
  75, BG ancestry 121, contract 119, appServer 37, Mate Pair 44, ancestry reporter 54, BG module 117; 0
  failed / 0 error); lint 0. Pre-refactor `devtools::check()` on the GREEN tree: 0 / 0 / 0.

### 2026-09-23 · [issue #169] S775 GREEN 2/2: NEWS.Rmd release-state entry + UI roxygen (ledger for the three GREEN-phase commits)
- `NEWS.Rmd`: the ONE existing #169 entry under "Mate Pair Analysis" REVISED (not appended; Learning 785) to the
  release state: load the rules on the Breeding Groups tab and the Mate Pair Analysis tab uses them (block ->
  Excluded tab with the reason "ancestry rule"; flag -> stays in Eligible Pairs with its rule shown, also in the
  exported file); a status line says whether rules are active and how many animals no rule covers; the script
  arguments and the coverage result stay described; without rules, or with no ancestry column, everything is
  exactly as before. Plain-language criterion (S628) applied: no "reactive"/"snapshot"/kernel wording.
  `R/modMatePair.R` `modMatePairUI()` roxygen `@return` now mentions the collapsed section + status line;
  `man/modMatePairUI.Rd` regenerated (`devtools::document()` touched only this file).

### 2026-09-23 · [issue #169] S775 GREEN 1/2: Mate Pair module applies the ancestry rules loaded on Breeding Groups (`402549a7`)
- `R/modBreedingGroups.R`: the return list gains `ancestryRules = reactive(ancestryRulesData())` (the validated
  table as loaded; NULL when none; deliberately NOT `ancestryRulesForRun()`) + roxygen `@return`.
  `R/appServer.R`: `ancestryRules = bgResults$ancestryRules` threaded into `modMatePairServer` (the same
  object; a BG return without the element gives an explicit NULL). `R/modMatePair.R`: new `ancestryRules = NULL`
  parameter; collapsed "Ancestry Guardrails" toggle + always-visible `ancestryStatus` output + explainer panel
  (unprefixed `conditionalPanel` condition, Learning 324); `ancestryRulesData()` / `ancestryRulesForRun()` (rules
  only when loaded AND the pedigree has an `ancestry` column) / `ancestryStatusText()` (none / active / inactive);
  the click passes `ancestryRules = ancestryRulesForRun()` to `reportMatePairs()` so the stored result IS the run
  snapshot (D8c); the zero-pairs alert keeps its text byte-for-byte and appends an ancestry-exclusion count
  sentence only when >=1 pair was excluded by a rule. `man/modBreedingGroupsServer.Rd`,
  `man/modMatePairServer.Rd` regenerated. Five files. GREEN result: the 16 new module blocks, the two
  contract rows, 3 BG blocks and 2 appServer blocks pass; sibling `test_modMatePair.R` (44) unchanged.

### 2026-09-23 · [issue #169] S775 RED correction: the malformed-rules block's unobservable post-error read removed (`fdb705bd`)
- Declared RED correction, test only (no implementation change). The RED block pinning "a malformed rules
  table surfaces at the click" also asserted `isReady()` was FALSE afterwards; at GREEN it errored with
  `shiny.destroyed.error` — the observer error being pinned makes Shiny destroy the module session, after
  which no module-domain reactive (the returned `isReady()`, and the module-local `reactiveVal` run store
  too) can be read. That half was unobservable, so it was dropped; the surfaced warning carrying the
  `checkAncestryRules` message stays pinned. Own commit to keep GREEN 1/2 within the 5-file cap.

### 2026-09-23 · [issue #169] S775 RED: Slice 2 failing tests committed (Mate Pair module ancestry rules)
- New `tests/testthat/test_modMatePair_ancestry.R` (16 blocks) plus additions to
  `test_moduleContract.R` (BG `names` +`ancestryRules`; matePair `args`
  +`ancestryRules`), `test_modBreedingGroups_ancestryRules.R` (3 blocks: the new
  BG return element — NULL / validated / NULL-if-malformed and re-upload; the
  element is the validated table even with no ancestry column, i.e. NOT
  `ancestryRulesForRun()`) and `test_appServer_server.R` §9 (2 blocks: the same
  reactive object threads through; a BG return without the element gives an
  explicit NULL). Tests only — zero `R/`/`man/`/`NAMESPACE`/`NEWS` changes; 4
  files (under the 5-file cap). Pinned on the shipped `example_ancestry_*`
  fixtures (re-measured at Orient: 25 pairs → 20 eligible / 3 flagged / 5
  ancestry-excluded): UI toggle + always-visible status + explainer in order;
  three status texts verbatim; rules applied with columns after `damGu`;
  rules-off `identical()` to the kernel for the omitted argument, a `NULL`
  reactive, and rules-with-no-ancestry-column (D4-1/D1); conservation (D4-3);
  snapshot both directions (D8c); CSV header with/without rules; the
  zero-pairs alert (existing text byte-identical, plus an "N pair(s) were
  excluded by ancestry rules -- see the Excluded tab." sentence only when >=1
  ancestry exclusion); a malformed table surfaces at the click; a warning-bearing
  table still applies and its run-time warning is not muffled (dragon 10).
- Owner gates (S775): UI layout "toggle + visible status"; zero-pairs message
  "yes, pinned"; PRE-RED→RED. **RED audit:** 15 of the 16 new blocks fail — 1
  block passes (the rules-off `identical()` pin, characterization), 1 more is
  partly green for the same reason (the rules-off half of the zero-pairs alert
  block); every failing expectation is the intended cause (absent UI element /
  `ancestryStatus` output, `unused argument (ancestryRules = ...)`, missing
  `ancestryRules` return element, argument not passed by `appServer`). Blocks
  that stop at the `unused argument` seam leave their deeper expectations
  unexercised until GREEN (Learning 784) — cross-checked against the shipped
  kernel in scratch (zero-pairs 0/1 `I1|C2`, warn-rules 25/0 flagged
  `I1|U1`,`A1|U1`, the malformed message, the 2/2/2 status). One vacuous
  ordering expectation (a `-1` position sentinel passing `expect_lt`) was
  tightened before this commit. Lint 0 on all four files.

### 2026-09-23 · [issue #169] S775 claim: Slice 2 — rules delivery + Mate Pair module wiring *(in progress)*
- Owner-picked at the Phase 0 priorities gate (S774 next-steps (A),
  `BACKLOG.md:8`). Orient measured: 0 undocumented on both ledger frontiers
  (both at `a7628998` = HEAD), 15 unpushed (`origin/master` = `79206add`), CI
  green (all four push workflows + the 2026-09-23 nightly), S774
  receipt-citation vs `.quality-gates-results.json` matched byte-for-byte BEFORE
  any ratchet run; `HANDOFFS.md` trim trigger FIRES (68,434 B vs 65,536 B) —
  reported, not this session's deliverable. Deliverable is Slice 2 of 3 (the
  module; no override gate; strict TDD, `AskUserQuestion`-gated phases). Stub +
  pending receipt ride this commit; close-out records the rest. Issue #169 stays
  open until Slice 3.

### 2026-09-23 · [ad hoc] S774 records: Slice 1 of #169 DONE, close-out records committed
- **Deliverable:** Slice 1 of issue #169 (the `reportMatePairs()` ancestry
  kernel), recorded in the entries below: claim `0a4c155e`, RED `a29e88bb`,
  GREEN 1/2 `eb104544`, GREEN 2/2 `f4ca894f`, REFACTOR `f852fcb9`, docs
  `a0c81ea4`. Ratchet 1/1 at `f852fcb9` (3,539,382 B, +10,649 B vs S773 = the new
  tests + docs; results `2a43ab2f7bf5`, manifest `aa983075d6a2`); the
  receipt-citation comparison ran at Orient BEFORE the run. Clean regression read
  348 files / 8,007 expectations 0 failed / 0 error and `devtools::check()`
  0 / 0 / 0, each measured before AND after the refactor. Not run, stated: no
  live app run (the module is untouched and does not pass the new arguments).
  Checklists: lint ✓, NEWS ✓ (release-state), `_pkgdown.yml`/citation/tutorial
  N/A, `a2interactive.Rmd` owed as the deferred pass (in the BACKLOG item); the
  GitHub issue stays open (Slices 2-3 remain).
- **`BACKLOG.md`:** the mate-pair item rewritten forward-carrying (Slice 1
  shipped; pickup = Slice 2, with the module's `ancestry`-column check called out
  as the trap); a NEW item, "`NEWS.Rmd` release-state sweep" (owner-directed; four
  clusters found by heuristic grep, a floor not a census), was added — recorded,
  NOT done.
- **Receipt:** `HANDOFFS.md` S774 `status: complete` (self 8/10, S773 evaluated
  9/10); its `commit:` names the last code commit `f852fcb9` (the records commit
  cannot name its own sha). Handoff evaluation and the S774 record are in
  `SESSION_NOTES.md`. Housekeeping sizes are recorded in the receipt's gotcha (9).
- **Model:** Claude Sonnet 5.

### 2026-09-23 · [issue #169] S774 docs: Learnings 784-785 + the plan's Slice 1 outcome (for Slice 2)
- `PROJECT_LEARNINGS.md` Learning 784 (a RED audit for an added-optional-argument
  slice must classify every failing expectation's message; a regex naming the
  argument passes falsely on R's own `unused argument` text; an erroring block
  leaves its later assertions and oracles unexercised) and Learning 785 (NEWS
  entries are release-state relative to the prior release, never an in-progress
  milestone; owner-directed). `docs/planning/mate-pair-ancestry-guardrails-plan.md`
  §5 gained an **Outcome (S774)** paragraph: the override contract, columns,
  `NA`-level coverage semantics, helper names/locations, measured timing, and the
  Slice 2 trap (the module must check for the `ancestry` column BEFORE passing
  rules, because `reportMatePairs()` now `stop()`s without it).
- **Model:** Claude Sonnet 5.

### 2026-09-23 · [issue #169] S774 REFACTOR: shared `.ancestryCoverage()` replaces the duplicated coverage block
- Owner-gated (GREEN→REFACTOR, one candidate). The ~12-line coverage block
  inside `reportAncestryViolations()` and `reportMatePairs()`'s
  `mateAncestryCoverage()` copy are now ONE internal `.ancestryCoverage(ids,
  ped, rules)` (`@noRd`, `R/reportAncestryViolations.R`), called by both. No
  behavior change: identical expectation counts in the 7 ancestry/mate-pair
  corpora (153/42/44/54/103/31/105, 0 failures), the new file's
  `identical(coverage, reportAncestryViolations(...)$coverage)` parity block
  still passes, lint clean on both files, `document()` a no-op. Full
  verification on the refactored tree: clean regression read 348 files / 8,007
  expectations, **0 failed / 0 error** (unchanged from pre-refactor);
  `devtools::check()` **0 / 0 / 0**.
- **Model:** Claude Sonnet 5.

### 2026-09-23 · [issue #169] S774 GREEN 2/2: NEWS.Rmd entry for the `reportMatePairs()` ancestry arguments
- One `NEWS.Rmd` entry under Mate Pair Analysis, plain language for a colony
  manager (S628 criterion). **Owner correction mid-session:** the first draft
  read "first step ... a later step of this work"; the owner ruled that NEWS
  entries state the release-time state relative to the prior release (2.0.0),
  never an in-progress milestone, and the entry was rewritten before commit.
  Saved as a feedback memory. The owner also noted several EXISTING entries
  (the four #168 ancestry entries, `NEWS.Rmd` ~376-422) share the fault; not
  touched here — a `BACKLOG.md` sweep item is recorded at close-out. `NEWS.md`
  not re-rendered (last rendered S716; the #168 slices set the same precedent).
- **Full verification on this tree (measured):** clean regression read,
  unfiltered, `NOT_CRAN=true` + `load_all()` first: 348 files, 8,007
  expectations, **0 failed / 0 error** (186 skipped = opt-in/`skip_on_cran`
  blocks; 6 warnings, none from the new file). `devtools::check()`: **0 errors /
  0 warnings / 0 notes**, and `document = TRUE` produced no churn.
- **Model:** Claude Sonnet 5.

### 2026-09-23 · [issue #169] S774 GREEN 1/2: `reportMatePairs(ancestryRules, overriddenRules)` kernel shipped (`eb104544`)
- `R/reportMatePairs.R` (+ regenerated `man/reportMatePairs.Rd`): two optional
  arguments; `block` moves a pair to `excluded` (reason `"ancestry rule"`),
  `flag` and overridden-block pairs stay in `pairs` annotated
  (`ancestryRule`/`ancestrySeverity`/`ancestryStatus`, appended after `damGu`),
  new `ancestryCoverage` element. Screen runs LAST (D5), before marker/GV
  enrichment, on a vectorised matcher (one `match()` over all pairs); rules and
  overrides validated once up front so bad arguments fail identically on every
  path incl. the two early returns; shape depends on the argument, never the
  data; `NULL` rules take the untouched path (`identical()`). Internal helpers
  `@noRd` in the same file; `ancestryOverrides.R` and
  `reportAncestryViolations.R` NOT modified (the coverage helper duplicates the
  group reporter's ~12 lines, guarded by an `identical()` parity test).
- **Measured:** new file 18 blocks / 153 expectations, 0 failed/0 error/0
  warnings; siblings unchanged (`reportMatePairs` 42, `modMatePair` 44,
  `reportAncestryViolations` 54, `ancestryOverrides` 103); lint clean; 102,400
  pairs in 0.77 s with rules vs 0.89 s without (loop alternative ~49 s).
- **Declared RED correction:** the scaling block's independent oracle used
  `table(male, female)` (a position-wise cross-tab, 320 observations) instead
  of the product of marginal counts over the 102,400 pairs; fixed in this
  commit (hand-verified 54 x 53 x 2 = 5,724 block, likewise flag). Assertion
  intent unchanged; invisible in RED because the block errored on the missing
  argument.
- **Model:** Claude Sonnet 5.

### 2026-09-23 · [issue #169] S774 RED: Slice 1 failing tests committed (`reportMatePairs()` ancestry kernel)
- New `tests/testthat/test_reportMatePairsAncestry.R` (tests only; zero
  `R/`/`man/`/`NAMESPACE`/`NEWS` changes): 18 blocks on the shipped
  `example_ancestry_*` fixtures pinning plan §5 Slice 1 done-when 1-7 — NULL-rules
  `identical()` (D4-1); additivity/conservation with `minAge` + `exclude`
  active (D4-2/3, D5); hand-derived counts 25 → 20/5 with the 5 block and 3
  flag pairs named by id; overrides (either orientation, any case, optional
  `reason` ignored) 23/2; zero-rule and flag-only tables; self-pair rule;
  `ancestryCoverage` (census 2/3/1/2/1/1, equal to the group reporter's) and its
  universe; argument-determined shape on all three empty paths (D4-4); stop
  paths with pinned messages; the validator warning fires exactly once;
  case/whitespace/factor/NA level normalisation; a 102,400-pair scaling guard
  (< 10 s, independent oracle). Owner-ratified at two gates: the
  `overriddenRules` contract ("sibling shape, reject no-ops": ancestry1/2,
  optional ignored `reason`, error on an unknown/flag/duplicate override or
  overrides without rules) and PRE-RED→RED.
- **RED audit (measured):** 1 block passes (the fixture-premise
  characterization), 17 fail; all 26 failing expectations cite the missing
  arguments (`unused argument`) or the not-yet-implemented messages. Two test
  defects were caught and fixed BEFORE this commit: a helper hard-coding
  `minAge` (an unrelated collision error) and a stop-path regex (`"ancestry"`)
  that matched R's own `unused argument (ancestryRules = ...)` text and passed
  for the wrong reason — every stop-path phrase is now specific. The hand-derived
  expectations were cross-checked against an independent base-R computation
  (scratchpad); sibling corpus unchanged and green (`test_reportMatePairs.R` 42,
  `test_modMatePair.R` 44, `test_reportAncestryViolations.R` 54,
  `test_ancestryOverrides.R` 103 expectations, 0 failures). Lint clean.
- **Model:** Claude Sonnet 5.

### 2026-09-23 · [issue #169] S774 claim: Slice 1 — `reportMatePairs()` ancestry kernel *(in progress)*
- Owner-picked at the Phase 0 priorities gate (S773 next-steps (A),
  `BACKLOG.md:8`). Orient measured: 0 undocumented on both ledger frontiers
  (both at `d3603995` = HEAD), 8 unpushed, CI 10/10 green, S773
  receipt-citation vs `.quality-gates-results.json` matched byte-for-byte
  BEFORE any ratchet run. Deliverable is Slice 1 of 3 (script-callable kernel
  only; strict TDD, `AskUserQuestion`-gated phases). Stub + pending receipt
  ride this commit; close-out records the rest. Issue #169 stays open until
  Slice 3.

### 2026-09-23 · [ad hoc] S773 records: mate-pair design gate DONE, close-out records committed
- **Deliverable:** the design gate recorded in the `[issue #169]` entry below
  (`6925d1a0`; issue #169 opened, plan ratified, BACKLOG item rewritten
  forward-carrying). Ratchet 1/1 at `6925d1a0` (3,528,733 B, +16 B vs S772 =
  noise; results `1591937f7581`, manifest `aa983075d6a2`); the
  receipt-citation comparison ran at Orient BEFORE the run. Not run: local
  suite/`devtools::check()` — no package code changed. No `.R`/export/UI/
  statistic (all code checklists N/A); the GitHub issue stays open (the
  implementation is not done).
- **Receipt:** `HANDOFFS.md` S773 `status: complete` (self 9/10, S772
  evaluated 9/10); its `commit:` names the deliverable commit `6925d1a0`
  (the records commit cannot name its own sha). Handoff evaluation and the
  S773 record are in `SESSION_NOTES.md`.
- **Ledger sizes (measured at close-out, `--check --budget-bytes 65536`, none
  fire):** `SESSION_NOTES.md` 35,867 B (records grew it +9.0 KB), `HANDOFFS.md`
  58,245 B, `CHANGELOG.md` 31,428 B (before this line). The next
  `HANDOFFS.md` archive pass and `SESSION_NOTES.md` trim are nearer than S772
  forecast — recorded in the receipt's gotcha (11).
- **Model:** Claude Sonnet 5.

### 2026-09-23 · [issue #169] Mate-pair ancestry guardrails design gate RATIFIED; issue #169 opened
- **Deliverable (design-only, zero `R/`/`tests/`/`man/` changes):**
  `docs/planning/mate-pair-ancestry-guardrails-plan.md` — 10 decisions (6
  forced/evidence-determined; 4 owner judgment calls put in one
  `AskUserQuestion` round, the owner took the recommended option in all four:
  `block` moves a pair to Excluded with reason "ancestry rule" and stays
  overridable; script API = optional `ancestryRules`/`overriddenRules` on
  `reportMatePairs()`; rules uploaded once on Breeding Groups and threaded to
  the Mate Pair module with per-tab overrides/manifest; inline columns + a
  collapsed section + a small Ancestry tab), three implementation slices, ten
  dragons, alternatives, provenance. `BACKLOG.md`'s mate-pair item rewritten
  forward-carrying (design RATIFIED, READY at Slice 1, tracked by #169) — not
  removed, because the implementation is still open.
- **Non-commit action:** GitHub issue **#169** opened (`enhancement`), the full
  draft rendered inline and confirmed by the owner before filing (Learning
  776). Stays open through Slices 1-2; closes at Slice 3's close-out.
- **Findings that shaped the design (measured/read, not inferred):** the rules
  live only inside `modBreedingGroups` (a module-local upload; no return
  element; zero `appServer` wiring) — the crux the BACKLOG item did not name;
  the shipped example fixtures suffice (25 candidate pairs -> 5 block / 3 flag /
  17 unmatched, both rule orientations present); looping
  `reportAncestryViolations()` over two-animal groups measured 2.39 s per
  5,000 pairs (minutes at real 10^5-10^6-pair sizes is an ESTIMATE), so a
  vectorized matcher is required.
- Not run: local suite / `devtools::check()` — no package code changed; all
  code checklists N/A (no `.R`, export, UI, or statistic). Cross-references
  verified: every cited path exists (the one absent path is the plan's own
  proposed new e2e file) and the line pins match the source.
- **Model:** Claude Sonnet 5.

### 2026-09-23 · [ad hoc] S773 claim: mate-pair guardrail surface design gate *(in progress)*
- Owner-picked at the Phase 0 priorities gate (S772 next-steps (B),
  `BACKLOG.md:8`). Orient measured: 0 undocumented on both ledger frontiers
  (both at `897ffd8b` = HEAD), 5 unpushed, CI 10/10 green, S772
  receipt-citation vs `.quality-gates-results.json` matched byte-for-byte
  BEFORE any ratchet run. Deliverable is a design document + the new GitHub
  issue (design gate only, no code). Stub + pending receipt ride this commit;
  close-out records the rest.

### 2026-09-23 · [ad hoc] S772 records: SESSION_NOTES.md read-cap trim DONE, close-out records committed
- **Deliverable:** the trim recorded in the tool-written entry below (`3f78c7ac`,
  owner-ratified `--cut 5 --force`: 8 of 13 records → `-2` shard, 54,857 →
  21,099 B, verify script OK pre- AND post-commit). Post-pass `--check
  --budget-bytes 65536`: CHANGELOG 26,786 B, HANDOFFS 44,468 B,
  SESSION_NOTES 21,099 B — none fire. Ratchet 1/1 at `3f78c7ac` (3,528,717 B,
  −13 B vs S771 = noise; results `7a1b249baa2d`, manifest `aa983075d6a2`);
  the receipt-citation comparison ran at Orient BEFORE the run. Not run:
  local suite/`devtools::check()` — no package code changed. No BACKLOG item
  or GitHub issue involved; no `.R`/export/UI/statistic (all checklists N/A).
- **Receipt:** `HANDOFFS.md` S772 `status: complete` (self 9/10, S771
  evaluated 9/10); its `commit:` names the deliverable commit `3f78c7ac`
  (the records commit cannot name its own sha; no separate sha commit).
  Surfaced, not filed: the read-cap ceiling decision (next-steps (E)).

### 2026-09-23 · [ad hoc] Ledger trim: `SESSION_NOTES.md` → `docs/archive/SESSION_NOTES-through-2026-09-23-2.md` (8 record(s), 54,857 B → 21,099 B)

**Written by:** `methodology_trim.py` v1.5.0 — a tool action, not a session's judgment.
Moved the oldest **8** record(s) (2026-09-19 → 2026-09-23) out of [`SESSION_NOTES.md`](SESSION_NOTES.md) into
[`docs/archive/SESSION_NOTES-through-2026-09-23-2.md`](docs/archive/SESSION_NOTES-through-2026-09-23-2.md). Losslessness is asserted by L1 (records-zone concatenation), L2 (zone
pinning) and L3 (record partition), and is **re-derivable** — run [`docs/archive/SESSION_NOTES-through-2026-09-23-2.md.verify.sh`](docs/archive/SESSION_NOTES-through-2026-09-23-2.md.verify.sh)
rather than trusting a digest printed here. Live file 54,857 B → 21,099 B (−61.5%).

### 2026-09-23 · [ad hoc] S772 claim: SESSION_NOTES.md read-cap trim *(in progress)*
- Owner-picked at the Phase 0 priorities gate (S771 next-steps (A)). Orient
  measured: 0 undocumented on both ledger frontiers (both at `5f7e362b` =
  HEAD), 2 unpushed, CI 10/10 green, S771 receipt-citation vs
  `.quality-gates-results.json` matched byte-for-byte BEFORE any ratchet run.
  `SESSION_NOTES.md` 54,172 B vs the 56,750 B read cap. Stub + pending receipt
  ride this commit; close-out records the rest.

### 2026-09-23 · [ad hoc] S771 sha: close-out commit sha recorded in HANDOFFS.md receipt
- Receipt `commit:` reconciled to `f97b493c` (self-reconcile, S760–S770
  precedent; carries its own ledger entry). Ledger sizes after:
  `SESSION_NOTES.md` 54,172 B (2,578 B under the 56,750 B read cap — trim is
  next-step A), `HANDOFFS.md` and `CHANGELOG.md` well under the 65,536 B
  budget.

### 2026-09-23 · [ad hoc] S771 records: push + CI verification DONE, close-out records committed
- **Deliverable:** the push and CI verification recorded in the entry below.
  Ratchet 1/1 at `79206add` (3,528,730 B, −28 B vs S770 = noise on a
  docs-only diff; results `c02aeda2c3db`, manifest `aa983075d6a2`); the
  receipt-citation comparison ran at Orient BEFORE the run. Not run: local
  full suite / `devtools::check()` — no package code changed this session;
  CI's R-CMD-check + test-coverage on the pushed head is the independent
  verification.
- **Records:** S770 handoff evaluated 9/10 (the read-cap rule had been
  dropped from its standing set); S771 self-assessment 8/10; `HANDOFFS.md`
  receipt complete. `SESSION_NOTES.md` measures 54,172 B vs the 56,750 B
  read cap (2,578 B headroom) after the records were condensed from a
  first draft that measured 57,640 B, 890 B over — a trim is the top
  next-step. Learnings: none appended (FM #28). Disclosed: the claim
  commit carries a `Claude Fable 5` trailer, later commits `Claude Sonnet 5`
  (a mid-session `/model` switch); a mistyped-sha poll cost one round.
- **Not covered by the push's CI:** the live-e2e (shinytest2) tier is
  nightly-schedule + manual-dispatch only per its workflow header, so the
  pushed code's e2e coverage (incl. S769's ancestry e2e file) awaits the
  next nightly run.

### 2026-09-23 · [ad hoc] S771 push: `8007de81..79206add` pushed to `origin/master`; CI green on all four push workflows
- **Action:** `git push origin master` — 98 commits (Orient's 97 unpushed
  plus the S771 claim `79206add`), owner-gated (the Phase 0 priorities
  pick's option text said choosing it was the go-ahead). `origin/master`
  == local HEAD at push time (0 ahead).
- **CI, matched by exact head SHA `79206addff574f281176941bb31ee7ba90b91702`:**
  lint.yaml `35940154521` success; pkgdown.yaml `35940154508` success;
  test-coverage.yaml `35940154485` success; R-CMD-check.yaml `35940154498`
  success (all completed by 2026-09-24T01:14:30Z, R-CMD-check the last at
  25 m). The first CI verification of everything since `8007de81` — the
  whole #168 ancestry-guardrails cluster through Slice 4b, the three
  ledger archive passes, and the pandoc close-out.

### 2026-09-23 · [ad hoc] S771 claim: push to origin/master + CI verification *(in progress)*
- Owner-picked at the Phase 0 priorities gate (S770 next-steps (A)). Orient
  measured: 0 undocumented on both ledger frontiers (both at `42c57ad6` =
  HEAD), 97 unpushed, CI 10/10 green (current through `8007de81`), S770
  receipt-citation vs `.quality-gates-results.json` matched byte-for-byte
  BEFORE any ratchet run. Stub + pending receipt ride this commit; close-out
  records the rest.

### 2026-09-23 · [ad hoc] S770 sha: close-out commit sha recorded in HANDOFFS.md receipt
- Receipt `commit:` reconciled to `f2671ca6` (self-reconcile, S760–S769
  precedent; carries its own ledger entry). Ledger sizes after: all three
  under the 65,536 B budget with the headroom the records entry states.

### 2026-09-23 · [ad hoc] S770 records: archive pass DONE, close-out records committed
- **Deliverable:** the two owner-gated trims recorded in the tool-written
  entries below — `CHANGELOG.md` 66,092 → 20,120 B (`--cut 13`, keeps
  S768–S770) at `b57c35bc`; `HANDOFFS.md` 76,658 → 33,009 B (`--cut 4`,
  keeps S767–S770) at `c195ea31`. Both verify scripts run pre- AND
  post-commit: L1/L2/L3 hold. Post-pass `--check --budget-bytes 65536`:
  none of the three ledgers fires (20,888 / 33,009 / 41,867 B).
- **Records:** S769 handoff evaluated 10/10; S770 self-assessment 9/10;
  `HANDOFFS.md` receipt complete. The archived S760 receipt's standing
  set is carried forward INTO the S770 receipt (S686 forward-carrying
  rule) — successors stop pointing at "S760's live receipt." Learnings:
  none appended (mechanics covered by 777/782; the "S760 next-steps (E)"
  mispointer is corrected in the receipt, FM #28).
- **Verification:** ratchet 1/1 at `c195ea31` (3,528,758 B, +9 B vs S769
  = noise on a docs-only diff; results `9649b761f9d3`, manifest
  `aa983075d6a2`); receipt-citation comparison done before the run.

### 2026-09-23 · [ad hoc] Ledger trim: `HANDOFFS.md` → `docs/archive/HANDOFFS-through-2026-09-23.md` (7 record(s), 76,658 B → 33,009 B)

**Written by:** `methodology_trim.py` v1.5.0 — a tool action, not a session's judgment.
Moved the oldest **7** record(s) (2026-09-22 → 2026-09-23) out of [`HANDOFFS.md`](HANDOFFS.md) into
[`docs/archive/HANDOFFS-through-2026-09-23.md`](docs/archive/HANDOFFS-through-2026-09-23.md). Losslessness is asserted by L1 (records-zone concatenation), L2 (zone
pinning) and L3 (record partition), and is **re-derivable** — run [`docs/archive/HANDOFFS-through-2026-09-23.md.verify.sh`](docs/archive/HANDOFFS-through-2026-09-23.md.verify.sh)
rather than trusting a digest printed here. Live file 76,658 B → 33,009 B (−56.9%).

### 2026-09-23 · [ad hoc] Ledger trim: `CHANGELOG.md` → `docs/archive/CHANGELOG-through-2026-09-23.md` (52 record(s), 66,092 B → 20,120 B)

**Written by:** `methodology_trim.py` v1.5.0 — a tool action, not a session's judgment.
Moved the oldest **52** record(s) (2026-09-21 → 2026-09-23) out of [`CHANGELOG.md`](CHANGELOG.md) into
[`docs/archive/CHANGELOG-through-2026-09-23.md`](docs/archive/CHANGELOG-through-2026-09-23.md). Losslessness is asserted by L1 (records-zone concatenation), L2 (zone
pinning) and L3 (record partition), and is **re-derivable** — run [`docs/archive/CHANGELOG-through-2026-09-23.md.verify.sh`](docs/archive/CHANGELOG-through-2026-09-23.md.verify.sh)
rather than trusting a digest printed here. Live file 66,092 B → 20,120 B (−69.6%).

### 2026-09-23 · [ad hoc] S770 claim: CHANGELOG + HANDOFFS archive pass *(in progress)*
- Session claimed at Phase 1B (stub + pending receipt). Owner picked S769's
  next-steps (A) at the Phase 0 priorities gate. Measured at Orient:
  `HANDOFFS.md` 76,182 B FIRES the ratified 65,536 B trigger; `CHANGELOG.md`
  65,527 B — 9 B under, crossing with this very entry. Phase 0 reconcile:
  0 undocumented on both frontiers; S769 receipt complete, ratchet citation
  matches `.quality-gates-results.json` byte-for-byte; CI 10/10 green.
  Close-out records the rest.

### 2026-09-23 · [ad hoc] S769 sha: close-out commit sha recorded in HANDOFFS.md receipt
- Receipt `commit:` reconciled to `cd36df89` (self-reconcile, S760–S768
  precedent). Measurement correction recorded in receipt + notes:
  `CHANGELOG.md` landed 443 B UNDER the 65,536 B trigger (65,093 B), not
  over as estimated; `HANDOFFS.md` (75,810 B) does fire. Next-steps (A)
  unchanged — the archive pass still covers both files.

### 2026-09-23 · [issue #168] S769 records: Slice 4b DONE, close-out committed
- **Deliverable:** see the GREEN entries below. REFACTOR declared no-op
  (owner-ratified — the one DRY candidate is test-pinned at both sites; the
  S766 in-function-strings-are-the-idiom precedent). `devtools::check()`
  completed after the GREEN commits: **0 errors / 0 warnings / 0 notes**.
- **Records:** S768 handoff evaluated 10/10; S769 full handoff +
  self-assessment 9/10; `HANDOFFS.md` receipt complete. **Learnings: none
  appended** — the one candidate (`commented_code_linter` fires on a prose
  comment with an inner `#` when the prefix parses as a symbol) is a
  sub-case of existing reword-comment reflexes; carried as a handoff gotcha
  instead (FM #28).
- **BACKLOG:** the plan §5 deferred mate-pair guardrail follow-up extracted
  as its own "Up Next" item (its tracking issue closed this session — the
  S686 still-open-sub-thread rule).
- **Reported, not fixed:** after these records, `CHANGELOG.md` (~68 KB) and
  `HANDOFFS.md` (~77 KB) BOTH fire the ratified 65,536 B trim trigger — the
  archive pass is the handoff's next-steps (A); a second archive pass here
  would be a second deliverable.

### 2026-09-23 · [issue #168] S769 issue close: #168 closed as completed (non-commit action)
- `gh issue close 168 --reason completed` with a comment citing the slice
  history (S763/S764/S765/S766/S769), the verification battery, and what is
  deliberately NOT closed with it (the mate-pair follow-up — plan §5,
  extracted to `BACKLOG.md`; the harem-sire hole — its own BACKLOG item).
  Owner-ratified at the GREEN→REFACTOR gate's paired question.

### 2026-09-23 · [issue #168] S769 GREEN 2/2: NEWS + tutorial/article documentation for the completed guardrails (Slice 4b)
- `NEWS.Rmd`: plain-language entry for the completed guardrails (Ancestry
  results tab, per-rule session override with required written reason,
  overridden pairings stay visible, downloadable audit record).
- `vignettes/manual_components/_breeding_group_formation.Rmd`: Ancestry
  Guardrails configuration bullet + the results-tab list corrected to the
  actual four tabs (Groups, Statistics, Group Detail, Ancestry — the list
  had been two-tab stale) with the new Ancestry tab described; includes the
  D6 name-both-UNKNOWN-and-OTHER guidance. Verified: `a3manual.Rmd` (its
  including parent) renders clean.
- `vignettes/articles/colony-manager-guide.qmd`: "Ancestry guardrails"
  walkthrough in the Breeding Group Formation section (upload → status →
  Ancestry sub-tab → override with reason → audit manifest) plus the D6
  UNKNOWN/OTHER practical note. Verified: `quarto render` clean.
- Citation checklist (issue #120) re-checked on the shipped UI: **N/A
  confirmed** — violations and coverage counts are rule bookkeeping, not
  statistics/estimators (plan §5 expectation recorded, not assumed).

### 2026-09-23 · [issue #168] S769 GREEN 1/2: Slice 4b implementation — override gate, Ancestry results tab, audit-manifest download
- `R/modBreedingGroups.R`: static override controls inside the guardrails
  panel (`overrideRule` select over the not-yet-overridden block rules,
  `overrideOpen` → #150-mold `modalDialog` with verbatim
  `.ancestryOverrideWarningText` + required `overrideReason` +
  `overrideConfirm`, `overrideStatus`, `clearOverrides`); overrides are
  session-scoped (`ancestryOverridesRV`), reset on rules re-upload; the
  formation call now passes `.effectiveAncestryRules(rules, overrides)` and
  SNAPSHOTS rules/overrides/ped(id, ancestry) into `groupResults` (Learning
  780 + the #150 params-snapshot mold); `ancestryReport()` feeds
  `reportAncestryViolations()` the selected candidate's FORMED groups only
  (Learning 781) with the ORIGINAL rules + overrides; `ancestryManifest()`
  via `.buildAncestryOverrideManifest`; new "Ancestry" results tab
  (guidance, violations DT, coverage table, manifest `downloadHandler` via
  `getDatedFilename()`). Return list unchanged (module contract rule 4).
- **Verification (measured):** target file 20/20 blocks, 105 expectations,
  0 failed / 0 error (first run after implementation); full suite (NOT_CRAN,
  `load_all()`, unfiltered) **0 failed / 0 error / 7662 passed / 186
  skipped / 6 warnings** (warnings pre-existing; +1 skip = the new e2e
  file's opt-in gate); **live e2e** (`NPRC_RUN_E2E=true`, headless Chrome,
  dev build installed): new `test-e2e-breeding-groups-ancestry.R` 17/17 —
  full drive incl. both manifest downloads (block-rule `nPairs == 0`
  pre-override; overridden row + reason + verbatim warning post-override),
  zero console errors; sibling `e2e-breeding-groups-{module,detailed,
  tutorial}` 26/26; lint 0 on all three touched files (one
  `commented_code_linter` false positive resolved by rewording the comment
  — the inner `#168` made the comment prefix parse as code).
  `devtools::check()` result recorded at close-out (running at commit time).

### 2026-09-23 · [issue #168] S769 RED: Slice 4b failing tests committed (override gate + Ancestry tab + manifest + e2e)
- 9 new blocks appended to `tests/testthat/test_modBreedingGroups_ancestryRules.R`
  (header updated to cover 4a+4b): Ancestry-tab + override-control UI ids;
  controls inside the guardrails panel; `overridableRules()` (block rules minus
  overridden); blank-reason rejection; confirm/clear/reset-on-reupload; the
  Learning 780 two-call wiring test (I1+C1 topRanked candidates: blocked →
  override → co-placed; report row `severity` block / `status` overridden;
  manifest row overridden TRUE + reason + verbatim gate wording; run-time
  SNAPSHOT semantics — a late override never rewrites an earlier run's
  manifest, the #150 mold); the Learning 781 universe test (coverage census =
  formed groups only, unused bucket excluded); pinned guidance strings.
  New `tests/testthat/test-e2e-breeding-groups-ancestry.R` (opt-in
  `NPRC_RUN_E2E`) drives the plan §5 done-when path live, asserting through
  the two downloaded manifests; its name matches the existing
  `^e2e-breeding-groups-` CI group regex, so registration is by construction
  (statically guarded by `test_shinytest2_workflow_coverage.R`).
- **Per-block RED audit (measured):** 4a blocks 1–11 all pass (39 passing
  expectations file-wide); all 9 new blocks FAIL — 2 by assertion on the
  missing UI ids (13 failed expectations), 7 by error on the missing server
  symbols (`overridableRules`, `ancestryOverridesRV`, `overrideStatusText`,
  `ancestryReport`, `ancestryManifest`, `ancestryTabGuidanceText`). Passing
  expectations inside failing blocks are 4a-behavior preconditions only.
  The e2e file parses and self-skips without the opt-in env var.
- Owner gates this session before RED: override lifetime = until cleared /
  rules re-upload (each run snapshots what was in effect); control shape =
  select + "Override rule…" button + #150 modal; PRE-RED→RED ratified with
  the exact block list.

### 2026-09-23 · [issue #168] S769 claim: Slice 4b — ancestry override controls + Ancestry results tab *(in progress)*
- Session claimed at the Phase 0 priorities gate (owner pick via `AskUserQuestion`).
  Deliverable: the §5 Slice 4 remainder from
  `docs/planning/issue168-ancestry-guardrails-plan.md:371` — override controls behind
  the #150-style `modalDialog` gate with required reason, effective rules to formation
  and ORIGINAL rules + overrides to the reporter/manifest (Learning 780), "Ancestry"
  results tab over FORMED groups only (Learning 781), `shinytest2` e2e registered in
  `.github/workflows/shinytest2.yaml` same-session, tutorial/article docs, #120
  re-check, and the explicit #168 close call. Strict TDD; stub + pending receipt
  committed with this claim.

### 2026-09-23 · [ad hoc] S768 sha: close-out commit sha recorded in HANDOFFS.md receipt
- `HANDOFFS.md` S768 receipt `commit:`/`changelog_ref:` fields reconciled to
  `a220e212` (self-reconcile, S760–S767 precedent; carries its own ledger entry).

### 2026-09-23 · [ad hoc] S768 records: pandoc item DONE, close-out records committed
- **Deliverable:** see the S768 deliverable entry below (`0fa0c067`). This entry
  records the close-out and the one owner-gated decision that rode with it.
- **Decision (owner-gated, `AskUserQuestion`):** `SESSION_NOTES.md` trimmed with
  `--cut 5 --force --budget-bytes 65536` (commit `d6d07e33`; the tool wrote the
  ledger entry above — Learning 782, no duplicate). `--force` was needed because
  the trimmer's own trigger (65,536 B) did not fire at 55,266 B, while the
  25,000-token one-read cap (56,750 B) would have made the pre-commit hook refuse
  this session's close-out records (the S762 situation). Owner picked `--cut 5`
  (live 23,645 B) over `--cut 8` (33,409 B); both dry runs measured L1/L2/L3 OK;
  the verify script ran clean before AND after the commit.
- **Records:** S767 handoff evaluated 9/10; S768 full handoff + self-assessment
  8/10; `HANDOFFS.md` receipt complete. **Learning 783** appended (a standing
  workaround that is green with or without the fix hides the fix's arrival — probe
  "owner action pending" environment items with the workaround OFF before ranking
  them). `BACKLOG.md` item already removed in the deliverable commit.
- **Verification:** ratchet 1/1 pass at `e8d32ec0` (3,521,109 B, results
  `ec7f2bd24e18`, manifest `aa983075d6a2`, no PATH workaround). Docs/environment-only
  session — no `.R` touched, so lint/suite/check not owed.
- **Reported, not fixed:** post-records `methodology_trim.py --check
  --budget-bytes 65536` — `SESSION_NOTES.md` 30,881 B and `CHANGELOG.md` 56,674 B
  do not fire; **`HANDOFFS.md` 68,907 B FIRES** (this session's own receipt took it
  from ~62.4 KB). Nothing mechanical gates on it and a second archive pass would be
  a second deliverable, so it is carried as next-steps (B) in the handoff.
- **Disclosures:** (1) the Phase 0 step 6 receipt-citation comparison was skipped
  before the ratchet re-run overwrote the results file (see the deliverable entry);
  (2) commit `e8d32ec0` carries a `Co-Authored-By: Claude Fable 5` trailer, the
  later S768 commits carry `Claude Sonnet 5` — the harness's attribution reminder
  changed mid-session and each commit followed the reminder in force at the time.

### 2026-09-23 · [ad hoc] Ledger trim: `SESSION_NOTES.md` → `docs/archive/SESSION_NOTES-through-2026-09-23.md` (9 record(s), 55,266 B → 23,645 B)

**Written by:** `methodology_trim.py` v1.5.0 — a tool action, not a session's judgment.
Moved the oldest **9** record(s) (2026-09-22 → 2026-09-23) out of [`SESSION_NOTES.md`](SESSION_NOTES.md) into
[`docs/archive/SESSION_NOTES-through-2026-09-23.md`](docs/archive/SESSION_NOTES-through-2026-09-23.md). Losslessness is asserted by L1 (records-zone concatenation), L2 (zone
pinning) and L3 (record partition), and is **re-derivable** — run [`docs/archive/SESSION_NOTES-through-2026-09-23.md.verify.sh`](docs/archive/SESSION_NOTES-through-2026-09-23.md.verify.sh)
rather than trusting a digest printed here. Live file 55,266 B → 23,645 B (−57.2%).

### 2026-09-23 · [ad hoc] S768 deliverable: broken-pandoc environment item RESOLVED and verified with the PATH workaround OFF; `BACKLOG.md` item removed
- **Finding:** the owner action the item asked for was already done before this
  session — no sudo step was run or needed here. `/usr/local/bin/pandoc` (the
  x86_64 binary) no longer exists; `which -a pandoc` shows only
  `/opt/homebrew/bin/pandoc` → `Cellar/pandoc/3.11` (arm64 Mach-O; symlink mtime
  Sep 22 17:15, so the Homebrew install predates the S765–S767 sessions; when the
  x86_64 file was removed is undated). No `RSTUDIO_PANDOC`/pandoc env vars set.
- **Verified WITHOUT the PATH workaround** (each surface the item's blast radius
  named): `rmarkdown::find_pandoc(cache = FALSE)` → 3.11 at `/opt/homebrew/bin`,
  `pandoc_available()` TRUE (no "subscript out of bounds" crash);
  `tests/testthat/test_positionMatingUnitForest.R` → 57 tests, **212/212
  expectations, 0 failed / 0 error / 0 skipped / 0 warnings**, and the 3 chromote
  live-render blocks each ran and passed (3+2+2 expectations) — the same 212 the
  item recorded as the "clean" figure under the workaround; `quality_ratchet.py
  --run` → **1/1 pass at `e8d32ec0`, 3,521,109 B** (results `ec7f2bd24e18`,
  manifest `aa983075d6a2`; −10 B vs S767's 3,521,119 B = noise — pandoc 3.11 vs
  the 3.10 the workaround used moved nothing measurable). The ratchet's clean-export
  build includes vignettes, so it exercises pandoc for real.
- **Not run (stated, not skipped silently):** the full suite and
  `devtools::check()` — no package code, tests, or docs-as-shipped changed, and
  each named blast-radius surface was verified directly. The local "3 errors on
  `test_positionMatingUnitForest.R`" reading is now retired as an environment
  artifact; a recurrence would be a NEW defect (re-probe `which -a pandoc` first).
- **Disclosure:** Phase 0 step 6's comparison of S767's receipt citation
  (`results 42f1031a3c6b`) against `.quality-gates-results.json` was not made
  before this session's re-run overwrote that gitignored file. The re-run is the
  step's permitted alternative and agrees on everything checkable (pass, identical
  manifest, size within 10 B); the specific results-hash comparison is lost.
- **`BACKLOG.md`:** the item (former lines 46-66) removed entirely per the S686
  completed-item removal checklist; this entry carries its load-bearing record.
  It was the only live file still carrying the literal workaround string (verified
  by `git grep` outside `docs/archive`); the 15 pandoc mentions in
  `PROJECT_LEARNINGS.md` are historical smart-quote/render learnings, not standing
  instructions.

### 2026-09-23 · [ad hoc] S768 claim: pandoc environment fix — resolve the broken x86_64 `/usr/local/bin/pandoc` (in progress)
- Owner picked the BACKLOG "Replace the broken x86_64 pandoc" item (found S756,
  owner action needing sudo) at the Phase 0 priorities gate. Session claimed:
  stub + pending `HANDOFFS.md` receipt + this entry. Plan: owner executes the
  sudo step; session verifies `rmarkdown::find_pandoc()`, the 3 chromote
  live-render tests, and the ratchet gate WITHOUT the PATH workaround, then
  removes the `BACKLOG.md` item. Docs/environment only — no package code.

