# Handoff Receipts — durable close-out proof

The cumulative, append-only record of **each session's close-out handoff**, distilled into a
machine-checkable block. It is the durable answer to *"was close-out actually performed, and what
did the session hand its successor?"* — the part of close-out that otherwise lives only in the
transient `SESSION_NOTES.md` (overwritten every session) or the spoken report (which leaves no file
at all).

One `handoff` block per **session** (not per commit), newest on top. The canonical-only
`bin/check-handoff` (copy it into your `bin/` if you want the structural check) asserts each block is
present and structurally complete; the next session's Phase 0 reconcile greps this file for a missing
or still-`pending` receipt and backfills it — that reconcile, not the checker, is the dependable
backstop, so the discipline needs no tooling. Together — a write-step at close-out **and** a
reconcile-on-read backstop — this makes a skipped handoff *detectable* rather than silent.

> **A green `bin/check-handoff` is not a good handoff.** The check verifies presence and structure,
> never semantic quality. Faithfulness is still scored 1–10 by the next session (Phase 3A). A
> well-formed but hollow receipt passes the check and is caught only by that human judgement.

## How to write a receipt

**At Phase 1B (claim the session)** — write the stub block below with `status: pending`, filling what
you can, and commit it with your session-claim commit. This committed `pending` block is the crash
breadcrumb: if the session ends before close-out, the next session's Phase 0 reconcile sees it.

**At Phase 3D (close-out)** — overwrite that block in place to `status: complete` and fill every
field. The block must satisfy all six Minimum Handoff Requirements (`SESSION_RUNNER.md` §3D).

## Format — a fenced `handoff` block

````
```handoff
session: S<N>
date: YYYY-MM-DD
status: <pending | complete>
self_score: <1-10>
predecessor_score: <1-10>
active_task: <current state>
what_was_done: <what you did, including a commit sha — or the literal `pending`>
next_steps: <specific and actionable; never "pick next from backlog">
key_files: <each entry carries a path:line token, e.g. SessionManager.java:245>
gotchas: <traps the next session should watch for>
runtime_smoke: <a run result, or "n/a — docs-only", or "impossible: <reason>">
changelog_ref: <PR #N or a short-sha into CHANGELOG.md>
commit: <short-sha — or `pending` until the next session reconciles it>
```
<free-text prose: the durable proxy for the Phase 3G spoken report, plus the +/- self-score breakdown>

Write clean `key: value` lines — no inline `#` comments (a `#` is a literal value character,
as in `changelog_ref: PR #52`). The keys are the six Phase 3D Minimum Handoff Requirements (the sixth
*is* `self_score`) plus `predecessor_score` (the Phase 3A evaluation) and a little metadata. `status`
is `pending` at the Phase 1B claim and `complete` at
close-out; a third value, `reconciled`, is written *only* by a later session's Phase 0 reconcile
when it reconstructs a receipt a crashed session never completed — you never write it yourself.
````

`self_score` and `predecessor_score` are distinct keys so one can never stand in for the other; omit
`predecessor_score` on Session 1 (there is no predecessor to score). `commit: pending` and
`what_was_done: pending` are legal at write time (the receipt ships in the very commit whose sha it
would name); the next session reconciles them to real shas.

## Size, and when to archive

This file gains a receipt every session and Phase 0 reads it every session, so it carries the same
size discipline as `CHANGELOG.md`: **two caps, two distinct failure modes, fire if either fires,
stop only when both stop conditions hold.**

| Cap | Protects against | Form | Fire when | Cut until |
|---|---|---|---|---|
| **Lines** — ~2,000, the agent `Read` truncation cap | **silent truncation**: a read past the cap returns no error and no marker | a **rate** | headroom < **15** receipts | headroom > **30** |
| **Bytes** — a per-file budget, default **65,536 B** (64 KB) | **context tax**: every session pays for the whole file, every time | a **level with hysteresis** | `size > budget` | `size ≤ ½ × budget` |

