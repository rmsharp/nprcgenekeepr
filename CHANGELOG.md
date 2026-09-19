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

### 2026-09-19 · [BL] S718 close-out: pointer-block sweep session records — SESSION_NOTES handoff + S717 evaluation (9/10), HANDOFFS receipt complete, ledger triggers verified not firing
- CI note: the 3 workflows in-flight at orientation on the S717 close-out
  head completed green in-session (test-coverage 12m48s, pkgdown 18m36s,
  R-CMD-check 31m32s; lint was already green), plus the scheduled shinytest2
  run green — 5/5; S717's deliberately-unwatched docs-only CI round is
  closed. FM #28 reduction this session = the deliverable itself (444 lines
  out of `BACKLOG.md`, 1,119 → 675); `methodology_trim.py --check` verified
  the SESSION_NOTES/HANDOFFS/CHANGELOG byte triggers all clear at close-out.
  No new learning appended (routine application of the S686 convention, no
  new signal — stated, not silent, per the S711/S712 precedent). No push
  (owner's call, per the standing convention).

### 2026-09-19 · [BL] S718 deliverable: pointer-block sweep RATIFIED and executed — all 15 `[ ]`-marked-but-fully-RESOLVED blocks removed from `BACKLOG.md` (429 lines, 1,119 → 690)
- Owner ratified "remove all 15" via `AskUserQuestion` (over a keep-S457/S458
  variant and a hold), extending the S686 completed-item convention to the
  S529–S531-era population the S687 item flagged. Verification before the
  gate: every resolving session has dated ledger entries in the CHANGELOG
  corpus (live + `docs/archive/CHANGELOG-*` shards; 3–7 headings each;
  **0 FM #27 gaps** — unlike S529's sweep, which found 2); depth spot-checked
  on the densest block (S565 Track B — the shard entry carries all of the
  block's verification detail); no open sub-threads (the S568 block's
  untitled-folder finding already stands as its own item, which stays); zero
  live cross-references from `CLAUDE.md`/`SESSION_NOTES.md`/`HANDOFFS.md`
  into the population.
- Removed (block → resolving sessions): S508-found HANDOFFS front-matter
  field → S561; `genOf` integer-widening fix → S556; repository branch
  cleanup → S557/S558; kinship2-supplement reproducibility audit + PDF
  classification → S549/S567; twinRelations-into-`kinship()` (3 slices) →
  S551–S553; consanguineous-mating marker + rectilinear propagation →
  S555/S563; kinship2-supplement full-reproduction plan + fidelity article +
  issues #156–#158 → S562/S566; Track A X-chromosome kinship → S564; Track B
  `shrinkPedigree()` → S565; affected-status shading fix → S554; stale
  `pb_diagram_legend.png` regeneration → S560; `pedigree-diagram.qmd`
  article → S560; Compounding-Loop tarball exclusion → S568; Option-2
  feasibility pointer → S457; Option-2 design pointer → S458.
- Deletion executed by a guarded line-range script (first/last-line anchors
  verified on every range before writing; diff confirmed deletion-only,
  429 deletions / 0 insertions). Full block text remains recoverable at the
  pre-sweep tree, commit `f058a8de` (`git show f058a8de:BACKLOG.md`). The
  completed sweep item itself (S687) is removed in this same commit per the
  convention. The 18 genuinely-open `[ ]` items are untouched; the
  borderline S518 BACKLOG-compression item was excluded as a
  recurring-maintenance item per its own S606 correction.

### 2026-09-19 · [BL] S718 claim: pointer-block sweep ratification + (if ratified) execution (BACKLOG Housekeeping item, owner-picked via `AskUserQuestion` at Phase 0)
- Docs-only maintenance session, no TDD phases (S686/S687 precedent). Plan:
  inventory the S529–S531-era `[ ]`-marked-but-fully-RESOLVED pointer blocks
  in `BACKLOG.md`, verify each has a complete `CHANGELOG.md` (or archive-shard)
  record, present the concrete population at the ratification gate, then — if
  ratified — apply the S686 4-step relocation (verify/enrich ledger,
  forward-carry live context, extract open sub-threads, delete). Stub +
  pending receipt committed with this entry.

### 2026-09-19 · [ad hoc] Backfilled (reconcile-on-read): undocumented commit `4cfe2dad` — S717's close-out self-reference commit (recorded the records-commit sha in its own `HANDOFFS.md` receipt), the documented recurring 1-commit shape; backfilled by the next session's Phase 0 reconcile

### 2026-09-19 · [ad hoc] S717 close-out: push to `origin/master` DONE — 33 commits (`1788e2b8..047d7f74`), all 4 CI workflows green on the pushed head
- First remote validation of the S715 curved-connector arc-verified
  roundness fix and the S716 MHC display rounding (plus the S712–S714
  census assessments and five sessions of records). CI on `047d7f74`:
  lint 4m41s, test-coverage 10m26s, pkgdown 18m40s, R-CMD-check 34m16s
  (run ids 35425960304/340/312/299), all `completed success` — watched to
  completion in-session via a 2-min poller, then confirmed directly via
  `gh run list`. The records + self-reconcile commits that follow are
  pushed immediately; their own docs-only CI round is verified at the next
  session's unconditional Phase 0 CI check (S706/S711 precedent).

### 2026-09-19 · [ad hoc] S717 claim: owner-directed push to `origin/master` (S716 next-step A, owner-picked via `AskUserQuestion` at Phase 0)
- Process/ops session, no TDD phases (S711 precedent): push the ~33 pending
  commits (S712–S716, incl. real package code — the S715 curved-connector
  fix and the S716 MHC display rounding, both never yet seen by CI), then
  watch all 4 on-push workflows to completion. Claim made BEFORE the push
  so the pushed head carries the session's own breadcrumb. Stub + pending
  receipt committed with this entry.

### 2026-09-19 · [ad hoc] Backfilled (reconcile-on-read): undocumented commit `b229a305` — S716's close-out self-reference commit (recorded the records-commit sha in its own `HANDOFFS.md` receipt), the documented recurring 1-commit shape; backfilled by the next session's Phase 0 reconcile

### 2026-09-18 · [BL] S716 close-out: MHC Haplotype Reporting polish DONE — display-only 4-decimal frequency rounding, `@return` rewritten, NEWS stale-phrase sweep + heading repair, article screenshot re-captured
- **Deliverable (strict TDD for the code part, every gate owner-approved via
  `AskUserQuestion`; BACKLOG item removed in this commit):**
  `output$mhcSummaryTable` (`R/modMarkerGenetics.R:1170`) now renders
  `DT::formatRound(DT::datatable(tbl), "frequency", digits = 4L)` — a
  client-side display renderer gated on `type !== 'display'`, so the
  `mhcHaplotypeSummaryTable` reactive, the CSV export, and DT's own
  sorting/filtering keep full precision. RED `27d06c97` (3 formatter
  grepls failing at HEAD for the right reason + reactive-identity and
  pre-upload pins), GREEN `dbd68126` (3-line edit). REFACTOR judged
  unnecessary at the owner-approved GREEN exit gate.
- **Docs (owner-scoped pre-RED):** `modMarkerGeneticsUI()` `@return`
  rewritten to the real 8-sub-tab UI (`c4fb69f3`, `document()`
  scope-checked); NEWS.Rmd sweep removed all 8 verified-stale "no Shiny
  screen yet" phrases (owner-ratified beyond the 2 the item named; the 2
  accurate ones stay) and repaired 2 pre-existing swallowed section
  headings (`## MHC Haplotype Reporting`, `## Genetic Value Analysis`
  rendered as literal `\##` for want of a preceding blank line); NEWS
  plain-language entry for the rounding (`37d17a55`); colony-manager-guide
  MHC screenshot re-captured live at the original framing (`476372e6`) —
  re-obligated by this session's own display change.
- **Verification:** full clean regression 2,437 blocks 0 failed / 0 error
  (+1 = the new test block; warnings 40 unchanged);
  `lintr::lint_package()` 0; wordlist/moduleContract/pkgdown guards green;
  Phase 3E live smoke: all rendered page-1 frequency cells exactly 4
  decimals, no module console errors; full MHC e2e green under
  `NPRC_RUN_E2E=true` incl. the full-precision CSV download pins;
  `devtools::check()` 0 errors + the known pre-existing 1 W / 1 N
  untracked-file artifacts. Learning 765 appended (DT 0.34.0 formatX
  seam + the NEWS render-diff/`\##` reflex + the e2e opt-in corollary).

### 2026-09-18 · [BL] S716 claim: MHC Haplotype Reporting follow-up polish (BACKLOG Housekeeping item, issue #148 Slice 4 close-out; owner-picked via `AskUserQuestion` at Phase 0)
- Three-part polish, strict TDD for the code part: (1) display-only rounding of
  the `frequency` column in `output$mhcSummaryTable` (`R/modMarkerGenetics.R`;
  the `mhcHaplotypeSummaryTable` reactive and the export stay untouched — tests
  pin those exactly), (2) `modMarkerGeneticsUI()`'s `@return` updated to cover
  the tabs shipped by #148 Slice 4 / #152 / #153, (3) the two stale "no Shiny
  screen yet" `NEWS.Rmd` phrases fixed + `NEWS.md` re-rendered (plain-language
  criterion). Stub + pending receipt committed with this entry.

