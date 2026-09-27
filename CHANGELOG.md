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

**Archived 25 record(s), 2026-09-24 → 2026-09-26** into [`docs/archive/CHANGELOG-through-2026-09-26.md`](docs/archive/CHANGELOG-through-2026-09-26.md) — same format, same order, frozen.
Losslessness is proved by [`docs/archive/CHANGELOG-through-2026-09-26.md.verify.sh`](docs/archive/CHANGELOG-through-2026-09-26.md.verify.sh), which re-derives L1/L2/L3 from git; run it rather
than trusting this sentence. Written by `methodology_trim.py` v1.5.0.

### 2026-09-26 · [ad hoc] S787 REFACTOR (test-only step): one control test closes mutant M7 (only the exact status `"added"` is set aside)
- Owner decision: the GREEN to REFACTOR gate ("Yes, REFACTOR: review + docs + M7 test",
  2026-09-26), which offered the alternatives "docs only, no M7 test" and "extract the shared
  `isAddedRecord()` helper" (declined). Review of `R/correctParentSex.R`: no code change; the
  shared `isAddedRecord()` helper stays deferred (four inline copies now: `convertDate.R:103`,
  `removeDuplicates.R:46`, `removeUnknownAnimals.R:31` as the complement, and this function).
- The one test-only addition, `tests/testthat/test_correctParentSex.R` (+1 `test_that`, the
  control "only the exact status added is set aside": `"Added"` and `"ADDED"` are unrecognised
  statuses, so real animals, in the five status layouts). It passes on the GREEN code by design
  (the exact-match behaviour already existed), so it is a control, not a RED test; against the
  pre-change code it fails, which is why that mutant now fails 6 tests and 59 expectations
  instead of the RED count of 5 and 43.
- **Measured:** the target file 18 tests, **121 of 121 expectations**, 0 errors, 0 warnings;
  lintr 0; the mutants re-run with the same controls (the real function and the GREEN-equivalent
  builder both fail 0 tests): **13 of 13 killed**, no survivors (M7 is now killed by the new test,
  1 test and 16 expectations). The host load average was still about 327 (`uptime`).

### 2026-09-26 · [ad hoc] S787 GREEN: `correctParentSex(reportErrors = TRUE)` sets aside only `"added"` records and checks every animal when the status is `NULL`
- Owner decision: the RED to GREEN gate ("Yes, proceed to GREEN", 2026-09-26). One file, the
  report branch only (`R/correctParentSex.R:89-98`): one mask `isAdded` (`rep(FALSE, length(id))`
  for a `NULL` status, otherwise `!is.na(recordStatus) & recordStatus == "added"`) replaces both
  `recordStatus == "original"` terms with `!isAdded`. The correction branch, the sex handling, an
  omitted argument's error and the recycling of a mismatched-length status are untouched; roxygen,
  `man/`, `NEWS.Rmd` and `BACKLOG.md` follow in the docs commit.