**Run this rather than estimating it:**

```sh
python3 methodology_trim.py --file HANDOFFS.md --check
```

`--check` evaluates both conditions and never writes. `--write` performs the trim, refuses unless it
can prove the split lossless, and **neither commits nor stages** — it leaves this file modified and
the new shard *untracked*, and leaves the commit to you (`git add HANDOFFS.md docs/archive/`).

An archive is a **shard**: a new frozen file, same format, same newest-on-top order.

- **Path: `docs/archive/HANDOFFS-through-<CUT-KEY>.md`.** Both halves are load-bearing — the
  directory keeps the shard from shadowing this file, and the `HANDOFFS-` prefix is what the
  trigger's own glob looks for. A shard named otherwise is silently invisible to it.
- **This file keeps one short pointer** naming each shard, the span it covers and how many receipts
  it holds — with the command that recomputes those counts, never a hand-maintained number.
- **The shard back-links here and states only facts about itself.** It must not restate a
  forward-looking rule: a shard is frozen, so a rule copied into one cannot be corrected when the
  live rule moves.
- **After a split, anything that enumerates receipts must span both** — `HANDOFFS.md
  docs/archive/HANDOFFS-*.md` — or it silently counts a shrunken population.

If a `CHANGELOG.md` sits beside this file, its own **Size, and when to archive** section carries the
reasoning both files share: why the line cap must be a rate, why the byte cap cannot be one, and how
to choose the budget. Everything needed to *act* is here.

What is specific to *this* file, and gets receipts wrong if assumed:

- **A record is a `handoff` block *plus the prose beneath it*, not the fence alone.** The self-score
  and predecessor-score paragraphs sit outside the fence and belong to the receipt above them. A
  fence-only cut severs every receipt from its own scoring.
- **Archive oldest-first by position, never by sorting on `session:`.** Two independent `S<N>`
  sequences can share one ledger — a fork and its upstream each running their own counter — and
  their numbers collide. The record's identity is **session + date**.
- **A trim leaves the newest-receipt check alone and moves what the older-receipt checks see.**
  Phase 0 reconcile is frontier-based and a structural checker applies the full schema to the newest
  receipt only, so neither is disturbed. Its other passes are not so confined — an answer-slot rule
  reads every receipt below the newest, and a locator-form rule reads every receipt in the file. So
  after a trim, **run the checker against each shard as well**, and recompute any "all N older
  receipts" count from the files rather than carrying it forward.
- **Never trim to zero receipts.** An empty receipt ledger is indistinguishable from a broken one.
- **A shard freezes, with one exception this file needs:** a `commit:` answer slot may still be
  reconciled inside an archived receipt, because that field was always going to be filled by a later
  session. Nothing else in a shard is rewritten.

**Archived 181 record(s), 2026-07-08 → 2026-08-10** into [`docs/archive/HANDOFFS-through-2026-08-10.md`](docs/archive/HANDOFFS-through-2026-08-10.md) — same format, same order, frozen.
Losslessness is proved by [`docs/archive/HANDOFFS-through-2026-08-10.md.verify.sh`](docs/archive/HANDOFFS-through-2026-08-10.md.verify.sh), which re-derives L1/L2/L3 from git; run it rather
than trusting this sentence. Written by `methodology_trim.py` v1.1.2.

**Archived 39 record(s), 2026-08-10 → 2026-08-12** into [`docs/archive/HANDOFFS-through-2026-08-12.md`](docs/archive/HANDOFFS-through-2026-08-12.md) — same format, same order, frozen.
Losslessness is proved by [`docs/archive/HANDOFFS-through-2026-08-12.md.verify.sh`](docs/archive/HANDOFFS-through-2026-08-12.md.verify.sh), which re-derives L1/L2/L3 from git; run it rather
than trusting this sentence. Written by `methodology_trim.py` v1.1.2.

