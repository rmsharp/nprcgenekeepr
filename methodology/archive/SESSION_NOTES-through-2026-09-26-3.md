# SESSION_NOTES.md — archive: 2026-09-26 → 2026-09-26

Retired records from [`SESSION_NOTES.md`](../../SESSION_NOTES.md), moved here so the live ledger stays small enough to read
in one pass. Same format, same newest-on-top order — this is the same ledger, continued.

Holds **4 record(s), 2026-09-26 → 2026-09-26**. Cut key: `2026-09-26`. Counts here are computed from the file
itself, never carried forward. This shard is frozen: it states no forward-looking rule,
because the live file owns those and a copy of one was wrong a day after it was written.

---

### Session 786 Handoff Evaluation (by Session 787)
**Score: 9/10.** **What helped:** every Orient measurement held -- 0 undocumented on both frontiers
(`b5b4512c` = HEAD), 12 unpushed (recounted), `origin/master` = `4e2e6e06`, the ratchet citation
(results `7f7a4d08491b`, manifest `aa983075d6a2`, head `e7d87c4a`) matched the results file before any
run, and the working-tree residue was exactly as described (the 5 render artifacts all trace to
tracked `.qmd` sources); the item's probe reproduced to the letter (an `NA` on the female sire
reports `NA`, an unrecognized status skips it, `NULL` reports nothing, `"added"` is skipped) and its
pins (`R/correctParentSex.R:89-92`, 6 tests all `"original"`) were right; the STANDING SET (receipt
gotcha 7) was read BEFORE the first command and none of its traps hit me; S786's scripts
(`run_full.R`, `mutants.R`, `diffrun.R`, `run_check.R`) adapted with small edits saved about an
hour; the size forecast was right (each ledger crossed its limit this session). **Missing:** (1) the
scripts are named but not located: each session's scratchpad is its own directory, and I found
S786's only by listing sibling `scratchpad` directories (they were in `245cd44a-...`); (2) gotcha
(3) says to "swap a spy into the namespace" but not that a spy which calls the exported function
recurses under `with_mocked_bindings` (my first run: "node stack overflow"; capture the original
first); (3) the item covered NA, unrecognized and `NULL`, not blank or case variants, mixed status
vectors, or that an omitted `recordStatus` errors in the report branch (an 18-case probe found
them); (4) the "1 failed" baseline holds only on a quiet machine: two wall-clock benchmarks fail
under host load (Learning 760 already said so; the handoff could have pointed at it). **Wrong:**
nothing material. **ROI:** high.