### 2026-09-18 · [ad hoc] Backfilled (reconcile-on-read): undocumented commit `56c705b8` — S715's close-out self-reference commit (recorded the records-commit sha in its own `HANDOFFS.md` receipt), the documented recurring 1-commit shape; backfilled by the next session's Phase 0 reconcile

### 2026-09-18 · [BL] S715 close-out: curved duplicate-connectors FIXED — arc-verified roundness selection ships; cArc 587 → 149 events, 117 → 72 arcs; exemplar + Track C warnings cleared, owner-ratified renders
- **Deliverable (strict TDD, every gate owner-approved via `AskUserQuestion`;
  BACKLOG item removed in this commit):** `.resolveEdgeNodeCollisions()`'s
  curved branch (`R/makePedigreeDiagramData.R`) now scores each connector's
  PAINTED arc for TRUE disc hits — `.curvedCwVia()` (the S714-verified
  vis-network `curvedCW` transcription), `.bezierPointAt()`,
  `.bezierMinDistTo()` (exact cubic solve), `.arcDiscHitCount()` (a
  conservative Lipschitz-bound sampled prefilter keeps the exact solve to
  near-boundary candidates; counts provably unchanged, resolve
  0.21 → 0.95 s instead of +4.4 s unoptimized) — and walks the roundness
  ladder `seq(0.05, 0.60, 0.05)` in preference order (fewest true hits,
  tie → closest to base 0.2, tie → smaller). `curved-heuristic` residuals
  now disclose exactly the arcs no step fully clears. RED `d39c66eb`
  (7 assertions failing for the right reasons, incl. the never-worse
  property the old bump measurably violated), GREEN `704d7c4c`.