- **Measured GREEN:** the target file 17 tests, **101 of 101 expectations**, 0 errors, 0 warnings
  (the 5 failing tests pass, the 12 others stay green). Full suite (`load_all` + `NOT_CRAN`, no
  filter): 353 files, 2,727 tests, 8,474 expectations, 0 errors, 187 skipped, 6 warnings (+11
  tests, +87 expectations against S786, exactly this slice: 101 minus the 14 already there), and
  **3 failed**: the known `test_pkgdown_reference_config.R` (the owner's untracked NEWS draft)
  plus two runtime benchmarks, `test_markerKinship.R` (median 0.101 s against a 0.1 s limit) and
  `test_markerParentageLikelihood.R` (0.516 s against 0.5 s), which touch none of this code. Both
  fail the same way on the pre-change tree exported from `HEAD` (0.107 s and 0.575 s), and the host
  load average was 350 (`uptime`, processes outside this session) with the suite taking 8.9 min
  against about 4.6 min, so they are environmental, not caused by this change; they are rechecked
  at close-out. lintr 0 on `R/correctParentSex.R` and the test file.
- **Mutation testing** (13 mutants of the report-branch mask over the target file plus
  `test_qcStudbook.R`, controls first): the real function and a builder configured as GREEN both
  fail 0 tests, and the pre-change code as a mutant fails exactly the RED count (5 tests, 43
  expectations), so the harness is faithful. **12 of 13 killed** (an unguarded `NA` negation, a
  missing `NULL` branch, only-`"original"`-counts, `NA` counted as added, blank counted as added,
  added not excluded, any added row skipping all, each of the sire and dam masks dropped, `NULL`
  meaning none, and a scalar-only-first mask). **One survivor, M7:** a case-insensitive `"added"`
  passes every test, because no test pins that `"Added"` or `"ADDED"` is an unrecognised status and
  so a real animal; raised at the GREEN to REFACTOR gate, not patched in GREEN.
- **Runtime (3E), differential:** `correctParentSex()` is on the app's upload path, so 140
  `qcStudbook()` calls (`reportErrors` both ways over 13 package datasets, 13 example pedigree
  files, `ExamplePedigree.txt` and, for each, a variant with a sire flipped to female and one with a
  dam flipped to male where the pedigree has them, plus 5 probe fixtures) on the pre-change tree
  (`HEAD`, `git archive`) and the working tree, in separate `Rscript`s: **all identical**, including
  the 29 error results. The report branch was exercised: 70 report-mode calls, 34 with a non-empty
  `femaleSires`, `maleDams` or `sireAndDam`. Not a live click-through of the Shiny app.

### 2026-09-26 · [ad hoc] S787 RED: tests for `correctParentSex(reportErrors = TRUE)` naming NA, blank and unrecognised `recordStatus` parents and checking every animal when the status is `NULL`
- Owner decisions: the Phase 0 pick (the `correctParentSex()` slice), the Pre-RED shape decision
  **"NULL = check every animal"** (over "same plus a `recordStatus = NULL` default" and "NULL = a
  clear error"; an omitted argument stays R's "argument is missing" error), and the Pre-RED to RED
  gate ("Yes, proceed to RED", 2026-09-26). The rest of the shape is the owner's S785 Pre-RED
  decision: `"added"` is the only special status; an NA, blank or unrecognised status is a real
  animal.
- **Probe before the gate** (scratch scripts `probe_s787.R`, `probe_app_s787.R`, not in git; the
  current `reportErrors = TRUE` result against a written reference, a fixture of eight animals:
  `s1` a female sire, `d1` a male dam, `sH` (H) and `dU` (U) exempt, four offspring): **12 of 18
  cases differ**, in three separate ways. An `NA` status on `s1` or `d1` reports `NA` in place of
  the id (`fs=[NA]`, `md=[NA]`; also with a scalar `NA` and an all-`NA` vector); a blank, `"weird"`
  or `"Original"` status skips the animal silently (`fs=NULL`); a `NULL` status reports nothing at
  all (`fs=NULL md=NULL`, where `s1` and `d1` are right). Mixed statuses combine them (`NA` on `s1`
  and `added` on `d1` gives `fs=[NA] md=NULL`). Six controls already agree with the reference:
  all-original, a scalar `"original"`, `"added"` on `s1`, on both, and as a scalar, and an `NA` on
  rows that are not parents (`FALSE & NA` is `FALSE`, so it is harmless). The `reportErrors =
  FALSE` branch never reads the status (its result is identical for `NA`, `"weird"`, `NULL` and
  all-`NA`), and `sireAndDam` is reported whatever the status.
- **App path checked** (a namespace spy on `correctParentSex()` under `qcStudbook(reportErrors =
  TRUE)`, input `recordStatus` = `NA, "weird", "", NA, "original"` plus one unlisted parent): the
  function received only `original` (5) and `added` (2), no `NA`, because `addParents()` rewrites the
  column at `R/qcStudbook.R:229` before the call at `:234`; the app reports `s1` and `d1` correctly.
  So the defect is **script-only**, as the `BACKLOG.md` item said.
- **Observed, not filed or fixed:** (1) in the report branch an omitted `recordStatus` fails with R's
  "argument recordStatus is missing, with no default" (the correction branch never evaluates it, so
  omitting it works there); (2) a status vector whose length does not divide the number of ids is
  recycled with base R's "longer object length is not a multiple" warning; (3) an `NA` **sex** on a
  sire is flagged as a female sire (`!NA %in% c("H","U","M")` is `TRUE`), and **the app reaches
  it**: `convertSexCodes()` maps a missing sex to `"U"` but a blank or unrecognised code to `NA`
  (`R/convertSexCodes.R:39,50`), so a fixture with a sire whose sex is `""` or `"xyz"` reports
  `femaleSires = "s1"` from `qcStudbook(reportErrors = TRUE)` (measured with a namespace spy: the
  function received `NA`); a sex of `NA` or `"M"` does not. Whether a sire with an unreadable sex
  should be reported as a "female sire" is a question for the owner, not part of this slice. All
  three are outside the `recordStatus` slice.
- Tests only, 1 file, no `R/` change: `tests/testthat/test_correctParentSex.R` (+11 `test_that`, +5
  helpers over a fixture `statusPed`): five failing (an `NA` status names the id; an `NA` never
  reaches the reported ids; a blank or unrecognised status is a real animal; a `NULL` status checks
  every animal; a mixed vector skips only the added parents) and six controls (an added parent
  still skipped; a status on non-parent rows changes nothing; an all-original or scalar original
  status reports both; H and U parents never reported under any status; the correction branch and
  `sireAndDam` ignore the status; `qcStudbook(reportErrors = TRUE)` still reports `s1` and `d1` by
  id with junk input statuses).
- **Measured RED** (the file run alone against the unchanged `R/`, `load_all` + `NOT_CRAN`): 17
  tests, **5 failing (43 of 101 expectations)**, 0 errors, 0 skipped, 0 warnings; the 6 existing
  tests and the 6 new controls pass by design. Each failure read from its message: `NA` against
  `"s1"` for the `NA` and mixed cases, `TRUE` against `FALSE` for `anyNA()`, and `NULL` against
  `"s1"` for the blank, unrecognised and `NULL` cases; the per-test counts (8, 5, 24, 2, 4) match
  the hand prediction. lintr 0 on the file. Commit left RED on purpose; GREEN follows behind an
  owner gate.

### 2026-09-26 · [ad hoc] S787 claim: `correctParentSex()` slice 3 (the last) of the sibling `recordStatus` sites *(in progress)*
- Owner-picked at the Phase 0 priorities gate (item 1, `BACKLOG.md` "One more place tests
  `recordStatus == "original"` with no NA guard", READY, Effort S; found S784, narrowed S785 and
  S786). The fix shape is already the owner's S785 Pre-RED decision (`"added"` is the only special
  status), so this session goes straight to strict TDD: Pre-RED reading and probe, RED, GREEN,
  REFACTOR review, each phase gate via `AskUserQuestion`. Orient measured: 0 undocumented on both
  the `CHANGELOG.md` and `HANDOFFS.md` frontiers (`b5b4512c` = HEAD; the S786 receipt is
  `status: complete`, nothing to backfill); 12 unpushed, `origin/master` = `4e2e6e06`; the S786
  ratchet citation (results `7f7a4d08491b`, manifest `aa983075d6a2`, head `e7d87c4a`, 1/1) matched
  `.quality-gates-results.json` before any run; the pushed tip's 4 workflows and the scheduled
  `shinytest2` run all `success`; dashboard 96/100; context budget nothing over a ceiling
  (`CLAUDE.md` 26,360 B in the warn band; `SESSION_NOTES.md` 47,336 B, `CHANGELOG.md` 63,458 B and
  `HANDOFFS.md` 59,015 B before this claim; the trim check fires on none); the untracked residue is
  the owner's (`BACKLOG.log`, two NEWS drafts) plus 5 Quarto renders of tracked `.qmd` sources
  (date- and source-checked). The archive pass is proposed and undecided. Stub + pending receipt
  ride this commit; close-out records the rest. TDD phase PRE-RED at claim; no code touched.

### 2026-09-26 · [ad hoc] S786 records: close-out for the `removeDuplicates()` slice (S785 handoff evaluated 9/10, receipt, Learning 799, next-session items)
- **Deliverable:** the close-out records for S786, whose work is recorded in the entries below: RED
  `f00d8696`, GREEN `32f2b406`, docs `e7d87c4a` (claim `62df6441`, whose "(in progress)" marker this
  entry closes). No push (not asked): 12 local commits after `origin/master` = `4e2e6e06`.
- **Verification that ran after the docs commit** (the docs entry said it would follow): the
  clean-export `R CMD check --as-cran` on `e7d87c4a` -- 0 errors, 0 warnings, 1 NOTE (CRAN incoming
  feasibility: the maintainer line and the development version), `* DONE` confirmed by a fixed-string
  match, status 0. Ratchet **1/1 at `e7d87c4a`**: 3,570,428 B (+1,595 B over S785's 3,568,833 B),
  results `7f7a4d08491b`, manifest `aa983075d6a2` (unchanged).
- **Not fixed, recorded:** `correctParentSex()` remains (READY, S) in the narrowed `BACKLOG.md` item;
  the `reportErrors = FALSE` branch's "mismatched information" stop for rows that differ only in
  `recordStatus` is in the RED entry and is not filed.
- **Records:** S785 handoff evaluated 9/10, self-assessment 8/10, receipt `status: complete`
  (`HANDOFFS.md`), Learning 799 (`PROJECT_LEARNINGS.md:2269`), next-session items in
  `SESSION_NOTES.md`. `CHANGELOG.md` is about 63,500 B against the 65,536 B trim budget (nothing over a
  limit, so no reduction was owed now); at this session's growth all three ledgers cross theirs during
  the next session, so the archive pass is owed first (owner-gated).

### 2026-09-26 · [ad hoc] S786 docs + REFACTOR review: `removeDuplicates()` roxygen and man page, `NEWS.Rmd` Fixed entry, `BACKLOG.md` narrowed to `correctParentSex()`
- Owner decision: the GREEN to REFACTOR gate ("Yes: review + docs, no code refactor",
  2026-09-26).
- **REFACTOR reviewed, no change:** `R/removeDuplicates.R` re-read after GREEN; the code is one
  named mask and one subscript, nothing to simplify. The shared `isAddedRecord()` helper stays
  deferred (three inline copies now: `convertDate()` and `removeDuplicates()` write `!is.na(x) & x
  == "added"`, `removeUnknownAnimals()` writes its complement); the decision is carried in the
  `BACKLOG.md` item for the last slice.
- **Docs:** roxygen `@param reportErrors` and `@return` in `R/removeDuplicates.R` no longer say
  "found among original records": they say that only `"added"` records are left out and that any
  other status, including `NA` or blank, is searched, and that the result has one entry per extra
  occurrence. `man/removeDuplicates.Rd` regenerated with `devtools::document()`; nothing else in
  `man/` changed, and `tools::checkRd` is clean. `NEWS.Rmd` (after the `convertDate()` bullet): one
  plain-language "Fixed" bullet in release-state wording (the "Duplicate IDs found" list no longer
  names stand-in parents when a real duplicate is present; `removeDuplicates()` now checks animals
  whose record of being added is blank or unrecognized). `NEWS.md` is rendered separately and was
  not touched (S785's convention).
- **`BACKLOG.md`:** the item is narrowed to `correctParentSex()` and retitled; the finished
  `removeDuplicates()` record lives in the RED and GREEN entries, and what the remaining slice needs
  (the `recordStatus = NULL` decision, the reach note, the `isAddedRecord()` question, the
  negative-subscript trap) is written into the item. Committed through the header-less blob; the
  owner's 5-line YAML header stays unstaged.
- **Verification after the docs edit:** the two target files 81/81; `test_wordlist_coverage.R`
  passes; `test_pkgdown_reference_config.R` still shows its 1 known failure (the owner's untracked
  `vignettes/suggested_NEWS_entry.Rmd` is not covered by `_pkgdown.yml` articles); lintr 0 on
  `R/removeDuplicates.R`. The clean-export `R CMD check --as-cran` on the committed HEAD runs next
  and is recorded in the close-out entry.

### 2026-09-26 · [ad hoc] S786 GREEN: `removeDuplicates(reportErrors = TRUE)` treats only `"added"` as special and never recycles a mask over the added rows
- Owner decision: the RED to GREEN gate ("Yes, proceed to GREEN", 2026-09-26).
- **Change (one file, the `reportErrors = TRUE` branch only):** `R/removeDuplicates.R:38-47` builds
  `isAdded <- !is.na(ped$recordStatus) & ped$recordStatus == "added"`, takes `ids <-
  ped$id[!isAdded]` and returns `ids[duplicated(ids)]` (else `NULL`). An `NA`, blank or
  unrecognised status is now a real animal, the ids come from the non-added rows alone (no logical
  mask shorter than `ped$id`), and the result keeps one entry per extra occurrence. No roxygen,
  `man/`, `NEWS.Rmd` or `BACKLOG.md` change in this commit (the docs commit follows).
- **Measured:** the two target files 40 tests, **81 of 81 expectations pass** (RED: 6 failing tests,
  12 failed expectations); 12 related files (`name_first_class`, `geneDrop`, `modInput_qcStudbook`,
  `runQcStudbook`, `checkErrorLst`, `summary.nprcgenekeeprErr`, `removeUnknownAnimals`,
  `correctParentSex`, `convertDate`, `getDateErrorsAndConvertDatesInPed`, `getRecordStatusIndex`,
  `addParents`) 99 tests / 249 expectations, 0 failing; **full suite** (`load_all` + `NOT_CRAN`,
  no filter) 353 files, 2,716 tests, 8,387 expectations, **1 failed** (the known
  `test_pkgdown_reference_config.R`, the owner's untracked NEWS draft), 0 errors, 187 skipped, 6
  warnings (not attributed; the two touched files report 0), 4.8 min; +10 tests and +21
  expectations over S785's 2,706 / 8,366, exactly this slice's new tests. lintr 0 on
  `R/removeDuplicates.R` and both test files.
- **Mutants** (8, the function binding replaced in memory in both the namespace and the attached
  package environment, each changing only the report branch; a no-mutation control first): control 0
  failing; **8 of 8 killed**: the pre-change code (6 tests / 12 expectations, the RED count), an
  unguarded NA mask (2 / 5), only-`"original"`-counts (2 / 5), `unique()` on the result (1 / 1),
  the recycled `ped$id[duplicated(ids)]` (3 / 5), `character(0)` instead of `NULL` (3 / 5), blank
  counted as added (1 / 1), added rows counted (2 / 2).
- **Runtime (3E), differential app path:** 87 `qcStudbook()` calls (`reportErrors` both ways over 13
  package datasets, 13 example pedigree files, each of those files with its first 3 rows repeated
  as a real duplicate, `ExamplePedigree.txt`, and the 3 probe fixtures) on the pre-change tree
  (`f00d8696`, extracted with `git archive`) and on the working tree, in separate `Rscript`s:
  **85 identical; exactly 2 differ, and both are the intended change**: a real duplicate `x` plus
  app-added parents reports `x` (was `c("x","s2")`, and `c("x","s2","U0003")` with the dam `NA`).
  19 calls end in an error in both trees for unrelated reasons (`reportErrors = FALSE` stops:
  missing `birth` in five diagram example files, a sire-and-dam animal, the mismatched-duplicate
  fixture). **Limit:** those five example files, and their duplicated variants, return before
  `removeDuplicates()` is reached, so they do not exercise it; the 9 duplicated variants that do
  reach it (no unlisted parents in them) are identical. Not a live click-through of the Shiny app.
- **Disclosure:** the full suite ran on this code before the docs edit that follows (roxygen,
  `man/`, `NEWS.Rmd`, `BACKLOG.md`); the docs commit re-runs the target files, the wordlist and
  pkgdown tests, lintr and the clean-export `R CMD check` on the final tree.

### 2026-09-26 · [ad hoc] S786 RED: tests for `removeDuplicates(reportErrors = TRUE)` keeping NA and unrecognised `recordStatus` animals and never naming an added record
- Owner decisions: the Phase 0 pick (the `removeDuplicates()` slice) and the Pre-RED to RED gate
  ("Yes, proceed to RED", 2026-09-26). The fix shape is the owner's S785 Pre-RED decision:
  `"added"` is the only special status; an NA, blank or unrecognised status is a real animal.
- **Probe before the gate** (scratch scripts `probe_s786.R`, `probe_app_s786.R`, not in git; the
  current `reportErrors = TRUE` result against the reference `ids <- ped$id[<non-added>];
  ids[duplicated(ids)]`, `smallPed` plus a `recordStatus` column, three duplicated rows `A B C`):
  NA on the duplicate rows returns `B C`; NA on the first-occurrence rows `B C`; NA on two innocent
  rows `Q A B C` (names `Q`); all NA a 19-id list; `"weird"` on the duplicates `NULL` (misses all
  three); a blank on one duplicate row `A B`; originals `x, x, z` plus four added rows `x a2`;
  added rows first (`a1, x, z, x`) `z` (wrong id, misses `x`); two added first `a2 x`; added in
  the middle (`x, a1, x, z`) `a1`. Controls that already agree with the reference: no duplicates,
  three duplicate rows, a triple `x, x, x` (`x x`, one entry per extra occurrence), zero rows,
  added-only rows, added rows that share an id. So the line is wrong in three separate ways
  (an NA in a row subscript, an unrecognised status excluded, a recycled logical), a wider set than
  the `BACKLOG.md` item listed.
- **App path reproduced** (`qcStudbook(reportErrors = TRUE)`, fixtures need a `birth` column or the
  call returns at `missingColumns` before it reaches `removeDuplicates()`): three rows (`x, x, z`)
  with four unlisted parents report `duplicateIds = c("x", "s2")`, and the user reads "Duplicate
  IDs found: x, s2"; with the dam left `NA` the app-minted `U0003` is named too; the same shape
  with no duplicate reports nothing. `qcStudbook()` hands `removeDuplicates()` the originals first
  and the added rows last, so on the app path only the recycling false positive is reachable (no
  false negative), and only when a real duplicate is present.
- **Observed, not filed:** the `reportErrors = FALSE` branch stops with "Duplicate IDs with
  mismatched information present" when duplicate rows differ only in `recordStatus` (`NA` against
  `"original"`), because `unique()` compares whole rows. That is arguably correct (different
  information), the branch never reads the status, and the app cannot produce it; left alone.
- Tests only, 2 files, no `R/` change: `tests/testthat/test_removeDuplicates.R` (+8 `test_that`:
  NA on first-occurrence, duplicate and all rows; NA on innocent rows, and NA statuses with no
  duplicate must give `NULL`; blank and unrecognised status; recycled added rows; added rows first,
  two first and in the middle; and three controls: the ordinary results, a factor status, and the
  `reportErrors = FALSE` branch ignoring the status); `tests/testthat/test_qcStudbook.R` (+2: the
  app-path case above must report exactly `"x"`, and a no-duplicate control).
- **Measured RED** (each file run alone against the unchanged `R/`, `load_all` + `NOT_CRAN`):
  `test_removeDuplicates.R` 11 tests, 5 failing (11 of 27 expectations); `test_qcStudbook.R` 29
  tests, 1 failing (1 of 54); **6 failing tests, 12 failed expectations of 81, 0 errors, 0 skipped,
  0 warnings**; the 4 new controls pass by design, and so do the 3 existing `removeDuplicates`
  tests. Each failure read from its message: lengths 2, 2, 19 and 4 against 3 (missed or invented
  ids); `noDups` returns `"E"` where `NULL` is expected; `NULL` against `c("A","B","C")` for both
  the unrecognised and the blank status; lengths 2 against 1 for the recycled case; `"z"`, length
  2 and `"a1"` against `"x"` for the three orderings; the app path returns length 2 against 1.
  lintr 0 on both files. Commit left RED on purpose; GREEN follows behind an owner gate.

### 2026-09-26 · [ad hoc] S786 claim: `removeDuplicates()` NA and recycled-subscript slice (slice 2 of the sibling `recordStatus` sites) *(in progress)*
- Owner-picked at the Phase 0 priorities gate (item 1, `BACKLOG.md` "Two more places test
  `recordStatus == "original"` with no NA guard", READY, Effort S; found S784, narrowed S785). The
  fix shape is already the owner's S785 Pre-RED decision (`"added"` is the only special status), so
  this session goes straight to strict TDD: Pre-RED reading, RED, GREEN, REFACTOR review, each phase
  gate via `AskUserQuestion`. Orient measured: 0 undocumented on both the `CHANGELOG.md` and
  `HANDOFFS.md` frontiers (`6fbf264b` = HEAD; the S785 receipt is `status: complete`, nothing to
  backfill); 7 unpushed, `origin/master` = `4e2e6e06`; the S785 ratchet citation (results
  `e743300ed559`, manifest `aa983075d6a2`, head `e7eaf320`, 1/1) matched
  `.quality-gates-results.json` before any run; all 10 recent `gh run` rows `success`; dashboard
  96/100; context budget nothing over a ceiling (`CLAUDE.md` 26,360 B in the warn band;
  `SESSION_NOTES.md` 33,171 B, `CHANGELOG.md` 50,469 B and `HANDOFFS.md` 49,153 B before this
  claim); the untracked residue is the owner's (`BACKLOG.log`, two NEWS drafts) plus 5 Quarto
  renders of tracked `.qmd` sources (date- and source-checked). Stub + pending receipt ride this
  commit; close-out records the rest. TDD phase PRE-RED at claim; no code touched.

### 2026-09-26 · [ad hoc] S785 records: close-out for the date-conversion slice (S784 handoff evaluated 9/10, receipt, Learning 798, next-session items)
- **Deliverable:** the close-out records for S785, whose work is recorded in the entries below: RED
  `8829239b`, GREEN `d701f1e0`, docs `e7eaf320`, the owner-gated `SESSION_NOTES.md` trim `84f3a6ea`
  (claim `a83be7ca`). No push (not asked): 7 local commits after `origin/master` = `4e2e6e06`.
- **Verification that ran after the docs commit** (the docs entry said it would follow): the
  clean-export `R CMD check --as-cran` on `e7eaf320` -- 0 errors, 0 warnings, 1 NOTE (CRAN incoming
  feasibility: the maintainer line and the development version 2.0.0.9000), `* DONE` confirmed by a
  fixed-string match, status 0. Ratchet **1/1 at `e7eaf320`**: 3,568,833 B (+2,031 B over S784's
  3,566,802 B), results `e743300ed559`, manifest `aa983075d6a2` (unchanged). Differential runtime
  smoke of the app path: 28 `qcStudbook()` calls (9 over package datasets and the reach probe, 19
  over 13 pedigree files under `inst/extdata`, up to 2,791 rows) on the pre-change tree (`8829239b`)
  and on HEAD, in separate `Rscript`s: identical (one error message differs only by the
  per-process `tempdir()` path; identical once masked). Not a live click-through of the Shiny app.
- **Filed, not fixed:** a new `BACKLOG.md` item (HEAD `:73`, DECISION NEEDED, Effort S, low
  priority): `convertDate(reportErrors = TRUE)` numbers an invalid date among the non-added records
  only (probe: an `"added"` row first, a bad date on full row 3, reported as row 2; the pre-change
  code reports 2 too; correct when the added row is last, the order `addParents()` produces, so the
  app is unaffected). The `removeDuplicates()` recycling defect and the `correctParentSex()`
  behaviors are in the narrowed item (HEAD `:34`), recorded in the RED and docs entries.
- **Records:** S784 handoff evaluated 9/10, self-assessment 8/10, receipt `status: complete`
  (`HANDOFFS.md`), Learning 798 (`PROJECT_LEARNINGS.md:2268`), next-session items in
  `SESSION_NOTES.md`. The `BACKLOG.md` change rides this commit through the header-less blob (the
  owner's 5-line YAML header stays unstaged).

### 2026-09-26 · [ad hoc] Ledger trim: `SESSION_NOTES.md` → `docs/archive/SESSION_NOTES-through-2026-09-26.md` (7 record(s), 55,796 B → 22,338 B)

**Written by:** `methodology_trim.py` v1.5.0 — a tool action, not a session's judgment.
Moved the oldest **7** record(s) (2026-09-24 → 2026-09-26) out of [`SESSION_NOTES.md`](SESSION_NOTES.md) into
[`docs/archive/SESSION_NOTES-through-2026-09-26.md`](docs/archive/SESSION_NOTES-through-2026-09-26.md). Losslessness is asserted by L1 (records-zone concatenation), L2 (zone
pinning) and L3 (record partition), and is **re-derivable** — run [`docs/archive/SESSION_NOTES-through-2026-09-26.md.verify.sh`](docs/archive/SESSION_NOTES-through-2026-09-26.md.verify.sh)
rather than trusting a digest printed here. Live file 55,796 B → 22,338 B (−60.0%).

### 2026-09-26 · [ad hoc] S785 docs: `convertDate()` roxygen + `man/`, `NEWS.Rmd` Fixed entry, `BACKLOG.md` narrowed to two sites; REFACTOR reviewed, no change
- **REFACTOR (owner-approved at the GREEN to REFACTOR gate): reviewed, no code change.** The
  added-record mask is one line in two places (`convertDate()` here, `removeUnknownAnimals()` from
  S784) and takes two different forms (a keep-mask there, a set-aside mask here); a shared
  `isAddedRecord()` helper is better cut when `removeDuplicates()` and `correctParentSex()` land, so
  it is recorded in the `BACKLOG.md` item instead of extracted now (it would also touch S784's
  file).
- Docs, 5 files (the per-commit cap): `R/convertDate.R` roxygen (`@param ped` says only `"added"`
  records are left unconverted and that an `NA` or unrecognized status is a real animal whose dates
  are converted and checked; `@return` says added records are not checked and come back after the
  others -- an earlier draft said "unchanged", corrected because the closing `rbind()` can coerce an
  added row's date cell); `man/convertDate.Rd` regenerated with `roxygen2::roxygenise()` (8.0.0),
  which changed only that file (`git status`), `tools::checkRd` silent; `NEWS.Rmd` one plain-language
  "Fixed" bullet under General Fixes after the S784 `removeUnknownAnimals()` one, in release-state
  wording against 2.0.0 (the animals `convertDate()` used to lose, the blank row, the unexplained
  invalid-date stop); `BACKLOG.md` item "Four more places ..." rewritten forward-carrying as "Two more
  places ..." (`removeDuplicates()`, `correctParentSex()`), shape decided, READY, Effort S per slice,
  with the S785 probes, the recycling defect and its app-path reach (`qcStudbook(reportErrors =
  TRUE)` reported `x, s2`), the `NULL`-status observation, the deferred `isAddedRecord()` idea and the
  negative-subscript trap; staged through the header-less blob so the owner's 5-line YAML header
  stays unstaged.
- **Re-verified on the final tree** (after the docs edit, so the S784 disclosure about a check that
  predated its docs does not recur): the three target files 3 + 14 + 5 tests, 54 expectations, 0
  failed; the related files 0 failed except the known `test_pkgdown_reference_config.R` (the owner's
  untracked `suggested_NEWS_entry.Rmd`); the wordlist test passes with the new roxygen words; lintr 0
  on both R files and the three test files. The clean-export `R CMD check --as-cran` runs on HEAD
  after this commit; its result is recorded in the S785 records entry.
- **Checklists:** lint done; NEWS done; `_pkgdown.yml` (no new export), citation, tutorial and
  `a2interactive` (no new function or parameter) N/A; no GitHub issue exists for this defect
  (BACKLOG-only, found S784); the BACKLOG item is narrowed, not complete, so it stays.

### 2026-09-26 · [ad hoc] S785 GREEN: `convertDate()` and `getRecordStatusIndex()` treat only `"added"` as special
- Two R files, minimum change, no new functionality (owner-approved at the RED to GREEN gate):
  `R/getRecordStatusIndex.R:15` is now `which(ped$recordStatus == status)` (drops NA, integer);
  `R/convertDate.R:96-99` builds `isAdded <- !is.na(ped$recordStatus) & ped$recordStatus ==
  "added"` and splits with `ped[isAdded, ]` / `ped[!isAdded, ]`, a logical mask, never a negative
  subscript from a possibly-empty index; the `nrow(ped) == 0L` early return and the closing
  `rbind()` are untouched. An NA, blank or unrecognised status is now a real animal that is kept
  in place with its date converted and validated; the pipeline function
  (`getDateErrorsAndConvertDatesInPed()`) needed no edit, its fix comes through the helper.
- **Measured GREEN:** the three target files 3 + 14 + 5 tests, 7 + 26 + 21 = 54 expectations, 0
  failed, 0 errors (RED was 8 failing tests / 20 failed expectations). Related files (qcStudbook,
  modInput_qcStudbook, removeUnknownAnimals, removeDuplicates, correctParentSex, wordlist_coverage,
  setExit, checkParentAge) 0 failed; `test_pkgdown_reference_config.R` 1 failed, read from its
  message: "1 article(s) not covered ... suggested_NEWS_entry", the owner's untracked
  `vignettes/suggested_NEWS_entry.Rmd` draft, not this change. **Full suite** (`load_all` +
  `NOT_CRAN`, no file filter): 353 files, 2,706 tests, 8,366 expectations, **1 failed** (that same
  one), 0 errors, 187 skipped; against S784's 352 / 2,694 / 8,326 the delta is +1 file, +12 tests,
  +40 expectations, exactly this slice's additions. lintr 0 on both R files and all three test
  files.
- **Mutants** (each edits one fix, runs the three target files, restores byte-identical): a control
  with no mutation 0 / 0 / 0 failing tests; dropping the `is.na()` guard killed by 3 `convertDate`
  and 1 pipeline test; treating NA as added, killed by 3 + 1; keeping only `"original"` (the old
  behavior), killed by 4 + 2; the old `seq_along` subscript in the helper, killed by 2 index and 1
  pipeline test; an inverted comparison in the helper, killed by 2 + 3. The helper mutants leave
  the `convertDate` file at 0 and the `convertDate` mutants leave the index file at 0. All 5
  killed. Not yet run: the clean-export `R CMD check` (it follows the docs edit, so it sees the
  final tree).

### 2026-09-26 · [ad hoc] S785 RED: tests for the date-conversion path keeping NA and unrecognised `recordStatus` animals
- Owner decisions at the Pre-RED gate (2026-09-26): **fix shape (1)** -- `"added"` is the only
  special status, so an NA, blank or unrecognised status is a real animal, processed like an
  original (the `removeUnknownAnimals()` contract from S784); **slice = the date-conversion path**:
  `convertDate()` + `getRecordStatusIndex()`, plus a new test file for
  `getDateErrorsAndConvertDatesInPed()` (it had no direct test). `removeDuplicates()` and
  `correctParentSex()` stay in `BACKLOG.md` as their own items.
- **Probe before the gate** (scratch scripts, not in git; `smallPed` plus a `recordStatus` column,
  one value changed at row 5): `convertDate()` gives 18 rows from 17 with 2 all-NA rows and loses
  the real animal for an NA status, and gives 16 rows from 17 for `"weird"` (the animal is silently
  dropped); `getRecordStatusIndex(ped, "added")` returns `NA_integer_`; the pipeline function stops
  with "only 0's may be mixed with negative subscripts" when the pedigree also has an invalid date
  (its all-original control returns `"7"`); `removeDuplicates(reportErrors = TRUE)` with two NA
  statuses returns `"F" "A" "B" "C"` (control `"A" "B" "C"`); `correctParentSex(reportErrors =
  TRUE)` with an NA status on a female sire reports `NA` instead of `"s1"`, with `"weird"` skips
  `"s1"` silently, and with `recordStatus = NULL` reports nothing.
- **New finding, out of scope, to be filed at close-out:** `removeDuplicates(reportErrors = TRUE)`
  (`R/removeDuplicates.R:39-40`) subscripts the full-length `ped$id` with `duplicated()` of the
  shorter original-only vector, and R recycles that logical. Originals `x, x, z` plus four added
  rows return `"x" "a2"` (an added placeholder named as a duplicate), with no NA involved. It IS
  reachable from the app path: `qcStudbook(reportErrors = TRUE)` on a 3-row pedigree with one
  duplicate id and unlisted parents reported `x, s2` (`s2` is a placeholder).
- Tests only, 3 files, no `R/` change: `tests/testthat/test_getRecordStatusIndex.R` (+2
  `test_that`: NA and unrecognised never match, all-NA gives `integer(0)`);
  `tests/testthat/test_convertDate.R` (+5: NA kept in place with its date converted and no phantom
  row, unrecognised kept, all-NA kept, `reportErrors = TRUE` validates an NA or unrecognised
  animal's date, and a control that a bad date on an `"added"` row is still ignored);
  `tests/testthat/test_getDateErrorsAndConvertDatesInPed.R` (NEW, 5: an all-original control, NA
  and unrecognised statuses alongside invalid dates, added rows retained, and every original
  invalid leaves the pedigree unconverted). The function is returned-not-signalled through a
  `tryCatch` helper so a defect is one clean failed expectation.
- **Measured RED** (each file run alone against the unchanged `R/`): `getRecordStatusIndex` 3
  tests, 2 failing (4 of 7 expectations); `convertDate` 14 tests, 4 failing (11 of 26); pipeline
  file 5 tests, 2 failing (5 of 21); **8 failing tests, 20 failed expectations of 54, 0 errors, 0
  skipped**; the 4 controls pass today by design. Each failure read from its message: index
  lengths 3 vs 2 and 3 vs 0 (the NA leaks in); a phantom NA id and 7 rows from 6; `"weird"` 5 rows
  from 6; all-NA 10 rows from 5; `reportErrors` returns `NULL` where `"3"` / `"4"` is expected;
  the pipeline stops with the exact "only 0's may be mixed with negative subscripts"; `"weird"` 7
  rows from 8. lintr 0 on the three files. Commit left RED on purpose; GREEN follows behind an
  owner gate.

### 2026-09-26 · [ad hoc] S785 claim: the sibling `recordStatus` NA sites (`convertDate`, `removeDuplicates`, `getDateErrorsAndConvertDatesInPed`, `correctParentSex`) *(in progress)*
- Owner-picked at the Phase 0 priorities gate (item 1, `BACKLOG.md` "Four more places test
  `recordStatus == "original"` or `"added"` with no NA guard", DECISION NEEDED, Effort S-M; found
  S784). The owner picks the fix shape and the slice scope first (three shapes are written out in the
  item), then strict TDD, one small slice per file. Orient measured: 0 undocumented on the
  `CHANGELOG.md` frontier (`483b26a6` = HEAD); the `HANDOFFS.md` frontier is `4e2e6e06` with one
  commit after it (`483b26a6`, S784's own push record; the S784 receipt is `status: complete`, so
  nothing to backfill); 1 unpushed, `origin/master` = `4e2e6e06` (the S784 notes' "11 unpushed at
  `38baa151`" is superseded by the owner-directed push recorded below); the S784 ratchet citation
  (results `ecf49efe323b`, manifest `aa983075d6a2`, head `9c078193`, 1/1) matched
  `.quality-gates-results.json` before any run; all 10 recent `gh run` rows `success`; dashboard
  96/100; context budget nothing over a ceiling (`CLAUDE.md` 26,360 B in the warn band,
  `SESSION_NOTES.md` 54,052 B, a trim owed at or before the next close-out). Stub + pending receipt
  ride this commit; close-out records the rest. TDD phase PRE-RED at claim; no code touched.

### 2026-09-26 · [ad hoc] S784 push: `origin/master` `38baa151..4e2e6e06` (11 commits, owner-directed after close-out)
- **Action (non-commit):** the owner asked "push the local commits" after the S784 close-out. Pre-push
  check: fetched; branch `master`; 11 ahead, 0 behind (a fast-forward); the only uncommitted change was
  the owner's 5-line `BACKLOG.md` header. Pushed with a plain `git push origin master`; `origin/master`
  then equalled local `HEAD` (`4e2e6e06`). The 11 commits: S783 RED `bebb26f5`, GREEN `c0ef7bc6`, docs
  `4125c436`, records `36300a61`; S784 claim `4aea6297`, RED `171c848e`, GREEN `f1a7d31a`, docs
  `9c078193`, trims `a118c70d` and `7cbd32bd`, records `4e2e6e06`.
- **CI (awaited, because `R/` and tests changed):** all four push workflows `completed success` on
  `4e2e6e06` -- lint 4 m 46 s, pkgdown 6 m 19 s, test-coverage 11 m 35 s, R-CMD-check 22 m 48 s
  (runs `36272617239`, `36272617200`, `36272617224`, `36272617228`; confirmed against the plain
  unfiltered `gh run list`, since a `--commit`-filtered listing returned nothing).
- **Disclosure:** my first wait script failed with an HTTP 404 (zsh did not word-split an unquoted
  run-id list, a trap already in the standing set); it was a script bug, not a CI failure, and the
  relaunched waits used one `gh` call per run. This entry rides a LOCAL commit, so `origin/master`
  is one commit behind local until the next push (S783's precedent).

### 2026-09-26 · [ad hoc] S784 records: close-out for the NA phantom-row slice (S783 handoff evaluated 9/10, receipt, Learning 797, next-session items)
- **Deliverable:** the close-out records for S784, whose work is recorded in the entries below and
  in the two tool-written trim entries: RED `171c848e`, GREEN `f1a7d31a`, docs `9c078193`, ledger
  trims `HANDOFFS.md` `a118c70d` and `CHANGELOG.md` `7cbd32bd` (claim `4aea6297`). Adds the S783
  handoff evaluation (9/10) and the S784 self-assessment (8/10) to `SESSION_NOTES.md`; completes the
  S784 receipt in `HANDOFFS.md` (`status: pending` to `complete`); appends Learning 797 to
  `PROJECT_LEARNINGS.md`; files one `BACKLOG.md` item (the trimmer's verify false positive) through
  the header-less blob, so the owner's 5-line YAML header stays unstaged.
- **Ratchet:** 1/1 pass at `9c078193`, 3,566,802 B (+519 B against S783's 3,566,283 B, noise);
  results `ecf49efe323b`, manifest `aa983075d6a2` unchanged. The S783 citation (results
  `bc39c545844e`) matched `.quality-gates-results.json` BEFORE the run.
- **Ledger reduction (this session's decay term):** the owner-gated archive pass ran because the
  `CHANGELOG.md` trigger fired at 66,341 B: `CHANGELOG.md` 68,367 B to 33,122 B (25 of 42 records)
  and `HANDOFFS.md` 61,696 B to 31,685 B (4 of 7 receipts). `SESSION_NOTES.md` was 44,630 B at the
  start of close-out, under its ceiling, and nothing was removed from it.
- **Disclosures:** (1) my Phase 0 priorities list omitted tagged `BACKLOG.md` items: the
  hard-wrapped file splits tags across lines and my single-line pattern matched 11 of 19 tagged
  items, dropping the contributor tutorial, the papers item, the harem-sire hole and the LabKey
  items; found at close-out, so the owner picked from an incomplete list (all four options shown
  were valid; the omitted ones are named in the handoff's next steps); (2) the archive pass
  diverged from the gate text (the `HANDOFFS.md` shard's verify script FAILs one L2 check on a
  false positive), approved as "trim anyway, record + file the defect" and recorded in the
  tool-written `HANDOFFS.md` trim entry; (3) `R CMD check` and the full suite ran on the GREEN
  code, BEFORE the comment-only roxygen / `man/` / NEWS edit (S783's same limit); (4) nothing was
  pushed: the owner did not ask, so the local commits after `origin/master` stay local.
- **Checklists:** lint done; NEWS done (the docs entry); `_pkgdown.yml`, citation, tutorial and
  `a2interactive` (no new parameter) N/A; no GitHub issue exists for this defect; the BACKLOG
  completed-item removal was done in the docs commit.

### 2026-09-26 · [ad hoc] Ledger trim: `CHANGELOG.md` → `docs/archive/CHANGELOG-through-2026-09-26.md` (25 record(s), 68,367 B → 33,122 B)

**Written by:** `methodology_trim.py` v1.5.0 — a tool action, not a session's judgment.
Moved the oldest **25** record(s) (2026-09-24 → 2026-09-26) out of [`CHANGELOG.md`](CHANGELOG.md) into
[`docs/archive/CHANGELOG-through-2026-09-26.md`](docs/archive/CHANGELOG-through-2026-09-26.md). Losslessness is asserted by L1 (records-zone concatenation), L2 (zone
pinning) and L3 (record partition), and is **re-derivable** — run [`docs/archive/CHANGELOG-through-2026-09-26.md.verify.sh`](docs/archive/CHANGELOG-through-2026-09-26.md.verify.sh)
rather than trusting a digest printed here. Live file 68,367 B → 33,122 B (−51.6%).

### 2026-09-26 · [ad hoc] Ledger trim: `HANDOFFS.md` → `docs/archive/HANDOFFS-through-2026-09-26.md` (4 record(s), 61,696 B → 31,685 B)

**Written by:** `methodology_trim.py` v1.5.0 — a tool action, not a session's judgment.
Moved the oldest **4** record(s) (2026-09-24 → 2026-09-26) out of [`HANDOFFS.md`](HANDOFFS.md) into
[`docs/archive/HANDOFFS-through-2026-09-26.md`](docs/archive/HANDOFFS-through-2026-09-26.md). Losslessness is asserted by L1 (records-zone concatenation), L2 (zone
pinning) and L3 (record partition), and is **re-derivable** — run [`docs/archive/HANDOFFS-through-2026-09-26.md.verify.sh`](docs/archive/HANDOFFS-through-2026-09-26.md.verify.sh)
rather than trusting a digest printed here. Live file 61,696 B → 31,685 B (−48.6%).

**Divergence from the S784 owner gate (recorded here per Learning 777(b); owner-approved "trim anyway,
record + file the defect"):** the gate promised a passing `.verify.sh`. The generated script prints
`FAIL: L2 FRONT MATTER leaked 1 line(s) into the shard, first: 'python3 methodology_trim.py --file
HANDOFFS.md --check'`, while the write-time L1, L2 and L3 all reported OK and the script's own L1
and L3 checks hold. Cause (read from the script's L2 block): its leak test is `ln in
"".join(sr)`, a SUBSTRING test of each front-matter line (over 24 chars) against the whole archived
records text, and the archived S779 receipt's `next_steps:` quotes `python3 methodology_trim.py
--file HANDOFFS.md --check --budget-bytes 65536`, which contains that front-matter line. It is a
false positive: the front matter did not move into the shard, and the same script's "lost line"
check already uses exact-line-set membership (its BL-28 fix). Reproduced by a write, a rollback and
a second write, and by a separate Python reproduction (1 hit, S779). It recurs on any later
`HANDOFFS.md` trim, since S779 is always in the archived tail. No CI job, test or tool runs the
`.verify.sh` scripts (only the dashboard recognizes the suffix). Filed as a `BACKLOG.md` item.

### 2026-09-26 · [ad hoc] S784 docs: `removeUnknownAnimals()` roxygen + `man/`, `NEWS.Rmd`, `BACKLOG.md`; REFACTOR reviewed, no change
- **REFACTOR (owner-approved gate, 2026-09-26):** re-read `R/removeUnknownAnimals.R` (a one-line body
  plus a two-line comment) and the six new test blocks; no duplication or unclear structure worth
  changing, so no code or test edit. The new "no added animals returns the pedigree unchanged"
  guard overlaps the older nrow-only "removes nothing" test on purpose (it asserts whole-pedigree
  identity, and M2 is killed by both).
- **Docs:** `@return` in `R/removeUnknownAnimals.R` now says only `"added"` rows are removed and
  every other animal is kept, including one with a missing (`NA`) or any other `recordStatus`;
  `devtools::document()` changed only `man/removeUnknownAnimals.Rd` (`git status` checked, `tools::checkRd`
  clean). `NEWS.Rmd`: the existing `removeUnknownAnimals()` "Fixed" bullet (S782's) is REWRITTEN to
  the finished state against 2.0.0, not given a second bullet -- it now removes only the added
  animals, and used to return an empty pedigree when no record of added animals existed and to lose
  animals whose record was blank or unrecognized, sometimes leaving a blank row (the owner's
  release-state rule; plain-language criterion applied). `NEWS.md` is not re-rendered (it is
  rendered at release). The wordlist test caught my "unrecognised" (British) in the NEWS text
  after the first draft; changed to "unrecognized" and the test re-run green.
- **`BACKLOG.md`:** the NA phantom-row item is REMOVED (the completion record is the S784 GREEN entry
  above, enriched with the verification detail); one new DECISION NEEDED item (Effort S-M) files
  the four sibling sites the probe found (`convertDate` 18 rows from 17 with two all-NA rows;
  `removeDuplicates(reportErrors = TRUE)` names an innocent id; `getRecordStatusIndex(.., "added")`
  returns `NA_integer_` and its only remaining caller would stop on a mixed-sign subscript;
  `correctParentSex` the same pattern, read not probed), the reach (unreachable through
  `qcStudbook()`: `addParents()` overwrites the column), three shapes for the owner and the
  empty-negative-subscript trap. The owner's uncommitted 5-line YAML header stays out of the
  commit (header-less blob; `git diff HEAD -- BACKLOG.md` is checked after).
- **Verification after the docs edit:** `test_removeUnknownAnimals.R` 11 tests / 25 expectations 0
  failed; `test_wordlist_coverage.R` 0 failed (after the fix above); `test_pkgdown_reference_config.R`
  1 failed (the owner's untracked NEWS draft, expected); `test_getRecordStatusIndex.R` 0 failed;
  lintr 0 on the R file. **Disclosure:** the full suite and `R CMD check` ran on the GREEN code,
  BEFORE this comment-only roxygen / `man/` / NEWS edit; after it I re-ran only the four test
  files above, lintr and `tools::checkRd` (the same limit S783 disclosed).
- **Checklists:** lint done; NEWS done (rewrite of the existing entry); `_pkgdown.yml` (no new
  export), citation, tutorial, and `a2interactive` (no new parameter; a behavior fix) N/A; no GitHub
  issue exists for this defect, so none closed.

### 2026-09-26 · [ad hoc] S784 GREEN: `removeUnknownAnimals()` removes only "added" rows and keeps NA and unrecognised statuses
- **Change:** `R/removeUnknownAnimals.R:27-29` -- `ped[getRecordStatusIndex(ped, status =
  "original"), ]` becomes `ped[is.na(ped$recordStatus) | ped$recordStatus != "added", ]`, with a
  two-line comment saying why the `is.na()` guard is there. No other `R/` file; `getRecordStatusIndex()`
  is untouched (it keeps its one remaining caller, `getDateErrorsAndConvertDatesInPed()`, and its
  own test). Roxygen, `man/` and `NEWS.Rmd` are deliberately NOT in this commit (the docs commit
  follows behind the next gate).
- **Measured:** `test_removeUnknownAnimals.R` 11 tests / 25 expectations, 0 failed (RED was 5 failing
  tests / 11 failed expectations); eight related files (`addParents`, `convertDate`,
  `correctParentSex`, `getRecordStatusIndex`, `modInput_qcStudbook`, `qcStudbook`,
  `removeDuplicates`, `runQcStudbook`) 0 failed, 0 errors; full suite (`load_all` + `NOT_CRAN`, no
  file filter) 352 files, 2,694 tests, 8,326 expectations, **1 failed**, 0 errors, 187 skipped, 6
  warnings -- +6 tests and +12 expectations against S783's 2,688 / 8,314, exactly the six new
  blocks; the 1 failure is `test_pkgdown_reference_config.R` "articles: contents covers every
  real article", caused by the owner's untracked `suggested_NEWS_entry` draft (as in S782/S783);
  lintr 0 on `R/removeUnknownAnimals.R`; `R CMD check --as-cran --no-manual` on a `git archive
  $(git write-tree)` export (the change staged, so the tree is exactly this commit's): 0 errors, 0
  warnings, 1 NOTE (the dev-version one, "Version contains large components (2.0.0.9000)"), with
  `* DONE`, `Status: 1 NOTE`, `status == 0`, no timeout and the tests step present confirmed in the
  saved result (Learning 795), about 5 minutes.
- **Mutation checks (throwaway mocks of the exported binding, with controls):** control A (the
  shipped body via the mock) 0 of 11 failing; control B (`ped[0L, ]`) 9 of 11 failing, so the mock
  takes effect. M1 a bare `!= "added"` with no `is.na()` guard: killed by 4 tests (the NA, all-NA,
  mixed and factor tests). M2 a negative index from `getRecordStatusIndex(ped, "added")` (the
  `-integer(0)` trap): killed by 7 tests, including the new no-"added" guard and the pre-existing
  "removes nothing" test. M3 the old keep-only-`original` behavior through `which()`: killed by 5
  tests (the NA, all-NA, unrecognised, mixed and factor tests).
- **Runtime (3E):** n/a -- no app caller (`removeUnknownAnimals()` has no caller in `R/`; from a grep
  of `R/`, not an app test).

### 2026-09-26 · [ad hoc] S784 RED: tests for `removeUnknownAnimals()` keeping NA and unrecognised statuses
- Owner decisions at the Pre-RED gate (2026-09-26): fix **shape (2)** -- `removeUnknownAnimals()`
  removes exactly the rows marked `"added"` and keeps every other row (NA, blank, unrecognised),
  matching its title and the S782 F1 contract; `getRecordStatusIndex()` is NOT touched. A `"weird"`
  status is now kept (17 -> 17; it was dropped, 17 -> 16), a deliberate small behavior change to
  disclose in `NEWS.Rmd`. **Probe before the gate** (scratch script, hand-built `smallPed` with
  `recordStatus` NA at row 5): the same `== status` pattern misbehaves at three more inline sites,
  all OUT of scope and to be filed in `BACKLOG.md` at close-out -- `convertDate()`
  (`R/convertDate.R:95-96`) returns 18 rows from 17 with 2 all-NA rows; `removeDuplicates(reportErrors
  = TRUE)` (`R/removeDuplicates.R:39-40`) names an innocent id (`"F"`) as a duplicate;
  `getDateErrorsAndConvertDatesInPed()` (`:39-42`) would stop on `sb[-c(2, NA), ]` ("only 0's may be
  mixed with negative subscripts"; `correctParentSex()` `:90,92` is the same pattern, read not
  probed). Reach, read from `R/qcStudbook.R:229` and `R/addParents.R:43-44`: `qcStudbook()` calls
  `addParents()`, which overwrites `recordStatus` unconditionally, so neither the app nor the
  `qcStudbook()` path can carry an NA status; only a script that hand-builds the column and calls
  these exported functions directly can. `removeUnknownAnimals()` has no caller in `R/`.
  Tests only (`tests/testthat/test_removeUnknownAnimals.R`, +6 `test_that` blocks; the existing 5
  untouched; no `R/` change): a status column with no `"added"` rows returns the pedigree
  identical (guard for the `-integer(0)` trap), one NA status kept with no phantom row, all-NA
  statuses kept, an unrecognised status kept, the mixed case (rows 1:3 `"added"` removed, NA and
  `"weird"` kept, order preserved), and a factor `recordStatus` with an NA. **Measured RED:** the
  file reports 11 tests: 5 failing (11 failed expectations of 25) and 6 passing (14 expectations;
  the 5 existing plus the guard), 0 errors, 0 skipped. Each failure is for the right reason,
  read from its message: a phantom NA id (`anyNA(result$id)`), animal 5 missing, `"weird"` dropped
  (16 rows vs 17), the mixed case 13 rows vs 14. A probe first confirmed `identical()` holds for a
  row-subset that keeps every row (row names survive), so the whole-pedigree assertions cannot
  fail on row-name representation. The guard passes today by design (proven only by passing).
  lintr 0 on the file. Commit left RED on purpose; GREEN follows behind an owner gate.

### 2026-09-26 · [ad hoc] S784 claim: the NA phantom-row defect in `removeUnknownAnimals()` *(in progress)*
- Owner-picked at the Phase 0 priorities gate (item 1: a `recordStatus` value of `NA` gives
  `removeUnknownAnimals()` an all-NA phantom row; DECISION NEEDED, Effort S; found S782). The owner
  picks the fix shape first, then one small strict-TDD slice. Orient measured: 0 undocumented on
  both the `CHANGELOG.md` and `HANDOFFS.md` frontiers (`36300a61` = HEAD); the S783 receipt is
  `status: complete`; 4 unpushed, `origin/master` = `38baa151`; the S783 ratchet citation (results
  `bc39c545844e`, manifest `aa983075d6a2`, head `4125c436`, 1/1) matched
  `.quality-gates-results.json` before any run; all 10 recent `gh run` rows `success`; dashboard
  96/100; context budget nothing over a ceiling. Stub + pending receipt ride this commit; close-out
  records the rest. TDD phase PRE-RED at claim; no code touched.

### 2026-09-26 · [ad hoc] S783 records: close-out for PED_GV F4 (S782 handoff evaluated 9/10, receipt, Learning 796, next-session items)
- **Deliverable:** the close-out records for S783, whose work is recorded in the entries below:
  push `b5166c8b..38baa151`, RED `bebb26f5`, GREEN `c0ef7bc6`, docs `4125c436` (claim `38baa151`).
  Adds the S782 handoff evaluation (9/10: every Orient measurement and `BACKLOG.md` pin held; the
  inherited F4 plan contradicted itself; one wrong pin), the S783 record and self-assessment
  (8/10) in `SESSION_NOTES.md`, the completed `HANDOFFS.md` receipt, and Learning 796
  (`PROJECT_LEARNINGS.md:2266`: a cycle guard on a repeat-keeping recursion tracks the route, not
  a visited set; a mocked-binding mutation proves a guard; two zsh traps). **Ratchet (non-commit
  measurement):** `quality_ratchet.py --run` at `4125c436` -- 1/1 pass, tarball 3,566,283 B (+896 B
  vs S782 = noise), results `bc39c545844e`, manifest `aa983075d6a2`; the S782 citation (results
  `76631f2eafcc`, head `00610aed`) matched the results file BEFORE the run. **Reduction:** nothing
  was removed from a mandated-read file this session (no trim was due; the S782 handoff's estimate
  was "within about two sessions"). **Not done, on purpose:** no second push (the four commits
  after `38baa151` are local; the owner did not ask), no GitHub issue closed (F4 has none), the
  owner-side working-tree residue untouched.

### 2026-09-26 · [ad hoc] S783 docs: PED_GV F4 -- roxygen + `man/getAncestors.Rd`, `NEWS.Rmd` "Fixed" entry, `BACKLOG.md`; REFACTOR reviewed, no change
- **REFACTOR (owner chose the review pass over my recommendation to skip it):** re-read
  `R/getAncestors.R` and the six new tests; nothing worth changing (the worker is the original
  recursion plus one guard; a helper for the four repeated `contains a cycle` + path assertion
  pairs would hide what each test checks). **No REFACTOR commit.** One check added: a throwaway
  mutation (a mocked binding whose message reports the whole route, `R/` untouched) fails exactly
  the intended test, "names only the cycle when the start id is outside it" (1 of 12), so the
  `expect_false(grepl("\\bZ\\b", msg))` guard the RED entry called "proven only by passing" can
  fail. **Docs:** `getAncestors()` roxygen gains a paragraph (diamond repeats; stops with an
  error naming the ids on a cycle); `devtools::document()` changed only `man/getAncestors.Rd`
  (+5 lines; `tools::checkRd` 0 issues); `NEWS.Rmd` "General Fixes" gets one plain-language entry
  (a judgment call beyond the checklist, which mandates one only for new exports or Shiny
  features; the S782 F1 precedent; easy to drop); `BACKLOG.md`: F4 out of the PED_GV item (F2
  and F3 remain, DECISION NEEDED), and the absent-id and depth-limit findings filed as their own
  DECISION NEEDED item. The owner's uncommitted YAML header on `BACKLOG.md` is left out of the
  commit (header-less blob). **Not re-run for this comment-only change:** the full suite and
  `R CMD check` (both measured on the GREEN code, which is unchanged); re-run this session:
  `test_getAncestors.R` 12/12, the three related files, lintr 0.

### 2026-09-26 · [ad hoc] S783 GREEN: PED_GV F4 fixed -- `getAncestors()` stops with a message naming a pedigree cycle
- `R/getAncestors.R` only. The exported `getAncestors(id, ptree)` keeps its signature and is now a
  thin wrapper over a new unexported `.getAncestorsOnPath(id, ptree, path)` (`@noRd`) that carries
  the ids on the CURRENT route (per branch, not a global visited set); an id already on its route
  stops with `call. = FALSE`: "getAncestors: the pedigree contains a cycle (an animal is its own
  ancestor): X -> Y -> X. Each id is a sire or dam of the one before it; correct the sire and dam
  entries for these ids." (only the cycle's ids, not the route leading to it). Otherwise the
  recursion is unchanged: sire lineage then dam lineage, diamond repeats kept. **Measured:**
  `test_getAncestors.R` 12 tests / 19 expectations, 0 failing (RED was 6 failing tests); the four
  files that touch `getAncestors`/`findLoops`/`countLoops`/`createPedTree` 59 expectations, 0
  failed; full suite (`load_all` + `NOT_CRAN`, no filter) 352 files, 2,688 tests (S782's 2,682 + 6),
  8,314 expectations, **1 failed**, 0 errors, 187 skipped, 6 warnings -- the 1 failure is
  `test_pkgdown_reference_config.R` "articles: contents covers every real article", caused by the
  owner's untracked `suggested_NEWS_entry` draft (same as S782; not touched); lintr 0 on both
  files; `R CMD check --as-cran --no-manual` on a `git archive $(git write-tree)` export of the
  index: 0 errors, 0 warnings, 1 NOTE (dev-version "Version contains large components", the same
  as S782), `* DONE`, `Status:` and `res$status == 0` all confirmed, 5.2 min. **Mutation check
  (throwaway, via a mocked binding, `R/` untouched):** swapping the route for a global visited set
  makes the diamond guards ("with repeats", "full ancestor set") FAIL, so the repeats guard is
  proven to fail on the wrong design; the real implementation passes all 12. **Incidental
  measurement:** the longest acyclic chain that resolves rose from 997 to 2,218 generations
  (binary search; the old function reproduced at 997 by two methods); cause not investigated,
  and not a behavior anyone asked for. **One wording change from the Pre-RED gate:** "sire/dam" in
  the message became "sire and dam" because `nonportable_path_linter` reads the slash in a string
  as a file path (a `# nolint` was the alternative). CI on the earlier push (`b5166c8b..38baa151`,
  which carried the S782 code) was `success` on all four push workflows. Commit left GREEN on
  purpose; REFACTOR (if any) follows behind an owner gate.

### 2026-09-26 · [ad hoc] S783 RED: PED_GV F4 -- tests for a `getAncestors()` cycle guard
- Owner decisions at the Pre-RED gate (2026-09-26): detection is **path-based** through an
  unexported recursive helper (the exported `getAncestors(id, ptree)` signature is unchanged; a
  global visited set would drop the documented diamond repeats); the error **names the cycle**
  (`X -> Y -> X`, only the cycle's ids, plain `stop()`, no condition class); the neighbouring
  defects (an id or parent absent from the tree fails with "argument is of length zero"; an
  acyclic chain about 1,000 generations deep overflows R's expression limit) are OUT of scope,
  to be filed in `BACKLOG.md` at close-out. Tests only (`tests/testthat/test_getAncestors.R`, +6
  `test_that` blocks; the existing 6 untouched; no `R/` change): sire-side 2-cycle, self-parent,
  dam-side 2-cycle, 3-cycle in order, a start id outside the cycle (names only the cycle), and
  `findLoops()`/`countLoops()` surfacing the same message. **Measured RED:** the file reports 6
  failing tests (11 failed expectations) and 6 passing (7 expectations), 0 errors; every failure
  is "Expected `msg` to match ..." because the message is still R's "evaluation nested too
  deeply: infinite recursion". One expectation (`expect_false(grepl("\\bZ\\b", msg))`) passes
  today vacuously -- the test fails on its first expectation -- so it is a guard proven only by
  passing. The existing diamond-repeats test (`test_getAncestors.R:28`) is the no-false-positive
  guard and passes. lintr 0 on the file. Commit left RED on purpose; GREEN follows behind an
  owner gate.

### 2026-09-26 · [ad hoc] S783 push: 18 local commits to `origin/master` (`b5166c8b..38baa151`)
- Non-commit action, owner-directed at the Phase 0 priorities gate ("push commits; then F4"):
  `git push origin master` sent the 17 commits that were local at Orient (S775-S782 records, the
  PED_GV triage, and the F1 RED/GREEN/REFACTOR/docs commits) plus the S783 claim; the remote head
  matched local (`38baa151`) afterwards. CI on it: lint, pkgdown, test-coverage and R-CMD-check
  all `completed success` (R-CMD-check 23 m 23 s) -- awaited, because the range carried real
  `R/` and test changes (S782 F1), not only build-ignored files. The S783 commits after the claim
  (RED, GREEN, docs, records) are NOT pushed; the owner did not ask for a second push.

### 2026-09-26 · [ad hoc] S783 claim: PED_GV F4 -- `getAncestors()` cycle guard *(in progress)*
- Owner-picked at the Phase 0 priorities gate, with one owner-directed pre-step: "push commits; then
  F4". The push of the local commits (17 at Orient, plus this claim) is a non-commit action and gets
  its own close-out entry. Orient measured: 0 undocumented on both the `CHANGELOG.md` and
  `HANDOFFS.md` frontiers (`636e1c45` = HEAD); the S782 receipt is `status: complete`; 17
  unpushed, `origin/master` = `b5166c8b`; the S782 ratchet citation (results `76631f2eafcc`,
  manifest `aa983075d6a2`, head `00610aed`, 1/1) matched `.quality-gates-results.json`
  before any run; all 10 recent `gh run` rows `success`; dashboard 96/100; context budget nothing
  over a ceiling. Stub + pending receipt ride this commit; close-out records the rest. TDD phase
  PRE-RED at claim; no code touched.

### 2026-09-26 · [ad hoc] S782 records: close-out for PED_GV F1 (S781 handoff evaluated 9/10, receipt, Learning 795, next-session items)
- **Deliverable:** the close-out records for S782, whose work is recorded in the entries below:
  RED `3772dd70`, GREEN `3aae4b9c`, REFACTOR `e948f790`, docs `00610aed` (claim `a70e9dfe`). Adds
  the `HANDOFFS.md` receipt, the `SESSION_NOTES.md` record with the S781 handoff evaluation, and
  Learning 795 (an `rcmdcheck` 0/0/0 from an aborted run is not a clean check; measure a duration
  before stating it). **Ratchet:** 1/1 at `00610aed`, 3,565,387 B (+210 B vs S781 = noise),
  results `76631f2eafcc`, manifest `aa983075d6a2`; the S781 citation matched BEFORE the run.
- **Correction to the GREEN entry's disclosure** (an entry once committed is never edited): it says
  "my first two check runs were NOT clean evidence". Measured from the task files, three attempts
  preceded the completing one -- the false 0/0/0, a diagnostic re-run that showed the abort, and an
  argument-name failure (55 s, 23 s and 1 s of compute); the completing `R CMD check` took 6 min
  20 s and the full suite 4 min 50 s. The "about 40 minutes lost" and "about 20 minutes" I first
  wrote were unmeasured and are corrected in the receipt and `SESSION_NOTES.md`.
- **Left for later:** the push (17 local commits after this one) is the owner's call; F4, F2, F3
  and the NA-status decision stay open in `BACKLOG.md`; no GitHub issue exists for F1, so none
  closed.

### 2026-09-26 · [ad hoc] S782 docs: `NEWS.Rmd` "Fixed:" entry for F1; `BACKLOG.md` -- F1 removed from the PED_GV item, NA phantom-row defect filed
- `NEWS.Rmd` (General Fixes, development version): one plain-language "Fixed:" entry -- 
  `removeUnknownAnimals()` no longer returns an empty pedigree when the pedigree has no record of
  which animals were added. Spell check found nothing new on the added lines; the two tests that
  read `NEWS.Rmd` pass. `NEWS.md` not re-rendered (it lags by design until release).
- `BACKLOG.md`: the PED_GV item now carries F4, F2, F3 (F1 is done; the fix's record is the GREEN
  entry above); a new DECISION NEEDED item files the `recordStatus`-`NA` phantom-row defect the owner
  ruled out of F1's scope, with the S782 probe numbers, the helper's two callers and three fix
  shapes. Staged header-less (`tail -n +6` blob via `git update-index`), so the owner's uncommitted
  5-line YAML header stays in the working tree only.

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

