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

------------------------------------------------------------------------

## ACTIVE TASK

### What Session 638 Did

**Deliverable:** Root-caused and fixed the `org.chromium.Chromium.*`
temp-detritus NOTE in `R CMD check` (“checking for detritus in the temp
directory”), which had been reproducing on all 3 `ubuntu-latest` legs
(found S636, confirmed S637, “root cause not yet diagnosed”). **DONE**,
full strict TDD (RED→GREEN, REFACTOR skipped by owner choice — diff
minimal). **Started/Completed:** 2026-08-26 (single session).

**What actually happened, in order:** 1. **Phase 0 orientation** (full
protocol): clean tracked tree, 7 pre-existing untracked items already
triaged by S637. Ledger reconcile found a genuine gap: S637’s own final
close-out commit (`dec55f20`, writing `HANDOFFS.md`/`SESSION_NOTES.md`)
landed after the `CHANGELOG.md` frontier with no entry — the established
“self-reference” pattern (a close-out commit can’t cite its own sha).
Backfilled it the same 2-commit way this project’s precedent already
does: `ce396c87` (fixed S637’s `HANDOFFS.md` receipt `commit:` field) +
`c51202a7` (logged that fix in `CHANGELOG.md`). Rendered the priorities
list; user corrected a housekeeping-note mischaracterization (completed
`BACKLOG.md` items get *removed*, recorded in `CHANGELOG.md` — never
edited in place, already `SESSION_RUNNER.md` Phase 3F’s own rule) and
picked “root-cause the temp-detritus NOTE.” 2. **Claimed the session**
(1B stub + `HANDOFFS.md` pending receipt, commit `cc8d617e`). 3.
**Investigation** (`diagnose` skill): built a fast local feedback loop
despite the bug initially looking CI-only — a disposable `Rscript`
subprocess mimicking `getLiveRenderedPositions()`’s exact pattern,
diffing the OS temp root before/after. Confirmed the bug reproduces
identically on macOS/branded desktop Chrome in seconds, proving the
mechanism is platform-generic, not CI-specific. Direct chromote 0.5.1
source inspection (`asNamespace("chromote")`) found
`getLiveRenderedPositions()` closes only its `ChromoteSession`, never
the parent
[`chromote::default_chromote_object()`](https://rstudio.github.io/chromote/reference/default_chromote_object.html)
singleton — so the underlying Chrome subprocess was only ever
hard-killed by `processx`’s `supervise = TRUE` parent-exit mechanism,
never given a chance to run Chromium’s own
`ProcessSingleton::Cleanup()`. Directly inspected a real leftover
directory’s contents (`SingletonCookie` symlink + `SingletonSocket` Unix
socket) to confirm the mechanism rather than assume from the filename
pattern. 4. **PRE-RED→RED gate** (`AskUserQuestion`): proposed the fix
(one-time, teardown-scoped graceful close) plus a 2-part regression test
(structural + a live mechanism-proof test using a dedicated, non-default
`Chromote$new()` instance) — owner approved. 5. **RED:** wrote
`tests/testthat/test_helper_live_render_positions_teardown.R` (matching
`test_helper_live_render_positions_timeout.R`’s house style) — confirmed
5 structural assertions fail for the right reason (the live
mechanism-proof test passed immediately, since it validates chromote’s
own behavior, not code this session had written yet). 6. **RED→GREEN
gate** (`AskUserQuestion`): owner approved the fix. 7. **GREEN:** added
a guarded, one-time
`withr::defer(chromeParent$close(), envir = testthat::teardown_env())`
registration to `getLiveRenderedPositions()`. Found and fixed a bug in
my OWN test (not the implementation): `fixed = TRUE` combined with
regex-escaped `\\(` searched for literal backslashes that don’t exist.
Confirmed GREEN, sibling timeout test unaffected. 8. **Empirical
verification against the real caller:** ran
`test_positionMatingUnitForest.R` (the only real usage, 3 call sites)
end-to-end as a standalone subprocess — 0 leftover temp-dir entries
before vs. after, matching exactly what R CMD check measures. 9. **The
live mechanism-proof test proved flaky specifically inside
[`devtools::check()`](https://devtools.r-lib.org/reference/check.html)’s
sandboxed subprocess** (0 new entries found even after replacing a fixed
0.3s sleep with a 5s poll) despite working reliably in every standalone
reproduction (including with the default singleton already alive). Root
cause of the sandbox-specific discrepancy not pinned down (`TMPDIR`
inheritance and `find_chrome()` resolution both checked, both matched).
Per `diagnose`’s “after 2 failed attempts, stop and reconsider” — and
since this test never exercised the actual fix’s code path anyway —
presented the finding via `AskUserQuestion`; owner approved dropping it
rather than chasing further, keeping the structural test as the sole
automated regression guard. 10. **GREEN→REFACTOR gate**
(`AskUserQuestion`): owner approved skipping REFACTOR (diff minimal).
11. Committed in 2 checkpoints (5-file cap): fix (`03e3bd52`), then
documentation — `PROJECT_LEARNINGS.md` Learning 671, `CLAUDE.md`
learnings-count pointer, `BACKLOG.md` (removed the resolved item per
`SESSION_RUNNER.md` Phase 3F’s own rule — completed items are removed,
not edited in place — and filed 1 new, unrelated, incidentally-found
item: `ubuntu-latest (oldrel-1)` failing at the `setup-r@v2` step
itself, a `sudo`/R-installer infra error found while watching CI, not
chased), `CHANGELOG.md` (commit `cd4f968c`). 12. **Verified locally
before pushing:** full clean regression 0 failed/0 error/6446 passed;
[`devtools::check()`](https://devtools.r-lib.org/reference/check.html) 0
errors — “checking for detritus in the temp directory … OK” for the
first time — 1 WARNING + 1 NOTE both confirmed pre-existing local-only
clutter (non-portable filename, `scratchpad/`), not new;
`lintr::lint_package()` 0 lints. 13. **Pushed** (owner-approved via
`AskUserQuestion`) and watched the real CI run (`32969359216`) to
completion (~23 min). **All 5 platforms `success`; confirmed via direct
per-platform job-log inspection (not the abbreviated summary) that all 3
`ubuntu-latest` legs (`release`/`oldrel-1`/`devel`) now show
`checking for detritus in the temp directory ... OK` and `Status: OK`**
– the NOTE is gone. 0 test failures anywhere (`FAIL 0` grepped directly
from the `devel` leg’s log). The separately-filed
`ubuntu-latest (oldrel-1)` `setup-r@v2` infra flake did NOT reproduce
this run (succeeded cleanly) – consistent with the
one-off-transient-flake hypothesis noted in `BACKLOG.md`, though still
not proven absent by a single clean re-run alone.

**Self-assessment (Session 638): 8/10.** **Strengths:** (1) built a
fast, cheap local feedback loop for a bug that initially looked CI-only,
turning a slow CI-round-trip debugging loop into a several-second one —
the `diagnose` skill’s own core discipline, applied faithfully; (2)
traced the root cause to an actual library-internals mechanism
(chromote’s own source, Chromium’s documented `ProcessSingleton`) rather
than guessing from the filename pattern alone, directly inspecting a
real leftover directory’s contents to confirm; (3) verified the fix
empirically against the REAL caller (the actual test file that uses the
helper), not just an isolated synthetic repro; (4) caught and fixed a
bug in my OWN test (the `fixed = TRUE` + regex-escape mismatch) rather
than assuming the implementation was wrong when the first re-run still
failed; (5) recognized a genuinely flaky, tangential supplementary test
for what it was (not testing the actual fix, environment-specific,
already had 2 failed fix attempts) and stopped chasing it per
`diagnose`’s own guidance, rather than either silently leaving it flaky
or endlessly iterating; (6) followed strict TDD faithfully with an
explicit `AskUserQuestion` gate at every phase transition, including the
mid-GREEN scope-adjustment question when the live test’s flakiness
surfaced. **Weaknesses:** (1) the root-cause investigation and the
flaky-test back-and-forth together consumed 3 separate
[`devtools::check()`](https://devtools.r-lib.org/reference/check.html)
runs (~4-5 min each) — the FIRST
[`devtools::check()`](https://devtools.r-lib.org/reference/check.html)
run could have been deferred until after resolving the live test’s
design, since the structural tests alone (verified via the much faster
`test_file()`) already gave high confidence before that first full-check
cycle; (2) did not anticipate the live mechanism-proof test’s
sandbox-specific flakiness at PRE-RED gate time — the design looked
sound in isolation and there was no obvious signal beforehand that it
would behave differently under
[`devtools::check()`](https://devtools.r-lib.org/reference/check.html)’s
subprocess.

**Gotchas for a future session:** (1) chromote’s Chrome-launch args
never pass `--user-data-dir` — Chromium’s own fallback creates a
randomly-named ephemeral profile dir per launch; this is generic
Chromium behavior, not chromote-specific, so the same leak class could
recur anywhere else in this codebase that launches Chrome without
gracefully closing its OWN parent `Chromote` object (audit any future
direct `chromote::Chromote$new()`/`default_chromote_object()` use the
same way). (2) The dropped live mechanism-proof test’s sandbox-specific
flakiness (0 new entries found even after a 5s poll, inside
[`devtools::check()`](https://devtools.r-lib.org/reference/check.html)
specifically) remains an open, unexplained data point — `TMPDIR`
inheritance and `find_chrome()` resolution were both checked and matched
between environments, so the actual cause is still unknown; a future
session investigating chromote/sandbox interactions should treat this as
a real, reproducible discrepancy worth another look, not dismiss it. (3)
The `CHANGELOG.md`/`HANDOFFS.md` self-reference gap pattern (a session’s
own final close-out commit can’t cite its own sha) recurred again this
session for S637 — same established 2-commit workaround applied; expect
it to recur for S638’s own close-out too, and the next session’s Phase 0
should backfill it the same way if not already done by the time that
session starts. (4) `BACKLOG.md`’s “Up Next” top item is now
`test-coverage.yaml`’s missing Chrome-provisioning steps (READY, Effort
S) — matches `R-CMD-check.yaml`’s proven 3-step fix pattern exactly,
should be a fast pickup.

### Session 636 Handoff Evaluation (by Session 637)

**Score: 7/10.** **What helped:** gotcha (1) correctly framed the CI
break as a DECISION NEEDED item requiring an owner trade-off weigh-in
before a session acts, not a routine pickup – matched exactly: this
session needed 2 `AskUserQuestion` rounds (fix-approach candidates, then
the temp-detritus NOTE scope) before any code was written, precisely as
the handoff anticipated. Gotcha (3) (the CI-break tracking convention –
fix as found or defer via `BACKLOG.md`, never a standalone GitHub issue)
was directly actionable: applied it correctly to both NEW findings this
session surfaced (the temp-detritus NOTE reproducing further, and the
unrelated `test-coverage.yaml` Chrome-provisioning gap), filing both to
`BACKLOG.md` with no GitHub issue ever considered. `key_files`’ framing
of `.github/workflows/R-CMD-check.yaml:97-100` as “the live CI break –
NOT edited this session” was accurate and useful context. **What was
missing:** the handoff’s own `BACKLOG.md` entry (which it pointed to,
rather than duplicating) listed 4 candidate fixes – loosen `error-on`, a
narrower `rcmdcheck` allowlist, redesign Track C’s kinship2 usage, or
hold – and none of the 4 was “check whether kinship2 is actually
declared in `DESCRIPTION` at all.” A direct `grep DESCRIPTION` (this
session’s own first investigative step after the user pushed back on
scope) found the real, much-simpler root cause in under a minute: it was
never declared. This is a genuine gap in S636’s own analysis, not an
unknowable one – the same
[`devtools::check()`](https://devtools.r-lib.org/reference/check.html)
run S636 already had in hand states the WARNING is specifically about an
*undeclared* dependency, which is a direct pointer to checking
`DESCRIPTION` first, before reasoning about bigger structural
trade-offs. **What was wrong:** nothing found inaccurate – gotcha (2)
(“no further tracks – A/B/C/D are all DONE”) remains true, untouched
this session. **ROI:** moderate – the process/convention guidance
(gotchas 1/3) saved real back-and-forth, but the technical candidate
list needed to be set aside rather than built on, costing this session
its own from-scratch root-cause investigation rather than a shorter
verify-and-apply.

### What Session 637 Did

**Deliverable:** Fixed the `R-CMD-check.yaml` CI break (`BACKLOG.md` “Up
Next” top item, found S636) to a genuinely clean 0 errors/0 warnings/0
notes baseline in CI, per owner-directed “broader” scope (not just a
green checkmark). **DONE**, full strict TDD (RED→GREEN, REFACTOR skipped
by owner choice – diff already minimal). **Started/Completed:**
2026-08-26 (single session).

**What actually happened, in order:** 1. **Phase 0 orientation** (full
protocol): clean tracked tree (7 untracked items, all traced to
pre-existing clutter or S636’s own uncleaned render byproducts, not a
new ghost session). Ledger frontiers current (`CHANGELOG.md` at HEAD;
`HANDOFFS.md` one commit behind, the established
self-reference-workaround pattern). `gh run list` showed the last
completed `R-CMD-check.yaml` run RED (all 5 platforms) – the exact
finding S636 left. Dashboard 96/100, 1 HIGH risk (the same
carried-forward FM \#28 ledger-size finding). Rendered the priorities
list (4 numbered items) via `AskUserQuestion`; owner picked “Fix CI red
build.” 2. **Owner asked a clarifying question before committing to
scope**: “is the goal 0 errors/0 warnings/0 notes?” A live
[`devtools::check()`](https://devtools.r-lib.org/reference/check.html)
run plus direct comparison against the actual failed CI job log (not
assumed from the local run alone) showed the honest answer was more
nuanced: 2 of the local WARNING/NOTE findings were purely local
untracked clutter invisible to CI; CI’s own real state was 1 WARNING
(kinship2) + 1-2 NOTEs. Presented this distinction; owner chose
“broader” – pursue a genuinely clean CI baseline, not just silence the
failing gate. 3. **Investigated before proposing a fix approach** (this
session’s own initiative, not from the handoff): grepped `DESCRIPTION`
directly and found `kinship2` was never declared at all – the 4
candidate fixes `BACKLOG.md` listed had all missed this simpler root
cause. Root-caused the `vignettes/figure` NOTE the same way: traced to
one dead, git-tracked PNG (`c18b7fd6`) that nothing in the repo actually
reads. Found a 3rd, brand-new NOTE (`org.chromium.Chromium.*` temp
detritus, `ubuntu-latest oldrel-1` only) with no prior documentation.
Presented all 3 findings; owner confirmed fixing the first 2 (fully
diagnosed, deterministic) and filing the 3rd separately (undiagnosed,
single-occurrence) rather than chasing it this session. 4. **Claimed the
session** (1B stub + `HANDOFFS.md` pending receipt, commit `e335542f`).
5. **PRE-RED→RED gate** (`AskUserQuestion`): proposed the exact fix (add
`kinship2` to `Suggests:`; `git rm` the dead PNG; new guard test) –
owner approved. 6. **RED:** wrote
`tests/testthat/test_r_cmd_check_clean_baseline.R` (2 `test_that()`
blocks, following `test_rbuildignore.R`’s established style: parse
`DESCRIPTION`/filesystem state directly, no package install needed) –
confirmed both fail for the right reason (kinship2 absent from
`Suggests`; `vignettes/figure/` still present). 7. **RED→GREEN gate**
(`AskUserQuestion`): owner approved the minimum fix. 8. **GREEN:** added
`kinship2` to `DESCRIPTION` `Suggests:`; `git rm -r vignettes/figure`.
Confirmed both new tests pass. Ran a full
[`devtools::check()`](https://devtools.r-lib.org/reference/check.html):
the kinship2 WARNING and the `figure` NOTE are BOTH gone from the real
check output – the 1 remaining WARNING + 1 NOTE are the same local- only
clutter identified in step 2 (confirmed, not assumed). Full clean
regression: 0 failed/0 error/39 warnings/6439 passed (matches S636’s own
baseline, +2 for the new guards). `lintr::lint_package()` 0 lints on the
new file. `renv::snapshot(dev = TRUE)` recorded `kinship2`/`quadprog`;
`renv::status(dev = TRUE)` confirmed consistent. 9. **GREEN→REFACTOR
gate** (`AskUserQuestion`): owner approved skipping REFACTOR (diff too
small to need restructuring). 10. **Flagged a real,
previously-unverified consequence BEFORE pushing** (matching
`PROJECT_LEARNINGS.md` Learning 669’s own “re-present a trade-off once
its shape is known” rule): `R-CMD-check.yaml`’s
`setup-r-dependencies@v2` (`needs: check`) installs `Suggests` packages,
so declaring `kinship2` there means CI will now actually install it –
flipping Track C’s 6 `skip_if_not_installed("kinship2")` tests from skip
to run, on all 5 platforms, for the first time ever. Confirmed via
direct inspection of the workflow file (not assumed). Presented via
`AskUserQuestion`; owner approved pushing and watching CI to confirm.
11. Committed in 2 checkpoints (5-file cap): mechanical
(`DESCRIPTION`/`renv.lock`/new test/ `vignettes/figure` removal, commit
`526c7fec`), then documentation (`PROJECT_LEARNINGS.md` Learning 670 +
`CLAUDE.md`’s learnings-count pointer, commit `438f3eb8`). Pushed. 12.
**Watched the real CI run to completion** (2 `Monitor` cycles, ~20+ min
total – the live- kinship2 tests actually running for the first time
added real wall-clock time neither this session nor S636 had observed
before). Along the way, incidentally found `test-coverage.yaml` (a
DIFFERENT workflow, for the PREVIOUS commit) had failed on a known
chromote Chrome-launch flake (S616/S618/S619/S629’s own diagnosed
signature) – confirmed via direct job-log inspection that
`test-coverage.yaml` has zero Chrome-provisioning steps (unlike the
other 2 CI workflows) and isn’t even covered by the existing guard
test’s `workflow_files` vector. Did NOT fix it – unrelated to this
session’s own negotiated scope, filed to `BACKLOG.md` instead (Learning
382 precedent: report an incidentally-discovered, unrelated gap, don’t
fix it mid-session). 13. **Confirmed the real result via direct
per-platform job-log inspection**, not the abbreviated summary table:
`macos-latest`/`windows-latest` are a genuine `Status: OK` (0/0/0); the
3 `ubuntu-latest` legs show only the separately-filed temp-detritus
NOTE, now confirmed reproducing on all 3 (previously seen on only 1).
Grepped the full 5-platform log for `FAIL` and for “kinship2 is not
installed” – 0 and 0 respectively, confirming the skip-to-run flip
landed cleanly with no new failures anywhere. 14. Updated `BACKLOG.md`
(resolved the top item with full CI-confirmed detail; filed 2 new items
– the temp-detritus NOTE now confirmed on all 3 ubuntu legs, and the
separate `test-coverage.yaml` gap) and `CHANGELOG.md`, committed
(`2224d1ec`).

**Self-assessment (Session 637): 8/10.** **Strengths:** (1) did not
trust the predecessor’s own candidate-fix list at face value – grepped
`DESCRIPTION` directly and found a materially simpler, correct root
cause none of the 4 candidates named; (2) caught and corrected its own
initial framing gap when the owner asked a clarifying scope question,
rather than defending the narrower reading – distinguished real
CI-visible findings from local-only clutter via direct comparison
against the actual failed CI job log, not assumption; (3) proactively
surfaced the Suggests-declaration’s real CI-behavior consequence
(skip-to-run flip) BEFORE pushing, matching the project’s own
established “re-present a trade-off once its shape is known” discipline,
rather than letting it surface as a surprise; (4) followed strict TDD
faithfully with an explicit `AskUserQuestion` gate at every phase
transition; (5) live-verified via direct per-platform log inspection
rather than trusting the abbreviated CI summary table, which is exactly
what surfaced the temp-detritus NOTE’s now-confirmed 3-platform
reproduction; (6) found 2 more real, unrelated findings mid-session (the
detritus NOTE’s wider reproduction; the completely separate
`test-coverage.yaml` gap) and correctly did NOT fold either into this
session’s own deliverable, filing both to `BACKLOG.md` instead.
**Weaknesses:** (1) the CI-watch phase took much longer than anticipated
(~20+ minutes across 2 `Monitor` cycles) – foreseeable in hindsight (the
live-kinship2 tests actually running for the first time was the whole
point of the fix) but not explicitly estimated before pushing, so the
wait wasn’t flagged as an expected cost up front; (2) initially answered
the owner’s “is the goal 0/0/0” question by treating it as settled by
`BACKLOG.md`’s own framing before doing the comparative CI-log check
that revealed the real, more nuanced picture – the right investigation
happened, but only after the owner’s question prompted it rather than
before presenting an initial (slightly imprecise) scope summary.

**Key files:** `DESCRIPTION` (the one-line `Suggests:` fix, the actual
root cause), `tests/testthat/ test_r_cmd_check_clean_baseline.R` (new
regression guard, 2 `test_that()` blocks, follows
`test_rbuildignore.R`’s style),
`vignettes/figure/plot-focal-age-sex-pyramid-1.png` (removed – confirmed
dead via `a2interactive.Rmd:340`’s live-regenerating chunk), `renv.lock`
(records kinship2/quadprog), `.github/workflows/R-CMD-check.yaml:39-42`
(`setup-r-dependencies@v2` `needs: check` – NOT edited, but its behavior
is why kinship2 now installs in CI),
`.github/workflows/test-coverage.yaml` (the new, separate, unrelated gap
– zero Chrome-provisioning steps, not fixed this session),
`tests/testthat/test_r_cmd_check_workflow_chrome_setup.R:33` (the
existing guard’s `workflow_files` vector – doesn’t cover
`test-coverage.yaml`, a future fix needs to extend it too),
`PROJECT_LEARNINGS.md` Learning 670 (all 3 findings), `BACKLOG.md` (1
item resolved, 2 new items filed).

**Gotchas for a future session:** (1) **The temp-detritus NOTE
(`org.chromium.Chromium.*`) now confirmed reproducing on all 3
`ubuntu-latest` legs** (previously seen on only 1) – root cause not yet
diagnosed, but no longer a rare flake; a future session should be able
to reproduce it on demand. Likely candidate: a chromote
`ChromoteSession` not `$close()`-ing in some test’s teardown – start
with `tests/testthat/helper-live-render-positions.R` and
`data-raw/kinship2FidelityValidation.R`’s `screenshot_layout()`. (2)
**`test-coverage.yaml` will keep failing intermittently** until it gets
the same 3-step Chrome-provisioning fix
`R-CMD-check.yaml`/`R-CMD-check-scheduled.yaml` both already have
(S618/S619/S629’s own precedent) – a future session fixing it must ALSO
extend `test_r_cmd_check_workflow_chrome_setup.R`’s `workflow_files`
vector to cover it, or the fix itself is unguarded against regressing.
(3) Track C’s 6 live-kinship2 tests now actually run in CI (not skip) on
every platform, for the first time ever – this is intentional and
confirmed clean (0 failures), but a future CI failure in
`test_comparePedigreeStructure.R` is now a real possibility that was
structurally impossible before this session (previously the tests never
executed in CI at all). (4) The kinship2 structural-comparison plan
(Tracks A-D) has no further work – confirmed independently again this
session; a future session touching pedigree-diagram/kinship2 work should
consult `BACKLOG.md`’s “Up Next” fresh rather than assume there’s more
there. **Score: 7/10 – Session 636’s handoff evaluated above.**

### Session 635 Handoff Evaluation (by Session 636)

**Score: 9/10.** **What helped:** `next_steps`/`active_task` named
exactly what this session did (“Implement Track D … port the `$go_to()`
chromote fix into `data-raw/ kinship2FidelityValidation.R`’s
`screenshot_layout()`, regenerate every Track B/C image, run
`compareAgainstKinship2()` against the vignette’s own Track B/C fixtures
specifically, and remove the S631 caveats … ONLY if that comparison
supports it”) – this was followed literally end to end. `gotchas` (3)
(“Track D should reuse `toKinship2Pedigree()` … via
`source(file.path("tests", "testthat", "helper-comparePedigreeStructure.R"))`
rather than re-deriving the sire/dam-swap logic again”) gave the EXACT
[`source()`](https://rdrr.io/r/base/source.html) call used verbatim this
session – direct, real time saved. Gotcha (4) (the WARNING count is now
permanently 2, do not treat as a new regression) was applied correctly:
this session’s own
[`devtools::check()`](https://devtools.r-lib.org/reference/check.html)
confirmed 2 WARNINGs/2 NOTEs, unchanged from that baseline, and did not
flag it as new. **What was missing:** no gotcha flagged that plan §4.4’s
literal “remove the S631 caveats from both \[documents\] … if that
comparison supports it” text doesn’t actually hold up under scrutiny –
`pedigree-diagram-kinship2-reference-comparison.qmd` rests on 4
completely different example pedigrees never touched by the Track B/C
comparator, a gap this session had to discover by actually reading that
second document’s own examples in full (see `PROJECT_LEARNINGS.md`
Learning 668). This is a fair, non-culpable gap: S635 was scoped to
Track C and had no obligation to pre-read Track D’s own two target
documents in depth; the plan itself (S632) is the more natural place
this should have been caught. **What was wrong:** nothing found
inaccurate – gotcha (2)’s “CI skip-vs-run behavior… still needs visual
confirmation once pushed” remains accurate and is still not discharged
(see gotchas below; this session’s commits are also not yet pushed as of
this write-up). **ROI:** high – the exact
[`source()`](https://rdrr.io/r/base/source.html) line and the WARNING-
baseline framing were both used directly; the one gap cost real
investigation time but was not something the handoff could reasonably
have caught in advance.

### What Session 636 Did

**Deliverable:** Implemented **Track D** of
`docs/planning/pedigree-diagram-kinship2-structural- comparison-plan.md`
(§4.4) – ported the `$go_to()` chromote fix into
`data-raw/ kinship2FidelityValidation.R`’s `screenshot_layout()`,
regenerated every Track B/C image, ran Track C’s
`compareAgainstKinship2()` comparator against the vignette’s own
fixtures, removed the S631 caveat from the published vignette
(supported), left the sibling planning document’s caveat standing (not
supported by any evidence), and added a `NEWS.Rmd` entry. **DONE**, no
RED/GREEN cycle (owner-approved PRE-RED framing – no new package
function exists to test). **All 4 tracks of the kinship2
structural-comparison plan are now complete.** Then pushed
(owner-approved) – the first time any of Track A/B/C/D’s commits ever
reached CI – confirming the outstanding Track C skip-vs-run gotcha
resolved cleanly, but also discovering a genuinely new problem:
`R-CMD-check.yaml` is red on all 5 platforms. Filed it as a GitHub
issue, then closed that issue same-session per a live owner correction
(this project does not track CI breaks as issues) and re-filed it
correctly as a `BACKLOG.md` item instead, adding a matching standing
convention to `CLAUDE.md`. **Started/Completed:** 2026-08-25/26 (single
session).

**What actually happened, in order:** 1. **Phase 0 orientation** (full
protocol): clean tree except the same pre-classified untracked artifacts
S633-S635 already checked (no ghost session – last commit `2e576c9d`,
continuous with this session). Ledger frontiers current (`CHANGELOG.md`
at HEAD; `HANDOFFS.md` one commit behind, the established
self-reference-workaround pattern). CI green (10/10
`completed success`). Dashboard 96/100, 1 HIGH risk (carried-forward FM
\#28 finding, not acted on). Rendered the priorities list (4 numbered
items) via `AskUserQuestion`; owner picked “Track D.” 2. **Re-read plan
§4.4 in full**, plus `screenshot_layout()` (the race), the reference
`$go_to()` fix in `tests/testthat/helper-live-render-positions.R`, Track
C’s `compareAgainstKinship2()` helper, `.comparePedigreeStructures()`‘s
return shape, and BOTH target documents’ S631 caveats in full – found
the reference-comparison.qmd coverage gap during this read (4 different,
untested example pedigrees), not assumed. 3. **PRE-RED scope gate**
(`AskUserQuestion`, 2 questions): (1) whether to run a RED/GREEN cycle
for a track with no new package function – owner approved skipping it,
verify functionally instead (matching Learning 643’s own precedent); (2)
how to handle the coverage-gap finding – owner approved leaving
`pedigree-diagram-kinship2-reference-comparison.qmd`’s caveat up
regardless, over following the plan’s literal “remove from both” text.
4. **Claimed the session** (1B stub + `HANDOFFS.md` pending receipt,
commit `555e3fdf`). 5. Ported the fix, added the
[`source()`](https://rdrr.io/r/base/source.html) call + Track D
comparator section, ran the script live (kinship2/chromote/htmlwidgets
all available locally) – clean run, `identical = TRUE` on all 3 fixtures
(Track B full, Track B shrunk, Track C). Visually inspected 2
regenerated images against kinship2’s own reference render for the same
fixture (per
`[[verify-diagrams-against-ground- truth]]`/`[[pedigree-comparison-show-images]]`
user memory) – confirmed the structural match the comparator reported
(nprcgenekeepr duplicates `A`, kinship2 duplicates `Y`, for the SAME
underlying relationships). 6. Edited both target documents (removed
vignette’s caveat + added “Structural verification” section + updated
Verdict; added the coverage-gap note to the reference-comparison doc)
and `NEWS.Rmd`. Rendered both `.qmd` files via `quarto render` – clean,
no errors; cleaned up the render byproducts (gitignored/local-only). 7.
**Full verification**, run properly in the true background this time
after a mid-session self-correction (see gotchas):
`lintr::lint_package()` found 1 `undesirable_function_linter` hit on the
new [`source()`](https://rdrr.io/r/base/source.html) call, fixed with
the exact `# nolint start/end` pattern `data-raw/fgSEValidation.R`
already established for the identical case;
[`devtools::check()`](https://devtools.r-lib.org/reference/check.html) 0
errors / 2 WARNINGs / 2 NOTEs, all 4 unchanged from Track C’s own
baseline; full clean regression 0 failed / 0 error / 39 warnings / 6437
passed – the previously-documented `test_wordlist_coverage.R` “1
pre-existing failure” did NOT reproduce (confirmed via an isolated
`test_file()` run too), flagged as a genuine finding rather than
silently repeating the old number from memory. 8. Committed in 2
checkpoints (5-file cap): mechanical (script + 4 images), then
documentation (2 `.qmd` files + `NEWS.Rmd`). Updated `BACKLOG.md`’s top
item (Track D DONE, all 4 tracks complete), added `PROJECT_LEARNINGS.md`
Learning 668, updated `CLAUDE.md`’s learnings-count pointer (667→668,
Sessions 1-635+→1-636+), added the `CHANGELOG.md` entry. 9. First
close-out pass (evaluation + self-assessment + handoff notes +
`HANDOFFS.md` receipt + `CHANGELOG.md` sha-fix trailer, all committed) –
believed complete at this point. 10. Asked the user whether to push (an
outward-facing action, not silently pre-authorized); owner approved.
Pushed `master` – the first time Track A/B/C/D’s 31+6 commits ever
reached CI. Watched `R-CMD-check.yaml` via a background wait loop.
Confirmed the outstanding plan §5 gotcha resolved cleanly: Track C’s 3
live-kinship2 tests skip in CI exactly as designed
(`{kinship2} is not installed (6): ...`) on every platform. **Also
discovered, via direct job-log inspection on 2 platforms (not assumed
from one), a genuinely new problem:** all 5 `R-CMD-check.yaml` matrix
jobs fail identically at `check-r-package@v2`, root-caused to that
action’s default `error-on: "warning"` (uncustomized in this project’s
workflow file) tripping on Track C’s own already-accepted kinship2
WARNING – the first time these commits had ever reached the live CI
gate. See `PROJECT_LEARNINGS.md` Learning 669. 11. Presented the finding
via `AskUserQuestion` (loosen the CI gate now vs. leave red and track
for a dedicated session); owner picked leaving it for a dedicated
session. Filed it as GitHub issue \#165. 12. **User interrupted with a
live correction:** this project does not file GitHub issues for CI
breaks – fix as found, or defer via `BACKLOG.md`; it’s fine if a future
session picks it up. Closed issue \#165 immediately, rewrote the
`BACKLOG.md` item as the sole tracker (with the full root-cause detail +
4 candidate fix approaches that had been in the issue body), fixed the
“filed as issue \#165” framing in the `CHANGELOG.md` entry and in
`PROJECT_LEARNINGS.md` Learning 669’s own closing sentence, and added a
new standing “CI-break tracking convention” checklist entry to
`CLAUDE.md` (mirroring the existing checklist-entry format) so a future
session doesn’t repeat the same file-then-close round-trip. 13. **Second
close-out pass** (this write-up, superseding step 9’s now-stale
narrative) – amended rather than silently left inaccurate, per
`SAFEGUARDS.md`’s re-read-before-edit discipline.

**Self-assessment (Session 636): 9/10.** **Strengths:** (1) found and
did not silently resolve either way a genuine gap between the plan’s
literal text and what the actual verification evidence covers
(`pedigree-diagram-kinship2-reference-comparison.qmd`’s own untested
examples) – presented via `AskUserQuestion` before acting, rather than
mechanically following “remove from both” or unilaterally deciding to
keep both caveats up; (2) correctly recognized that a track with no new
package function doesn’t fit the RED/GREEN/REFACTOR model and raised
that as an explicit PRE-RED scope question rather than either forcing a
hollow test cycle or silently skipping the phase-gate ceremony; (3)
visually cross-checked the regenerated images against kinship2’s own
reference render for the same fixture, not just trusting the
comparator’s boolean output, matching standing user memory on
diagram-comparison rigor; (4) caught and self-corrected a
background-task process- tracking mistake mid-session (see gotchas)
rather than reporting an unverified “completed” result at face value;
(5) did not stop at “commits pushed, CI checked” once it turned red –
root-caused the failure via direct log inspection on 2 platforms before
reporting anything, rather than guessing or assuming it was the
already-anticipated kinship2-skip concern; (6) when corrected live about
the issue-filing convention, applied the fix immediately and completely
– closed the issue, rewrote every file that referenced it (`BACKLOG.md`,
`CHANGELOG.md`, `PROJECT_LEARNINGS.md` Learning 669), and captured the
convention itself in `CLAUDE.md` so it doesn’t need re-teaching.
**Weaknesses:** (1) made the exact nested-`&` background-task mistake
S634/S635’s own documented gotcha warns against, on the FIRST attempt
this session (not the second) – caught only because the resulting log
looked suspiciously short and a direct `ps`/`lsof` check confirmed the
real process was still running; cost real wall-clock time working out
the correct wait condition. (2) closed out once (step 9) before the
push-and-verify work was actually finished, requiring a second close-out
pass – the push was known to be outstanding (gotcha 2, inherited from
S635) but was treated as a separate, optional follow-up rather than
sequenced before the first close-out; a cleaner session would have
pushed and confirmed CI *before* writing the first handoff, avoiding the
rework. (3) filed a GitHub issue for a CI break without first checking
whether this project had a standing convention against it – a plain read
of `BACKLOG.md`’s own existing pattern (S634’s issue \#164 was filed for
a *design-level* incidental finding, not a *CI-health* one) might have
prompted asking before filing, rather than filing and being corrected.

**Key files:** `data-raw/kinship2FidelityValidation.R` (the `$go_to()`
port + Track D comparator section, the deliverable),
`vignettes/articles/kinship2-fidelity-validation.qmd` (caveat removed,
new “Structural verification” section, Verdict updated),
`docs/planning/pedigree-diagram-kinship2- reference-comparison.qmd`
(coverage-gap note added, caveat left standing), `NEWS.Rmd` (Pedigree
Diagram section, new entry),
`docs/planning/pedigree-diagram-kinship2-structural-comparison-plan.md`
§4.4 (Track D’s contract, now fully discharged),
`.github/workflows/R-CMD-check.yaml:97-100` (the `check-r-package@v2`
step whose default `error-on: "warning"` is the live CI break – NOT
edited this session), `PROJECT_LEARNINGS.md` Learning 668 (the
coverage-gap finding + 2 smaller findings) and Learning 669 (the
CI-break root cause + the issue-filing correction), `CLAUDE.md`’s new
“CI-break tracking convention” checklist entry, `BACKLOG.md` (2 items:
Track D all-4-tracks-DONE, and the new CI-red item with 4 candidate
fixes).

**Gotchas for a future session:** (1) **`master`’s CI is currently RED**
(`R-CMD-check.yaml`, all 5 platforms) – see `BACKLOG.md`’s top-of-file
item for the full root cause (Track C’s accepted kinship2 WARNING
vs. `check-r-package@v2`’s default `error-on: "warning"`) and 4
candidate fixes, none decided. This is a DECISION NEEDED item, not a
routine pickup – the owner should weigh the trade-off (loosen the gate
for all warnings vs. a narrower fix vs. redesigning Track C’s kinship2
usage vs. holding) before a session acts. (2) The kinship2
structural-comparison plan
(`docs/ planning/pedigree-diagram-kinship2-structural-comparison-plan.md`)
has no further tracks – A/B/C/D are all DONE, and this is now
independently confirmed by a real CI run (not just local verification).
A future session picking up pedigree-diagram work should consult
`BACKLOG.md`’s “Up Next” section fresh rather than assuming this plan
has more to do. (3) **CI-break convention:** do not file a GitHub issue
for a CI break found live in-session – fix it if in scope, otherwise add
a `BACKLOG.md` item with full root-cause detail (see `CLAUDE.md`’s new
checklist entry). (4) **Background-task discipline, reinforced with a
new failure shape (`PROJECT_LEARNINGS.md` Learning 668):** even when
`run_in_background: true` is used correctly at the TOP level, adding a
manual trailing `&` INSIDE that command
(e.g. `Rscript ... > log 2>&1 &`) makes the harness report “completed”
almost immediately – because the wrapper script itself finishes fast –
while the real process keeps running fully detached. A plausible-looking
partial log is not proof of completion; verify via `ps`/`lsof` on the
actual output file to find the real driver PID, and wait on THAT PID
specifically (a stale/wrong PID in the wait condition, as this session’s
own first fix attempt used, can also report “done” prematurely). (5)
`pedigree-diagram-kinship2-reference- comparison.qmd` still carries an
unverified-claims caveat and always will, absent a future session
running Track C’s comparator (or an equivalent) against ITS OWN 4
example pedigrees specifically – this is not a stale caveat to remove
casually; it is now a checked, deliberate, currently-accurate state.
**Score: N/A – Session 635’s handoff evaluated above (9/10).**

### Session 634 Handoff Evaluation (by Session 635)

**Score: 9/10.** **What helped:** `next_steps`/`active_task` named
exactly what this session did (“Track C
(`.comparePedigreeStructures()` + D-7 fixture + live-kinship2 tests) is
the next pickup”) and the strict A→B→C→D order was reinforced again,
unmodified. `key_files` and `gotchas` were both directly useful: gotcha
(1)’s restatement of plan §3.3/§3.4/§4.3’s scope was used as the literal
task list; gotcha (2)’s D-8 framing (“a non-empty diff on the real
fixture is a genuine finding to report, not silently reconcile”) was
applied directly – this session’s real fixture run came back
`identical = TRUE`, reported as the mirror-image good-news finding, not
silently assumed; gotcha (4) (“CI will skip Track C’s live-kinship2
tests… confirm this visually once”) was actionable and is carried
forward below, still pending a push; gotcha (6) (use
`run_in_background: true` directly, no nested `&`) was followed
correctly this session with no repeat of S634’s own process hiccup.
**What was missing:** gotcha (1) repeated the plan’s own literal text
that `toKinship2Pedigree()`/ the orchestration wrapper should live in
`data-raw/kinship2FidelityValidation.R`, without flagging that this
specific file has hard top-level `chromote`/`htmlwidgets`
[`requireNamespace()`](https://rdrr.io/r/base/ns-load.html)
[`stop()`](https://rdrr.io/r/base/stop.html)s that make it unsourceable
from a test – a real, if minor, gap this session had to discover and
route through its own `AskUserQuestion` gate. This is a fair,
non-culpable gap: S634 was scoped to Track B and had no obligation to
pre-verify Track C’s own file-placement mechanics; the plan itself
(S632) is the more natural place this should have been caught, and even
a careful re-read of the plan’s prose alone would not surface it – it
only became visible by actually trying to write a test that sources the
named file. **What was wrong:** nothing found inaccurate. **ROI:** high
– the scope/ordering guidance was used directly and correctly; the one
gap cost a single extra `AskUserQuestion` round-trip, not real rework.

### What Session 635 Did

**Deliverable:** Implemented **Track C** of
`docs/planning/pedigree-diagram-kinship2-structural- comparison-plan.md`
(§3.3/§3.4/§4.3) – `.comparePedigreeStructures()` in `R/`,
`toKinship2Pedigree()` + `compareAgainstKinship2()` orchestration in a
new testthat helper, a new D-7 crossing-duplication fixture, and
live-kinship2 end-to-end tests against the Track-C fixture, the D-7
fixture, and the real 375-individual bundled fixture (D-8). **DONE**,
full strict TDD (RED→GREEN, REFACTOR skipped by owner-approved choice).
**Started/Completed:** 2026-08-25 (single session).

**What actually happened, in order:** 1. **Phase 0 orientation** (full
protocol): clean tree except the same pre-classified untracked artifacts
S633/S634 already checked (no ghost session – last commit `bfcef69c`,
same day, continuous with this session). Ledger frontiers current
(`CHANGELOG.md` at HEAD; `HANDOFFS.md` one commit behind, but that gap
was itself the established self-reference-workaround pattern, not an
unrecorded action). CI green (10/10 `completed success`). Dashboard
96/100, 1 HIGH risk (carried-forward FM \#28 finding, not acted on).
Rendered the priorities list (4 numbered items) via `AskUserQuestion`;
owner picked “Track C: kinship2 structural comparison.” 2. **Re-read the
plan’s Track C sections in full** (§1.1-1.5, §2, §3.3/§3.4, §4.3) plus
the existing Track A/B implementation (`R/comparePedigreeStructure.R`)
and test file (`tests/testthat/test_comparePedigreeStructure.R`) in
full. 3. **Prototyped and empirically verified everything BEFORE writing
RED** (`scratchpad/ prototype_trackC.R`, `explore_d7_duplication.R`,
`explore_d7_v2.R`): `.comparePedigreeStructures()` against hand-built
structures; `toKinship2Pedigree()` against the existing Track-C
fixture’s known C2 reversal; and, hardest, a NEW D-7 fixture. 6
hand-guessed candidates (including a literal full-sibling-marriage case,
the closest reading of the plan’s one textual hint) all failed to
reproduce kinship2’s own crossing-driven single-mate duplication. Found
the real mechanism only by reading kinship2’s actual unexported source
from a local literate-programming checkout
(`~/Documents/Development/R/r_workspace/kinship2/noweb/*.Rnw`) – traced
it to `spouselist` consumption order across `align.pedigree()`’s
top-level `founders` loop – then predicted and confirmed, on the first
subsequent attempt, that a “double cross-marriage between two founder
sibships” duplicates one member (candidate 5). Directly verified via
`align.pedigree()$nid` (`[5,6,7,5,8]`, A1’s index appearing at 2
columns). Ran the full `compareAgainstKinship2()` pipeline against this
fixture, the existing 9-subject Track-C fixture, AND the real
375-individual bundled fixture: `identical = TRUE` on all three. See
`PROJECT_LEARNINGS.md` Learning 667. 4. **Claimed the session** (1B
stub + `HANDOFFS.md` pending receipt, commit `e8babfb4`). 5.
**PRE-RED→RED gate** (`AskUserQuestion`): proposed the verified design,
INCLUDING a scope/approach deviation –
`toKinship2Pedigree()`/`compareAgainstKinship2()` live in a NEW
`tests/testthat/helper-comparePedigreeStructure.R`, not literally inside
`data-raw/kinship2FidelityValidation.R` as plan §3.4’s text says,
because that script’s own hard `chromote`/`htmlwidgets`
[`stop()`](https://rdrr.io/r/base/stop.html)s would break sourcing it
from a test – matching the project’s own established
`data-raw/fgSEValidation.R` + `tests/testthat/helper-fgSEValidation.R`
split instead. Owner approved the recommended option. 6. **RED:**
appended 10 `test_that()` blocks to `test_comparePedigreeStructure.R` (5
pure `.comparePedigreeStructures()` unit tests; 2 `toKinship2Pedigree()`
unit tests; 3 live-kinship2 end-to-end tests) plus the new D-7 fixture,
and wrote `helper-comparePedigreeStructure.R` in full (test scaffolding,
not the tracked deliverable – matching Track B’s own precedent for the
rectilinear waypoint walker). Ran – confirmed the 5 pure tests + 3
end-to-end tests fail with
`could not find function ".comparePedigreeStructures"`/`object '.comparePedigreeStructures' not found`
(the correct reason); the 2 `toKinship2Pedigree()` tests and the
D-7-duplication-confirming test passed cleanly (scaffolding, correctly
not under this track’s own RED/GREEN cycle). 7. **RED→GREEN gate**
(`AskUserQuestion`): approved. 8. **GREEN:** wrote
`.comparePedigreeStructures()` in `R/comparePedigreeStructure.R`,
exactly the verified prototype algorithm (canonicalize both sides,
vectorized set-diff both directions). Passed clean on the first run. 9.
**GREEN→REFACTOR gate** (`AskUserQuestion`): presented the honest
assessment that no restructuring is needed (already minimal, matches the
prototype, no duplication with Track A/B’s structurally-different
extractors) – owner chose to skip REFACTOR, matching Track A/B’s own
precedent for the same reason. 10. **Lint fix:** `lintr::lint_package()`
(loaded via
[`pkgload::load_all()`](https://pkgload.r-lib.org/reference/load_all.html)
first) found 1 `brace_linter` hit (a multi-line function body without
curly braces), fixed, re-ran clean. 11. **Full verification, run
properly in background this time** (`run_in_background: true` directly,
no nested `&` – applying S634’s own gotcha (6)): full clean regression 1
pre-existing failure (`test_wordlist_coverage.R`, same known baseline) /
0 error / 39 warnings / 6436 passed (up from Track B’s 6395 baseline).
[`devtools::check()`](https://devtools.r-lib.org/reference/check.html):
**0 errors, but 2 WARNINGs** (up from Track A/B’s 1) – a NEW “unstated
dependencies in tests: kinship2” WARNING. 12. **Found and presented a
genuine, unanticipated consequence before finalizing:** confirmed by
grep that Track C’s tests are the ONLY files anywhere in `tests/` with a
REAL executable `kinship2::`/`kinship2:::` call
(`test_kinship.R`/`test_shrinkPedigree.R` only mention kinship2 in
comments/test-description strings, per plan §1.5’s hardcoded-values
design) – this is a purely syntactic `R CMD check` consequence the
plan’s own §1.5 could not have anticipated before the code existed.
Presented 3 options via `AskUserQuestion` (accept & document / avoid via
indirect namespace dispatch / hold pending a CRAN-status check); owner
picked “accept and document,” matching this project’s existing posture
(the pre-existing non-portable-filename WARNING has been carried unfixed
for many sessions as a known baseline item). See `PROJECT_LEARNINGS.md`
Learning 667 for the full write-up of both this and the D-7 discovery
method. 13. **Updated `BACKLOG.md`’s top item**: Track C marked DONE
with verification detail and the WARNING decision; next pickup named as
Track D. Added `PROJECT_LEARNINGS.md` Learning 667; updated
`CLAUDE.md`’s learnings-count pointer (666→667 learnings, Sessions
1-635+). 14. **Close-out** (this write-up). **CI skip-vs-run behavior
for Track C’s live-kinship2 tests is NOT YET visually confirmed** (plan
§5’s own requirement) – this session’s commits have not been pushed as
of this write-up; see gotchas below.

**Self-assessment (Session 635): 9/10.** **Strengths:** (1) when 6
hand-guessed D-7 fixture candidates all failed, switched from “guess and
check” to reading the dependency’s actual unexported source from a local
literate-programming checkout, rather than continuing to iterate blindly
or giving up on empirical proof – this is exactly the discipline the
plan’s own D-7/Learning 596 asked for, applied under real difficulty,
not just on the easy first attempt; (2) found and transparently surfaced
a genuine, previously-unanticipated
[`devtools::check()`](https://devtools.r-lib.org/reference/check.html)
consequence (the new kinship2 WARNING) BEFORE finalizing verification,
with the exact grep evidence distinguishing it from pre-existing
kinship2 mentions, rather than either silently accepting a worse
baseline or silently hiding it; (3) correctly distinguished
test-scaffolding functions (`toKinship2Pedigree()`, matching Track B’s
rectilinear walker precedent) from the tracked TDD deliverable
(`.comparePedigreeStructures()`), so RED correctly failed only for the
right function; (4) applied S634’s own handoff gotcha about
background-task discipline correctly on the first attempt, with no
repeat of the prior session’s process hiccup. **Weaknesses:** (1) the
D-7 fixture search itself cost real time (6 failed candidates before
finding the local kinship2 source checkout) – a faster path might have
been checking for a local dependency source checkout FIRST, before
hand-guessing candidates from the vaguer `.Rnw` comment hint alone; (2)
as of this write-up, the plan’s own explicit “CI skip-vs-run behavior
must be visually confirmed once” requirement is not yet discharged –
carried forward as a gotcha rather than completed in-session.

**Key files:** `R/comparePedigreeStructure.R`
(`.comparePedigreeStructures()`, new, the deliverable),
`tests/testthat/test_comparePedigreeStructure.R` (10 new blocks + the
`.pedCrossMarriageFixture()` D-7 fixture),
`tests/testthat/helper-comparePedigreeStructure.R` (new file,
`toKinship2Pedigree()` + `compareAgainstKinship2()`),
`docs/planning/pedigree-diagram-kinship2-structural-comparison-plan.md`
§3.3/§3.4/§4.3/§4.4 (Track C’s contract; Track D’s up next),
`PROJECT_LEARNINGS.md` Learning 667 (the D-7 discovery method + the
WARNING trade-off), `BACKLOG.md` “Up Next” top item (updated, Track C
DONE / Track D next), `scratchpad/prototype_trackC.R`/`explore_d7_v2.R`
(verified prototypes, session-local, not committed).

**Gotchas for a future session (Track D, the next pickup):** (1)
implement exactly
`docs/planning/ pedigree-diagram-kinship2-structural-comparison-plan.md`
§4.4 – port `PROJECT_LEARNINGS.md` Learning 643’s `$go_to()` fix into
`data-raw/kinship2FidelityValidation.R`’s own `screenshot_layout()`
helper (currently 2 separate `Page$navigate()`/`Page$loadEventFired()`
calls, the exact race-condition class already fixed elsewhere),
regenerate every Track B/C image, run Track C’s new
`compareAgainstKinship2()` against the vignette’s own Track B/C fixtures
specifically, and remove the S631 caveats from both
`vignettes/articles/kinship2-fidelity-validation.qmd` and
`docs/planning/pedigree-diagram-kinship2-reference-comparison.qmd` ONLY
if that comparison supports it – a real discrepancy staying uncaught
(caveats left up) is a correct, valuable outcome per the plan’s own
framing, not something to force past. (2) **CI skip-vs-run behavior for
Track C’s live-kinship2 tests still needs visual confirmation once
pushed** (plan §5) – this session’s commits are local-only as of
close-out; whichever session pushes next should check the
`R-CMD-check.yaml` run’s own test log for a clean `SKIP` on the 3 new
end-to-end tests (kinship2 is absent in CI), not just assume
`skip_if_not_installed()` behaves as documented. (3) `Track D` may want
to reuse `toKinship2Pedigree()` from
`tests/testthat/helper-comparePedigreeStructure.R` via
`source(file.path("tests", "testthat", "helper-comparePedigreeStructure.R"))`
inside `data-raw/kinship2FidelityValidation.R` itself (matching
`data-raw/fgSEValidation.R`’s own established
[`source()`](https://rdrr.io/r/base/source.html) pattern for its paired
helper) rather than re-deriving the sire/dam-swap logic a second time.
(4) The 2nd
[`devtools::check()`](https://devtools.r-lib.org/reference/check.html)
WARNING (“unstated dependencies in tests: kinship2”) is now a permanent
part of this project’s baseline going forward – do not treat it as a new
regression to fix in a future session; it is the accepted, documented
cost of Track C’s live-kinship2 design (`PROJECT_LEARNINGS.md` Learning
667). (5) The dashboard’s HIGH-risk finding (3 files past the FM \#28
2,000-line read cap) is still open, still not acted on, carried forward
again. **Score: N/A – Session 634’s handoff evaluated above (9/10).**

### Session 633 Handoff Evaluation (by Session 634)

**Score: 9/10.** **What helped:** `next_steps` named exactly what this
session did (“Implement Track B … `.extractNprcStructure()`, input is
`makePedigreeMatingLayout(ped, edgeStyle="direct", twinRelations=NULL)`’s
output. Must also include the D-2 edgeStyle-invariance property test …
Strict A-\>B-\>C-\>D order continues: do not skip to Track C”) and the
ordering constraint was used directly, unmodified. `key_files` correctly
pointed at the plan’s §3.2/§4.2 and Track A’s own output shape contract.
**What helped most:** the `gotchas` field’s warning that “the plan’s own
§3.2 pseudocode is explicitly marked illustrative/non-vectorized –
expect real translation work” was accurate but, if anything,
understated: the D-2 edgeStyle-invariance test’s own “rectilinear”-side
extraction has **no pseudocode in the plan at all** (§3.2 only sketches
the direct-style half) – this session had to design that algorithm from
scratch, verified empirically in `scratchpad/` against real code output
before committing it to a test file. **What was missing:** the handoff
didn’t flag that gap specifically (that Track B’s harder half has zero
pseudocode to translate, unlike Track A’s fully-specified §3.1) – a fair
omission, since S633 was scoped to Track A only and had no obligation to
pre-read Track B’s own design gaps in depth. **What was wrong:** nothing
found inaccurate. **ROI:** high — the ordering/scope guidance was used
verbatim; the one gap cost real design time but was not something the
handoff could reasonably have caught.

### What Session 634 Did

**Deliverable:** Implemented **Track B** of
`docs/planning/pedigree-diagram-kinship2-structural- comparison-plan.md`
(§3.2/§4.2) — `.extractNprcStructure()`, a new
zero-`kinship2`-dependency internal (`@noRd`) function in
`R/comparePedigreeStructure.R`, plus the D-2 edgeStyle-invariance
property test. **DONE**, full strict TDD (RED→GREEN, REFACTOR skipped by
owner-approved choice). **Started/Completed:** 2026-08-25 (single
session).

**What actually happened, in order:** 1. **Phase 0 orientation** (full
protocol): clean tree except the same pre-classified untracked artifacts
S633 already checked (no ghost session — last commit `801d0b2d` at
15:07:35, same day, continuous with this session). Ledger frontiers
current. CI green (10/10 `completed success`). Dashboard 96/100, 1 HIGH
risk (3 files past the FM \#28 read cap — carried forward, not acted
on). Rendered the priorities list (4 numbered items, including the
ratified `GENETIC_METRICS_ISSUES_ SEQUENCING_AUDIT_2026-08-08.md`
next-item for issue \#148) via `AskUserQuestion`; owner picked
“Implement Track B.” 2. **Re-read the plan’s Track B section in full**
(§3.2, §4.2, plus §1.2’s re-verified
[`makePedigreeMatingLayout()`](https://github.com/rmsharp/nprcgenekeepr/reference/makePedigreeMatingLayout.md)
structure) and **re-verified the actual rectilinear-style output
directly against source** (`R/makePedigreeDiagramData.R:1239-1552`
`.addRectilinearWaypoints()`, `:1554-1853`
`.resolveEdgeNodeCollisions()`) — the plan gives §3.2 pseudocode for the
direct-style extractor only; the D-2 edgeStyle-invariance test’s own
“rectilinear”-side walker has no pseudocode at all and had to be
designed from scratch this session. 3. **Empirically prototyped and
verified the design BEFORE writing RED**
(`scratchpad/ prototype_trackB.R`, `explore_rectilinear.R`,
`explore_real.R`): both the direct-style extractor and a graph-based
rectilinear-side walker (jog-waypoint collapse → connected components
over `__drop_`/`__bar_`/`__proj_` nodes → edge-direction-based
parent/child-side classification), run against the 9-subject Track C
fixture AND the real 375-individual bundled fixture (confirmed
exercising real `__proj_`/`__jog_` waypoints — 56 and 154 respectively).
Canonicalized results matched exactly on both (502 parent-child edges /
237 mate pairs on the real fixture) — D-2’s invariance claim confirmed
empirically before committing to a test design, and both algorithms
confirmed correct. 4. **Incidental finding, filed not fixed:** while
designing a founder-only edge-case fixture, discovered
[`makePedigreeMatingLayout()`](https://github.com/rmsharp/nprcgenekeepr/reference/makePedigreeMatingLayout.md)
crashes (`arguments imply differing number of rows: 0, 1`) on any
pedigree with zero total parent-child edges — a pre-existing, unrelated
bug, root- caused to `R/makePedigreeDiagramData.R:1172`. Filed as [issue
\#164](https://github.com/rmsharp/%20nprcgenekeepr/issues/164) per the
established “report, don’t fix mid-session” precedent
(`PROJECT_LEARNINGS.md` Learning 382); worked around by hand-building
the founder-only test fixture directly in `.extractNprcStructure()`’s
own input-contract shape, matching Track A’s own precedent. 5. **Claimed
the session** (1B stub + `HANDOFFS.md` pending receipt, commit
`b18a3ef5`). 6. **PRE-RED→RED gate** (`AskUserQuestion`): proposed the
verified fixture/algorithm design (5 fixtures for
`.extractNprcStructure()`’s own unit tests; the empirically-verified
rectilinear walker as a test-file-local helper for the D-2 property
test) — owner approved. 7. **RED:** appended to
`tests/testthat/test_comparePedigreeStructure.R` — 7 new `test_that()`
blocks (return shape; founder-only; D5 single-known-parent; the
7-subject fixture reused from Track A; the 9-subject Track C fixture
with duplicates + consanguinity; 2 edgeStyle-invariance property tests,
Track C fixture + real 375-individual fixture), plus the local
`.extractNprcStructureFromWaypoints()` test helper (ported from the
verified prototype). Ran — confirmed all 7 new blocks fail with
`could not find function ".extractNprcStructure"`, the correct failure
reason; the local test helper itself loaded and ran with no errors. 8.
**RED→GREEN gate** (`AskUserQuestion`): approved. 9. **GREEN:** wrote
`.extractNprcStructure()` in `R/comparePedigreeStructure.R`,
implementing §3.2’s algorithm hardened per the plan’s own note
(`nChildren` counted from the assembled `parentChildEdges`, never left
`NA`; both loops vectorized, no `rbind` in a loop). Passed clean on the
first run — no bug found this time (unlike Track A’s Learning 666), a
direct result of the upfront empirical prototyping. 10. **GREEN→REFACTOR
gate** (`AskUserQuestion`): presented the honest assessment that
`.extractNprcStructure()` itself needs no restructuring, and that its
apparent duplication with the test-only rectilinear walker’s own
downstream assembly logic is **deliberate, not accidental** — plan §4.2
requires a “separately-implemented” second extraction specifically so a
bug in shared logic can’t silently pass the invariance test on both
sides; factoring it out would defeat the cross-check. Owner chose to
skip REFACTOR. 11. **Full verification:** `lintr::lint_package()`
(loaded via
[`pkgload::load_all()`](https://pkgload.r-lib.org/reference/load_all.html)
first) found 2 `string_boundary_linter` hits (`grepl("^__union_", ...)`
→ `startsWith(..., "__union_")`), fixed, re-ran clean (0 lints). Full
clean regression: 1 pre-existing failure (`test_wordlist_coverage.R`,
same known baseline) / 0 error / 39 warnings — no new failures.
[`devtools::check()`](https://devtools.r-lib.org/reference/check.html):
**Status: 1 WARNING, 2 NOTEs, 0 errors** — all 3 confirmed pre-existing/
unrelated (non-portable untracked filename, untracked `scratchpad/`,
`vignettes/figure/` knitr leftover), matching Track A’s own baseline
exactly; the full installed-package test suite ran clean
(`FAIL 0 | WARN 39 | SKIP 206 | PASS 6395` inside the check). 12.
**Runtime smoke test (Phase 3E): n/a.** Same as Track A — a pure,
internal (`@noRd`), zero-call-site data transformation, confirmed by
grep (no call sites outside the test file). No runtime behavior changed
to verify. 13. **Updated `BACKLOG.md`’s top item**: Track B marked DONE
with verification detail and the issue \#164 finding; next pickup named
as Track C (`.comparePedigreeStructures()` + the D-7 fixture +
live-kinship2 end-to-end tests). 14. **Process hiccup, self-caused and
resolved, reported in full:** the first
[`devtools::check()`](https://devtools.r-lib.org/reference/check.html)
invocation nested a shell `&` inside an already-backgrounded `Bash` tool
call — the tool reported “completed” almost immediately (that was just
the outer wrapper’s `echo`), while the actual check kept running
detached. It was later killed mid-run (evidence: `testthat.R`’s own
`.Rout` shows a clean finish, `FAIL 0 | WARN 39 | SKIP 206 | PASS 6395`,
but the parent `R CMD check` process exited without ever printing the
final `Status:` line — consistent with the harness reclaiming the
process group once the tool call was marked done). Diagnosed by checking
the `Rcheck` directory’s own `00check.log`/`testthat.Rout` directly
rather than trusting the truncated redirect log; re-ran properly via the
`Bash` tool’s own `run_in_background: true` (no nested `&`) to get a
trustworthy, complete result. No data lost, no incorrect conclusion
reached — but this cost 2 Monitor cycles. 15. **Close-out** (this
write-up).

**Self-assessment (Session 634): 9/10.** **Strengths:** (1) recognized
that the plan gives Track B’s harder half (the rectilinear-side walker)
zero pseudocode, and responded by empirically prototyping and verifying
a from-scratch graph algorithm against BOTH a small hand-traceable
fixture and the real 375-individual fixture BEFORE writing any RED test
— this is why GREEN passed clean on the first try, with zero wasted
RED/GREEN churn; (2) found and correctly triaged a genuine,
reproducible, unrelated pre-existing bug (issue \#164) — filed properly,
not fixed mid-session, not silently worked around without disclosure;
(3) the GREEN→REFACTOR gate assessment was substantive, not a rubber
stamp — correctly identified that the apparent code duplication with the
test helper is load-bearing (independence for the cross-check), not an
oversight, and explained why refactoring it away would be actively
harmful to the test’s own guarantee; (4) caught and correctly diagnosed
my own process mistake (the nested-`&` background-task bug) by checking
ground truth (the Rcheck directory’s own logs) rather than accepting an
ambiguous “completed” signal at face value, then re-ran to get a
trustworthy result rather than reporting the incomplete one.
**Weaknesses:** (1) the nested-`&` mistake itself — should have used the
`Bash` tool’s own `run_in_background: true` correctly on the first
attempt; cost real wall-clock time (2 Monitor cycles) though no
correctness risk since the mistake was caught before being reported as a
result; (2) spent a longer-than-ideal stretch manually polling the check
log via repeated `Bash` calls before correctly switching to `Monitor`
with a properly-matching process-exit condition — the harness’s own “do
not poll” guidance applied and was not followed cleanly at first.

**Key files:** `R/comparePedigreeStructure.R`
(`.extractNprcStructure()`, new, the deliverable),
`tests/testthat/test_comparePedigreeStructure.R` (7 new blocks +
`.extractNprcStructureFromWaypoints()` test helper),
`docs/planning/pedigree-diagram-kinship2-structural-comparison-plan.md`
§3.2/§4.2/§4.3 (Track B’s contract; Track C’s up next), `BACKLOG.md` “Up
Next” top item (updated, Track B DONE / Track C next), [issue
\#164](https://github.com/rmsharp/nprcgenekeepr/issues/164) (incidental
finding), `scratchpad/prototype_trackB.R` (the verified prototype,
session-local, not committed).

**Gotchas for a future session (Track C, the next pickup):** (1)
implement exactly
`docs/planning/ pedigree-diagram-kinship2-structural-comparison-plan.md`
§3.3/§3.4/§4.3 — `.comparePedigreeStructures()` (the diff itself,
canonicalized/unordered comparison per §1.3’s “order never matters”
fact) + `.toKinship2Pedigree()` + orchestration wrapper in
`data-raw/ kinship2FidelityValidation.R` (the ONE genuine `kinship2`
dependency point,
[`requireNamespace()`](https://rdrr.io/r/base/ns-load.html)- guarded) +
the new D-7 crossing-duplication fixture + live-kinship2 end-to-end
tests (`skip_if_not_installed("kinship2")`-guarded) against the Track-C
fixture, the D-7 fixture, and the real 375-individual fixture (D-8’s
toy-AND-real-scale discipline). (2) D-8: **a non-empty diff on the real
fixture is a genuine finding to report, not silently reconcile** — Track
C’s own “Done looks like” explicitly allows ending with an open question
rather than a clean “identical” result. (3) Track B’s own output
contract (`list(parentChildEdges, matePairs)`, identical shape to Track
A’s) is already implemented/tested in both directions — Track C’s
comparator should be built and tested agnostic to which side is which,
per the plan’s own §3.3 framing. (4) CI will skip Track C’s
live-kinship2 tests (no workflow installs kinship2, §1.5) — confirm this
visually once (not just assumed) when Track C first lands, per
`SAFEGUARDS.md`’s “trust but verify.” (5) The dashboard’s HIGH-risk
finding (3 files past the FM \#28 2,000-line read cap) is still open,
still not acted on, carried forward again. (6) When running
[`devtools::check()`](https://devtools.r-lib.org/reference/check.html)
in the background, use the `Bash` tool’s own `run_in_background: true`
directly — do NOT nest a shell `&` inside it (see this session’s own
process hiccup, item 14 above). **Score: N/A — Session 633’s handoff
evaluated above (9/10).**

### Session 632 Handoff Evaluation (by Session 633)

**Score: 9/10.** **What helped:** `next_steps` named the exact
deliverable (“Implement Track A … .extractKinship2Structure() in a new
R/ file, zero kinship2 dependency, unit-tested against synthetic list
fixtures”) and the exact ordering constraint (“do not skip to Track C’s
live-kinship2 tests before A/B land”) — both used directly, unmodified,
as this session’s own scope statement. `key_files` correctly pointed at
the plan document itself; the plan’s own §3.1/§4.1 (algorithm, output
contract, fixture list) was sufficiently precise that no additional
research/rediscovery was needed before writing RED. **What was
missing:** the handoff didn’t flag that the plan’s own §3.1 pseudocode
(presented as “re-implements kinship2’s own align.pedigree() derivation
verbatim,” to be implemented exactly) has an untested edge case — a
literal scalar `role` value fails R’s
[`data.frame()`](https://rdrr.io/r/base/data.frame.html) recycling rule
against a zero-match (founder-only) mask. This wasn’t discoverable from
the handoff alone; it surfaced only once RED’s own required founder
fixture was written and run. Not a real gap in the handoff (S632 could
not have known without implementing), but worth noting since Track B/C’s
own pseudocode blocks carry the same “illustrative, needs hardening”
caveat explicitly, while Track A’s did not. **What was wrong:** nothing
found inaccurate. **ROI:** high — near-zero rediscovery cost.

### What Session 633 Did

**Deliverable:** Implemented **Track A** of
`docs/planning/pedigree-diagram-kinship2-structural- comparison-plan.md`
(§3.1/§4.1) — `.extractKinship2Structure()`, a new,
zero-`kinship2`-dependency internal (`@noRd`) function in
`R/comparePedigreeStructure.R`, plus its test file. **DONE**, full
strict TDD (RED→GREEN, REFACTOR skipped by owner-approved choice).
**Started/Completed:** 2026-08-25 (single session).

**What actually happened, in order:** 1. **Phase 0 orientation** (full
protocol): clean tree except pre-classified untracked artifacts (all
individually date-checked, matching S632’s own report — no ghost
session). Ledger frontiers current (`CHANGELOG.md` == HEAD;
`HANDOFFS.md` one commit behind, the standard self-referential non-gap).
CI green (`gh run list`, 10/10 `completed success`). Dashboard 96/100, 1
HIGH risk (3 files past the FM \#28 read cap — carried forward, not
acted on). Rendered the priorities list (4 numbered items, including a
ratified-sequencing-audit item for issue \#148 per `CLAUDE.md`’s own
“flat tag grep is not sufficient” rule) via `AskUserQuestion`; owner
picked “Implement Track A.” 2. **Re-read the plan’s Track A section in
full** (§3.1, §4.1, §1.1, §1.4, §7 ratification outcome) before
proposing RED scope — confirmed D-6 (internal `R/` helpers, no exported
surface, so `NEWS.Rmd`/`_pkgdown.yml`/`a2interactive.Rmd` checklists
don’t trigger for this track). 3. **Claimed the session** (1B stub +
`HANDOFFS.md` pending receipt, commit `ebc6ec70`). 4. **PRE-RED→RED
gate** (`AskUserQuestion`): proposed 4 synthetic fixtures (founder-only;
single-known-parent; multi-mate/shared-parent dedup; a combined
7-subject/2-mating fixture built this session, since the plan’s own
live-verified 7-subject fixture data wasn’t reproduced in the document
text) — owner approved as scoped. 5. **RED:** wrote
`tests/testthat/test_comparePedigreeStructure.R` (5 `test_that()`
blocks, 19 assertions). Ran — confirmed all 5 blocks fail with
`could not find function ".extractKinship2Structure"`, the correct
failure reason. No implementation code written. 6. **RED→GREEN gate**
(`AskUserQuestion`): approved. 7. **GREEN:** wrote
`R/comparePedigreeStructure.R`, implementing §3.1’s algorithm. First run
surfaced a real bug the plan’s own pseudocode carries:
`data.frame(..., role = "father")` throws
`arguments imply differing number of rows: 0, 1` when the father-mask
has zero matches (the founder-only fixture) — R’s recycling rule fills
short-to-long, never long-to-zero. Fixed with
`role = rep("father", sum(hasFather))` (and the mother equivalent).
Re-ran: all 19 assertions pass. Documented as `PROJECT_LEARNINGS.md`
Learning 666. 8. **GREEN→REFACTOR gate** (`AskUserQuestion`): presented
the honest assessment that nothing in the ~20-line function needs
restructuring; owner chose to skip REFACTOR and proceed to close-out
verification. 9. **Full verification:** `lintr::lint_package()` (loaded
via
[`pkgload::load_all()`](https://pkgload.r-lib.org/reference/load_all.html)
first, per Learning 224) found 2 `implicit_integer_linter` hits
(`findex > 0`/`mindex > 0` → `0L`/`0L`), fixed, re-ran clean (0 lints).
Full clean regression: 1 pre-existing failure
(`test_wordlist_coverage.R`, flagged word `bitSize` — confirmed by
direct grep that this word originates entirely in the pre-existing
`R/shrinkPedigree.R`, not this session’s files) / 0 error / 39
pre-existing warnings (0 from the new test file, confirmed directly).
[`devtools::check()`](https://devtools.r-lib.org/reference/check.html)
(the project’s full build-equivalent): 0 errors, 1 warning + 2 notes,
all 3 confirmed pre-existing/ unrelated (the untracked “Compounding
Loop” file’s non-portable name; the untracked `scratchpad/` dir; a
pre-existing `vignettes/figure/` knitr leftover — same three the project
has flagged before, e.g. `BACKLOG.md`’s own S(unnamed) precedent at line
~602-605). 10. **Runtime smoke test (Phase 3E): n/a.** The new function
is a pure, internal (`@noRd`), zero-call-site data transformation — not
wired into the Shiny app, any exported function, or any startup/service
path. No runtime behavior changed to verify. 11. **Updated
`BACKLOG.md`’s top item**: Track A marked DONE with verification detail;
next pickup named as Track B (`.extractNprcStructure()` + the D-2
edgeStyle-invariance property test). 12. **`PROJECT_LEARNINGS.md`
Learning 666** — the plan-pseudocode-recycling-edge-case finding (§7
above); `CLAUDE.md` learnings-count pointer refreshed (665→666,
S632+→S633+). 13. **Self-caused-and-resolved incident, reported here in
full:** while confirming the wordlist failure was pre-existing, ran
`git stash` / `git stash pop` to diff against a clean tree — but
`git stash` had “no local changes to save” (my new files are untracked,
and `git stash` doesn’t include untracked files by default), so the
subsequent `git stash pop` instead popped a completely unrelated,
pre-existing stash entry
(`stash@{0}: WIP on dev: be8d0598 start of dev branch with use of renv`),
producing a `.DS_Store` modify/delete conflict. Diagnosed immediately
(`git stash show --stat` confirmed the stash’s ENTIRE content was a
10244-byte `.DS_Store` binary churn, nothing else;
`git show HEAD:.DS_Store` confirmed HEAD doesn’t track the file at all,
per S488’s “untrack .DS_Store” precedent). Resolved with
`git rm .DS_Store` (matching HEAD’s own “deleted” state) — working tree
confirmed back to its exact pre-incident state (same 8 untracked files,
nothing else touched), and the pre-existing stash entry left untouched
in the stash list (not mine to drop). No data lost; verified the
pre-existing-failure claim by grep instead (more reliable than stash for
this repo’s state, given the leftover stash entry). 14. **Close-out**
(this write-up).

**Self-assessment (Session 633): 8/10.** **Strengths:** (1) followed the
full TDD phase-gate protocol correctly — 3 `AskUserQuestion` gates
(PRE-RED→RED, RED→GREEN, GREEN→REFACTOR), each with concrete, verifiable
actions, not rubber-stamp questions; (2) RED-phase fixture design
deliberately included a zero-match edge case (per the plan’s own “Done
looks like” bar), which is what caught a genuine defect in the plan’s
own pseudocode rather than only in my translation of it — a real
instance of the discipline paying for itself; (3) chose to build my own
7-subject/2-mating fixture transparently, flagging that the plan’s cited
fixture data wasn’t reproduced in the document text, rather than
fabricating “the” original fixture from guesswork; (4) verified the 2
pre-existing-defect claims (`test_wordlist_coverage.R`’s `bitSize`,
[`devtools::check()`](https://devtools.r-lib.org/reference/check.html)’s
3 findings) by direct grep/ content inspection against my own new files,
not by assumption; (5) honestly reported the self-caused git-stash
incident in full rather than omitting it, per this project’s “recovering
from its own errors” standard. **Weaknesses:** (1) the git-stash
incident itself — reaching for `git stash` to verify a pre-existing
failure was an unnecessary, riskier method when a direct grep (which I
used right after, and which was strictly better here) was available from
the start; a repo with a long-lived unrelated stash entry is not a
scenario I checked for before invoking a stash command, and
`SAFEGUARDS.md`’s own “Read Before Edit”/“Preserve User Edits” spirit
argues for `git stash list` before ever popping; (2) did not re-verify
Track A’s own tests are still green after the final `0L` lint fix using
the FULL regression command (only the fast single-file command) before
running
[`devtools::check()`](https://devtools.r-lib.org/reference/check.html) —
reasonable given
[`devtools::check()`](https://devtools.r-lib.org/reference/check.html)
itself re-runs the full suite and did come back 0 errors, but the
sequencing was slightly out of the stated verification order.

**Key files:** `R/comparePedigreeStructure.R` (new, the deliverable —
`.extractKinship2Structure()`),
`tests/testthat/test_comparePedigreeStructure.R` (new, 5 blocks/19
assertions),
`docs/planning/ pedigree-diagram-kinship2-structural-comparison-plan.md`
§3.1/§4.1 (source contract), `BACKLOG.md` “Up Next” top item (updated,
Track A DONE / Track B next), `PROJECT_LEARNINGS.md` Learning 666,
`CLAUDE.md:283` (pointer).

**Gotchas for a future session (Track B, the next pickup):** (1)
implement exactly
`docs/planning/ pedigree-diagram-kinship2-structural-comparison-plan.md`
§3.2/§4.2 — `.extractNprcStructure()`, input is
`makePedigreeMatingLayout(ped, edgeStyle="direct", twinRelations=NULL)`’s
output; **must** also include the D-2 edgeStyle-invariance property test
(a second, throwaway `"rectilinear"`-side extraction implementation) —
this is the track that actually proves D-2’s claim, not merely assumes
it. (2) The plan’s own §3.2 pseudocode is explicitly marked
illustrative/non-vectorized — expect real translation work, and per this
session’s own Learning 666, treat every “must handle zero/founder/
no-match” test requirement as an adversarial check on the pseudocode
itself, not just your implementation of it — recycling/length-mismatch
bugs are exactly the shape that hides in pseudocode that was only read,
not executed against an empty case. (3) Do not skip to Track C’s
live-kinship2 tests — Track B’s own tests must import Track A’s output
shape contract (`list(parentChildEdges, matePairs)`, both already
implemented and unit-tested in `R/comparePedigreeStructure.R` this
session). (4) The dashboard’s HIGH-risk finding (3 files past the FM
\#28 2,000-line read cap) is still open, still not acted on, carried
forward again. **Score: N/A — Session 632’s handoff evaluated above
(9/10).**

### Session 631 Handoff Evaluation (by Session 632)

**Score: 9/10.** **What helped:** the `HANDOFFS.md` receipt’s
`next_steps` field was specific and actionable almost to the letter —
“(c) design and build a real structural comparison – extract the
parent-child/mate-pair edge set from both kinship2’s `pedigree` object
and nprcgenekeepr’s
[`makePedigreeMatingLayout()`](https://github.com/rmsharp/nprcgenekeepr/reference/makePedigreeMatingLayout.md)
output… and diff them programmatically” is nearly verbatim what became
this session’s plan document’s own scope statement (§0). `key_files`
correctly pointed at `data-raw/kinship2FidelityValidation.R:75-84` and
`PROJECT_LEARNINGS.md#Learning-664`, both of which were central to this
session’s evidence base. The `BACKLOG.md` item’s own framing (owner’s
exact words, both problems numbered and evidenced) meant Phase 0’s
priorities-list rendering needed no extra digging to present it
accurately. **What was missing:** the handoff’s `next_steps` field
described (a)/(b)/(c) as one undifferentiated block (“a future session
should (a)… (b)… (c)…”); it didn’t anticipate that (c) alone — the
actual DECISION NEEDED item — would need its own dedicated *design*
session before any implementation, per `SESSION_RUNNER.md`’s
planning/implementation boundary (FM \#18). This wasn’t wrong, just
incomplete — S632 had to derive the design-first framing itself from the
`BACKLOG.md` item’s own “DECISION NEEDED” tag rather than finding it
already spelled out. **What was wrong:** nothing found inaccurate.
**ROI:** high — the handoff’s precision measurably shortened this
session’s own scoping work.

### What Session 632 Did

**Deliverable:** Design document —
`docs/planning/pedigree-diagram-kinship2-structural-comparison-plan.md`
— an interface-first design for a programmatic structural-comparison
algorithm between
[`makePedigreeMatingLayout()`](https://github.com/rmsharp/nprcgenekeepr/reference/makePedigreeMatingLayout.md)’s
output and kinship2’s own `pedigree` object, resolving the DECISION
NEEDED tag on `BACKLOG.md`’s top “Up Next” item (found S631). **DONE**
(plan only — no implementation code, per `SESSION_RUNNER.md`’s
planning/implementation boundary, FM \#18). **Started/Completed:**
2026-08-25 (single session).

**What actually happened, in order:** 1. **Phase 0 orientation** (full
protocol): clean tree except pre-classified untracked artifacts (all
individually date-checked and traced to already-documented sources — 3
spike-evidence HTMLs from S588, the recurring Office lock file, the
recurring `scratchpad/` debug-script dir, S630’s own
deliberately-uncommitted review PDFs — no ghost session). Ledger
frontiers current (`CHANGELOG.md` == HEAD; `HANDOFFS.md` one commit
behind HEAD, the standard self-referential non-gap). CI green
(`gh run list`, last 10 runs all `completed success`). Dashboard 96/100,
1 HIGH risk (3 files now past the FM \#28 2,000-line read cap:
`HANDOFFS.md`/`SESSION_NOTES.md`/`CHANGELOG.md` — flagged in the report,
not acted on, since it wasn’t the item picked). Rendered the priorities
list (4 items) via `AskUserQuestion`; the user picked “Pedigree-diagram
vs kinship2 comparison algorithm.” 2. **Scoped the task as a planning
session**, not implementation — `BACKLOG.md`’s own “DECISION NEEDED on
the comparison methodology’s actual design” tag, and
`SESSION_RUNNER.md`’s `Design→ARCHITECTURE_WORKSTREAM.md` mapping, both
pointed here. Confirmed `DESIGN_WORKSTREAM.md` (UI/UX-specific) didn’t
fit; `ARCHITECTURE_WORKSTREAM.md` (interface-first design for a new
internal capability) did. Declared TDD phase N/A (matching the sibling
S569 plan doc’s own established precedent for planning sessions). 3.
**Claimed the session** (1B stub + `HANDOFFS.md` pending receipt, commit
`c729a222`). 4. **Ran a 5-agent Workflow research fan-out** (parallel,
no barrier needed — each agent’s findings were consumed independently at
synthesis time): kinship2 `pedigree` object internals (live inspection,
[`str()`](https://rdrr.io/r/utils/str.html)/[`unclass()`](https://rdrr.io/r/base/class.html),
`align.pedigree()`’s unexported `spouselist` derivation deparsed);
`makePedigreeDiagramData.R`’s full output/synthetic-id structure
(1,900-line file read in full); existing test/fixture inventory
(`test_makePedigreeMatingLayout.R`, `test_resolveEdgeNodeCollisions.R`,
repo-wide grep); prior planning-doc “dragons” (5 documents + 2
`PROJECT_LEARNINGS.md` learnings read in full); a grep-based
integration-point inventory (`DESCRIPTION`, every
`makePedigreeMatingLayout`/`kinship2` call site). 530K subagent tokens,
86 tool calls, 0 errors. 5. **Adversarially re-verified the 2 most
load-bearing structural claims myself**, directly reading
`R/makePedigreeDiagramData.R:1085-1234,460-522,355-365` rather than
trusting agent report alone — both confirmed exactly as reported (the
`edgeStyle="direct"` vs `"rectilinear"` split, the 5 reserved-prefix
validation). Also spot-verified `R/modPedigree.R:773-775`,
`vignettes/a2interactive.Rmd:500`, both `PROJECT_LEARNINGS.md` Learning
line numbers, and the owner-correction callout’s actual text in
`pedigree-diagram-kinship2-reference-comparison.qmd`. 6. **Designed the
comparator** around one key architectural finding this session made, not
merely inherited: kinship2’s `pedigree` object is a plain S3 list
exposing only `id`/`findex`/`mindex`/ (optional `relation`) — nothing
that actually requires the `kinship2` namespace to read. This let the 3
core functions be typed to that minimal shape (not the
[`kinship2::pedigree`](https://rdrr.io/pkg/kinship2/man/pedigree.html)
class), making them fully unit-testable with **zero** `kinship2`
dependency; only a thin `data-raw/`-side wrapper that actually
constructs a real
[`kinship2::pedigree()`](https://rdrr.io/pkg/kinship2/man/pedigree.html)
object needs the guard/skip. Also established (and required as its own
verification task, not an assumption): comparing on
`makePedigreeMatingLayout(ped, edgeStyle="direct")` output is sufficient
and far simpler than walking `"rectilinear"`’s waypoint chains, since
the underlying relationship structure is built once, identically, before
the style branch (confirmed by direct source reading, step 5). 7.
**Wrote the full plan**
(`docs/planning/pedigree-diagram-kinship2-structural-comparison-plan.md`),
matching the sibling `kinship2-supplement-full-reproduction-plan.md`’s
house style: evidence base, 8 numbered design decisions (forced
vs. judgment call, each labeled), interface-first function contracts
with illustrative (explicitly-marked non-final) pseudocode, 4
session-sliceable tracks with completion criteria and verification
commands, cross-track notes, an alternatives-considered table, and a
provenance section. 8. **Routed the 4 genuine judgment calls to the
owner via `AskUserQuestion`**, matching the established S562
ratification precedent — code placement (internal `R/` helpers
vs. script-only vs. exported), twin-relation comparison scope (now
vs. deferred), whether to add a new crossing-duplication fixture, and
whether Track D (closing the loop on the vignette) stays in this plan.
**All 4 ratified exactly as recommended**, zero corrections. Filled in
the plan’s own “Ratification outcome” section with the result. 9.
**Verified every citation added this session resolves** (Phase 3F
requirement): grepped/read every cited <file:line> and doc-line-range
directly — all confirmed accurate, none fabricated or drifted. 10.
**Updated `BACKLOG.md`’s top item** to record the plan as DONE/RATIFIED
and name Track A as the next pickup, rather than marking the whole item
`[x]` (implementation hasn’t happened yet). 11. **`PROJECT_LEARNINGS.md`
Learning 665** — the typed-to-minimal-shape adapter pattern (§6 above),
a genuinely new, reusable architectural pattern, not a restatement of
prior learnings. `CLAUDE.md` learnings-count pointer refreshed. 12.
**Close-out** (this write-up).

**Self-assessment (Session 632): 9/10.** **Strengths:** (1) used a
Workflow research fan-out appropriately for a genuinely research-heavy
design task, then did NOT simply trust the agents’ output —
independently re-verified the 2 claims the whole design’s correctness
rests on, catching zero errors but establishing real confidence rather
than assumed confidence; (2) correctly distinguished *forced* design
decisions (only one option is actually correct, given verified source
facts) from genuine *judgment calls* (routed to the owner), rather than
either deciding everything unilaterally or asking about everything; (3)
found a real architectural win (the zero-kinship2- dependency
typed-to-minimal-shape pattern) that wasn’t merely assumed from the
owner’s callout text but derived from directly inspecting the installed
package; (4) correctly scoped this session to design-only, resisting any
pull toward writing implementation code even though the design was
concrete enough to make that tempting (`SAFEGUARDS.md` mode-switch
discipline, FM \#18); (5) matched established house style (the sibling
S562 plan) closely enough that the ratification step reused a proven
pattern rather than improvising one. **Weaknesses:** (1) the
illustrative pseudocode in the plan’s §3.2 is explicitly
unrolled/non-vectorized (flagged as such in the document itself) — a
minor gap, deliberate, but means Track A/B’s implementing session has
real translation work to do, not just transcription; (2) did not
independently re-execute the kinship2-internals research agent’s own R
code (I verified
[`makePedigreeMatingLayout()`](https://github.com/rmsharp/nprcgenekeepr/reference/makePedigreeMatingLayout.md)’s
structure directly via source reading, but trusted the kinship2 agent’s
live-run transcript output rather than re-running it myself) — a
reasonable tradeoff given the output was highly concrete (actual
[`str()`](https://rdrr.io/r/utils/str.html) dumps, actual code+output
pairs) and independently cross-checked against kinship2’s own deparsed
`align.pedigree()` internals, but a stricter session could have re-run
it.

**Key files:**
`docs/planning/pedigree-diagram-kinship2-structural-comparison-plan.md`
(the deliverable), `BACKLOG.md` “Up Next” top item (updated, not
closed), `PROJECT_LEARNINGS.md` Learning 665, `CLAUDE.md:283` (pointer),
`R/makePedigreeDiagramData.R:1085-1234,460-522,355-365` (directly
re-verified this session — the source of truth for Track B’s design),
`R/modPedigree.R:773-775` (the existing `duplicateToReal` resolution
precedent).

**Gotchas for a future session (Track A, the next pickup):** (1)
implement exactly
`docs/planning/ pedigree-diagram-kinship2-structural-comparison-plan.md`
§3.1/§4.1 — `.extractKinship2Structure()`, in a new `R/` file, zero
kinship2 dependency, unit-tested against synthetic list fixtures (no
kinship2 install needed for this track at all). (2) Do not skip straight
to Track C’s live-kinship2 tests — the strict A→B→C→D dependency order
(plan §5) exists because Track B’s tests import Track A’s output shape
contract, and Track C directly calls both. (3) `kinship2` is confirmed
absent from every CI workflow (grepped this session) — Track C’s
`skip_if_not_installed("kinship2")`-guarded tests will skip cleanly in
CI and only run live locally; this is intentional, not a gap to “fix”
later. (4) The dashboard’s new HIGH-risk finding (3 files past the
2,000-line read cap) was reported but not acted on this session — still
open for a future session to address if picked. **Score: N/A — no gap,
direct continuation.** S631 is a same-conversation continuation of S630
(the owner’s correction arrived immediately after S630’s own close-out
report), not a fresh-session pickup from a written handoff — there was
no discovery/re-orientation step where a handoff’s quality mattered.
Noted here for the record rather than skipped silently.

### What Session 631 Did

**Deliverable:** Stopped presenting kinship2-vs-nprcgenekeepr
pedigree-diagram comparisons as verified equivalent, per direct owner
correction: “you are still publishing comparisons of kinship2 output to
nprcgenekeepr output as equivalent when they are clearly not… I have
stated that your equivalence assessments have been wrong in the past for
these same pedigrees.” **DONE** (as scoped — an honest correction +
properly-scoped future fix, not the deeper algorithm work itself, per
the owner’s own “the next session needs to work on…” framing).
**Started/Completed:** 2026-08-25 (same conversation as S630,
immediately following its close-out).

**What actually happened, in order:** 1. **Took the correction seriously
rather than defending S630’s report.** S630 had presented
`vignettes/articles/kinship2-fidelity-validation.qmd`’s Track A/B/C
comparisons as strong existing evidence without re-verifying them —
re-read both existing user-memory files
(`pedigree-comparison-show-images`,
`verify-diagrams-against-ground-truth`) first to recall the established
discipline this exact mistake violates (S591/S603 precedent). 2. **Read
`data-raw/kinship2FidelityValidation.R` in full** (the script generating
the disputed evidence): confirmed Track A (kinship-matrix
[`identical()`](https://rdrr.io/r/base/identical.html)) and Track B’s
surviving-id-set
([`setequal()`](https://rdrr.io/r/base/sets.html))/`bitSize` ARE
genuinely computed and checked — but Track B’s full/shrunk PLOTS and
Track C’s consanguineous-marker PLOTS are two independently-rendered
static images (kinship2’s own `plot.pedigree()`, nprcgenekeepr’s
`visNetwork` screenshot) with ZERO programmatic comparison between them
— captions asserting “matching kinship2’s own family groupings” etc. are
prose, not computed facts. 3. **Independently verified Track C by hand**
(not eyeballing): computed `kinship(A,Y) = 0.25` directly via the
exported
[`kinship()`](https://github.com/rmsharp/nprcgenekeepr/reference/kinship.md)
function against the fixture’s own ground-truth relationships (confirmed
A and Y are full siblings via `pedC`’s own sire/dam columns), then
pulled
[`makePedigreeMatingLayout()`](https://github.com/rmsharp/nprcgenekeepr/reference/makePedigreeMatingLayout.md)’s
actual edge list and traced every `__union_N`/`__dup_X_N` node back to
real individuals — confirmed the A×Y union is the ONLY one marked
consanguineous (`#D55E00`), matching ground truth exactly, for this ONE
fixture only. 4. **Found the images are also stale**, independent of the
missing-algorithm problem: regenerated Track A/B via
`data-raw/kinship2FidelityValidation.R` and directly compared old
vs. new `trackB-nprc-full.png` — the OLD (committed, S566/2026-08-13-14)
image shows diagonal “direct”- style fan-out edges (the package default
AT THE TIME), while the current algorithm (confirmed via a fresh,
successful regeneration despite the script’s own chromote error later in
the run) produces clean right-angle sibship bars — the package default
flipped to “rectilinear” via Track 2 (S574), and the entire positioning
algorithm was rewritten since (Walker/BJL, issue \#141, S592-S621), with
nobody re-verifying either change against this article. 5. **Checked the
sibling document**
`docs/planning/pedigree-diagram-kinship2-reference- comparison.qmd` (the
file sitting untracked in the working directory since this
conversation’s very start) — same defect shape, staler still
(2026-08-08, refreshed once 2026-08-13), plus a `date: today`
frontmatter field that hides its own staleness by showing today’s date
on every render regardless of actual content age. 6. **Corrected both
documents** with a prominent, honest caveat (added, not deleted the
content — the numeric claims remain genuinely valid) stating the
diagram-equivalence claims are unverified and must not be cited pending
a real comparison. Re-rendered `kinship2-fidelity-validation.qmd` to
HTML to confirm the caveat renders correctly (it does); could not
re-render `pedigree-diagram-kinship2-reference-comparison.qmd` here (its
own live
[`library(kinship2)`](https://cran.r-project.org/package=kinship2) code
chunk fails under quarto’s renv-scoped R, a pre-existing, unrelated
limitation) — deleted its now-inconsistent stale untracked `.html`
instead of leaving a pre-caveat version sitting in the working tree. 7.
**Filed a properly-scoped `BACKLOG.md` item** for the actual fix (port
the known `chromote` `$go_to()` race fix into the generation script,
regenerate every image, build a real structural edge-set comparison) as
dedicated future-session work — explicitly NOT attempted this session,
matching the owner’s own “the next session needs to work on our
graphical comparison algorithm” framing. Noted the encouraging data
point (the one successfully-regenerated image looks structurally much
better than the stale one) without merging it, to keep the working tree
consistent with the caveat’s own “still stale” framing until the full
fix lands together. 8. **Updated memory:** `PROJECT_LEARNINGS.md`
Learning 664 (project-level); user-memory
`verify-diagrams-against-ground-truth.md` gained a third documented
instance of this exact failure class recurring.

**Self-assessment (Session 631): 8/10.** **Strengths:** (1) did not get
defensive or try to re-justify S630’s report — took the correction at
face value and re-derived ground truth from scratch, exactly matching
the “when a user says a class of claim has been wrong before, re-derive
it, don’t re-read the writeup more carefully” rule this session itself
wrote into memory; (2) found 2 DISTINCT real problems (no algorithm;
stale images) rather than stopping at the first one found; (3) correctly
recognized the difference between “verify and correct the immediate
false claim” (this session’s proper scope) and “build the actual
comparison algorithm” (explicitly the owner’s stated next-session scope)
and did not blur the two — resisted the temptation to keep pulling the
thread into the deeper fix after finding one image regenerated cleanly
by luck. **Weaknesses:** (1) discovered, embarrassingly, that this
session’s own S630 predecessor report contained a small factual error
unrelated to the main correction: it stated
`kinship2-fidelity-validation.html` was a tracked/committed exception to
the general untracked-HTML convention — `git ls-files` now shows it was
never tracked at all, both `.html` files follow the identical
(gitignored, regenerable) convention. Corrected understanding here; did
not previously verify this claim before repeating it, a smaller instance
of the same “repeated a claim without checking” pattern this whole
session is about. (2) Did not attempt to port the `$go_to()` chromote
fix even though it’s a small, well-understood, mechanical change, out of
deliberate restraint per the owner’s “next session” framing — a
defensible call, but a future session reading this should not assume the
restraint means the fix is hard; it means it was deliberately deferred.

**Key files:** `vignettes/articles/kinship2-fidelity-validation.qmd`
(caveat added),
`docs/planning/pedigree-diagram-kinship2-reference-comparison.qmd`
(caveat added), `BACKLOG.md` “Up Next” (new item, top of file),
`data-raw/kinship2FidelityValidation.R` (read in full, not modified —
its `screenshot_layout()` helper is where the `$go_to()` fix belongs),
`PROJECT_LEARNINGS.md` Learning 664, `CLAUDE.md:283` (pointer).

**Gotchas for a future session:** (1)
`pedigree-diagram-kinship2-reference-comparison.qmd` cannot be rendered
in this environment via `quarto render` — its live
[`library(kinship2)`](https://cran.r-project.org/package=kinship2) chunk
fails because quarto’s R process is renv-scoped and kinship2 isn’t in
the lockfile (by design, per the project’s own “never a Suggests
dependency” rule); `data-raw/kinship2FidelityValidation.R` works fine
via plain `Rscript` (not renv-scoped the same way) — a future session
regenerating either document’s content should use that same
plain-`Rscript` path, not `quarto render` directly for the
reference-comparison doc. (2) The `chromote` race fix needed in
`kinship2FidelityValidation.R`’s `screenshot_layout()` is the same
one-line-conceptual fix already applied elsewhere
(`PROJECT_LEARNINGS.md` Learning 643, `$go_to()` instead of separate
`navigate()`/`loadEventFired()` calls) — should be quick to port. (3)
Building the actual structural comparison algorithm will need to resolve
`__union_N`/`__dup_X_N`/`__bar_*`/`__drop_*` synthetic node ids in
[`makePedigreeMatingLayout()`](https://github.com/rmsharp/nprcgenekeepr/reference/makePedigreeMatingLayout.md)’s
output back to real individuals before diffing against kinship2’s own
`pedigree` object relationships — this session did this by hand for
Track C only (see step 3 above); that manual method is a reasonable
starting template for the real algorithm, not just a one-off.

### Session 629 Handoff Evaluation (by Session 630)

**Score: 8/10.** **What helped:** Phase 0 orientation (CI status, ledger
reconcile, priorities list) was accurate and complete —
CHANGELOG.md/HANDOFFS.md frontiers matched HEAD exactly (modulo the
known self-referential sha-fix commit pattern), all push-triggered CI
was green, and the rendered priorities list gave a clean starting point.
**What was missing/N/A:** this session’s actual deliverable came from a
fresh, specific user request (“show me evidence of pedigree drawing
improvements”) that bypassed the BACKLOG.md priorities picker entirely —
S629’s `next_steps` field had no way to anticipate that, so this isn’t a
gap in S629’s own handoff, just a session that pivoted on direct user
direction rather than picking from backlog. **What was wrong:** nothing
found inaccurate. **ROI:** high for orientation, N/A for this session’s
specific deliverable.

### What Session 630 Did

**Deliverable:** Found and fixed a live crash in the Diagram tab
(Rectilinear edge style, the app’s own default, on a realistic
focal-animal-trim workflow) while verifying the `pedigree-diagram.qmd`
article’s screenshots against the current app — the user’s actual
request (“show me evidence of pedigree drawing improvements… create HTML
and PDF files… documentation should demonstrate the use of each pedigree
drawing feature”). **DONE.** **Started/Completed:** 2026-08-24/25
(single session, spanning midnight).

**What actually happened, in order:** 1. **Phase 0 orientation** (full
protocol, documented above): clean tree except pre-classified untracked
artifacts, CI green, ledger frontiers current, dashboard 96/100.
Rendered the priorities list; **before the user picked one, they asked
directly:** “I want to see evidence of Pedigree drawing improvements…
create \[HTML/PDF files\] and open them for review” — a direct task,
superseding the backlog picker (Phase 1, not a backlog pick). 2.
**Investigated existing evidence:** found
`vignettes/articles/kinship2-fidelity-validation.qmd` (tracked,
committed, real side-by-side kinship2-vs-nprcgenekeepr images across 3
tracks) — opened it live in the browser via a local
`python3 -m http.server` (the `file://` scheme is blocked for the
Claude-in-Chrome extension). Found
`vignettes/articles/pedigree-diagram.qmd` already demonstrates every
current Diagram-tab control (`pedigreeEdgeStyle`, `pedigreeShowNames`,
`pedigreeShowTwinConnectors`, twin-relations upload, interaction,
script-callable equivalent — cross-checked directly against
`R/modPedigree.R`’s actual `ns(...)`-registered inputs, no gaps) — the
user’s mid-turn “documentation should demonstrate each feature” ask was
already substantially satisfied; the concrete, unresolved gap was
`BACKLOG.md`’s own flagged-but- unverified screenshot-staleness item
(found S582). 3. **Claimed the session** (1B stub + `HANDOFFS.md`
pending receipt, commit `6740eba3`). 4. **Regenerated the 5
screenshots** — got `Error: subscript out of bounds` for every fixture,
under Rectilinear (the current default). Ruled out 2 false leads before
treating this as real: (a) the installed package binary was 10 days
stale (Aug 14, predating ~60 sessions of pedigree-diagram work) —
reinstalled from current `HEAD`, crash persisted; (b) a standalone
[`shinytest2::AppDriver`](https://rstudio.github.io/shinytest2/reference/AppDriver.html)
script with full server-log capture reproduced the identical crash
outside the screenshot-harness, ruling out a harness-specific bug. The
captured server log’s own traceback pinpointed `.detectStraight()`
inside `.resolveEdgeNodeCollisions()` (`R/makePedigreeDiagramData.R`,
commit `c7bdbe4b`, issue \#160 Track 2). 5. **Root-caused precisely:**
`xOf`/`yOf` were named ATOMIC vectors (`stats::setNames(...)`), and `[[`
on an atomic vector throws “subscript out of bounds” for an unmatched
name — whereas the surrounding `is.null(yf) || is.null(yt)` guard was
written assuming LIST `[[` semantics (returns `NULL`). An edge
referencing a node id absent from `nodes` (which the real Shiny module’s
ancestors-UNION-descendants focal-trim produces, confirmed by
reproducing directly — an initial manual repro using
[`trimPedigree()`](https://github.com/rmsharp/nprcgenekeepr/reference/trimPedigree.md)’s
ancestors-ONLY output did NOT crash, exposing the exact shape that
matters) hit this gap. Presented the full evidence chain to the owner
via `AskUserQuestion` (fix now / file-and-defer / show-what-exists) —
**owner picked fix now.** 6. **RED:** 2 new tests in
`tests/testthat/test_resolveEdgeNodeCollisions.R` — a minimal synthetic
dangling-edge-reference fixture, and a real-fixture regression (21-row
hardcoded subset, reproducing the exact production crash with no
Shiny/E2E harness needed). Both confirmed failing for the right reason
against unmodified source. Commit `27cad886`. 7. **RED→GREEN gate** via
`AskUserQuestion` — owner approved the minimum fix (named lists instead
of atomic vectors). 8. **GREEN:**
`xOf <- as.list(stats::setNames(nodes$x, nodes$id))` (same for `yOf`) —
a 2-line change. Both new tests pass; full
`test_resolveEdgeNodeCollisions.R` passes; clean full regression 1
failed (`test_markerParentageLikelihood.R`, a timing-benchmark test,
confirmed passing cleanly in isolation both with and without this change
— a load flake, not a regression);
[`devtools::check()`](https://devtools.r-lib.org/reference/check.html) 1
error (the same 2 timing-flake tests, confirmed passing in isolation) +
1 warning + 1 note (both pre-existing/well-documented: non-portable
“Compounding Loop” filename, leftover knitr `figure/` dir);
`lintr::lint_package()` 0 lints (confirmed both before and after).
Commit `fcd24fdb`. 9. **GREEN→REFACTOR gate** via `AskUserQuestion` —
owner confirmed no refactor needed. 10. **Regenerated all 5
screenshots** against the fixed, freshly-reinstalled app — all now
render correctly (visually confirmed via direct image inspection, not
assumed). Confirmed the original `BACKLOG.md` staleness fear was also
real (3 of 5 had drifted to the pre-Track-2 “direct” edge-style default)
— a secondary, now-moot finding once the crash fix made regeneration
possible at all. Committed the 5 PNGs + `BACKLOG.md` item closed `[x]`
(commit `4fcdcb22`). 11. **Re-rendered both articles**
(`pedigree-diagram.qmd`, `kinship2-fidelity-validation.qmd`) to HTML
(quarto) and PDF (quarto + system TeX, confirmed available — MacTeX at
`/Library/TeX/texbin`) for the owner’s review. Verified the PDF’s own
content directly (not just “render succeeded”) via the `Read` tool’s
PDF-page support. **Not committed** — matching the established
`docs/planning/*.html` precedent of regenerable, one-time review
artifacts. 12. **Runtime smoke test (Phase 3E):** DONE — the live
[`shinytest2::AppDriver`](https://rstudio.github.io/shinytest2/reference/AppDriver.html)
reproduction (step 4) plus the post-fix screenshot regeneration (step
10) together ARE the faithful runtime verification for this bug fix; not
a separate, deferred step. 13. **Close-out** (this write-up): `NEWS.Rmd`
Pedigree Diagram entry (plain-language criterion applied).
`PROJECT_LEARNINGS.md` Learning 663. `CLAUDE.md` learnings-count pointer
refreshed. `CHANGELOG.md` entry added.

**Self-assessment (Session 630): 9/10.** **Strengths:** (1) did not
accept the first regenerated screenshot’s error message at face value —
ruled out 2 plausible false leads (stale build, harness artifact) with
real, independent verification before treating the crash as a genuine
production bug, matching this project’s own “verify against ground
truth” standard; (2) when a first manual repro attempt did NOT reproduce
the crash, did not conclude “must be a Shiny-only issue” and stop —
compared the manual repro’s data shape against the real call site
(`modPedigree.R:588`’s `pedigreeData()` reactive) and found the actual
discrepancy (ancestors-only vs. ancestors-UNION-descendants); (3) got a
full, precise server-side R traceback via a standalone `AppDriver` +
`get_logs()` script rather than settling for the browser’s generic
“Error: subscript out of bounds” display; (4) followed every TDD gate
via `AskUserQuestion` as required, including the PRE-RED scope/approach
decision distinct from the phase gates themselves; (5) restored the
working tree to a clean state immediately after finding the crash (the
freshly-generated screenshots showed the error, not the feature) rather
than leaving broken images sitting uncommitted while continuing the
investigation. **Weaknesses:** (1) the very first repro attempt called
`trimPedigree(ped2, ids)` with arguments in the wrong order (the
signature is `(probands, ped, ...)`) — a self-inflicted, self-corrected
mistake that cost a few tool calls before checking `args(trimPedigree)`
directly; (2) did not attempt to verify the
`diagram_twin_connectors.png` screenshot’s exact connector
colors/dash-styles pixel-level (relied on “renders without error,
matches the article’s description” — sufficient for this session’s
purpose, but a more exhaustive verification would zoom/color-sample it
directly).

**Key files:** `R/makePedigreeDiagramData.R:1663-1673`
(`.detectStraight()`, the fix),
`tests/testthat/test_resolveEdgeNodeCollisions.R` (2 new tests, end of
file), `BACKLOG.md` (staleness item closed `[x]`), `NEWS.Rmd` (Pedigree
Diagram section), `PROJECT_LEARNINGS.md` Learning 663, `CLAUDE.md:283`
(learnings-count pointer), `CHANGELOG.md` 2026-08-25 entry,
`vignettes/articles/shiny_app_use/{pb_diagram_legend,diagram_rectilinear_edge_style, diagram_show_names,diagram_affected_shading,diagram_twin_connectors}.png`
(regenerated).

**Gotchas for a future session:** (1) the installed package binary (used
by any
[`shinytest2::AppDriver`](https://rstudio.github.io/shinytest2/reference/AppDriver.html)-
based script, since it launches a SEPARATE R process via
`system.file(..., package = "nprcgenekeepr")`, not
[`pkgload::load_all()`](https://pkgload.r-lib.org/reference/load_all.html)‘s
dev session) can silently go stale relative to source `HEAD` — no
existing session-runner step catches this; a future
E2E/screenshot-generation session should
`devtools::install(quick = TRUE, upgrade = FALSE)` first if the
installed copy’s age vs. `HEAD`’s commit date is not already known to be
fresh. (2) `pedigree-diagram.html`/`.pdf` and
`kinship2-fidelity-validation.pdf` are sitting locally in
`vignettes/articles/` uncommitted (gitignored for `.html` via a nested
`vignettes/articles/.gitignore`; the `.pdf`s are simply untracked) —
regenerable review artifacts, not meant to be committed; a future
session can delete them freely or regenerate via
`quarto render <file>.qmd --to html`/`--to pdf`. (3) The
Claude-in-Chrome browser extension disconnected mid-session (after
working earlier) and could not be reconnected — the local
`python3 -m http.server 8791` (repo root) used to view the articles may
still be running; kill it if found (`lsof -i :8791`). (4)
`.resolveEdgeNodeCollisions()`’s OTHER internal `xOf`/`yOf` computations
(inside the `repeat` loop body, used for `hitInfo`/`jogUnitOf`/
`levelOf`) were confirmed safe as-is (they only ever index `hitRows`
entries that already passed `.detectStraight()`’s own guard) — not
changed, and should not need to be unless `hitRows`’ construction
changes.

### Session 628 Handoff Evaluation (by Session 629)

**Score: 9/10.** **What helped:** the receipt’s `next_steps` field (6
READY items, plus the growing-unpushed-commit-count note) was accurate
and reused directly for this session’s own Phase 0 priorities rendering,
saving a from-scratch `BACKLOG.md` sweep. **What was missing:** nothing
it reasonably could have — this session’s actual deliverable (the red
`R-CMD-check-scheduled` run) postdates S628’s own close-out entirely;
the run that failed triggered at 2026-08-24T09:18:39Z, after S628 had
already closed, so S628’s own Phase 0 `gh run list` correctly reported
“all green” at the time it checked. **What was wrong:** nothing found
inaccurate. **ROI:** high.

### What Session 629 Did

**Deliverable:** Diagnose and fix the red `R-CMD-check-scheduled` run
(found live at this session’s own Phase 0 `gh run list` check, run
`32710819747`, 2026-08-24T09:18:39Z — `ubuntu-latest (release)` failed
with “R CMD check found ERRORs” while devel/oldrel-1/macOS/ Windows all
passed). **DONE.** **Started/Completed:** 2026-08-24 (single session).

**What actually happened, in order:** 1. **Phase 0 orientation** (full
protocol): `SESSION_RUNNER.md`/`SAFEGUARDS.md` read in full,
`git status`/`log`/`diff --stat` (clean except the same pre-classified
untracked artifacts — 4 `docs/planning/pedigree-diagram-*.html`
spike-evidence files, a recurring MS/LibreOffice lock file, an old
`scratchpad/` dir — all older than this session, none new),
`gh issue list` (11 open, unchanged), ledger reconcile
(`CHANGELOG.md`/`HANDOFFS.md` frontiers = HEAD, no gap),
`python3 methodology_dashboard.py` (96/100, 3 individual HIGH file-size
flags re-verified fresh rather than trusted from a prior session’s
summary). **`gh run list --branch master` (the `CLAUDE.md`-mandated
unconditional CI-status check) found the red scheduled run** — surfaced
in the Phase 0 report per the established “report, don’t fix inline”
guardrail. Rendered the priorities list (4 `AskUserQuestion` options,
including the fresh CI finding alongside 3 of S628’s own carried-forward
READY items) — **user picked the CI diagnosis.** 2. **Phase 1B claimed**
(stub + `HANDOFFS.md` `status: pending` receipt, commit `2e06b49c`). 3.
**Diagnosed via the real job log**, not the annotation summary
(`gh api .../jobs/<id>/logs` — `gh run view --log-failed` returned empty
output in this environment): root cause is
`test_positionMatingUnitForest.R:1645`’s `getLiveRenderedPositions()`
call failing inside `chromote:::launch_chrome()` → `startup()` → “Chrome
debugging port not open after 10 seconds” — the exact failure class S616
(2026-08-20) already diagnosed and fixed on `R-CMD-check.yaml`. Per
`PROJECT_LEARNINGS.md` Learning 647’s own rule (“don’t stop after one
push/run in either direction”), re-ran the failed job unmodified
(`gh run rerun --job`) rather than assuming it was the known flake from
memory — passed clean, a second data point confirming the failure was
real-but-intermittent, not a code regression. 4. **Found the true root
cause via step-by-step job inspection** (an initial misstep, corrected
quickly: first inspected `R-CMD-check.yaml`, the wrong file, before
noticing the failing run’s job had only 9 steps where
`R-CMD-check.yaml`’s own Chrome-provisioning steps would put it at 13+ —
traced to `.github/workflows/R-CMD-check-scheduled.yaml`, a
near-duplicate weekly-cron workflow with the identical 5-leg matrix that
never received the S616/S618/S619 fix, because
`tests/testthat/test_r_cmd_check_workflow_chrome_setup.R` guarded only
the non-scheduled file by hardcoded path). Presented the finding + 2
fix-approach options via `AskUserQuestion` (pre-RED scope/approach gate)
— **owner picked the direct port + parametrized test over a deeper DRY
`workflow_call` refactor.** 5. **RED:** parametrized the test file’s
existing 4 `test_that()` blocks to loop over both workflow files (shared
helper functions, not a duplicated file) — confirmed failing only for
`R-CMD-check-scheduled.yaml`, for the right reason (all 4 pattern
elements genuinely absent), while all 4 `R-CMD-check.yaml` tests still
passed. Commit `1bedb5e5`. 6. **RED→GREEN gate** via `AskUserQuestion` —
owner approved. 7. **GREEN:** ported the identical 3-step pattern
(pinned `browser-actions/setup-chrome@v2` + `CHROMOTE_CHROME` +
[`chromote::find_chrome()`](https://rstudio.github.io/chromote/reference/find_chrome.html)
pre-flight assertion, same `if: != macos-latest` guard) into
`R-CMD-check-scheduled.yaml`. All 8 guard tests pass; full clean
regression 0 failed/0 error;
[`devtools::check()`](https://devtools.r-lib.org/reference/check.html) 0
errors (1 warning + 2 notes, all pre-existing/unrelated);
`lintr::lint_package()` 0 lints; YAML parses clean. Commit `156b67ad`.
8. **GREEN→REFACTOR gate** via `AskUserQuestion` — owner confirmed no
refactor needed (the ported block is already the proven pattern; the DRY
alternative stays declined, not filed as a follow-up per owner
direction). 9. **Phase 3E runtime smoke test** — owner-directed, via
`AskUserQuestion`, to the real-CI-required option matching this
project’s own established bar for CI-workflow fixes (S616/S618/S619:
local checks alone are insufficient for a CI-platform-timing-specific
defect). Pushed all 23 pending commits (`git push origin master`,
closing a 5-session unpushed-commit gap); confirmed all 4 push-triggered
workflows green; manually dispatched `R-CMD-check-scheduled.yaml`
(`gh workflow run`, run `32796324964`) — **all 5 matrix legs green,
including `ubuntu-latest (release)`, the leg that failed before.** 10.
**Close-out** (this write-up): `BACKLOG.md` Housekeeping item added and
marked `[x]` DONE in the same session. `PROJECT_LEARNINGS.md` Learning
662 recorded. `CLAUDE.md` learnings-count pointer refreshed (628+/661 →
629+/662). `CHANGELOG.md` entry added.

**Runtime smoke test (Phase 3E):** DONE, live real-CI verification — see
step 9 above. Not silently skipped, not settled for local-only checks:
this is a CI-infrastructure fix, so the faithful verification is a real
GitHub Actions run, which was obtained.

**TDD phase declaration:** full RED→GREEN→REFACTOR cycle,
`AskUserQuestion`-gated at every transition (PRE-RED scope/approach →
RED → GREEN → REFACTOR), matching the S618/S619 precedent for a
CI-workflow-config fix under this project’s TDD contract.

**Close-out checklist mapping** (`CLAUDE.md`): citation /
tutorial-article / `NEWS.Rmd` / `a2interactive.Rmd` / `_pkgdown.yml`
checklists all **N/A** — no new exported function, no new user-facing
Shiny feature, no `R/` production file touched (only a test file and CI
workflow YAML). GitHub issue close-out: **N/A** — not filed as a GitHub
issue, matching the established “found-and-fixed same session” precedent
(Tracks A/B/C, S563-S565). Lint checklist: **DONE** — 0 lints on the
touched test file.

**Self-assessment (Session 629): 9/10.** **Strengths:** (1) did not stop
at “confirmed transient flake, nothing to do” after the first rerun
passed — kept digging into WHY a supposedly-fixed flake class could
still occur at all, which surfaced the real structural gap (workflow
drift + missing test coverage) rather than settling for the shallower,
incomplete conclusion; (2) applied Learning 647’s own “don’t stop after
one data point” rule correctly, getting a second data point via a real
rerun before concluding transience rather than pattern-matching from
memory of the similar-sounding S616 incident; (3) matched this project’s
own established bar for CI-workflow fixes (real CI verification, not
just local checks) without being told to — proposed it via
`AskUserQuestion` rather than declaring done after local tests passed;
(4) used the actual raw job log (`gh api .../jobs/<id>/logs`) rather
than giving up when the higher-level `gh run view --log-failed` returned
empty output; (5) followed every TDD gate via `AskUserQuestion` as
required, including a scope/approach decision distinct from the phase
gates themselves. **Weaknesses:** (1) initially inspected the wrong
workflow file (`R-CMD-check.yaml` instead of
`R-CMD-check-scheduled.yaml`) before the step-numbering gap analysis
corrected course — a fairly quick self-correction, but checking
`gh api .../jobs/<id>` for the parent workflow name directly would have
caught this a few tool calls sooner; (2) the full
diagnose→fix→live-verify cycle took several background CI waits
(appropriate given the real-verification requirement, but worth noting
as the session’s actual wall-clock driver, not the diagnosis or
implementation itself).

**Key files:** `.github/workflows/R-CMD-check-scheduled.yaml` (gained
the 3-step Chrome- provisioning block, lines ~49-93),
`tests/testthat/test_r_cmd_check_workflow_chrome_setup.R` (parametrized
over both workflow files), `BACKLOG.md` Housekeeping (new `[x]` DONE
item), `PROJECT_LEARNINGS.md` Learning 662, `CLAUDE.md:283`
(learnings-count pointer), `CHANGELOG.md` 2026-08-24 `[BL-N]` entry.

**Gotchas for a future session:** (1) if `R-CMD-check.yaml`‘s own
Chrome-provisioning block is ever changed again,
`R-CMD-check-scheduled.yaml` must be updated to match in the SAME
session — the two files are still two independent copies, not a shared
source; `test_r_cmd_check_workflow_chrome_setup.R` will catch a full
removal/reordering of the pattern in either file, but it does NOT catch
every possible divergence between the two copies’ exact step content
(e.g. a future comment-only edit to one and not the other). (2) The
declined DRY `workflow_call` refactor (a single reusable workflow both
files invoke) remains a legitimate future option if this class of drift
recurs a third time — not filed as a `BACKLOG.md` item per this
session’s owner direction, so a future session considering it should
re-derive the case fresh rather than expect a pointer. (3)
`gh run view --log-failed` returned empty output in this environment for
both a run-level and job-level target;
`gh api repos/<owner>/<repo>/actions/jobs/<job-id>/logs` (raw log dump,
then grep) is the reliable fallback that actually worked here. (4) All
23 previously-unpushed commits (spanning S627/S628 plus this session)
are now on `origin/master` — the “N sessions without a push” tracking
some recent handoffs carried can reset.

### Session 627 Handoff Evaluation (by Session 628)

**Score: 9/10.** **What helped:** the receipt’s `next_steps` field named
this exact item — “NEWS.Rmd simplification by feature + guardrail
(READY, Effort L, explicitly multi-round/ iterative — propose the
feature taxonomy + guardrail mechanism via `AskUserQuestion` first)” —
and this session followed that procedural guidance precisely: proposed
the taxonomy and guardrail options via `AskUserQuestion` before touching
`NEWS.Rmd`, then iterated across multiple review rounds with the owner
rather than declaring done after one pass. The receipt’s own priorities
list (unpushed-commit count, other READY items) was accurate and matched
this session’s independent Phase 0 sweep. **What was missing:** nothing
the receipt could reasonably have provided — the specific defects the
owner caught during this session (forward-reference ordering, then
delta-language framing) emerged from live interactive review of prose,
not something a prior session on an unrelated topic (the mating-unit
marker decision) could have anticipated. **What was wrong:** nothing
found inaccurate. **ROI:** high — the exact next-step framing (“propose
via `AskUserQuestion` first”) was followed directly and set this
session’s structure correctly from the start.

### What Session 628 Did

**Deliverable:** Simplify `NEWS.Rmd`’s dev-version (`2.0.0.9000`)
entries for a non-technical audience, reorganize by feature within the
release heading, and design/land a guardrail against re-drift
(`BACKLOG.md` Up Next, found 2026-08-20, owner-directed). **DONE.**
**Started/Completed:** 2026-08-23/24 (spans a date rollover
mid-session).

**What actually happened, in order:** 1. **Phase 0 orientation** (full
protocol): `SESSION_RUNNER.md`/`SAFEGUARDS.md` read in full,
`git status`/`log`/`diff --stat` (clean except pre-classified untracked
artifacts — Quarto render byproducts, a recurring MS/LibreOffice lock
file, an old `scratchpad/` dir, all individually traced, none new),
`gh issue list` (11 open), `gh run list` (all green), ledger reconcile
(one-commit gap = the established self-referential sha-recording
pattern, no real gap), `python3 methodology_dashboard.py` (96/100, 1
HIGH risk = the recurring FM \#28 file-size flag). Rendered the
priorities list (4 `AskUserQuestion` options) — **user picked the
NEWS.Rmd simplification item.** 2. **Phase 1B claimed** (stub +
`HANDOFFS.md` `status: pending` receipt, commit `5c8cc7e1`). 3. **Read
the full 318-line dev-version section** (57→58 entries by direct count)
and proposed a 10-group feature taxonomy plus 4 guardrail-mechanism
options via `AskUserQuestion` — owner approved the taxonomy as proposed,
then asked to clarify the “style note” guardrail option before choosing.
Explaining it surfaced a real weakness in the recommendation (no
distinct beneficiary once traced through, since every `NEWS.Rmd` edit is
session-mediated and every session already reads `CLAUDE.md`) — landed
on the checklist-extension guardrail alone. 4. Owner pushed back on
“every entry traces to a numbered session” as implying a false 1:1
entry-to-session mapping; corrected the claim (many-to-many, sessions
touch many entries and entries get touched by many sessions) without it
changing the underlying guardrail conclusion. 5. **Round 1 draft:**
rewrote all 58 entries for plain language, grouped by the approved
taxonomy, kept issue-number citations and function names (dropped for
Shiny-first entries, kept for script-only “no Shiny UI yet” ones).
Landed the `CLAUDE.md` guardrail extension. Verified via entry-count +
issue-number diffs against the original (caught and restored 6
accidentally dropped citations) and a clean
[`rmarkdown::render()`](https://pkgs.rstudio.com/rmarkdown/reference/render.html).
6. **Round 2:** owner flagged that entries within a group weren’t in
true chronological/dependency order (a refinement could sit before the
introducing entry for the same feature). Ran an 8-agent background
`Workflow` doing real `git log -S`/`CHANGELOG.md` archaeology per
feature group; used the results to reorder Pedigree Diagram and Marker
Genetics (the two groups that actually needed it), catching a real
mis-attribution (the “anchor generation mismatch” fix is S573, not issue
\#144/S473-474 as hinted) and a genuine naming collision (Marker
Genetics’ “Cross-Center” sub-tab vs. the separate “Cross-Center
Identity” tab — verified the real UI label in
`R/modMarkerGenetics.R:143` before wording a fix, rather than inventing
a rename). 7. **Round 3:** owner flagged “the Diagram tab’s layout was
rebuilt” as presupposing a released “before” state that never existed
(the Diagram tab is itself new in this unreleased section). Generalized
past the one instance: found and reworded the same delta-language defect
in 11 further Pedigree Diagram entries and 5 Marker Genetics entries
(every “gained a sub-tab” for a tab that itself debuts this release)
plus 1 in Cross-Center Identity Matching — leaving delta language intact
wherever it’s legitimate (confirmed pre-existing tabs/functions via
`NAMESPACE`/`git log`/`NEWS.md`). Self-caught one own-introduced typo
during the sweep. 8. **Close-out** (this write-up): `BACKLOG.md` item
marked `[x]` DONE with full resolution. `PROJECT_LEARNINGS.md` Learning
661 recorded (the order-vs-wording generalization gap between round 2
and round 3). `CLAUDE.md` learnings-count pointer refreshed (627+/660 →
628+/661). `CHANGELOG.md` `[BL-N]` entry added.

**Runtime smoke test (Phase 3E):** N/A — zero `R/`/`tests/` files
touched; this is a documentation- only session (`NEWS.Rmd`, `NEWS.md`,
`CLAUDE.md`, `BACKLOG.md`, `CHANGELOG.md`, `PROJECT_LEARNINGS.md`). The
file’s own build-equivalent, `rmarkdown::render("NEWS.Rmd")`, was run
clean after every substantive edit instead — not silently skipped,
stated explicitly.

**TDD phase declaration:** no implementation code was written this
session (`NEWS.Rmd` is documentation prose, not R production/test code)
— the RED/GREEN/REFACTOR gates do not apply, no `PRE-RED→RED` transition
entered, matching the S626/S627 precedent for documentation-only
sessions.

**Close-out checklist mapping** (`CLAUDE.md`): citation /
tutorial-article / `a2interactive.Rmd` / `_pkgdown.yml` / lint
checklists all **N/A** — no new exported function, no new Shiny feature,
no `.R` file touched. GitHub issue close-out: **N/A** — this
`BACKLOG.md` item names no GitHub issue.

**Self-assessment (Session 628): 8/10.** **Strengths:** (1) followed the
owner-stated multi-round process precisely rather than declaring done
after one pass; (2) delegated the objective, checkable part of the
ordering fix (real git/CHANGELOG chronology) to a parallel research
workflow, kept the judgment-heavy synthesis (final ordering, wording,
disambiguation) on myself, matching the project’s
capability-tiered-review guidance; (3) caught my own mistake before
shipping it — the first fix for the Cross-Center naming collision
(renaming the sub-tab) would itself have described a UI control that
doesn’t exist, caught only by checking the real Shiny code first; (4)
verified fidelity mechanically (entry counts, issue-number diffs) after
every pass rather than trusting a visual read; (5) used the file’s
actual build-equivalent
([`rmarkdown::render()`](https://pkgs.rstudio.com/rmarkdown/reference/render.html))
repeatedly rather than only inspecting source text. **Weaknesses:** (1)
did not proactively generalize the “reader never experienced this”
principle to WORDING in round 2 — I applied it fully to ORDER (an
8-agent research pass) but left delta-language framing untouched, even
though the same underlying principle (nothing before `2.0.0` establishes
a reader-known baseline) already implied it; it took the owner’s
specific “rebuilt” example in round 3 to surface it, costing an extra
round that could have been one; (2) initially dropped 6 issue-number
citations while paraphrasing for jargon in round 1 — caught by my own
diff check before presenting, but shouldn’t have happened; (3)
introduced a spacing typo during the round-3 rewrite, self-caught only
on a final re-read.

**Key files:** `NEWS.Rmd` (the dev-version section, now organized into
10 `##` feature-group headings under `# nprcgenekeepr 2.0.0.9000`),
`NEWS.md` (regenerated via
[`rmarkdown::render()`](https://pkgs.rstudio.com/rmarkdown/reference/render.html),
must stay in sync with `NEWS.Rmd` — always re-render after any further
`NEWS.Rmd` edit), `CLAUDE.md` (NEWS.Rmd entry checklist, extended with
the plain-language criterion), `BACKLOG.md` (item marked `[x]` DONE),
`PROJECT_LEARNINGS.md` Learning 661, `CHANGELOG.md` 2026-08-24 `[BL-N]`
entry.

**Gotchas for a future session:** (1) any FUTURE `NEWS.Rmd` dev-version
entry added under `2.0.0.9000` must go into the matching feature-group
heading (not appended chronologically at the end) — check the existing
10 groups before adding a new one; if the entry doesn’t fit any existing
group, that’s a real signal to ask before inventing an 11th. (2) The
“everything not yet on CRAN is a draft” principle this session applied
only reaches back to `2.0.0` — confirmed via `NEWS.Rmd`’s own text and
`grep -i cran NEWS.Rmd` that no version before `2.0.0` was ever actually
“accepted”/“published” on CRAN (only “submission”/“resubmission”
attempts) — so `2.0.0` is the correct, and currently only, reader-known
baseline; don’t extend delta-language license further back without
re-verifying if this package’s CRAN history changes. (3) When this
section next regroups or splits into a real release version, re-verify
the “no Shiny UI yet”-tagged entries (script-callable-only functions)
still say that accurately — several might have since gained a Shiny
screen in a later, not-yet-NEWS’d session. (4) `NEWS.md` is a **tracked,
generated** file — never hand-edit it; always regenerate from `NEWS.Rmd`
via `rmarkdown::render(..., output_format = "github_document")` and
commit both together.

### Session 626 Handoff Evaluation (by Session 627)

**Score: 8/10.** **What helped:** the receipt’s `next_steps` field
correctly carried forward the full, unchanged priorities list from S625
— including naming issue \#161 as “still unblocked for an owner decision
(S625’s finding, unchanged)” — which this session confirmed
independently (via a fresh `BACKLOG.md` grep) rather than relying on it
alone, and it matched exactly. The `gotchas` about
`methodology_dashboard.py` being a canonical TRACKED sync target were
accurate background but not directly load-bearing for this session’s
own, unrelated topic. **What was missing:** nothing this session needed
that the receipt could reasonably have provided — S626’s own deliverable
(the `PROJECT_LEARNINGS.md` dashboard question) was unrelated to issue
\#161, so it had no investigative head-start to offer beyond correctly
noting the item was ready to pick up; the GitHub-issue-thread context
(the S592 deferral comment) and the tooltip-loss finding were both
things this session had to discover itself. **What was wrong:** nothing
found inaccurate — every claim in the receipt (commits, the “not a gap”
finding, the priorities list) re-verified true. **ROI:** high — the
priorities list was reused directly as this session’s own Phase 0
render, saving a from-scratch `BACKLOG.md` sweep.

### What Session 627 Did

**Deliverable:** Decide (owner call) whether to hide the `__union_N`
mating-unit node marker to match kinship2’s plain-intersection
convention (issue \#161, unblocked S625). **DONE.**
**Started/Completed:** 2026-08-23 (single session).

**What actually happened, in order:** 1. **Phase 0 orientation** (full
protocol, abbreviated re-check since this is a same-conversation
continuation of S626 — `SESSION_RUNNER.md`/`SAFEGUARDS.md` content
unchanged since S626’s own full read this session):
`git status`/`log`/`diff --stat` (clean except the same pre-classified
untracked artifacts, no new ghost-session signal; local branch grew to
12 commits ahead of `origin/master`, unpushed), `gh issue list` (12
open, unchanged), `gh run list` (all green, unchanged — no push since
last check), ledger reconcile (`CHANGELOG.md`/`HANDOFFS.md` frontiers
one commit behind HEAD only via the established self-referential
sha-recording pattern — no real gap), `python3 methodology_dashboard.py`
(96/100, 1 HIGH risk, same recurring flag), `SESSION_NOTES.md` ACTIVE
TASK re-read to confirm S626’s own handoff landed intact. Rendered the
priorities list (4 `AskUserQuestion` options, same set as S626’s own
list minus the item S626 resolved) — **user picked issue \#161’s marker
decision.** 2. **Phase 1B claimed** (stub + `HANDOFFS.md`
`status: pending` receipt, commit `befa2fb3`). 3. **Re-read the full
`BACKLOG.md` item and the live GitHub issue \#161 thread**
(`gh issue view 161 --json ...`, since `gh issue view` plain form errors
on this repo’s deprecated Projects- classic integration) — confirmed the
S592 deferral rationale and that both named deferral conditions were
satisfied per S625. 4. **Located the exact styling code:**
`R/makePedigreeDiagramData.R:1061-1076` (`unitNodes` construction:
`shape = "dot"`, `size = 6L`, `title = sprintf("%d offspring", ...)`, a
comment citing “Track 1, owner decision S570” for the *color* being kept
`NA` — confirmed via `CHANGELOG.md`/archive that S570’s decision was
specifically about affected-status fill color, a narrower, orthogonal
decision from \#161’s “does a marker exist at all” question). Cross-
checked the established `size = 0` + transparent-color invisible-node
technique (`.addRectilinearWaypoints()`’s D1/D2 waypoint node
construction, lines ~1533-1548) and found it sets
`title = NA_character_` on every such node — a fact not mentioned
anywhere in the GitHub issue, surfacing a real functional cost (loss of
the “N offspring” hover tooltip) beyond the purely visual trade-off
already named. 5. **Gathered visual evidence per this project’s
established practice** (render/attach actual images for any
kinship2-vs-nprcgenekeepr comparison, not just describe metrics): read
`vignettes/articles/shiny_app_use/diagram_rectilinear_edge_style.png`
(this package’s own current rendering) and
`vignettes/articles/kinship2-fidelity-validation-img/trackC-kinship2.png`
(kinship2’s actual output) — both displayed inline, confirming the
issue’s own framing directly. 6. **Presented the decision via
`AskUserQuestion`** (4 options: keep / hide everywhere / hide in
“direct” style only / hold for a live comparison) with both images and
the tooltip finding. **Owner picked “keep the dot” (status quo).** 7.
**Close-out bookkeeping:** `BACKLOG.md` item marked `[x]` DONE in place
with the full resolution recorded (not deleted, matching this project’s
mark-DONE-not-delete convention). [Issue
\#161](https://github.com/rmsharp/nprcgenekeepr/issues/161) closed via
`gh issue close --reason completed` with a comment citing the evidence
and decision, per `CLAUDE.md`’s GitHub issue close-out checklist.
`PROJECT_LEARNINGS.md` Learning 660 recorded. `CLAUDE.md`’s learning/
session-count pointer refreshed (626+/659 → 627+/660). `CHANGELOG.md`
`[issue #161]` entry added.

**Runtime smoke test (Phase 3E):** N/A — zero code changed (the owner’s
decision was “no change”); zero `R/`/`tests/` files touched beyond being
read; the only non-documentation action was a GitHub issue close (not a
runtime change). Not silently skipped: stated explicitly.

**TDD phase declaration:** no implementation code was written this
session (evidence-gathering + decision + documentation only, resolved as
“no change”) — the RED/GREEN/REFACTOR gates do not apply; no
`PRE-RED→RED` transition was entered, matching S626’s own precedent for
a pure decision session (itself matching S546’s “S325 reopened, decision
only”).

**Close-out checklist mapping** (`CLAUDE.md`): citation /
tutorial-article / `NEWS.Rmd` / `a2interactive.Rmd` / `_pkgdown.yml`
checklists all **N/A** — no new exported function, no new user-facing
Shiny feature, no code touched. **GitHub issue close-out: DONE this
session** — issue \#161 closed with the decision and evidence, in the
same session the `BACKLOG.md` item was marked DONE, per the established
checklist. Lint checklist **N/A** — no `.R` files touched.

**Self-assessment (Session 627): 9/10.** **Strengths:** (1) did not
treat the GitHub issue’s own named trade-off as the complete picture —
traced the exact proposed implementation technique (`size = 0` +
transparent color) against its own established precedent (D1/D2
waypoints) and found a real, previously-unnamed functional cost (tooltip
loss) before presenting the decision; (2) gathered and displayed actual
rendered images for both sides of the comparison rather than describing
them, matching this project’s established practice for
kinship2-vs-nprcgenekeepr comparisons; (3) re-read the live GitHub issue
thread directly (not just the `BACKLOG.md` summary) to confirm the S592
deferral rationale before treating it as settled; (4) correctly
distinguished the S570 decision (affected-status fill color, orthogonal)
from this session’s own question (marker existence) rather than
conflating the two just because both cite “mating-unit dot” in nearby
code comments; (5) closed the GitHub issue in the same session per the
established checklist, rather than leaving it open for a later
orientation to catch. **Weaknesses:** (1) did not render a fresh, live
screenshot of this specific package’s own diagram — reused an existing
committed screenshot (`diagram_rectilinear_edge_style.png`, dated Aug
13) rather than confirming it still reflects current `master`
pixel-for-pixel; low risk (no rendering-affecting change has landed in
the mating-unit-dot code since), but not independently re-verified this
session; (2) presented 4 options in the `AskUserQuestion` (including a
hybrid “direct style only” option) without a stated recommendation of
its own — arguably correct for a genuine aesthetic call reserved for the
owner, but a light recommendation with reasoning might have made the
choice faster without constraining it.

### Session 625 Handoff Evaluation (by Session 626)

### Session 625 Handoff Evaluation (by Session 626)

**Score: 7/10.** **What helped:** the receipt precisely named the item
(`BACKLOG.md`’s `PROJECT_LEARNINGS.md`/`methodology_dashboard.py` gap),
gave the exact list contents
(`("SESSION_NOTES.md", "CHANGELOG.md", "HANDOFFS.md") + _BACKLOG_LOCATIONS`)
and the exact measured line count (2,005) with no rediscovery needed —
both re-verified true this session. **What was missing:** the receipt’s
own `gotchas` (3) asserted “worth fixing the dashboard’s own hardcoded
file list before this file grows further unnoticed” — stated as a
settled direction, not as a premise still needing confirmation, even
though the underlying `BACKLOG.md` item it filed (also S625’s own text)
was more carefully hedged as “confirm-then-decide, not an implementation
session.” A `gotchas` field that flagged the “is this actually a Phase 0
mandate, or does it just look like one” open question explicitly would
have made the investigative step this session did anyway more clearly
the point, rather than something the item’s own hedge had to rescue.
**What was wrong:** the underlying factual claim, carried from S625’s
own `BACKLOG.md` item and Learning 658 into this receipt’s `gotchas`,
that `PROJECT_LEARNINGS.md` is “a mandatory Phase 0 (`CLAUDE.md`) read”
— direct grep of `SESSION_RUNNER.md`/`SAFEGUARDS.md` this session found
no such mandate anywhere; `CLAUDE.md` itself says the opposite (“read it
when you need prior-session context”). **ROI:** moderate — the receipt’s
navigational pointers (exact item, exact list, exact count) saved real
rediscovery time, but its framing leaned toward “fix it” when the honest
state was “unconfirmed premise,” and only the item’s own separate, more
careful hedge kept this session from following that lean directly into
an unnecessary code change.

### What Session 626 Did

**Deliverable:** Confirm-then-decide: does `methodology_dashboard.py`’s
size-risk list have a real gap by omitting `PROJECT_LEARNINGS.md`, or is
the omission by design? (`BACKLOG.md` Housekeeping item, found S625.)
**DONE.** **Started/Completed:** 2026-08-23 (single session).

**What actually happened, in order:** 1. **Phase 0 orientation** (full
protocol): `SESSION_RUNNER.md`/`SAFEGUARDS.md` read in full,
`SESSION_NOTES.md` ACTIVE TASK, `gh issue list` (12 open),
`git status`/`log`/`diff --stat` (clean except the same pre-classified
untracked artifacts S624/S625 already traced — no new ghost-session
signal; local branch 8 commits ahead of `origin/master`, unpushed),
`gh run list` (all green), ledger reconcile
(`CHANGELOG.md`/`HANDOFFS.md` frontiers both one commit behind HEAD only
via the established S600/S602-S625 self-referential sha-recording
pattern — no real gap, no backfill needed),
`python3 methodology_dashboard.py` (96/100, 1 HIGH-risk category:
`HANDOFFS.md`/`CHANGELOG.md` both past the 2,000-line cap and
archive-trigger byte budget, recurring/known). Rendered the priorities
list (4 `AskUserQuestion` options built from a full `BACKLOG.md` tag
sweep) — **user picked the `PROJECT_LEARNINGS.md`/dashboard gap item.**
2. **Phase 1B claimed** (stub + `HANDOFFS.md` `status: pending` receipt,
commit `d4c4243a`). 3. **Investigated the item’s own premise before
acting on it.** Read `methodology_dashboard.py`’s `READ_CAP_WATCHED`
section (lines 236-278) in full: its own extensive design comment
explains the list is deliberately restricted to files
`SESSION_RUNNER.md` Phase 0 instructs a session to read IN FULL to
establish state, and explicitly names `ROADMAP.md` as a file
*deliberately* excluded for the same reason (“cited as a pointer, never
as a file read whole to compute anything”). Grepped
`SESSION_RUNNER.md`/`SAFEGUARDS.md` directly for “PROJECT_LEARNINGS” —
zero hits; Phase 0 names only `SAFEGUARDS.md`, `SESSION_NOTES.md`’s
ACTIVE TASK, and `CHANGELOG.md`/ `HANDOFFS.md` (step 6 reconcile) as
full-file reads. Re-read `CLAUDE.md`’s own “Project-specific Learnings”
section: “Read it when you need prior-session context… append new
learnings there, not here” — on-demand, not mandatory. **Conclusion: the
S625 item’s premise (“a mandatory Phase 0 (`CLAUDE.md`) read”) does not
hold** — `PROJECT_LEARNINGS.md` fits the same deliberately- excluded
category as `ROADMAP.md`, not a missed one. 4. Separately checked
whether `methodology_dashboard.py` itself is safe to locally patch even
if the premise had held: grepped the sibling `methodology` checkout’s
`bin/_manifest.py` and confirmed `starter-kit/methodology_dashboard.py`
is a canonical **TRACKED** dest (kept current by sync); this project’s
copy is already stale (v2.14.0 vs. canonical v2.15.2) per the
dashboard’s own startup warning — a second, independent reason not to
hand-edit the list even as a fallback. 5. **Presented the finding to the
owner via `AskUserQuestion`** (3 options: correct the record / flag the
size anyway as a different, non-FM#28 risk / hold and dig deeper first)
rather than deciding unilaterally, since the finding overturns a
predecessor’s stated premise. **Owner picked “correct the record.”** 6.
**Close-out bookkeeping:** `BACKLOG.md` item marked `[x]` DONE in place
with the resolution recorded (matching this project’s
mark-DONE-not-delete convention) — no dashboard code change made.
`PROJECT_LEARNINGS.md` Learning 659 recorded (confirm a predecessor’s
premise by direct grep against the actual mandate, even when the item is
already well-hedged). `CLAUDE.md`’s learning/session-count pointer
refreshed (625+/658 → 626+/659). `CHANGELOG.md`
`[BL-projectLearningsGapConfirm]` entry added.

**Runtime smoke test (Phase 3E):** N/A — documentation-only changes
(`BACKLOG.md`, `PROJECT_LEARNINGS.md`, `CLAUDE.md`, `CHANGELOG.md`
prose); zero `R/` or `tests/` files touched, zero runtime behavior
changed, zero `.py` files touched (investigated
`methodology_dashboard.py` read-only, never edited). Not silently
skipped: stated explicitly.

**TDD phase declaration:** no implementation code was written this
session (investigation + decision + documentation only) — the
RED/GREEN/REFACTOR gates do not apply; no `PRE-RED→RED` transition was
ever entered, matching this project’s established precedent for pure
decision/ documentation sessions (e.g. S546’s “S325 reopened, decision
only”).

**Close-out checklist mapping** (`CLAUDE.md`): citation /
tutorial-article / `NEWS.Rmd` / `a2interactive.Rmd` / `_pkgdown.yml`
checklists all **N/A** — no new exported function, no new user-facing
Shiny feature, no code touched. GitHub issue close-out **N/A** —
`BACKLOG.md`-only housekeeping, not tied to a GitHub issue number. Lint
checklist **N/A** — no `.R` files touched.

**Self-assessment (Session 626): 9/10.** **Strengths:** (1) did not
accept the predecessor’s stated premise (“a mandatory Phase 0 read”) at
face value despite it appearing in both a `BACKLOG.md` item and a
`HANDOFFS.md` gotcha — verified it by direct grep against the actual
mandate (`SESSION_RUNNER.md`) rather than trusting repetition across two
artifacts as corroboration; (2) found and applied the dashboard tool’s
own stated design rationale (the `ROADMAP.md` precedent) as the deciding
evidence, rather than reasoning about what “should” be flagged from
first principles; (3) checked a second, independent angle (the
TRACKED-dest sync-safety question) even after the first finding made the
primary decision fairly clear, since it materially affects the “flag it
anyway” alternative the user might have picked; (4) surfaced the finding
via `AskUserQuestion` rather than unilaterally closing the item out
silently, since it directly overturns a predecessor’s claim.
**Weaknesses:** (1) added a new `PROJECT_LEARNINGS.md` entry (659) to a
file whose own size was the subject of this session’s investigation — an
unavoidable tension (the append-only Learning ledger is where this
project records exactly this kind of finding) but worth naming directly,
matching S624/S625’s own self-assessments naming the same tension; (2)
did not additionally check whether any *other* mandated-read file
(e.g. a workstream doc) references `PROJECT_LEARNINGS.md` as something
to read in full — the grep covered `SESSION_RUNNER.md`/
`SAFEGUARDS.md`/`CLAUDE.md`/`docs/methodology/workstreams/` but a
narrower, more exhaustive sweep of every `.md` file for a “read
PROJECT_LEARNINGS.md in full” instruction was not run; the finding is
strong but not from an exhaustive negative-result search.

### Session 624 Handoff Evaluation (by Session 625)

**Score: 9/10.** **What helped:** the receipt’s `next_steps` field named
the 16/17-item `BACKLOG.md` `[x]`-sweep as READY with useful count-drift
context (“now 17 items, since this session added one more
DONE-but-unswept entry”) — directionally correct (the true count at
claim was 18, still off by one, but the signal “the cited count has
drifted since S619” was right and prompted a direct re-count rather than
trusting either number). `gotchas` (3) — “this project’s convention for
a completed `BACKLOG.md` item is mark `[x]` DONE with the resolution
written in place, not delete the line outright” — was directly
load-bearing for correctly closing THIS session’s own triggering item
(marked `[x]` DONE in place, not deleted same-session, avoiding a
self-referential ambiguity). `gotchas` (1) — flagging that
`PROJECT_LEARNINGS.md` is past the 2,000-line FM \#28 cap but “wasn’t in
the dashboard’s reported list this session, worth confirming” — was
directly acted on: confirmed true this session (2,005 lines,
`methodology_dashboard.py`’s size-risk list hardcoded to 3 other files,
`PROJECT_LEARNINGS.md` absent) and filed as a new `BACKLOG.md` item
rather than left unconfirmed. **What was missing:** nothing the receipt
could reasonably have included — the dangling-cross-reference risk this
session found (deleting an item broke a still-open sibling item’s
“Tracks 1-3 above”/“the follow-up item below” pointers) is specific to
actually performing a large bulk deletion, not something a prior session
doing different work could have anticipated. **What was wrong:** nothing
found inaccurate — the receipt’s own claims (commits, root cause, scope)
all re-verified true. **ROI:** high — both load-bearing gotchas paid off
directly in this session’s own close-out decisions.

### What Session 625 Did

**Deliverable:** Sweep the `[x]`-checked, fully-resolved items out of
`BACKLOG.md` (`BACKLOG.md` Housekeeping item, found S619). **DONE.**
**Started/Completed:** 2026-08-23 (single session).

**What actually happened, in order:** 1. **Phase 0 orientation** (full
protocol): `SESSION_RUNNER.md`/`SAFEGUARDS.md` read in full,
`SESSION_NOTES.md` ACTIVE TASK, `gh issue list` (12 open),
`git status`/`log`/`diff --stat` (clean except pre-existing,
already-classified untracked artifacts; local branch 4 commits ahead of
`origin/master`, unpushed since S624), `gh run list` (all green), ledger
reconcile (no gap — the one commit past `CHANGELOG.md`‘s frontier is the
documented S600/S602-S623 self-referential sha-recording pattern, not a
new unrecorded action), `python3 methodology_dashboard.py` (96/100, 1
HIGH risk, same recurring FM \#28 flag). Rendered the priorities list (4
`AskUserQuestion` options, built from a full `BACKLOG.md` tag sweep
since no single predecessor-stated order existed this time) — **user
picked the `[x]`-item sweep.** 2. **Phase 1B claimed** (stub +
`HANDOFFS.md` `status: pending` receipt, commit `42e59d0b`). Direct
re-count at claim found **18** `[x]`-checked items, not the “16” the
triggering item cites (2 more checked since S619: S607’s MIT/REUSE
badges, S624’s own `CLAUDE.md`-filter item). Confirmed, not
spot-checked, every one of the 18 items’ cited session numbers
(S574-S624) has a substantive `CHANGELOG.md` entry (`CHANGELOG.md` +
`docs/archive/CHANGELOG*.md`); spot-verified the largest deletion (the
S592-S621 same-row-collision/Walker-BJL chain, ~590 lines) resolves to
real `[issue #141]`-tagged entries, not incidental mentions. 3. **Mapped
exact line boundaries** for all 18 items via
`grep -n "^- \[x\]\|^- \[ \]\|^## "` (marker-to-next-marker ranges),
deleted all 18 in one `sed` pass into a scratch file, verified before
applying: `[x]` count 0, `[ ]` count unchanged (36=36, no open item
caught in a deletion range), every `##` section header intact, no
double-blank-line artifacts at any seam. 4. **Found and fixed one
dangling cross-reference this deletion created** (not caught by the
established `CHANGELOG.md`/Learning/file-path grep checklist, since it’s
a same-file spatial pointer, not a citation): the kept issue \#161 item
referenced “Tracks 1-3 above” and “the follow-up item below,” both
now-deleted. Rewrote in place with an S625 update noting both of S592’s
named deferral conditions are now satisfied (Tracks 1-3 shipped S596;
the Track 3 trade-offs fully resolved by the unrelated Walker/BJL
migration, issue \#141 closed S621), unblocking \#161 for an owner
decision. 5. **Full-file coherence re-read** (both halves, ~1,150 lines)
confirmed no truncated sentences or other artifacts beyond the one
cross-reference already fixed. 6. **Close-out bookkeeping:** triggering
item marked `[x]` DONE in place (not deleted same-session, matching this
project’s mark-DONE-not-delete convention). New `BACKLOG.md`
Housekeeping item filed (found, not fixed, per Learning 382 precedent):
`PROJECT_LEARNINGS.md` is past the 2,000-line FM \#28 cap (2,005 lines)
but `methodology_dashboard.py`’s hardcoded size-risk list doesn’t
include it. `PROJECT_LEARNINGS.md` Learning 658 recorded (dangling
spatial cross-references after `BACKLOG.md` deletion + the
dashboard-coverage gap); `CLAUDE.md`’s learning-count/session-count
pointer refreshed (624+/657 → 625+/658). `CHANGELOG.md` entry to follow
this commit. Net: `BACKLOG.md` 2,192 → ~1,170 lines (~47% reduction,
after this close-out’s own additions).

**Runtime smoke test (Phase 3E):** N/A — documentation-only changes
(`BACKLOG.md`, `PROJECT_LEARNINGS.md`, `CLAUDE.md` prose); zero `R/` or
`tests/` files touched, zero runtime behavior changed. Not silently
skipped: stated explicitly.

**Close-out checklist mapping** (`CLAUDE.md`): citation /
tutorial-article / `NEWS.Rmd` / `a2interactive.Rmd` / `_pkgdown.yml`
checklists all **N/A** — no new exported function, no new user-facing
Shiny feature, no code touched. GitHub issue close-out **N/A** —
`BACKLOG.md`-only housekeeping, not tied to a GitHub issue number. Lint
checklist **N/A** — no `.R` files touched.

**Self-assessment (Session 625): 9/10.** **Strengths:** (1) did not
trust either the triggering item’s stated count (16) or S624’s own
updated guess (17) — re-counted directly (18) and grepped CHANGELOG
coverage for every cited session number before deleting anything, rather
than assuming the prior sessions’ spot-checks were sufficient; (2)
computed exact line-range boundaries via a single `grep -n` pass and
verified the deletion in a scratch file before applying it, rather than
editing the live file iteratively and risking a mismatched
`old_string`/partial edit across 1,000+ lines; (3) caught and fixed a
real defect the deletion itself introduced (the dangling issue \#161
cross-reference) via a full-file re-read, not just a diff-stat glance;
(4) surfaced a genuinely new, on-theme finding (the
`PROJECT_LEARNINGS.md`/dashboard gap) without scope-creeping into fixing
it mid-session, matching the established Learning 382 precedent.
**Weaknesses:** (1) added a new `PROJECT_LEARNINGS.md` entry (658) and a
new `BACKLOG.md` item to a file already flagged oversized by the
dashboard, the same FM \#28 tension S624’s own self-assessment flagged
for Learning 657 — this session at least made the tension itself a
tracked, actionable item rather than only restating it; (2) did not
attempt a second independent verification pass of the `sed` deletion
(e.g. `git diff` reviewed by a fresh sub-agent) beyond this session’s
own direct re-reads — for a ~1,050-line deletion, an independent check
would have been a stronger guarantee against a subtle off-by-one
boundary error, though the direct seam-by-seam spot checks and full-file
re-read this session did perform found nothing wrong.

### Session 623 Handoff Evaluation (by Session 624)

**Score: 9/10.** **What helped:** the receipt’s `next_steps` field named
this exact deliverable as item 1 — “fix or re-scope CLAUDE.md’s stale
test-app-*/test-e2e-* ‘Clean regression read’ filter (READY, Effort S)”
— with the precise rationale (root cause gone, filter matches nothing,
risks hiding a future regression) already worked out; zero rediscovery
needed. `gotchas` (4) — “CLAUDE.md’s test-app-*/test-e2e-*
baseline-noise exclusion filter is stale … do not rely on it” — was
directly load-bearing, and the underlying `BACKLOG.md` item (which the
receipt pointed to) carried the exact line citation
(`tests/testthat/helper-shinytest2.R:200`) this session verified and
reused directly in the fix. **What was missing:** nothing critical — the
item left “remove vs. re-scope” as an open decision for the executing
session, which was the right call: it wasn’t yet established whether a
live exception remained (none did, confirmed this session), so
pre-deciding would have been guessing. **What was wrong:** nothing found
inaccurate — every claim in the receipt/BACKLOG item (the line number,
the “0 failed/0 error for weeks” pattern, issue \#163 as the concrete
near-miss example) re-verified true this session. **ROI:** high — direct
pickup with no investigative overhead beyond this session’s own
scope-verification grep sweep.

### What Session 624 Did

**Deliverable:** Fix `CLAUDE.md`’s stale `test-app-*`/`test-e2e-*`
“Clean regression read” baseline-noise filter (`BACKLOG.md` Housekeeping
item, found S623). **DONE.** **Started/Completed:** 2026-08-23 (single
session).

**What actually happened, in order:** 1. **Phase 0 orientation** (full
protocol): `SESSION_RUNNER.md`/`SAFEGUARDS.md` read in full,
`SESSION_NOTES.md` ACTIVE TASK, `gh issue list` (12 open),
`git status`/`log`/`diff --stat` (clean, S623 fully closed out, ledger
frontier == HEAD, no reconcile needed), `gh run list` (all green,
including today’s scheduled `shinytest2.yaml`),
`python3 methodology_dashboard.py` (96/100, 1 HIGH risk —
`HANDOFFS.md`/`CHANGELOG.md`/`BACKLOG.md` all past the 2,000-line read
cap, FM \#28, unchanged/recurring). Individually traced 3 untracked-file
groups found by `git status` rather than batch-assuming: the 4
`docs/planning/*.html` files are known Quarto render byproducts of
tracked `.qmd` sources;
`inst/extdata/reference/~$e Compounding Loop.html` is a recurring
MS/LibreOffice lock-file artifact matching the exact Session 568
precedent (deleted once already, reappeared); `scratchpad/` is leftover
debug scripts from the already-shipped S598-S602
duplicate-occurrence-selection investigation. None were ghost-session
deliverables. Rendered the priorities list (4 `AskUserQuestion` options
in S623’s own stated order, +2 more named below the picker per the
\>4-items rule) — **user picked item 1, the stale filter fix.** 2.
**Phase 1B claimed** (this stub + `HANDOFFS.md` `status: pending`
receipt, commit `f1051c65`). 3. **Scope verification before editing:**
grepped the whole repo for the stale filter’s text and the “baseline
noise” framing (~20 hits). Classified each individually rather than
assuming grep’s hit count was the edit count: `docs/archive/*.md`
(frozen), `PROJECT_LEARNINGS.md` Learning \#2/#4 (frozen historical
record, explicitly named off-limits by the originating `BACKLOG.md`
item), a dozen `docs/planning/*.md` historical plans (none of their
issue numbers are open;
`cran-2.0.0-submission-plan.md`/`shiny-module-conversion-plan.md` both
predate the already-shipped 2.0.0 release), and narrative in
`CHANGELOG.md`/`SESSION_NOTES.md` describing past sessions’ findings.
Only `CLAUDE.md`’s own Build/Test/Verify section was live guidance.
Re-verified (not trusted from the `BACKLOG.md` item’s text) that
`create_test_app()` is defined at
`tests/testthat/helper-shinytest2.R:200` exactly. 4. **Fix:** removed
the `!grepl("test-app-|test-e2e-", file)` exclusion from `CLAUDE.md`’s
“Clean regression read” entry; added a dated inline note (S624)
explaining the removal and warning against reviving a permanent
file-name-pattern amnesty, without touching Learning \#2/#4 itself. 5.
**Close-out bookkeeping:** `BACKLOG.md` Housekeeping item marked `[x]`
DONE with the resolution recorded in place (matching this project’s
mark-DONE-not-delete convention, per the standing 16-item-sweep
housekeeping item). `PROJECT_LEARNINGS.md` Learning 657 recorded (scope
verification: classify each grep hit live-vs-frozen before editing);
`CLAUDE.md`’s own learning-count cross-reference refreshed (656→657).
`CHANGELOG.md` `[BL-cleanRegressionFilter]` entry added. Commit
`e12ac08c` (CLAUDE.md fix + BACKLOG.md + PROJECT_LEARNINGS.md, 3 files).

**Runtime smoke test (Phase 3E):** N/A — documentation-only change to
`CLAUDE.md` prose; zero `R/` or `tests/` files touched, zero runtime
behavior changed. Not silently skipped: stated explicitly.

**Close-out checklist mapping** (`CLAUDE.md`): citation /
tutorial-article / `NEWS.Rmd` / `a2interactive.Rmd` / `_pkgdown.yml`
checklists all **N/A** — no new exported function, no new user-facing
Shiny feature, no code touched. GitHub issue close-out **N/A** — this is
a `BACKLOG.md`-only housekeeping item, not tied to a GitHub issue
number. Lint checklist **N/A** — no `.R` files touched.

**Self-assessment (Session 624): 9/10.** **Strengths:** (1) verified
scope by grepping the whole repo before editing, rather than assuming
the one obvious location was the only one, and correctly classified
every hit as live vs. frozen instead of either over-editing
archives/frozen learnings or under-editing a live doc; (2) re-verified
the cited line number and regression-count claims directly rather than
trusting the `BACKLOG.md` item’s prose; (3) preserved this project’s
no-retroactive-edit precedent for frozen documents (Learning \#2/#4,
`docs/archive/`, closed-issue planning docs); (4) closed every standing
bookkeeping obligation in the same session (BACKLOG DONE, CHANGELOG
entry, learning + pointer refresh) without deferring any of it.
**Weaknesses:** (1) did not re-run a fresh full regression suite this
session — relied on S623’s own same-day unfiltered run; defensible since
zero code changed, but a fully independent verification would have
re-run it; (2) the new Learning 657, while accurate and reusable, sits
close in spirit to already-established scope-verification precedents
(Learnings 479, 653) — could arguably have been a shorter addendum
rather than a full new numbered entry, especially given
`PROJECT_LEARNINGS.md` is itself now past the 2,000-line read cap the
dashboard already flags for its sibling ledgers (an FM \#28 pressure
this session added to rather than relieved).

### Session 622 Handoff Evaluation (by Session 623)

**Score: 9/10.** **What helped:** the receipt’s `next_steps` field named
issue \#163 specifically as READY, with a concrete investigative
starting point (“likely candidate is a missing/insufficient
`wait_for_idle()` around the D6 marker-genetics/mate-pair cross-module
wiring”) — directionally correct (the actual root cause IS a missing
wait for an async step, just a more specific one: DT’s own
`server = TRUE` client\<-\>server AJAX round-trip, not a generic Shiny
idle wait) and enough to start the investigation focused rather than
blind. `gotchas` (2) — `gh run view <id> --log-failed` returning empty
for this job’s log, work around via
`gh api repos/.../actions/jobs/<id>/logs` directly — was directly
load-bearing: this session hit the identical need (pulling 3 separate
historical job logs, 08-18/08-20/08-21) and used the API path from the
start with zero rediscovery time. **What was missing:** nothing the
receipt could reasonably have included — the exact mechanism (DT’s
server-side AJAX round-trip racing the app’s own `data-ready` signal)
genuinely required this session’s own investigation; S622 correctly
scoped it out rather than guessing. **What was wrong:** nothing found
inaccurate. **ROI:** high — both the next_steps direction and the gotcha
saved real investigative time.

### What Session 623 Did

**Deliverable:** Diagnose and fix the intermittent
`e2e-mate-pair-analysis-module` shinytest2 E2E failure — GitHub issue
\#163 (found by S622 in the same nightly CI run as the separately-fixed
`e2e-pedigree-` failures). **DONE.** **Started/Completed:**
2026-08-21/2026-08-22 (single session).

**What actually happened, in order:**

1.  **Phase 0 orientation** (full protocol), then a mid-session owner
    interjection: the user flagged that `CLAUDE.md`’s “Clean regression
    read” guidance still treats `test-app-*`/`test-e2e-*` files as
    “pre-existing baseline noise” (citing `PROJECT_LEARNINGS.md`
    Learning 2/4, Sessions 3-4) even though the project has run 0
    failed/0 error for weeks. Verified directly: `create_test_app()`
    (the specific thing undefined back in S3/S4) is now defined
    (`tests/testthat/helper-shinytest2.R:200`) and has been for a long
    time — the filter’s premise is stale and, worse, would silently
    exclude a REAL regression landing in exactly those files (this
    session’s own issue \#163 is a concrete example). Logged to
    `BACKLOG.md` Housekeeping (READY, Effort S) rather than fixed
    mid-session (kept to the one claimed deliverable); this session’s
    own regression checks did not use that filter.
2.  **CI forensics**: pulled job logs for all 3 relevant
    `shinytest2.yaml` scheduled runs (08-18 failed, 08-20 passed, 08-21
    failed — same 2 assertions both failing runs) via the raw GitHub API
    (S622’s own gotcha about `gh run view --log-failed` returning empty
    saved rediscovery time). Confirmed 3 earlier “failure” runs
    (08-12/08-13/08-14) were a DIFFERENT, already-resolved bug
    (`makeExamplePedigreeFile` not yet available) — correctly excluded
    from scope, not conflated with the current issue.
3.  **Root-caused via direct execution + instrumentation, not
    inference**: read
    [`modMatePairServer()`](https://github.com/rmsharp/nprcgenekeepr/reference/modMatePairServer.md)
    (`R/modMatePair.R`) and found
    `session$sendCustomMessage("setDataReady", ...)` fires synchronously
    right after `matchResults(res)`, but `pairsTable`/`excludedTable`
    are `DT::renderDT(server = TRUE)` outputs (the DT package default) —
    a separate, later, client\<-\>server AJAX round-trip `data-ready`
    says nothing about. Confirmed empirically via 3 independent lines of
    evidence: (1) both real CI failures’ captured HTML showed
    `.dataTables_processing` still `display: block` at read time; (2) a
    JS-instrumented local probe (event listeners on
    `nprcgenekeepr:dataReady` + DT’s own `xhr.dt`/ `draw.dt`) measured a
    genuine ~130-150ms gap even unthrottled locally; (3) a Chrome
    DevTools Protocol network-throttle harness
    (`app$get_chromote_session()$Network$emulateNetworkConditions()`)
    reliably reproduced the exact real failure (0 rows, id absent,
    processing visible) without a fix and reliably passed with one — a
    genuine forced RED→GREEN cycle for a bug that would not reproduce
    locally at normal speed (8/8 clean in an unthrottled tight loop,
    matching the `diagnose` skill’s own “raise the reproduction rate”
    guidance for non-deterministic bugs). Presented root cause + fix
    approach via `AskUserQuestion` (PRE-RED gate) before writing any
    test code — user approved the recommended (defensive, both-tables)
    approach.
4.  **RED**: added a new shared `wait_for_dt_rendered()` helper to
    `tests/testthat/helper-shinytest2.R` (polls a DT table’s own
    processing indicator until hidden); wired it in before both
    `pairsTable` and `excludedTable` reads in
    `test-e2e-mate-pair-analysis-module.R`. **Caught a real bug in the
    helper’s own first draft during the throttled verification**, not
    just in the target defect: used `el.closest('.dataTables_wrapper')`,
    which returned null 100% of the time because DT’s wrapper is a DOM
    *child* of the table’s outer container, not an ancestor
    (`.closest()` only walks up) — the broken helper’s own 15s timeout
    simply outlasted the real (much shorter) render time, so a
    superficial check would have looked like a pass for the wrong
    reason. Caught by comparing the poll’s own FALSE result against an
    immediately-following direct HTML read that showed the table WAS
    actually populated — the contradiction was the tell. Fixed with
    `.querySelector(...)` (descendant search). Presented RED evidence +
    the caught bug via `AskUserQuestion` (RED→GREEN gate) before running
    the confirming test suite.
5.  **GREEN**: touched file (`test-e2e-mate-pair-analysis-module.R`) ran
    5/5 clean at normal speed (0 failed/error/warning each run). Full
    project-wide regression run **unfiltered** (`NPRC_RUN_E2E=true`, no
    `test-app-*`/`test-e2e-*` exclusion, per this session’s own
    Learning-2/4 finding above): 6,606 passed / 0 failed / 0 error / 2
    skipped / 39 warnings across 2,244 test blocks — the 39 warnings
    confirmed pre-existing/unrelated (the touched file itself ran 0
    warnings across all 5 of its own runs). A background-process
    handling mistake mid-run: killed a backgrounded regression run out
    of an unfounded timeout concern, right as it happened to complete
    naturally — produced a corrupted/truncated read; caught immediately
    (the printed content didn’t match a clean run’s shape) and re-ran
    cleanly via `nohup`+`disown` rather than trusting the corrupted
    output.
6.  **REFACTOR**: `lintr::lint()` 0 findings on both touched files (no
    duplication to extract — the helper was written once, shared, from
    the start).
    [`devtools::check()`](https://devtools.r-lib.org/reference/check.html)
    deliberately skipped (test-only diff, matching S622’s own precedent
    for the identical file-type diff).
7.  **Close-out**: `PROJECT_LEARNINGS.md` Learning 656 recorded;
    `CLAUDE.md` learning-count cross-reference refreshed (655→656);
    `CHANGELOG.md` `[issue #163]` entry added; issue \#163 closed on
    GitHub citing the full evidence trail; this handoff written.
8.  **Post-close-out, owner-directed**: pushed all 11 session commits to
    `origin/master` (`004eb3e9..9128ee52`), then manually dispatched
    `shinytest2.yaml` (`gh workflow run`, since it only runs on
    schedule/dispatch, never on push) rather than waiting for tomorrow’s
    schedule. **Result: SUCCESS** (run `32594167345`) —
    `e2e-mate-pair-analysis-module`: `passed=8 failed=0 error=0`;
    `e2e-pedigree-` (S622’s fix, same push):
    `passed=73 failed=0 error=0`. Both fixes now confirmed on live
    GitHub Actions CI, not just local verification.
    `CHANGELOG.md`/`HANDOFFS.md` updated with this result.

**Runtime smoke test (Phase 3E):** n/a in the traditional sense — no
production runtime behavior changed (zero `R/` diffs). The functional
equivalent: the fixed tests were run against the REAL Shiny app
(shinytest2 + chromote, both real and throttled-real), confirming the
fix holds under the actual client-server rendering path under both
normal and stressed network conditions.

**Close-out checklist mapping** (`CLAUDE.md`): citation /
tutorial-article / `NEWS.Rmd` / `a2interactive.Rmd` / `_pkgdown.yml`
checklists all **N/A** — no new exported function, no new user-facing
Shiny feature, test-file-only diff. GitHub issue close-out **DONE**
(issue \#163 closed this session, citing the `CHANGELOG.md` entry and
verification evidence). Lint checklist **DONE** (0 lints, confirmed
above).

**Self-assessment (Session 623): 9/10.** **Strengths:** (1) Did not stop
at plausible static evidence (the captured CI HTML alone) — built a
JS-instrumented probe to MEASURE the actual race window, then went
further and used Chrome DevTools Protocol network throttling to force a
genuine, repeatable RED→GREEN cycle for a bug that would not reproduce
locally at normal speed, rather than settling for “probably fixed.” (2)
Caught a real bug in my own fix’s first draft
(`closest()`/`querySelector()`) via the throttled verification itself,
before it ever reached the committed test file — the verification
process did its job. (3) Took the user’s mid-session Learning-2/4
observation seriously: verified it directly (confirmed
`create_test_app()` is now defined) rather than deferring or dismissing
it, and concretely changed this session’s own regression-check
methodology (unfiltered) as a result, not just noted it for later. (4)
Correctly scoped the 3 older (08-12/08-13/08-14) CI “failures” as a
different, already-resolved bug rather than folding them into this
investigation. **Weaknesses:** (1) Mishandled a backgrounded process
once — killed it out of an unfounded timeout worry right as it was
completing naturally, producing corrupted output that had to be
diagnosed and the run redone; cost real time even though the underlying
regression evidence was never actually lost (recovered cleanly via
`nohup`+`disown`). (2) Spent several tool calls on ineffective “wait for
the background task” filler (repeated no-op Bash calls) before settling
on a single proper long-running background waiter — should have gone
straight to that pattern.

### Session 621 Handoff Evaluation (by Session 622)

**Score: 9/10.** **What helped:** the receipt’s `next_steps` field gave
a clean, ordered BACKLOG priority list (pedigree-diagram package-split
scoping; NEWS.Rmd simplification; the 16-item BACKLOG sweep; 4
lower-priority items including `context_budget.py` and the macOS
chromote hang) that fed directly into this session’s own Phase 0
priorities list — no reconstruction needed, just re-verification the
tags were still accurate (they were). `gotchas` (2) — “`__proj_` node-id
prefix is PRE-EXISTING `.buildMatingUnitForest()` dogleg infrastructure,
NOT introduced by Walker/BJL” — was directly load-bearing: this
session’s own root-cause investigation independently rediscovered
`__proj_` nodes mid-diagnosis (the first jog-only-waypoint model gave 67
components instead of the ground-truth 56) and the gotcha’s framing
meant the “wait, is this a Walker/BJL artifact?” tangent was ruled out
in seconds rather than becoming its own investigative detour. **What was
missing:** the receipt couldn’t have flagged this (it’s new information,
not a gap in S621’s own scope), but worth noting for the record: S621’s
own close-out did not run the `gh run list` CI check this session’s
Phase 0 found red (the scheduled `shinytest2.yaml` run) — not a fault of
S621 (that check runs at ORIENT, not close-out, and S621’s own Orient
predates the red run entirely by a day), just context for why this sat
unnoticed until now. **What was wrong:** nothing found inaccurate.
**ROI:** high — the handoff’s own priorities list was accurate and
immediately actionable, and the `__proj_` gotcha specifically saved real
investigative time.

### What Session 622 Did

**Deliverable:** Diagnose (and fix) the 2 shinytest2 `e2e-pedigree-` E2E
failures surfaced by the nightly CI run, found via this session’s own
Phase 0 unconditional `gh run list` check (`CLAUDE.md`’s S545 addition).
**DONE.** **Started/Completed:** 2026-08-21 (single session).

**What actually happened, in order:**

1.  **Phase 0 orientation** (full protocol:
    `SESSION_RUNNER.md`/`SAFEGUARDS.md` read in full,
    `SESSION_NOTES.md`, `gh issue list` (12 open),
    `git status`/`log`/`diff --stat` (clean, S621 fully closed out),
    `python3 methodology_dashboard.py` (96/100, 1 HIGH risk —
    `HANDOFFS.md`/ `BACKLOG.md`/`CHANGELOG.md` all past the 2,000-line
    read cap, FM \#28), ghost-session check on 6 untracked files (all
    pre-existing, already traced by S614). **`gh run list` found the
    scheduled `shinytest2.yaml` run red** (2026-08-21T07:19 UTC)
    alongside all green push-triggered runs — surfaced as a NEW finding,
    not yet in `BACKLOG.md`/GitHub issues. Rendered the priorities list
    (4 `AskUserQuestion` options: the CI failure, `context_budget.py`
    evaluation, `BACKLOG.md` housekeeping continuation, the 16-item DONE
    sweep) — **user picked the CI failure.**
2.  **CI forensics before claiming scope**, since the raw failure output
    alone didn’t say which of the 19 module groups failed or why: pulled
    the full job log directly via
    `gh api repos/.../actions/jobs/<id>/logs` (the
    `gh run view --log-failed` CLI path returned empty for this job — a
    tooling gap worth remembering, not investigated further). Found 2
    distinct, unrelated failing groups: `e2e-mate-pair-analysis-module`
    (2 failures, empty results table, later confirmed intermittent —
    passed on the 2026-08-20 nightly run) and `e2e-pedigree-` (2
    failures, same exact assertions both times). Cross-checked the
    pre-Walker/BJL-cutover 2026-08-18 nightly log and found the
    identical `e2e-pedigree-` failure shape already present — ruling out
    “fresh migration regression” before it was ever claimed as the
    working hypothesis.
3.  **Phase 1B claimed** (`SESSION_NOTES.md` stub + `HANDOFFS.md`
    `status: pending` receipt, committed `09f74f72`), scoped explicitly
    to `e2e-pedigree-` only — the mate-pair-analysis flake stated as
    out-of-scope up front, per “one intent” discipline.
4.  **Root-caused by direct execution, not inference** (the `diagnose`
    skill’s Phase 1-4): called
    [`makePedigreeMatingLayout()`](https://github.com/rmsharp/nprcgenekeepr/reference/makePedigreeMatingLayout.md)
    locally against the real `obfuscated_rhesus_mhc_ped.csv` fixture.
    `edgeStyle = "direct"` gave exactly the expected 56 marked edges
    (detection logic correct); `edgeStyle = "rectilinear"` (the app’s
    actual default) gave 103 raw rows. First hypothesis (collapse only
    `__jog_` waypoint chains) gave 67 components, not 56 — genuinely
    wrong, caught by cross-validating with an independent
    `igraph::components()` implementation rather than trusting the
    hand-rolled union-find. Root-caused the gap: `__proj_` D2-dogleg
    nodes (from `.addRectilinearWaypoints()`) also need treating as
    pass-through waypoints on this real, 375-individual fixture (the
    small unit-test fixture that “confirmed” `__proj_` unreachable was a
    different, smaller fixture under a structural invariant that doesn’t
    generalize). With both waypoint types collapsed: exactly 56. Traced
    the MZ-connector chain the same way:
    `E06FRB -> __jog_23_a -> __jog_23_b -> HV7LZ3` — reaches the real
    co-twin node correctly, just via 2 hops. Presented the full
    root-cause finding via `AskUserQuestion` (PRE-RED gate) before
    writing any fix, since “the test’s own assertion is wrong” doesn’t
    fit the classic write-a-failing-test-first mold — user approved the
    chain-walking-fix approach.
5.  **RED**: added 2 shared helpers to
    `tests/testthat/helper-shinytest2.R` (`count_colored_edge_lines()`,
    `get_edge_chain_terminus()`) implementing the validated
    waypoint-collapsing algorithm, and rewrote both failing assertions
    in `test-e2e-pedigree-module.R:350`/`:694` to use them.
6.  **GREEN**: ran `test-e2e-pedigree-module.R` locally against the real
    Shiny app (shinytest2 + chromote, both available locally) — 52/52
    passed, 0 failed/error (was 2 failed pre-fix), confirmed via
    `AskUserQuestion` gate before proceeding.
7.  **REFACTOR**: `lintr::lint()` 0 findings on both touched files (no
    duplication existed to extract — the helpers were written once,
    shared, from the start). Full project-wide clean regression: 6,339
    passed / 0 failed / 0 error / 0 non-baseline offenders across 2,244
    test blocks.
    [`devtools::check()`](https://devtools.r-lib.org/reference/check.html)
    deliberately skipped (owner-confirmed via `AskUserQuestion`):
    test-only diff, no `R/`/`DESCRIPTION`/`NAMESPACE`/`man/` changes,
    and the check’s own test-execution step is exactly what the
    regression read already covered.
8.  **Scope discipline**: grepped every other `test-e2e-*.R` file for
    the same raw-edge-property assertion pattern
    (`edges.get()|edges.filter|m.length|marked.length`) — 0 hits,
    confirming the fragility was isolated to this one file, no broader
    audit owed. Filed [issue
    \#163](https://github.com/rmsharp/nprcgenekeepr/issues/163) for the
    out-of-scope mate-pair-analysis-module flake rather than silently
    dropping it.
9.  **Close-out**: `PROJECT_LEARNINGS.md` Learning 655 recorded;
    `CLAUDE.md` learning-count cross-reference refreshed (654→655);
    `CHANGELOG.md` `[ad hoc]` entry added; this handoff written.

**Runtime smoke test (Phase 3E):** n/a in the traditional sense — no
production runtime behavior changed (zero `R/` diffs). The functional
equivalent here is the E2E run itself: the fixed tests were executed
against the REAL Shiny app (not mocked), confirming the fix actually
holds under the real rendering path, not just in isolation.

**Close-out checklist mapping** (`CLAUDE.md`): citation /
tutorial-article / `NEWS.Rmd` / `a2interactive.Rmd` / `_pkgdown.yml`
checklists all **N/A** — no new exported function, no new user-facing
Shiny feature, test-file-only diff. GitHub issue close-out **N/A** for
the fix itself (ad hoc find-and-fix, no pre-filed issue to close) —
issue \#163 filed fresh for the deferred flake, appropriately left open.
Lint checklist **DONE** (0 lints, confirmed above).

**Self-assessment (Session 622): 9/10.** **Strengths:** (1) Did the CI
forensics (pulling the raw job log via the GitHub API when the CLI’s own
`--log-failed` came back empty) BEFORE claiming scope or committing to a
hypothesis — this is what surfaced that 2 unrelated failures were
bundled in one red run, preventing an over-scoped claim. (2) Checked the
pre-migration CI log before accepting “Walker/BJL regression” as the
working theory, avoiding a wrong-cause investigation entirely. (3)
Caught my own FIRST root-cause hypothesis being wrong (67 vs. 56
components) by cross-validating with an independent implementation
(`igraph`) rather than trusting one hand-rolled union-find, and kept
digging until the discrepancy was fully explained (`__proj_` nodes), not
just patched around. (4) Recognized explicitly that “the fix is a test
correction, not a production fix” doesn’t fit the classic TDD
RED-must-fail mold, and surfaced that tension to the user via
`AskUserQuestion` rather than silently forcing the ceremony or silently
skipping it. **Weaknesses:** (1) Briefly misused `ScheduleWakeup` (a
`/loop`-specific tool) to wait on a background test run instead of just
letting the harness’s own task-notification mechanism handle it — caught
and self-corrected within the same turn, no real cost, but worth naming
so it isn’t repeated. (2) Did not verify locally that
`gh run view --log-failed` failing was itself worth a one-line note
anywhere durable (e.g. a `PROJECT_LEARNINGS.md` tooling-gotcha entry) —
minor, left as an oral note in this handoff instead.

### Session 613 Handoff Evaluation (by Session 614)

**Score: 10/10.** **What helped:** the `HANDOFFS.md` receipt’s
`next_steps` field named 3 exact, binding obligations rather than a
vague “continue Phase 2” pointer — “(1) write the new Test 15 … (2)
restate the `qualifies(U)` gate … the full 5 conjuncts … (3) fold the
widened union-dot/`M_repr` cosmetic drift disclosure into whatever
real-fixture measurement Phase 2 already owed.” All 3 were directly
actionable this session: (1) Test 15 was written in RED exactly as
specified; (2) the implementation’s own `qualifies()` function uses the
full 5-conjunct gate (mateCount(P)==1, mateCount(M)==1,
`!hasOwnDirectChild(P)`, both ids in `realIds`, unambiguous opposite
sex), not the abbreviated 3-conjunct form the design note’s own first
draft used; (3) is explicitly folded into Phase 2b’s own deferred
real-fixture-measurement scope, not silently dropped. `key_files`
pointed exactly at the shipped `sweepMinSep()` (`:997-1015`) and
`orderBySex` (`:1054-1078`) line ranges — both read directly and
cross-checked against my own port. `gotchas` (1) “the S8 formula applies
ONLY to the B1 qualifying case, do not generalize to B3” was directly
useful: my own first implementation draft had exactly this bug
(inferring “is this a B1 call” from `memberId %in% freePassIds` rather
than from which call site invoked it), caught and fixed during GREEN —
the gotcha didn’t prevent the bug, but its framing made the bug fast to
recognize once the test failure pointed at it. **What was missing:**
nothing critical — Phase 2’s own real size (large enough to need this
session’s own further split into 2a/2b) wasn’t flagged by S613’s
handoff, but that was the parent plan’s own “splittable if too large”
note to make, not S613’s job. **What was wrong:** nothing found
inaccurate. **ROI:** very high.

### What Session 614 Did

**Deliverable:** Walker/BJL Phase 2a (issue \#141) — the adapter
mechanics half of the pedigree adapter parallel to production, per
`docs/planning/pedigree-diagram-walker-bjl-apportioning- redesign-plan.md`’s
Phase 2 spec as amended by the Phase 1b design note’s §8 resolution.
**DONE** — new `.positionMatingUnitForestBJL()` implementing the full
3-tier reconciliation, GREEN and REFACTORed, 17/17 new tests passing,
zero collateral damage. Owner-directed scope split (this session’s own
Phase 1 `AskUserQuestion`, before declaring RED): Phase 2b (the
live-render helper + real-375-fixture A/B verification) is explicitly
**not done** — a required, separate follow-up session.
**Started/Completed:** 2026-08-19–2026-08-20.

**What actually happened, in order:**

1.  **Phase 0 orientation** — read `SESSION_RUNNER.md`/`SAFEGUARDS.md`
    in full; `SESSION_NOTES.md` (S613’s own active task);
    `gh issue list` (13 open); `git status`/`log`/`diff --stat` (clean,
    S613 fully closed out, ledger frontiers both `== HEAD`, no reconcile
    owed); `gh run list` (CI green on recent completed runs, 2
    in-progress at report time); `methodology_dashboard.py` (96/100, 1
    HIGH risk — `SESSION_NOTES.md`/`HANDOFFS.md` both past the
    2,000-line cap, unchanged from S613, not fixed this session per
    report-don’t-fix). Ghost-session check on 6 untracked files (4
    rendered `docs/planning/*.html` evidence docs, 1 Office lock-file
    artifact, 1 `scratchpad/` dir of old verification scripts) — all
    traced to already-documented, already- resolved work, none a ghost
    deliverable. Rendered the priorities list (4 numbered
    `AskUserQuestion` options) — **user picked the Walker/BJL Phase 2
    item.**
2.  **Grounded directly in both planning documents before any code** —
    full reads of
    `docs/planning/pedigree-diagram-walker-bjl-apportioning-redesign-plan.md`
    (Migration Path/Phase 2 spec) and
    `docs/planning/pedigree-diagram-walker-bjl-phase1b-mixed-gen-reconciliation.md`
    (§3’s mechanism, §8’s seam-resolution formula and its 2 disclosed
    Phase-2 obligations). **Process gap, disclosed:** this reading ran
    across several large tool calls before the Phase 1B claim stub was
    written — a real deviation from Learning 628’s own “claim at the
    literal next tool call” rule, caught and corrected (claimed
    immediately after, before any further work) but not avoided
    outright. No harm resulted (zero commits/technical changes happened
    during the gap), but the discipline itself was not followed as
    written.
3.  **Phase 1B claimed** — `SESSION_NOTES.md` stub + `HANDOFFS.md`
    `status: pending` receipt, committed (`577ad298`).
4.  **Scope decision, via its own dedicated `AskUserQuestion` before
    declaring RED** (per CLAUDE.md’s own “pre-RED scope decision is a
    separate question” rule): given Phase 1a (a far simpler *generic*
    engine) filled a full session by itself, and Phase 2 adds the full
    B1/B2/B3 classification + 3-tier reconciliation + 15-test matrix + a
    new live-render helper, the user picked **“split: adapter first”** —
    this session scopes to the adapter + full synthetic test matrix; the
    live-render helper and real-375-fixture verification are explicitly
    deferred to a Phase 2b session, disclosed up front in the test
    file’s own header, not silently dropped.
5.  **PRE-RED → RED**, gated via `AskUserQuestion`: wrote
    `tests/testthat/test_positionMatingUnitForestBJL.R` — 17
    `test_that()` blocks (the design note’s own 15-fixture matrix, §4
    Tests 1-14 + §8.4’s required Test 15, plus 3 property tests).
    Derived exact-value oracles for the numerically-tricky fixtures
    (Tests 1, 2, 5, 6, 11, 13, 14,
    15. by actually running Tier 1’s own mechanics (a throwaway probe
        script calling the real, existing
        `.buildMatingUnitForest()`/`.positionTreeApportion()`/`.buildForestChildrenOf()`,
        plus a hand-copied `sweepMinSep()` backstop matching the shipped
        push semantics exactly) against each fixture — never
        hand-derived. Found and fixed 3 of my own fixture-construction
        bugs during this process (wrong assumed anchor in 2 fixtures; a
        vector-misalignment bug in a 3rd) by running each fixture
        against the REAL `.buildMatingUnitForest()` before finalizing
        assertions, not by reasoning alone. Confirmed genuine RED: all
        17 blocks error on “could not find function,” full clean
        regression 0 failed / 17 error (all new) / 0 non-baseline
        offenders. Committed (`0a43ec30`).
6.  **RED → GREEN**, gated: implemented `.positionMatingUnitForestBJL()`
    in `R/makePedigreeDiagramData.R` (new function, zero changes to
    `.positionMatingUnitForest()` or any other existing code). First run
    found 9 failures; diagnosed and fixed each by actually running the
    failing fixture in isolation, not by inspection — **2 were genuine
    implementation defects**: (a) B1 eligibility needs an explicit
    `!hasParentEdge(M)` conjunct the OLD, shipped `freePassIds` helper
    doesn’t carry (its own candidate pool never needed it, since under
    the OLD algorithm a mating unit’s own sire/dam can never also be
    someone’s tracked child — a distinction 2b’s “grandchild reattached
    as a real child” architecture breaks), causing a B2 individual to
    wrongly get a second, Tier-3 derived-point row; (b) a dangling
    non-anchor party (no own row in `ped`) crashed on
    `sireOf[[id]]`/`damOf[[id]]`, fixed by excluding dangling ids from
    B1 eligibility up front, matching the OLD function’s own confirmed
    behavior (verified directly: `.positionMatingUnitForest()` drops a
    dangling free-pass parent from its output entirely). The other 7
    failures were my OWN test bugs (a legitimate epsilon nudge from Tier
    2’s own exact-tie sweep I hadn’t accounted for in 2 assertions; a
    B1/B2 id-classification ambiguity in a 3rd fixture I’d wrongly
    assumed was “B1-free”). Recorded `PROJECT_LEARNINGS.md` Learnings
    639/640 for both defect classes — both are genuinely transferable,
    not one-off. Verified: 17/17 GREEN (53 expectations), full clean
    regression 0 failed/0 error project-wide, 0 non-baseline offenders.
    Committed (`e7f1f593`).
7.  **GREEN → REFACTOR**, gated: `lintr::lint()` (package loaded first,
    Learning 224 methodology) found exactly 2 style lints
    (`character(0)` → `character(0L)`), test file already 0. Fixed,
    re-verified 17/17 GREEN + 0 lints + full clean regression
    unaffected. Committed (`afa7c5f5`).
8.  **Extra verification beyond the gated cycle:** ran
    [`devtools::document()`](https://devtools.r-lib.org/reference/document.html)
    (0 changes, expected — `@noRd`, no exported symbol) and a full
    [`devtools::check()`](https://devtools.r-lib.org/reference/check.html)
    as an additional build-equivalent confirmation beyond the
    testthat/lintr checks the gated cycle itself required. Result: **1
    WARNING, 2 NOTEs, 0 errors — all 3 pre-existing, none attributable
    to this session’s diff:** the non-portable-filename WARNING and the
    “scratchpad” top-level-directory NOTE both trace to the SAME
    untracked files this session’s own Phase 0 ghost-session check
    already found and reported (an Office lock-file artifact,
    `inst/extdata/reference/~$e Compounding Loop.html`; a pre-existing
    `scratchpad/` dir left by an earlier, unrelated session) — confirmed
    pre-existing, not fixed here, per the established “report an
    incidentally-discovered, unrelated gap, don’t fix it mid-session”
    precedent (Learning 382). The 3rd NOTE (`vignettes/figure/` knitr
    leftover) is the same long-documented pre-existing NOTE multiple
    prior sessions’ own close-outs have already recorded.
9.  **Close-out:** `BACKLOG.md`’s Walker/BJL item updated with the S614
    progress paragraph; `PROJECT_LEARNINGS.md` Learnings 639/640
    recorded; this handoff written.

**Runtime smoke test (Phase 3E):** n/a in the traditional sense — the
new function is `@noRd` (internal, non-exported), has zero call sites
anywhere in the package (grep-confirmed: the only reference to
`.positionMatingUnitForestBJL` outside its own definition and its own
test file is this session’s own documentation), and is never reached by
the Shiny app’s reactive chain or any exported function. Matches Phase
1a’s own precedent exactly (`.positionTreeApportion()` also shipped
inert, wired to nothing, in its own session). No runtime behavior
changed; nothing to smoke-test.

**Close-out checklist mapping** (`CLAUDE.md`): citation /
tutorial-article / `NEWS.Rmd` / `a2interactive.Rmd` / `_pkgdown.yml`
checklists all **N/A** — no new exported function, no new user-facing
Shiny feature, `@noRd` throughout. GitHub issue close-out **N/A** —
issue \#141 stays open (this is one slice of a 5+ session parent plan).
Lint checklist **DONE** (0 lints on both touched files, confirmed
above).

**Self-assessment (Session 614): 9/10.** **Strengths:** (1) Derived
exact-value oracles for the numerically-tricky RED fixtures by actually
executing the existing engine against a throwaway probe, rather than
hand-computing or guessing — caught 3 of my own fixture-construction
mistakes before they ever reached the implementation phase, matching
this investigation’s own established “verified by execution” standard.
(2) Made the Phase 2a/2b scope split explicit via its own dedicated
`AskUserQuestion`, rather than either forcing all of Phase 2 into one
session (risking a rushed, under-verified close) or silently narrowing
scope without surfacing the decision. (3) Diagnosed every GREEN-phase
test failure by actually running the specific failing fixture in
isolation and reasoning from real output, not by inspection or
assumption — this is what distinguished the 2 genuine implementation
defects from the 7 test-authoring bugs, and would have been impossible
to sort out correctly from code-reading alone. (4) Recorded both genuine
defect classes as transferable `PROJECT_LEARNINGS.md` entries with
concrete practical rules, not just fixed-and-moved-on. (5) Ran the full
clean-regression read 3 times (post-RED, post-GREEN, post-REFACTOR) plus
a fresh
[`devtools::check()`](https://devtools.r-lib.org/reference/check.html),
not just once at the end. **Weaknesses:** (1) The Phase 1B claim was not
made at the literal next tool call after the user picked this item — 2
large planning-document reads happened first (disclosed above, no
technical harm resulted, but the discipline itself was violated). (2)
Did not build the live-render helper or measure the real 375-individual
fixture this session — **this is a real, material gap, not a
formality**: the parent plan’s own Verification Plan names the
real-fixture zero-coincidence check as “the single most important test
in the whole migration,” and it has NOT been run against this new
adapter. Phase 2a being GREEN on synthetic fixtures is necessary but
explicitly not sufficient evidence the adapter is correct on the actual
pedigree shape this whole redesign exists to fix — a future session must
not skip Phase 2b or treat Phase 2a’s own green tests as if they already
answered that question. (3) 3 of my own 17 RED-phase fixtures needed
correction during GREEN (not wrong in intent, but wrong in a specific
mechanical detail — which party wins an anchor tie-break, or what a
legitimate epsilon nudge does to an exact-equality assertion) — a more
careful first pass, verifying EVERY fixture (not just the
numerically-hardest ones) against the real `.buildMatingUnitForest()`
before finalizing, would have caught these in RED rather than GREEN.
**ROI:** high — Phase 2’s single largest, most novel implementation
slice (the 3-tier adapter itself) is done and verified; Phase 2b is now
a bounded, well-scoped remainder (build one reusable helper, run it on
2-3 fixtures) rather than an undifferentiated continuation of “the whole
rest of Phase 2.”

**Next steps:** Phase 2b (its own session) — build
`tests/testthat/helper-live-render-positions.R` (the chromote-based
`getPositions()` ground-truth harness the parent plan’s own Phase 2 spec
requires), then run the real-fixture zero-coincidence gate and the
F1/Track-C/real-375 live-render checks against
`.positionMatingUnitForestBJL()`. **Must explicitly measure, not
assume:** whether the adapter’s own zero-exact-coincidence property
(verified so far only on synthetic fixtures) survives the real
375-individual pedigree’s own scale and irregularity — if it does not,
Phase 2b returns to Phase 1b with the specific counter-example, per the
parent plan’s own gate. Also owed from S613’s own Obligation 3 (deferred
here, not dropped): fold the widened union-dot/`M_repr`
cosmetic-distance disclosure (`sweepMinSep()` pushing `P` itself, not
only `P`’s children) into whatever real-fixture measurement Phase 2b
runs.

**Key files:** `R/makePedigreeDiagramData.R:1278-1457`
(`.positionMatingUnitForestBJL()`, the new function, immediately after
`.positionMatingUnitForest()` and before
[`makePedigreeMatingLayout()`](https://github.com/rmsharp/nprcgenekeepr/reference/makePedigreeMatingLayout.md));
`tests/testthat/test_positionMatingUnitForestBJL.R` (all 17 tests, own
header documents the Phase 2b deferral explicitly);
`R/positionTreeApportion.R` (unchanged, Phase 1a engine this adapter
calls into for Tier 1);
`docs/planning/pedigree-diagram- walker-bjl-phase1b-mixed-gen-reconciliation.md`
§3/§8 (the mechanism/formula this implements); `PROJECT_LEARNINGS.md`
Learnings 639/640 (the 2 defect classes found this session).

**Gotchas for Phase 2b:** (1) The chromote live-render helper is
genuinely new infrastructure (no prior committed version exists despite
2 prior bespoke, uncommitted uses per the parent plan’s own C2-4
finding) — budget real design time, not just a mechanical port. (2)
`.positionMatingUnitForestBJL()` is entirely untested against ANY
real-world-shaped irregularity (polygamous anchors beyond 5 mates, deep
asymmetric branches, actual dangling-parent data) — the real-375 fixture
will very likely surface at least one case the 17 synthetic fixtures
didn’t anticipate; do not be surprised if Phase 2b needs its own
repair-and-critique round rather than a clean first pass, matching this
investigation’s own 6-prior-attempts history. (3)
`mateCountP`/`mateCountM` in `qualifies()` are computed via
`sum(anchoredUnits$sire==id | anchoredUnits$dam==id)` — this counts
ANCHORED unions only (matching the design note’s own intent), not total
mating-unit membership; if a future change touches this function,
preserve that distinction. (4) `derivedX()`’s `isB1` parameter is passed
explicitly by each call site (never inferred from `memberId %in% b1Ids`)
specifically to avoid Learning 639’s own bug recurring — do not
“simplify” this back to an inferred check.

------------------------------------------------------------------------

### Session 614 Handoff Evaluation (by Session 615)

**Score: 9/10.** **What helped:** the `HANDOFFS.md`/`SESSION_NOTES.md`
`next_steps` field named 5 exact, executable pieces of work (“build
helper-live-render-positions.R”; “run the real-fixture zero-coincidence
gate”; “the F1/Track-C/real-375 live-render checks”; “must explicitly
measure, not assume: whether the zero-exact-coincidence property
survives real scale”; “fold in S613’s Obligation 3”) — all 5 were
directly actionable and became this session’s own 7 new tests almost
one-to-one. `key_files` pointed exactly at the shipped
`.positionMatingUnitForestBJL()` (`:1278-1457`) and the new function’s
own output contract (`id`/`x`/`gen`, no `y`) — both read directly and
confirmed before writing a single test. **Gotcha \#2 (“the real-375
fixture will very likely surface at least one case the 17 synthetic
fixtures didn’t anticipate”) was directly borne out — but not in the
shape predicted:** no code defect surfaced (the adapter’s own internal
invariants all passed clean on first run), but the REAL-SCALE
live-render check surfaced something more fundamental — a
previously-unmeasured characteristic of vis.js’s own rendering
(pixel-rounding collapses the shared 1e-3 cosmetic tie-break nudge) that
neither the 17 synthetic tests nor any prior session had reason to find,
since it requires actual production-scale chromote rendering to observe.
The handoff’s own framing (“do not be surprised if Phase 2b needs its
own repair-and-critique round”) correctly primed for “expect something,”
even though what showed up was a measurement finding, not an
implementation bug. **What was missing:** the handoff didn’t anticipate
that
[`devtools::check()`](https://devtools.r-lib.org/reference/check.html)
itself (not just `testthat`/`lintr`) would be needed to catch a real
regression (the new “unstated dependencies in tests” WARNING) — a
reasonable gap, since Phase 2a touched zero chromote/htmlwidgets code,
so there was no reason for S614 to have hit this. **What was wrong:**
nothing found inaccurate. **ROI:** very high — the 5-item `next_steps`
list mapped almost directly onto this session’s own scope, with zero
re-derivation needed.

### What Session 615 Did

**Deliverable:** Walker/BJL Phase 2b (issue \#141) — the real-fixture
verification half of the Walker/BJL pedigree adapter, per
`docs/planning/pedigree-diagram-walker-bjl-apportioning-redesign- plan.md`’s
Phase 2 spec and
`docs/planning/pedigree-diagram-walker-bjl-phase1b-mixed-gen- reconciliation.md`
§8.4 Obligation 2. **DONE** — new reusable chromote-based live-render
helper, 7 new tests (24 total in the file), all GREEN and REFACTORed.
**Started/Completed:** 2026-08-19 – 2026-08-20.

**What actually happened, in order:**

1.  **Phase 0 orientation** — read `SESSION_RUNNER.md`/`SAFEGUARDS.md`
    in full; `SESSION_NOTES.md` (S614’s own active task);
    `gh issue list` (13 open); `git status`/`log`/`diff --stat` (clean,
    6 local unpushed S614 commits, both `CHANGELOG.md`/`HANDOFFS.md`
    ledger frontiers `== HEAD`, no reconcile owed); `gh run list`
    (S612’s own `R-CMD-check.yaml` failure traced to hosted-runner infra
    flake, not code; 3 S613-push workflows shown `in_progress` 5+ hours
    — flagged as likely stuck/orphaned, not diagnosed, per
    report-don’t-fix); `methodology_dashboard.py` (96/100, 1 HIGH risk,
    unchanged from S614). Ghost-session check on the same 6 untracked
    files S614 already traced — unchanged, no new ghost work. Rendered
    the priorities list (4 numbered `AskUserQuestion` options) — **user
    picked Walker/BJL Phase 2b.**
2.  **Phase 1B claimed** — `SESSION_NOTES.md` stub + `HANDOFFS.md`
    `status: pending` receipt, committed (`87c59054`).
3.  **PRE-RED research** — full reads of both governing planning
    documents’ Phase 2 spec, Phase 1b §8.4 Obligation 1/2, and the
    `data-raw/kinship2FidelityValidation.R`/`test_makePedigreeMatingLayout.R:124`/
    investigation-doc §2.2 precedent for the live-render methodology;
    read `.positionMatingUnitForestBJL()` and
    [`makePedigreeMatingLayout()`](https://github.com/rmsharp/nprcgenekeepr/reference/makePedigreeMatingLayout.md)
    directly (not from memory) to derive the exact `xScale=120`/
    `yScale=150` scaling and the vis.js
    `document.getElementById("graph"+el.id).chart` binding mechanism
    (read directly from the installed `visNetwork.js` source, then
    **verified live via a throwaway probe script** before committing to
    the design — confirmed the mechanism actually works and found
    `elementId` isn’t reliably honored by `visNetwork()`, so the helper
    locates the widget dynamically via
    `document.querySelector('.visNetwork')` instead). Found F1 and
    “Track C” are the SAME already-established 9-subject fixture (not 2
    separate ones the plan’s own wording suggested). **2 dedicated
    `AskUserQuestion` gates before RED:** (a) minimal position-only
    nodes/edges for the live-render check vs. full
    [`makePedigreeMatingLayout()`](https://github.com/rmsharp/nprcgenekeepr/reference/makePedigreeMatingLayout.md)
    cosmetic decoration — owner picked minimal, informed by the probe
    confirming styling doesn’t affect `getPositions()` when physics is
    off; (b) the formal PRE-RED→RED gate itself, listing the exact 7
    planned tests.
4.  **RED** — added `.buildMinimalEdges()` test helper + 7 `test_that()`
    blocks to `test_positionMatingUnitForestBJL.R` (24 total). Confirmed
    genuine RED: the 3 helper-dependent tests errored “could not find
    function `getLiveRenderedPositions`”; the 4 real-fixture measurement
    tests (calling the ALREADY-SHIPPED adapter, genuinely unknown
    outcome) all **passed on first run** — zero-coincidence gate clean,
    exact-midpoint invariant clean, 224/237 structural count confirmed,
    Obligation 2 drift comfortably bounded. Directly computed (outside
    testthat, for the session record) the actual measured numbers:
    180/224 touching / 208/224 half-column (vs. OLD 175/224 / 203/224);
    34 qualifying B1 unions, drift 0.399–0.401.
5.  **GREEN** — implemented `getLiveRenderedPositions()`
    (`tests/testthat/helper-live-render-positions.R`). First
    combined-file run found 2 real bugs, both found and fixed via direct
    execution, not inspection: (a) chromote’s own 10s default
    `Page$loadEventFired()` timeout was too short for the 714-node real
    fixture’s self-contained HTML — added a `loadTimeout` parameter (30s
    default, 60s for the real fixture); (b) **major finding, not a
    bug**: live-rendering revealed vis.js’s `getPositions()` rounds to
    whole pixels (confirmed via a direct 3-node probe:
    `x=150/150.12/150.5` all read back as `150`), so the shared
    1e-3-raw-unit cosmetic tie-break nudge (×`xScale=120` = 0.12px) used
    by BOTH the OLD and NEW algorithms renders pixel-identical to
    whatever it was nudged away from. Measured side by side on the real
    fixture (same script, same helper): OLD 368/714 nodes
    pixel-coincident (182 groups), NEW 380/714 (190 groups) —
    comparable, a pre-existing shared characteristic, not a Phase 2b
    regression. **Stopped and asked** (via `AskUserQuestion`) rather
    than silently redesigning the tests: owner picked “diagnostic, not
    hard gate” — Tests 6/7 rewritten to assert only DataSet-integrity
    (no id silently collapses; confirmed clean on both fixtures) and
    report the measured rate via
    [`message()`](https://rdrr.io/r/base/message.html). Recorded
    `PROJECT_LEARNINGS.md` Learning 641. 24/24 tests GREEN; full clean
    regression 0 failed/0 error; `lintr::lint_package()` 0 findings
    (already clean, no fixes needed).
6.  **[`devtools::check()`](https://devtools.r-lib.org/reference/check.html)
    — found and fixed a real NEW WARNING** (“unstated dependencies in
    tests: chromote, htmlwidgets”) — the SAME `pkg::fn()` pattern
    `data-raw/kinship2FidelityValidation.R` already used safely (that
    script is `.Rbuildignore`d, outside the checked surface) is
    genuinely unsafe once copied into the CHECKED `tests/testthat/`
    surface. **Stopped and asked** rather than unilaterally choosing
    between “add to Suggests” vs. “avoid `::` syntax”; the user
    clarified the general packaging rule directly (`Suggests:` for
    test/example/vignette-needed packages, `Config/Needs/<name>:` for
    dev-tooling-only ones) rather than answering the question as posed —
    applied it: `chromote`/`htmlwidgets` added to `Suggests:` (confirmed
    `renv::snapshot(dev=TRUE)` needed no changes, both already
    transitively pinned). **User then flagged `covr`’s own placement
    mid-turn** (already sitting in `Suggests:` despite being pure
    coverage tooling, already installed independently by
    `.github/workflows/test-coverage.yaml:27`) — relocated to a new
    `Config/Needs/coverage: covr`, matching the file’s own pre-existing
    `Config/Needs/website: quarto` precedent. Flagged (not fixed, user
    directed a `BACKLOG.md` item instead) that `devtools`/
    `roxygen2`/`pkgdown` look like further instances of the same
    misplacement. Recorded `PROJECT_LEARNINGS.md` Learning 642. Re-ran
    [`devtools::check()`](https://devtools.r-lib.org/reference/check.html):
    “unstated dependencies in tests … OK” confirmed; final result 0
    errors/1 WARNING/2 NOTEs, all 3 pre-existing (non-portable filename,
    `scratchpad/` top level, `vignettes/figure/` knitr leftover) —
    identical to S614’s own baseline, zero new.
7.  **REFACTOR** — re-confirmed `lintr::lint_package()` 0 lints
    project-wide and the full test suite (via
    [`devtools::check()`](https://devtools.r-lib.org/reference/check.html)’s
    own `testthat.R` run, 24/24 + whole project) green; no structural
    code changes needed beyond the GREEN-phase bug fixes already made.
8.  **Close-out:** `BACKLOG.md`’s Walker/BJL item updated with the Phase
    2b progress paragraph; new Housekeeping item added for the
    `Suggests`/`Config-Needs` cleanup (user-directed); this handoff
    written.

**Runtime smoke test (Phase 3E):** n/a, matching Phase 1a/2a’s own
precedent exactly — `.positionMatingUnitForestBJL()` itself is unchanged
this session (zero production code touched; only new test
infrastructure + a `DESCRIPTION`/`renv.lock` metadata change). No
runtime behavior changed; nothing to smoke-test.

**Close-out checklist mapping** (`CLAUDE.md`): citation /
tutorial-article / `NEWS.Rmd` / `a2interactive.Rmd` / `_pkgdown.yml`
checklists all **N/A** — no new exported function, no new user-facing
Shiny feature. GitHub issue close-out **N/A** — issue \#141 stays open
(one slice of a 5+ session parent plan). Lint checklist **DONE** (0
lints, confirmed above).

**Self-assessment (Session 615): 9/10.** **Strengths:** (1) Verified the
vis.js `getPositions()` binding mechanism via a live throwaway probe
BEFORE committing to the helper’s design, exactly matching this
project’s own “verified by execution” standard — caught that `elementId`
isn’t reliably honored, avoiding a design built on an untested
assumption. (2) When the live-render check revealed the pixel-rounding
characteristic, stopped and asked rather than either (a) silently
weakening the test to hide an inconvenient result, or (b) unilaterally
attempting a production-code fix outside a measurement session’s own
charter — this is the single most consequential judgment call this
session made. (3) Measured the OLD algorithm side by side with the NEW
one before characterizing the finding, rather than assuming (without
evidence) that Phase 2b’s own new code was the cause — this turned a
scary-looking “380 nodes colliding” result into a
correctly-contextualized “comparable to the pre-existing baseline”
finding. (4) Ran
[`devtools::check()`](https://devtools.r-lib.org/reference/check.html),
not just `testthat`/`lintr`, catching a real regression neither of the
other two tools could have found; fixed it via the owner’s own stated
packaging rule rather than guessing. (5) Directly computed the actual
real-fixture measured numbers (touching/half-column counts, Obligation 2
drift range) via a standalone script for the session record, since
`testthat`’s own reporters suppress
[`message()`](https://rdrr.io/r/base/message.html) output by default.
**Weaknesses:** (1) The initial DESCRIPTION-fix question offered only 2
options (add to Suggests vs. avoid `::`) without considering the
`Config/Needs/` alternative at all — the user had to supply that framing
directly rather than it being one of the offered choices, a real gap in
the question’s own completeness. (2) Did not proactively audit the REST
of `Suggests:` for the same misplacement pattern before the user pointed
at `covr` specifically — once `covr`’s own placement was flagged,
`devtools`/`roxygen2`/`pkgdown` should arguably have been checked with
the same scrutiny in the same pass rather than only afterward, in prose,
unverified. (3) The Obligation-2 measurement test re-derives
`b1Ids`/`qualifies()` predicates directly from `forest`/`ped` rather
than reusing any shared production logic — necessary (these predicates
are internal to `.positionMatingUnitForestBJL()`, not separately
callable) but creates a real, disclosed duplication- drift risk if the
production predicate ever changes without the test being updated to
match. **ROI:** very high — Phase 2 is now fully closed out with real,
measured evidence (not just synthetic-fixture coverage) behind its own
most important gate, and a previously-unknown, potentially load-bearing
characteristic of the rendering pipeline (pixel-rounding vs. cosmetic
nudges) is now documented rather than latent.

**Next steps:** Phase 3 (cutover) — its own separate session, per the
parent plan’s own Phase 3 spec: **Commit 3-1** (4 files — production
call site switch, `.positionMatingUnitForest()`/
`.computeDupNudge()`/patch-stack deletion,
`.positionMatingUnitForestBJL()` renamed to replace it outright,
`test_positionMatingUnitForest.R` becomes the merged final test file
with re-pinned positional literals); **Commit 3-2** (2 files, genuinely
deferrable only if `test_addRectilinearWaypoints.R`/
`test_resolveEdgeNodeCollisions.R` are ALREADY green after Commit 3-1 —
must be confirmed by actually running the suite, not assumed). **A
decision Phase 3 should make explicitly, informed by this session’s own
new evidence:** whether the pixel-rounding/cosmetic-nudge characteristic
(Learning 641) needs its own follow-up design session (widening the
epsilon so it survives pixel rounding) before or after cutover — this
session deliberately left that open, not resolved, per its own
measurement-only charter. Also still owed: Phase 4 (cleanup/docs, close
issue \#141).

**Key files:** `tests/testthat/helper-live-render-positions.R` (new, the
reusable chromote helper — `getLiveRenderedPositions()`, `loadTimeout`
param); `tests/testthat/test_positionMatingUnitForestBJL.R:809-` (Phase
2b’s 7 new tests, `.buildMinimalEdges()` helper near the top);
`DESCRIPTION` (`chromote`/ `htmlwidgets` added to `Suggests:`, `covr`
moved to new `Config/Needs/coverage:`);
`R/makePedigreeDiagramData.R:1278-1457`
(`.positionMatingUnitForestBJL()`, UNCHANGED this session — read only,
for the Obligation-2 predicate re-derivation); `PROJECT_LEARNINGS.md`
Learnings 641/642 (the 2 findings this session).

**Gotchas for Phase 3:** (1) The pixel-rounding characteristic (Learning
641) applies EQUALLY to the OLD algorithm being replaced — do not treat
it as something the cutover itself needs to fix; it’s a pre-existing,
disclosed, comparable-magnitude characteristic of both. (2)
`test_positionMatingUnitForestBJL.R`’s own Tests 6/7 (F1/real-375
live-render) are diagnostic, not hard gates — when merging this file’s
content into `test_positionMatingUnitForest.R` per Commit 3-1’s own
spec, preserve that framing rather than accidentally hardening them into
a gate neither algorithm clears. (3) `.buildMinimalEdges()` and the
live-render tests deliberately do NOT exercise
[`makePedigreeMatingLayout()`](https://github.com/rmsharp/nprcgenekeepr/reference/makePedigreeMatingLayout.md)’s
own full cosmetic decoration (shapes/colors/twin markers) — Phase 3’s
own live-render check (F1/Track-C/real fixture, “directly confirming…
correct child-centering and no new visual overlap”) is the first point
where that full decoration actually needs live-rendering, and should
reuse `getLiveRenderedPositions()` unmodified (per the plan’s own
intent) rather than building a second helper. (4)
`getLiveRenderedPositions()`’s default
`loadTimeout=30`/`waitSeconds=1.5` are fine for small fixtures; the
real-375-scale render needs `loadTimeout=60`/`waitSeconds=3` explicitly
(not committed as new defaults, to keep small-fixture tests fast) — pass
them explicitly for any comparably large fixture in Phase 3.

### Session 615 Handoff Evaluation (by Session 616)

**Score: 7/10** (structural ceiling, not a quality fault). **What
helped:** the receipt’s `key_files`/`what_was_done` fields let me
quickly confirm `getLiveRenderedPositions()` and its 2 call sites were
the only surface in play, and its own disclosed gotcha — “the real-375
fixture will very likely surface at least one case the 17 synthetic
fixtures didn’t anticipate” — primed me correctly for “expect a genuine
new finding here,” which turned out true, just in a different place
(CI-platform timing, not the fixture itself). **What was missing,
structurally rather than by omission:** S615’s `next_steps`/`gotchas`
are entirely about Phase 3 (cutover) — which is NOT what this session
worked on. This isn’t a handoff quality gap: the run that actually
failed (`32335116264`) was triggered by S615’s OWN final close-out
commit push, meaning the failure didn’t exist yet at the moment S615
wrote its handoff — no amount of care in that handoff could have
surfaced it. This session’s actual task was found by MY OWN Phase 0’s
`gh run list` CI-status check (the CLAUDE.md addition ratified S545),
not inherited from S615’s handoff at all. **What was wrong:** nothing
found inaccurate in what S615 claimed about its own work. **ROI:** low
for THIS session specifically, but through no fault of S615’s — a real
structural limit on how far a written handoff can reach (it cannot
predict a CI run triggered by its own closing commit).

### What Session 616 Did

**Deliverable:** Diagnose and fix the `R-CMD-check.yaml`
`windows-latest` CI failure (`gh run` `32335116264`) introduced by
S615’s new `tests/testthat/helper-live-render-positions.R`. **DONE** —
root-caused to a documented chromote
`Page$navigate()`/`Page$loadEventFired()` race (rstudio/chromote#102),
fixed via `$go_to()`, verified GREEN on 2 consecutive real
`R-CMD-check.yaml` pushes (`windows-latest` clean both times).
**Started/Completed:** 2026-08-20.

**What actually happened, in order:**

1.  **Phase 0 orientation** — read `SESSION_RUNNER.md`/`SAFEGUARDS.md`
    in full; `SESSION_NOTES.md` (S614/S615’s own active task, both read
    in full); `gh issue list` (13 open); `git status`/`log`/
    `diff --stat` (clean, ledger frontiers both `== HEAD`, no reconcile
    owed); `methodology_dashboard.py` (96/100, 1 HIGH risk, unchanged);
    **`gh run list --branch master --limit 10`** (per CLAUDE.md’s
    S545-ratified CI-status-check step) found `R-CMD-check.yaml` RED on
    `windows-latest` only, from S615’s own final push — surfaced as a
    4th numbered priorities-list option, distinct from any `BACKLOG.md`
    tag. Ghost-session check on the same 6 untracked files prior
    sessions already traced — unchanged, no new ghost work. Rendered the
    priorities list (4 numbered `AskUserQuestion` options) — **user
    picked the CI fix.**
2.  **Protocol gap, disclosed and corrected (see `PROJECT_LEARNINGS.md`
    Learning 644):** went straight from the picker answer into diagnosis
    (`gh run view --log-failed`, downloading the failed run’s artifact,
    reading `00check.log`/`testthat.Rout.fail`) WITHOUT claiming the
    session first — a 4th recurrence of the Learning 624/625/628
    pattern. Caught once the diagnosis reached a concrete root-cause
    hypothesis; corrected immediately (claimed before writing any fix
    code), committed separately (`db736a3d`).
3.  **Diagnosis, verified by primary sources, not guesswork:**
    downloaded the failed run’s `nprcgenekeepr.Rcheck` artifact directly
    (`gh run download`) rather than trusting the annotation summary
    alone; confirmed both Windows failures were
    `Chromote: timed out waiting for event Page.loadEventFired` at
    `helper-live-render-positions.R:84`. `WebSearch`/`WebFetch` research
    (rstudio/chromote#102, the package’s own “Loading a page reliably”
    vignette) identified the documented race between `Page$navigate()`
    and `Page$loadEventFired()` as separate CDP round- trips, and
    `$go_to()` as chromote’s own shipped fix; confirmed `$go_to()`
    exists with the needed `timeout_`/`delay` parameters in the exact
    pinned/installed chromote version (0.5.1).
4.  **Pre-RED approach decision, via its own `AskUserQuestion`:** this
    is a CI-environment-timing bug no local test can deterministically
    RED/GREEN (the race doesn’t reliably reproduce on a quiet local
    machine); owner picked “no new test — the CI run itself is the test”
    over adding a source-inspection regression test, with the existing 2
    chromote tests (already green locally, already red on Windows CI)
    serving as RED and a real pushed CI run as GREEN.
5.  **RED→GREEN gate** (`AskUserQuestion`, exact diff spelled out) →
    implemented: replaced `helper-live-render-positions.R`’s
    `Page$navigate()`+`Page$loadEventFired()`+[`Sys.sleep()`](https://rdrr.io/r/base/Sys.sleep.html)
    sequence with a single
    `$go_to(url, timeout_ = loadTimeout, delay = waitSeconds)` call.
    Verified locally: full clean regression 0 failed/0 error (incl. all
    24 chromote tests), `lintr::lint()` 0 findings.
6.  **GREEN→REFACTOR gate** (no-op, already 0 lints) → committed
    (`f75e3e42`), pushed, then polled `gh run view`/`gh run list`
    (background, via `Bash run_in_background` + `TaskOutput`) for the
    real R-CMD-check.yaml run until completion: **`windows-latest`
    GREEN** — confirms the fix. A DIFFERENT, unrelated failure appeared
    on `ubuntu-latest (release)` (`chromote:::launch_chrome()`
    process-launch abort, not the loadEventFired race) — diagnosed as
    NOT caused by this session’s diff (`$go_to()` only touches
    post-connection page-load waiting, never process launch) and
    confirmed transient by re-running the SAME job unmodified
    (`gh run rerun --job`), which passed clean. **User flagged this had
    been seen before and asked for deeper diagnosis, not a dismissal** —
    researched it properly (rstudio/chromote issues
    \#106/#124/#134/#150/#170, a well-documented
    port-allocation/resource-contention category) and found this project
    had ALREADY solved an analogous flake for a different workflow
    (`.github/workflows/shinytest2.yaml`’s
    `browser-actions/setup-chrome@v2` + `CHROMOTE_CHROME` +
    assert-resolvable pattern, from
    `docs/planning/phase8-e2e-harness-subplan.md` Risk R5) — a concrete,
    evidenced lead for a future session, filed as a `BACKLOG.md` item
    rather than folded into this session’s own scope (owner-directed via
    `AskUserQuestion`, matching “1 and done”).
7.  **Mid-session, unrelated user question answered without touching
    files:** “why are `BACKLOG.md` items marked Done instead of moved to
    `CHANGELOG.md`” — investigated and answered directly (the file uses
    `- [x]` checked-but-retained items against its own stated “open
    items only” policy; a known, already-diagnosed gap per S518/S529’s
    own Housekeeping item), no file changes made answering it.
8.  **Mid-session, second explicit user task, executed inline:** “make a
    backlog item to simplify NEWS.Rmd entries… include guardrails…
    organize by feature not chronologically.” Investigated S538’s prior
    trim (386-\>134 lines, 2026-08-12) and the CURRENT state (315
    lines/57 entries, 8 days later — regrown in the same
    verbose/technical style with zero guardrail), pulled 3 verified
    current examples of the technical/verbose pattern, wrote a
    fully-scoped `BACKLOG.md` item capturing the owner’s 3 explicit
    requirements (iterative-until-satisfied; by-feature not
    chronological; a designed, landed guardrail against recurrence).
9.  **Close-out:** this handoff; `PROJECT_LEARNINGS.md` Learnings
    643/644; 2 `BACKLOG.md` items filed (NEWS.Rmd simplification; the
    `launch_chrome()` flake) — committed separately (`935cca22`) from
    the code fix, per `SAFEGUARDS.md`’s commit-boundary discipline.

**Runtime smoke test (Phase 3E):** n/a — the only production-surface
file touched is `tests/testthat/helper-live-render-positions.R`, a
test-only helper with zero call sites outside `tests/testthat/`. No
Shiny app / runtime behavior changed.

**Close-out checklist mapping** (`CLAUDE.md`): citation /
tutorial-article / `NEWS.Rmd` / `a2interactive.Rmd` / `_pkgdown.yml`
checklists all **N/A** — no new exported function, no new user-facing
Shiny feature, test-infrastructure-only fix. GitHub issue close-out
**N/A** — this work isn’t tied to a specific open issue (a CI-health fix
incidental to issue \#141’s own Phase 2b, not itself part of that
issue’s scope). Lint checklist **DONE** (0 lints, confirmed above).

**Self-assessment (Session 616): 8/10.** **Strengths:** (1) Diagnosed
from primary evidence at every step — downloaded and read the actual
failed-run artifact rather than trusting the annotation summary;
researched the race condition via chromote’s own documentation/issue
tracker rather than guessing at a fix; confirmed the exact
installed/pinned chromote version had the needed API before proposing
it. (2) Correctly distinguished 2 genuinely different chromote failure
classes (a post-connect event race vs. a pre-connect process-launch
failure) rather than assuming one fix should cover both, or that a green
retry meant “nothing more to see” — this distinction came from actually
reading the stack traces, not from a plausible-sounding unified story.
(3) When the user pushed back on treating the launch_chrome flake as a
dismissible fluke, did real research rather than either over-conceding
scope (silently expanding this session) or under-responding (reasserting
“it’s just flaky”) — landed on a well-evidenced `BACKLOG.md` item citing
this project’s OWN prior, analogous fix. (4) Honored the
CI-environment-only nature of the bug by using an actual
push-and-observe verification loop (background polling) rather than
declaring victory on local-only evidence, which would have been
faithful-verification failure mode \#24 in this exact shape. (5) Kept 2
unrelated mid-session user requests (the BACKLOG.md-Done question, the
NEWS.Rmd item) properly scoped — answered/filed without expanding this
session’s own TDD-gated deliverable. **Weaknesses:** (1) **Repeated
Learning 624/625/628’s Phase 1B-skip pattern a 4th time** — went
straight from the priorities-picker answer into diagnostic work
(downloading CI artifacts) before writing the claim stub, exactly the
failure mode 3 prior learnings already named. Recorded as Learning 644
with a candidate mechanical fix (fold the claim into the picker’s own
`AskUserQuestion`) rather than a 4th “try to remember better”
restatement, since restating clearly isn’t working. (2) Did not verify
the `windows-latest` fix with more than 2 CI runs — a race condition fix
confirmed clean twice is strong but not absolute evidence; a 3rd or Nth
push over time would strengthen confidence further, deliberately not
pursued here to avoid over-scoping a single-fix session into an extended
confidence-building campaign. **ROI:** high — the actual CI-red state
this session inherited (S615’s own final push, `R-CMD-check.yaml` red on
`windows-latest`) is now genuinely green, confirmed by real CI evidence,
not just local passing tests; 2 well-evidenced follow-on `BACKLOG.md`
items were filed rather than either silently expanding scope or losing
the findings.

**Next steps:** No specific technical next step from this session’s own
scope (the CI fix is complete and verified). 3 items now sit in
`BACKLOG.md` a future session could pick up: (1) the `launch_chrome()`
intermittent-flake fix (READY, Effort M — port `shinytest2.yaml`’s
Chrome-setup pattern into `R-CMD-check.yaml`, verify via repeated pushes
since the failure is intermittent); (2) the NEWS.Rmd
simplify-by-feature-with-guardrails item (READY, Effort L,
owner-directed, explicitly iterative/multi-round); (3) Walker/BJL Phase
3 (cutover, issue \#141) — still the largest single READY item,
unchanged by this session, per S615’s own `next_steps` (Commit 3-1 / 3-2
as specified there).

**Key files:** `tests/testthat/helper-live-render-positions.R:75-90`
(the `$go_to()` fix, only file with production-relevant changes);
`BACKLOG.md` (2 new items, “Up Next” section, after the
pedigree-package-factoring item); `PROJECT_LEARNINGS.md` Learnings
643/644.

**Gotchas for future sessions:** (1) `$go_to()` is now this project’s
own established pattern for ANY future chromote-based live-render helper
— do not reintroduce the manual
`Page$navigate()`+`Page$loadEventFired()` sequence elsewhere. (2) The
`launch_chrome()` flake is real and NOT fixed — a future session should
not assume “it passed on retry” means it’s resolved; `BACKLOG.md`’s own
item lays out why (intermittent, needs the same Chrome-provisioning
pattern `shinytest2.yaml` already uses, needs repeated-push verification
not single-run). (3) Learning 644’s own candidate fix (folding the Phase
1B claim into the priorities-picker `AskUserQuestion`) is untried — a
future session proposing it should treat it as a hypothesis to test, not
an already-validated mechanism.

**Post-close-out correction (same session, disclosed rather than left
silent, matching the established S575/S603/S607 precedent):** after this
record was first written, a context interruption meant the Phase 3G
report was never actually shown to the owner — the owner’s next message
(“this is not a formal Phase 3 close-out report”) caught it. Separately,
before that: the owner directly clarified the NEWS.Rmd `BACKLOG.md`
item’s “reorganize by feature” requirement — feature-grouping applies
WITHIN each release heading, never across them (release headings keep
their existing reverse-chronological order). `BACKLOG.md:740-770` edited
to make that scoping explicit; logged in `CHANGELOG.md` as its own dated
entry (`8007c1c8`) rather than silently folded into this record with no
trace, matching this project’s own “disclose a found-after-the-fact
correction” convention. Both corrections are additive — nothing in the
original close-out content above was inaccurate or retracted, unlike
S603’s precedent (a retracted fix) or S607’s (a verification gap); this
is closer to S575’s shape (real findings surfaced after the close-out
commit had already landed).

------------------------------------------------------------------------

### What Session 617 Did

**Deliverable:** Sync this project’s canonical-overlay methodology files
to `v3.7` of `https://github.com/KJ5HST/methodology.git`, per
`BOOTSTRAP.md`’s “Updating an existing project” procedure, then re-apply
this project’s own documented local customization to
`methodology_trim.py` (`CLAUDE.md`’s “methodology_trim.py
local-customization checklist”) and verify. (IN PROGRESS) **Started:**
2026-08-20 **Status:** Session claimed. Work beginning. **Ledger:**
`CHANGELOG: pending` — set at claim; this session’s actions are recorded
in `CHANGELOG.md` at Phase 3F. Until close-out, this line is the crash
breadcrumb for the next session’s reconcile.

### Session 616 Handoff Evaluation (by Session 617)

**Score: 8/10.** **What helped:** the handoff was structurally complete
(all 6 minimum requirements present, `HANDOFFS.md` receipt filled
correctly) and its “Gotchas for future sessions” item 1 (“`$go_to()` is
now this project’s own established pattern for ANY future chromote-based
live-render helper”) is exactly the kind of durable, transferable fact a
handoff should carry forward. **What was missing:** nothing that blocked
this session — S616’s own task (a CI-timing fix) is unrelated to today’s
methodology-sync task, which arrived as a fresh user directive rather
than from S616’s own `next_steps` list, so there was little in that list
this session could directly use. This is expected, not a defect in
S616’s handoff: not every session’s task descends from the
immediately-prior one. **What was wrong:** nothing found inaccurate.
**ROI:** moderate — mainly useful for confirming the repo was in a
genuinely clean, fully-closed-out state before this session’s own claim
(verified independently via `git status`/ledger-frontier checks in Phase
0, which matched what S616 reported).

### What Session 617 Did

**Deliverable:** Sync this project’s canonical-overlay methodology files
to `v3.7` of `https://github.com/KJ5HST/methodology.git`. **DONE**, via
hand-reconciliation rather than a blind overlay — the user picked this
explicitly (`AskUserQuestion`, “Hand-reconcile onto v3.7”) after a
significant discovery changed the shape of the task.
**Started/Completed:** 2026-08-20.

**What actually happened, in order:**

1.  **Phase 0 orientation** (continuing from the prior turn) — read
    `SESSION_RUNNER.md`/`SAFEGUARDS.md` in full; `SESSION_NOTES.md`
    (S613-616’s own active task, the Walker/BJL Phase 2a/2b + CI-fix
    thread); `gh issue list` (13 open); `git status`/`log`/`diff --stat`
    (clean, ledger frontiers both `== HEAD`); `gh run list` (several
    in-progress/pending from the last 2 pushes, nothing red);
    `methodology_dashboard.py` (96/100, 1 HIGH risk — `HANDOFFS.md` past
    its 2,000-line cap, unchanged); ghost-session check on 6 untracked
    files (all pre-existing, already traced by S614-616). Rendered the
    priorities list + `AskUserQuestion` — user did not pick from it;
    instead gave a fresh directive: “sync with v3.7 of
    <https://github.com/KJ5HST/methodology.git>”.
2.  **Investigated the sibling `/Users/rmsharp/Development/methodology`
    checkout** (a fork, `origin=rmsharp/methodology`,
    `upstream=KJ5HST/methodology`, both remotes present) — confirmed it
    has the real `v3.7` tag (`git describe --tags` → `v3.7`, commit
    `dcb6fc6`, “Merge pull request \#74 from KJ5HST/release/v3.7”). Ran
    `bin/status`/`bin/sync --dry-run` against it with the sibling
    checked out AT that tag (never touched the sibling’s working tree
    destructively — restored to `main` immediately after extracting what
    was needed; later comparisons used `git show v3.7:<path>` directly,
    touching nothing in the sibling repo at all).
3.  **Major discovery, before any file was touched:** `bin/status`
    flagged `SESSION_RUNNER.md`, `BOOTSTRAP.md`, `CLAUDE_TEMPLATE.md`,
    `methodology_dashboard.py`, and 3 `docs/methodology/` files as
    “locally modified” (not “N versions behind”) against true `v3.7`.
    Full diffs revealed why: this project’s `FRAMEWORK_LEARNINGS.md` and
    `methodology_trim.py` — both actively, heavily used (the latter for
    CHANGELOG/HANDOFFS/SESSION_NOTES archiving; the former never
    actually true canonical) — **have never existed in any tagged
    `KJ5HST/methodology` release, v1.0.0 through v3.7** (checked all 27
    tags directly). They reached this project via the 2026-08-10 sync
    (`18d8e3c7`), whose own commit message honestly names its actual
    source as `KJ5HST/methodology v3.6-255-gc43e7ee` — the
    `rmsharp/methodology` fork’s unreleased `main` branch, 255 commits
    past the v3.6 *tag*, not an official release. Also found:
    `methodology_dashboard.py` locally is 2.14.0, genuinely NEWER than
    true v3.7’s 2.10.6 — a literal sync would have been a downgrade.
    Conversely, true v3.7’s `SESSION_RUNNER.md` has a real addition this
    project was missing: **Failure Mode \#28 “Unbounded mandatory
    read”** + 4 Degradation Detection rows. Recorded as
    `PROJECT_LEARNINGS.md` Learning 645.
4.  **Surfaced this to the user via `AskUserQuestion`** before touching
    any file — 3 options (hand-reconcile / literal overlay / sync from
    the fork’s main instead). **User picked hand-reconcile.**
5.  **Executed the reconciliation**, file by file, verifying each
    against the actual `v3.7` tag content (`git show v3.7:<path>`, never
    the sibling’s live working tree after the first checkout):
    - `SESSION_RUNNER.md`: added FM \#28 + its 4 Degradation Detection
      rows (genuine new v3.7 content); kept the local
      `FRAMEWORK_LEARNINGS.md`-extraction pattern for the 2
      Learning-routing bullets and the “Learnings (added by sessions)”
      section (local’s `FRAMEWORK_LEARNINGS.md` already holds 21 rows
      vs. v3.7’s inline 13 — reverting would have been a real
      regression, confirmed by reading the file directly, not assumed).
    - `RECOMMENDED_SKILLS.md`: applied v3.7’s improved `/caveman` skill
      description verbatim (a genuine content upgrade, unrelated to the
      `FRAMEWORK_LEARNINGS.md` question) — now matches v3.7 exactly.
    - `CLAUDE_TEMPLATE.md`, `ITERATIVE_METHODOLOGY.md`, `HOW_TO_USE.md`,
      `docs/methodology/workstreams/AUDIT_WORKSTREAM.md`: confirmed
      each’s only diff is the `FRAMEWORK_LEARNINGS.md` citation-target
      (both sides self-consistent with their own pattern) — no change
      needed.
    - `BOOTSTRAP.md`: confirmed local is a strict superset of v3.7
      (includes the FRAMEWORK_LEARNINGS.md/ `methodology_trim.py`
      mentions AND an entire “3 rules for a `bin/sync`-less update”
      section v3.7 doesn’t have at all) — no change needed.
    - `methodology_dashboard.py`: kept at local 2.14.0 per the user’s
      explicit choice (no downgrade).
    - `SAFEGUARDS.md`, `CONTEXT_TEMPLATE.md`, and 8
      `docs/methodology/workstreams/*` files: already confirmed
      byte-identical to v3.7 — no action.
    - `FRAMEWORK_LEARNINGS.md`, `methodology_trim.py`: left untouched by
      design (not part of v3.7’s manifest at all; `bin/sync` would
      neither update nor delete them).
6.  **Corrected `CLAUDE.md`’s now-confirmed-inaccurate claim** that
    `methodology_trim.py` is “a canonical-overlay file per
    `BOOTSTRAP.md`’s sync table” — rewrote the local-customization
    checklist entry to state the actual provenance and narrow the
    residual risk to its real trigger (a future sync against the fork’s
    *unreleased* `main`, not a tagged release, which is what S617 ran).
7.  **Verified cross-references** (this project’s own Learning \#7
    discipline, now literally cited inside the SESSION_RUNNER.md text
    just edited): grepped for stale “27 failure modes” claims after
    adding FM \#28 — found and fixed one in `CLAUDE.md`’s
    Project-Specific Failure Modes section; found one more
    (`docs/methodology/README.md`) that is dated historical changelog
    prose describing a past release, correctly left untouched. Also
    refreshed `CLAUDE.md`’s stale `PROJECT_LEARNINGS.md` pointer count
    (635→645 learnings, _(3.5MB→)2.6MB actual) while already editing the
    surrounding text.
8.  **Filed a `BACKLOG.md` Housekeeping item** for `context_budget.py`
    (a genuinely new v3.7 tool, `bin/status` reports `missing`/`absent`)
    — deliberately NOT adopted this session (a new capability is a
    bigger decision than syncing an existing file), flagged for a future
    scoping session.
9.  **Verified nothing broke:** `methodology_trim.py --check` still runs
    cleanly on all 3 ledgers (CHANGELOG.md/HANDOFFS.md/SESSION_NOTES.md
    — pre-existing trigger-fires unrelated to this session, matching the
    dashboard’s already-known HIGH risk flag);
    `methodology_dashboard.py` still runs, health unchanged at 96/100.
10. **Close-out:** this handoff; `PROJECT_LEARNINGS.md` Learning 645
    recorded (step 3 above).

**Runtime smoke test (Phase 3E):** n/a — docs/tooling-only sync, zero
`.R` files touched, no Shiny app or package runtime behavior affected.
Confirmed via `git status --porcelain` (only `.md` files +
`RECOMMENDED_SKILLS.md`/`CLAUDE.md`/`PROJECT_LEARNINGS.md`/`BACKLOG.md`
changed).

**Close-out checklist mapping** (`CLAUDE.md`): citation /
tutorial-article / `NEWS.Rmd` / `a2interactive.Rmd` / `_pkgdown.yml`
checklists all **N/A** — no R code, no exported function, no Shiny
feature. GitHub issue close-out **N/A** — not tied to a GitHub issue.
Lint checklist **N/A** — no `.R` files touched.

**Self-assessment (Session 617): 9/10.** **Strengths:** (1) Did not
blindly trust “sync to v3.7” as a mechanical file-overlay — checked out
the actual tag and diffed against it before touching anything, which is
what surfaced the fork-vs-upstream provenance gap in the first place.
(2) When the discovery changed the shape of the task, stopped and asked
via `AskUserQuestion` rather than either silently downgrading working
tools (`methodology_dashboard.py`, the `FRAMEWORK_LEARNINGS.md` pattern)
or silently deviating from the literal instruction by syncing from the
fork instead. (3) Verified every “locally modified” file’s diff
line-by-line against actual `v3.7` tag content (via `git show`, never
trusting the sibling repo’s mutable working tree after the first
checkout) rather than accepting `bin/status`’s summary label at face
value — this is what caught that `RECOMMENDED_SKILLS.md`’s “1 version
behind” WAS a safe, genuine upgrade while the 7 “locally modified” files
were not. (4) Applied this project’s own Learning \#7 (cross-reference
completeness) to the very edit that introduced it — grepped for stale
failure-mode-count claims after adding FM \#28 and fixed the one live
instance found. (5) Recorded the provenance-gap discovery as a
`PROJECT_LEARNINGS.md` learning with a concrete, transferable practical
rule, not just fixed-and-moved-on. **Weaknesses:** (1) Did not re-verify
the sibling repo’s clean/restored state with a final `git status` after
the last `git show`-based extraction pass (though no further checkouts
happened after the one restore, so risk was low — worth a habit going
forward: confirm the sibling repo is exactly as found before ending any
session that touches it). (2) The Phase 1B claim (S617’s own stub)
happened after the Phase 0 orientation-continuation and BEFORE any
technical investigation began, which is correct per Learning
624/625/628/644’s own repeated finding — but this session’s
investigation (checking out tags, running `bin/status`) happened AFTER
the claim, so this session did NOT repeat that specific failure mode;
noting explicitly since it’s now a recorded pattern worth confirming
session over session. **ROI:** high — this session avoided 2 real
regressions (a `methodology_dashboard.py` downgrade, a
`FRAMEWORK_LEARNINGS.md`-pattern content loss with no replacement) that
a literal, un-investigated “just run `bin/sync`” would have caused,
adopted one genuine new capability (FM \#28) the project was missing,
and corrected a standing factual error in `CLAUDE.md` about this
project’s own tooling provenance.

**Next steps:** No further methodology-sync work is owed from this
session’s own scope — the reconciliation is complete and verified. One
item is now in `BACKLOG.md` Housekeeping a future session could pick up:
evaluate adopting `context_budget.py` (v3.7’s new context/token-budget
tracker, READY, Effort S — a scoping session). Separately, this
session’s investigation makes 2 broader, optional future considerations
visible (not filed as BACKLOG items, since neither is a concrete, scoped
task yet): (a) whether `FRAMEWORK_LEARNINGS.md`/`methodology_trim.py`
should be formally re-framed as fully project-owned tools (drop the
“sync” framing entirely, since no tagged release will ever update them)
or whether this project wants to periodically pull fresh copies from the
fork’s `main` on purpose; (b) whether future methodology syncs should
default to checking out a specific tag in the sibling checkout (as this
session did) rather than trusting whatever branch happens to be checked
out there, given `bin/sync --source=local`’s documented behavior of
reading the working tree as-is.

**Key files:** `SESSION_RUNNER.md:220-222,278,329-330,356-360,365-382`
(the FM \#28 addition + the preserved `FRAMEWORK_LEARNINGS.md` pattern);
`CLAUDE.md:272` (the corrected `methodology_trim.py` provenance note),
`CLAUDE.md:282,286` (refreshed cross-reference counts);
`RECOMMENDED_SKILLS.md:94` (the `/caveman` description upgrade);
`BACKLOG.md` Housekeeping (the new `context_budget.py` item, inserted
first); `PROJECT_LEARNINGS.md` Learning 645 (the full provenance-gap
finding and practical rule).

**Gotchas for future sessions:** (1) A future “sync methodology” session
should check out the specific target tag in the sibling
`/Users/rmsharp/Development/methodology` checkout (verify clean first,
restore the branch after) rather than trusting whatever is currently
checked out there — `bin/sync --source=local` has no concept of “the
latest release,” it reads the working tree as-is. (2)
`FRAMEWORK_LEARNINGS.md` and `methodology_trim.py` will NOT be touched
by any future tagged-release sync (they’re absent from
`bin/_manifest.py`’s `DISTRIBUTION` for every tag checked) — do not
expect `bin/status`/`bin/sync` to ever report them as anything but
`missing`/absent-from-manifest when compared against a tag; this is
expected, not a bug. (3) `methodology_dashboard.py` was deliberately
left at 2.14.0 (ahead of true v3.7’s 2.10.6) — if a future session syncs
again and sees this flagged “locally modified,” that’s the same
intentional preservation, not new drift, unless the fork’s version has
since fallen behind what’s needed.

------------------------------------------------------------------------

### Session 617 Handoff Evaluation (by Session 618)

**Score: 8/10.** **What helped:** the receipt was structurally complete
(all 6 minimum requirements present, `HANDOFFS.md` block filled
correctly, `status: complete`) and every claim it made — clean repo,
both ledger frontiers `== HEAD`, dashboard 96/100 — was independently
re-verified as accurate in this session’s own Phase 0
(`git log -1 -- CHANGELOG.md`/`HANDOFFS.md`, a fresh
`methodology_dashboard.py` run). The `gotchas` list
(FRAMEWORK_LEARNINGS.md/ methodology_trim.py permanently absent from
tagged-sync manifests; methodology_dashboard.py deliberately ahead of
v3.7) is durable, correct information a future methodology-sync session
will need. **What was missing:** nothing that blocked this session —
S617’s own task (a methodology framework sync) is unrelated to this
session’s task (a CI-config fix), which arrived from the priorities-list
picker rather than from S617’s own `next_steps`, so there was little in
that list this session could directly use. This mirrors S617’s own
evaluation of S616 exactly (“not every session’s task descends from the
immediately-prior one”) — expected, not a defect. **What was wrong:**
nothing found inaccurate. **ROI:** moderate — mainly useful for
confirming the repo was genuinely clean and fully closed out before this
session’s own claim, matching S617’s own precedent for scoring a handoff
whose task didn’t chain into the next session’s.

### What Session 618 Did

**Deliverable:** Fix `R-CMD-check.yaml`’s intermittent chromote
Chrome-launch failure (BACKLOG.md Housekeeping item, found S616) — port
`shinytest2.yaml`’s `browser-actions/setup-chrome@v2` +
`CHROMOTE_CHROME` + preflight-resolvability pattern into
`R-CMD-check.yaml`, then verify via repeated real CI pushes. **PARTIALLY
DONE, disclosed:** `windows-latest` genuinely fixed and verified GREEN
on a real push; `macos-latest` reclassified as a distinct, still-open
problem, deferred to a future session per owner direction.
**Started/Completed:** 2026-08-20.

**What actually happened, in order:**

1.  **Phase 0 orientation** — read `SAFEGUARDS.md` in full;
    `SESSION_NOTES.md` (S613–617’s full thread, ~590 lines);
    `gh issue list` (13 open);
    `git status`/`log --oneline -5`/`diff --stat` (clean, 4 unpushed
    S617 commits); `methodology_dashboard.py` (96/100, 1 project HIGH —
    but the underlying risk-flag detail, read directly from
    `dashboard.html`, showed 3 files now past the 2,000-line cap:
    `HANDOFFS.md` 2,529, and **`BACKLOG.md` 2,097 / `CHANGELOG.md`
    2,039, both newly crossed** since S617 — a timely instance of the FM
    \#28 “unbounded mandatory read” S617 itself had just adopted into
    `SESSION_RUNNER.md`, flagged in the report, not fixed).
    `gh run list --branch master` (S545-ratified CI-status-check step)
    found `R-CMD-check.yaml` RED on `windows-latest` — “Chrome debugging
    port not open after 10 seconds” — matching the already- filed
    BACKLOG item almost exactly, plus new evidence it now also hits
    `windows-latest`, not just `ubuntu-latest`. Ledger reconcile: 1
    commit past the `CHANGELOG.md` frontier (`d0d248b8`), matched the
    established S600/S602–S616 self-reference-workaround precedent (a
    receipt-only edit, nothing new to log) — no backfill needed;
    `HANDOFFS.md` frontier `== HEAD`. Ghost-session check on the same 6
    untracked files prior sessions already traced — unchanged. Rendered
    the 4-item priorities list + `AskUserQuestion` — **user picked the
    chromote CI-flake fix.**
2.  **Phase 1B claimed immediately** — `SESSION_NOTES.md` stub +
    `HANDOFFS.md` `status: pending` receipt, committed (`1d1d9203`),
    before any technical investigation — avoided a 5th recurrence of the
    Learning 624/625/628/644 pattern.
3.  **PRE-RED research** — read
    `docs/methodology/workstreams/DEVELOPMENT_WORKSTREAM.md`,
    `shinytest2.yaml`’s full Chrome-provisioning block,
    `R-CMD-check.yaml`’s current state. `WebFetch`/`WebSearch` confirmed
    `browser-actions/setup-chrome@v2` supports macOS/Windows/ Linux and
    that `install-dependencies` is documented Linux-only (a no-op
    elsewhere, matching `no-sudo`’s own explicit annotation) — verified
    against the action’s own `action.yml`, not assumed. **PRE-RED→RED
    gate** (`AskUserQuestion`): chose a static structural test (parsing
    the raw workflow YAML, `test_shinytest2_workflow_coverage.R`’s own
    house style) over “CI-run- only, no new test” (S616’s precedent for
    a pure runtime race) — this is a parseable config change, not a
    runtime race, so a deterministic local RED/GREEN cycle is possible
    and was judged more rigorous.
4.  **RED** — wrote
    `tests/testthat/test_r_cmd_check_workflow_chrome_setup.R` (3
    `test_that` blocks, 8 expectations): asserts
    `browser-actions/setup-chrome@v2` + `id: setup-chrome` +
    `install-dependencies: true`; `CHROMOTE_CHROME` exported from
    `chrome-path` via `$GITHUB_ENV`;
    [`chromote::find_chrome()`](https://rstudio.github.io/chromote/reference/find_chrome.html)
    asserted, in the correct order ahead of `check-r-package@v2`.
    Confirmed genuine RED: 8/8 fail (steps don’t exist yet), full clean
    regression 8 failed/0 error project-wide, all 8 in the new file.
    Committed (`888fcbf4`).
5.  **RED→GREEN gate** (`AskUserQuestion`, exact diff spelled out) →
    implemented: ported the 3-step pattern into `R-CMD-check.yaml`
    between `setup-r-dependencies@v2` and `check-r-package@v2`. 8/8
    GREEN, full regression 0 failed/0 error, `lintr::lint_package()` 0
    lints. Committed (`58905242`).
6.  **GREEN→REFACTOR gate** (`AskUserQuestion`) → confirmatory no-op (0
    lints, minimal diff); ran
    [`devtools::check()`](https://devtools.r-lib.org/reference/check.html)
    as extra verification — 0 errors/1 WARNING/2 NOTEs, all 3 confirmed
    pre-existing (matching S614–S617’s own exact baseline). Pushed to
    trigger real CI.
7.  **1st real CI run (`32403201121`) found the GREEN implementation had
    a genuine bug, NOT intermittency:** `windows-latest` still failed
    with the EXACT SAME “port not open” symptom. Direct log inspection
    (`gh run view --log`, not just `--log-failed`) found
    `CHROMOTE_CHROME =` printed EMPTY — the `echo ... >> "$GITHUB_ENV"`
    step is bash syntax, and unlike `shinytest2.yaml` (ubuntu-only, bash
    is the OS default), this job’s matrix includes `windows-latest`,
    whose `run:` default shell is PowerShell.
    [`chromote::find_chrome()`](https://rstudio.github.io/chromote/reference/find_chrome.html)
    had silently fallen back to the ambient system Chrome. **Same run
    also showed a NEW, previously-green leg failing: `macos-latest`**,
    with `CHROMOTE_CHROME` confirmed correctly set (ruling out the same
    shell bug) but
    `Chromote: timed out waiting for response to command Runtime.evaluate`
    plus an internal `attempt to apply non-function` — a live CDP
    timeout, not a launch failure, a genuinely different symptom class.
    **Stopped and reported both findings to the owner via
    `AskUserQuestion` rather than silently pushing another speculative
    fix** — owner clarified: fix the diagnosed Windows bug and re-push;
    treat macOS as intermittent for now, escalate to its own future
    session if it recurs.
8.  **Fixed the diagnosed bug within GREEN** (matching this project’s
    own “found/fixed via execution during GREEN” precedent, S614/S615):
    extended the RED test with a `step_block_ containing()` helper
    asserting the CHROMOTE_CHROME-exporting step declares `shell: bash`
    — confirmed genuine RED (1/9 new expectation fails) — then added
    `shell: bash` to the step — 9/9 GREEN, full regression 0 failed/0
    error, 0 lints. Committed (`a3d34f1a`), pushed.
9.  **2nd real CI run (`32406103954`): `windows-latest` GREEN**,
    `CHROMOTE_CHROME` confirmed correctly populated. **`macos-latest`
    failed AGAIN with the identical CDP-timeout signature** — 2/2
    recurrence with `CHROMOTE_CHROME` confirmed correctly set both
    times, ruling out both the shell bug and pure one-off resource
    contention as the sole explanation; the same run also showed
    `ubuntu-latest (oldrel-1)` red, characterized via its own log as an
    entirely unrelated r-hub.io R-version-resolution API failure (before
    any Chrome-provisioning step runs, this leg was green on the 1st
    push with the same code) — confirmed transient by re-running the
    single job (`gh run rerun --job 96545448701`), passed clean.
10. **Close-out:** `BACKLOG.md`’s chromote-flake item updated in place
    with the full S618 narrative (windows-latest FIXED/verified;
    macos-latest reclassified as a distinct, still-open problem,
    deferred; ubuntu-oldrel-1 noted as unrelated transient noise) rather
    than checked off, since the item’s own original scope (both
    platforms) is only half-resolved. `PROJECT_LEARNINGS.md` Learnings
    646/647 recorded; `CLAUDE.md`’s learning-count cross- reference
    refreshed (645→647). This handoff written.

**Runtime smoke test (Phase 3E):** the deliverable changes CI runtime
behavior directly — verified via 2 real, pushed `R-CMD-check.yaml` runs
(not local-only), exactly the faithful verification this kind of change
needs (matching S616’s own “push-and-observe” precedent).
`windows-latest` confirmed GREEN on live infrastructure with
`CHROMOTE_CHROME` populated correctly; `macos-latest` confirmed still
RED on live infrastructure, disclosed, not silently treated as passing.

**Close-out checklist mapping** (`CLAUDE.md`): citation /
tutorial-article / `NEWS.Rmd` / `a2interactive.Rmd` / `_pkgdown.yml`
checklists all **N/A** — no new exported R function, no new user-facing
Shiny feature, CI-workflow-config-only. GitHub issue close-out **N/A** —
this work isn’t tied to a specific open issue. Lint checklist **DONE**
(0 lints on both touched `.R` files, confirmed 3 times across
RED/GREEN/the shell-bash fix).

**Self-assessment (Session 618): 8/10.** **Strengths:** (1) Followed the
full TDD PRE-RED→RED→ GREEN→REFACTOR cycle with an `AskUserQuestion`
gate at every transition, including the atypical “is a local RED/GREEN
cycle even possible for a CI-config change” pre-RED decision — reasoned
explicitly rather than defaulting to S616’s runtime-race precedent
without checking whether it actually applied here. (2) Verified via REAL
CI pushes, not just local tests, exactly per the BACKLOG item’s own
“repeated real pushes, not a single run” requirement — this is what
caught a genuine implementation bug (Windows shell portability) no local
machine (bash-default) could ever have surfaced. (3) When the 1st real
push contradicted the fix hypothesis (macOS regression, Windows
unchanged), stopped and reported both findings via `AskUserQuestion`
rather than either silently declaring partial victory or unilaterally
chasing more speculative fixes — matching this project’s own established
“stop and ask” precedent (S616). (4) Correctly distinguished 3 different
failure signatures across 2 CI runs (Windows shell bug; macOS CDP
timeout; unrelated ubuntu r-hub.io infra flake) by reading actual step
logs and env values, not by assuming a shared cause — avoided both
over-fixing and mis-attributing. (5) Found and fixed a bug in my OWN
test (a comment line falsely matching
[`chromote::find_chrome()`](https://rstudio.github.io/chromote/reference/find_chrome.html))
via direct execution, then extended the RED coverage to lock in the
shell:bash requirement rather than patching the YAML and moving on. (6)
Claimed the session at the literal next step after the picker resolved,
avoiding a 5th recurrence of Learning 624/625/628/644’s documented
pattern. **Weaknesses:** (1) Did not research GitHub Actions’ own per-OS
default-shell behavior before writing the first GREEN diff — a
`shinytest2.yaml`- verbatim port assumed bash without checking whether
the destination matrix’s OS composition (mixed, unlike the ubuntu-only
source) made that assumption unsafe; a live CI failure was needed to
surface it, when a documentation check likely would have caught it
first. (2) The macOS CDP-timeout regression remains genuinely unresolved
at close-out — disclosed in full, with 2 data points and exact
signatures, not silently dropped, but the underlying “is the pin itself
implicated” question is still open. (3) 2 full CI-verification
round-trips (≈35 CI-minutes each across 5 matrix legs) were needed
rather than 1, extending the session’s real-world duration — inherent to
“verify via real CI,” not obviously avoidable, but worth naming.
**ROI:** high — a genuinely broken CI leg (`windows-latest`, red across
the 2 pushes immediately preceding this session) is now green and
independently re-verified twice; a previously vague “intermittent
Chrome-launch failure” is now split into 3 precisely characterized,
evidence-backed problems (1 fixed, 1 newly-scoped for a future session,
1 confirmed unrelated noise) — a materially better-scoped starting point
than this session’s own.

**Next steps:** A future session should investigate the `macos-latest`
CDP-timeout regression as its own dedicated task (`BACKLOG.md`’s
chromote item narrates the full finding) — research the
`Chromote: timed out waiting for response to command Runtime.evaluate` /
`attempt to apply non-function` signature against chromote’s own issue
tracker, determine whether the pinned 152.0.7977.54 Chrome-for-Testing
build has known headless-CDP problems on macOS ARM64, and decide whether
pinning is even the right fix for that leg (vs. leaving macOS on ambient
Chrome, which was green before this session’s diff) before attempting
another fix. **Must explicitly measure, not assume:** whether a 3rd real
CI push reproduces the same signature a 3rd time (strengthening the
“real, recurring” conclusion) or clears (weakening it back toward
“coincidental double flake”) — this session stopped at 2 data points per
owner direction, not because 2 was judged sufficient.

**Key files:** `.github/workflows/R-CMD-check.yaml:48-75` (the 3-step
Chrome-provisioning block + the `shell: bash` fix);
`tests/testthat/test_r_cmd_check_workflow_chrome_setup.R` (3 `test_that`
blocks, 9 expectations, incl. the
`step_block_containing()`/`drop_comment_lines()` helpers); `BACKLOG.md`
Housekeeping (the chromote-flake item, updated in place with the full
S618 narrative — NOT checked off, since macOS remains open);
`PROJECT_LEARNINGS.md` Learnings 646/647.

**Gotchas for a future session:** (1) `shell: bash` is now this
project’s own established requirement for ANY `run:` step using bash
syntax inside a workflow whose matrix includes `windows-latest` — do not
assume a step ported from an ubuntu-only workflow carries its shell
default along. (2) The macOS CDP timeout reproduced with
`CHROMOTE_CHROME` CONFIRMED correctly set both times — do not
re-diagnose it as “the pin isn’t working,” that specific hypothesis is
already ruled out; the open question is why a live CDP round-trip times
out on an already-connected, correctly-pinned session. (3)
`ubuntu-latest (oldrel-1)`’s r-hub.io version-resolution failure is
unrelated CI infra noise, already confirmed transient by a clean rerun —
do not fold it into the chromote-flake investigation if it recurs; it is
a different category entirely (R-version resolution, not Chrome).

### Session 618 Handoff Evaluation (by Session 619)

**Score: 9/10.** **What helped:** `next_steps` named 3 exact, actionable
directives — “research the signature against chromote’s own issue
tracker,” “check whether the pinned 152.0.7977.54 Chrome-for-Testing
build has known headless-CDP problems on macOS ARM64,” and “decide
whether pinning is even the right fix for that leg (vs. leaving macOS on
ambient Chrome, which was green before this session’s diff) before
attempting another fix” — all 3 were followed almost verbatim: a 6-agent
research workflow did exactly that research, and the eventual fix WAS
“leave macOS on ambient Chrome,” precisely the alternative S618 had
already named as a live option rather than something this session had to
discover from scratch. `key_files`
(`.github/workflows/R-CMD-check.yaml:48-75`,
`test_r_cmd_check_workflow_chrome_setup.R`) pointed exactly at the files
this session edited. `gotchas` \#2 (“`CHROMOTE_CHROME` CONFIRMED
correctly set both times — do not re-diagnose it as ‘the pin isn’t
working’”) held up exactly: this session’s own H1 fix attempt
independently re-confirmed the env var was correctly set even while
genuinely failing, matching the gotcha precisely rather than
re-litigating it. **What was missing:** nothing critical — S618 could
not have known the eventual root-cause mechanism (chromote’s internal
`get_pixel_ratio()` bootstrap probe) without the same source-level
research this session did; that gap is appropriately S618’s own
deferral, not an omission. **What was wrong:** nothing found inaccurate
— every claim (distinct from the Windows shell bug, recurring 2/2,
`CHROMOTE_CHROME` correctly set) was independently re-verified and held.
**ROI:** very high — the `next_steps` text functioned almost as a mini
research brief, directly shaping this session’s own investigation
structure.

### What Session 619 Did

**Deliverable:** Diagnose AND fix the `macos-latest` CDP-timeout CI
failure in `R-CMD-check.yaml` (`BACKLOG.md` Housekeeping item, found
S618). **DONE** — root cause identified via direct chromote source
inspection; a first fix attempt (raise `default_timeout`) was tried,
verified via real CI, and found NOT to work (a genuine falsification,
not a formality); a fallback fix (revert `macos-latest` to ambient
Chrome) was then implemented and verified GREEN on real CI, resolving
the CI-config half of this item completely — all 5 `R-CMD-check.yaml`
matrix legs are now green. **Started/Completed:** 2026-08-20 (single
session).

**What actually happened, in order:**

1.  **Phase 0 orientation** — read `SAFEGUARDS.md` in full;
    `SESSION_NOTES.md` (S613–618’s full thread); `gh issue list` (13
    open); `git status`/`log`/`diff --stat` (clean, S618 fully closed
    out, both ledger frontiers `== HEAD`). `gh run list --branch master`
    (S545-ratified CI-status check) found the MOST RECENT push (S618’s
    own docs-only close-out commit) still showed `R-CMD-check.yaml` red
    on `macos-latest`, with the identical `Runtime.evaluate` signature —
    a 3rd data point, on a docs-only commit, ruling out any code-diff
    cause. `methodology_dashboard.py` (96/100, 1 HIGH risk, unchanged —
    the same 3 files past the 2,000-line cap, report-don’t-fix). Ledger
    reconcile: no gap (both frontiers `== HEAD`). Ghost-session check on
    the same 6 untracked files prior sessions already traced —
    unchanged. Rendered the priorities list + `AskUserQuestion` — **user
    picked the macOS CDP-timeout investigation.**
2.  **Phase 1B claimed at the literal next step** — `SESSION_NOTES.md`
    stub + `HANDOFFS.md` `status: pending` receipt, committed
    (`40c2e96b`), before any technical investigation — avoided a 5th
    recurrence of the Learning 624/625/628/644 pattern.
3.  **Mid-session, unrelated user question:** owner noticed 16
    `[x]`-checked DONE items still in `BACKLOG.md`. Investigated (not
    assumed): confirmed each already has a dated `CHANGELOG.md` entry
    (nothing at risk of loss) and that this matches an established
    periodic-batch-sweep precedent (S548, 2026-08-13), not a new process
    break. Filed a new Housekeeping item per owner direction to keep the
    current task uninterrupted rather than switching scope mid-session
    (`ff091613`).
4.  **Diagnosis via a 6-agent research workflow** (`diagnose` skill’s
    Phase 1–3): 5 parallel research angles (chromote’s own source,
    chromote’s issue tracker, GitHub Actions macOS-runner
    resource-constraint evidence, Gatekeeper/quarantine mechanics, a
    fresh trace of this project’s own CI logs) + 1 synthesis pass. Found
    the exact mechanism via direct source inspection (not assumed):
    `ChromoteSession$new()` unconditionally issues an internal
    `Runtime.evaluate` command during its own bootstrap
    (`private$get_pixel_ratio()`, chromote 0.5.1) to read
    `window.devicePixelRatio`, governed by a 10s `default_timeout` field
    with no constructor argument to raise it. Ranked 5 falsifiable
    hypotheses; H1 (cold-launch timing exhaustion) was top-ranked and
    best-evidenced.
5.  **H1 fix, full TDD cycle** (PRE-RED→RED→GREEN→REFACTOR,
    `AskUserQuestion`-gated at every transition): raised
    `chromote::default_chromote_object()$default_timeout` to 60s in
    `helper-live-render-positions.R`, guarded by a new structural RED
    test (`test_helper_live_render_positions_timeout.R`, 3 `test_that`
    blocks / 6 expectations). Confirmed genuine RED (6/6 fail), GREEN
    (6/6 pass, full clean regression 0 failed/0 error, 0 lints),
    [`devtools::check()`](https://devtools.r-lib.org/reference/check.html)
    (0 errors, 1 pre-existing WARNING, 2 pre-existing NOTEs, all
    confirmed unrelated to this diff). Committed (`1553099a` RED,
    `1780789d` GREEN), pushed.
6.  **Real CI verification found H1 FALSIFIED, not confirmed:** run
    `32417985922`’s `macos-latest` leg failed again after 13m34s —
    identical signature, identical 3 tests, wall time roughly doubled
    (454s→865s, consistent with the full 60s actually being exhausted 3
    times). Reported this negative result to the user immediately via
    `AskUserQuestion` rather than silently trying another guess
    (matching S616/S618’s own “stop and ask” precedent) — recorded as
    `PROJECT_LEARNINGS.md` Learning 648.
7.  **Fallback fix, full TDD cycle** (PRE-RED→RED→GREEN→REFACTOR,
    gated): added `if: ${{ matrix.config.os != 'macos-latest' }}` to the
    3 Chrome-provisioning steps in `R-CMD-check.yaml`, reverting that
    one leg to ambient Chrome (S616’s own proven-green precedent),
    guarded by 3 new assertions extending
    `test_r_cmd_check_workflow_chrome_setup.R`. Confirmed genuine RED
    (3/3 fail), GREEN (12/12 pass — 9 pre-existing + 3 new — full clean
    regression 0 failed/0 error, 0 lints). Committed (`4a134701` RED,
    `d2e9f487` GREEN), pushed.
8.  **Real CI verification: ALL 5 matrix legs GREEN**, run `32423688930`
    — `macos-latest` completed in 10m4s (faster than any prior run on
    this leg since chromote tests joined `R CMD check`’s surface), with
    the 3 Chrome-provisioning steps cleanly skipped (`-`) and
    `check-r-package@v2` passing. `ubuntu-latest`/`windows-latest`
    unaffected, pin intact. Recorded as `PROJECT_LEARNINGS.md` Learning
    649.
9.  **Close-out:** `BACKLOG.md`’s chromote item removed outright (Phase
    3F’s literal instruction — fully resolved, full history already in
    `CHANGELOG.md` across S616/S618/S619 entries; a deliberate choice
    not to perpetuate the exact `[x]`-left-in-place pattern flagged
    mid-session in step 3) plus a new, explicitly optional/low-priority
    Housekeeping item for the still- unexplained *why* (the pinned
    binary’s hang mechanism itself, distinct from the now-fully-
    resolved practical CI failure). `PROJECT_LEARNINGS.md` Learnings
    648/649 recorded; `CLAUDE.md`’s learning-count cross-reference
    refreshed (647→649). This handoff written.

**Runtime smoke test (Phase 3E):** the deliverable changes CI runtime
behavior directly — verified via 2 real, pushed `R-CMD-check.yaml` runs
(not local-only): the H1 attempt confirmed FAILING on live
infrastructure (disclosed, not hidden), the fallback confirmed GREEN on
all 5 matrix legs on live infrastructure. This is the faithful
verification this kind of change needs, matching S616/S618’s own
“push-and-observe” precedent.

**Close-out checklist mapping** (`CLAUDE.md`): citation /
tutorial-article / `NEWS.Rmd` / `a2interactive.Rmd` / `_pkgdown.yml`
checklists all **N/A** — no new exported R function, no new user-facing
Shiny feature, CI-workflow/test-helper-config-only. GitHub issue
close-out **N/A** — this work isn’t tied to a specific open issue
(matching S618’s own precedent). Lint checklist **DONE** (0 lints on all
3 touched files, confirmed at each GREEN phase).

**Self-assessment (Session 619): 9/10.** **Strengths:** (1) Used a
6-agent research workflow for the diagnosis phase rather than guessing —
direct source inspection of chromote’s actual GitHub code (not just its
documented API) found the exact internal mechanism, which no amount of
log- reading alone would have surfaced. (2) Followed the full TDD
PRE-RED→RED→GREEN→REFACTOR cycle, `AskUserQuestion`-gated at every
transition, for BOTH the H1 attempt and the fallback — two complete,
independently-verified cycles within one deliverable, not one cycle
skipped for expediency. (3) When H1 failed on real CI, reported the
negative result honestly and immediately, treating the falsification
itself as diagnostic evidence (distinguishing “genuinely wedged” from
“needs more time”) rather than silently trying a second guess — matching
this project’s own “stop and ask” precedent and turning a failed attempt
into a documented, transferable learning (648) rather than a discarded
dead end. (4) Verified via REAL CI pushes both times, not local tests
alone — the only faithful verification for a CI-runner-specific
timing/environment bug. (5) Handled the mid-session unrelated user
question (stale BACKLOG.md `[x]` items) by investigating before
answering (confirmed nothing was at risk, confirmed it matched existing
precedent) rather than assuming either “this is broken” or “this is
fine,” and avoided scope creep by filing rather than fixing mid-task,
per the user’s own explicit choice. (6) At close-out, removed the
now-fully- resolved chromote BACKLOG item outright (Phase 3F’s literal
text) rather than leaving it `[x]`-checked — a small but deliberate act
of not perpetuating the exact debt pattern surfaced mid-session.
**Weaknesses:** (1) Two early process missteps, both self-corrected but
real overhead: attempted `ScheduleWakeup` (a `/loop`-specific tool) to
wait on a background task outside a loop context, and spawned a
redundant monitoring `Agent` for a background Bash task that already had
its own completion notification — neither caused harm, both wasted a
small amount of turns/tokens. (2) The H1 fix attempt, while the
top-ranked hypothesis from a genuinely thorough research pass, still
cost a full ~14-minute real-CI round-trip that did not resolve the issue
— the fallback’s own supporting evidence (S616’s directly-proven-green
run on ambient Chrome, same leg) was arguably at least as strong as H1’s
evidence going in, and a more skeptical prioritization might have tried
the lower-risk fallback first or in parallel rather than sequentially.
(3) The research workflow itself was a substantial token investment
(~500k subagent tokens, 6 agents, ~12 minutes) for a diagnosis whose
actionable outcome (the fallback) did not strictly require ALL 5
research angles — though the mechanism-level finding (the exact internal
`Runtime.evaluate` call site) is now durably documented and may save a
future session real time if pinned-Chrome parity on macOS is ever
revisited. **ROI:** very high — a CI failure that had recurred on every
real push since S618 (4 consecutive red `macos-latest` runs across 2
sessions) is now fully green, with a well-evidenced, documented
root-cause explanation on record rather than a blind patch, and the
exact falsification data point (raising the timeout does NOT help) is
preserved so no future session re-attempts the same speculative fix.

**Next steps:** No forced next step — the practical problem (macOS CI
failing) is FULLY resolved. Optional, explicitly low-priority: a future
session could investigate WHY the pinned Chrome-for-Testing binary hangs
on `macos-latest`’s `ChromoteSession$new()` bootstrap specifically
(`BACKLOG.md` Housekeeping’s new optional item) — only worth doing if
pinned-Chrome reproducibility on macOS becomes valuable later; the
research workflow’s own findings (an unconfirmed-for-Chromium
Firefox/Mozilla sandbox-stall analog; Gatekeeper/quarantine evidenced as
NOT applicable to `browser-actions/setup-chrome`’s actual pipeline) are
a starting point, not a solved problem. Otherwise, pick up any other
`BACKLOG.md` item per the normal Phase 0 priorities-list process
(Walker/BJL Phase 2b, NEWS.Rmd simplification, and the
pedigree-package-split scoping session were the other 3 items on this
session’s own priorities list, still open).

**Key files:** `.github/workflows/R-CMD-check.yaml:48-89` (the 3-step
Chrome-provisioning block + the new `if:` guards);
`tests/testthat/helper-live-render-positions.R:75-96` (the
`default_timeout` raise, H1’s own code — kept even though H1 alone
didn’t resolve macOS, since it’s harmless, correct hygiene, and still
matters for the legs that keep the pin);
`tests/testthat/test_r_cmd_check_ workflow_chrome_setup.R` (12
expectations, 4 `test_that` blocks, the new one guarding the `if:`
guards); `tests/testthat/test_helper_live_render_positions_timeout.R`
(new file, 3 `test_that` blocks / 6 expectations,
structural/source-inspection style); `PROJECT_LEARNINGS.md` Learnings
648/649 (the falsification finding and the per-platform-fallback
pattern); `BACKLOG.md` Housekeeping (the chromote item removed outright;
the new optional root-cause item added).

**Gotchas for a future session:** (1) `macos-latest` in
`R-CMD-check.yaml` now runs WITHOUT a pinned Chrome — it uses whatever
Chrome the runner image ships ambiently, same as before S618’s pin was
introduced. If `macos-latest` ever starts failing chromote tests again,
do NOT assume it’s this exact bug recurring — re-diagnose from scratch,
since ambient Chrome can itself drift over time in a way the pinned
binary wouldn’t. (2) Raising `default_timeout`
(`helper-live-render- positions.R`) is proven NOT sufficient to fix a
genuinely wedged chromote session on the pinned macOS binary — do not
re-attempt “just raise it further” as a fix for any future recurrence of
this specific symptom without new evidence; treat a still-failing
raised-timeout as confirming “wedged,” not “needs more time.” (3) The
16-item `BACKLOG.md` `[x]`-sweep and the optional macOS root-cause item
are both genuinely optional/low-priority — neither blocks anything, both
are explicitly deferred, not accidentally dropped.

### Session 619 Handoff Evaluation (by Session 620)

**Score: 8/10.** **What helped:** `key_files` pointed exactly at the
files this session’s own diagnosis touched; `gotchas` \#1/#2 (macOS
reverted to ambient Chrome; raising `default_timeout` proven
insufficient, don’t re-attempt) held up and were directly relevant
background while reading the CI-status check at Phase 0. **What was
missing/wrong:** `next_steps` said “Walker/BJL Phase 2b… still open” as
one of “the other 3 items on this session’s own priorities list” — this
was already STALE at the moment S619 wrote it: Phase 2b had been DONE 4
sessions earlier (S615, per `BACKLOG.md`’s own dated entry), and S619’s
own Phase 0 orientation should have surfaced this via the standard
priorities-list render. This didn’t cost this session real time (Phase
0’s own fresh `BACKLOG.md` read caught the correct state — Phase 3 was
the actual next step, not Phase 2b — before any priorities list was
rendered to the user), but it’s the kind of inaccuracy Learning-worthy
elsewhere in this project’s history: a handoff’s “next_steps” list
should be re-verified against the CURRENT `BACKLOG.md` state at write
time, not copied forward from an earlier session’s own framing without
re-checking. **ROI:** moderate — the CI-status gotchas were useful; the
stale priorities pointer was caught by Phase 0’s own independent
process, not by trusting the handoff.

### What Session 620 Did

**Deliverable:** Walker/BJL Phase 3 — Cutover (issue \#141), per
`docs/planning/pedigree-diagram- walker-bjl-apportioning-redesign-plan.md`
§Migration Path Phase 3. **DONE** — full TDD PRE-RED→RED→GREEN→REFACTOR
cycle, `AskUserQuestion`-gated at every transition.
`.positionMatingUnitForest()` cut over from the OLD contour-merge
implementation to the Walker/BJL engine; `.computeDupNudge()` and the
OLD implementation deleted; `orderBySex` removed from
[`makePedigreeMatingLayout()`](https://github.com/rmsharp/nprcgenekeepr/reference/makePedigreeMatingLayout.md)’s
public signature. **Started/Completed:** 2026-08-20–2026-08-21 (single
session).

**What actually happened, in order:**

1.  **Phase 0 orientation** — read `SESSION_RUNNER.md`/`SAFEGUARDS.md`
    in full; `SESSION_NOTES.md` (S613-619’s thread); `gh issue list` (13
    open); `git status`/`log`/`diff --stat` (clean, S619 fully closed
    out, ledger frontiers both `== HEAD` except the self-reference
    2-commit gap, matching the established S600/S602-619 no-op pattern);
    `gh run list` (CI green on all recent runs);
    `methodology_dashboard.py` (96/100, 1 HIGH risk, unchanged file-size
    items). Ghost-session check on the same 6 untracked files prior
    sessions already traced — unchanged, no new ghost deliverable.
    Rendered the priorities list (4 numbered `AskUserQuestion` options)
    — **user picked Walker/BJL Phase 3 (the direct continuation of the
    in-flight epic, Phase 2b’s real-fixture gate having already passed
    per S615).**
2.  **Grounded directly in the plan document’s Phase 3 spec,
    Evidence-Based Inventory, and current source** before any code: full
    read of the plan’s Migration Path Phase 3 section (Commit 3-1/3-2
    file lists), the full pinned-value/test inventory table, and direct
    reads of every affected test file (`test_positionMatingUnitForest.R`
    in full — all 1583 original lines across several Read calls — plus
    `test_positionMatingUnitForestBJL.R` in full, 931 lines, plus the
    relevant sections of
    `test_makePedigreeMatingLayout.R`/`test_addRectilinearWaypoints.R`/
    `test_resolveEdgeNodeCollisions.R`) and the current
    `.positionMatingUnitForestBJL()`/
    `.positionMatingUnitForest()`(OLD)/[`makePedigreeMatingLayout()`](https://github.com/rmsharp/nprcgenekeepr/reference/makePedigreeMatingLayout.md)
    source.
3.  **Phase 1B claimed** — `SESSION_NOTES.md` stub + `HANDOFFS.md`
    `status: pending` receipt, committed (`014f0910`).
4.  **PRE-RED scope decision, via its own dedicated `AskUserQuestion`**
    (per CLAUDE.md’s “pre-RED scope decision is a separate question”
    rule): reconciled the plan’s literal “Commit 3-1 (4 files) / Commit
    3-2 (2 files)” split against this project’s own unbroken
    RED/GREEN-as-separate-commits convention — chose RED (test-only,
    files re-pinned/merged/deleted) then GREEN (production swap alone),
    each its own commit.
5.  **Second PRE-RED scope decision**, surfaced by direct source
    inspection before writing RED: found the top-level plan’s own
    “orderBySex… untouched” claim was stale relative to Phase 1b’s own
    later, ratified finding (“restructured, not preserved unchanged —
    eliminated as a separate pass”) — `.positionMatingUnitForestBJL()`
    never had an `orderBySex` parameter at all, and 6 test blocks across
    2 files still tested the OLD toggle directly. Presented via
    `AskUserQuestion`; owner picked removing the parameter from the
    public signature outright (zero real callers, grep-confirmed) over
    keeping it as a silent no-op.
6.  **RED**, gated: built a throwaway monkey-patch probe (reassigning
    `.positionMatingUnitForest`’s package-namespace binding to delegate
    to `.positionMatingUnitForestBJL()`, matching this project’s own
    “verify by execution, never hand-derive” discipline) to derive every
    new pinned value — trio/GA204Z-loop positional literals, the
    F1/nested/notover black-box regression values (150.12/60.12/180.12),
    Track 1/2 defect counts (all found to fully resolve to 0, a
    genuinely surprising result from directly running the code, not
    predicted) — then wrote the merged/re-pinned
    `test_positionMatingUnitForest.R` (24 BJL tests merged in, 3-way-OR
    invariant replaced with a single exact-equality assertion, 4
    orderBySex tests + 2 Track-3-clamp tests + 3 computeDupNudge
    white-box tests deleted, 3 Track-3-Engagement-Gate fixtures
    transformed into black-box regression coverage), deleted
    `test_positionMatingUnitForestBJL.R`, and re-pinned the other 3
    files. Confirmed genuine RED (219 failed / 0 error, entirely
    contained to the 5 touched files). Committed (`d6135511`, later
    amended — see step 8).
7.  **RED→GREEN**, gated: deleted `.computeDupNudge()` and the OLD
    `.positionMatingUnitForest()` (~700 lines); renamed
    `.positionMatingUnitForestBJL()` to `.positionMatingUnitForest()`,
    updating its own roxygen doc; updated the call site; removed
    `orderBySex` from
    [`makePedigreeMatingLayout()`](https://github.com/rmsharp/nprcgenekeepr/reference/makePedigreeMatingLayout.md).
    First full-regression run found 20 failures / 1 error — **2 genuine
    implementation defects**, diagnosed by running each failing fixture
    in isolation, not by inspection: (a) BJL never carried the OLD
    function’s own input-validation guards (Phase 2a/2b’s fixtures were
    always valid by construction, so this gap was never exercised) —
    restored verbatim; (b) a mating unit whose BOTH sire and dam are
    dangling (issue \#154’s original “both-dangling” shape) crashed
    `.buildForestChildrenOf()` on an empty `rootIds` — BJL had no
    equivalent to the OLD algorithm’s own issue \#154 fix; fixed by
    making such a unit’s own real children independent Tier-1 roots
    directly, and broadening Tier 2’s union-x derivation to cover every
    unit with ≥1 real child (not just anchored ones). The remaining 18
    failures / 0 errors were **RED-phase test bugs** (matching S614’s
    own established “3 RED-phase test bugs found and fixed during GREEN”
    precedent): a now- superseded minSep property test (deleted, its
    correctly-scoped Phase 2a successor already merged in), the issue
    \#143/#144 mismatch-count regression guard (rewrote to assert the
    mismatch set is exactly the B2 population, 56, not 0 — B2
    individuals render at their own genuine gen by design under the new
    engine, a deliberate Phase 1b/2a difference from the OLD algorithm’s
    uniform non-anchor override, confirmed via direct classification:
    all 56 were B2, none unexplained), 1
    `test_addRectilinearWaypoints.R` fixture whose own non-anchor was
    accidentally B2-shaped (fixed by making it a parentless B1 founder,
    restoring the fixture’s own intended premise), and 3
    `test_makePedigreeMatingLayout.R`/`test_resolveEdgeNodeCollisions.R`
    connector/curved-heuristic re-pins driven by the new engine’s
    different coordinate distribution (1 fixture — the small issue \#160
    comment 1 synthetic reproduction — no longer collides at all under
    the new coordinates; rewritten to use the real 375-fixture instead,
    which reliably reproduces the mechanism, 47 measured collisions).
    Verified genuine GREEN: full clean regression 0 failed/0 error
    project-wide (2 marker-genetics failures seen in ONE full-suite run
    confirmed pre-existing order-dependent flakiness via `git stash` —
    both pass cleanly in isolation, absent from RED’s own offender
    list).
8.  **Amended RED** (`e92d945e`) to fold in the 4 test-file corrections
    from step 7 — each re-verified via `git stash` (temporarily removing
    the GREEN-phase production diff) to confirm the corrected content
    still shows genuine, meaningful RED against the OLD, unmodified
    algorithm (229 failed / 0 error, up from 219, still entirely
    contained to the same 5 files) before amending — keeping RED an
    honest, minimal “what should be true post-cutover” record and GREEN
    a clean, SAFEGUARDS.md-cap-compliant (5 files:
    `R/makePedigreeDiagramData.R` + `NEWS.Rmd`/`NEWS.md` +
    `man/makePedigreeMatingLayout.Rd` + `inst/WORDLIST`) production-only
    commit (`b013c009`).
9.  **GREEN→REFACTOR**, gated: `lintr::lint_package()` (whole package) 0
    findings before AND after a genuine simplification (an O(n·m)
    `vapply` scan replaced with a direct `unique(childEdges$from)`
    membership check, verified behavior-preserving via full regression +
    lint). Committed (`01f29342`).
10. **Required Phase-3 verification beyond the gated cycle:**
    live-render check (F1/Track-C 9-subject and real-375 fixtures, via
    `helper-live-render-positions.R`, already merged into the suite from
    Phase 2b) confirmed passing as part of the full clean regression,
    plus a direct standalone re-confirmation; fresh grep re-confirmed
    the call-site/downstream-consumer inventory (single call site, zero
    `matingUnits`/`duplicates`/`childEdges` consumers outside this file)
    has not drifted since planning;
    [`devtools::check()`](https://devtools.r-lib.org/reference/check.html)
    (0 errors, 1 WARNING + 2 NOTEs, all 3 confirmed pre-existing — a
    4th, NEW Rd cross-reference warning, a `\link{}` to the now-internal
    `.positionMatingUnitForest()` from the one exported function’s doc,
    was found and fixed in-session); pushed and confirmed CI green on
    all 4 workflows.
11. **Close-out:** `BACKLOG.md`’s Walker/BJL item updated with the full
    S620 progress narrative; `CHANGELOG.md` entry added;
    `PROJECT_LEARNINGS.md` Learnings 650/651/652 recorded; `CLAUDE.md`’s
    learning-count cross-reference refreshed (649→652); this handoff
    written.

**Runtime smoke test (Phase 3E):** the deliverable changes runtime
behavior directly (every Diagram tab render now uses the new positioning
engine) — verified via the live-render checks in step 10
(chromote-driven real DOM rendering, not just internal x/gen math), plus
the full
[`devtools::check()`](https://devtools.r-lib.org/reference/check.html)
examples run
([`makePedigreeMatingLayout()`](https://github.com/rmsharp/nprcgenekeepr/reference/makePedigreeMatingLayout.md)’s
own `@examples` block executes against the real bundled example
pedigree). This is the faithful verification this kind of change needs,
matching this project’s own established “live-render, not just internal
math” precedent (S615’s own memory note).

**Close-out checklist mapping** (`CLAUDE.md`): citation checklist
**N/A** — no new statistic. Tutorial/article checklist **N/A** — no new
Shiny tab/control, internal algorithm swap only. `NEWS.Rmd` checklist
**DONE** — same-session entry disclosing the layout-engine switch and
the `orderBySex` removal. `a2interactive.Rmd` checklist **deferred, per
its own explicit policy** — `grep`-confirmed `a2interactive.Rmd` never
documented `orderBySex` to begin with (removing it creates no
staleness/broken-example risk there), so nothing is actively broken; the
whole Walker/BJL migration’s user-facing effect (diagrams look
different) is a candidate for the deferred documentation pass once the
migration fully completes (Phase 4+). `_pkgdown.yml` checklist **N/A** —
no new exported function, only a parameter removed from an
already-listed one. GitHub issue close-out **N/A** — issue \#141 stays
open (Phase 4, a future session, closes it per the plan’s own spec).
Lint checklist **DONE** (0 lints, package-wide, confirmed at REFACTOR).

**Self-assessment (Session 620): 9/10.** **Strengths:** (1) Used a real
monkey-patch probe (never a plain “call the new function directly”) to
derive every re-pinned literal against the FULL, real downstream
pipeline — this is what caught several genuinely surprising,
unpredictable-by-reasoning findings (the D1 bar-vs-bar residual and
larger-gap residual both fully resolving to 0, not just improving; the
real-fixture DZ twin connector losing its collision while MZ/“?” kept
theirs) that a literal-by-literal hand-derivation would have gotten
wrong. (2) Diagnosed every GREEN-phase failure by running the specific
failing fixture/probe in isolation, never by inspection or assumption —
this surfaced 2 genuine implementation defects (input validation,
both-dangling root handling) as distinct from RED-phase test bugs, and
traced the B2-rendering-difference root cause across 4
separately-symptomatic test failures rather than patching each ad hoc
(recorded as its own transferable Learning 650). (3) Surfaced 2 real,
non-obvious scope/approach decisions (RED/GREEN commit-split
reconciliation; the `orderBySex` removal, found via direct source
inspection contradicting the top-level plan’s own now-stale claim) via
dedicated `AskUserQuestion`s before writing code, rather than silently
picking an interpretation. (4) Kept every commit within
`SAFEGUARDS.md`’s 5-file cap by amending the still-local, unpushed RED
commit with GREEN-phase test corrections — re-verified via `git stash`
that the amended content was still genuinely RED against the untouched
baseline before amending, rather than either exceeding the cap or
leaving a known-red intermediate commit (which the plan’s own Phase 3
spec explicitly warns against). (5) Found and fixed a NEW
[`devtools::check()`](https://devtools.r-lib.org/reference/check.html)
warning (Rd cross-reference) in-session rather than deferring it,
keeping the package’s check status at parity with every prior session’s
own established pre-existing-only baseline. **Weaknesses:** (1) The
initial RED-phase test-file authoring did not anticipate the
B2-rendering-difference (a design choice already documented in the Phase
1b design note, findable via grep before writing RED, not just via
GREEN-phase failures) — Learning 650 names the transferable fix (grep
the design note’s own documented OLD-vs-NEW differences against the
existing test suite’s own trigger conditions BEFORE writing RED). (2)
This session ran long (a single sitting covering the full plan-scoped
Phase 3, as the plan’s own “session boundary: this phase is one session”
note anticipated given its C2-1/C2-2 restructuring) — no
session-boundary violation, but a genuinely large amount of ground
covered in one continuous session. **ROI:** very high — a 5+ session
migration’s own central cutover step is complete, all tests genuinely
green (not vacuously), 2 real defects the new engine would otherwise
have shipped with are fixed, and 3 transferable Learnings (650/651/652)
compress the session’s own hard-won diagnostic technique for any future
engine-swap migration.

**Next steps:** **Phase 4** (cleanup/documentation) is the plan’s own
explicit next step — its own separate session, per the plan’s “session
boundary: this phase is one session” note (acceptable to split into
4a/4b if too large, per the plan’s own C2-8 fix): (1) update
`docs/planning/pedigree-diagram-option2-layout-design-plan.md`’s D3
section to describe the completed BJL implementation; (2) close GitHub
issue \#141, citing this migration’s commits
(`014f0910`/`e92d945e`/`b013c009`/`01f29342`, plus S610/S613/S614/S615’s
own prior-phase commits) and the regression-number re-pin evidence; (3)
update `BACKLOG.md`’s “Track 3’s 2 disclosed trade-offs” item (both
trade-offs are now resolved by construction — no clamp exists anywhere
in the new engine); (4) sweep stale in-code comments referencing Track
3/Track 6/`.computeDupNudge()`/the old patch-stack (a fresh
`grep -rn "Track 6\|Track 3\|computeDupNudge\|finalUnitX" R/ docs/` is
the plan’s own named verification command); (5) confirm explicitly (not
assume) whether the tutorial/article and `a2interactive.Rmd` checklists
apply — this session’s own close-out already confirmed
`a2interactive.Rmd` needs no fix (never documented `orderBySex`), but
the FULL migration’s own user-facing “diagrams look different” effect
may warrant a documentation note once Phase 4 completes the whole
redesign. Otherwise, `BACKLOG.md`’s other READY items remain open:
NEWS.Rmd simplification (Effort L, explicitly iterative/multi-round),
the pedigree-diagram-package-split scoping session (Effort M,
owner-directed to run after this migration is fully done — i.e., after
Phase 4), and the 16-item `BACKLOG.md` `[x]`-sweep (Effort S).

**Key files:** `R/makePedigreeDiagramData.R:585-798` (the production
`.positionMatingUnitForest()`, formerly `.positionMatingUnitForestBJL()`
— the 2 new GREEN-phase fixes live at `:657-679` \[orphan- unit roots\]
and `:703-717` \[Tier 2 `xDerivableUnits` broadening\]); `:896-`
([`makePedigreeMatingLayout()`](https://github.com/rmsharp/nprcgenekeepr/reference/makePedigreeMatingLayout.md),
`orderBySex` removed); `tests/testthat/test_positionMatingUnitForest.R`
(now ~1910 lines, the merged production test file — the 3-way-OR
replacement is at the “single exact-equality” test near the file’s
middle, the transformed Track-3-Engagement-Gate fixtures and the merged
BJL Phase 2a/2b content follow the zero-coincidence-gate test);
`docs/planning/pedigree-diagram-walker-bjl-apportioning-redesign- plan.md`
(§Migration Path Phase 3/Phase 4, §Evidence-Based Inventory);
`PROJECT_LEARNINGS.md` Learnings 650/651/652.

**Gotchas for a future session:** (1) The monkey-patch probe technique
(Learning 651) is reusable for ANY future “swap engine X for Y, re-pin
downstream literals” migration in this codebase — don’t re-derive it
from scratch; [`unlockBinding()`](https://rdrr.io/r/base/bindenv.html) +
[`assign()`](https://rdrr.io/r/base/assign.html) on the OLD function’s
namespace binding, then call the real, unmodified, exported top-level
function through it. (2) `orderBySex` is GONE from
[`makePedigreeMatingLayout()`](https://github.com/rmsharp/nprcgenekeepr/reference/makePedigreeMatingLayout.md)’s
public signature — if any future session finds external code (a script,
a vignette, a downstream consumer) still passing it, that call will now
error with “unused argument,” not silently no-op; this is the intended,
disclosed behavior (NEWS.Rmd/man page both document it), not a
regression to investigate. (3) B2 individuals (own parent edge or own D5
direct child) now render at their own genuine gen, not their non-anchor
unit’s gen — do NOT assume every non-anchor party renders at its unit’s
gen the way the OLD algorithm’s issue \#143 override guaranteed; check
B1 vs. B2 status first (Learning 650’s own practical rule). (4) Track
3’s parent-span clamp and the entire
`.computeDupNudge()`/Track-3-Engagement-Gate mechanism no longer exist
anywhere in the codebase — any future BACKLOG.md item or in-code comment
still referencing them describes OLD, now-dead behavior (Phase 4’s own
comment-sweep task, not yet done).

------------------------------------------------------------------------

### Session 620 Handoff Evaluation (by Session 621)

**Score: 9/10.** **What helped:** the `next_steps` field named exactly
the 6 concrete actions Phase 4 needed (D3 section update; close issue
\#141 citing commits; update `BACKLOG.md`’s trade-off item; sweep stale
in-code comments with the plan’s own exact `grep` command; confirm the
tutorial/article and `a2interactive.Rmd` checklists rather than assume;
add `NEWS.Rmd`/`CHANGELOG.md` entries) — used almost verbatim as this
session’s own task checklist. `key_files`/`gotchas` were directly useful
and all confirmed accurate on re-read:
`.positionMatingUnitForest():585-798`, `orderBySex` removed, Track
3/`.computeDupNudge()` genuinely gone (grep-confirmed 0 hits in `R/`),
B2-vs-B1 gen rendering — every one of these was load-bearing for writing
an accurate D3 update and issue-close comment without re-deriving them
from scratch. **What was missing:** the `HANDOFFS.md` receipt’s own
free-text prose section was left as the literal unfilled placeholder
(`<free-text prose: filled at close-out>`) rather than actual prose —
`SESSION_NOTES.md`’s version was fully written, so this cost nothing
practically, but the receipt itself didn’t fully satisfy its own
documented format (a small, worth-noting gap, not scored heavily).
**What was wrong:** nothing found inaccurate — every specific claim
(commit shas, line ranges, “Track 3/6 no longer exist”,
“`a2interactive.Rmd` already N/A for `orderBySex`”) checked out exactly
on independent verification this session. **ROI:** very high.

### What Session 621 Did

**Deliverable:** Walker/BJL Phase 4 — Cleanup & Close (issue \#141), per
`docs/planning/pedigree- diagram-walker-bjl-apportioning-redesign-plan.md`’s
§Phase 4 spec. **DONE** — documentation/cleanup only, no production
logic changed. **Started/Completed:** 2026-08-20 (single session).

**What actually happened, in order:**

1.  **Phase 0 orientation** — read `SESSION_RUNNER.md`/`SAFEGUARDS.md`
    in full; `SESSION_NOTES.md` (S613-S620’s thread); `gh issue list`
    (13 open); `git status`/`log`/`diff --stat` (clean, S620 fully
    closed out, `CHANGELOG.md` ledger 2 commits behind `HEAD` —
    confirmed the established self-reference no-op pattern, not a
    genuine gap; `HANDOFFS.md` frontier `== HEAD`); `gh run list` (CI
    green on all recent runs); `methodology_dashboard.py` (96/100, 1
    HIGH risk, unchanged file-size items). Ghost-session check on the
    same 6 untracked files prior sessions already traced — unchanged, no
    new ghost deliverable. **Incidental finding, reported not fixed:**
    `BACKLOG.md`’s single-child-union item still carried an inline
    “targeted repair session (READY, Effort S)” tag for a function
    (`.computeSingleChildAntiCoincidence()`) that grep-confirmed was
    never shipped — the item’s own LATER prose (S609, same block) showed
    this was redirected to the Walker/BJL migration itself 12 sessions
    earlier; struck later this session as part of the Phase 4
    deliverable itself (see below), not a separate action. Rendered the
    priorities list (4 numbered `AskUserQuestion` options) — **user
    picked Walker/BJL Phase 4.**
2.  **Phase 1B claimed** — `SESSION_NOTES.md` stub + `HANDOFFS.md`
    `status: pending` receipt, committed (`7dccb6e6`).
3.  **Grounded directly in the plan’s Phase 4 spec, the D3 section it
    points at, and issue \#141’s full text/comments** before any edit:
    read
    `docs/planning/pedigree-diagram-walker-bjl- apportioning-redesign-plan.md`’s
    §Phase 4 (“what DONE looks like,” the verification command), the
    option2-layout-design-plan.md’s full D3 section (§3), and
    `gh issue view 141` in full (body + the S609 comment; state OPEN,
    labels `enhancement`/`premature optimization`).
4.  **D3 section updated** — appended a “Superseded (S609-S620)” note
    after the original D3 text (not rewritten in place, matching this
    project’s established precedent of preserving historical planning
    narrative — BACKLOG.md’s own append-only item convention is the same
    pattern) describing the correctness-driven redirect, the 3-tier
    reconciliation mechanism shipped, and the explicit
    D1/D2/D4/D5/D6-unchanged scope boundary.
5.  **Stale in-code comment sweep** — ran the plan’s own verification
    command
    (`grep -rn "Track 6|Track 3|computeDupNudge|finalUnitX" R/ docs/`),
    then deliberately extended it to `tests/` (not in the plan’s own
    command, but `test_that()` descriptions are exactly as much in-code
    documentation as a roxygen comment — Learning 654). `R/` was already
    accurate (S620 had annotated its own doc comments correctly during
    RED). `docs/planning/*.md` deliberately left untouched — 13 files
    reference these terms, all legitimate historical record of decisions
    made at the time, matching this project’s precedent against
    retroactively editing frozen/historical narrative. **One genuine
    finding in `tests/`:** `test_makePedigreeMatingLayout.R`’s own
    `test_that()` docstring for the 1,412-node real-fixture assertion
    still narrated the REMOVED Track 3 clamp’s arithmetic (“1,202 + 210
    = 1,412”) as the live explanation — verified stale, not just dated,
    by actually re-executing the real fixture (`direct nodes: 714`,
    `__bar_: 251`, `__drop_: 237`, `__proj_: 56` \[pre-existing dogleg
    infrastructure, unrelated to this migration\], `__jog_: 154`) and
    finding the OLD arithmetic’s own terms no longer decompose the
    number at all, even though both totals coincidentally land on 1,412.
    Rewrote the docstring to the verified current composition — **no
    assertion values changed** (both `1412L` and `154L` were already
    correct), comment-only. Spot-verified via
    [`testthat::test_file()`](https://testthat.r-lib.org/reference/test_file.html)
    on the one touched file (all green) plus a full clean regression
    afterward (0 failed/0 error, no non-baseline offenders) and
    `lintr::lint()` (0 findings) before committing.
6.  **BACKLOG.md’s “Track 3’s 2 disclosed trade-offs” item closed**
    (`[x]`) — both trade-offs (child-centering quality, D1 bar-vs-bar
    overlap) confirmed resolved by construction; the D1 bar-vs-bar
    residual specifically re-measured this session by running
    `test_addRectilinearWaypoints.R` directly (all green, 0 residual,
    matching its own docstring claim). The stale single-child-union tag
    found at Phase 0 (step 1 above) struck in place with a dated
    explanation, not deleted — Learning 653.
7.  **Issue \#141 closed** on GitHub: a comment citing the full Phase
    1a-4 commit history (`8ac50a4e` S611;
    `0a43ec30`/`e7f1f593`/`afa7c5f5` S614; `891837d6` S615;
    `014f0910`/`e92d945e`/`b013c009`/`01f29342` S620) and re-confirming
    the D1/D2/D4/D5/D6-unchanged scope. **Label decision gated via
    `AskUserQuestion`** (3 prior sessions, S609/S620×2, had explicitly
    deferred this exact call to “a future planning session or the owner
    directly” — this was that session): owner picked removing
    `premature optimization`, since its own meaning no longer applies to
    a closed, shipped, adversarially-verified implementation.
8.  **Tutorial/article and `a2interactive.Rmd` checklists explicitly
    re-confirmed, not assumed** — grepped both
    `vignettes/articles/colony-manager-guide.qmd` and
    `vignettes/a2interactive.Rmd` for algorithm-specific claims
    (contour-merge/Reingold/Walker/Buchheim/`orderBySex`): zero hits in
    either. Independently confirmed the vignette’s own “5 reserved
    node-id prefixes” comment is still accurate — `__proj_` is
    pre-existing `.buildMatingUnitForest()` dogleg infrastructure
    (gen-mismatch waypoints), unrelated to and unaffected by this
    migration, not a new prefix it introduced.
9.  **`NEWS.Rmd`** needs no further entry — S620’s own entry already
    discloses the user-facing change (layout engine switch, `orderBySex`
    removal) completely, confirmed by direct read.
10. **Close-out:** `CHANGELOG.md` S621 entry added; commits split across
    the 5-file cap (deliverable: `909dad20`; learnings: `8878239c`);
    `PROJECT_LEARNINGS.md` Learnings 653/654 recorded; `CLAUDE.md`’s
    learning-count cross-reference refreshed (652→654); this handoff
    written.

**Runtime smoke test (Phase 3E):** n/a — documentation/cleanup only,
zero production logic touched (confirmed: `R/` needed no changes at all,
the one code-adjacent edit was a test file’s comment-only docstring). No
runtime behavior changed; nothing to smoke-test, matching this session’s
own declared TDD framing (stated at Phase 1: “N/A this session…
documentation/cleanup”).

**Close-out checklist mapping** (`CLAUDE.md`): citation checklist
**N/A** — no new statistic. Tutorial/article checklist **DONE (confirmed
N/A)** — explicitly re-grepped this session, not assumed. `NEWS.Rmd`
checklist **N/A (already satisfied by S620)** — confirmed by direct
read, no further entry needed. `a2interactive.Rmd` checklist **DONE
(confirmed N/A)** — explicitly re-grepped, including the
reserved-node-id-prefix claim specifically. `_pkgdown.yml` checklist
**N/A** — no new exported function. GitHub issue close-out **DONE** —
issue \#141 closed this session, citing the full commit history per the
established \#131/#134/#135/#139/#142/#143/#144 precedent. Lint
checklist **DONE** (0 lints on the one touched test file, package-wide
unaffected).

**Self-assessment (Session 621): 9/10.** **Strengths:** (1) Extended the
plan’s own literal verification grep beyond its stated `R/ docs/` scope
into `tests/`, finding one genuine stale docstring the plan’s own
command would have missed entirely (Learning 654). (2) Verified the
stale docstring’s replacement by actually re-executing the real fixture
and breaking down every node-id prefix, rather than just updating the
one number that had visibly changed (`210L`→`154L`) and leaving an
equally-confident-but-wrong arithmetic framing around it — found a
pre-existing, unrelated `__proj_` node category in the process that
resolved what first looked like a real discrepancy. (3) Found and
corrected a stale `BACKLOG.md` inline tag that a flat future grep would
have surfaced as a live option, years after the same item’s own later
prose had already documented its abandonment (Learning 653) — caught
only because the named function was grep-confirmed never shipped, not by
reading the tag’s own text. (4) Gated the `premature optimization` label
decision via `AskUserQuestion` rather than either unilaterally deciding
it or leaving it unresolved a 4th time, directly resolving a decision 3
prior sessions had explicitly deferred. (5) Preserved historical
planning narrative by appending rather than rewriting (D3 section,
BACKLOG.md item), matching this project’s own strong precedent, while
still making the CURRENT state easy to find. (6) Full clean regression +
lint run despite this being a documentation-only session, rather than
assuming comment-only edits are risk-free. **Weaknesses:** (1) Spent
real investigative time (several tool calls) chasing the exact
node-count arithmetic discrepancy before finding the `__proj_`
explanation — defensible given this project’s own “verify by execution,
never assume” standard, but a more experienced first guess (checking
`.buildMatingUnitForest()`’s reserved-prefix list, which already
enumerated `__proj_`) would have found the explanation faster. (2) Did
not independently re-verify EVERY one of S620’s own `key_files`
line-range claims byte-for-byte before relying on them (spot-checked the
ones actually used); low risk here since all spot-checks that were done
came back accurate. **ROI:** high — the 11-session Walker/BJL migration
(S610-S621) is fully closed out: implementation shipped and verified
(S610-S620), documentation/issue/backlog trail closed (S621), 2
project-level process learnings captured with transferable practical
rules.

**Next steps:** Walker/BJL (issue \#141) is fully closed — no further
session owed. `BACKLOG.md`’s other READY items remain open, in the order
left by this session’s own Phase 0 priorities list: (1) the
pedigree-diagram package-split scoping session (Effort M,
research/scoping only) — the “probably after the Walker/BJL redesign”
sequencing condition its own text named is now satisfied; (2) `NEWS.Rmd`
simplification for a non-technical audience (Effort L, explicitly
iterative, needs a recurrence guardrail this time per S538’s own gap);
(3) the 16-item `BACKLOG.md` `[x]`-sweep (Effort S, housekeeping — note
this item’s own count grows by at least 1 more now that this session’s
own Track 3 trade-off item is `[x]`-checked); (4) lower-priority items
unchanged from S621’s own Phase 0 report (Chrome-for-Testing macOS hang
root-cause, `context_budget.py` adoption evaluation, `DESCRIPTION`
`Suggests:`/`Config/Needs` cleanup, kinship2 supplement PDF
reproduction, `BACKLOG.md`’s own ledger-size compression).

**Key files:**
`docs/planning/pedigree-diagram-option2-layout-design-plan.md` (D3
section, the “Superseded (S609-S620)” note appended this session);
`BACKLOG.md` (the “Track 3’s 2 disclosed trade-offs” item, now
`[x]`-closed, plus the struck stale tag in the single-child-union
sub-thread); `tests/testthat/test_makePedigreeMatingLayout.R:588-625`
(the corrected docstring, assertions unchanged); `PROJECT_LEARNINGS.md`
Learnings 653/654; GitHub issue \#141 (closed, `enhancement` label only,
`premature optimization` removed).

**Gotchas for a future session:** (1)
`.computeSingleChildAntiCoincidence()` was NEVER shipped — if a future
session finds it referenced anywhere outside `BACKLOG.md`’s own
now-struck historical note, that is new, not a missed cleanup from this
session. (2) The `__proj_` node-id prefix is PRE-EXISTING
`.buildMatingUnitForest()` dogleg infrastructure (parent/union
gen-mismatch waypoints), NOT something the Walker/BJL migration
introduced — do not attribute future `__proj_`-related bugs to the new
positioning engine without checking `.buildMatingUnitForest()` first
(line ~1418 in `R/makePedigreeDiagramData.R`). (3) `docs/planning/*.md`
files are deliberately excluded from any future “stale reference” sweep
unless a specific file is explicitly named as needing a live update (as
`pedigree-diagram-option2-layout-design-plan.md`’s D3 section was this
session) — most planning docs are intentionally frozen historical
record, not living documentation.