- **Verification:** target file + exemplar file green; full clean
  regression 2,436 blocks, 0 failed / 0 error (warnings 48 → 40 = the
  cleared collision warnings); `lintr::lint_package()` 0;
  `devtools::check()` 0 errors + the known pre-existing 1 W / 1 N
  untracked-local-file artifacts; census re-run `69152999` (postfix CSV;
  frozen 2026-09-02 and 2026-09-18 baselines untouched): **cArc
  587 → 149 events, cArcEdges 117 → 72; Track C fully arc-clean; class
  (b) = 6 unchanged**, so the fidelity article's "6 of 237" is NOT
  re-obligated. Test pins re-derived: residuals 56 → 72 (the true
  population, no longer chord false positives), the S690 named pair
  `__dup_1X40V5_1 → 1X40V5` now pins UNCHANGED 0.2 (it was a false
  positive), `__dup_0L5AWR_1 → 0L5AWR` pins cleared-at-0.5 (6 → 0 hits).
- **Exemplar warning pins (owner-ratified at the GREEN gate, per the
  S693 pin's own re-render rule):** linebreeding + half_sib now render
  warning-free (their 4 pinned residuals = 1 chord false positive + 3
  true collisions, all cleared by the ladder);
  `test_examplePedigreeFixtures.R` specs flipped, renders
  `scratchpad/s715_render_{linebreeding,half_sib}_after.png` approved.
- **Incidental (`fa4ec9ad`):** S714's article edit left
  `test_wordlist_coverage.R` failing on `px` (that session touched no
  package files and carried the baseline forward — the carried-baseline
  heuristic has a hole for `.qmd`-fed tests, Learning 764); fixed via
  `inst/WORDLIST` per the S564/S565 precedent. NEWS.Rmd plain-language
  entry + NEWS.md render in `69152999`.
- **Runtime evidence (Phase 3E):** live chromote renders through the
  app's own widget construction (the S712/S714 verified path) — 2
  exemplar full views + Real-375 before/after site crops
  (`scratchpad/s715_render_site_0L5AWR_{before,after}_zoom.png`).

### 2026-09-18 · [BL] S715 claim: curved duplicate-connectors fix — arc-verified roundness selection replacing the blind +0.3 bump
- Session claimed (stub + pending receipt + this entry). Owner picked the
  S714-filed BACKLOG Housekeeping item via the Phase 0 `AskUserQuestion` picker.
  Scope: `.resolveEdgeNodeCollisions()`'s curved branch
  (`R/makePedigreeDiagramData.R`) gains arc-verified roundness selection using
  the census's exact predicates (ported as internal helpers); strict TDD;
  `test_resolveEdgeNodeCollisions.R` pins re-derived; census re-run + full
  suite + lint at verification.
- **Ledger repair (ad hoc, disclosed):** removed a 5-line truncated duplicate
  S713 receipt header (an unclosed ` ```handoff ` fence, no unique content)
  that S714's records commit `8c717ee6` accidentally inserted into
  `HANDOFFS.md` between the S714 prose and the real S713 receipt.

### 2026-09-18 · [ad hoc] Backfilled (reconcile-on-read): undocumented commit `0b4d84bb` — S714 close-out self-reference
- S714's final commit recorded its own records-commit sha (`8c717ee6`) into the
  `HANDOFFS.md` receipt after the ledger entry was written — the recurring
  self-reconcile shape (predicted "~1" by the S714 handoff; measured 1).
  Backfilled at Session 715 Phase 0.

### 2026-09-18 · [BL] S714 close-out: curved-chord upper bound REPLACED by the true arc census — 1,668 chord rows were 100% false positives; real population 587 events / 117 arcs; fix item ratified and filed
- **Deliverable (`318c32da`; curved-chord BACKLOG block replaced by the ratified
  fix item in this commit):** the census now measures the arc vis-network
  actually paints. The `curvedCW` via formula was transcribed from the bundled
  `vis-network.min.js` and verified against the LIVE widget via chromote
  (`edgeType.getViaNode()`): max |via(model) − via(live)| = 1.1e-13 px over all
  173 curved edges, per-edge roundness overrides (0.2 / bumped 0.5) confirmed
  applied. Exact point-to-quadratic distances (cubic root solve), no sampling.
- **Findings (audit doc `docs/audits/PEDIGREE_DRAWING_CURVED_ARC_CENSUS_
  2026-09-18.md`):** (1) overlap join: 0 of the frozen 1,667+1 chord pairs are
  true hits — the arc bows over every same-row chord obstacle; (2) the true
  population, 587 events on 117 of 170 Real-375 connectors (Track C arc-clean),
  sits entirely where no predicate ever looked: 485 events on cross-row
  connectors (`c1` was same-row-only, `c2` skipped curved), 102 from bumped arcs
  crossing upper rows; median penetration 10.9 px of a 25-px radius; (3) the
  repair pass's blind +0.3 roundness bump is net-negative on Real 375 (21 arcs
  hit at 0.2 → 24 at the shipped 0.5); (4) incidental: vis-network
  parseInt-truncates predefined node coordinates — counts stable under that
  quantization (587→586 events, 117 arcs in every ±1-px jitter draw)
  (Learning 763). Census script extended (`c-arc-inside`, scoreboard
  `cArc`/`cArcEdges`, chord subclass retired, lint 0, post-lint re-run
  byte-identical); new baseline CSV
  `docs/audits/PEDIGREE_DRAWING_ERROR_CENSUS_2026-09-18_findings.csv` (595
  rows); frozen 2026-09-02 artifacts untouched.
- **S713 forward-carry discharged:** the re-run reports class (b) = 6 (first
  post-S713 confirmation of the ratified dust floor); the fidelity article's
  mate-line paragraph now cites 6 of 237 (`vignettes/articles/
  kinship2-fidelity-validation.qmd`), the caveats bullet verified count-free,
  Track B centering re-verified (b = 0 on both Track B fixtures).
- **Owner gate (recommended option taken):** fix item filed — arc-verified
  roundness selection replacing the blind bump (BACKLOG, READY, Effort M,
  strict TDD; full brief in the block, incl. which
  `test_resolveEdgeNodeCollisions.R` pins re-derive). Corpus sweep: the test
  comments' "47" figures are frozen CHANGED-history (live pin 56L, correct);
  the only stale live "47" was in the removed BACKLOG block.

### 2026-09-18 · [BL] S714 claim: census curved-chord arc-modelling measurement pass
- BACKLOG Housekeeping "Census curved-chord heuristic" item (S713 next-step A),
  owner-picked via `AskUserQuestion` at Phase 0. Deliverable: model the
  actually-drawn arc geometry (render layer's curved connectors + the roundness
  bump applied to duplicate connectors) and count how many drawn arcs truly pass
  inside a visible unrelated symbol — replacing the 1,667 Real-375 + 1 Track C
  `c-curved-chord` chord-heuristic upper bound — reproducibly, by extending
  `data-raw/pedigreeDrawingErrorCensus.R` or a committed sibling script; then
  recommend whether a fix item is warranted. Carries the S713 forward-carry
  (article "8 of 237" sites + Track B centering) if a census re-run lands.
  Measurement/scoping session, no TDD phases unless package code turns out to be
  touched. Stub + pending receipt written with this entry.

### 2026-09-18 · [ad hoc] Backfilled (reconcile-on-read): undocumented commit 35a33905 — S713 close-out self-reconcile
- S713's final commit recorded its own close-out commit sha (`f67830a1`) into the
  completed `HANDOFFS.md` receipt — the recurring self-reference shape S713's own
  handoff predicted (gotcha 4, "expect ~1"). Measured: exactly 1 commit past the
  frontier. No other action in the gap.

### 2026-09-18 · [BL] S713 close-out: census class (b) CLOSED — 6 real rows accepted as minSep-forced structural residuals, 2 dust rows ratified out of the predicate (both owner-ratified)
- **Deliverable (BACKLOG "Census class (b)" block removed in this commit):** the
  census's 8 class-(b) rows are fully dispositioned. The **6 real 60–180 px rows**
  (`__union_97/114/130/137/191/228`) are **accepted as structural residuals, no fix
  item**; the **2 numerical-noise rows** (`__union_75` ≈ 2.8e-5 px, `__union_132`
  ≈ 1.0e-6 px) are solver dust, and the census predicate now skips below the test
  suite's own 1e-3 raw-unit (0.12 px) meaningful floor
  (`data-raw/pedigreeDrawingErrorCensus.R`, commit `de4e6ce8`) so future runs report 6.
  The frozen 2026-09-02 census CSV is untouched (audit record; closure lives here).
- **Evidence — forced vs reducible (the item's own question), both instruments
  agreeing (`scratchpad/s713_probe.R`/`s713_probe2.R`, results in
  `scratchpad/s713_probe_results.rds`):** (1) binding-chain analysis: every
  adjacent pair between each of the 6 unions' rendered mates is BINDING at its
  floor, and the chain-implied minimum offset given the solved mate span equals the
  observed offset exactly (0.5/0.5/1.0/1.5/1.0/0.5 raw units) — marry-in-chain /
  polygamous-anchor crowding (WCPXHD's 5-unit chain, HV7LZ3's 3-unit anchor);
  (2) wUnion sweep 2 → 2e5 on trace()-captured QP inputs (target component: 733
  variables): offsets shrink only by stretching mate spans (`__union_137`
  480 → 1,787 px; `__union_130` 360 → 834 px) — i.e. **minSep-forced at the
  owner-ratified S675 weights**; centering by weight escalation degrades the layout
  and would contradict the no-weight-tuning mandate. The 6 are already disclosed,
  named, and bounded (≤ 1.55 u) by the committed structural-residual test
  (`tests/testthat/test_positionMatingUnitForest.R`, Learning 726 pattern), whose
  own comment reads "8 rows of which 2 dust = 6 meaningful" — the predicate change
  aligns the census with that same dust line (Learning 762).
- **Continuity:** frozen census reproduced to the digit from `s712_layouts.rds`
  (max |diff| ≈ 2e-15 u on all 8 rows) and from a fresh current-engine run (6 real
  rows to 1e-12) before any counterfactual was trusted. Predicate edit verified:
  old skip reproduces the frozen 8 on the current layout; new floor yields exactly
  the disclosed 6, dropping exactly the 2 dust rows. `lintr::lint_package()` (loaded
  per Learning 224): 0 lints. Crops of all 4 neighbourhoods
  (`scratchpad/s713_crop_*.png`): each "off-centre" dot sits adjacent to its distal
  marry-in mate — the conventional multiple-marriage-chain rendering.
- **Coupled prose re-verified (no edit owed now):** Track B "all four union dots
  exactly centered" re-measured live (max residual 1.9e-11 px); the article's
  "8 of 237 ... where the separation floors bind" stays accurate as a citation of
  the standing frozen baseline — the count becomes 6 only at the next census
  re-run, an obligation forward-carried into the curved-chord BACKLOG item.

### 2026-09-18 · [BL] S713 claim: census class (b) off-centre union-dot assessment
- S712 next-step A / BACKLOG "Census class (b)" item, owner-picked via
  `AskUserQuestion` at Phase 0. Deliverable: (i) decide whether the 2
  numerical-noise rows (`__union_75` −2.3e-07 units, `__union_132` 8.7e-09 units)
  belong in the census (the visible-offset tolerance question for the census
  predicate); (ii) determine whether the 6 real 60–180 px offsets
  (`__union_97/114/130/137/191/228`) are minSep-forced or QP-reducible
  (`R/makePedigreeDiagramData.R`, `.solveJointQP()`); (iii) re-verify the coupled
  fidelity-article prose ("8 of 237", 0.00-px Track B centering). Assessment
  session. Stub + pending receipt written with this entry.

### 2026-09-18 · [ad hoc] Backfilled (reconcile-on-read): undocumented commit ed79261f — S712 close-out self-reconcile
- S712's final commit recorded its own close-out commit sha into the completed
  `HANDOFFS.md` receipt (the recurring 1-commit self-reference shape its handoff
  gotcha 4 predicted; measured exactly 1). Backfilled at S713 Phase 0 reconcile.

### 2026-09-18 · [BL] S712 close-out: census class (d) CLOSED — both duplicate-adjacent sites assessed acceptable (owner-ratified)
- **Deliverable (this commit; BACKLOG "Census class (d)" block removed in it):** the
  census's 2 class-(d) "adjacent" rows (`docs/audits/PEDIGREE_DRAWING_ERROR_CENSUS_
  2026-09-02_findings.csv` rows 3 and 1679 — the CSV itself is a frozen audit record,
  unchanged) are **closed as visually acceptable**, owner-ratified via
  `AskUserQuestion` with all 6 crops presented.
- **Evidence:** fresh current-engine layouts of both fixtures (default rectilinear;
  `scratchpad/s712_probe.R`, cached at `scratchpad/s712_layouts.rds`) reproduce the
  census to the digit — Track C `__dup_Y_2`/`Y` dx = 120.0 px exactly, Real 375
  `__dup_SLN0TF_2`/`SLN0TF` dx = 119.9999999992 px; both pairs same-row with ZERO
  nodes strictly between; the dashed duplicate-connector is present in the edge frame
  at both sites. Crops (100% / 2.2x / context per site, Learning 732 recipe,
  `scratchpad/s712_crop_*.png`): Track C plainly legible (70-px rim gap, connector
  visible); Real 375 structurally identical, its short connector visually obscured
  only by unrelated long-range dashed chords — the class-(c) curved-chord density
  issue tracked in its own BACKLOG item, not an adjacency defect.
- **Rationale for acceptance:** adjacent-at-minSep (1 raw unit = 120 px, the engine's
  own same-row minimum) is the same spacing as any other adjacent pair on the row;
  the overlap subclass (< 50 px) has count 0; adjacency minimizes duplicate-connector
  length, and added separation would lengthen the connector and feed the very class-c
  clutter that is the only legibility concern observed. No separation follow-up
  scoped. Coupled-prose check: `vignettes/articles/kinship2-fidelity-validation.qmd`
  contains zero class-(d)/"adjacent" references (grep-verified), so no prose update
  was owed.
- **Also closed in-session:** S711's open CI loop — R-CMD-check on the S711
  close-out head completed green (run 35390065689, 33m33s; that head is now 4/4).

### 2026-09-18 · [BL] S712 claim: census class (d) duplicate-adjacent assessment
- S711 next-step A / BACKLOG "Census class (d)" item, owner-picked via
  `AskUserQuestion` at Phase 0. Deliverable: render the 2 duplicate-adjacent sites
  (`__dup_Y_2` vs `Y`, Track C; `__dup_SLN0TF_2` vs `SLN0TF`, Real 375) as crops,
  verify local geometry programmatically, judge acceptability, and close the item
  with a dated note or scope a follow-up. Stub + pending receipt written with this
  entry.

### 2026-09-18 · [ad hoc] Backfilled (reconcile-on-read): undocumented commit 1788e2b8 — S711 close-out self-reconcile
- S711's final commit recorded its own close-out commit sha into the completed
  `HANDOFFS.md` receipt (the recurring 1-commit self-reference shape its handoff
  gotcha 3 predicted; measured exactly 1). Backfilled at S712 Phase 0 reconcile.

### 2026-09-18 · [ad hoc] S711 close-out: owner-directed push DONE — 34 commits to origin/master, all 4 CI workflows green
- **Push (non-commit action):** `955f6f19..afd33514`, 34 commits (32 at session start
  + Phase 0 backfill `83618479` + claim `afd33514`), spanning S708 MHC Slice 4, the
  S709 export-preview crash fix, and the S710 ledger archive pass. Claim was committed
  BEFORE the push so the pushed head carries the session's own breadcrumb.
- **Outcome:** all 4 on-push workflows green on `afd33514` — lint 5m43s,
  test-coverage 9m58s, pkgdown 16m52s, R-CMD-check 33m22s (runs
  35386636842/35386636857/35386636853/35386636874); watched to completion in-session,
  then re-verified via `gh run list` before recording. Close-out records + the
  self-reconcile sha commit are pushed immediately after this entry (second push);
  that round's verification belongs to the next session's unconditional Phase 0 CI
  check (S706 precedent). Docs-only local changes; runtime smoke n/a — the
  deliverable's verification IS the CI matrix on real runners.

### 2026-09-18 · [ad hoc] S711 claim: owner-directed push of local master to origin/master
- S710 next-step A, owner-picked via `AskUserQuestion` at Phase 0. 33 commits ahead at
  claim (32 at session start + the Phase 0 backfill `83618479`); the claim commit
  itself makes 34. Deliverable: push, then verify the 4 on-push CI workflows
  (R-CMD-check / lint / pkgdown / test-coverage) green and record the outcome.
  Stub + pending receipt written with this entry.

### 2026-09-18 · [ad hoc] Backfilled (reconcile-on-read): undocumented commit 0f7f94fe — S710 close-out self-reconcile
- S710's final commit recorded its own close-out commit sha into the completed
  `HANDOFFS.md` receipt (the recurring 1-commit self-reference shape its handoff
  gotcha 5 predicted; measured exactly 1). Backfilled at S711 Phase 0 reconcile.

### 2026-09-18 · [ad hoc] S710 close-out: ledger archive pass DONE — all three byte triggers cleared
- **Deliverable (trims `7fbe17b7`/`3dbe15f3`/`447f2beb`):** S709 next-step A. All three
  ledger files trimmed into `docs/archive/*-through-2026-09-18.md` shards, L1/L2/L3
  verified by each shard's own `verify.sh`: `SESSION_NOTES.md` 87,984 → 4,771 B
  (19 records), `HANDOFFS.md` 78,503 → 16,481 B (13 receipts, never zero),
  `CHANGELOG.md` 68,117 → 9,471 B (40 records, trimmed last so the two earlier
  trim-injected entries landed inside its cut). Final `--check` on all three: no
  trigger fires.
- **Findings:** the default cut on every file collided with the existing
  `-through-2026-09-17` shards (S704–S708 all share that date) — legal retained counts
  were quantized (SESSION_NOTES ≥15 or ≤2; HANDOFFS ≤2; CHANGELOG ≤8) and probed with
  dry-run `--cut N` before any write (Learning 761). The predicted small-denominator
  SRF refusals (Learnings 549/586/594) never fired — no `--force`, no owner gate
  needed. Docs-only; no package files touched; runtime smoke n/a.

### 2026-09-18 · [ad hoc] Ledger trim: `CHANGELOG.md` → `docs/archive/CHANGELOG-through-2026-09-18.md` (40 record(s), 68,117 B → 9,471 B)

**Written by:** `methodology_trim.py` v1.1.2 — a tool action, not a session's judgment.
Moved the oldest **40** record(s) (2026-09-17 → 2026-09-18) out of [`CHANGELOG.md`](CHANGELOG.md) into
[`docs/archive/CHANGELOG-through-2026-09-18.md`](docs/archive/CHANGELOG-through-2026-09-18.md). Losslessness is asserted by L1 (records-zone concatenation), L2 (zone
pinning) and L3 (record partition), and is **re-derivable** — run [`docs/archive/CHANGELOG-through-2026-09-18.md.verify.sh`](docs/archive/CHANGELOG-through-2026-09-18.md.verify.sh)
rather than trusting a digest printed here. Live file 68,117 B → 9,471 B (−86.1%).

### 2026-09-18 · [ad hoc] Ledger trim: `HANDOFFS.md` → `docs/archive/HANDOFFS-through-2026-09-18.md` (13 record(s), 78,503 B → 16,481 B)

**Written by:** `methodology_trim.py` v1.1.2 — a tool action, not a session's judgment.
Moved the oldest **13** record(s) (2026-09-17 → 2026-09-18) out of [`HANDOFFS.md`](HANDOFFS.md) into
[`docs/archive/HANDOFFS-through-2026-09-18.md`](docs/archive/HANDOFFS-through-2026-09-18.md). Losslessness is asserted by L1 (records-zone concatenation), L2 (zone
pinning) and L3 (record partition), and is **re-derivable** — run [`docs/archive/HANDOFFS-through-2026-09-18.md.verify.sh`](docs/archive/HANDOFFS-through-2026-09-18.md.verify.sh)
rather than trusting a digest printed here. Live file 78,503 B → 16,481 B (−79.0%).

### 2026-09-18 · [ad hoc] Ledger trim: `SESSION_NOTES.md` → `docs/archive/SESSION_NOTES-through-2026-09-18.md` (19 record(s), 87,984 B → 4,771 B)

**Written by:** `methodology_trim.py` v1.1.2 — a tool action, not a session's judgment.
Moved the oldest **19** record(s) (2026-08-14 → 2026-09-18) out of [`SESSION_NOTES.md`](SESSION_NOTES.md) into
[`docs/archive/SESSION_NOTES-through-2026-09-18.md`](docs/archive/SESSION_NOTES-through-2026-09-18.md). Losslessness is asserted by L1 (records-zone concatenation), L2 (zone
pinning) and L3 (record partition), and is **re-derivable** — run [`docs/archive/SESSION_NOTES-through-2026-09-18.md.verify.sh`](docs/archive/SESSION_NOTES-through-2026-09-18.md.verify.sh)
rather than trusting a digest printed here. Live file 87,984 B → 4,771 B (−94.6%).

### 2026-09-18 · [ad hoc] S710 claim: ledger archive pass — trim SESSION_NOTES.md, HANDOFFS.md, and CHANGELOG.md
- Session claimed (stub + pending HANDOFFS receipt + this entry, one commit). S709
  next-step A, owner-picked via `AskUserQuestion` at Phase 0: all three ledger byte
  triggers fire (`SESSION_NOTES.md` 87,140 B, `HANDOFFS.md` 78,117 B, `CHANGELOG.md`
  65,829 B — it crossed its 65,536 B budget with this session's own Phase 0 backfill).
  Run `methodology_trim.py --write` per file with L1/L2/L3 losslessness verification;
  any small-denominator SRF refusal goes to the owner via `AskUserQuestion` before a
  `--force` (Learnings 549/586/594). Docs-only maintenance; no TDD phases apply.

### 2026-09-18 · [ad hoc] Backfilled (reconcile-on-read): undocumented commit `710fea78` — S709's own close-out self-reference commit
- S710 Phase 0 ledger reconcile. The one commit past the frontier (`33b0a556`) is
  S709's final close-out write, which by construction lands after its CHANGELOG entry:
  `710fea78` (close-out commit sha recorded in the HANDOFFS receipt, self-reconcile).
  S709's gotcha 5 predicted about 1 self-reference commit; it measured as exactly 1.

### 2026-09-18 · [BL-Up-Next] S709 close-out: export-preview session-crash fix DONE — the Marker Genetics observers survive missing pedigree ids and failed-validation uploads
- **Deliverable (RED `cd63250c`, GREEN `310c731d`, NEWS `76807b2a`+`61c544a3`):** the top
  BACKLOG Up Next item (found S708). Every upstream read inside the LD-block, sequence,
  and MHC export-preview observers in `R/modMarkerGenetics.R` now goes through
  `safeRead()` + `req()`, so a malformed upload's validation error or an erroring
  `pedigree()` aborts the preview quietly instead of ending the user's session (Learning
  758); the sequence observer ports the MHC tab's Dragon 5 pre-check
  (`sequenceExportMissingIds`: build nothing, show the count + alias-map precondition in
  the guidance); the three guidance renderUIs name the could-not-be-processed state.
  Strict TDD, all gates owner-approved via `AskUserQuestion` (3 PRE-RED approach
  decisions, PRE-RED→RED, RED→GREEN, GREEN→skip-REFACTOR-and-close-out).
- **Two evidence-driven scope rulings (owner-ratified):** the LD-block missing-id
  pre-check was deliberately NOT ported — `markerLdBlock()` subsets its matrix to
  `founderIds` drawn from the same pedigree (`R/markerLdBlock.R:236`), so `idsUsed` can
  never carry a non-pedigree id and the branch would be untestable dead code; and the
  RED tests exposed a SECOND, unknown crash path fixed in the same GREEN — the module's
  eager E2E data-ready `observe()` re-threw a malformed shared upload's validation error
  with no export click at all (Learning 759).
- **Verification:** fresh pre-change baseline 2,405→S708-shape reproduced (2,427 blocks,
  failed=0). RED honest: 5 new `testServer` blocks fail via `shiny.destroyed.error`
  (Learning 759's refinement: the destroyed module session IS directly assertable),
  1 guard passes by design; the new live E2E reproduced the disconnect on the real tab
  pre-fix (`Shiny.shinyapp.isConnected()` FALSE). GREEN: target file 66/66; both live
  E2E tests pass (Phase 3E smoke — session survives, guidance shows the reason,
  pre-existing full export flow unchanged); package-loaded lint 0; full suite once on
  final source 2,434 blocks = baseline + the 7 new, failed=3 all triaged (2 wall-clock
  benchmarks green on quiet re-run — CPU contention, Learning 760; 1 spelling fixed by
  rewording the NEWS entry, re-run green); `devtools::check()` 0 errors, 1 W + 1 N both
  the known untracked-local-file artifacts. Learnings 759/760 appended; BACKLOG item
  removed.

### 2026-09-18 · [BL-Up-Next] S709 claim: fix the LD-block/Genomic ROH export-preview session-disconnect crash
- Session claimed (stub + pending HANDOFFS receipt + this entry, one commit). Top BACKLOG
  Up Next item (found S708): both existing export observers in `R/modMarkerGenetics.R`
  call de-identification primitives that `stop()` inside `observeEvent()`, which
  disconnects a live Shiny session (Learning 758); port the MHC tab's
  `mhcExportMissingIds` pre-check to `ldBlockExportPreview` and `sequenceExportPreview`,
  and fold in the MHC malformed-upload residual. Strict TDD. Close-out entry follows at
  Phase 3F.

### 2026-09-18 · [ad hoc] Backfilled (reconcile-on-read): undocumented commit `cc540bf3` — S708's own close-out self-reference commit
- S709 Phase 0 ledger reconcile. The one commit past the frontier (`6b008487`) is
  S708's final close-out write, which by construction lands after its CHANGELOG entry:
  `cc540bf3` (close-out commit sha recorded in the HANDOFFS receipt, self-reconcile).
  S708's gotcha 5 predicted about 1 self-reference commit; it measured as exactly 1.

### 2026-09-18 · [issue #148] S708 closed issue #148 on GitHub (all 4 slices shipped)
- `gh issue close 148 --reason completed` with a comment listing the four slices' commits
  and S708's verification evidence (closed 2026-09-18T05:23:31Z,
  https://github.com/rmsharp/nprcgenekeepr/issues/148). Non-commit action, per the issue
  close-out checklist (close in the same session the last BACKLOG item ships).

