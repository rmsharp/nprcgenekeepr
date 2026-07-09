# Plan — Document 1: "Engineering nprcgenekeepr 2.0.0" (public Quarto pkgdown article)

**Status:** Plan written Session 330 (DRAFT). Owner ratified proceeding with **Phase A**
and its commit-range framing (§2/§9 dragon #4) via `AskUserQuestion`, Session 331
(2026-07-09) — **Phase A is now DONE** (§7). Phases B-F remain future, separately
approved sessions each; no phase is bundled with another (FM #26).

**Workstream:** Adapted `docs/methodology/workstreams/RESEARCH_DOCUMENTATION_WORKSTREAM.md`
(Phases 2/3/4/6), substituting this repository's own artifacts (`git log`, `CHANGELOG.md`,
`PROJECT_LEARNINGS.md`, `HANDOFFS.md`, `SESSION_NOTES.md`, source/test trees) for the
workstream's default "external primary source / bibliography" model. There is no academic
citation list here — every claim's "citation" is a commit sha, a CHANGELOG entry, or a
file this project already produces. The workstream's discipline (claim-source mapping,
figure/table provenance, no unverified numeric claims, render verification) applies with
that substitution.

**Companion document (explicitly OUT of scope here):** "Document 2" — package purpose,
how it addresses that purpose, and how to put it into use — gets its own future planning
session per the owner's instruction (2026-07-09). Nothing in this plan commits Document
2's scope, audience, or structure.

---

## 1. Context

Session 329 crossed the CRAN 2.0.0 submission HARD STOP
(`docs/planning/cran-2.0.0-submission-plan.md` Phase 5). The owner asked (2026-07-09) for
two documents describing the finished v1.0.8 -> v2.0.0 modernization effort. This plan
covers only **Document 1**: a technical description of that transformation, required to
cover at minimum (1) the new use of Shiny modules, (2) new features, (3) enhanced
testing, and (4) the extensive use of Claude CLI (Claude Code) in the development
process — plus proposed tables and graphics to enhance information transfer.

**Why now, and why public:** the owner confirmed (`AskUserQuestion`, this session) that
Document 1 should be a **public pkgdown article**, not an internal-only report. This is a
real framing decision, not a default — the article will describe AI-agent-driven
development to an audience that includes CRAN reviewers, other researchers evaluating
the package, and potential collaborators. Section 4 (Claude CLI / methodology) therefore
carries the highest scrutiny of any section in this document (flagged as a dragon, §9).

**Format is already decided, not an open question.** `docs/planning/quarto-documentation-future-proofing-analysis.md`
§6-7 (adopted by the owner, Session 105, 2026-06-17) established: new long-form web
content goes in `vignettes/articles/*.qmd` (Quarto), rendered into the pkgdown site
via pkgdown's mixed `.qmd`/`.Rmd` mode, `.Rbuildignore`d so it carries **zero CRAN risk**
(confirmed each time via an `R CMD build` tarball check, per the S107-110 precedent
below). Four articles already exist on this pattern:

| Article | Session | Verification pattern |
|---|---|---|
| `vignettes/articles/breeding-group-formation.qmd` | S107 | `quarto render` + `pkgdown::build_article()` + `R CMD build` tarball check |
| `vignettes/articles/genetic-value-analysis.qmd` | S108 | same |
| `vignettes/articles/studbook-quality-control.qmd` | S109 | same + two-lens adversarial review |
| `vignettes/articles/age-sex-pyramid.qmd` | S110 | same + two-lens review (caught a real defect — reversed apparent sex skew) |

Document 1 is a **fifth article on the same, already-proven pattern** — not a new
toolchain decision. `_pkgdown.yml` has no explicit `articles:`/navbar menu (confirmed this
session), so pkgdown auto-lists new articles; adding the file requires no config edit,
matching the S107-110 precedent.

**Proposed working title / slug:** `vignettes/articles/engineering-the-2.0.0-release.qmd`
— "Engineering nprcgenekeepr 2.0.0: Modular Architecture, Expanded Capability, and an
AI-Assisted Development Process". Both are the author's naming call, not locked by this
plan; confirm or rename at Phase B kickoff.

---

## 2. Scope decisions (this session, owner-confirmed where noted)

- **Audience/location: public pkgdown article** (owner-confirmed, `AskUserQuestion`,
  2026-07-09). Written for domain experts, other primate-center bioinformatics groups,
  CRAN reviewers, and potential contributors — not a lay audience, not an internal-only
  memo.
