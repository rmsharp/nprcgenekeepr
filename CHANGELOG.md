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

### 2026-08-15 · [BL-N] S582: close out (pb_diagram_legend.png reshoot DONE)
- **Deliverable:** `BACKLOG.md` item (found S574) -- **DONE**. Recaptured
  `vignettes/articles/shiny_app_use/pb_diagram_legend.png` via a standalone `shinytest2`/chromote
  script reproducing the canonical `pedigree-diagram-screenshots.R`'s "Base fixture" step
  (`obfuscated_rhesus_mhc_ped.csv`, focal ids `8LKBV9`/`FJIB3R`/`GA204Z`, selector
  `#pedigree-moduleContainer`), deliberately not setting `pedigreeEdgeStyle` so the capture
  inherits the app's own current zero-interaction default (`"rectilinear"`, confirmed live via
  `R/modPedigree.R`'s `.currentEdgeStyle()`). New image confirmed showing "Rectilinear
  (kinship2-style)" pre-selected with right-angle edge routing, diffed visually against the prior
  committed image. Build-equivalent: `pkgdown::build_article()` for both `articles/pedigree-diagram`
  and `articles/colony-manager-guide` rendered clean (`quarto render`); built HTML's embedded image
  MD5-confirmed identical to the new source PNG. Render litter removed before commit. Neither
  article's prose needed a change (already said "Rectilinear" is the default, from Track 2's own
  S574 pass). Incidental finding filed as its own `BACKLOG.md` item, not fixed: the same script's
  other 3 non-base-fixture screenshots share the identical never-sets-`pedigreeEdgeStyle` omission
  and may be stale by the same mechanism, unverified. See `PROJECT_LEARNINGS.md` Learning 589.

### 2026-08-14 · [BL-N] S582: claim (reshoot pb_diagram_legend.png)
- **Deliverable:** Session claimed. `BACKLOG.md` item (found S574) -- reshoot
  `shiny_app_use/pb_diagram_legend.png`, stale since Track 2 (S574) flipped the Diagram tab's
  zero-interaction default to Rectilinear. Phase 1B stub written to `SESSION_NOTES.md`; pending
  receipt opened in `HANDOFFS.md`.