```handoff
session: S545
date: 2026-08-13
status: complete
self_score: 8
predecessor_score: 9
active_task: Phase 0 CI-status-check decision -- RESOLVED. Owner chose (via
AskUserQuestion) to run gh run list --branch master --limit 10 every
session, unconditionally; recorded in CLAUDE.md's "Additional Phase 0
steps." 2 mid-turn owner exchanges also actioned: (1) a new BACKLOG.md
item to verify nprcgenekeepr's exported functions can reproduce the
kinship2 R package's own supplementary-material worked examples; (2) a
question about why BACKLOG.md has "(none remaining)" pointer items,
answered, then a new BACKLOG.md item to stop that practice and delete
resolved items outright instead.
what_was_done: Reconciled S544's HANDOFFS.md commit: pending self-reference
to 126711a9 (dd177a80). Claimed the session (c6c6c0a6). Presented the CI
-check decision as a 4-option AskUserQuestion (every-session unconditional
/ push-conditioned / branch-protection-instead / hold); owner picked
unconditional. Wrote the decision into CLAUDE.md's "Additional Phase 0
steps" (new gh run list --branch master --limit 10 step at Phase 0 step 4,
report-don't-fix at step 7, 3 rejected alternatives recorded). Smoke
-tested the exact command: found R-CMD-check.yaml on 126711a9 still
in_progress at 15+ min -- not a red run, but exactly what the new step
exists to catch; reported, not chased. Mid-turn owner request #1: checked
for existing coverage (none -- confirmed via grep and reading the PDF's
first 3 pages: it is kinship2's own supplementary material, Sinnwell/
Therneau/Schaid, Mayo Clinic, distinct from the audits' existing source
PDFs), then added a new BACKLOG.md Housekeeping item, logged only, not
investigated. Mid-turn exchange #2: owner asked why BACKLOG.md has "none
remaining" items; grep-verified SESSION_RUNNER.md Phase 3F/FM#27 both say
to remove completed items outright, confirmed 57 of ~75 top-level bullets
are rewrite-in-place pointers instead, answered without editing anything
(a question, not an instruction -- FM#23); owner then explicitly asked for
a BACKLOG.md item -- added one (READY, Effort L, given 57 items need
individual CHANGELOG.md-coverage verification before deletion). Updated
BACKLOG.md (3 items: CI-check resolved, 2 new) and PROJECT_LEARNINGS.md
(Learning 552).
next_steps: BACKLOG.md priorities unchanged from S544 except the resolved
CI-check item and 2 new items: (1) Write the Pedigree Diagram tutorial
article (READY, Effort M). (2) Reopen the S325 CHANGELOG.md legacy-footer
migration decision (DECISION NEEDED, Effort L). (3) Issue #148 (MHC
haplotype reporting) needs a scope-narrowing conversation. (4) Issue #138
(full-colony rendering) needs its own scoping session. (5) NEW: verify
kinship2-supplement-PDF results/plots are reproducible with nprcgenekeepr
exported functions (READY, Effort M) -- reconstruct the PDF's "fam1" 17
-subject pedigree as a fixture first. (6) NEW: delete the 57 "(none
remaining)" BACKLOG.md pointer bullets outright rather than compress them
further (READY, Effort L) -- verify each has CHANGELOG.md coverage before
deleting, per the S529 precedent. (7) NPRC outreach owner review (DECISION
NEEDED); LabKey remaining recs (BLOCKED) unchanged. **Also: the
R-CMD-check.yaml run flagged in_progress this session (126711a9) was never
confirmed complete -- the next session's own new Phase 0 CI check is what
should confirm it, not an assumption that it finished green.**
key_files: CLAUDE.md:201-224 (new "GitHub Actions CI status check"
subsection); BACKLOG.md (CI-check item resolved; 2 new items, Housekeeping
section top); PROJECT_LEARNINGS.md Learning 552 (new).
gotchas: (1) `gh run list` (unfiltered) is required, not `gh run list
--workflow=<one>` -- a single named workflow can be green while a sibling
is red on the same commit (Learning 549's own precedent, reused here).
(2) inst/extdata/reference/NIHMS593658-supplement-supplement_1.pdf is
currently untracked in git and NOT yet in .gitignore/.Rbuildignore, unlike
its 2 copyrighted siblings in the same directory (5201430.pdf,
bioinformatics_24_2_279.pdf) -- do not `git add` it without first deciding
whether it needs the same copyright-driven exclusion treatment.
(3) PROJECT_LEARNINGS.md entries are appended at the END of the file in
ascending order -- inserting a new Learning by matching an old entry's
text mid-file (rather than the tail) can land it BEFORE the entry it
should follow; verify final ordering with `grep -n "^#### Learning"` after
inserting, not just that the content landed somewhere. (4) Before deleting
any of the 57 "(none remaining)" BACKLOG.md items (new item above), verify
CHANGELOG.md coverage exists for each one first -- S529 found 2 cases
where it didn't and had to backfill before compressing; the same gap could
exist here and deleting without checking would be a real information loss,
not just a relocation.
runtime_smoke: n/a for Shiny runtime (no R/ production code touched) --
the equivalent verification for a Phase-0-process change is running the
newly-documented command itself, which was done (gh run list --branch
master --limit 10, confirmed working and immediately useful).
changelog_ref: this session's own CHANGELOG.md entries, 2026-08-13 ([ad
hoc] the Phase 0 reconcile; [ad hoc] the claim; [BL-phase0CiCheck] the
decision; [ad hoc] the close-out entry covering BACKLOG.md/
PROJECT_LEARNINGS.md findings and the 2 mid-turn backlog additions)
commit: 7021c6f7
```