### What Session 787 Did
**Deliverable:** **`correctParentSex()` -- slice 3, the LAST, of the sibling `recordStatus` sites --
DONE.** The report branch (`reportErrors = TRUE`) now sets aside only records marked `"added"`; an
`NA`, blank or unrecognized status is a real animal and a `NULL` status means "no added rows known,
check every animal". Before, an `NA` reported `NA` in place of the id, a blank or unrecognized
status skipped the animal silently, and `NULL` reported nothing (12 of 18 probe cases differed).
**The four-site `BACKLOG.md` item is COMPLETE and removed.** Script-only reach: `qcStudbook()` rewrites
the column through `addParents()` first (a spy confirmed the function only ever receives `original`
and `added` from the app). Owner-picked at the Phase 0 priorities gate; strict TDD with an
`AskUserQuestion` at every gate.
**Commits:** claim `3287ba8c`; RED `9da678e6`; GREEN `d20e7b1c`; REFACTOR test-only `0a3c4473`; docs
`9effbe81`; ledger trims `7a55e198` (this file), `d0c80d24` (`HANDOFFS.md`), `bc87e5e7`
(`CHANGELOG.md`); this records commit.
**Push:** none (not asked); 21 local commits after `origin/master` = `4e2e6e06` (recount); CI has not
seen S785, S786 or S787.
**Owner decisions:** the Phase 0 pick; at Pre-RED, **"NULL = check every animal"** (over a
`recordStatus = NULL` default and NULL = an error); PRE-RED to RED yes; RED to GREEN yes; GREEN to
REFACTOR "review + docs + M7 test" (over docs-only and extracting the shared helper); **file** the
unreadable-sex finding; the archive pass on **all three** ledgers.
**Result (measured):** probe (18 cases, current against a written reference): 12 differ in three
ways (`NA` names `NA`; blank, `"weird"` and `"Original"` skip; `NULL` reports nothing), 6 controls
agree, the correction branch and `sireAndDam` ignore the status. RED: 11 new tests, **5 failing (43
of 101 expectations)**, 0 errors, the 6 existing tests and 6 controls passing, each message read.
GREEN: 17/17 (101/101); with the M7 control 18 tests, **121/121**; lintr 0 on both files; **13 of 13
mutants killed** (12 first; the survivor, a case-insensitive `"added"`, was closed by one control
test) with the real function and a GREEN-equivalent builder both at 0 and the pre-change code as a
mutant reproducing the RED count. Full suite (`load_all` + `NOT_CRAN`, no filter, on the GREEN code)
353 files, 2,727 tests, 8,474 expectations, **3 failed** (the known `test_pkgdown_reference_config.R`
plus `test_markerKinship.R` and `test_markerParentageLikelihood.R`), 0 errors, 187 skipped, 6
warnings; those two are wall-clock benchmarks that failed identically on the pre-change tree under a
host load average of 100-350 (not mine) and pass on the final code at load 39 (5 and 25 tests, 0
failed). Clean-export `R CMD check --as-cran` on `9effbe81`: **as-is 1 error (those two benchmarks;
7,079 other expectations passed), 0 warnings, 1 NOTE**; with `CI=true` (removes exactly those two
blocks, the only `skip_on_ci()` uses in the suite) **0 errors, 0 warnings, 1 NOTE (dev version),
status 0, `* DONE` by a fixed-string match**. Ratchet **1/1 at `9effbe81`** (3,572,199 B, +1,771 B;
results `3ad0c74e0635`, manifest `aa983075d6a2`). **Archive pass (owner-approved, `--force` for the
known SRF refusal, `CHANGELOG.md` last):** this file 49,605 to 25,068 B (5 of 8 records),
`HANDOFFS.md` 59,498 to 32,555 B (3 of 6), `CHANGELOG.md` 78,761 to 34,405 B (26 of 38); all three
verify scripts OK on L1/L2/L3 (the known `HANDOFFS.md` false positive did not trigger).
**Runtime (3E):** `correctParentSex()` is on the app's upload path, so a differential run: 140
`qcStudbook()` calls (`reportErrors` both ways over 13 datasets, 13 example files,
`ExamplePedigree.txt`, a sire-flipped and a dam-flipped variant of each where present, 5 probe
fixtures), the pre-change tree (`git archive`) vs the working tree, separate `Rscript`s: **all
identical** including the 29 error results; 70 report-mode calls, 34 with a non-empty error list.
Not a live click-through of the Shiny app.
**Disclosures:** (1) the full suite ran on the GREEN code BEFORE the M7 test and the docs edit; after
them I re-ran the target file, the wordlist and pkgdown tests, lintr, `checkRd`, the mutants (13/13)
and the clean-export check on the final code; a full suite with the M7 test would be 2,728 tests and
8,494 expectations by arithmetic (+1, +20), NOT measured; (2) I ran the mutants and the differential
run beside the full suite (Learning 760 again; it took 8.9 min against about 4.6), which confounded
the benchmark reading until a pre-change control settled it; (3) my first RED ledger draft said the
app cannot produce an `NA` sex on a parent; false (a blank or unrecognized sex becomes `NA`, and the
app then reports it as a "female sire"); caught by verifying before the commit, corrected, and now
filed as an item; (4) two counting slips corrected (140 calls not 141; a grep that counted empty
`fs=[]`); (5) my first tag-enumeration regex was too strict (4 of 26 tagged; the control was 21),
rewritten; (6) the M7 test is a test-only step inside REFACTOR, owner-approved at the gate; (7) I
ordered the Phase 0 list READY-first again (S786's choice) and the picker showed the first 4 of 9
numbered items; (8) your working-tree residue is untouched and the `BACKLOG.md` header stayed
unstaged (the working diff is the 5 header lines, checked after the docs commit); (9) the S787
claim entry in `CHANGELOG.md` keeps its "(in progress)" marker by the ledger rule.
**Checklists:** lint done; NEWS done (`NEWS.Rmd:530`); `_pkgdown.yml` (no new export), citation,
tutorial and `a2interactive` (no new function or parameter) N/A; no GitHub issue exists for this
defect; the `BACKLOG.md` item was REMOVED and two items filed (26 to 27 items, 21 to 22 tagged).

**Self-assessment (Session 787): 8/10.** **Strengths:** STANDING SET read before the first command;
Orient measured (both frontiers, remote tip, ratchet citation before the run, CI, budget, trim
check, the tag enumeration against its control, both sequencing audits, the untracked files
source-checked); code, callers, tests and the workstream read before the gate; the probe diffed the
code against a written reference over a case matrix and the app path was spied, so the shape
decision and the "script-only" claim are measured; a false claim caught by verifying and turned into
a finding; every gate through `AskUserQuestion`; RED for the right reasons with hand-predicted
failure counts that matched; GREEN verified past the minimum (full suite, mutants with two
controls, a 140-call differential run, clean-export check on the final code, ratchet); the two
benchmark reds diagnosed with a pre-change control and a CI-equivalent rerun instead of assumed
away or ignored; scope held (the sex finding filed not fixed; the helper deferred). **Weak:** (1) I
broke Learning 760 by running heavy jobs beside the suite; (2) a spy that recursed (one wasted run);
(3) a too-strict tag regex and two counting slips, each caught by a cross-check; (4) the full suite
predates the M7 test and docs edit (mitigated, disclosure 1); (5) a long Phase 0 report. **Learnings:**
800.

**Next steps (specific):** (A) **The `recordStatus` sibling-sites family is DONE.** **READY now**
(working-file `BACKLOG.md` lines; HEAD = minus 5): `NEWS.Rmd` release-state sweep (M) `:136`; the
docs staleness audit (L) `:152`; the `a2interactive` `reportMatePairs()` section (S) sub-item (1) of
`:114`; the Chrome-for-Testing hang root-cause (M, optional, low priority) `:339`; the `BACKLOG.md`
ledger-size housekeeping (L) `:397`. (B) **New this session, DECISION NEEDED:** a sire or dam with a
blank or unrecognized sex is reported as a "female sire" or "male dam" (S) `:39`; the shared
`isAddedRecord()` helper (S, optional) `:56`. (C) **Other open decisions:** `convertDate(reportErrors)`
row numbering (S, low) `:70`; the absent-id decision for `getAncestors()` (S) `:85`; F2 and F3 `:13`;
`paths-ignore` (S) `:101`. (D) **Owner-requested or owner-decision:** the contributor tutorial (M)
`:175`, the peer-reviewed papers (L, its own scoping session first) `:559`, the harem-sire hole
`:214`, blank ancestry OTHER vs UNKNOWN `:192`, the two LabKey items `:253` and `:268`, the
retrospective backfill `:234`, the trimmer's verify false positive (S) `:362`. (E) Your decisions
open: the working-tree residue (the `BACKLOG.md` header, `BACKLOG.log`, the two NEWS drafts -- the
draft still turns one local test red -- and 5 render artifacts), **the push of the 21 local commits
after `4e2e6e06` (CI has not run on any of them)**, closing the 11 recommended PED_GV ids. No archive
pass is owed at the next Orient (measure it).

**Key files:** `R/correctParentSex.R:4-41` (roxygen), `:100-106` (the `isAdded` mask and the two
report lines); `tests/testthat/test_correctParentSex.R:139-303` (the new block: helpers `statusPed`,
`statusReport`, `statusAt`, `allStatus`, `statusCases`; 12 new tests); `NEWS.Rmd:530`;
`man/correctParentSex.Rd`; `BACKLOG.md` working `:39` and `:56` (the two new items);
`CHANGELOG.md:61` (the S787 entries, newest first: records, the three tool-written trim entries,
docs, REFACTOR, GREEN, RED, claim); `HANDOFFS.md` (the S787 receipt at the top of the receipts);
`PROJECT_LEARNINGS.md:2270` (Learning 800); `docs/archive/*-through-2026-09-26-2.md` (three shards,
each with a `.verify.sh`); `.quality-gates-results.json` (untracked; the citation source); scratchpad
scripts in `/private/tmp/claude-501/-Users-rmsharp-Development-nprcgenekeepr/b5fc9869-c030-4cc3-9280-b4620c73c99f/scratchpad/`
(`probe_s787.R`, `probe_app_s787.R`, `probe_sex_s787.R`, `probe_sex2_s787.R`, `run_red_s787.R`,
`mutants_s787.R`, `diffrun_s787.R`, `run_full_s787.R`, `run_check_s787.R`, `run_check_ci_s787.R`,
`rerun_timing_s787.R`, `enum_backlog2.py`; not in git; S786's are in the sibling `245cd44a-...`
directory).

**Gotchas for the next session:** (1) Expect 0 undocumented on both frontiers -- measure; 21
unpushed after this records commit (recount); `origin/master` = `4e2e6e06`; the working tree is NOT
clean (`BACKLOG.md` = your 5-line header only, untracked `BACKLOG.log`, two `suggested_NEWS_entry`
drafts, 5 render artifacts); stage by name; the header-less blob method worked verbatim (edit the
working file, `tail -n +6 BACKLOG.md > blob`, `git hash-object -w blob`, `git update-index
--cacheinfo 100644,<sha>,BACKLOG.md`, commit, confirm `git diff HEAD -- BACKLOG.md` shows only the 5
header lines); working-file `BACKLOG.md` line numbers are HEAD +5 (this note cites working-file
numbers). (2) **A local unfiltered suite reads 1 failed on a QUIET machine** (the pkgdown draft);
under host load two wall-clock benchmarks (`test_markerKinship.R` `< 0.1` s,
`test_markerParentageLikelihood.R` `< 0.5` s) also fail: check `uptime` and `ps -Ao
pid,ppid,etime,%cpu,comm | sort -k4 -nr | head`, run the two files ALONE, run the failing files on a
`git archive` of the pre-change commit, and for `R CMD check` pass `"CI" = "true"` in `env` (removes
exactly those two blocks); never run other heavy jobs beside the suite (Learnings 760, 800). Suite
baseline: 353 files, 2,727 tests, 8,474 expectations, 187 skipped, 6 warnings (measured before the
M7 test). Clean-export `R CMD check` recipe unchanged (S782 receipt gotcha 2), about 7-10 min under
load. (3) Ratchet 1/1 at `9effbe81` (3,572,199 B, results `3ad0c74e0635`, manifest `aa983075d6a2`);
compare BEFORE any run, run AFTER committing. (4) A spy for a function called inside the package:
capture `realFn <- <fn>` BEFORE `with_mocked_bindings` and call `realFn`, never `pkg::fn` (Learning
800b); a fixture through `qcStudbook()` needs a `birth` column. (5) The four `recordStatus` sites
(`removeUnknownAnimals()`, `convertDate()`, `removeDuplicates()`, `correctParentSex()`) all use the
"added-only special" shape; do not reintroduce `x[-idx]` or `seq_along(x)[cond]` in any of them.
(6) Sizes measured before this records commit (re-measure at Orient): this file 37,300 B (hook
ceiling 56,750 B), `HANDOFFS.md` 41,745 B, `CHANGELOG.md` 37,203 B against the 65,536 B trim
budget; a five-commit session added about 13.7 KB to `CHANGELOG.md` (before its trim) and 9-10
KB to the other two, so an archive pass is due again in about two to three sessions; when it is, `--cut N` keeps the N newest,
trim `CHANGELOG.md` LAST, and count the tool-written trim entries when choosing the cut for a
session-boundary seam. (7) STANDING SET carried in the S787 receipt's gotcha (7); READ IT BEFORE THE
FIRST COMMAND. New in S787: a wall-clock benchmark red is a host-load question first; the trim tool
writes its own `CHANGELOG.md` entry, so each trim commit is 4 files.

### Session 785 Handoff Evaluation (by Session 786)
**Score: 9/10.** **What helped:** every Orient measurement held -- 0 undocumented on both frontiers
(`6fbf264b` = HEAD), 7 unpushed, `origin/master` = `4e2e6e06`, the ratchet citation (results
`e743300ed559`, manifest `aa983075d6a2`, head `e7eaf320`) matched the results file before any run,
and the working-tree residue was exactly as described (the "5 render artifacts" are 3 Quarto HTML
and 2 PDF renders of tracked `.qmd` sources); the item's recycling claim (originals `x, x, z` plus
4 added rows return `"x" "a2"`) reproduced to the letter; the decided shape and the recipe (`ids <-
ped$id[<non-added mask>]; ids[duplicated(ids)]`) were what I shipped; the header-less blob method
and the clean-export `R CMD check` recipe worked verbatim (about 6 min); this time I read the
STANDING SET (receipt gotcha 7) before the first command and hit none of its traps. **Missing:**
(1) the item covered the NA trigger and the recycling, not that an UNRECOGNIZED or blank status
makes the line miss every duplicate (`NULL` where `A B C` is right), nor the row-order variants
(added rows first name `z` and miss `x`); a reference-vs-current probe found them; (2) the app-path
recipe ("a 3-row pedigree with one duplicate id and unlisted parents reported `x, s2`") gave no
fixture, and a fixture without a `birth` column returns at `missingColumns` before
`removeDuplicates()` runs (my first probe printed `character(0)`); the shape that reproduces is
`x, x, z` with four unlisted parents (with the dam `NA` the app-minted `U0003` is named too); (3)
the pins are HEAD line numbers while the working file is +5 (you flagged it; I still added 5 by
hand); (4) the "8-10 KB per session" ledger estimate was low for a four-commit session:
`CHANGELOG.md` grew 11.4 KB before its close-out entry. **Wrong:** nothing material. **ROI:** high.

