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