```handoff
session: S544
date: 2026-08-13
status: complete
self_score: 8
predecessor_score: 8
active_task: test-coverage.yaml CI failure -- RESOLVED. Diagnosed and fixed
find_pkg_src()'s missing inst/ check in test_wordlist_coverage.R; confirmed
test-coverage.yaml green on the real CI run (f4b478c0), along with
R-CMD-check.yaml/pkgdown.yaml/lint.yaml. BACKLOG.md updated (item resolved,
plus 1 new item: an owner-requested Pedigree Diagram tutorial article).
what_was_done: Read the full gh run view --log (not --log-failed) and found
the real failure: test_wordlist_coverage.R:68:3 flagging 146
already-whitelisted domain words. Traced spelling::spell_check_package()'s
source (get_wordlist->get_wordfile->file.path(pkg_path,"inst/WORDLIST")) to
find the hardcoded source-tree-relative lookup. Diagnosed find_pkg_src()'s
devtools::test() fallback branch accepting an INSTALLED package directory
(retains DESCRIPTION, loses inst/ -- flattened into the package root at
install time under covr's R CMD INSTALL --install-tests) as source.
Reproduced byte-for-byte locally via R CMD INSTALL --install-tests +
testthat::test_dir() (not the full covr run) before writing any fix code.
Strict TDD: RED (2 new tests, 1 fails as predicted) -> GREEN (all 3
branches now require dir.exists(file.path(cand,"inst")) via a shared
is_pkg_src() helper; 3 tests pass) -- both gates AskUserQuestion-approved.
Full regression 0 failed/0 error (5,519 passed); devtools::check() 0
errors/0 warnings/1 pre-existing unrelated NOTE; lintr clean. Committed
(cd5eb453 claim, f4b478c0 fix), pushed, polled gh run list until all 4
workflows on f4b478c0 completed: test-coverage.yaml, R-CMD-check.yaml,
pkgdown.yaml, lint.yaml all "completed success". Also actioned a mid-turn
owner request: added a new BACKLOG.md item for a dedicated Pedigree
Diagram tutorial article (checked issue #139 first -- already resolved
S455 but only a paragraph, now stale relative to the tab's much-expanded
feature set) -- logged only, not implemented, to keep this session's
TDD-gated scope to the one approved deliverable.
next_steps: BACKLOG.md priorities unchanged from S543 except the resolved
item: (1) Phase 0 CI-check gap -- DECISION NEEDED on whether/how to add a
gh run list check to Phase 0, Effort S. (2) Reopen the S325 CHANGELOG.md
legacy-footer migration decision -- DECISION NEEDED, multi-session
campaign, Effort L. (3) Issue #148 (MHC haplotype reporting) needs a
scope-narrowing conversation per the ratified sequencing audit. (4) NEW
this session: write a dedicated Pedigree Diagram tutorial article
(BACKLOG.md, owner-requested, READY, Effort M) -- a future session should
inventory the tab's current full feature set against the live app before
drafting. (5) NPRC outreach owner review (DECISION NEEDED, Effort N/A);
LabKey remaining recs (BLOCKED); issue #138 (Tier-3 deferred, no new
evidence) each unchanged from S543.
key_files: tests/testthat/test_wordlist_coverage.R (find_pkg_src() fix +
2 new tests, lines 35-109); BACKLOG.md (test-coverage.yaml item resolved;
new Pedigree Diagram article item); PROJECT_LEARNINGS.md Learning 551
(new).
gotchas: (1) spelling::spell_check_package()'s wordlist lookup is a
hardcoded <path>/inst/WORDLIST -- it has no concept of an installed
package, so ANY future helper that resolves a "package root" for this
guard must keep proving it found a SOURCE tree (inst/ present), not just
a directory with a DESCRIPTION file, which installed packages also have.
(2) covr::package_coverage() runs tests against an R CMD INSTALL
--install-tests copy, not the raw source checkout -- any test relying on
relative-path archaeology to find "the package source" needs to account
for this execution mode specifically; a fast local repro is plain
R CMD INSTALL --install-tests --library=<tmp> . + testthat::test_dir()
with NOT_CRAN=true set, no covr or GitHub Actions required. (3) When
backgrounding a long R command, pass run_in_background: true to the Bash
tool call directly rather than shell-level `&` + log redirection -- the
latter escapes the harness's own task tracking and needs manual ps-based
polling to detect completion (hit this once this session; the earlier
regression-suite run used the correct pattern).
runtime_smoke: n/a for Shiny runtime (no R/ production code touched) --
the equivalent verification for a CI-config fix is the real CI run itself
going green, which was confirmed directly (test-coverage.yaml, plus
R-CMD-check.yaml/pkgdown.yaml/lint.yaml, all "completed success" on
f4b478c0).
changelog_ref: this session's own CHANGELOG.md entries, 2026-08-13 ([ad hoc]
the claim; [BL-testCoverageCovrInstallTests] the fix; [ad hoc] the
close-out entry covering BACKLOG.md/PROJECT_LEARNINGS.md findings and the
mid-turn backlog addition)
commit: 126711a9 (reconciled S545 -- self-reference at write time, per the
S543/S544 precedent: this receipt ships in the commit whose sha it names)
```