### What Session 786 Did
**Deliverable:** **`removeDuplicates()` -- slice 2 of the sibling `recordStatus` sites -- DONE.**
The `reportErrors = TRUE` branch now searches every record that is not marked `"added"` (an `NA`,
blank or unrecognized status is a real animal) and no longer recycles a mask over the added rows;
before, an `NA` invented or dropped ids, an unrecognized status hid every duplicate, and with a
real duplicate present the app's "Duplicate IDs found" list named ids the app added itself (`x,
s2`). Owner-picked at the Phase 0 priorities gate; strict TDD with an `AskUserQuestion` at every
gate.
**Commits:** claim `62df6441`; RED `f00d8696`; GREEN `32f2b406`; docs `e7d87c4a` (REFACTOR
reviewed, no change); this records commit.
**Push:** none (not asked); 12 local commits after `origin/master` = `4e2e6e06` (recount).
**Owner decisions:** the Phase 0 pick; PRE-RED to RED yes; RED to GREEN yes; GREEN to REFACTOR yes
("review + docs, no code refactor"). No shape or scope decision was needed (S785 decided both).
**Result (measured):** the Pre-RED probe (20 cases, current against a written reference) is in the
`CHANGELOG.md` RED entry: the line is wrong three separate ways (an NA in a row subscript, an
unrecognized or blank status excluded, a recycled mask), every control already agreed, and the app
path reproduced (`x, s2`). RED: 10 new tests, 6 failing (12 of 21 new expectations; the two files
11 tests / 5 failing and 29 / 1), 0 errors, the 4 new controls and the 3 existing tests passing,
each failure's reason read from its message. GREEN: the two files 40 tests, 81/81; 12 related
files 99 tests, 249 expectations, 0 failed; full suite (`load_all` + `NOT_CRAN`, no filter) 353
files, 2,716 tests, 8,387 expectations, **1 failed** (the known `test_pkgdown_reference_config.R`,
your untracked NEWS draft), 0 errors, 187 skipped, 6 warnings (+10 tests, +21 expectations vs S785,
exactly this slice); lintr 0 on 3 files; **8 of 8 mutants killed** with a no-mutation control at 0
(the pre-change code as a mutant fails 6 tests / 12 expectations, the RED count). Clean-export `R
CMD check --as-cran` on HEAD `e7d87c4a` (after the docs edit): 0 errors, 0 warnings, 1 NOTE (dev
version), `* DONE` confirmed by a fixed-string match, status 0. Ratchet **1/1 at `e7d87c4a`**
(3,570,428 B, +1,595 B; results `7f7a4d08491b`, manifest `aa983075d6a2`).
**Runtime (3E):** `removeDuplicates()` is on the app's upload path (`qcStudbook()`), so I ran it
differentially: 87 `qcStudbook()` calls (`reportErrors` both ways over 13 package datasets, 13
example pedigree files and a real-duplicate variant of each, `ExamplePedigree.txt`, 3 probe
fixtures), the pre-change tree (`f00d8696`, `git archive`) vs the working tree, in separate
`Rscript`s: **85 identical, exactly 2 differ and both are the intended change** (`x, s2` and `x, s2,
U0003` become `x`). Limit: 5 example files (and their variants) have no `birth` column and return
before `removeDuplicates()` runs in both trees. Not a live click-through of the Shiny app.
**Disclosures:** (1) I ordered the Phase 0 list READY-first, a departure from "the order S785 left
them", and said so in the report; the picker showed the first 4 of 10 numbered items by rule; (2)
the full suite and the mutants ran on the GREEN code BEFORE the docs edit; after it I re-ran the
two target files, the wordlist and pkgdown tests, lintr and `checkRd`, and the clean-export check
ran on the final code; (3) the suite's 6 warnings are not attributed (the touched files report 0;
S785 recorded no count to compare); (4) I observed, and did NOT file, that the `reportErrors =
FALSE` branch stops with "mismatched information" when duplicate rows differ only in
`recordStatus` (arguably correct; in the RED entry); (5) the shared `isAddedRecord()` helper is
deferred again (three inline copies); (6) your working-tree residue is untouched and the
`BACKLOG.md` header stayed unstaged (working-tree diff = the 5 header lines, checked after the
commit); (7) the S786 claim entry in `CHANGELOG.md` keeps its "(in progress)" marker by the ledger
rule (an entry once committed is never edited); the records entry closes it.
**Checklists:** lint done; NEWS done (`NEWS.Rmd:524`); `_pkgdown.yml` (no new export), citation,
tutorial and `a2interactive` (no new function or parameter) N/A; no GitHub issue exists for this
defect; the `BACKLOG.md` item is narrowed to `correctParentSex()`, not complete, so it stays.

**Self-assessment (Session 786): 8/10.** **Strengths:** STANDING SET read before the first
command; Orient measured (both frontiers, remote tip, ratchet citation before the run, CI, budget,
the whitespace-normalized tag enumeration with a control: 26 items / 21 tagged, both sequencing
audits checked, the untracked files date- and source-checked); code, callers, tests and the workstream
read before the gate; the probe diffed the code against a written reference over a case matrix and
found a wider defect set than filed; a failed app-path reproduction was investigated (fixture
lacked `birth`, then a namespace spy showed the exact input) rather than assumed; every gate through
`AskUserQuestion`; RED for the right reasons (each message read); GREEN verified past the minimum
(related files, full suite, 8 mutants with a control, a differential run of the app path, the
clean-export check on the final HEAD, the ratchet after committing); scope held (one function, one
observation recorded not fixed, helper deferred). **Weak:** (1) my first app fixture had no `birth`
column and I first built a probe writer with a stray parameter (two wasted calls); (2) I read the
background-launcher notification as job completion twice before checking the job's own marker
(Learning 799f); (3) the full suite and mutants predate the docs edit (mitigated, disclosure 2);
(4) the suite's 6 warnings went unattributed; (5) the READY-first reordering of the priorities list
was my judgment, not the documented rule. **Learnings:** 799.

**Next steps (specific):** (A) **Slice 3, `correctParentSex()` (READY, S)** -- the LAST slice of
the sibling `recordStatus` item, `BACKLOG.md` working file `:39` (HEAD `:34`): `R/correctParentSex.R:89-92`;
tests in `tests/testthat/test_correctParentSex.R` (6 today, every status `"original"`); S785's
probe: an `NA` status on the female sire `s1` reports `NA` instead of `"s1"`, an unrecognized status
skips it silently, `recordStatus = NULL` reports nothing (decide what an absent status means as part
of the slice; "no added rows, so check every animal" is the natural reading), `"added"` is skipped
correctly (keep as a control); script-only reach (the app overwrites the column); decide the shared
`isAddedRecord()` helper at its REFACTOR (three inline copies today); add a `NEWS.Rmd` "Fixed"
line; REMOVE the item from `BACKLOG.md` when it lands and record completion in `CHANGELOG.md`. (B)
**Ledger archive pass, owed FIRST and owner-gated:** nothing is over a limit now (so none was owed at
this close-out), but at this session's growth rate all three files cross theirs during the next
session (gotcha 6), and this file's hook refuses a records commit that grows it past its ceiling;
propose the pass to the owner in the Phase 0 report. Trim `CHANGELOG.md` LAST (Learning 761),
`--cut N` KEEPS the N newest (Learning 777), expect the known SRF small-denominator refusal and the
owner-approved `--force`. (C) The other open items, working
file numbering (HEAD = minus 5): `convertDate(reportErrors)` row numbering (DECISION NEEDED, S, low)
`:68`; the absent-id decision for `getAncestors()` (DECISION NEEDED, S) `:83`; F2 and F3
(DECISION NEEDED) `:13`; **READY now:** `NEWS.Rmd` release-state sweep (M) `:134`, the docs
staleness audit (L) `:150`, the trivial cleanup bundle (S) inside `:13`, the `a2interactive`
`reportMatePairs()` section (S) `:112` sub-item (1). (D) **Owner-requested or owner-decision:** the
contributor tutorial (M) `:173`, the peer-reviewed papers (L, its own scoping session first) `:557`,
the harem-sire hole `:212`, blank ancestry OTHER vs UNKNOWN `:190`, the two LabKey items and the
retrospective backfill (grep `LabKey` / `Retrospective`); the trimmer's verify false positive
(DECISION NEEDED, S) `:360`; `paths-ignore` (DECISION NEEDED, S) `:99`. (E) Your decisions open: the
working-tree residue (the `BACKLOG.md` header, `BACKLOG.log`, the two NEWS drafts -- the draft still
turns one local test red -- and 5 render artifacts), the push of the 12 local commits after
`4e2e6e06`, closing the 11 recommended PED_GV ids.

**Key files:** `R/removeDuplicates.R:42-53` (the mask and the report branch; roxygen `:14-25`);
`tests/testthat/test_removeDuplicates.R:39-155` (the new tests; helper `makeStatusPed` `:43`),
`tests/testthat/test_qcStudbook.R:173-212` (the two app-path tests); `NEWS.Rmd:524`;
`man/removeDuplicates.Rd`; `BACKLOG.md` working `:39` (the narrowed item; HEAD `:34`);
`CHANGELOG.md:57` (the S786 entries, newest first: records, docs, GREEN, RED, claim); `HANDOFFS.md` (the S786 receipt at the top of the receipts);
`PROJECT_LEARNINGS.md:2269` (Learning 799); `.quality-gates-results.json` (untracked; the citation
source); scratchpad scripts `probe_s786.R`, `probe_app_s786.R`, `run_red.R`, `run_full.R`,
`mutants.R`, `diffrun.R`, `run_check.R`, `narrow_backlog.py` (not in git).

**Gotchas for the next session:** (1) Expect 0 undocumented on both frontiers -- measure; 12
unpushed after this records commit (recount); `origin/master` = `4e2e6e06`; the working tree is NOT
clean (`BACKLOG.md` = your 5-line header only, untracked `BACKLOG.log`, two `suggested_NEWS_entry`
drafts, 5 render artifacts); stage by name; the header-less blob method worked verbatim (edit the
working file, `tail -n +6 BACKLOG.md > blob`, `git hash-object -w blob`, `git update-index
--cacheinfo 100644,<sha>,BACKLOG.md`, commit, then confirm `git diff HEAD -- BACKLOG.md` shows only
the 5 header lines); working-file `BACKLOG.md` line numbers are HEAD +5 (this note cites working-file
numbers). (2) A local unfiltered suite reads **1 failed** until your draft leaves the tree
(`test_pkgdown_reference_config.R`); its baseline is now 353 files, 2,716 tests, 8,387 expectations,
187 skipped, 6 warnings (unattributed). The clean-export `R CMD check` recipe (S782 receipt gotcha
2) worked unchanged: `git archive HEAD`, `pkgbuild::build`, `rcmdcheck` with the two `_R_CHECK_`
switches, about 6 min, accept only a fixed-string `"* DONE"` plus status 0. (3) For the
`correctParentSex()` slice: build the mask with `is.na()` and never a negative subscript from an
index that can be empty; a probe fixture for anything that goes through `qcStudbook()` needs a
`birth` column or the call returns at `missingColumns` before it reaches the later steps; to see what
a pipeline function actually receives, swap a spy into the namespace (Learning 799b). (4)
`removeDuplicates()`, `convertDate()`, `getRecordStatusIndex()` and `removeUnknownAnimals()` are done
with the "added-only special" shape; do not reintroduce `seq_along(x)[cond]` or `x[-idx]` in any of
them. (5) Ratchet 1/1 at `e7d87c4a` (3,570,428 B, results `7f7a4d08491b`, manifest
`aa983075d6a2`); compare BEFORE any run, run AFTER committing. (6) Sizes (measured before the final
commit): this file about 47,400 B (the hook counts TOKENS at 2.27 B/token, ceiling 25,000 = 56,750
B), `CHANGELOG.md` about 63,500 B and `HANDOFFS.md` about 59,000 B against the 65,536 B trim budget.
This session grew them by about 13.8 KB, 12.9 KB and 9.7 KB (each about 3 KB above S785's
estimate; a four-commit session with a wide probe explains it), so at that rate a session that
claims, does RED, GREEN and docs, and closes out crosses all three: `CHANGELOG.md` and
`HANDOFFS.md` past 65,536 B, this file past 56,750 B (where the hook refuses the commit). Measure
with the context-budget tool and `wc -c` at Orient. (7) The STANDING SET is in the S786 receipt's gotcha (7);
READ IT BEFORE THE FIRST COMMAND. New traps (S786): a `(cmd > out; echo "exit=$?" >> out) &` inside
a `run_in_background` call notifies at LAUNCH, so wait on the job's own `exit=` marker (Learning
799f); the `Grep` tool was unavailable, use `grep` through Bash with quoted globs; piping a
summary through `head -N` can cut the TOTAL line, so grep it separately.

