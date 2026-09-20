# Session Notes

**Purpose:** Continuity between sessions. Each session reads this first and writes to it before closing out.

**Archived 612 record(s), 1998-12-06 → 2026-08-12** into [`docs/archive/SESSION_NOTES-through-2026-08-12.md`](docs/archive/SESSION_NOTES-through-2026-08-12.md) — same format, same order, frozen.
Losslessness is proved by [`docs/archive/SESSION_NOTES-through-2026-08-12.md.verify.sh`](docs/archive/SESSION_NOTES-through-2026-08-12.md.verify.sh), which re-derives L1/L2/L3 from git; run it rather
than trusting this sentence. Written by `methodology_trim.py` v1.1.2.

**Archived 40 record(s), 2026-08-11 → 2026-08-13** into [`docs/archive/SESSION_NOTES-through-2026-08-13.md`](docs/archive/SESSION_NOTES-through-2026-08-13.md) — same format, same order, frozen.
Losslessness is proved by [`docs/archive/SESSION_NOTES-through-2026-08-13.md.verify.sh`](docs/archive/SESSION_NOTES-through-2026-08-13.md.verify.sh), which re-derives L1/L2/L3 from git; run it rather
than trusting this sentence. Written by `methodology_trim.py` v1.1.2.

**Archived 76 record(s), 2026-01-26 → 2026-08-15** into [`docs/archive/SESSION_NOTES-through-2026-08-15.md`](docs/archive/SESSION_NOTES-through-2026-08-15.md) — same format, same order, frozen.
Losslessness is proved by [`docs/archive/SESSION_NOTES-through-2026-08-15.md.verify.sh`](docs/archive/SESSION_NOTES-through-2026-08-15.md.verify.sh), which re-derives L1/L2/L3 from git; run it rather
than trusting this sentence. Written by `methodology_trim.py` v1.1.2.

**Archived 170 record(s), 2026-08-19 → 2026-09-17** into [`docs/archive/SESSION_NOTES-through-2026-09-17.md`](docs/archive/SESSION_NOTES-through-2026-09-17.md) — same format, same order, frozen.
Losslessness is proved by [`docs/archive/SESSION_NOTES-through-2026-09-17.md.verify.sh`](docs/archive/SESSION_NOTES-through-2026-09-17.md.verify.sh), which re-derives L1/L2/L3 from git; run it rather
than trusting this sentence. Written by `methodology_trim.py` v1.1.2.

**Archived 19 record(s), 2026-08-14 → 2026-09-18** into [`docs/archive/SESSION_NOTES-through-2026-09-18.md`](docs/archive/SESSION_NOTES-through-2026-09-18.md) — same format, same order, frozen.
Losslessness is proved by [`docs/archive/SESSION_NOTES-through-2026-09-18.md.verify.sh`](docs/archive/SESSION_NOTES-through-2026-09-18.md.verify.sh), which re-derives L1/L2/L3 from git; run it rather
than trusting this sentence. Written by `methodology_trim.py` v1.1.2.

**Archived 21 record(s), 2026-09-17 → 2026-09-19** into [`docs/archive/SESSION_NOTES-through-2026-09-19.md`](docs/archive/SESSION_NOTES-through-2026-09-19.md) — same format, same order, frozen.
Losslessness is proved by [`docs/archive/SESSION_NOTES-through-2026-09-19.md.verify.sh`](docs/archive/SESSION_NOTES-through-2026-09-19.md.verify.sh), which re-derives L1/L2/L3 from git; run it rather
than trusting this sentence. Written by `methodology_trim.py` v1.5.0.

**Archived 10 record(s), 2026-09-19 → 2026-09-19** into [`docs/archive/SESSION_NOTES-through-2026-09-19-2.md`](docs/archive/SESSION_NOTES-through-2026-09-19-2.md) — same format, same order, frozen.
Losslessness is proved by [`docs/archive/SESSION_NOTES-through-2026-09-19-2.md.verify.sh`](docs/archive/SESSION_NOTES-through-2026-09-19-2.md.verify.sh), which re-derives L1/L2/L3 from git; run it rather
than trusting this sentence. Written by `methodology_trim.py` v1.5.0.