```handoff
session: S543
date: 2026-08-12
status: complete
self_score: 7
predecessor_score: 9
active_task: CHANGELOG.md SRF_RED archive-refusal decision -- RESOLVED. Forced the archive
through per owner decision after finding the decisive structural fact (trimmable region capped
at 116,176 B vs. a 935,287 B frozen legacy footer, so no trim can ever clear the byte/line
trigger regardless of force). BACKLOG.md updated with the resolution plus 2 new queued items
(S325 migration decision; possible CHANGELOG.md entry-rate contributor).
what_was_done: Re-derived live SRF numbers (2.9933 vs most-recent-archive boundary 50b65d1;
0.1804 vs largest-drop boundary 0929172a) rather than trusting S542's report; pulled actual
pre/post byte sizes for both boundary events via git cat-file -s, explaining the RED reading as
an artifact of 50b65d1 (2026-08-11) only freeing 35,169 B on top of a file the PRIOR day's
0929172a archive had already settled near its floor. Split the file at its Legacy history
marker (awk 'NR<1374' / 'NR>=1374') and found the trimmable region totals only 116,176 B against
a 935,287 B frozen pre-S325 footer (~14x the byte budget, ~1.8x the line cap) -- meaning no trim
can ever clear the trigger. Presented this to the owner via 2 rounds of AskUserQuestion (the
first, Hold-recommended framing was challenged directly by the owner before this structural fact
was even computed); owner chose to force. Logged the claim commit to CHANGELOG.md first
(e27718f0, clearing P1_UNDOCUMENTED per Learning 545's sequencing), then ran
methodology_trim.py --file CHANGELOG.md --write --force: archived 67 records, 1,051,843 B ->
945,242 B, verified lossless via the tool's own generated verify.sh (L1/L2/L3 OK) before
committing (329344b1). Verified the predicted non-fix empirically post-trim (--check still
FIRES at 945,242 B). Updated BACKLOG.md (resolved the item, added 2 new Housekeeping items) and
PROJECT_LEARNINGS.md (Learning 550).
next_steps: 2 new BACKLOG.md Housekeeping items, both unstarted: (1) Reopen the S325
"freeze legacy, go forward" decision -- the only lever that can actually clear CHANGELOG.md's
byte/line triggers; DECISION NEEDED on whether the campaign is worth running at all, Effort L,
needs its own scoping session. (2) CHANGELOG.md's own ~4-entries-per-session ledger convention
may be a rate contributor analogous to HANDOFFS.md's diagnosed Receipt Inflation (H4) -- not
confirmed causal, needs a future session to measure the housekeeping-vs-deliverable entry-byte
split. Unchanged from S542: test-coverage.yaml CI break (READY to diagnose), Phase 0 CI-check
gap (DECISION NEEDED), NPRC outreach owner review (DECISION NEEDED), LabKey remaining recs
(BLOCKED), issue #138/#148 (each need their own scoping session per their ratified sequencing
audits).
key_files: CHANGELOG.md (1,051,843 B -> 945,242 B, 67 records archived); docs/archive/
CHANGELOG-through-2026-08-12.md (new shard, 67 records); BACKLOG.md (SRF_RED item resolved, 2
new Housekeeping items); PROJECT_LEARNINGS.md Learning 550 (new); /Users/rmsharp/Development/
methodology/docs/planning/ledger-trimmer-design.md (canonical design doc read this session,
§3.3/§5.3/§9-10 -- not part of this repo, but load-bearing for the decision).
gotchas: (1) An SRF_RED refusal's "most recent archive" boundary can be inflated purely by that
prior archive having been small -- pull actual pre/post byte sizes (git cat-file -s <sha>^:<f> /
<sha>:<f>) before trusting the ratio. (2) A file with a large fixed/unarchivable region (this
project's frozen pre-S325 legacy footer) can make SRF irrelevant to the real question -- check
whether the fixed region alone already exceeds the budget before treating SRF as decisive either
way. (3) This session's first AskUserQuestion was under-researched (see self-assessment) -- it
presented the canonical design doc's literal H3 rule without first computing the footer/tagged
split; do the awk-based structural split BEFORE presenting options on a similar future decision,
not after a correction.
runtime_smoke: n/a -- docs/ledger-only change, no runtime/Shiny behavior touched.
changelog_ref: this session's own CHANGELOG.md entries, 2026-08-12 ([ad hoc] the claim; [ad hoc]
the tool's own auto-appended CHANGELOG.md archive entry; [ad hoc] the close-out entry covering
BACKLOG.md/PROJECT_LEARNINGS.md findings)
commit: 4bac5d55
```

