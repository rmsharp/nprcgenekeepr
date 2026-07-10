# Plan — Document 2: Purpose, Approach, and a Colony Manager's Guide to Practice
(public Quarto pkgdown article)

**Status:** Plan written Session 345 (DRAFT). Owner confirmed article form (new
`vignettes/articles/*.qmd`, not a README rewrite or external paper) and audience
(primate-center bioinformatics / colony managers) via `AskUserQuestion`, Session 345
(2026-07-10). Owner then confirmed the content strategy — **port and modernize
`ColonyManagerTutorial.Rmd`** rather than draft from scratch — via a second
`AskUserQuestion`, Session 345 (2026-07-10), after this session's research surfaced
that the target content already exists in two places (§1). **No phase has been
executed yet; this plan is not yet ratified end-to-end (§12 has open decisions).**

**Workstream:** Adapted `docs/methodology/workstreams/RESEARCH_DOCUMENTATION_WORKSTREAM.md`
(Phases 2/3/4/6), matching Document 1's own adaptation
(`docs/planning/v2-transformation-article-plan.md`) — substituting this project's own
artifacts (source tree, existing vignettes, `NAMESPACE`, live app structure) for the
workstream's external-bibliography model. Unlike Document 1, this document's claims are
almost entirely about **current static package structure and existing prose**, not a
historical commit range — see §5's reproducibility note for how that changes the
evidence-base approach.

**Companion documents (explicitly not re-scoped here):** Document 1
(`vignettes/articles/engineering-the-2.0.0-release.qmd`, DONE) is the engineering/process
narrative. The six existing feature articles
(`age-sex-pyramid.qmd`, `breeding-group-formation.qmd`, `fg-se-validation.qmd`,
`genetic-value-analysis.qmd`, `offline-focal-animal-workflow.qmd`,
`studbook-quality-control.qmd`) remain the feature-depth references this article points
to rather than duplicates.

---

## 1. Context and a load-bearing discovery

`BACKLOG.md` describes Document 2 as: "package purpose, how it addresses that purpose,
and how to put it into use." Explicitly deferred out of Document 1's plan (S330) to its
own future planning session per the owner's 2026-07-09 instruction; named as a next step
in five straight handoffs (S336, S339, S341, S343, S344) and never picked up until this
session.

**Before drafting anything, this session surveyed what documentation already exists**
(per the "check process history before re-running work" discipline) and found that the
content Document 2 is meant to cover is **not greenfield** — it already exists, in two
different places, in two different states of completeness and visibility:

1. **`vignettes/a3manual.Rmd` + `vignettes/manual_components/*.Rmd`** (13 child files) —
   a CRAN-shipped manual (not `.Rbuildignore`d), actively maintained (edits as recent as
   2026-07-08, two days before this session — `git log -1 -- vignettes/manual_components/`).
   Its `_introduction.Rmd` and `_summary_of_major_functions.Rmd` components are the
   **same source files** `README.Rmd` builds from (`README.Rmd:32-44` `child=`s the
   identical paths) — README and this manual already share one source of truth for
   *purpose* and *approach*. Beyond that shared core, the manual adds real per-feature
   usage sections (`_input.Rmd`, `_pedigree_browser.Rmd`, `_genetic_value_analysis.Rmd`,
   `_summary_statistics.Rmd`, `_breeding_group_formation.Rmd`, `_gv_and_bg_desc.Rmd`,
   `_orip_reporting.Rmd`) plus two algorithm appendices
   (`_breeding_group_algorithm.Rmd`, `_genome_uniqueness_algorithm.Rmd`) and
   `_software_development.Rmd`.