### 2026-08-14 · [ad hoc] S581: reconcile HANDOFFS.md commit self-reference (`6dd26870`)
- **Deliverable:** Fixed this session's own `HANDOFFS.md` receipt `commit: pending` -> `6dd26870`
  (the close-out commit's own sha, unknowable until after that commit was made) -- matching the
  established S562-S580 precedent.

### 2026-08-14 · [BL-N] S581: close out (locale-dependent order() tie-break sweep DONE)
- **Deliverable:** `BACKLOG.md` order()-sweep item (found S578) -- **DONE**. Fresh
  `grep -n "order(" R/*.R` (26 sites) classified all; 4 real hits fixed (`method = "radix"`
  added, RED->GREEN->REFACTOR): `orderReport.R:81,93`, `qcStudbook.R:323`,
  `modBreedingGroups.R:690` `bgGroupView`. 2 initially-flagged hits corrected to false positives
  via empirical verification: `kinshipMatrixToKValues.R:107` (data.table's own `forder()`
  auto-substitution), `computeGenomicROH.R:112` (returned value provably locale-invariant despite
  the intermediate sort being locale-sensitive) -- explanatory comments added, no behavior change.
  See `PROJECT_LEARNINGS.md` Learning 588 for the full classification methodology.

### 2026-08-14 · [BL-N] S581: verification (full clean regression + live E2E)
- **Deliverable:** 4 targeted RED tests confirmed GREEN post-fix; full clean regression 5,955
  passed / 1 pre-existing failure unrelated (`test_wordlist_coverage.R`) / 0 errors / 33
  pre-existing warnings (both match the established baseline); 0 lints on all 5 touched R files
  (`lintr::lint_package()`, project's own `.lintr` config); `devtools::check()` 0 errors/0
  warnings/1 pre-existing NOTE (`vignettes/figure/` knitr leftover). Live E2E
  (`NPRC_RUN_E2E=true`, real `shinytest2`/`chromote` browser) confirmed all 3 affected runtime
  paths: `test-e2e-mate-pair-analysis-module.R` (qcStudbook), `test-e2e-genetic-value-tutorial.R`
  (orderReport/reportGV), `test-e2e-breeding-groups-module.R` (bgGroupView) -- all pass.

### 2026-08-14 · [BL-N] S581: REFACTOR (explanatory comments, no behavior change)
- **Deliverable:** Added comments to `R/kinshipMatrixToKValues.R:107` and
  `R/computeGenomicROH.R:112` documenting why each is NOT the Learning 585 defect class despite
  superficially matching the character-column-sort pattern. Verified no behavior change (both
  files' own test suites pass unchanged); 0 lints.

### 2026-08-14 · [BL-N] S581: GREEN (method="radix" for 4 confirmed hits)
- **Deliverable:** `R/orderReport.R:81,93`, `R/qcStudbook.R:323`, `R/modBreedingGroups.R:690` --
  `method = "radix"` added to each locale-dependent `order()` call. 4 targeted RED tests now
  GREEN; full clean regression 1 pre-existing failure unrelated, 0 errors; 0 lints on touched
  files; `devtools::check()` 0 errors/0 warnings/1 pre-existing NOTE.

### 2026-08-14 · [BL-N] S581: RED (4 confirmed locale-dependent order() hits)
- **Deliverable:** Fresh `grep -n "order(" R/*.R` classification (26 sites). 4 real hits
  confirmed via empirical divergence testing and RED tests added: `test_orderReport.R` (2 new
  blocks), `test_qcStudbook.R` (1 new block), `test_modBreedingGroups.R` (1 new block,
  `shiny::testServer()` -- no prior coverage of `bgGroupView` existed). All 4 confirmed failing
  for the right reason against unmodified source; 0 regressions in the 3 touched test files. 2
  initially-flagged hits (`kinshipMatrixToKValues.R:107`, `computeGenomicROH.R:112`) corrected to
  false positives during this same investigation -- no test written for either (nothing to prove).

### 2026-08-14 · [BL-N] S581: claim session (locale-dependent order() tie-break sweep)
- **Deliverable:** Phase 1B claim. Picked via Phase 0 `AskUserQuestion` from `BACKLOG.md`'s
  order()-sweep item (found S578). Wrote `SESSION_NOTES.md` claim stub and `HANDOFFS.md`
  `status: pending` receipt. PRE-RED investigation (fresh grep + classification) up next.

### 2026-08-14 · [ad hoc] S580: reconcile HANDOFFS.md commit self-reference (`75c23fe5`)
- **Deliverable:** Fixed this session's own `HANDOFFS.md` receipt `commit: pending` -> `75c23fe5`
  (the close-out commit's own sha, unknowable until after that commit was made) -- matching the
  established S562-S579 precedent.

### 2026-08-14 · [BL-N] S580: close out (HANDOFFS.md byte-budget/line-headroom archive trim DONE)
- **Deliverable:** Session S580's own close-out. Evaluated S579's `HANDOFFS.md` receipt (9/10 --
  the `gotchas` field's `SRF_RED` non-durability warning primed this session for the identical
  divergence on `HANDOFFS.md`, saving a full re-diagnosis). Self-assessed 9/10 (proactively added
  the claim commit's own ledger entry instead of waiting for `P1_UNDOCUMENTED` to catch it; pulled
  absolute byte deltas before the `SRF_RED` decision; caught and fixed a stranded front-matter
  sentence the tool's own edit left behind; weakness: still no independent adversarial-verification
  pass, and skipped a second scope-confirmation `AskUserQuestion` after the picker). Wrote handoff
  notes to `SESSION_NOTES.md`; completed the `HANDOFFS.md` receipt (`status: complete`).

### 2026-08-14 · [BL-N] S580: downstream updates (BACKLOG item resolved, PROJECT_LEARNINGS 587)
- **Deliverable:** Removed the resolved `BACKLOG.md` Housekeeping item (`HANDOFFS.md`'s archive
  trigger, found S579), replaced with a short resolution pointer. Added `PROJECT_LEARNINGS.md`
  Learning 587: confirms the Learning 586 `SRF_RED` recurrence pattern is not `CHANGELOG.md`-
  specific -- the very next session hit it on `HANDOFFS.md` too, a file Learning 549 had cited as
  having "proceeded cleanly" the one time it was checked. Also repositioned `HANDOFFS.md`'s own
  "This file currently holds N receipt(s)" sentence back to immediately after the newest archive
  pointer (the tool's in-place regex edit left it stranded between the 3rd and 4th pointer blocks
  after this session's new pointer was inserted), matching the established S508/S561 convention.

### 2026-08-14 · [ad hoc] Ledger trim: `HANDOFFS.md` → `docs/archive/HANDOFFS-through-2026-08-14.md` (21 record(s), 125,404 B → 9,682 B)

**Written by:** `methodology_trim.py` v1.1.2 — a tool action, not a session's judgment.
Moved the oldest **21** record(s) (2026-08-13 → 2026-08-14) out of [`HANDOFFS.md`](HANDOFFS.md) into
[`docs/archive/HANDOFFS-through-2026-08-14.md`](docs/archive/HANDOFFS-through-2026-08-14.md). Losslessness is asserted by L1 (records-zone concatenation), L2 (zone
pinning) and L3 (record partition), and is **re-derivable** — run [`docs/archive/HANDOFFS-through-2026-08-14.md.verify.sh`](docs/archive/HANDOFFS-through-2026-08-14.md.verify.sh)
rather than trusting a digest printed here. Live file 125,404 B → 9,682 B (−92.3%).

### 2026-08-14 · [BL-N] S580: claim session (HANDOFFS.md byte-budget/line-headroom archive trim)
- **Deliverable:** Phase 1B claim stub written to `SESSION_NOTES.md`/`HANDOFFS.md` (`status:
  pending`) for this session's deliverable: archive `HANDOFFS.md`'s tagged-receipt portion into a
  new dated shard (`BACKLOG.md` Housekeeping, found S579) -- both the line-headroom (4 records
  against the 15-record threshold) and byte-budget (125,043 B against 65,536 B) triggers fire.
  Owner-picked via `AskUserQuestion` over 3 other READY items (locale-dependent `order()` sweep,
  sibling subtree-width asymmetry, stale `pb_diagram_legend.png` screenshot).

### 2026-08-14 · [BL-N] S579: post-close-out finding: HANDOFFS.md's own archive trigger fires
- **Deliverable:** A post-close-out `--check` sweep of both ledgers (prompted by this session's
  own `CHANGELOG.md` trim) found `HANDOFFS.md`'s line-headroom trigger now fires (4 records
  against the 15-record threshold) -- not fixed this session (out of scope), filed as a new
  `BACKLOG.md` Housekeeping item with the SRF boundary numbers already pulled for whoever picks
  it up next.

### 2026-08-14 · [ad hoc] S579: reconcile HANDOFFS.md commit self-reference (`c35b1983`)
- **Deliverable:** Fixed this session's own `HANDOFFS.md` receipt `commit: pending` -> `c35b1983`
  (the close-out commit's own sha, unknowable until after that commit was made).

### 2026-08-14 · [BL-N] S579: close out (CHANGELOG.md byte-budget archive trim DONE)
- **Deliverable:** Session S579's own close-out. Evaluated S578's `HANDOFFS.md` receipt (7/10 --
  the `next_steps` pointer to this exact item was accurate and immediately actionable, but no
  `gotchas` entry warned that `CHANGELOG.md` archiving carries a real, previously-documented risk
  of `SRF_RED` refusal). Self-assessed 8/10 (self-caught a Learning-553-shaped picker-before-prose
  mistake within the same turn; surfaced the `SRF_RED` refusal's two boundary readings plus
  absolute byte deltas to the user rather than force-passing or silently blocking; weakness: the
  risk wasn't checked during Phase 0, only after committing to the task). Wrote handoff notes to
  `SESSION_NOTES.md`; completed the `HANDOFFS.md` receipt (`status: complete`).

**Archived 62 record(s), 2026-08-13 → 2026-08-14** into [`docs/archive/CHANGELOG-through-2026-08-14.md`](docs/archive/CHANGELOG-through-2026-08-14.md) — same format, same order, frozen.
Losslessness is proved by [`docs/archive/CHANGELOG-through-2026-08-14.md.verify.sh`](docs/archive/CHANGELOG-through-2026-08-14.md.verify.sh), which re-derives L1/L2/L3 from git; run it rather
than trusting this sentence. Written by `methodology_trim.py` v1.1.2.

### 2026-08-14 · [ad hoc] Ledger trim: `CHANGELOG.md` → `docs/archive/CHANGELOG-through-2026-08-14.md` (62 record(s), 101,210 B → 32,753 B)

**Written by:** `methodology_trim.py` v1.1.2 — a tool action, not a session's judgment.
Moved the oldest **62** record(s) (2026-08-13 → 2026-08-14) out of [`CHANGELOG.md`](CHANGELOG.md) into
[`docs/archive/CHANGELOG-through-2026-08-14.md`](docs/archive/CHANGELOG-through-2026-08-14.md). Losslessness is asserted by L1 (records-zone concatenation), L2 (zone
pinning) and L3 (record partition), and is **re-derivable** — run [`docs/archive/CHANGELOG-through-2026-08-14.md.verify.sh`](docs/archive/CHANGELOG-through-2026-08-14.md.verify.sh)
rather than trusting a digest printed here. Live file 101,210 B → 32,753 B (−67.6%).

### 2026-08-14 · [ad hoc] S579: claim session (CHANGELOG.md byte-budget archive trim) (`f18431b0`)
- **Deliverable:** Phase 1B claim stub (`SESSION_NOTES.md`) and `HANDOFFS.md` `status: pending`
  receipt for this session's deliverable: archive `CHANGELOG.md`'s tagged-record portion into a
  new dated shard (`BACKLOG.md` Housekeeping, found S573) — the byte trigger fires again
  (100,783 B against the 65,536 B budget).

### 2026-08-14 · [ad hoc] S578: reconcile HANDOFFS.md commit self-reference (`b321df39`)
- **Deliverable:** Fixed this session's own `HANDOFFS.md` receipt `commit: pending` -> `b321df39`
  (the close-out commit whose sha the receipt itself couldn't name until after it was made) --
  matching the established S562-S577 precedent.

### 2026-08-14 · [BL-N] S578: close out (Track 6 child-centered union-position implementation DONE) (`b321df39`)
- **Deliverable:** Full session record written (`SESSION_NOTES.md`, `HANDOFFS.md` receipt). See
  the receipt for the complete self-assessment (9/10) and predecessor evaluation (8/10).

### 2026-08-14 · [BL-N] S578: Track 6 downstream updates for locale-independence fix (BACKLOG, plan doc section 10) (`26f7d909`)
- **Deliverable:** Documents the `devtools::check()`-found, `LC_ALL=C`-reproduced locale-dependent
  tie-break defect and its `method = "radix"` fix in the `BACKLOG.md` DONE item and the plan
  doc's section 10 Implementation Record. Also files a new `BACKLOG.md` Housekeeping item for the
  same defect class found more broadly across the package (`qcStudbook()`, `orderReport()`), not
  fixed this session.

### 2026-08-14 · [BL-N] S578: locale-independent tie-break in de-collision pass (`b0467657`)
- **Deliverable:** `devtools::check()` (run as its own separate build-equivalent step, not
  skipped as redundant with the already-green `pkgload::load_all()` + `test_dir()` regression
  read) surfaced 5 test failures, not the 1 known pre-existing `test_wordlist_coverage.R`
  failure. Root-caused via `LC_ALL=C` reproduction (no code change): `order()` on a character
  node-id vector is `LC_COLLATE`-locale-dependent, so which of 2 exactly-tied same-gen nodes
  absorbs the de-collision pass's 1e-3 epsilon nudge can differ between locales -- a genuinely
  pre-existing latent defect (the original pre-Track-6 pass used the same non-radix `order()`)
  that this session's own widened node-category coverage first exposed as an observable,
  hardcoded-test-breaking symptom. Fixed by adding `method = "radix"` (R's only
  locale-independent character-vector ordering) to both affected `order()` calls in
  `.positionMatingUnitForest()`; updated 4 `expectPos()` values in
  `test_positionMatingUnitForest.R` to match the new locale-stable output. Verified: targeted
  file green under both `en_US.UTF-8` and `LC_ALL=C`; full clean regression under `LC_ALL=C` 1
  pre-existing unrelated failure, 0 new; `lintr::lint_package()` 0 lints; `devtools::check()`
  re-run clean against the established baseline only. `PROJECT_LEARNINGS.md` Learning 585 records
  the finding.

### 2026-08-14 · [BL-N] S578: Track 6 downstream updates (BACKLOG, plan doc section 10) (`228b5071`)
- **Deliverable:** Marked the `BACKLOG.md` Housekeeping item DONE (implemented S578). Added
  section 10 (Implementation Record) to
  `docs/planning/pedigree-diagram-track6-child-centered-union-position-plan.md` documenting the
  2 Pre-RED corrections, re-measured headline figures, and verification evidence.

### 2026-08-14 · [BL-N] S578: GREEN, Track 6 child-centered mating-unit position (`f65ecbea`)
- **Deliverable:** Implements `docs/planning/pedigree-diagram-track6-child-centered-union-
  position-plan.md` §2 (Extended Candidate A, design ratified S576) in
  `.positionMatingUnitForest()` (`R/makePedigreeDiagramData.R`): a mating unit's `finalUnitX` is
  now the midpoint of its own children's final x (was its 2 parents' midpoint); a duplicate
  node's `dupX` is now derived from the new `finalUnitX`; the final de-collision pass is
  broadened to cover every node (real, duplicate, union). Pre-RED empirical validation found the
  `orderBySex` block must move earlier in the function (finalUnitX/dupX computed after it, not
  at §2.1's literally-described pre-orderBySex location) for the §2.4 invariant to hold. Also
  fixed 2 pre-existing tests whose assertions directly encoded the old parent-midpoint behavior.
  Verified: all 30 tests in `test_positionMatingUnitForest.R` pass; full clean regression 1
  pre-existing unrelated failure, 0 new; `lintr::lint_package()` 0 lints; real-fixture
  re-measurement matches the ratified figures (100/251→9/251 violating edges, 61.94/120.12→
  48.00/48.00 duplicate-to-union distance, 0 exact coincidences); live `visNetwork`/`chromote`
  render (both `edgeStyle` values, small + full real fixture) 0 console errors, visually
  confirms unions now sit close to their own children.

### 2026-08-14 · [BL-N] S578: RED, Track 6 child-centered union-position invariant (`0780cdfd`)
- **Deliverable:** Added 2 new tests to `test_positionMatingUnitForest.R` (the §2.4 invariant on
  the small GA204Z/8LKBV9 fixture + the real 375-individual fixture; a duplicate-vs-any-node
  exact-coincidence test) and updated the existing "issue #143 fix" exact-value test (8 of 13
  `expectPos()` calls, re-derived live via a from-scratch reimplementation of Extended
  Candidate A run against unmodified `.buildMatingUnitForest()` output). Confirmed RED: the 3
  touched tests fail against unmodified source (8/27, 225/241, 1/1 expectations), including a
  genuine pre-existing duplicate/union coincidence unrelated to this decision; all 25 other
  tests in the file pass unchanged.

### 2026-08-14 · [ad hoc] S578: claim session (Track 6 child-centered union-position implementation) (`ca921a92`)
- **Deliverable:** Phase 1B claim stub written to `SESSION_NOTES.md`/`HANDOFFS.md`.

### 2026-08-14 · [ad hoc] S577: reconcile HANDOFFS.md commit self-reference (`3a1a8de4`)
- **Deliverable:** Fixed this session's own `HANDOFFS.md` receipt `commit: pending` -> `3a1a8de4`
  (the close-out commit whose sha the receipt itself couldn't name until after it was made) --
  matching the established S562-S576 precedent. Bundled into the SAME commit as this entry (unlike
  S576's own instance of this same action, which this session's Phase 0 found had no matching
  `CHANGELOG.md` entry at all and had to backfill) -- applying this session's own Phase 0 finding
  immediately rather than repeating the gap.

### 2026-08-14 · [BL-N] S577: close out (duplicate-connector arc curve-direction fix DONE)
- **Deliverable:** GREEN implementation ratified via both TDD phase gates (`AskUserQuestion`
  PRE-RED->RED and RED->GREEN, both approved as written; GREEN->REFACTOR offered and explicitly
  skipped). `R/makePedigreeDiagramData.R`'s `dupEdges` construction now x-orders `from`/`to`
  instead of always `from=dupId`, matching kinship2's own `arcconnect()` convention (always sorts
  its pair by x before drawing). Verified: targeted tests 188/188, full clean regression
  4854/4854 (0 error), 0 lint on the touched file, real 375-individual fixture re-measurement
  52/52 same-row connectors now correct (was 19/52), live `visNetwork`/`chromote` render visually
  confirms the convex bow. Self-score 9/10; S576 handoff evaluation 9/10. See `HANDOFFS.md` S577
  receipt for the full record.

### 2026-08-14 · [BL-N] S577: downstream updates (BACKLOG item removed, plan doc section 7a) (`ee22559c`)
- **Deliverable:** Removed the resolved `BACKLOG.md` Housekeeping item. Updated
  `docs/planning/pedigree-diagram-kinship2-fidelity-remediation-plan.md` section 7a with the root
  cause and fix summary.

### 2026-08-14 · [BL-N] S577: GREEN, x-order duplicate-connector from/to (`a01c176c`)
- **Deliverable:** `R/makePedigreeDiagramData.R` `dupEdges` construction (~line 1342): order
  `from`/`to` by ascending x (using the already-computed `nodes$x`) instead of the fixed
  `from=dupId, to=realId`, `smooth.type="curvedCW"`/`smooth.roundness=0.2` unchanged. Fixes the
  duplicate-individual dashed connector's bow direction to match kinship2's own convention
  regardless of which occurrence sits left/right. Verified self-contained: `dupEdges$color`/`width`
  are unconditionally NA regardless of `from`/`to`, and no downstream
  `.addRectilinearWaypoints()` D1/D2 logic keys off a duplicate-connector row's `from`/`to`.

### 2026-08-14 · [BL-N] S577: RED, duplicate-connector arc x-ordering (`0d013838`)
- **Deliverable:** Added 2 new tests to `tests/testthat/test_makePedigreeMatingLayout.R` (a
  deterministic `loopPed`-fixture case + the real 375-individual bundled fixture) asserting every
  dashed duplicate-connector edge has `from.x <= to.x`. Updated 3 existing tests whose filters
  assumed `from` is always the duplicate id, relaxed to `{from,to}` set membership. Confirmed RED:
  184 pass / 4 fail against the pre-fix implementation.

### 2026-08-14 · [ad hoc] S577: claim session (duplicate-individual arc curve-direction fix) (`a04090ec`)
- **Deliverable:** Phase 1B claim stub written to `SESSION_NOTES.md`/`HANDOFFS.md`.

### 2026-08-14 · [ad hoc] S576: reconcile HANDOFFS.md commit self-reference (`ce8c50a1`) (Backfilled reconcile-on-read, Session 577)
- **Deliverable:** Fixed S576's own `HANDOFFS.md` receipt `commit: pending` -> `7b04a911` (the
  close-out commit whose sha the receipt itself couldn't name until after it was made) -- matching
  the established S562-S575 precedent. Backfilled at Session 577 Phase 0 reconcile: the commit
  itself (`ce8c50a1`, made at S576 close-out) landed with no corresponding `CHANGELOG.md` entry,
  found via the `CHANGELOG.md` frontier (`7b04a911`) trailing `HEAD` by one commit while
  `HANDOFFS.md`'s own frontier had no gap.

### 2026-08-14 · [BL-N] S576: close out (Track 6 design ratified)
- **Deliverable:** Design document ratified via `AskUserQuestion` ("proceed as written").
  `docs/planning/pedigree-diagram-track6-child-centered-union-position-plan.md` DONE. Updated
  `docs/planning/pedigree-diagram-kinship2-fidelity-remediation-plan.md` (new §4 Track 6 entry, §7b
  pointer), `BACKLOG.md` (originating item annotated DESIGN RATIFIED S576; new item filed for the
  residual sibling-subtree-width-asymmetry finding), `PROJECT_LEARNINGS.md` (Learning 582).
  Self-score 8/10; S575 handoff evaluation 8/10. See `HANDOFFS.md` S576 receipt for the full record.

### 2026-08-14 · [BL-N] S576: Track 6 design -- child-centered mating-unit position
- **Deliverable:** Design document for the pedigree-diagram parent-child positioning offset
  (`BACKLOG.md` Housekeeping, found S575). Decided "Extended Candidate A": recompute a mating
  unit's final x from its own children's final x-span instead of its 2 parents; recompute the
  duplicate (non-anchor-parent) node's x from the new union x; broaden the existing de-collision
  pass to cover duplicates (closes a regression the union-only fix alone would introduce, measured
  this session). Validated on the real 375-individual bundled fixture: violating child-edges
  100/251 -> 9/251 (91% reduction), worst-case offset 10,687 -> 4,121 scaled units (61% reduction),
  duplicate-to-union distance mean 62/max 120 -> constant 48. 9 residual edges (3.6%) traced to a
  distinct, out-of-scope phenomenon (sibling subtree-width asymmetry), filed as its own new
  `BACKLOG.md` item. Implementation is a separate future session.

### 2026-08-14 · [ad hoc] S576: claim session (parent-child positioning offset design) (`43dac0f7`)
- **Deliverable:** Phase 1B claim stub written to `SESSION_NOTES.md`/`HANDOFFS.md`.

### 2026-08-14 · [ad hoc] S575: post-close-out correction (2 real findings owner caught in the published artifact)
- **Deliverable:** Owner review of the published comparison artifact identified 2 real issues
  neither Track 5 nor any prior Claim (1-4c) checked: (1) the duplicate-connector dashed arc bows
  concave, opposite kinship2's own convex `arcconnect()` convention; (2) children are frequently
  rendered far from their own parent union -- 100/251 (40%) real-fixture child-edge groups exceed a
  200-unit horizontal offset, 73/251 (29%) exceed 500, max 10,687, root-caused to
  `R/makePedigreeDiagramData.R:924`'s parent-midpoint union-x computation being decoupled from
  child position, compounded by Track 3's per-row `sweepMinSep()`. Corrected the published artifact
  in place (same URL), the remediation plan (`docs/planning/pedigree-diagram-kinship2-fidelity-
  remediation-plan.md` new §7), this session's own `SESSION_NOTES.md`/`HANDOFFS.md` records
  (self-score revised 9 -> 6), and `PROJECT_LEARNINGS.md` (new Learning 581, plus repositioned
  Learning 580 which had been inserted out of order). Filed 2 new `BACKLOG.md` Housekeeping items
  for future dedicated sessions -- neither fixed this session.

### 2026-08-14 · [ad hoc] S575: reconcile HANDOFFS.md commit self-reference (`bb0c9bb2`)
- **Deliverable:** Fixed this session's own `HANDOFFS.md` receipt `commit: pending` ->
  `bb0c9bb2` (the close-out commit whose sha the receipt itself couldn't name until after it was
  made) -- matching the established S562-S574 precedent.

### 2026-08-14 · [ad hoc] S575: close out (Track 5 re-measurement DONE, no gap found)
- **Deliverable:** Evaluated S574's handoff (9/10), self-assessed (9/10), documented
  `PROJECT_LEARNINGS.md` Learning 580 (live/offline cross-validation + structural-proof pattern for
  coverage questions), wrote the full `HANDOFFS.md` receipt.

### 2026-08-14 · [ad hoc] S575: Track 5 re-measurement (no rectilinear routing gap found) (`3c3412af`)
- **Deliverable:** `docs/planning/pedigree-diagram-kinship2-fidelity-remediation-plan.md` §Track 5
  -- re-measured, after Tracks 3-4 landed, how much diagonal-edge residue remains in
  `edgeStyle = "rectilinear"` mode. Cross-validated 3 ways: offline `makePedigreeMatingLayout()` on
  the real 375-individual fixture (0 non-dashed diagonal edges vs. 237 in `direct` mode);
  structural proof from `.addRectilinearWaypoints()`'s D1/D2 loops (coverage guaranteed by
  construction, any pedigree); live `shinytest2`/`chromote` query of the rendered `visNetwork`
  widget matching the offline figures exactly. All 5 tracks of the remediation plan are now
  resolved -- no `.addRectilinearWaypoints()` change was warranted. Mid-session: published a
  direct-vs-rectilinear comparison Artifact at owner request.

### 2026-08-14 · [ad hoc] S575: claim session (Track 5 re-measurement) (`68432947`)
- **Deliverable:** Phase 1B claim stub written to `SESSION_NOTES.md`/`HANDOFFS.md`.

### 2026-08-14 · [ad hoc] S574: reconcile HANDOFFS.md commit self-reference (`98327c27`)
- **Deliverable:** Fixed this session's own `HANDOFFS.md` receipt `commit: pending` ->
  `98327c27` (the close-out commit whose sha the receipt itself couldn't name until after it was
  made) -- matching the established S562-S573 precedent.

### 2026-08-14 · [ad hoc] S574: close out (Track 2 implementation DONE) (`98327c27`)
- **Deliverable:** Evaluated S573's handoff (9/10), self-assessed (9/10), documented
  `PROJECT_LEARNINGS.md` Learning 579, wrote the full `HANDOFFS.md` receipt.

### 2026-08-14 · [ad hoc] S574: downstream updates (NEWS, plan doc, BACKLOG) (`4931ef91`)
- **Deliverable:** `NEWS.Rmd`/`NEWS.md` "Changed:" entry; remediation plan's Track 2 section
  marked DONE with full implementation record, §5 status line updated (only Track 5 remains);
  `BACKLOG.md` Housekeeping item flagging `pb_diagram_legend.png` as a now-stale screenshot
  (found, not fixed, this session).

### 2026-08-14 · [ad hoc] S574: vignette updates for the new default (`6a619ad1`)
- **Deliverable:** Updated `vignettes/a2interactive.Rmd`, `vignettes/articles/colony-manager-
  guide.qmd`, and `vignettes/articles/pedigree-diagram.qmd` (the 3rd found during this session's
  own doc pass, not named in Track 2's own documentation-debt note) -- all default-behavior/
  node-cap prose corrected to match the new rectilinear default.

### 2026-08-14 · [ad hoc] S574: test updates for the default edgeStyle flip (`1db9af90`)
- **Deliverable:** 1 test helper + 13 blocks pinned to `edgeStyle = "direct"` explicitly or
  rewritten to assert the new default, across `test_addRectilinearWaypoints.R`/
  `test_makePedigreeMatingLayout.R`/`test_modPedigree.R`. A 9th gap in
  `test-e2e-pedigree-module.R` found and fixed only after reinstalling the dev package into the
  `renv` library (`PROJECT_LEARNINGS.md` Learning 579).

### 2026-08-14 · [ad hoc] S574: Track 2 implementation (flip default edgeStyle to rectilinear) (`cb5141f7`)
- **Deliverable:** `docs/planning/pedigree-diagram-kinship2-fidelity-remediation-plan.md` §Track 2
  -- `makePedigreeMatingLayout()`'s `edgeStyle` default and `R/modPedigree.R`'s
  `.currentEdgeStyle()` NULL-fallback flipped `"direct"` -> `"rectilinear"` (2-line source diff,
  matching roxygen docstring + regenerated `man/`). Verified: full clean regression 0 failed/0
  error among true offenders; `devtools::check()` 0 errors/0 warnings/1 pre-existing NOTE; 0
  lints; live `shinytest2` verification of all 6 named must-not-regress features (#129/#131/#132/
  #134/#135/#138) against the real bundled fixture (reinstalled dev package), 3.05s timed render.

### 2026-08-14 · [ad hoc] S574: claim session (Track 2 implementation) (`1a81aefd`)
- **Deliverable:** Phase 1B claim stub written to `SESSION_NOTES.md`/`HANDOFFS.md`.

### 2026-08-14 · [ad hoc] S573: reconcile HANDOFFS.md commit self-reference (`21022157`)
- **Deliverable:** Fixed this session's own `HANDOFFS.md` receipt `commit: pending` ->
  `21022157` (the close-out commit whose sha the receipt itself couldn't name until after it was
  made) -- matching the established S562-S572 precedent.

### 2026-08-14 · [ad hoc] S573: close out (Track 4 implementation DONE)
- **Deliverable:** Closed out Track 4 implementation (gen-aware D2 anchor selection, Candidate A)
  of `docs/planning/pedigree-diagram-track4-gen-aware-anchor-plan.md` -- self-assessed 9/10
  (adversarial-verification gap flagged S551-S558 still open on this larger-than-usual
  vertical-slice session; live-verification screenshots too zoomed-out to visually distinguish
  individual multi-anchor nodes, though live-JS-queried coordinates substantively cover the same
  requirement). Evaluated S572's own handoff 9/10 (accurate, executable §6/§7 pointer; zero
  material gaps except an unflagged second-order consequence -- the consanguineous-marker dogleg
  test's own full premise rewrite). Added `PROJECT_LEARNINGS.md` Learning 578 (a committed
  regression test's fixture can outlive the exact scenario it demonstrates once an upstream fix
  closes a defect class structurally; needs a full premise rewrite, not a value update).
  Cross-updated both planning documents (implementation record appended to Track 4's own plan;
  the remediation plan's own Track 4 section and §5 status note) and `BACKLOG.md`'s Candidate C
  item. See `SESSION_NOTES.md` Session 573 entry, `HANDOFFS.md` S573 receipt.

### 2026-08-14 · [ad hoc] S573: Track 4 implementation (gen-aware D2 anchor selection, Candidate A) (GREEN)
- **Deliverable:** `.buildMatingUnitForest()`'s `preferAnchor()` (`R/makePedigreeDiagramData.R`)
  rewritten gen-first (prefers the deeper-gen parent, subsuming founder-preference -- a founder
  always has `gen == 0`), the elimination/`used` shortcut and now-dead `isFounderOf()` removed.
  `.positionMatingUnitForest()`'s `effGenOf` computation and the anchor `dispGenOf` override
  deleted; `positionIndividual()`'s 2 call sites revert to `genOf`. Net simplification: 24
  insertions / 69 deletions. Establishes the structural invariant `matingUnits$gen ==
  genOf[[anchor]]` unconditionally, closing the anchor-side row-mismatch residual issue #144's own
  plan explicitly predicted and left open (51/237 real-fixture mismatches -> 0). PRE-RED:
  prototyped the exact edit directly against live source (stash/rerun precedent), captured the
  full 16-block/43-expectation blast radius, reverted before writing RED tests. New invariant test
  (0 exceptions on the real fixture) plus the 2 residual-acceptance tests at
  `test_positionMatingUnitForest.R:809-893` rewritten to residual-resolved assertions, confirmed
  RED against unmodified source. GREEN: all 16 pre-existing blocks across
  `test_buildMatingUnitForest.R`/`test_positionMatingUnitForest.R`/
  `test_addRectilinearWaypoints.R`/`test_makePedigreeMatingLayout.R` re-derived from live
  implementation output, including a full premise rewrite of the consanguineous-marker
  dogleg-propagation test (its triggering scenario is now structurally unreachable). REFACTOR
  declined (owner-confirmed via `AskUserQuestion` -- the GREEN diff already is the net
  simplification). Measured redistribution on the real fixture: duplicate nodes 128->102 (-20.3%),
  multi-anchor individuals 2->22 (max 5, `WCPXHD`), direct-style nodes 740->714, rectilinear nodes
  1228->1202. Verified: full clean regression 0 failed/0 error; `devtools::check()` 0 errors/0
  warnings/1 pre-existing unrelated NOTE; `lintr::lint_package()` 0 lints on all 5 touched files.
  Phase 3E: live `shinytest2` verification against the real bundled fixture, both `edgeStyle`
  values -- node counts matched exactly, zero diagram-related console errors, 2 screenshots, 4
  multi-anchor individuals live-queried with valid coordinates; the existing 15-test/52-assertion
  live E2E pedigree-module suite passed unchanged. `NEWS.Rmd` entry added (regenerated `NEWS.md`,
  incidentally catching it up on 5 entries already in `NEWS.Rmd` since S563-S571 that had never
  been regenerated). Commit: `f7724917`.

### 2026-08-14 · [ad hoc] S573: claim session (Track 4 implementation)
- **Deliverable:** Claim stub for implementing Track 4 (gen-aware D2 anchor selection, Candidate
  A) of `docs/planning/pedigree-diagram-track4-gen-aware-anchor-plan.md` (ratified S572).
  Owner-picked via `AskUserQuestion` over Track 2 (flip default `edgeStyle`), issue #148's
  scope-narrowing conversation, and the NPRC outreach plan. Commit: `1ebcb006`.

### 2026-08-14 · [ad hoc] S572: reconcile HANDOFFS.md commit self-reference (`c5d2c5a9`)
- **Deliverable:** Fixed this session's own `HANDOFFS.md` receipt `commit: pending` ->
  `c5d2c5a9` (the close-out commit whose sha the receipt itself couldn't name until after it was
  made) -- matching the established S562-S571 precedent.

