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

**Archived 54 record(s), 2026-09-23 → 2026-09-24** into [`docs/archive/CHANGELOG-through-2026-09-24.md`](docs/archive/CHANGELOG-through-2026-09-24.md) — same format, same order, frozen.
Losslessness is proved by [`docs/archive/CHANGELOG-through-2026-09-24.md.verify.sh`](docs/archive/CHANGELOG-through-2026-09-24.md.verify.sh), which re-derives L1/L2/L3 from git; run it rather
than trusting this sentence. Written by `methodology_trim.py` v1.5.0.

### 2026-09-26 · [ad hoc] S782 REFACTOR: PED_GV F1 -- one no-op `stri_c()` removed from a new test title
- Owner-gated (chose the review pass over skipping). Review of `R/removeUnknownAnimals.R` (3
  changed lines) found nothing to restructure; folding the guard into `getRecordStatusIndex()` or a
  shared helper would cross function boundaries (plan-mode work, out of scope). The one change: the
  all-`added` test title in `tests/testthat/test_removeUnknownAnimals.R` wrapped a single string in
  `stri_c()`, which does nothing; it is now a plain, shorter title. **No behavior change; measured:**
  the file still shows 13 expectations passing, 0 failing, and lint finds 0 on it. **Not re-run:**
  the full suite and `R CMD check` -- only a test title in one file changed, and the GREEN entry
  below holds those results for the same code.

### 2026-09-26 · [ad hoc] S782 GREEN: PED_GV F1 fixed -- `removeUnknownAnimals()` returns a pedigree without a `recordStatus` column unchanged
- **Fix:** `R/removeUnknownAnimals.R` -- a guard returns `ped` as-is when `"recordStatus"` is not in
  `names(ped)` (was 17 rows in, 0 out, silently); the with-column line is untouched and
  `getRecordStatusIndex()` was not changed. One roxygen `@return` sentence states the no-column
  behavior; `devtools::document()` changed only `man/removeUnknownAnimals.Rd`.