2. **`vignettes/ColonyManagerTutorial.Rmd`** (748 lines) — a screenshot-illustrated,
   step-by-step tutorial literally titled *"GeneKeepR: A Colony Manager's Tutorial"* —
   the exact audience confirmed for Document 2. Covers: Introduction, Installation,
   Uploading a Pedigree File, Pedigree Browser (incl. Unknown IDs, focal-animal
   selection/trimming), Pedigree Age Plot, Genetic Value Analysis, Summary Statistics,
   Breeding Group Formation. **Excluded from the CRAN build**
   (`.Rbuildignore:31`, `^vignettes/ColonyManagerTutorial\.Rmd$`) and not part of the
   public `vignettes/articles/` set either — so despite being actively kept in sync with
   API changes (`git log`: last touched 2026-07-07, migrating `minParentAge` references
   to `minSireAge`/`minDamAge` per issue #119 — the prose at L171-181 explicitly notes
   the current split-field UI while acknowledging the *screenshot* still shows the old
   single-field layout), **it is currently invisible to any reader.**
   Its screenshots (`vignettes/shiny_app_use/*.png`) were last regenerated 2024-12-16
   (`git log -1 -- vignettes/shiny_app_use/`) — **before** the Shiny-module migration
   (Session 22-35, 2026-06-03 to 2026-06-06) — so republishing as-is would show a UI that
   no longer exists.

**Owner-ratified conclusion (this session):** Document 2's plan targets **porting and
modernizing `ColonyManagerTutorial.Rmd`** into a new `vignettes/articles/*.qmd`, using it
(and the shared `_introduction.Rmd`/`_summary_of_major_functions.Rmd` purpose/approach
content) as **primary source material to adapt and re-verify**, not a blank page to
draft from scratch. This closes the "good content, not public" gap directly, and
directly satisfies all three parts of `BACKLOG.md`'s framing (purpose / approach /
usage) using material that already exists and is already mostly accurate.

### A separate, smaller finding (flagged, not fixed here)

`inst/_pkgdown.yml`'s curated Reference-page grouping ("Data objects" / "Major Features
and Functions" / "Primary interactive functions" / "All exposed functions") is **dead
configuration** — confirmed this session via `pkgdown:::pkgdown_config_path`
(`asNamespace("pkgdown")$pkgdown_config_path`), which resolves the **first existing**
file from `_pkgdown.yml`, `_pkgdown.yaml`, `pkgdown/_pkgdown.yml`,
`pkgdown/_pkgdown.yaml`, `inst/_pkgdown.yml`, `inst/_pkgdown.yaml` in that order; the
project's root `_pkgdown.yml` exists (and has no `reference:` key), so
`inst/_pkgdown.yml` is never reached. Confirmed live on the deployed site
(`https://rmsharp.github.io/nprcgenekeepr/reference/index.html`, fetched this session):
a single flat "All functions" alphabetical list, not the grouped structure
`README.md:86-94` describes. Independently, `inst/_pkgdown.yml`'s own lists have drifted
from `NAMESPACE`: of 182 current exports, 64 are absent from its "All exposed functions"
list (incl. every `mod*Server`/`mod*UI` pair, `appServer`/`appUI`, `runModularApp`, and
newer functions like `getPotentialParents`, `applyKinshipOverrides`,
`setLabKeyDefaults`) — yet `git log` shows this file has been genuinely, actively
maintained (S161, S171, S205, S285, S300), so it is shadowed *and* independently stale,
not abandoned.

This matters to Document 2 because the natural next step for a reader after this article
is "browse the Reference page" — citing the intended grouped structure as live would be
a claim-source-audit failure baked into the article at birth. **Not fixed in this
session** — out of this session's declared scope (planning Document 2, not fixing
pkgdown config). Recorded as a new `BACKLOG.md` item at close-out. Document 2's own
drafting phase must re-verify the Reference page's live state at draft time (§9 dragon
5) rather than assume either the stale grouped structure or today's flat list.

---

## 2. Scope decisions (owner-confirmed this session)

- **Article form: new standalone public `vignettes/articles/*.qmd`** (`AskUserQuestion`,
  2026-07-10) — not a README rewrite, not an external software paper. Same pkgdown
  pattern as Document 1 and the six existing feature articles
  (`docs/planning/quarto-documentation-future-proofing-analysis.md` §6-7, S105 — format
  already decided, not reopened here).
- **Audience: primate-center bioinformatics / colony managers evaluating or learning to
  use the package** (`AskUserQuestion`, 2026-07-10) — matches `ColonyManagerTutorial.Rmd`'s
  own stated audience and Document 1's domain-expert framing.