---

## ACTIVE TASK

### What Session 727 Did
**Deliverable:** Tarball-size audit — measured inventory of what ships in the built source
tarball + ranked remedy candidates (research only; no remedies applied) (IN PROGRESS)
**Started:** 2026-09-19
**Status:** Session claimed. Work beginning.
**Ledger:** `CHANGELOG: pending` — the claim commit's `CHANGELOG.md` entry says (in progress);
Phase 3F records the rest. Until close-out, this line is the crash breadcrumb for the next
session's reconcile.

### Session 725 Handoff Evaluation (by Session 726)
**Score: 9/10.** **What helped:** the priorities list mapped one-for-one onto this session's
Phase 0 picker (push decision surfaced as the owner's actual pick); the ~31-unpushed
prediction + the post-close-out addendum's own ledger note reconciled exactly to the
measured 32; "expect 0 undocumented commits; measure it" measured 0 on the CHANGELOG
frontier, and the one commit past the HANDOFFS frontier was the addendum itself, carrying
its own ledger entry — reconcile closed as a no-op in minutes; the warn-band CLAUDE.md
gotcha correctly framed this session's context-budget WARN as headroom, not a finding.
**What was missing:** nothing material. **What was wrong:** gotcha (3)'s "the stray `~$e
Compounding Loop.html` still makes `devtools::check()` warn" was already superseded at
write time + one commit — S725's own post-close-out addendum (`89b14d1b`) deleted the file
and added standing guards; the addendum's ledger entry self-corrects this, so zero harm.
**ROI:** high.

### What Session 726 Did
**Deliverable:** Owner-directed push to `origin/master` + CI verification — **DONE.**
Pushed `4565c39d..9006b567` (33 commits: the 32 pre-existing S720–S725 commits + the S726
claim), and all 4 push-triggered workflows completed green ON THE PUSHED SHA `9006b567`:
R-CMD-check 31m53s, pkgdown 13m47s, test-coverage 10m4s, lint 4m37s. This is the FIRST
remote validation of the S720–S725 work: the S724 warning-free suite (CI's R-CMD-check runs
it), the S721 Suggests trim + renv re-snapshot, the S720 context-budget adoption, the S725
CLAUDE.md reduction, and the S725 `~$`-guard additions. No TDD phases (no `.R` files
touched; push + docs). Lint N/A.
**Started/completed:** 2026-09-19 (single session). Claim `9006b567` (rode the push, so CI
ran on it — S717 precedent); mid-session BACKLOG filing `f8970edc`; records + sha commits
follow this handoff.
**Ledger:** one `CHANGELOG.md` entry per action (claim, BACKLOG filing, close-out, sha).

**Mid-session owner request (filed, not acted on — 1-and-done, S721 precedent):**
tarball-size-reduction item added to `BACKLOG.md` Up Next (`f8970edc`, READY, Effort L):
owner reports ~19 MB source tarball vs CRAN's ≤10 MB policy; owner steer that slimming
examples/test data may beat the package split. Item mandates measure-first (`R CMD build`
+ `tar tzvf` inventory — on-disk sizes mislead because `.Rbuildignore` already excludes
`docs/`, `vignettes/articles/`, and several reference files), carries S726 on-disk anchors
(`inst/extdata/` 5.3 MB, vignette HTMLs ~4.3 MB, `tests/` 3.4 MB), and cross-references
the package-split item (S667 rec "do not split now", owner disposition pending) and the
pedigree-growth measurement item both ways.

**Verification:** push confirmed (`master` even with `origin/master` post-push;
`git rev-list --count` 33 at push time); CI 4/4 `completed success` filtered on
`headSha == 9006b567` exactly (not just "latest runs green"); quality_ratchet: 0/0 pass ·
0 fail · 0 unmeasured · results 4f53cda18c2b · manifest 4f53cda18c2b. Post-append trim
triggers (`--budget-bytes 65536`): none fire on SESSION_NOTES/HANDOFFS/CHANGELOG.

**Self-assessment (Session 726): 9/10.** **Strengths:** (1) CI verification pinned to the
exact pushed sha via `--jq` filter on `headSha`, not eyeballed from the run list; (2) the
mid-session owner request was filed with a measure-first mandate that caught the
on-disk-vs-tarball misdirection (`.Rbuildignore` excludes the two biggest trees) before it
could send the future session chasing the wrong 60 MB; (3) no scope creep — the filed item
was not started. **Weaknesses:** (1) the ~19 MB tarball figure is recorded as
owner-reported, not measured in-session (deliberate — a full `R CMD build` mid-push-session
wasn't worth the wall time, but the item's headline number is unverified until the research
session builds the artifact); (2) one harness fumble — the first CI wait used a blocked
sleep-chain form and had to be redone as a background poller.

**Learnings:** no new `PROJECT_LEARNINGS.md` entry — routine clean push; the
tarball-inventory insight lives in the filed BACKLOG item (its forward-carrying home per
the S686 convention).

**Next steps (specific):** (A) **Owner: push decision** — recount with
`git rev-list --count origin/master..HEAD` (~3 expected after close-out: BACKLOG filing
`f8970edc` + records + sha; the last two are an estimate at write time). All 3 are
docs-only; no urgency, they ride the next push. (B) Priorities: tarball-size-reduction
research (READY, L, owner-requested S726 — measure first); pedigree-growth measurement
(READY, S, owner-requested S721 — feeds the tarball item); package-split disposition +
REUSE registration (owner decisions pending); BACKLOG.md editorial compression (READY, L).
(C) Standing report-only: HANDOFFS.md truncated duplicate S720 stub (grep for two adjacent
`session: S720` blocks); iCloud Housekeeping item closable pending a duplicates-stay-gone
confirmation.

**Key files:** `BACKLOG.md` Up Next tail (the new tarball item + the split item's new
cross-ref line), `CHANGELOG.md` S726 entries, `HANDOFFS.md` S726 receipt,
`.github/workflows/` (unchanged — the 4 green runs are ids 35481709978–35481710058).

**Gotchas for the next session:** (1) **The `devtools::check()` warn/exit-1 gotcha should
now be CLEARED** — S725's addendum deleted the `~$` lock file and added standing guards;
the next local check run should confirm (0 errors expected; the `scratchpad/` NOTE
remains). If a `~$*` file reappears, the guards make it invisible to both git and
`R CMD build`. (2) CI is now current through `9006b567` — only the ~3 close-out docs
commits are unpushed; "expect 0 undocumented commits; measure it" at next Phase 0.
(3) Standing: every `methodology_trim.py` run needs `--budget-bytes 65536`; `renv.lock`
carries no dev tooling (`Rscript` out-of-sync banner expected); CLAUDE.md sits in the warn
band with ~1,640 B headroom — new adaptation narrative goes to `PROJECT_LEARNINGS.md`.
(4) Full-suite baseline unchanged (no test-read files touched): 2437/0/0/184/0 — and now
remote-confirmed by R-CMD-check on `9006b567`.

### Session 724 Handoff Evaluation (by Session 725)
**Score: 9/10.** **What helped:** the priorities list matched this session's Phase 0
picker one-for-one, and the picked item's own BACKLOG block WAS the plan (excess
location, remedies in order, keep-intact list — all accurate); the ~27-unpushed-commits
prediction measured exactly 27; "expect 0 undocumented commits; measure it" measured 0;
standing gotcha (4)'s "context-budget reds by design until the CLAUDE.md reduction
campaign" framed the target precisely, and the trim-budget/`~$e`-file/renv-banner
gotchas all held. **What was missing:** nothing material. **What was wrong:** nothing
found — every checked claim held. **ROI:** high.

### What Session 725 Did
**Deliverable:** `CLAUDE.md` reduction campaign — **DONE.** 43,348 B → 26,360 B, under
the 28,000 B `.context-budget.json` ceiling (17 KB cut; warn band ≥24,000 B is
documented headroom, not a defect). Method per the BACKLOG item: each Adaptations block
classified sentence-by-sentence into operative rule vs incident narrative; rules kept
(verbatim or tightened) with origins compressed to Learning pointers; narrative existing
nowhere else moved to `PROJECT_LEARNINGS.md` **Learning 770** (the relocation record:
S545 rejected alternatives, S436 origin, NEWS.Rmd drift history, `methodology_trim.py`
provenance, the S325/S546/S547 legacy-history decision chain, and the reduction method
itself); full pre-reduction text archived as `git show 1ef168b8:CLAUDE.md`. Kept intact:
SESSION PROTOCOL header, `budget:protected` Project Overview fence, TDD contract,
Build/Test/Verify. BACKLOG item removed in the deliverable commit. No TDD phases
(docs-only, S720–S724 precedent); lint N/A (no `.R` files).
**Started/completed:** 2026-09-19 (single session). Claim `1ef168b8`; deliverable
`c8512d0d`; records + sha commits follow this handoff.
**Ledger:** one `CHANGELOG.md` entry per commit; the deliverable entry carries the full
method + verification record.

**Verification:** `wc -c CLAUDE.md` = 26,360 B; `python3 context_budget.py` = no file
over its ceiling (resident 26,360/34,000, `budget:protected` fence intact); every
Learning number cited by a new pointer grep-verified present (382/433/435/475/477/478/
479/495/506/533/544/547/549/554/586/587/669/740); `grep -c '^#### Learning '` = 770,
matching the new record's number; all in-file "above" cross-references re-read and
resolving; no test reads the 4 touched `.md` files (grep-verified: all matches are
comments/strings), so the S724 suite baseline 2437/0/0/184/0 carries forward
legitimately under Learning 764's scope rule. quality_ratchet: 0/0 pass · 0 fail · 0
unmeasured · results 4f53cda18c2b · manifest 4f53cda18c2b. Trim triggers post-append
(`--budget-bytes 65536`): none fire on SESSION_NOTES/HANDOFFS/CHANGELOG.

**Self-assessment (Session 725): 9/10.** **Strengths:** (1) every relocated narrative's
destination verified before the pointer was written — nothing points at a Learning that
doesn't hold the content; (2) caught two sentences the reduction itself falsified and
updated them in the same pass (the context-budget check's expected state; the trilogy's
"no file has moved yet"); (3) the first draft of the new expected-state sentence claimed
"all green" — measurement (warn at 26,360 B) corrected it to "no file over its ceiling"
before commit. **Weaknesses:** (1) landed in the warn band rather than under 24,000 B —
the remaining large block (the Build/Test/Verify regression-read narrative) was
explicitly on the item's keep-intact list, so deeper cutting needs an owner decision;
(2) growth headroom is only ~1,640 B before red.

**Next steps (specific):** (A) **Owner: push decision** — recount with
`git rev-list --count origin/master..HEAD` (~31 expected after close-out: 27 pre-existing
+ claim + deliverable + records + sha; the last two are an estimate at write time).
(B) Priorities: pedigree-growth measurement (READY, S, owner-requested S721); owner
decisions pending: package-split disposition, REUSE registration; BACKLOG.md editorial
compression (READY, L). (C) Standing report-only: HANDOFFS.md truncated duplicate S720
stub (grep for two adjacent `session: S720` blocks); iCloud Housekeeping item closable
pending a duplicates-stay-gone confirmation.

**Key files:** `CLAUDE.md` (whole Adaptations section reshaped; overview/TDD/BTV
untouched), `PROJECT_LEARNINGS.md` tail (Learning 770), `BACKLOG.md` (campaign item
removed), `CHANGELOG.md` S725 entries.

**Gotchas for the next session:** (1) **CLAUDE.md is now under ceiling but in the warn
band — any growth commit trips the pre-commit hook's relative rule; put new adaptation
narrative in `PROJECT_LEARNINGS.md` and keep only the rule + pointer in `CLAUDE.md`**
(the Learning 770 method, recorded there as point 6). (2) The context-budget expected
state changed: reds are no longer "by design" — a `CLAUDE.md` red is now a finding.
(3) Standing: every `methodology_trim.py` run needs `--budget-bytes 65536`; the stray
`~$e Compounding Loop.html` still makes `devtools::check()` warn and exit 1
non-interactively; `renv.lock` carries no dev tooling (`Rscript` out-of-sync banner
expected). (4) Full-suite baseline unchanged this session (no test-read files touched):
2437/0/0/184/0.

