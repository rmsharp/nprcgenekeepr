# Session Notes

**Purpose:** Continuity between sessions. Each session reads this first
and writes to it before closing out.

**Archived 612 record(s), 1998-12-06 → 2026-08-12** into
[`docs/archive/SESSION_NOTES-through-2026-08-12.md`](https://github.com/rmsharp/nprcgenekeepr/docs/archive/SESSION_NOTES-through-2026-08-12.md)
— same format, same order, frozen. Losslessness is proved by
[`docs/archive/SESSION_NOTES-through-2026-08-12.md.verify.sh`](https://github.com/rmsharp/nprcgenekeepr/docs/archive/SESSION_NOTES-through-2026-08-12.md.verify.sh),
which re-derives L1/L2/L3 from git; run it rather than trusting this
sentence. Written by `methodology_trim.py` v1.1.2.

**Archived 40 record(s), 2026-08-11 → 2026-08-13** into
[`docs/archive/SESSION_NOTES-through-2026-08-13.md`](https://github.com/rmsharp/nprcgenekeepr/docs/archive/SESSION_NOTES-through-2026-08-13.md)
— same format, same order, frozen. Losslessness is proved by
[`docs/archive/SESSION_NOTES-through-2026-08-13.md.verify.sh`](https://github.com/rmsharp/nprcgenekeepr/docs/archive/SESSION_NOTES-through-2026-08-13.md.verify.sh),
which re-derives L1/L2/L3 from git; run it rather than trusting this
sentence. Written by `methodology_trim.py` v1.1.2.

**Archived 76 record(s), 2026-01-26 → 2026-08-15** into
[`docs/archive/SESSION_NOTES-through-2026-08-15.md`](https://github.com/rmsharp/nprcgenekeepr/docs/archive/SESSION_NOTES-through-2026-08-15.md)
— same format, same order, frozen. Losslessness is proved by
[`docs/archive/SESSION_NOTES-through-2026-08-15.md.verify.sh`](https://github.com/rmsharp/nprcgenekeepr/docs/archive/SESSION_NOTES-through-2026-08-15.md.verify.sh),
which re-derives L1/L2/L3 from git; run it rather than trusting this
sentence. Written by `methodology_trim.py` v1.1.2.

**Archived 170 record(s), 2026-08-19 → 2026-09-17** into
[`docs/archive/SESSION_NOTES-through-2026-09-17.md`](https://github.com/rmsharp/nprcgenekeepr/docs/archive/SESSION_NOTES-through-2026-09-17.md)
— same format, same order, frozen. Losslessness is proved by
[`docs/archive/SESSION_NOTES-through-2026-09-17.md.verify.sh`](https://github.com/rmsharp/nprcgenekeepr/docs/archive/SESSION_NOTES-through-2026-09-17.md.verify.sh),
which re-derives L1/L2/L3 from git; run it rather than trusting this
sentence. Written by `methodology_trim.py` v1.1.2.

**Archived 19 record(s), 2026-08-14 → 2026-09-18** into
[`docs/archive/SESSION_NOTES-through-2026-09-18.md`](https://github.com/rmsharp/nprcgenekeepr/docs/archive/SESSION_NOTES-through-2026-09-18.md)
— same format, same order, frozen. Losslessness is proved by
[`docs/archive/SESSION_NOTES-through-2026-09-18.md.verify.sh`](https://github.com/rmsharp/nprcgenekeepr/docs/archive/SESSION_NOTES-through-2026-09-18.md.verify.sh),
which re-derives L1/L2/L3 from git; run it rather than trusting this
sentence. Written by `methodology_trim.py` v1.1.2.

**Archived 21 record(s), 2026-09-17 → 2026-09-19** into
[`docs/archive/SESSION_NOTES-through-2026-09-19.md`](https://github.com/rmsharp/nprcgenekeepr/docs/archive/SESSION_NOTES-through-2026-09-19.md)
— same format, same order, frozen. Losslessness is proved by
[`docs/archive/SESSION_NOTES-through-2026-09-19.md.verify.sh`](https://github.com/rmsharp/nprcgenekeepr/docs/archive/SESSION_NOTES-through-2026-09-19.md.verify.sh),
which re-derives L1/L2/L3 from git; run it rather than trusting this
sentence. Written by `methodology_trim.py` v1.5.0.

**Archived 10 record(s), 2026-09-19 → 2026-09-19** into
[`docs/archive/SESSION_NOTES-through-2026-09-19-2.md`](https://github.com/rmsharp/nprcgenekeepr/docs/archive/SESSION_NOTES-through-2026-09-19-2.md)
— same format, same order, frozen. Losslessness is proved by
[`docs/archive/SESSION_NOTES-through-2026-09-19-2.md.verify.sh`](https://github.com/rmsharp/nprcgenekeepr/docs/archive/SESSION_NOTES-through-2026-09-19-2.md.verify.sh),
which re-derives L1/L2/L3 from git; run it rather than trusting this
sentence. Written by `methodology_trim.py` v1.5.0.

------------------------------------------------------------------------

## ACTIVE TASK

### What Session 729 Did

**Deliverable:** Owner-directed push to `origin/master` + CI
verification (IN PROGRESS) — 13 commits expected (the 12 unpushed
S726–S728 docs/config commits + this claim, which rides the push so CI
runs on it, S717/S726 precedent). Verification = all 4 push-triggered
workflows `completed success` ON THE PUSHED SHA (jq-filtered on
`headSha`, not eyeballed). **Started:** 2026-09-19 **Status:** Session
claimed. Push follows this commit immediately. **Ledger:**
`CHANGELOG: pending` — the claim commit’s `CHANGELOG.md` entry says (in
progress); Phase 3F records the rest. Until close-out, this line is the
crash breadcrumb for the next session’s reconcile.

### Session 727 Handoff Evaluation (by Session 728)

**Score: 9/10.** **What helped:** next step (A) WAS this session’s
deliverable, framed exactly as the decision the Phase 0/1 pickers then
posed (commit or discard the `.Rbuildignore` line); the `BACKLOG.md:100`
block was the execution plan verbatim — steps in order, verification
commands named (`tools:::inRbuildignore` + `git check-ignore`, S725
precedent), threshold suggestion (\<=5 MB) adopted as declared; the
audit §7 recipe became the gate command nearly verbatim; “~8 expected”
unpushed measured exactly 8; “expect 0 undocumented; measure it”
measured 0 on both frontiers; gotcha (1) (dirty `.Rbuildignore`, not
session-made, don’t touch) correctly shaped Phase 0. **What was
missing:** nothing material — only that nobody had checked whether the
ratchet’s timeout accommodates a build-based gate (one grep: 600 s,
fits). **What was wrong:** nothing found — every checked claim held, and
the gate’s clean-export measurements (3,485,137 B at `f82f978a`;
3,485,027 B at `2570645b`) are consistent with the audit’s 3,485,185 B
at `f8ffa40b` (drift = the docs-only commits in between). **ROI:** high.

### What Session 728 Did

**Deliverable:** Tarball build-hygiene follow-ups (`BACKLOG.md:100`
steps 1–3) — **DONE.** The owner’s `^scratchpad$` `.Rbuildignore` line
is committed (the 19.7 MB working-tree leak closed); `scratchpad/` and
the testthat debris (`tests/testthat/_problems/`,
`testthat-problems.rds`) are ignored in BOTH `.Rbuildignore` and
`.gitignore`; and the project’s FIRST declared quality gate is live:
`tarball_size_clean_export` (clean-export
[`pkgbuild::build()`](https://pkgbuild.r-lib.org/reference/build.html)
of `git archive HEAD`, max 5,000,000 B), measured in-session **1/1 pass
at 3,485,027 B** on the deliverable commit. Config/docs only — no `.R`
files; TDD N/A; lint N/A. **Started/completed:** 2026-09-19 (single
session). Claim `f82f978a`; deliverable `2570645b`; records + sha
commits follow this handoff. **Ledger:** one `CHANGELOG.md` entry per
commit; the deliverable entry carries the numbers.

**What actually happened, in order:** 1. **Phase 0:** reconcile clean (0
undocumented on both frontiers; the sole `status: pending` grep hit is
the HANDOFFS how-to text, not a receipt); CI 4/4 green on `9006b567`;
dashboard 96/100; context budget warn-band only; 8 unpushed as
predicted; dirty `.Rbuildignore` reported, untouched. 2. **Owner
decisions via pickers** (Phase 0 pick + one 3-question Phase 1 gate):
pick the build-hygiene item; commit the edit; ALSO git-ignore
`scratchpad/` (ghost-check tradeoff accepted); include the size gate. 3.
**Edits:** `.Rbuildignore` +2 debris lines (:159–160) beside the owner’s
:155; `.gitignore` new block (:93–103); `.quality-gates.json` first gate
(:17–27), command = audit §7 recipe printing a self-tagged
`TARBALL_BYTES=` marker. 4. **Verification:** `git check-ignore -v`
resolves all three paths to the new lines; `tools:::inRbuildignore` TRUE
on each real path (directory matches prune contents — the semantics
S727’s 3.56 MB working-tree build measured); gate exercised twice (claim
commit 3,485,137 B; deliverable commit 3,485,027 B; both pass with ~1.5
MB headroom); `git status` untracked noise down to the 5 known
planning/article files. 5. **BACKLOG:** completed block removed in the
deliverable commit (S686 convention); step 4 (optional `inst/doc`
slimming) extracted as its own DECISION-NEEDED item at `BACKLOG.md:100`.

**Self-assessment (Session 728): 9/10.** **Strengths:** (1) all three
embedded owner decisions collected in ONE structured gate before the
claim, so execution never stalled; (2) the gate was exercised in-session
twice, and the receipt cites the run at the shipped HEAD, not the claim
state; (3) scope held — no CI-workflow variant, no inst/doc slimming,
nothing beyond the approved three steps. **Weaknesses:** (1) “5 MB” was
interpreted as decimal 5,000,000 B (the audit’s currency) without asking
— documented in the gate’s `unit`, but 5 MiB was equally plausible; (2)
the first ratchet run measured the claim state — harmless here
(docs-only claim) but the sequencing is now a Learning 772 caution; (3)
every future close-out pays ~2 min of gate build time — approved, but
the recurring cost lands on successors.

**Next steps (specific):** (A) **Owner: push decision** — recount with
`git rev-list --count origin/master..HEAD` (~12 expected after
close-out: 8 pre-existing + claim + deliverable + records + sha; the
last two are an estimate at write time). All docs/config-only; the push
also puts the first gate manifest on the remote. (B) Priorities:
pedigree-growth measurement (READY, S, owner-requested S721 — bounded at
+1.07 MB total, measure compressed from a clean build); package-split
disposition (owner; size no longer argues for it) + REUSE registration
(owner action, S); BACKLOG.md editorial compression (READY, L); the
extracted inst/doc slimming item (DECISION NEEDED, M, `BACKLOG.md:100`).
(C) Standing report-only: HANDOFFS.md truncated duplicate S720 stub (two
adjacent `session: S720` blocks); iCloud Housekeeping item closable
pending a duplicates-stay-gone confirmation; the owner’s stale 19.7 MB
`../nprcgenekeepr_2.0.0.9000.tar.gz` + `../nprcgenekeepr.Rcheck/` still
sit outside the repo (delete/rebuild is the owner’s call).

**Key files:** `.quality-gates.json:17` (the gate —
name/threshold/command/why), `.Rbuildignore:155-160` (scratchpad +
debris lines), `.gitignore:93-103` (mirror block with the tradeoff
note), `BACKLOG.md:100` (extracted inst/doc item),
`PROJECT_LEARNINGS.md` Learning 772 (gate-author mechanics),
`docs/audits/TARBALL_SIZE_AUDIT_2026-09-19.md` §7 (the recipe the gate
command reuses).

**Gotchas for the next session:** (1) **`scratchpad/` no longer shows as
untracked — by owner decision, not by accident.** The Phase 0
untracked-file ghost-session check must remember the directory still
exists on disk (`ls -d scratchpad` if in doubt); it is now invisible to
both git and builds. (2) **`quality_ratchet.py --run` now takes ~2 min**
(full package build with vignettes) — not a hang; per-gate timeout is
600 s. Run it AFTER committing: the gate measures `git archive HEAD`
(Learning 772); never swap in `--no-build-vignettes`, which measures a
~38%-lighter artifact than the one CRAN gets. (3) The gate threshold is
decimal 5,000,000 B; thresholds only tighten — loosening is a plan-mode
decision committed with `--no-verify` (SAFEGUARDS Blast Radius). (4)
Standing: every `methodology_trim.py` run needs `--budget-bytes 65536`;
`renv.lock` carries no dev tooling (`Rscript` banner expected);
CLAUDE.md in warn band (~1,640 B headroom) — narrative goes to
`PROJECT_LEARNINGS.md`; the two `SESSION_NOTES.md` ceilings still differ
(56,750 B token cap binds before the 65,536 B byte trigger — owner
decision pending); suite baseline 2437/0/0/184/0 carries forward (no
code touched).

### Session 726 Handoff Evaluation (by Session 727)

**Score: 9/10.** **What helped:** the filed tarball item’s measure-first
mandate (“build the real artifact and `tar tzvf` it; on-disk sizes
mislead”) WAS this session’s method and led straight to the answer;
S726’s own self-assessment flagged the ~19 MB headline as
“owner-reported, not measured” — exactly the claim that turned out to
need refuting, so it was approached as a hypothesis, not a fact; “~3
unpushed” measured 3; “expect 0 undocumented commits; measure it”
measured 0 on both frontiers; gotcha (1)’s “the `scratchpad/` NOTE
remains” was, in hindsight, the clue. **What was missing:** nobody
(S721–S726) connected that NOTE to the artifact — a top-level directory
that check complains about is a directory that ships; the item’s remedy
list was therefore built entirely around slimming package content.
**What was wrong:** the on-disk anchors (tests 3.4 MB, `inst/extdata`
5.3 MB) pointed at data slimming, which measured compressed is worth
almost nothing — low harm, because the same item told the reader not to
trust on-disk numbers. **ROI:** high.

### What Session 727 Did

**Deliverable:** Tarball-size audit — **DONE.**
[`docs/audits/TARBALL_SIZE_AUDIT_2026-09-19.md`](https://github.com/rmsharp/nprcgenekeepr/docs/audits/TARBALL_SIZE_AUDIT_2026-09-19.md).
**The “~19 MB tarball” is not package content: it is the untracked 20 MB
`scratchpad/` directory leaking into working-tree builds. A clean
`git archive HEAD` build is 3,485,185 B (3.49 MB) — 35% of CRAN’s 10 MB
line** (CRAN 2.0.0 was 2,419,329 B). Research only: no remedy applied,
no `.R`/`.Rbuildignore`/`.gitignore` change, no TDD phases, lint N/A.
**Started/completed:** 2026-09-19 (single session). Claim `f8ffa40b`;
deliverable `6d221ddc`; close-out trim `1a5f345e`; records + sha commits
follow this handoff. **Ledger:** one `CHANGELOG.md` entry per commit;
the deliverable entry carries the numbers.

**What actually happened, in order:** 1. **Phase 0:** reconcile clean (0
undocumented on both frontiers); CI 4/4 green on the pushed sha
`9006b567`; dashboard 96/100; context budget WARN-band only. **Dirty
tree:** an uncommitted, not-session-made `.Rbuildignore` edit
(`+^scratchpad$`). The Phase 0 picker (with a second question about that
edit) was dismissed “to clarify”; the owner then replied with the pasted
label “Tarball-size research” — taken as the pick. The dirty-file
question was never answered, so the edit was left untouched all session.
2. **Three real builds** (all in the session scratch dir, via
[`pkgbuild::build()`](https://pkgbuild.r-lib.org/reference/build.html)
run from the repo root so renv’s library applies): working tree
3,564,041 B; clean HEAD export 3,485,185 B; clean export +
`scratchpad/` + testthat debris under the COMMITTED `.Rbuildignore`
19,714,510 B. Then found and inspected the owner’s own artifact,
`../nprcgenekeepr_2.0.0.9000.tar.gz` (19,732,245 B, built 20:14): 252
`scratchpad/` entries. Reproduction matches to 0.1%. 3. **Inventory:**
997 entries / 12.01 MB uncompressed; compressed shares by directory and
a per-file `gzip -9` ranking. `inst/doc` is 38% of the tarball (three
`html_document` vignettes); example/test data is cheap compressed. CRAN
policy text verified at source (rev. 6875); installed size cross-checked
against CI run 35481710058 (9.5–10.2 MB, `INFO`). 4. **Mid-session owner
messages:** “note size of `../nprcgenekeepr_2.0.0.9000.tar.gz`” (already
measured; it is the report’s primary evidence) and “does this mean we
need to add files and folders to rbuildignore?” — answered yes (the
owner’s pending line is the fix; two testthat-debris paths also
warranted) and NOT acted on (a question is not an instruction; filed in
the follow-up item). 5. **BACKLOG:** the Effort-L reduce-size item
removed (premise refuted) and replaced by “Tarball build-hygiene
follow-ups” (DECISION NEEDED, S) at `BACKLOG.md:100`; split item
cross-ref rewritten (`:95`); pedigree-growth item given the +1.07 MB
upper bound (`:140`). 6. **Close-out trim (`1a5f345e`):** this handoff
pushed `SESSION_NOTES.md` to 57,111 B — over `context_budget.py`’s
25,000-token read cap (= 56,750 B at 2.27 B/token), which the pre-commit
hook enforces, while `methodology_trim.py --budget-bytes 65536` still
said NOTHING_TO_DO. Resolved with an explicit `--cut 5` (budget flag
still passed; no `--force` needed): 10 records (S720–S724) to
`docs/archive/SESSION_NOTES-through-2026-09-19-2.md`, L1/L2/L3 verified
before and after commit. The trim ran on the committed pre-handoff state
(the verify script anchors to the trim commit’s parent), then this
handoff was re-applied.

**Verification:** every headline number is a measured byte count from a
built artifact, and the explanation was tested by controlled
reproduction, not inferred. Three draft claims in the report were caught
by a pre-commit fact-check and corrected (scratchpad file count 244→250;
“~63 MB excluded”→43.5 MB measured; “leaking for weeks” re-anchored to
the 2026-08-17 oldest-file date + empty `git log -S`). No code touched,
so the suite baseline 2437/0/0/184/0 carries forward (Learning 764 scope
rule). quality_ratchet and post-append trim-trigger results: see the
close-out `CHANGELOG.md` entry.

**Self-assessment (Session 727): 8/10.** **Strengths:** (1) refuted the
item’s premise by measurement in the first 20 minutes instead of
executing an Effort-L slimming campaign against a non-problem; (2)
closed the loop three ways — controlled reproduction, the owner’s actual
artifact, and the local check log — rather than stopping at plausible
arithmetic (3.56 + 16.27 ≈ 19.8); (3) compressed-byte attribution
overturned the item’s own remedy steer with numbers; (4) left the
owner’s uncommitted edit alone and answered the owner’s question without
acting on it. **Weaknesses:** (1) the task pick rested on a terse pasted
label after a dismissed picker — reasonable and reversible (docs-only),
but not an explicit confirmation; (2) removing the owner-requested L
item and substituting an S follow-up was this session’s judgment under
the S686 convention — the owner may prefer otherwise; (3) the
`a2interactive.html` component breakdown was attempted with a sloppy
regex that produced nonsense (negative remainders) and was reported as
“identified, not weighed” rather than redone; (4) two Phase 0 shell
fumbles (GNU vs BSD `stat`).

**Next steps (specific):** (A) **Owner decision first:** commit or
discard the uncommitted `.Rbuildignore` `+^scratchpad$` line — it is the
fix (measured), and the follow-up item at `BACKLOG.md:100` is blocked on
it. Then that item’s steps (2)–(4) in order; (2) is trivial and can ride
the same commit, verified with `tools:::inRbuildignore` +
`git check-ignore` on the real paths. (B) **Owner: push decision** —
recount with `git rev-list --count origin/master..HEAD` (~8 expected
after close-out: 3 pre-existing + claim + deliverable + trim + records +
sha; the last two are an estimate at write time). All docs-only. (C)
Priorities after that: pedigree-growth measurement (READY, S — now
bounded at +1.07 MB total; measure compressed from a clean build);
package-split disposition (owner — size no longer argues for it) + REUSE
registration; BACKLOG.md editorial compression (READY, L). (D) Standing
report-only: HANDOFFS.md truncated duplicate S720 stub (grep for two
adjacent `session: S720` blocks); iCloud Housekeeping item closable
pending a duplicates-stay-gone confirmation; the owner’s stale 19.7 MB
`../nprcgenekeepr_2.0.0.9000.tar.gz` and `../nprcgenekeepr.Rcheck/` are
outside the repo and were only read, never touched.

**Key files:** `docs/audits/TARBALL_SIZE_AUDIT_2026-09-19.md` (§1 build
table, §2 inventory, §3 findings, §7 reproduction commands),
`BACKLOG.md:100` (follow-up item), `BACKLOG.md:95` and `:140` (rewritten
cross-refs), `.Rbuildignore:155` (the owner’s UNCOMMITTED line),
`vignettes/a2interactive.Rmd:4-7` / `gvaConvergence.Rmd:6-8` /
`simulatedKValues.Rmd:6-8` (the `html_document` declarations behind
Finding 3), `PROJECT_LEARNINGS.md` Learning 771.

**Gotchas for the next session:** (1) **The working tree is still
dirty** (`.Rbuildignore`) — not session-made; do not commit or discard
it without the owner’s word. Until it is committed, a working-tree build
from a checkout WITHOUT that line is 19.7 MB again. (2) **Never measure
the tarball from the working tree** — use the §7 clean-export recipe;
[`pkgbuild::build()`](https://pkgbuild.r-lib.org/reference/build.html)
must be launched from the repo root (renv library) even when building an
export elsewhere. (3) The `html_vignette` saving in Finding 3 is an
estimate, and `df_print: paged` does not exist under `html_vignette` —
that slice needs its own before/after build measurement. (4) Standing:
every `methodology_trim.py` run needs `--budget-bytes 65536`;
`renv.lock` carries no dev tooling (`Rscript` out-of-sync banner
expected); CLAUDE.md sits in the warn band (~1,640 B headroom) — new
narrative goes to `PROJECT_LEARNINGS.md`. (5) Full-suite baseline
unchanged: 2437/0/0/184/0. (6) **The two `SESSION_NOTES.md` ceilings are
NOT the same number in practice:** the token cap binds at 56,750 B, the
byte trigger at 65,536 B, and in the gap the hook refuses growth while
the trimmer reports NOTHING_TO_DO. `CLAUDE.md`’s “deliberately the same
number” sentence holds for `max_bytes` only (`.context-budget.json`’s
own note says `max_tokens` binds first) — report-only here (owner
decision: lower the trim budget to 56,750, or keep using an explicit
`--cut N`). With ~8 KB handoffs this recurs roughly every 4–5 sessions.

### Session 725 Handoff Evaluation (by Session 726)

**Score: 9/10.** **What helped:** the priorities list mapped one-for-one
onto this session’s Phase 0 picker (push decision surfaced as the
owner’s actual pick); the ~31-unpushed prediction + the post-close-out
addendum’s own ledger note reconciled exactly to the measured 32;
“expect 0 undocumented commits; measure it” measured 0 on the CHANGELOG
frontier, and the one commit past the HANDOFFS frontier was the addendum
itself, carrying its own ledger entry — reconcile closed as a no-op in
minutes; the warn-band CLAUDE.md gotcha correctly framed this session’s
context-budget WARN as headroom, not a finding. **What was missing:**
nothing material. **What was wrong:** gotcha (3)’s “the stray
`~$e Compounding Loop.html` still makes `devtools::check()` warn” was
already superseded at write time + one commit — S725’s own
post-close-out addendum (`89b14d1b`) deleted the file and added standing
guards; the addendum’s ledger entry self-corrects this, so zero harm.
**ROI:** high.

### What Session 726 Did

**Deliverable:** Owner-directed push to `origin/master` + CI
verification — **DONE.** Pushed `4565c39d..9006b567` (33 commits: the 32
pre-existing S720–S725 commits + the S726 claim), and all 4
push-triggered workflows completed green ON THE PUSHED SHA `9006b567`:
R-CMD-check 31m53s, pkgdown 13m47s, test-coverage 10m4s, lint 4m37s.
This is the FIRST remote validation of the S720–S725 work: the S724
warning-free suite (CI’s R-CMD-check runs it), the S721 Suggests trim +
renv re-snapshot, the S720 context-budget adoption, the S725 CLAUDE.md
reduction, and the S725 `~$`-guard additions. No TDD phases (no `.R`
files touched; push + docs). Lint N/A. **Started/completed:** 2026-09-19
(single session). Claim `9006b567` (rode the push, so CI ran on it —
S717 precedent); mid-session BACKLOG filing `f8970edc`; records + sha
commits follow this handoff. **Ledger:** one `CHANGELOG.md` entry per
action (claim, BACKLOG filing, close-out, sha).

**Mid-session owner request (filed, not acted on — 1-and-done, S721
precedent):** tarball-size-reduction item added to `BACKLOG.md` Up Next
(`f8970edc`, READY, Effort L): owner reports ~19 MB source tarball vs
CRAN’s ≤10 MB policy; owner steer that slimming examples/test data may
beat the package split. Item mandates measure-first (`R CMD build` +
`tar tzvf` inventory — on-disk sizes mislead because `.Rbuildignore`
already excludes `docs/`, `vignettes/articles/`, and several reference
files), carries S726 on-disk anchors (`inst/extdata/` 5.3 MB, vignette
HTMLs ~4.3 MB, `tests/` 3.4 MB), and cross-references the package-split
item (S667 rec “do not split now”, owner disposition pending) and the
pedigree-growth measurement item both ways.

**Verification:** push confirmed (`master` even with `origin/master`
post-push; `git rev-list --count` 33 at push time); CI 4/4
`completed success` filtered on `headSha == 9006b567` exactly (not just
“latest runs green”); quality_ratchet: 0/0 pass · 0 fail · 0 unmeasured
· results 4f53cda18c2b · manifest 4f53cda18c2b. Post-append trim
triggers (`--budget-bytes 65536`): none fire on
SESSION_NOTES/HANDOFFS/CHANGELOG.

**Self-assessment (Session 726): 9/10.** **Strengths:** (1) CI
verification pinned to the exact pushed sha via `--jq` filter on
`headSha`, not eyeballed from the run list; (2) the mid-session owner
request was filed with a measure-first mandate that caught the
on-disk-vs-tarball misdirection (`.Rbuildignore` excludes the two
biggest trees) before it could send the future session chasing the wrong
60 MB; (3) no scope creep — the filed item was not started.
**Weaknesses:** (1) the ~19 MB tarball figure is recorded as
owner-reported, not measured in-session (deliberate — a full
`R CMD build` mid-push-session wasn’t worth the wall time, but the
item’s headline number is unverified until the research session builds
the artifact); (2) one harness fumble — the first CI wait used a blocked
sleep-chain form and had to be redone as a background poller.

**Learnings:** no new `PROJECT_LEARNINGS.md` entry — routine clean push;
the tarball-inventory insight lives in the filed BACKLOG item (its
forward-carrying home per the S686 convention).

**Next steps (specific):** (A) **Owner: push decision** — recount with
`git rev-list --count origin/master..HEAD` (~3 expected after close-out:
BACKLOG filing `f8970edc` + records + sha; the last two are an estimate
at write time). All 3 are docs-only; no urgency, they ride the next
push. (B) Priorities: tarball-size-reduction research (READY, L,
owner-requested S726 — measure first); pedigree-growth measurement
(READY, S, owner-requested S721 — feeds the tarball item); package-split
disposition + REUSE registration (owner decisions pending); BACKLOG.md
editorial compression (READY, L). (C) Standing report-only: HANDOFFS.md
truncated duplicate S720 stub (grep for two adjacent `session: S720`
blocks); iCloud Housekeeping item closable pending a
duplicates-stay-gone confirmation.

**Key files:** `BACKLOG.md` Up Next tail (the new tarball item + the
split item’s new cross-ref line), `CHANGELOG.md` S726 entries,
`HANDOFFS.md` S726 receipt, `.github/workflows/` (unchanged — the 4
green runs are ids 35481709978–35481710058).

**Gotchas for the next session:** (1) **The `devtools::check()`
warn/exit-1 gotcha should now be CLEARED** — S725’s addendum deleted the
`~$` lock file and added standing guards; the next local check run
should confirm (0 errors expected; the `scratchpad/` NOTE remains). If a
`~$*` file reappears, the guards make it invisible to both git and
`R CMD build`. (2) CI is now current through `9006b567` — only the ~3
close-out docs commits are unpushed; “expect 0 undocumented commits;
measure it” at next Phase 0. (3) Standing: every `methodology_trim.py`
run needs `--budget-bytes 65536`; `renv.lock` carries no dev tooling
(`Rscript` out-of-sync banner expected); CLAUDE.md sits in the warn band
with ~1,640 B headroom — new adaptation narrative goes to
`PROJECT_LEARNINGS.md`. (4) Full-suite baseline unchanged (no test-read
files touched): 2437/0/0/184/0 — and now remote-confirmed by R-CMD-check
on `9006b567`.

### Session 724 Handoff Evaluation (by Session 725)

**Score: 9/10.** **What helped:** the priorities list matched this
session’s Phase 0 picker one-for-one, and the picked item’s own BACKLOG
block WAS the plan (excess location, remedies in order, keep-intact list
— all accurate); the ~27-unpushed-commits prediction measured exactly
27; “expect 0 undocumented commits; measure it” measured 0; standing
gotcha (4)’s “context-budget reds by design until the CLAUDE.md
reduction campaign” framed the target precisely, and the
trim-budget/`~$e`-file/renv-banner gotchas all held. **What was
missing:** nothing material. **What was wrong:** nothing found — every
checked claim held. **ROI:** high.

### What Session 725 Did

**Deliverable:** `CLAUDE.md` reduction campaign — **DONE.** 43,348 B →
26,360 B, under the 28,000 B `.context-budget.json` ceiling (17 KB cut;
warn band ≥24,000 B is documented headroom, not a defect). Method per
the BACKLOG item: each Adaptations block classified sentence-by-sentence
into operative rule vs incident narrative; rules kept (verbatim or
tightened) with origins compressed to Learning pointers; narrative
existing nowhere else moved to `PROJECT_LEARNINGS.md` **Learning 770**
(the relocation record: S545 rejected alternatives, S436 origin,
NEWS.Rmd drift history, `methodology_trim.py` provenance, the
S325/S546/S547 legacy-history decision chain, and the reduction method
itself); full pre-reduction text archived as
`git show 1ef168b8:CLAUDE.md`. Kept intact: SESSION PROTOCOL header,
`budget:protected` Project Overview fence, TDD contract,
Build/Test/Verify. BACKLOG item removed in the deliverable commit. No
TDD phases (docs-only, S720–S724 precedent); lint N/A (no `.R` files).
**Started/completed:** 2026-09-19 (single session). Claim `1ef168b8`;
deliverable `c8512d0d`; records + sha commits follow this handoff.
**Ledger:** one `CHANGELOG.md` entry per commit; the deliverable entry
carries the full method + verification record.

**Verification:** `wc -c CLAUDE.md` = 26,360 B;
`python3 context_budget.py` = no file over its ceiling (resident
26,360/34,000, `budget:protected` fence intact); every Learning number
cited by a new pointer grep-verified present (382/433/435/475/477/478/
479/495/506/533/544/547/549/554/586/587/669/740);
`grep -c '^#### Learning '` = 770, matching the new record’s number; all
in-file “above” cross-references re-read and resolving; no test reads
the 4 touched `.md` files (grep-verified: all matches are
comments/strings), so the S724 suite baseline 2437/0/0/184/0 carries
forward legitimately under Learning 764’s scope rule. quality_ratchet:
0/0 pass · 0 fail · 0 unmeasured · results 4f53cda18c2b · manifest
4f53cda18c2b. Trim triggers post-append (`--budget-bytes 65536`): none
fire on SESSION_NOTES/HANDOFFS/CHANGELOG.

**Self-assessment (Session 725): 9/10.** **Strengths:** (1) every
relocated narrative’s destination verified before the pointer was
written — nothing points at a Learning that doesn’t hold the content;
(2) caught two sentences the reduction itself falsified and updated them
in the same pass (the context-budget check’s expected state; the
trilogy’s “no file has moved yet”); (3) the first draft of the new
expected-state sentence claimed “all green” — measurement (warn at
26,360 B) corrected it to “no file over its ceiling” before commit.
**Weaknesses:** (1) landed in the warn band rather than under 24,000 B —
the remaining large block (the Build/Test/Verify regression-read
narrative) was explicitly on the item’s keep-intact list, so deeper
cutting needs an owner decision; (2) growth headroom is only ~1,640 B
before red.

**Next steps (specific):** (A) **Owner: push decision** — recount with
`git rev-list --count origin/master..HEAD` (~31 expected after
close-out: 27 pre-existing + claim + deliverable + records + sha; the
last two are an estimate at write time). (B) Priorities: pedigree-growth
measurement (READY, S, owner-requested S721); owner decisions pending:
package-split disposition, REUSE registration; BACKLOG.md editorial
compression (READY, L). (C) Standing report-only: HANDOFFS.md truncated
duplicate S720 stub (grep for two adjacent `session: S720` blocks);
iCloud Housekeeping item closable pending a duplicates-stay-gone
confirmation.

**Key files:** `CLAUDE.md` (whole Adaptations section reshaped;
overview/TDD/BTV untouched), `PROJECT_LEARNINGS.md` tail (Learning 770),
`BACKLOG.md` (campaign item removed), `CHANGELOG.md` S725 entries.

**Gotchas for the next session:** (1) **CLAUDE.md is now under ceiling
but in the warn band — any growth commit trips the pre-commit hook’s
relative rule; put new adaptation narrative in `PROJECT_LEARNINGS.md`
and keep only the rule + pointer in `CLAUDE.md`** (the Learning 770
method, recorded there as point 6). (2) The context-budget expected
state changed: reds are no longer “by design” — a `CLAUDE.md` red is now
a finding. (3) Standing: every `methodology_trim.py` run needs
`--budget-bytes 65536`; the stray `~$e Compounding Loop.html` still
makes `devtools::check()` warn and exit 1 non-interactively; `renv.lock`
carries no dev tooling (`Rscript` out-of-sync banner expected). (4)
Full-suite baseline unchanged this session (no test-read files touched):
2437/0/0/184/0.