- **Content strategy: port and modernize `ColonyManagerTutorial.Rmd`**
  (`AskUserQuestion`, 2026-07-10, after this session's research — §1) — treat it (plus
  the shared `_introduction.Rmd`/`_summary_of_major_functions.Rmd` components) as primary
  source to adapt, not draft from scratch. Screenshots need regeneration against the
  current modular app (§9 dragon 1); prose needs re-verification against current package
  behavior, not carried forward uncritically (§9 dragon 2); coverage should extend to
  tabs added since the tutorial was last substantively written (§9 dragon 3, §12
  decision 1).
- **Toolchain: Quarto**, not an open decision (§1, matching Document 1 §1).
- **Reproducibility model differs from Document 1.** Document 1's claims spanned a
  historical commit range and needed frozen data files to prevent silent drift on
  re-render. Document 2's claims are almost entirely about **current static package
  structure** (tab list, export counts, article inventory) with no time-series element,
  so each claim's evidence is a directly re-runnable command (`grep`, `wc -l`,
  `NAMESPACE` inspection, live app inspection), date-stamped "(as of 2026-07-10)" per
  anti-pattern #16, rather than frozen into a CSV. **Exception:** any numeric claim
  carried over from `ColonyManagerTutorial.Rmd` that depends on the specific contents of
  the example pedigree used (row counts, living-animal counts, computation timings — §9
  dragon 2) must be **re-derived from the current example data**, not copied from the
  2019-2020-era tutorial text.

---

## 3. Evidence base (what this session verified directly)

