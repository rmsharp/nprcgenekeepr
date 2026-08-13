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

## How to add an entry

At close-out, prepend one entry per action, **newest on top**, directly below this
section (above `## Legacy history` — never inside it). Key on a mechanical fact, not
judgment: *did this session author or retain any commit, or take any non-commit
action?* If yes, an entry is owed — "too small to log" is failure mode #27, not an
exception.

**Source tag — exactly one per entry**, so `grep -E '\[(issue #|BL-|ad hoc)' CHANGELOG.md`
enumerates every logged action:

- `[issue #<N>]` — a GitHub issue in this repository.
- `[BL-<N>]` — a `BACKLOG.md` item. Remove it from `BACKLOG.md` in the same commit.
- `[ad hoc]` — work with no backlog or issue origin (methodology syncs, planning/audit
  sessions, release mechanics, decline/wontfix decisions).

**Format** — the `###` header line is the required, greppable unit; detail bullets
below it (this project's established `**Deliverable:**`/verification-summary style)
are expected and encouraged:

```
### YYYY-MM-DD · [SOURCE] one-line outcome-focused summary (Session N)
- **Deliverable:** ...
```

When completing work, remove the item from `BACKLOG.md` and add an entry here.

## Size, and when to archive

Sectioning organises this file; it does not shrink it. The file grows without bound and Phase 0
reads it every session, so it also has a size discipline. **Two caps, because there are two
distinct failure modes and neither subsumes the other. Fire if either fires; stop only when both
stop conditions hold.**

| Cap | Protects against | Form | Fire when | Cut until |
|---|---|---|---|---|
| **Lines** — ~2,000, the agent `Read` truncation cap | **silent truncation**: a read past the cap returns no error and no marker, so the oldest entries simply stop existing for the reader | a **rate** | headroom < **15** entries | headroom > **30** |
| **Bytes** — a per-file budget, default **65,536 B** (64 KB) | **context tax**: every session pays for the whole file, every time | a **level with hysteresis** | `size > budget` | `size ≤ ½ × budget` |

**Run this. Do not eyeball it, and do not trust a size written here or anywhere else** — a number
in prose is stale the next time anyone prepends:

```sh
python3 methodology_trim.py --file CHANGELOG.md --check
```

`--check` evaluates both conditions, reports whether the trigger fires, and never writes. `--write`
performs the trim; a dry run is the default, and it refuses to write unless it can prove the split
lossless. **It neither commits nor stages** — it leaves the live file modified and the new shard
*untracked*, prints the rollback, and leaves the commit to you. Stage both yourself:
`git add CHANGELOG.md docs/archive/` — committing with `-a` alone would land the shortened ledger
while the shard, being untracked, never enters history at all.

**Why the line cap is a rate.** Headroom is `(2000 − lines) × entries-added ÷ lines-added` since the
last split, so it re-derives itself from the file on every read. A hand-written level cannot: it is
a derived value frozen at the moment someone typed it. This framework's own receipt ledger is the
worked example — it states its trigger as a level, *"approaches ~1,200 lines,"* and **that level has
never once fired.** The single archive that file has ever had was taken on judgment at 997 lines,
*before* the level was written; since then the file has grown several times past its byte budget
while still reading "under 1,200 lines." A level in the wrong unit says *fine* indefinitely. Where
there is no slope yet — before the first split, or immediately after one — the rate **abstains out
loud** rather than print a number it cannot support.

**Why the byte cap is not.** *"Cut until headroom is back above 30"* is unreachable on bytes at any
budget: a tool applying it would trim the file to a single record and still report the trigger
unsatisfied. A level with hysteresis terminates, and the ½ factor is what keeps the next entry from
re-firing the trigger immediately.

**The budget is judgment, and it is yours to set.** It does not follow from the line cap — at real
ledger densities, 2,000 lines is a different byte count for every file. Calibrate it the way this
default was: take the sizes your repo has actually operated at comfortably after previous archives,
and set the budget just above them. `--budget-bytes <N>` overrides it for a single run.

**Archiving again is not always the answer.** If the file has already given back everything the
last archive removed, another archive resets the *level* and not the *rate* — the tool measures
exactly that and **refuses to fire**; `--force` is how you overrule it deliberately. Before a file's
first archive there is no baseline to measure against, so it abstains rather than compute a zero.

### The shard convention

An archive is a **shard** — a new frozen file, same format, same newest-on-top order. **Note for
this file specifically:** the pre-S325 legacy history (Sessions 1-324, pre-ledger format) that used
to sit inline below a `## Legacy history` boundary marker was itself relocated into
[`docs/archive/CHANGELOG-legacy-pre-S325.md`](docs/archive/CHANGELOG-legacy-pre-S325.md) — S547,
2026-08-13, decided S546 — because the block alone (935,287 B / 3,567 lines) permanently exceeded
this file's own byte/line budgets, making the trigger unclearable by any trim of the tagged region
alone regardless of rate. It is a shard like any other (frozen, same order, no forward-looking
rule) — see that file's own header for why its name departs from the usual
`<BASENAME>-through-<CUTKEY>.md` pattern. It was created by a one-time manual relocation, not
`methodology_trim.py --write`, since the tool has no operation that moves the footer zone (only the
records zone) — verified beforehand (`classify_zones()` and `--check` against the post-relocation
content) not to break the tool's own zone classification or its byte/line trigger.

- **Path: `docs/archive/<LIVE-BASENAME>-through-<CUT-KEY>.md`.** Both halves are load-bearing. The
  directory keeps a shard from shadowing the live file by sort order, and the `CHANGELOG-` prefix is
  what the trigger's own glob looks for when it hunts its baseline — a shard named otherwise is
  silently invisible to it, and the trigger then measures against the wrong boundary.
- **The live file keeps one short pointer** naming each shard and the span it covers. Every count
  stated in that pointer carries the command that recomputes it, because a hand-maintained count
  drifts on the next prepend.
- **The shard back-links to the live file and states only facts about itself** — its own span, its
  own count. It must **not** restate a forward-looking rule. A shard is frozen, so a rule copied
  into one is wrong the moment the live rule moves, and correcting it means editing a frozen
  record. Cite the live file; do not copy it.
- **After a split the authority is the live file *and* its shards.** Any command that enumerates
  this ledger must span both by glob — `CHANGELOG.md docs/archive/CHANGELOG-*.md` — or the split
  silently shrinks the population the audit was counting.
- **Prefer a release frontier as the cut key**, because a shipped release is a boundary nothing can
  ever be written back into. A calendar date works too, but it is frozen only by convention; if you
  cut at one, say in the shard's own front matter that you departed and why.

**A trim is an action, not a side effect.** It earns its own commit and its own `[ad hoc]` entry
here — one ledger, one shard, one commit, one revert. It does **not** belong in Phase 0, which is
read-only apart from the reconcile backfill.

**Not everything that grows can be archived this way.** Archiving moves *history*. A file that grows
because someone keeps adding *procedure* has no past to move — extract a section to a sibling file
and leave a pointer instead. A backlog of open items is live state rather than history: that is a
grooming problem, and its completed items belong here, in this ledger, not in a frozen shard.

## [Unreleased]

## 2026-08

### 2026-08-13 · [BL-N] S547: verified and executed the CHANGELOG.md legacy-footer relocation, Learning 554
- **Deliverable:** Both verification checks from the S546-decided `BACKLOG.md` item passed, and the
  relocation was executed the same session (the item's own "if verification allows, execute"
  framing). **Check 1** (`methodology_trim.py` L1/L2/L3): zero fence markers anywhere in the legacy
  footer (grep + the tool's own `fence_scan()`), so the `SESSION_NOTES.md` fence-scanner defect
  class cannot occur here; `classify_zones()` and a real `--check` run against the post-relocation
  content both came back clean, `[CHECK] trigger does not fire`. **Check 2** (nothing expects it
  inline): grepped `docs/`, `bin/`, `*.py` — no script/tool has a live dependency on the block's
  location; `methodology_trim.py`'s `archive_events()` discovers shards by glob + a live-file-
  size-drop check, not filename parsing, so the new shard's descriptive (non-`-through-<date>`)
  name is still picked up correctly. Only inline references found were prose in already-closed
  planning docs and frozen archive/learnings history — left untouched per standing precedent
  against editing completed documents.
- **Executed:** relocated the block (935,287 B / 3,567 lines, byte-for-byte verified before/after)
  to [`docs/archive/CHANGELOG-legacy-pre-S325.md`](docs/archive/CHANGELOG-legacy-pre-S325.md);
  updated this file's "shard convention" note and live pointer to describe the new location.
  `CHANGELOG.md` is now 20,929 B / 283 lines — both the byte and line triggers clear (down from
  954,673 B / 3,836 lines). `CLAUDE.md`'s "CHANGELOG.md ledger-format resolution" note gained an
  S547 addendum recording the verification and execution. `BACKLOG.md`'s item resolved.
  `PROJECT_LEARNINGS.md` Learning 554 records the verification technique (importing
  `methodology_trim.py` and calling its `classify_zones()` directly against simulated post-edit
  content before making the real edit) for reuse on any future footer-zone relocation.

### 2026-08-13 · [BL-N] S547 claim: scope + verify the CHANGELOG.md legacy-footer bulk relocation
- **Deliverable:** Session S547 claimed. Picking up the `BACKLOG.md` Housekeeping item decided
  S546 ("Scope (and if verification allows, execute) a bulk relocation of `CHANGELOG.md`'s frozen
  pre-S325 legacy footer into its own archive file, un-retagged") — verify `methodology_trim.py`'s
  L1/L2/L3 losslessness invariants survive the relocation, grep for anything expecting the block
  inline, and execute if both are clear.

### 2026-08-13 · [ad hoc] S546 close-out: S325 CHANGELOG.md legacy-footer decision resolved (bulk-relocate scoped, not executed), Learning 553
- **Deliverable:** Session S546's own close-out. `BACKLOG.md`'s "Reopen the S325 'freeze legacy,
  go forward' decision" Housekeeping item (found S543) resolved via a 3-option `AskUserQuestion`
  (scope a lighter bulk relocation of the frozen legacy footer into its own archive file,
  un-retagged / commit to the full ~303-entry re-tag migration campaign / hold as a permanent
  known limitation) — owner picked the bulk-relocation option. `BACKLOG.md` item rewritten to
  READY, Effort M, scoped as a future session's job (verify `methodology_trim.py` L1/L2/L3
  invariants + no script expects the block inline, before moving anything — decision-only this
  session, no file relocated). `CLAUDE.md`'s "CHANGELOG.md ledger-format resolution" note gained
  an S546 addendum recording the decision and the 2 rejected-for-now fallbacks. Recorded
  `PROJECT_LEARNINGS.md` Learning 553 (a picker-before-prose-report process slip, self-caught and
  corrected; and the value of re-deriving a decision from its own underlying investigation rather
  than trusting a prior session's binary framing, which is how the third option was found).
- **Commit:** this close-out's own commit.

### 2026-08-13 · [ad hoc] S546 Phase 0 reconcile: S545's HANDOFFS.md commit self-reference
- **Deliverable:** Phase 0 ledger reconcile (`SESSION_RUNNER.md` step 6). S545's `HANDOFFS.md`
  receipt shipped with `commit: pending` — the standard self-reference limitation (the receipt
  ships in the very commit whose sha it would name), matching the S543→S544 and S544→S545
  pattern each prior session reconciled at its own claim. `HANDOFFS.md`'s frontier
  (`git log -1 -- HANDOFFS.md`) == `7021c6f7` (S545's own close-out commit), so reconciled
  `commit: pending` → `7021c6f7`. No undocumented commits found otherwise; `CHANGELOG.md`'s own
  frontier == `HEAD` already; `gh run list --branch master --limit 10` confirmed all 4 workflows
  on `7021c6f7` (S545's close-out push) completed successfully, resolving the
  still-`in_progress` `R-CMD-check.yaml` run S545's own handoff had flagged unconfirmed.
- **Commit:** this reconcile's own commit.

### 2026-08-13 · [ad hoc] S545 close-out: Phase 0 CI-check decision recorded in CLAUDE.md, BACKLOG.md updated (item resolved + 2 new items), Learning 552
- **Deliverable:** Session S545's own close-out. `BACKLOG.md`'s "Phase 0 has no step that checks
  GitHub Actions CI status" Housekeeping item (found S540) marked RESOLVED, citing the
  `CLAUDE.md` decision. Added 2 new `BACKLOG.md` items (both owner-directed mid-turn): (1) verify
  `nprcgenekeepr`'s exported functions can reproduce the kinship2 R package's own
  supplementary-material worked examples (`inst/extdata/reference/
  NIHMS593658-supplement-supplement_1.pdf`); (2) stop editing resolved `BACKLOG.md` items in
  place into "(none remaining)" pointers — delete them outright instead, per `SESSION_RUNNER.md`
  Phase 3F / FM#27's own literal instruction (57 of ~75 top-level bullets currently carry this
  pattern). Recorded `PROJECT_LEARNINGS.md` Learning 552 (the 2-axis CI-check decision shape, and
  the value of smoke-testing a documented-but-unrun Phase 0 step before close-out).
- **Commit:** this close-out's own commit.

### 2026-08-13 · [BL-phase0CiCheck] Decided the Phase 0 GitHub Actions CI-status check: gh run list --branch master --limit 10, every session, unconditionally (Session 545)
- **Deliverable:** `BACKLOG.md`'s "Phase 0 has no step that checks GitHub Actions CI status" item
  (found S540, `PROJECT_LEARNINGS.md` Learning 547). Presented the decision as a 4-option
  `AskUserQuestion` (every-session unconditional / push-conditioned / branch-protection-instead /
  hold); owner chose unconditional. Recorded in `CLAUDE.md`'s "Additional Phase 0 steps": run
  `gh run list --branch master --limit 10` at Phase 0 step 4 every session (never conditioned on
  whether this project pushed, since a scheduled/manually-triggered workflow can go red with no
  intervening local push at all); report, don't fix, any non-`completed success` run at step 7;
  the 3 rejected alternatives recorded so a future session doesn't re-litigate. Smoke-tested the
  documented command immediately: found `R-CMD-check.yaml` on `126711a9` still `in_progress` at
  15+ minutes — not a red run, but exactly the class of thing the new step exists to catch;
  reported, not chased, to keep this session's own scope intact.
- **Commit:** `7741b47e`.

### 2026-08-13 · [ad hoc] S545 claim: Phase 0 CI-status-check decision
- **Deliverable:** Session 545's Phase 1B claim stub (`SESSION_NOTES.md`, `HANDOFFS.md`).
- **Commit:** `c6c6c0a6`.

### 2026-08-13 · [ad hoc] S545 Phase 0 reconcile: S544's HANDOFFS.md commit self-reference
- **Deliverable:** Phase 0 ledger reconcile (`SESSION_RUNNER.md` step 6). S544's `HANDOFFS.md`
  receipt shipped with `commit: pending` — the standard self-reference limitation (the receipt
  ships in the very commit whose sha it would name), matching the S543 pattern S544 itself
  reconciled at its own claim. `HANDOFFS.md`'s frontier (`git log -1 -- HANDOFFS.md`) ==
  `126711a9` (S544's own close-out commit), so reconciled `commit: pending` → `126711a9`. No
  undocumented commits found otherwise; `CHANGELOG.md`'s own frontier == `HEAD` already.
- **Commit:** `dd177a80`.

### 2026-08-13 · [ad hoc] S544 close-out: test-coverage.yaml fix confirmed green on CI, BACKLOG.md updated (item resolved + new Pedigree Diagram article item), Learning 551
- **Deliverable:** Session S544's own close-out. `BACKLOG.md`'s `test-coverage.yaml` Housekeeping
  item (found S542) marked RESOLVED, citing the fix commit and the confirmed-green CI run. Added
  a new `BACKLOG.md` item (owner-requested mid-turn): a dedicated Pedigree Diagram tutorial
  article, distinct from and superseding the existing stale-screenshot item. Recorded
  `PROJECT_LEARNINGS.md` Learning 551 (the `covr --install-tests` vs. source-tree detection
  root cause, and the fast local-repro technique used to confirm it without a full `covr` run).
- **Commit:** this close-out's own commit.

### 2026-08-13 · [BL-testCoverageCovrInstallTests] Fixed test-coverage.yaml: find_pkg_src() now requires inst/ present, not just DESCRIPTION (Session 544)
- **Deliverable:** `tests/testthat/test_wordlist_coverage.R`'s `find_pkg_src()` helper was
  mis-accepting an INSTALLED package directory (retains `DESCRIPTION`, loses `inst/` — flattened
  into the package root by `R CMD INSTALL`) as a source tree under `covr::package_coverage()`'s
  `--install-tests` execution model, causing `spelling::get_wordfile()` to silently miss
  `inst/WORDLIST` and flag 146 already-whitelisted domain words as unknown. Fixed by requiring
  `dir.exists(file.path(cand, "inst"))` alongside the existing `DESCRIPTION` check in all 3
  branches (a shared `is_pkg_src()` helper). 2 new tests pin the source-vs-installed detection
  directly. Strict TDD RED→GREEN, both gates `AskUserQuestion`-approved. Full regression 0
  failed/0 error (5,519 passed); `devtools::check()` 0 errors/0 warnings/1 pre-existing
  unrelated NOTE; `lintr` clean. Pushed and confirmed `test-coverage.yaml` (plus
  `R-CMD-check.yaml`/`pkgdown.yaml`/`lint.yaml`) all `completed success` on the real CI run.
- **Commit:** `f4b478c0`.

### 2026-08-13 · [ad hoc] S544 claim: test-coverage.yaml CI diagnosis; reconciled S543's HANDOFFS.md self-reference (Session 544)
- **Deliverable:** Session 544's Phase 1B claim stub (`SESSION_NOTES.md`, `HANDOFFS.md`).
  Reconciled S543's `HANDOFFS.md` receipt's `commit: pending` self-reference to `4bac5d55`
  (the expected, routine next-session fill-in per the established S538-S541 pattern).
- **Commit:** `cd5eb453`.

### 2026-08-12 · [ad hoc] S543 close-out: CHANGELOG.md SRF_RED decision resolved, 2 new BACKLOG.md findings, Learning 550
- **Deliverable:** Session S543's own close-out. Resolved the `CHANGELOG.md` `SRF_RED` archive
  refusal by force-archiving (see the trim entry below), after finding the decisive structural
  fact that the trimmable region is capped at 116,176 B against a 935,287 B permanently-pinned
  pre-S325 legacy footer, so no trim of the tagged region can ever clear the byte/line trigger
  regardless of force. Logged 2 new `BACKLOG.md` Housekeeping items: reopening the S325
  "freeze legacy, go forward" decision as the only real lever (DECISION NEEDED, Effort L, needs
  its own scoping session); and `CHANGELOG.md`'s own ~4-entries-per-session convention as a
  possible rate contributor analogous to `HANDOFFS.md`'s diagnosed Receipt Inflation (H4), not
  confirmed causal. `PROJECT_LEARNINGS.md` Learning 550 records the SRF-artifact-vs-structural-
  ceiling distinction. See `SESSION_NOTES.md`, `HANDOFFS.md`.

**Archived 67 record(s), 2026-08-11 → 2026-08-12** into [`docs/archive/CHANGELOG-through-2026-08-12.md`](docs/archive/CHANGELOG-through-2026-08-12.md) — same format, same order, frozen.
Losslessness is proved by [`docs/archive/CHANGELOG-through-2026-08-12.md.verify.sh`](docs/archive/CHANGELOG-through-2026-08-12.md.verify.sh), which re-derives L1/L2/L3 from git; run it rather
than trusting this sentence. Written by `methodology_trim.py` v1.1.2.

**Relocated the entire pre-Session-325 legacy block (roughly 303 record(s), Sessions 1-324,
pre-ledger format)** into [`docs/archive/CHANGELOG-legacy-pre-S325.md`](docs/archive/CHANGELOG-legacy-pre-S325.md)
— S547, 2026-08-13 — verbatim, un-retagged, frozen, same order. Unlike the pointer above, this was
a one-time manual relocation of the frozen footer zone, not a `methodology_trim.py --write` trim of
the records zone, so there is no tool-generated `.verify.sh` for it; losslessness was instead
verified directly (a byte-for-byte comparison of the moved content against what `classify_zones()`
reported as the footer, plus a post-relocation `--check` run confirming the tool's own zone
classification and trigger both resolve cleanly) — see this file's own S547 entry and
`PROJECT_LEARNINGS.md` for the full verification record.

### 2026-08-12 · [ad hoc] Ledger trim: `CHANGELOG.md` → `docs/archive/CHANGELOG-through-2026-08-12.md` (67 record(s), 1,051,843 B → 945,242 B)

**Written by:** `methodology_trim.py` v1.1.2 — a tool action, not a session's judgment.
Moved the oldest **67** record(s) (2026-08-11 → 2026-08-12) out of [`CHANGELOG.md`](CHANGELOG.md) into
[`docs/archive/CHANGELOG-through-2026-08-12.md`](docs/archive/CHANGELOG-through-2026-08-12.md). Losslessness is asserted by L1 (records-zone concatenation), L2 (zone
pinning) and L3 (record partition), and is **re-derivable** — run [`docs/archive/CHANGELOG-through-2026-08-12.md.verify.sh`](docs/archive/CHANGELOG-through-2026-08-12.md.verify.sh)
rather than trusting a digest printed here. Live file 1,051,843 B → 945,242 B (−10.1%).

### 2026-08-12 · [ad hoc] S543 claim: CHANGELOG.md SRF_RED archive-refusal decision
- **Deliverable:** Session S543 claimed (`ca6b17fb`) to decide how to handle `CHANGELOG.md`'s
  `methodology_trim.py` `SRF_RED` refusal (owner-picked via the Phase 0 `AskUserQuestion`
  picker, over `test-coverage.yaml` CI diagnosis / the Phase 0 CI-check-gap decision / issue
  #138 scoping).