- **Verification (measured):** `test_removeUnknownAnimals.R` 13 expectations pass, 0 fail (RED had
  2 failing); `test_getRecordStatusIndex.R` passes. **Full suite** (`load_all` + `NOT_CRAN`, no
  file filter): 352 files, 2,682 tests, 1 failed, 0 errors, 6 warnings, 4.8 min. The 1 failure is
  `test_pkgdown_reference_config.R` "articles: contents covers every real article", and its own
  message names `suggested_NEWS_entry` -- the owner's UNTRACKED `vignettes/suggested_NEWS_entry.Rmd`,
  which pkgdown lists as an article missing from `_pkgdown.yml`; it is not in a clean export, so
  CI cannot see it, and I did not touch the file. All 6 warnings are in
  `test_modGeneticValue_snapshotSource.R`, none in this change's files. **Lint:** 0 findings on
  both touched files (after `load_all`). **`R CMD check --as-cran --no-manual`** on
  `git archive $(git write-tree)` (HEAD plus these two staged files; 0 copies of the owner's
  draft in it; tarball 3,565,400 B): 0 errors, 0 warnings, 1 NOTE ("Version contains large
  components (2.0.0.9000)", from the development version; not re-measured on the parent commit);
  examples OK, tests OK (267 s), exit status 0; env `_R_CHECK_CRAN_INCOMING_REMOTE_` and
  `_R_CHECK_FORCE_SUGGESTS_` set to false.
- **Disclosure:** my first two check runs were NOT clean evidence -- the first printed 0/0/0 with
  exit status 1 because `--as-cran` aborted at "CRAN incoming feasibility" (a 404 fetching the
  package index), and I only saw that by re-running with the output kept. **Runtime (3E):** no app
  caller exists (`R/` never calls the function); the roxygen example ran under check.

### 2026-09-26 · [ad hoc] S782 RED: PED_GV F1 -- tests for `removeUnknownAnimals()` on a pedigree without `recordStatus`
- Owner decisions at the Pre-RED gate (2026-09-26): a pedigree with no `recordStatus` column is
  returned unchanged (not `stop()`); NA / unrecognised `recordStatus` values are OUT of scope
  (probe P2 found an all-NA phantom row from `x == status` indexing -- to be filed in `BACKLOG.md`
  at close-out, with the same pattern at `R/convertDate.R:95-96`). Tests only
  (`tests/testthat/test_removeUnknownAnimals.R`, +3 `test_that` blocks; existing 2 untouched; no
  `R/` change). **Measured RED:** the file reports 2 failures and 10 passes -- both failures are the
  no-column case (`smallPed` 17 -> 0 rows, `pedSix` 8 -> 0 rows); the all-`added` and zero-row
  guards pass today by design. Commit left RED on purpose; GREEN follows behind an owner gate.

### 2026-09-26 · [ad hoc] S782 claim: PED_GV F1 -- `removeUnknownAnimals()` on a pedigree without `recordStatus` *(in progress)*
- Owner-picked at the Phase 0 priorities gate (S781 next-steps (A)). Orient measured: 0
  undocumented on both the `CHANGELOG.md` and `HANDOFFS.md` frontiers (`f9e0152b` = HEAD); no
  `status: pending` receipt; 11 unpushed, `origin/master` = `b5166c8b`; the S781 receipt's ratchet
  citation (results `b969c2dbef9b`, manifest `aa983075d6a2`, head `3c9aa076`) matched
  `.quality-gates-results.json` byte-for-byte BEFORE any run; all 10 recent `gh run` rows
  `success`. Stub + pending receipt ride this commit; close-out records the rest. TDD phase
  PRE-RED at claim; no code touched.

### 2026-09-26 · [ad hoc] S781 records: close-out for the PED_GV audit triage (S780 handoff evaluated 8/10, receipt, Learning 794, next-session items)
- **Deliverable:** the close-out records for S781, whose work is recorded in the entries below:
  the triage report (`737c2d17`), the `BACKLOG.md` rewrite (`3c9aa076`) and the owner-gated
  `SESSION_NOTES.md` archive (`ad6e5e89`, tool-written entry). Adds the `HANDOFFS.md` receipt, the
  `SESSION_NOTES.md` record with the S780 handoff evaluation, and Learning 794 (an id grep of the
  ledger over-counts as well as under-counts).
- **Ratchet:** 1/1 at `3c9aa076` (3,565,177 B, +46 B vs S780 = noise on a docs-only diff; results
  `b969c2dbef9b`, manifest `aa983075d6a2`); the S780 citation matched the results file BEFORE the
  run. **Not run:** the suite and `devtools::check()` -- no code changed and every changed file is
  build-ignored with no reader in `tests/` or `.github/`.
- **Not done, owner's call:** the push (11 local commits after this one) and the working-tree
  residue (the `BACKLOG.md` YAML header, `BACKLOG.log`, the two `suggested_NEWS_entry` drafts).
- **Model:** Claude Sonnet 5.

### 2026-09-26 · [ad hoc] Ledger trim: `SESSION_NOTES.md` → `docs/archive/SESSION_NOTES-through-2026-09-25.md` (8 record(s), 55,101 B → 17,581 B)

**Written by:** `methodology_trim.py` v1.5.0 — a tool action, not a session's judgment.
Moved the oldest **8** record(s) (2026-09-24 → 2026-09-25) out of [`SESSION_NOTES.md`](SESSION_NOTES.md) into
[`docs/archive/SESSION_NOTES-through-2026-09-25.md`](docs/archive/SESSION_NOTES-through-2026-09-25.md). Losslessness is asserted by L1 (records-zone concatenation), L2 (zone
pinning) and L3 (record partition), and is **re-derivable** — run [`docs/archive/SESSION_NOTES-through-2026-09-25.md.verify.sh`](docs/archive/SESSION_NOTES-through-2026-09-25.md.verify.sh)
rather than trusting a digest printed here. Live file 55,101 B → 17,581 B (−68.1%).

### 2026-09-26 · [ad hoc] `BACKLOG.md`: rewrote the PED_GV item from "triage first" to the post-triage plan
- **S781.** The item's first deliverable (the triage table) is done, so its "triage first" text
  became the follow-through plan: four correctness-hazard slices in order (F1 and F4 ready, F2 and
  F3 need an owner decision), a trivial-cleanup bundle, the owner-decision list for the overhaul
  roots, NEW-24 pointed at issue #123, 11 ids recommended for closing, and a warning that an id
  grep of the ledger both under- and over-counts. The item stays open: no fix has been made.
- The owner's own uncommitted `BACKLOG.md` change (the 5-line YAML header) was left out of the
  commit (staged from a header-less blob) and stays in the working tree. Docs-only; build-ignored.
- **Model:** Claude Sonnet 5.

### 2026-09-26 · [ad hoc] PED_GV audit triage report: 43 ids judged against today's code
- **Deliverable (S781):** `docs/audits/PED_GV_AUDIT_TRIAGE_2026-09-26.md`. One row per id, judged
  against today's source, with 9 R probes and the git history since the audit. **Result:** 35
  still present, 2 fixed (PED-8, PED-9), 4 moot (NEW-27, 33, 44, 47), 2 refuted (NEW-58, NEW-60).
  Only 5 of the 35 are correctness hazards, in four groups: `removeUnknownAnimals()` returns 0 rows
  when `recordStatus` is absent (NEW-31/32); the `U`-prefix id scheme can collide with or strip real
  ids (NEW-38); an excluded dam is re-admitted by `getPotentialParents()`'s fallback (NEW-35); and
  `getAncestors()` recurses forever on a cycle (NEW-41).
- **The 41-id list was off by two.** The ledger mentions NEW-29 and NEW-47 without recording a fix
  (NEW-47 is a NEWS label that collides with the audit id), so both were added: 43 rows. None of
  the 43 ids appears in any commit message; fixes travelled under issue numbers and XARCH names.
- **Nothing was fixed and no code changed.** Docs-only; `docs/` is build-ignored and no test or
  workflow reads the file. The 122 cited lines were extracted and compared with the claims; two
  cites that pointed at roxygen were corrected. Not pushed.
- **Model:** Claude Sonnet 5.

### 2026-09-26 · [ad hoc] S781 claim: PED_GV audit triage *(in progress)*
- Owner-picked at the Phase 0 priorities gate (S780 next-steps (A)). Orient measured: 0
  undocumented on the `CHANGELOG.md` frontier (`44a6c5e1` = HEAD); 1 commit past the
  `HANDOFFS.md` frontier, `44a6c5e1`, which is the owner-directed non-session addendum below (no
  receipt owed, its own entry says so); 6 unpushed, `origin/master` = `b5166c8b`; the S780
  receipt's ratchet citation matched `.quality-gates-results.json` byte-for-byte BEFORE any run;
  all 10 recent `gh run` rows `success`. Stub + pending receipt ride this commit; close-out
  records the rest.

### 2026-09-26 · [ad hoc] `BACKLOG.md`: recorded four owner-requested items (documentation staleness audit, contributor tutorial, LabKey collaboration, journal papers)
- Owner-directed addendum after S780 closed; **not a session** -- the owner clarified it was only a
  group of backlog items to record, so no claim, receipt or handoff was written. Four new open
  items (78 lines, additions only): the documentation audit for stale information and diagrams
  (READY, L) and the contributor tutorial (DECISION NEEDED, M), inserted after the `NEWS.Rmd`
  sweep; the LabKey collaboration with Josh Eckels (BLOCKED, M), after the existing LabKey item;
  and developing peer-reviewed papers (DECISION NEEDED, L), under Outreach. Placement is
  provisional and unranked -- the owner orders priorities.
- Facts stated in the items were measured 2026-09-26 (the two untracked PDFs dated 2026-08-25
  against `.qmd` sources dated 2026-09-17/18; no `CONTRIBUTING.md` or `CODE_OF_CONDUCT`;
  `DESCRIPTION` at 2.0.0.9000). The figures' staleness and the journal assessments are the
  owner's observation and an unverified pasted summary, and the items say so.
- The owner's own uncommitted `BACKLOG.md` change (a 5-line YAML header) was left out of the
  commit (staged from a header-less blob) and stays in the working tree, with the untracked
  `BACKLOG.log` and two `suggested_NEWS_entry` drafts. Docs-only; every changed file is
  build-ignored; not pushed (6 local commits).
- **Model:** Claude Sonnet 5.

### 2026-09-26 · [ad hoc] S780 records: `HANDOFFS.md` + `CHANGELOG.md` archive pass DONE (S779 handoff evaluated 9/10, receipt, next-session items)
- **Deliverable:** the ledger archive pass claimed 2026-09-24 (entry below, *(in progress)*),
  recorded by the two tool-written trim entries above it and the commits `b8ea95fa` (CHANGELOG)
  and `ff2f0f7f` (HANDOFFS). This entry adds what the tool does not know: **the owner gate**
  (one two-question `AskUserQuestion`: `CHANGELOG.md --cut 16 --force` and `HANDOFFS.md`
  default keep-3 `--force`, each ratified with the dry-run numbers and both SRF readings;
  the calendar-seam `--cut 2026-09-23` and "hold" options were declined) and **the numbers**:
  `HANDOFFS.md` 104,171 -> 26,031 B, `CHANGELOG.md` 97,745 -> 32,777 B with both trims' entries
  (143,108 B out of the live ledgers), the verify scripts run pre- and post-commit, none of the
  three ledgers firing `--check --budget-bytes 65536` afterward.
- **Verification:** ratchet 1/1 at `ff2f0f7f` (3,565,131 B; results `bd73c59e2e67`, manifest
  `aa983075d6a2`). No suite or `devtools::check()` run: no package code changed and every changed
  file is build-ignored. Nothing pushed; 5 local commits. CI state refreshed on return: all four
  workflows `success` on `b5166c8b`; nightly `shinytest2` `success` 2026-09-25 and 2026-09-26.
- **Also recorded:** the context-budget hook refused the first records commit
  (`SESSION_NOTES.md` 25,568 tokens vs the 25,000 ceiling); my removal of that file's oldest
  group was denied by the harness and not retried by another route, so the records were
  condensed instead (no committed content removed). Owner-side working-tree changes found on
  return (`BACKLOG.md` YAML front matter; untracked `BACKLOG.log` and two `suggested_NEWS_entry`
  drafts) were left untouched and unstaged.
- **Model:** Claude Sonnet 5.

### 2026-09-24 · [ad hoc] Ledger trim: `HANDOFFS.md` → `docs/archive/HANDOFFS-through-2026-09-24.md` (11 record(s), 104,171 B → 26,031 B)

**Written by:** `methodology_trim.py` v1.5.0 — a tool action, not a session's judgment.
Moved the oldest **11** record(s) (2026-09-23 → 2026-09-24) out of [`HANDOFFS.md`](HANDOFFS.md) into
[`docs/archive/HANDOFFS-through-2026-09-24.md`](docs/archive/HANDOFFS-through-2026-09-24.md). Losslessness is asserted by L1 (records-zone concatenation), L2 (zone
pinning) and L3 (record partition), and is **re-derivable** — run [`docs/archive/HANDOFFS-through-2026-09-24.md.verify.sh`](docs/archive/HANDOFFS-through-2026-09-24.md.verify.sh)
rather than trusting a digest printed here. Live file 104,171 B → 26,031 B (−75.0%).

### 2026-09-24 · [ad hoc] Ledger trim: `CHANGELOG.md` → `docs/archive/CHANGELOG-through-2026-09-24.md` (54 record(s), 97,745 B → 32,005 B)

**Written by:** `methodology_trim.py` v1.5.0 — a tool action, not a session's judgment.
Moved the oldest **54** record(s) (2026-09-23 → 2026-09-24) out of [`CHANGELOG.md`](CHANGELOG.md) into
[`docs/archive/CHANGELOG-through-2026-09-24.md`](docs/archive/CHANGELOG-through-2026-09-24.md). Losslessness is asserted by L1 (records-zone concatenation), L2 (zone
pinning) and L3 (record partition), and is **re-derivable** — run [`docs/archive/CHANGELOG-through-2026-09-24.md.verify.sh`](docs/archive/CHANGELOG-through-2026-09-24.md.verify.sh)
rather than trusting a digest printed here. Live file 97,745 B → 32,005 B (−67.3%).

### 2026-09-24 · [ad hoc] S780 claim: HANDOFFS.md + CHANGELOG.md ledger archive pass *(in progress)*
- Owner-picked at the Phase 0 priorities gate (S779 next-steps (B)). Orient measured: 0
  undocumented on both ledger frontiers (both at `84cb6155` = HEAD), 1 unpushed, S779
  receipt-citation vs `.quality-gates-results.json` matched byte-for-byte BEFORE any ratchet run.
  `HANDOFFS.md` 103,826 B and `CHANGELOG.md` 97,220 B vs the 65,536 B trigger. Stub + pending
  receipt ride this commit; close-out records the rest.

### 2026-09-24 · [ad hoc] S779 records: close-out for the ad hoc session (S778 handoff evaluated 8/10, receipt, Learnings 791-793, next-session BACKLOG items)
- **Deliverable:** the close-out records for the owner-directed ad hoc work of 2026-09-24, recorded
  in the entries below: the `.Rprofile` renv startup check (`23f20f3a`), the removal of
  `nprcgenekeepr_notes.txt` (`c182511b`), the `BACKLOG.md` staleness review and cleanup
  (`c67a3106`, `ab50aed1`, `0cc75dc4`, `59cb4406`, `8a616f15`, with the NEW-53 backfill) and three
  pushes. **Numbering:** the session is called **S779** here, at close-out; the earlier entries for
  this work say "outside a numbered session" and, being append-only, are not edited -- this entry
  supplies the number. No Phase 0/1 claim was made (the session began with an owner question).
- **Records:** `SESSION_NOTES.md` (S778 handoff evaluation 8/10, the S779 record, self-assessment
  6/10); `HANDOFFS.md` receipt `status: complete` (`commit: pending`); `PROJECT_LEARNINGS.md`
  Learnings **791** (trace a "resolved" section into the ledger by tag count and by ID plus name),
  **792** (no CI wait for build-ignored, unread files) and **793** (measure remote state before
  writing it into a menu); `BACKLOG.md` two items at the top of Up Next -- the owner's next-session
  pick, **resolve the PED_GV audit's remaining findings, triage first** (`:8`), and the optional
  `paths-ignore` decision (`:35`). Nothing was removed from `SESSION_NOTES.md` (45,210 B after
  these records, under the read cap).
- **Verification:** ratchet **1/1 at `b5166c8b`** (3,565,188 B, +23 B vs S778 = noise, every changed
  file being build-ignored; results `0936149cc117`, manifest `aa983075d6a2`; the S778 citation
  matched its results file BEFORE the run). Cross-references grepped: Learnings 791-793 resolve;
  the BACKLOG pins `:8`, `:35`, `:48`, `:70`, `:86`, `:108`, `:128`; `CHANGELOG.md:49`,
  `HANDOFFS.md:166`, `SESSION_NOTES.md:67`. **Not run:** the suite and `devtools::check()` -- no
  package code changed. **Disclosed:** no Phase 0; the TDD phase declared on most responses, not
  all; a wrong ahead-count in a picker (Learning 793); two CI watches the owner called a waste of
  time (Learning 792).
- **Commit:** this commit -- the five files above plus this entry. **Local, not pushed** (1
  unpushed after close-out, as at S778).

### 2026-09-24 · [ad hoc] Pushed `59cb4406..b5166c8b` to `origin/master` (2 docs-only commits); CI not awaited
- **Action:** `git push origin master` -- 2 commits: `8a616f15` (the `BACKLOG.md` cut of the three
  resolved sections plus the NEW-53 backfill entry) and `b5166c8b` (the ledger entry for the
  previous push). Owner-directed ("push the two commits"). **Before the push:** `git fetch` showed
  origin at `59cb4406`, an ancestor of HEAD (fast-forward); the outgoing diff was 2 files
  (`BACKLOG.md`, `CHANGELOG.md`), +87/-67, with no secret-named files and no credential-shaped
  strings in the added lines. **After:** local and `origin/master` both at `b5166c8b`.
- **CI:** not awaited and not looked at, per the owner's standing direction ("do not wait for an
  uninformative CI"): both changed files are matched by `.Rbuildignore` (`^BACKLOG.*\.md$`,
  `^CHANGELOG.*\.md$`) and no test or workflow reads either.
- **Session:** S779 (numbered at close-out) · **Verified:** the pre-push checks above only.
- **Not pushed:** the S779 records commit is local.

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