- **Toolchain: Quarto**, per the already-adopted Session 105 policy (§1 above) — not an
  open decision.
- **Four required content pillars** (owner's instruction, verbatim): Shiny modules,
  new features, enhanced testing, extensive Claude CLI use. This plan adds a fifth,
  optional "by the numbers" consolidation section (§5) purely as a reader aid — cut it
  in Phase F if it duplicates the other four sections too much.
- **Date-anchoring discipline** (anti-pattern #16): this document describes a
  still-in-flight project (CRAN's accept/reject decision is still pending as of this
  plan) — every claim about "current" state must carry an explicit "(as of
  2026-07-09)"-style stamp, in historical-past narrative tense, not present-relative
  language ("currently," "as of now").
- **Commit range for "the v1.0.8 -> v2.0.0 transformation"** (evidence-verified this
  session, not assumed): from the commit CRAN actually received for v1.0.8 to the commit
  CRAN actually received for v2.0.0, per `CRAN-SUBMISSION`'s own git history —
  `4548aa1b265566c1dd913bd63ce781932879f8a7` (v1.0.8, CRAN date 2025-07-26 02:48:26 UTC)
  `..8ca8bb24551a6a95dc4468d8ef5218bd3d3c91e0` (v2.0.0, CRAN date 2026-07-09 17:57:22 UTC).
  `git rev-list --count --no-merges` on that range: **512 commits**. This is the
  authoritative scope boundary for every quantitative claim in the document — not
  "since the project began" and not "since some session number," unless a claim is
  explicitly framed as project-lifetime (e.g., total historical session count).
  **Resolved in Phase A (2026-07-09), correcting the prior session's assumption:** the
  earlier `S1` grep match was a false lead from an abbreviated-tag search (`S[0-9]+`)
  that missed the long-form `(Session N)` convention this project used before Session
  58. Direct verification (`git log --no-merges --reverse` across the range,
  cross-checked against zero `Session 0` or earlier hits anywhere in the full repo
  history) establishes: the SESSION_RUNNER methodology's actual **Session 1** begins at
  commit `6fd87749` (2026-05-30, "add read-only technical-debt audit report (Session
  1)") — squarely inside this range, **not** predating v1.0.8 as previously assumed.
  The range's first 10 commits (2025-12-25 through 2026-05-30) are informal,
  pre-methodology Shiny-module-branch experimentation (e.g. `4790b64f` "1st attempt at
  adding modules") plus the methodology's own bootstrap commit (`299060c0` "Add
  iterative session methodology framework", 2026-04-02) — none session-numbered. The
  range's last session-tagged commit is **S328** (`8ca8bb24` itself, "backfill own
  HANDOFFS.md receipt commit sha" — the exact v2.0.0 CRAN-submission commit). So:
  **328 numbered sessions (Session 1 -> S328)** fall within the range, accounting for
  502 of the range's 512 commits; the other 10 predate the methodology. This is now the
  authoritative session-count claim for Section 4 — see
  `vignettes/articles/data/process-metrics.csv`.

---

## 3. Evidence base (adapted claim-source map — WHERE the evidence lives)

No external bibliography exists for this document; every "source" below is an artifact
already produced by this project. **Phase A status: COMPLETE (2026-07-09).** The frozen
extraction script (`vignettes/articles/data-raw/build-document1-evidence.R`) and its 7
output CSVs (`vignettes/articles/data/*.csv`) are checked in and reproducible per the
Reproducibility Decision (§5-6). The high-level table below is retained for orientation;
the per-claim Claim-Evidence Map that follows it is the actual drafting input for
Phases B-E.

| Content pillar | Primary evidence source(s) | Frozen Phase A data file |
|---|---|---|
| Shiny modules architecture | `docs/planning/shiny-module-conversion-plan.md` (412 lines, 9-phase vertical-slice migration) | `module-inventory.csv`, `migration-phases.csv` |
| New features | Closed GitHub issues in range, `CHANGELOG.md` | `feature-candidates.csv` (raw candidates — Phase C curates) |
| Enhanced testing | `tests/testthat/`, `docs/planning/phase8-e2e-harness-subplan.md` | `testing-growth.csv`, `commit-activity-timeline.csv` |
| Claude CLI / methodology | `SESSION_NOTES.md`, `HANDOFFS.md`, `CHANGELOG.md`, `PROJECT_LEARNINGS.md` | `process-metrics.csv`, `self-score-trend.csv` |

### Claim-Evidence Map (Phase A deliverable — one row per intended claim)

| # | Claim | Verified value | Evidence (sha / file / date) |
|---|---|---|---|
| C1 | Module count and total LOC | 10 `R/mod*.R` files; 4,731 lines total incl. `appUI.R`/`appServer.R` | `module-inventory.csv`; `wc -l R/mod*.R R/appUI.R R/appServer.R`, verified 2026-07-09 |
| C2 | Per-module responsibility + size + test coverage | e.g. `modSummaryStats` 921 LOC / 7 test files; `modInput` 716 LOC / 5 test files; `modGvAndBgDesc` 56 LOC / 1 test file (full table: 10 rows) | `module-inventory.csv` |
| C3 | 9-phase vertical-slice migration, Session 22 -> Session 35 (2026-06-03 to 2026-06-06) | Phases 1,2,9 shas directly verified (`596f6bc9`, `ef6a9f4c`, `3db018d1`/`24992e0b`/`53a9e5e0`/`a1618c48`) via `git log -1 <sha>`; Phases 3-7 verified by CHANGELOG session-close-out entry only (no sha quoted in the source plan) | `migration-phases.csv`; `docs/planning/shiny-module-conversion-plan.md` §9; verified 2026-07-09 |
| C4 | Phase 9 (monolith retirement) is the irreversible dragon phase | `runGeneKeepR()` now `lifecycle::deprecate_soft()`-aliases to the modular app; `inst/application/` (17 files) deleted as its own revertible commit | commit `3db018d1`, `24992e0b`; `shiny-module-conversion-plan.md:285` |
| C5 | Phase 8 (E2E harness) was NOT a single-session DONE — it expanded into a 4-session subplan, then a 7-part hardening pass | 8a-8d: Session 31-34 (2026-06-05 to 2026-06-06), issue #39 CLOSED at S34. 8e-1..8e-7: Session 37-50 (2026-06-07 to 2026-06-10), issue #40 | `CHANGELOG.md` 2026-06-05..2026-06-10 entries; `docs/planning/phase8-e2e-harness-subplan.md`; **corrects S330's characterization** ("Phases 1-9 all marked DONE") — Phase 8's DONE is compound, not atomic |
| C6 | 47 GitHub issues closed within the v1.0.8->v2.0.0 window (2025-07-26 to 2026-07-09) | 47 rows, labeled (enhancement/bug/unlabeled), raw curation candidates — not every one is feature-worthy prose (Phase C judgment call) | `feature-candidates.csv`; `gh issue list --state closed --search "closed:2025-07-26..2026-07-09"`, run 2026-07-09 |
| C7 | Test file count grew from v1.0.8 to v2.0.0 | 132 files (v1.0.8, `4548aa1b`) -> 175 (Session 1 start, `6fd87749`, 2026-05-30) -> 257 (v2.0.0, `8ca8bb24`) — a 95% increase over the full range | `testing-growth.csv`; `git ls-tree -r --name-only <sha> -- tests/testthat/`, verified 2026-07-09 |
| C8 | shinytest2/E2E test files existed early but were non-functional until Phase 8 wired them | 25 files already referenced `shinytest2`/`AppDriver` by Session 1 (2026-05-30) — built on the pre-methodology "module branch" (`7da01afe`) but calling undefined helpers ("unwritten theatre"); 32 files by v2.0.0, after Phase 8a-8e made them executable and behavioral | `testing-growth.csv` `shinytest2_referencing_files` column; `docs/planning/phase8-e2e-harness-subplan.md` §2.3/§2.6 |
| C9 | Commit-activity pace across the range | 7 commits (2025-12, pre-methodology) / 2 (2026-04) / 30 (2026-05) / 375 (2026-06, the modularization sprint) / 98 (2026-07, testing hardening + CRAN prep) | `commit-activity-timeline.csv`; `git log --format=%ad --date=format:%Y-%m`, verified 2026-07-09 |
| C10 | 328 SESSION_RUNNER-numbered sessions fall within the range | Session 1 (`6fd87749`, 2026-05-30) through S328 (`8ca8bb24`, 2026-07-09 — the exact v2.0.0 CRAN commit); 502 of the range's 512 commits are session-tagged, 10 predate the methodology | `process-metrics.csv`; direct `git log` verification, this session (also resolves plan §2's flagged gotcha, see above) |
| C11 | 309 `CHANGELOG.md` ledger entries, all within the range | Earliest entry 2026-05-30 (matches Session 1's own start date — the ledger is retroactive, adopted at Session 325 per the file's own "freeze legacy, go forward" note); latest 2026-07-09; zero entries outside `[2025-07-26, 2026-07-09]` | `process-metrics.csv`; `grep -cE "^### [0-9]{4}-[0-9]{2}-[0-9]{2}" CHANGELOG.md`, verified 2026-07-09 — **corrects S330's count of 308** (that snapshot predated S330's own close-out entry landing as #309) |
| C12 | 305 `PROJECT_LEARNINGS.md` entries | `#### Learning 1` through `#### Learning 305` | `process-metrics.csv`; `grep -cE "^#### Learning [0-9]+ " PROJECT_LEARNINGS.md` |
| C13 | Self-score trend — **partial window only, do not overclaim** | 7 complete `HANDOFFS.md` receipts, S324-S330 (2026-07-08/09 only): scores 8,8,8,9,9,9,9 (mean ≈8.57). Receipts began at S324, one session before the CHANGELOG ledger-format resolution (S325) — this covers ~2% of the 328-session range, not a trend across it | `self-score-trend.csv`; F5's own caution in §6 applies directly |
| C14 | Stakeholder-correction rate — "compounding discipline" evidence for Section 4 | Of 271 explicit self-assessment mentions of "N stakeholder correction(s)" across `SESSION_NOTES.md`, 269 (99.3%) report zero; 2 report exactly one | `process-metrics.csv`; `grep -c "0 stakeholder correction" / "[1-9][0-9]* stakeholder correction" SESSION_NOTES.md` — this is a mention-count proxy, not a per-session-verified audit; state that scope limit in Section 4 prose |

**Do not draft any section from the summary table alone.** Each claim above traces to a
frozen CSV or a directly re-verifiable git/grep command — that traceability, not the
one-line summary, is what Phases B-E cite.

**Do not draft any section from the "what this session verified" column alone.** That
column proves the sources exist and gives a rough shape; it is not a substitute for the
per-claim quoted-passage discipline each drafting phase owes.

---

## 4. Proposed document outline

1. **Abstract / TL;DR** (150-250 words, written last, after the body — per workstream
   Phase 3 discipline)
2. **Introduction** — what changed between 1.0.8 and 2.0.0 and why a technical writeup;
   one paragraph situating the four pillars; explicit scope stamp ("as of 2026-07-09").
3. **Section 1 — From Monolith to Modules: the Shiny Architecture Transformation**
   (Phase B, §7)
4. **Section 2 — New Capabilities in 2.0.0** (Phase C, §7)
5. **Section 3 — Testing at Scale** (Phase D, §7)
6. **Section 4 — An AI-Assisted Development Process** (Phase E, §7) — the Claude Code /
   Claude CLI methodology section
7. **Section 5 — By the Numbers** *(optional, cut if redundant — see §2)* — consolidated
   summary table/figure pulling one headline stat from each prior section
8. **Conclusion** — what this means for maintainers/collaborators going forward; NIH
   grant acknowledgment (P51 RR13986, P51 OD011092), matching the acknowledgment already
   present in `CLAUDE.md`/`DESCRIPTION`.
9. **Appendix (optional)** — glossary of methodology artifacts (`SESSION_RUNNER.md`,
   `SAFEGUARDS.md`, `CHANGELOG.md`, `HANDOFFS.md`, `PROJECT_LEARNINGS.md`) for readers
   unfamiliar with the process, one line each — supports Section 4 without bloating it.

---

## 5. Proposed tables

| # | Table | Purpose | Data source | Generation |
|---|---|---|---|---|
| T1 | Release timeline (v1.0.3 -> v1.0.7 -> v1.0.8 -> v2.0.0) with dates and CRAN status | Orient the reader on the time span covered | `CRAN-SUBMISSION` git history + `git tag` (both already mined this session — see §2) | Static markdown table, hand-authored from frozen Phase A data (not live `git` calls in the rendered doc — see §8 reproducibility note) |
| T2 | Shiny module inventory: module, responsibility, LOC, test-file count | Ground "new use of Shiny modules" in concrete structure, not prose assertion | `R/mod*.R` + `tests/testthat/test-mod*` (per-module counts already spot-checked this session) | R chunk reading a frozen Phase A CSV (`data/module-inventory.csv`) into a `kableExtra`/`gt` table |
| T3 | Migration phase summary (the 9 phases): phase, description, risk, session, commit sha, status | This is the single richest existing artifact for Section 1 — reuse, don't re-derive | `docs/planning/shiny-module-conversion-plan.md` §9 (already contains this exact table in prose form) | Reformat the existing plan's §9 content into the article's table; verify each sha still resolves in `git log` before publishing (workstream Phase 6 discipline) |
| T4 | New features/capabilities (feature, first-shipped session, one-line description, evidence ref) | Ground "new features" claim | `CHANGELOG.md` filtered to the 512-commit range, closed GitHub issues | Phase A extraction into a frozen data file; hand-curated selection (not every commit is feature-worthy) |
| T5 | Testing growth: test-file count and (if extractable) coverage, before vs. after, plus e2e/shinytest2 harness status | Ground "enhanced testing" claim quantitatively | `git log --follow` file-count history on `tests/testthat/`; Phase 8 of the module-conversion plan for e2e harness status | Frozen Phase A data -> table |
| T6 | Engineering-process metrics: total sessions in range, commits, CHANGELOG entries, PROJECT_LEARNINGS entries, HANDOFFS receipts, mean self-score, stakeholder-correction rate | The evidentiary core of Section 4 — must be real extraction, not characterization | `SESSION_NOTES.md`, `HANDOFFS.md`, `CHANGELOG.md`, `PROJECT_LEARNINGS.md` | Phase A/E extraction script (checked into `vignettes/articles/data/` or `inst/extdata/`) -> frozen CSV -> table |
| T7 *(optional, Appendix)* | Methodology-artifact glossary (file, one-line purpose) | Onboard readers unfamiliar with the SESSION_RUNNER process | This plan's own §3 evidence-base row descriptions | Hand-authored, no computation |

---

## 6. Proposed graphics / figures

| # | Figure | Purpose | Data source | Generation | Provenance note |
|---|---|---|---|---|---|
| F1 | Commit-activity timeline across the 512-commit range (commits per week or month) | Visualize the pace/duration of the effort | `git log` commit dates, frozen in Phase A | R chunk, `ggplot2` line/bar chart reading the frozen data file | Script checked into version control per workstream Figure Provenance rule; regeneratable, not user-hand-edited |
| F2 | Before/after architecture schematic: monolithic Shiny app vs. modular `mod*.R` + `appUI`/`appServer` structure | Make "new use of Shiny modules" visually concrete for readers who won't read T2/T3 | Conceptual, informed by `docs/planning/shiny-module-conversion-plan.md` §4 ("Current architecture (verified)") and §2 ("Target end state") | Mermaid diagram embedded in the `.qmd` (Quarto renders Mermaid natively) — no external image dependency, diffable in git | Original construction, not computed from data — flag as such per workstream Figure Provenance ("source of the data: original construction") |
| F3 | Test-suite growth over time (test file or test-case count vs. commit date) | Visual companion to T5 | Same `git log --follow` extraction as T5 | R chunk, `ggplot2`, reading the same frozen Phase A data as T5 | One dataset feeding both T5 and F3 avoids a second, possibly-drifting extraction |
| F4 | TDD RED -> GREEN -> REFACTOR cycle diagram, annotated with this project's phase-gate enforcement (`AskUserQuestion` gates) | Give Section 4 readers unfamiliar with strict TDD a concrete mental model before the metrics land | `CLAUDE.md` "Development Process Contract" section (already-authoritative description, no extraction needed) | Mermaid state diagram in the `.qmd` | Original construction from an existing authoritative doc, not computed |
| F5 *(optional)* | Session self-score trend over the 512-commit range (line chart, `HANDOFFS.md` `self_score` field over time) | Show the "compounding discipline" claim empirically rather than asserting it | `HANDOFFS.md` receipts (only cover recent sessions reliably — receipts are a Session-325-era addition, see `CHANGELOG.md`'s "freeze legacy, go forward" note) | R chunk, `ggplot2`, frozen Phase A data | **Caution:** `HANDOFFS.md` receipts don't extend across the full 512-commit range (they started later) — F5 may only be able to cover a partial window; state that limitation in the caption rather than implying full-range coverage (avoid anti-pattern #16 / overclaiming) |
| F6 *(optional)* | Existing `vignettes/shiny_app_use/` screenshots, repurposed to show the running modular app | Ground the architecture discussion in an actual running screenshot, not just diagrams | `vignettes/shiny_app_use/` (pre-existing, referenced by `a3manual.Rmd` per the Quarto-adoption analysis §7.1 slice 4) | Reuse existing images if still current; **do not regenerate/re-screenshot without confirming they're not already hand-curated** (FM #22 / anti-pattern #11) — check with the owner before touching this directory |

**Reproducibility decision (locked for Phase A):** every data-driven table/figure reads
from a **frozen data file checked into version control** (e.g.
`vignettes/articles/data/*.csv`, generated by a checked-in extraction script), not from
live `git`/`gh` calls inside the rendered `.qmd`. Rationale: the workstream's Figure
Provenance rule requires regenerable-from-script reproducibility, but a live `git log`
inside the document would make the "current" numbers silently drift on every future
render (violates anti-pattern #16 the moment someone re-renders the article after S331
lands) and would fail to render at all from a source tarball without the full git
history. Freezing the data as of the v2.0.0 submission commit (`8ca8bb24`) is itself an
explicit, stated scope boundary — exactly the "(as of 2026-07-09)" discipline this plan
already commits to.

---

## 7. Phased session breakdown

Each phase is one session (`SESSION_RUNNER.md` "1 and done"), following the same
per-session-vertical-slice discipline `shiny-module-conversion-plan.md` §9 already used
successfully for this project's largest prior migration. No phase may be bundled with
another (FM #26) except where explicitly marked mergeable below.

### Phase A — Build and freeze the evidence base · risk MEDIUM (foundational — see dragon flag, §9) · ✅ DONE (Session 331, commit pending)

> **✅ Implemented in Session 331 (2026-07-09), whole phase, no split.** One checked-in
> R extraction script (`vignettes/articles/data-raw/build-document1-evidence.R`) shells
> out to `git`/`gh` and parses `CHANGELOG.md`/`PROJECT_LEARNINGS.md`/`HANDOFFS.md`,
> writing 7 frozen CSVs to `vignettes/articles/data/`: `module-inventory.csv`,
> `migration-phases.csv`, `feature-candidates.csv` (47 closed-issue raw candidates),
> `testing-growth.csv`, `commit-activity-timeline.csv`, `process-metrics.csv`,
> `self-score-trend.csv`. Completed the §3 Claim-Evidence Map (14 rows, C1-C14) in
> place. **Resolved the §2 first-session-number gotcha** with hard evidence: Session 1
> begins at `6fd87749` (2026-05-30), squarely inside the ratified range, correcting the
> prior session's "methodology predates v1.0.8" assumption. **Two corrections to
> S330's characterizations surfaced by firsthand verification (not carried forward
> uncritically):** (1) Phase 8 of the module-conversion plan was NOT a simple
> session-22-style DONE — it expanded into a 4-session subplan (8a-8d, Session 31-34,
> issue #39) then a 7-part hardening pass (8e-1..8e-7, Session 37-50, issue #40); (2)
> the CHANGELOG entry count is 309, not S330's snapshot of 308 (S330's own close-out
> entry landed as #309 after that count was taken — not an error, a timing artifact).
> Spot-checked 12 extracted numbers by hand against raw `git log`/`CHANGELOG.md`/
> `PROJECT_LEARNINGS.md`/`HANDOFFS.md` — all 12 confirmed exactly. **Next: Phase B**
> (owner confirms scope/order first — Phases B-E are reorderable per §7's own note).
**What DONE looks like:** one or more checked-in data files (e.g.
`vignettes/articles/data/{module-inventory,features,testing-growth,process-metrics}.csv`)
plus the checked-in extraction script(s) that produced them; a completed Claim-Evidence
Map (this plan's §3 table, filled in with real dated/sha-anchored rows, one per intended
claim) as a working doc (can live in the same `docs/planning/` file or a companion).
**Verification:** spot-check ~10 extracted numbers by hand against raw `git log`/
`CHANGELOG.md`/`HANDOFFS.md` (the workstream's "verified quoted passage" discipline,
adapted); resolve the exact first-session-number question flagged in §2.
**Session boundary:** this phase produces data files and the claim map only — no
`.qmd` prose yet.

### Phase B — Draft Section 1 (Shiny modules) + T2, T3, F1, F2
**What DONE looks like:** `.qmd` section drafted, T2/T3 tables rendering from Phase A
data, F1/F2 figures rendering, section-level claim-source map complete (every claim in
this section has a quoted/verified backing per §3's discipline).
**Verification:** `quarto render` on the article in isolation; all figures/tables
present; no unresolved claims.

### Phase C — Draft Section 2 (new features) + T4
**What DONE looks like:** section drafted, T4 populated and curated (not every commit —
genuinely feature-shaped items only), claims sourced to `CHANGELOG.md`/issue numbers.
**Verification:** same as Phase B.

### Phase D — Draft Section 3 (testing) + T5, F3
**What DONE looks like:** section drafted, before/after testing claims quantified and
sourced, e2e/shinytest2 harness status accurately described (cross-check against Phase 8
of the module-conversion plan, which may still show open items — do not overclaim
completeness there).
**Verification:** same as Phase B.

### Phase E — Draft Section 4 (Claude CLI / methodology) + T6, F4, F5 · risk HIGH 🐉 (see §9)
**What DONE looks like:** section drafted with T6 fully populated from real extraction
(not characterization), F4/F5 rendering, tone calibrated to this being a public,
domain-expert-and-CRAN-reviewer-facing description of an AI-assisted process — factual
and quantified, matching this project's own established transparent voice (self-scores,
stakeholder-correction counts, and documented mistakes already appear routinely in
`CHANGELOG.md`/`HANDOFFS.md` — the article should reflect that same candor, not a
promotional gloss).
**Verification:** same as Phase B, plus a re-read of `PROJECT_LEARNINGS.md`'s own
framing to confirm the section doesn't contradict the project's documented failure
modes / corrections.

### Phase F — Assemble, consolidate, verify, publish · risk MEDIUM (irreversible-ish: public visibility)
**What DONE looks like:** Abstract, Introduction, optional Section 5, Conclusion
drafted; full-document claim audit (workstream Phase 6 — every numeric/dated claim
re-checked); complete render verification per the S107-110 pattern: `quarto render` +
`pkgdown::build_article()` + `R CMD build` tarball check (confirm the article still
ships nothing to CRAN); spot-check the four existing articles still render (workstream
Phase 6 "spot-check 2-3 unmodified sections" rule, applied at the article-set level);
cleanup of any search/extraction artifacts.
**Verification:** the full Verification Checklist, §10.
**Session boundary:** this is the publish gate — the article should not be considered
public-ready until this phase's checklist is green.

**Phases B-E may be reordered** (there is no hard dependency among Sections 1-4) but
Phase A must come first (everything reads its frozen data) and Phase F must come last
(it assembles and verifies the whole).

---

## 8. Toolchain / mechanics reference (Adaptation Notes, Quarto row)

Per `RESEARCH_DOCUMENTATION_WORKSTREAM.md`'s toolchain matrix, substituted for this
project's actual mechanics:

| Concept | This project's equivalent |
|---|---|
| Source file | `vignettes/articles/engineering-the-2.0.0-release.qmd` |
| "Bibliography" | None (no `.bib`) — claims cite commit shas / `CHANGELOG.md` dates / frozen data files instead |
| Render command | `quarto render vignettes/articles/engineering-the-2.0.0-release.qmd` (matches S107-110); also verify via `pkgdown::build_article("articles/engineering-the-2.0.0-release")` |
| "Citation key" check | N/A — substitute: every numeric/dated claim in prose must trace to a row in the Phase A claim-evidence map |
| Cross-reference check | Quarto `?@fig-x`/`?@tbl-x` unresolved-ref check in rendered output, same as any Quarto doc |
| Figure script | R chunks in the `.qmd` itself, reading frozen CSVs from `vignettes/articles/data/` |
| CRAN-risk check | `R CMD build .` + `tar tzf` (confirm `vignettes/articles/` and its `data/` subfolder do not ship) — same command already used for the four prior articles and for the `.Rbuildignore` fix in S327 |

---

## 9. Dragons (Learning #3 — not all phases are equally risky)

1. **Phase A is load-bearing for everything downstream.** Every table and figure in
   Sections 1-4 reads Phase A's frozen data. An error here (a miscounted commit range, a
   wrong sha, a session-number off-by-one) silently propagates into every later phase
   and is far more expensive to catch in Phase F than in Phase A. Spot-check generously.
2. **Phase E is the highest-scrutiny section in the document.** It is describing
   AI-agent-driven development, publicly, to an audience that includes CRAN reviewers
   and domain-expert researchers who may be skeptical of the practice. Overclaiming (or
   underclaiming — hiding the documented corrections/mistakes this project's own
   `PROJECT_LEARNINGS.md` is full of) both damage credibility. The existing project
   voice (self-scores, correction counts, named anti-patterns) is already calibrated for
   exactly this kind of candor — match it, don't invent a more marketing-forward tone.
3. **Phase F publishes to a public URL.** Unlike an internal report, this is not fully
   reversible in practice (search engines, cached copies, readers who already saw a
   draft state) even though the underlying `.qmd` is a normal, revertible git file.
   Treat Phase F's checklist as a real gate, not a formality.
4. **The commit-range boundary itself may need owner ratification.** This plan chose
   "CRAN-submission-commit to CRAN-submission-commit" (§2) as the scope boundary because
   it is the one unambiguous, machine-verifiable pair of endpoints. An alternative frame
   (e.g., "since the last major version bump," or "since the CHANGELOG ledger format was
   adopted in Session 325") would tell a different story. Flag this framing choice to the owner
   at Phase B kickoff — it is a scope decision, not purely mechanical.

---

## 10. Verification Checklist (adapted from the workstream, Quarto row)

Before Phase F closes:

- [ ] Every numeric, dated, or attributed claim in the article traces to a row in the
      Phase A claim-evidence map (commit sha, CHANGELOG date, or frozen data file)
- [ ] No claim uses present-relative dating ("currently," "as of now") without an
      explicit "(as of 2026-07-09)"-style stamp (anti-pattern #16)
- [ ] Every figure/table has stated provenance (frozen data file + generating script, or
      "original construction" for schematics)
- [ ] `quarto render` succeeds with no warnings; no unresolved `?@fig-x`/`?@tbl-x`
- [ ] `pkgdown::build_article()` succeeds
- [ ] `R CMD build .` + `tar tzf` confirms `vignettes/articles/engineering-the-2.0.0-release.qmd`
      and its `data/` subfolder do not ship (zero CRAN risk, matching S107-110)
- [ ] The four existing `vignettes/articles/*.qmd` still render (spot-check, workstream
      Phase 6 discipline)
- [ ] No search/extraction artifacts left in `vignettes/articles/data/` or elsewhere
- [ ] Section 4's tone re-read against `PROJECT_LEARNINGS.md`'s own established voice —
      candid, not promotional (dragon #2)
- [ ] Screenshot reuse (F6, if used) confirmed with the owner before any regeneration

---

## 11. Planning Session Checklist (`SESSION_RUNNER.md`)

- [x] Plan document written with file paths and (where applicable) line numbers /
      commit shas
- [x] Evidence gathered directly this session for every content pillar (§3) rather than
      assumed from memory — `shiny-module-conversion-plan.md` read in full;
      `R/mod*.R`, `tests/testthat/`, `CHANGELOG.md`, `PROJECT_LEARNINGS.md`,
      `HANDOFFS.md` counts verified via direct commands, not recalled
- [x] Commit-range scope boundary evidence-verified (`CRAN-SUBMISSION` git history),
      not assumed from the owner's "1.0.8 to 2.0.0" phrasing alone
- [x] Each phase (§7) has explicit completion criteria, verification commands, and a
      stated session boundary
- [x] Each phase marked as a separate session with a STOP point; no phase pre-bundles
      into another
- [ ] Deepest available reasoning mode set at session start — **not confirmed**; this
      session ran at whatever effort level the harness resolved by default. Flag for the
      owner: if a deeper mode is available, Phase A (foundational, dragon #1) and Phase E
      (highest-scrutiny, dragon #2) are where it would matter most.
- [ ] Close-out: evaluate predecessor, self-assess, write the `HANDOFFS.md` receipt,
      record the `CHANGELOG.md` ledger entry, commit, STOP — pending, this session's
      Phase 3 (imminent, not yet done as of this plan's drafting).

---

## 12. Open decisions for the owner (not blocking plan approval, but not silently assumed either)

1. **Article title/slug** (§1) — proposed, not locked.
2. **Section 5 ("By the Numbers")** — keep, or cut as redundant with Sections 1-4?
   Recommendation: draft it in Phase F only if Sections 1-4's individual tables don't
   already give a reader a quick-scan summary; do not treat it as mandatory.
3. **F6 (screenshot reuse)** — needs explicit owner confirmation before Phase D/E touch
   `vignettes/shiny_app_use/` (dragon-adjacent per FM #22).
4. **Commit-range framing** (dragon #4) — ratify "CRAN-submission-to-CRAN-submission" as
   the scope boundary, or prefer a different one, at Phase B kickoff.