| # | Claim | Verified value | Evidence |
|---|---|---|---|
| E1 | `vignettes/a3manual.Rmd` composes 13 child files from `vignettes/manual_components/` | Confirmed by direct read of `a3manual.Rmd` (57 lines, all `{r child=...}` includes) | `vignettes/a3manual.Rmd:29-56`, verified 2026-07-10 |
| E2 | `README.Rmd` and `a3manual.Rmd` share `_introduction.Rmd` and `_summary_of_major_functions.Rmd` as a single source | Both files `child=` the identical paths | `README.Rmd:32,43`; `vignettes/a3manual.Rmd:29-31` (via `manual_components/_summary_of_major_functions.Rmd`), verified 2026-07-10 |
| E3 | `manual_components/*.Rmd` actively maintained | Most recent touch 2026-07-08 (`_breeding_group_algorithm.Rmd`, `_genome_uniqueness_algorithm.Rmd`); others 2026-06-19 to 2026-07-07 | `git log -1 --format=%ad --date=short -- vignettes/manual_components/`, verified 2026-07-10 |
| E4 | `ColonyManagerTutorial.Rmd` is 748 lines, excluded from CRAN build, actively maintained | File read in full this session; `.Rbuildignore:31`; last touch 2026-07-07 (issue #119 slice 5 minParentAge migration) | `vignettes/ColonyManagerTutorial.Rmd` (full read); `.Rbuildignore`; `git log`, verified 2026-07-10 |
| E5 | `ColonyManagerTutorial.Rmd`'s prose is partially, not fully, current — e.g. it explicitly documents the current Minimum Sire/Dam Age split fields while noting the referenced screenshot still shows the old single-field layout | Direct read | `vignettes/ColonyManagerTutorial.Rmd:171-181`, verified 2026-07-10 |
| E6 | `vignettes/shiny_app_use/*.png` screenshots predate the Shiny-module migration | Last touch 2024-12-16, vs. migration Session 22-35 (2026-06-03 to 2026-06-06) | `git log -1 --format=%ad -- vignettes/shiny_app_use/`, verified 2026-07-10; migration dates per `docs/planning/v2-transformation-article-plan.md` §7 Phase B closure note |
| E7 | The current modular app mounts 10 tabs unconditionally plus 1 conditional (ORIP, ONPRC-only), grouped under a "More" menu for Settings/About/Help | Direct read of `R/appUI.R` tab structure | `R/appUI.R:137-260`, verified 2026-07-10 |
| E8 | `ColonyManagerTutorial.Rmd` covers 6 of those 10-11 tabs (Input, Pedigree Browser, Age-Sex Pyramid ["Pedigree Age Plot"], Genetic Value Analysis, Summary Statistics, Breeding Groups); it predates and does not cover Genetic Diversity (#112), Potential Parents (#48), the GV & BG Description tab, or Settings/About/Help | Cross-referenced E4's full read against E7's tab list | Direct comparison, verified 2026-07-10 |
| E9 | 182 exported functions in `NAMESPACE`; `inst/_pkgdown.yml`'s "Primary interactive functions" list names 58, its "All exposed functions" list names 159 (64 short of 182) | `grep -c "^export(" NAMESPACE` = 182; per-section `grep -c "^  - "` on `inst/_pkgdown.yml`; `comm -23` diff of sorted export lists | Verified 2026-07-10 (commands in this session's transcript) |
| E10 | `inst/_pkgdown.yml`'s reference grouping is dead configuration, shadowed by root `_pkgdown.yml`, confirmed live on the deployed site | `pkgdown:::pkgdown_config_path` inspected directly; live site fetched and confirmed flat "All functions" list only | Verified 2026-07-10 — see §1 sub-section |
| E11 | Issue #37 ("Exported functions not currently used by app") documents 127/182 exports reached by the app, 39 not, "by repeated owner decision... intended public API, not dead code" except one lone conditional-retire candidate (`safeExecute`) | `gh issue view 37 --json body` | Verified 2026-07-10 — informs the "two usage modes" framing (§4) without overclaiming API completeness |
| E12 | Six existing feature articles already exist and cover per-feature depth | `ls vignettes/articles/*.qmd` | Verified 2026-07-10 |

**Do not draft any section from this table's summary column alone** — each row points
to a re-runnable command or a specific file:line; the drafting session re-verifies
firsthand, matching Document 1's own claim-source discipline (its plan §3, "Do not draft
any section from the summary table alone").

---

## 4. Proposed document outline

1. **Abstract / TL;DR** (100-200 words — shorter than Document 1's, since this document
   is more a practical guide than a synthesis argument; written last)
2. **Introduction** — what this article is and who it's for; how it relates to Document
   1 (process/engineering) and the six feature articles (depth); explicit scope stamp
   ("as of 2026-07-10")
3. **Section 1 — Purpose: Why nprcgenekeepr Exists** — adapted from
   `manual_components/_introduction.Rmd` / `README.Rmd`'s shared source: the captive
   colony genetic-diversity management problem, the Vinson & Raboin (2015) methodology,
   the NIH grant acknowledgment
4. **Section 2 — Approach: The Five Function Groups and Two Ways to Use Them** — adapted
   from `_summary_of_major_functions.Rmd`; the five function groups (QC, pedigree
   creation, age-sex pyramid, GVA, breeding groups) mapped to the current app's tabs
   (E7/E8) and to the six existing feature articles (T1); the Shiny-app-vs-R-API framing
   informed by E9/E11 (stated carefully — "additional public API for specialized
   workflows," matching the project's own established framing, not "39 broken/unused
   functions")
5. **Section 3 — Practice: A Colony Manager's Walkthrough** (the bulk of the article,
   ported/modernized from `ColonyManagerTutorial.Rmd`) — Installation, Uploading a
   Pedigree, Pedigree Browser (incl. focal-animal selection), Age-Sex Pyramid, Genetic
   Value Analysis, Summary Statistics, Breeding Group Formation, plus **new subsections**
   for Genetic Diversity and Potential Parents (not in the source tutorial — §9 dragon 3,
   §12 decision 1)
6. **Conclusion** — pointers to the six feature articles for depth, to Document 1 for the
   engineering story, to the GitHub issue tracker for questions/bugs (matching
   `ColonyManagerTutorial.Rmd`'s own existing framing at L35-38), NIH grant
   acknowledgment

---

## 5. Proposed tables and figures

| # | Item | Purpose | Source | Generation |
|---|---|---|---|---|
| T1 | Function-group -> tab -> companion-article map (5 rows) | Orient the reader: which tab does which job, and where to read more | E7, E8, E12 | Hand-authored markdown table from verified current structure |
| T2 *(optional)* | API surface snapshot: Data objects / Primary interactive / All exposed counts, with the "as of 2026-07-10" stamp and a one-line pointer to issue #37's framing | Grounds the "two usage modes" claim without overclaiming | E9, E11 | Hand-authored, small — not worth a computed table for 3 numbers |
| F1 | Pipeline diagram: Studbook -> QC -> Pedigree -> {Age-Sex Pyramid, Genetic Value Analysis} -> Breeding Groups | Visual companion to Section 2, orients the walkthrough in Section 3 | Original construction from E7/T1 | Mermaid flowchart embedded in the `.qmd` (matches Document 1 F2's approach — no external image dependency) |
| Screenshots | Regenerated per-tab screenshots for every tab covered by Section 3 | The walkthrough's core illustrative material | Live modular app + example pedigree data | **Method to decide at Phase A kickoff (§9 dragon 1, §12 decision 2):** `shinytest2::AppDriver$get_screenshot()` driven by a checked-in script (reproducible, matches this project's existing E2E infrastructure) vs. manual capture. Either way, the generating script or manual-capture note must be checked into version control per the workstream's Figure Provenance rule. |

No frozen CSV data files are needed (§2's reproducibility note) — this article has no
historical time-series claims.

---

## 6. Phased session breakdown

Each phase is one session (`SESSION_RUNNER.md` "1 and done"). No phase may be bundled
with another (FM #26).

### Phase A — Finalize scope, gap inventory, and screenshot method · risk MEDIUM (foundational)

**What DONE looks like:** (1) `AskUserQuestion` at kickoff resolving §12 decisions 1-2
(tab coverage extent, screenshot-regeneration method) and confirming the proposed
title/slug; (2) a completed gap inventory — for every screenshot in
`vignettes/shiny_app_use/` referenced by `ColonyManagerTutorial.Rmd`, a stated
disposition (regenerate as-is / regenerate with updated framing / retire because the UI
element no longer exists); (3) for every numeric claim in `ColonyManagerTutorial.Rmd`
tied to example-data specifics (row counts, living-animal counts, timing claims), a
re-derived current value or an explicit "not re-verifiable, remove" verdict.
**Verification:** the gap inventory and re-derived numbers are the artifact — no render
yet.
**Session boundary:** produces the inventory and decisions only; no `.qmd` prose, no
screenshots yet.

### Phase B — Regenerate screenshots · risk HIGH 🐉 (see §9 dragon 1)

**What DONE looks like:** a checked-in, regeneratable capture script (or a documented
manual-capture procedure, per Phase A's method decision) produces current-UI screenshots
for every tab Section 3 will cover, driven against the current modular app and a stated
example dataset; old screenshots' disposition (replace in place vs. new dated files)
resolved per Phase A's inventory.
**Verification:** each new screenshot visually spot-checked against the live app
(matching Document 1's Learning 311 precedent — a rendering defect invisible to
`quarto render`/exit-code-0 was only caught by inspecting the actual image).
**Session boundary:** screenshots only — no article prose yet.

### Phase C — Port and draft Sections 1-3 · risk MEDIUM (highest claim-density phase)

**What DONE looks like:** `vignettes/articles/<slug>.qmd` created with Sections 1-2
(adapted from `_introduction.Rmd`/`_summary_of_major_functions.Rmd`, T1, F1) and Section
3 (ported/modernized from `ColonyManagerTutorial.Rmd` using Phase B's screenshots, plus
new Genetic Diversity and Potential Parents subsections per Phase A's coverage
decision); every carried-forward numeric claim traces to Phase A's re-derivation, not
the original tutorial text.
**Verification:** `quarto render` on the article in isolation; every claim in Section 3
either matches Phase A's re-derived value or is flagged for the Phase D audit.

### Phase D — Assemble, verify, decide `ColonyManagerTutorial.Rmd`'s fate, publish · risk MEDIUM (irreversible-ish: public visibility, see §9 dragon 4)

**What DONE looks like:** Abstract, Introduction, Conclusion drafted; full claim-source
audit (workstream Phase 6) over the whole article; complete render verification matching
the S107-110 / Document-1 pattern (`quarto render` + `pkgdown::build_article()` +
`R CMD build .` + `tar tzf` tarball check confirming zero CRAN risk); spot-check 2-3
unmodified existing articles still render; `AskUserQuestion` resolving §12 decision 3
(retire/redirect `ColonyManagerTutorial.Rmd` now that its content is public, or keep both
— avoiding anti-pattern #14 companion-paper drift either way); cleanup of render
artifacts before staging.
**Verification:** the full Verification Checklist, §10.
**Session boundary:** this is the publish gate — the article should not be considered
public-ready until this phase's checklist is green.

---

## 7. Toolchain / mechanics reference

Same as Document 1's plan §8 (`docs/planning/v2-transformation-article-plan.md`) —
Quarto, no `.bib`, `quarto render` + `pkgdown::build_article()` + `R CMD build .` /
`tar tzf` for the CRAN-risk check. Not restated in full here; see that plan for the
per-concept table. One addition: **screenshot regeneration**, which Document 1 did not
need — `shinytest2::AppDriver` (already a `Suggests` dependency, already used by this
project's E2E test tier) is the recommended mechanism if Phase A selects automated
capture (§5, §9 dragon 1).

---

## 8. Dragons (Learning #3 — not all phases are equally risky)

1. **Screenshot regeneration (Phase B) is the highest-risk phase.** The existing
   screenshots are hand-cropped to specific UI regions (e.g., three separate crops of
   one opening screen: top/middle/bottom; a red-oval annotation highlighting one field).
   `shinytest2::AppDriver$get_screenshot()` captures full-viewport or full-element
   screenshots, not curated crops or annotations — achieving equivalent illustrative
   framing may need a post-processing step (crop/annotate) that doesn't currently exist
   in this project's toolchain. Resolve the method at Phase A kickoff, not mid-Phase-B.
2. **Numeric claims tied to the specific example pedigree are a claim-source-audit
   trap.** `ColonyManagerTutorial.Rmd`'s row counts ("3,694 rows... reduces to 2,322"),
   living-animal counts ("332 living animals"), and computation-timing claims ("1 minute
   38 seconds... MacBook Pro (Mid 2014)") are all specific to the exact example data and
   hardware used when the tutorial was written (2019-2020). Carrying these forward
   uncritically would repeat Document 1's own corrected mistake pattern (its Phase F
   audit found real mismatches from trusting prior text) — Phase A must re-derive every
   one against current example data, not copy them.
3. **Coverage-extent scope creep risk.** The current app has 2 tabs
   (Genetic Diversity #112, Potential Parents #48) the source tutorial never covered,
   because they postdate it. Writing genuinely new content for these (not a port) is a
   different kind of work than modernizing existing prose — the temptation is to either
   silently skip them (leaving the article incomplete relative to the current app) or to
   let their drafting balloon Phase C into two capabilities bundled as one (FM #26).
   Resolve the coverage decision explicitly at Phase A kickoff (§12 decision 1); if both
   new tabs are in scope, budget Phase C accordingly rather than discovering the overrun
   mid-session.
4. **Phase D publishes to a public URL** — same caution as Document 1's plan §9 dragon
   3: not fully reversible in practice even though the underlying file is a normal git
   file.
5. **The pkgdown Reference-page staleness (§1) is a live trap regardless of this
   article's own drafting quality.** If Section 2 or the Conclusion points readers to
   "the Reference page's grouped sections," that claim must be re-verified fresh at
   Phase C/D draft time (fetch the live site), not assumed from README's current (also
   stale) description or from this plan's snapshot. Whether the underlying pkgdown
   config gets fixed before or after this article ships is an independent decision
   (§12 decision 4) — the article's own claim must be correct regardless of that
   decision's timing.

---

## 9. Verification Checklist (adapted from the workstream, Quarto row)

Before Phase D closes:

- [ ] Every numeric or dated claim in the article traces to a re-derived-this-session
      value (Phase A) or an original-construction figure, not carried forward
      uncritically from `ColonyManagerTutorial.Rmd`
- [ ] No claim uses present-relative dating without an explicit "(as of 2026-07-10)"
      (or later drafting-session date)-style stamp
- [ ] Every figure/screenshot has stated provenance (capture script + date, or
      "original construction" for the Mermaid diagram)
- [ ] `quarto render` succeeds with no warnings; no unresolved `?@fig-x`/`?@tbl-x`
- [ ] `pkgdown::build_article()` succeeds
- [ ] `R CMD build .` + `tar tzf` confirms the new article and any new data/screenshot
      subfolder do not ship (zero CRAN risk, matching S107-110 and Document 1)
- [ ] The six existing `vignettes/articles/*.qmd` plus Document 1 still render
      (spot-check, workstream Phase 6 discipline)
- [ ] No search/extraction artifacts left anywhere touched this session
- [ ] The article does not cite the pkgdown Reference page's grouped structure unless
      independently re-verified live at draft time (§8 dragon 5)
- [ ] `ColonyManagerTutorial.Rmd`'s fate (§12 decision 3) is resolved, not left
      ambiguous — either explicitly retired/redirected or explicitly kept with a stated
      reason

---

## 10. Planning Session Checklist (`SESSION_RUNNER.md`)

- [x] Plan document written with file paths and line numbers
- [x] Evidence gathered directly this session for every claim in §1/§3 — `a3manual.Rmd`,
      `manual_components/*.Rmd`, `ColonyManagerTutorial.Rmd` (full read), `README.Rmd`,
      `R/appUI.R`, `NAMESPACE`, `inst/_pkgdown.yml`, the live pkgdown site, and issue #37
      all read or queried directly this session, not assumed from memory
- [x] A genuine pre-drafting scope discovery (§1) was surfaced to the owner via
      `AskUserQuestion` rather than silently assumed or silently ignored — this is the
      load-bearing decision of this planning session
- [x] Each phase (§6) has explicit completion criteria, verification commands, and a
      stated session boundary
- [x] Each phase marked as a separate session with a STOP point; no phase pre-bundles
      into another
- [ ] Deepest available reasoning mode set at session start — not explicitly confirmed;
      this session ran at whatever effort level the harness resolved by default,
      matching Document 1's own plan's identical caveat (its §11). Flag for the owner:
      Phase B (screenshot regeneration, dragon 1) and Phase A (scope/method decisions)
      are where it would matter most.
- [ ] Close-out: evaluate predecessor, self-assess, write the `HANDOFFS.md` receipt,
      record the `CHANGELOG.md` ledger entry, commit, STOP — pending, this session's
      Phase 3 (imminent, not yet done as of this plan's drafting).

---

## 11. Open decisions for the owner (not blocking plan approval, but not silently assumed)

1. **Tab-coverage extent (§8 dragon 3).** Should Section 3 cover only the 6 tabs the
   source tutorial already covers (Input, Pedigree Browser, Age-Sex Pyramid, GVA,
   Summary Statistics, Breeding Groups), or also the 2 tabs added since
   (Genetic Diversity #112, Potential Parents #48)? Recommend: include both new tabs —
   they are core, non-ONPRC-specific public capabilities, and omitting them from a
   public "how to use it" guide undersells the current package. Resolve at Phase A
   kickoff.
2. **Screenshot regeneration method (§8 dragon 1).** Automated (`shinytest2`-driven,
   reproducible, matches existing E2E infrastructure, but full-viewport rather than
   curated crops/annotations) vs. manual (preserves the original curated framing, not
   reproducible/scriptable). Recommend: automated capture as the default, with manual
   post-processing (crop/annotate) only where a specific illustrative point (e.g., the
   red-oval highlight) genuinely needs it. Resolve at Phase A kickoff.
3. **Fate of `ColonyManagerTutorial.Rmd` after porting (§8 dragon 4).** Retire it (e.g.,
   replace its content with a redirect note to the new public article) once Document 2
   ships, or keep both in parallel? Recommend: retire/redirect, to avoid anti-pattern
   #14 companion-paper drift (a source vignette silently diverging from its port over
   time) — but this is the owner's call, resolve at Phase D.
4. **Timing of the pkgdown Reference-index fix (§1's separate finding).** Independent of
   Document 2's own timeline — fix before Document 2 references the Reference page, or
   let Document 2 ship first and fix separately? Either is fine as long as Document 2's
   own citation is verified live at draft time regardless (§8 dragon 5). Recorded as its
   own `BACKLOG.md` item at this session's close-out; no ordering dependency imposed
   here.
5. **Article title/slug** — not locked by this plan. Proposed working title:
   `vignettes/articles/colony-manager-guide.qmd` — "nprcgenekeepr: Purpose, Approach, and
   a Colony Manager's Guide to Practice." Confirm or rename at Phase A kickoff, matching
   Document 1's precedent (its own title was confirmed, not assumed, at its Phase B
   kickoff).
