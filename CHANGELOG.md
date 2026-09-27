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

**Archived 26 record(s), 2026-09-26 → 2026-09-26** into [`docs/archive/CHANGELOG-through-2026-09-26-2.md`](docs/archive/CHANGELOG-through-2026-09-26-2.md) — same format, same order, frozen.
Losslessness is proved by [`docs/archive/CHANGELOG-through-2026-09-26-2.md.verify.sh`](docs/archive/CHANGELOG-through-2026-09-26-2.md.verify.sh), which re-derives L1/L2/L3 from git; run it rather
than trusting this sentence. Written by `methodology_trim.py` v1.5.0.

### 2026-09-26 · [ad hoc] S787 records: close-out for the `correctParentSex()` slice (S786 handoff evaluated 9/10, receipt, Learning 800, next-session items)
- **Deliverable:** the close-out records for S787, whose work is recorded in the entries below: RED
  `9da678e6`, GREEN `d20e7b1c`, the REFACTOR test-only step `0a3c4473`, docs `9effbe81`, and the
  three owner-approved ledger trims (`7a55e198` `SESSION_NOTES.md`, `d0c80d24` `HANDOFFS.md`,
  `bc87e5e7` `CHANGELOG.md`, each with its tool-written entry); claim `3287ba8c`, whose "(in
  progress)" marker this entry closes. No push (not asked): 21 local commits after `origin/master`
  = `4e2e6e06`, none of which has been through CI.