```handoff
session: S542
date: 2026-08-12
status: complete
self_score: 8
predecessor_score: 9
active_task: HANDOFFS.md archived (226,617 B -> 8,629 B, 2,908 -> 142 lines). CHANGELOG.md's own
archive attempt refused (SRF_RED) and was deliberately NOT forced -- left for a future session's
scoping decision, logged to BACKLOG.md. 2 new BACKLOG.md Housekeeping findings this session:
test-coverage.yaml CI break (READY to diagnose), CHANGELOG.md SRF_RED (DECISION NEEDED).
what_was_done: Ran methodology_trim.py --file HANDOFFS.md --write: archived 39 of 40 records to
docs/archive/HANDOFFS-through-2026-08-12.md, verified lossless via the tool's own generated
verify.sh (L1/L2/L3 OK) before committing. Confirmed the sole retained record was this session's
own pending stub. Logged the Phase 1B claim commit to CHANGELOG.md first (a2550a1e), per
Learning 545, to clear the tool's P1_UNDOCUMENTED gate. Also ran gh run list beyond the routine
Phase 0 checklist and found test-coverage.yaml failing on origin/master's last 2 pushes (S536,
S540) -- confirmed R-CMD-check.yaml itself had gone green (closing S541's own open question).
Commits: 62882046 (claim), a2550a1e (ledger: record claim), 3ddb59ea (the archive), this
close-out's own commit (sha pending at write time, self-referential).
next_steps: Two new BACKLOG.md Housekeeping items, both unstarted: (1) test-coverage.yaml CI
break -- READY to diagnose, Effort S/M; needs gh run view <id> --log (not --log-failed) or a
local covr::package_coverage() repro to isolate the actual testthat.R failure past the
spelling.R sandbox-path noise. (2) CHANGELOG.md SRF_RED refusal -- DECISION NEEDED, Effort S;
a future session (or the owner) should choose between --force-ing a partial trim now vs.
reopening the S325 legacy-footer migration question. Unchanged from S541: Phase 0 CI-check gap
(DECISION NEEDED), NPRC outreach owner review (DECISION NEEDED), LabKey remaining recs (BLOCKED).
key_files: HANDOFFS.md (archived, 142 lines); docs/archive/HANDOFFS-through-2026-08-12.md (new
shard, 39 records); BACKLOG.md Housekeeping section (2 new items); CHANGELOG.md (claim entry +
tool's own auto-appended archive entry); PROJECT_LEARNINGS.md Learning 549 (new).
gotchas: (1) methodology_trim.py's SRF_RED gate is computed against the MOST RECENT archive
only -- a small preceding trim (yesterday's 11-record CHANGELOG.md archive) can make an
otherwise-healthy file refuse to archive again, while the SAME file reads healthy against its
largest-drop boundary. Read both numbers the tool prints before deciding whether --force is
appropriate; don't force reflexively off the RED reading alone. (2) The P1_UNDOCUMENTED gate
checks CHANGELOG.md's frontier regardless of which file is being trimmed (ledger_rel_for()
always returns "CHANGELOG.md") -- even a HANDOFFS.md-only trim needs the claim commit logged to
CHANGELOG.md first if the claim commit doesn't itself touch CHANGELOG.md. (3) This session ran
the Phase 0 priorities AskUserQuestion picker before the mandatory prose orientation report,
out of CLAUDE.md's documented order -- caught and corrected mid-session by re-reading that
convention; a future session should render the prose report first, every time.
runtime_smoke: n/a -- docs/ledger-only change, no runtime/Shiny behavior touched.
changelog_ref: this session's own CHANGELOG.md entries, 2026-08-12 ([ad hoc] the claim; [ad hoc]
the tool's own auto-appended HANDOFFS.md archive entry; [ad hoc] x2 for the BACKLOG.md findings)
commit: pending
```