- **Verification that ran after the docs commit** (the docs entry said it would follow):
  clean-export `R CMD check --as-cran` on `9effbe81`: **as-is 1 error, 0 warnings, 1 NOTE**, the
  error being the two wall-clock benchmarks (`test_markerKinship.R`, `test_markerParentageLikelihood.R`)
  failing under a host load average of 100-350 from processes outside the session, with 7,079 other
  expectations passing; **with `CI=true`** in the check's `env` (it removes exactly those two blocks,
  the only `skip_on_ci()` uses in the suite) **0 errors, 0 warnings, 1 NOTE (dev version), status 0,
  `* DONE` confirmed by a fixed-string match**. Ratchet **1/1 at `9effbe81`** (3,572,199 B, +1,771 B
  against S786's 3,570,428 B; results `3ad0c74e0635`, manifest `aa983075d6a2`). Both benchmark
  files pass on the final code in isolation once the load fell to 39 (5 and 25 tests, 0 failed),
  and both fail identically on the pre-change tree under load, so they are environmental.
- **Handoff and learning:** the S786 handoff evaluated **9/10**; self-assessment **8/10**;
  `HANDOFFS.md` receipt written `status: complete`; `SESSION_NOTES.md` written; **Learning 800**
  (`PROJECT_LEARNINGS.md:2270`): verify every "the app cannot reach this" sentence with a spy (mine
  was false: a blank or unrecognized sex becomes `NA`); capture the original function before mocking
  it; a "only the exact value is special" contract needs a case-variant mutant; a wall-clock benchmark
  red under host load is settled by the pre-change tree plus `CI=true`, and heavy jobs must be
  serialized (Learning 760). The `BACKLOG.md` item was removed in the docs commit; two items were
  extracted and filed there (the shared `isAddedRecord()` helper; an unreadable-sex parent reported as
  a "female sire" or "male dam", filed at the owner's answer).
- **Left for the owner:** the push of the 21 local commits, the working-tree residue (`BACKLOG.md`
  header, `BACKLOG.log`, the two NEWS drafts, 5 render artifacts), closing the 11 recommended PED_GV
  ids, and the two new `BACKLOG.md` decisions. TDD phase REFACTOR complete.

### 2026-09-26 · [ad hoc] Ledger trim: `CHANGELOG.md` → `docs/archive/CHANGELOG-through-2026-09-26-2.md` (26 record(s), 78,761 B → 34,405 B)

**Written by:** `methodology_trim.py` v1.5.0 — a tool action, not a session's judgment.
Moved the oldest **26** record(s) (2026-09-26 → 2026-09-26) out of [`CHANGELOG.md`](CHANGELOG.md) into
[`docs/archive/CHANGELOG-through-2026-09-26-2.md`](docs/archive/CHANGELOG-through-2026-09-26-2.md). Losslessness is asserted by L1 (records-zone concatenation), L2 (zone
pinning) and L3 (record partition), and is **re-derivable** — run [`docs/archive/CHANGELOG-through-2026-09-26-2.md.verify.sh`](docs/archive/CHANGELOG-through-2026-09-26-2.md.verify.sh)
rather than trusting a digest printed here. Live file 78,761 B → 34,405 B (−56.3%).

### 2026-09-26 · [ad hoc] Ledger trim: `HANDOFFS.md` → `docs/archive/HANDOFFS-through-2026-09-26-2.md` (3 record(s), 59,498 B → 32,555 B)

**Written by:** `methodology_trim.py` v1.5.0 — a tool action, not a session's judgment.
Moved the oldest **3** record(s) (2026-09-26 → 2026-09-26) out of [`HANDOFFS.md`](HANDOFFS.md) into
[`docs/archive/HANDOFFS-through-2026-09-26-2.md`](docs/archive/HANDOFFS-through-2026-09-26-2.md). Losslessness is asserted by L1 (records-zone concatenation), L2 (zone
pinning) and L3 (record partition), and is **re-derivable** — run [`docs/archive/HANDOFFS-through-2026-09-26-2.md.verify.sh`](docs/archive/HANDOFFS-through-2026-09-26-2.md.verify.sh)
rather than trusting a digest printed here. Live file 59,498 B → 32,555 B (−45.3%).

### 2026-09-26 · [ad hoc] Ledger trim: `SESSION_NOTES.md` → `docs/archive/SESSION_NOTES-through-2026-09-26-2.md` (5 record(s), 49,605 B → 25,068 B)

**Written by:** `methodology_trim.py` v1.5.0 — a tool action, not a session's judgment.
Moved the oldest **5** record(s) (2026-09-26 → 2026-09-26) out of [`SESSION_NOTES.md`](SESSION_NOTES.md) into
[`docs/archive/SESSION_NOTES-through-2026-09-26-2.md`](docs/archive/SESSION_NOTES-through-2026-09-26-2.md). Losslessness is asserted by L1 (records-zone concatenation), L2 (zone
pinning) and L3 (record partition), and is **re-derivable** — run [`docs/archive/SESSION_NOTES-through-2026-09-26-2.md.verify.sh`](docs/archive/SESSION_NOTES-through-2026-09-26-2.md.verify.sh)
rather than trusting a digest printed here. Live file 49,605 B → 25,068 B (−49.5%).

### 2026-09-26 · [ad hoc] S787 docs: `correctParentSex()` roxygen + man page, `NEWS.Rmd` Fixed entry; the `recordStatus` sibling-sites item COMPLETE and removed from `BACKLOG.md`, two extracted items filed
- **Completed (the last slice):** the `BACKLOG.md` item "One more place tests `recordStatus ==
  "original"` with no NA guard" (found S784, narrowed S785 and S786) is done: all four sibling
  sites now use the "added-only special" contract, `removeUnknownAnimals()` (S784),
  `convertDate()` with `getRecordStatusIndex()` (S785), `removeDuplicates()` (S786) and
  `correctParentSex()` (this session, GREEN `d20e7b1c`, test control `0a3c4473`); the item's block
  was REMOVED from `BACKLOG.md` in this commit, per the completed-item removal rule. No GitHub
  issue exists for it, so none is closed.
- **Files:** `R/correctParentSex.R` (roxygen only: `@details` gets a paragraph on what the
  `recordStatus` does in the report branch; `@param recordStatus` says only `"added"` is special,
  an `NA`, blank or unrecognized value is an original animal, `NULL` means no added records are
  known, and it is used only when `reportErrors = TRUE`), `man/correctParentSex.Rd` (regenerated by
  `devtools::document()`, which changed no other file), `NEWS.Rmd` (one plain-language "Fixed"
  bullet, `NEWS.Rmd:530`, stating the finished state and that the Shiny app was not affected),
  `BACKLOG.md` (staged header-less; your 5-line header stays unstaged).
- **Extracted from the removed block, so nothing open is lost** (item count 26 to 27, tagged 21 to
  22): (1) the deferred shared `isAddedRecord()` helper, now its own optional DECISION NEEDED item
  with the four inline copies named by file and line and the negative-subscript trap carried over;
  (2) the S787 finding that a sire or dam with a blank or unrecognized sex is reported as a "female
  sire" or "male dam" (DECISION NEEDED, Effort S), filed at the owner's answer to a gate question,
  with the measured reach and three options; the `reportErrors = FALSE` half of it (the sire's sex
  silently set to `"M"`, the dam's to `"F"`) was measured just before filing.
- **Checklists:** lint done (0 on `R/correctParentSex.R`, and 0 on the test file at RED and after
  the control); NEWS done; `_pkgdown.yml` (no new export), citation, tutorial and `a2interactive`
  (no new function or parameter; a documented-behavior change only) N/A. **Measured after the
  edits:** `test_correctParentSex.R` 18 tests, 121 of 121; `test_wordlist_coverage.R` 3 of 3;
  `test_pkgdown_reference_config.R` 1 failed of 5 (the known one: your untracked
  `suggested_NEWS_entry` draft is an article no `_pkgdown.yml` list covers); `tools::checkRd` clean.
  REFACTOR review: `R/correctParentSex.R` needed no code change.

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

