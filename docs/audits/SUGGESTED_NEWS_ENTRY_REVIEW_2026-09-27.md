# Review: `suggested_NEWS_entry.md` / `vignettes/suggested_NEWS_entry.Rmd` against `NEWS.Rmd`

**Session:** S793, 2026-09-27. **Workstream:** `docs/methodology/workstreams/AUDIT_WORKSTREAM.md`
(no TDD phase gates — this session produces a review document only; no `NEWS.Rmd`, code, or test
change).

**Scope note (owner-scoped 2026-09-27):** this reviews the owner's untracked draft
entry-by-entry against the current `NEWS.Rmd` and assigns an **adopt / reject / modify**
verdict with rationale to each suggested idea. It does **not** decide the separate,
already-open `BACKLOG.md` question of *whether/when* to consolidate the whole `NEWS.Rmd`
dev-block into a 3.0.0-style release note — that disposition (owner-ratified S791: continue the
piece-by-piece release-state sweep as scoped, revisit once the sweep closed) stands untouched.
This review supplies evidence for that future decision; it does not make it.

## Audit Summary

- **Scope:** `suggested_NEWS_entry.md` and `vignettes/suggested_NEWS_entry.Rmd` (dated
  2026-09-25, both owner-authored from an AI-assisted conversation per `BACKLOG.md`) — the two
  files are **substantively identical**; the `.Rmd` adds only a "Rationale" preamble and R
  Markdown YAML/chunk scaffolding. Compared against `NEWS.Rmd`'s current dev-block, `# nprcgenekeepr
  2.0.0.9000 (development version)` (`NEWS.Rmd:15-495`), which the now-closed 4-stage release-state
  sweep (S788-S792) already restated as finished-state prose for its `## Pedigree Diagram` section.
- **Criteria:** for each suggested idea — (a) does it accurately reflect the shipped
  feature/argument/function (checked against `R/` and `NEWS.Rmd`, not memory); (b) does it retain
  load-bearing caveats or limits a curator or script user needs; (c) does it avoid reintroducing an
  overgeneralization the release-state sweep specifically removed (an unqualified "always"/"every");
  (d) is the underlying idea an improvement to *wording or organization* independent of the separate
  "consolidate for 3.0.0" timing question.
- **Coverage:** 14 of 14 suggested items examined (12 content sections + 2 structural/global
  elements: the opening release-summary paragraph, and the overall consolidation strategy the
  draft's "Rationale" argues for). 100%.
- **Verdict count:** 2 ADOPT (global), 6 ADOPT (section), 6 MODIFY (2 global, 4 section), 1 REJECT
  (as literally drafted, with a MODIFY alternative given in the same finding).

## Findings

### Finding G1: Add an opening release-summary paragraph
- **Verdict:** ADOPT (for the eventual 3.0.0 release note; not actionable in today's dev-block,
  whose heading is still `2.0.0.9000 (development version)`, not `3.0.0`).
- **Location:** suggestion line 1 vs. `NEWS.Rmd:15-17` (jumps straight from the version heading to
  `## Package`).
- **Description:** the draft opens with a one-paragraph summary of everything new in the release
  before the section-by-section detail. `NEWS.Rmd`'s dev-block has no equivalent anywhere.
- **Evidence:** "This release substantially expands `nprcgenekeepr` beyond pedigree management and
  genetic value analysis, adding interactive pedigree visualization, marker-based genetic analysis,
  MHC haplotype reporting, cross-center identity matching, ancestry-aware breeding safeguards,
  de-identified export workflows, and longitudinal monitoring of colony genetic health."
- **Impact:** a reader scanning `NEWS.md` for "what's new" has to read all 12 section headings to
  reconstruct this; the paragraph is a genuine readability win with no accuracy risk (it names
  categories, not numbers or behaviors that could go stale).
- **Recommendation:** keep this idea in reserve for whenever the version heading actually becomes
  `3.0.0`; wording should be re-verified against the final feature set at that time, since scope may
  still change.

### Finding G2: Consolidate issue-by-issue history into user-facing feature groups
- **Verdict:** MODIFY — sound for a *release* note, premature as a *dev-block* rewrite.
- **Location:** the `.Rmd`'s "Rationale" section (lines 15-23).
- **Description:** the draft's central argument is that implementation-level fixes (connector
  routing, duplicate-node placement, spacing, mating-symbol positioning) "do not belong as
  individual NEWS bullets" and should become one higher-level statement.
- **Evidence:** this is already an open, owner-ratified decision, not a new one this review
  introduces — S791's disposition (`CHANGELOG.md`, `BACKLOG.md`'s now-standing item) was to
  continue the sweep piece-by-piece rather than merge the draft in, precisely because the granular
  entries are what let each sweep session verify a claim against real code and catch three stale
  claims (S789 male-left, S790 duplicate count, S791 sibling-bar) that a pre-consolidated bullet
  would have hidden.
- **Impact:** consolidating now, before a release is cut, would remove the very detail a future
  audit needs to re-verify claims against code.
- **Recommendation:** treat the draft as the *template to apply once, at the actual 3.0.0 cut* —
  not a reorganization to perform on the dev-block today. This matches the already-open BACKLOG
  item; no new decision is needed from this finding alone.

### Finding G3: Drop inline issue-number citations
- **Verdict:** MODIFY — correct for a release note, but the dev-block should keep them until then.
- **Location:** every suggestion bullet vs. `NEWS.Rmd`'s parenthetical `(issue #NNN)` citations
  throughout.
- **Description:** the draft cites no GitHub issue numbers anywhere.
- **Impact:** issue numbers are internal traceability, not user-facing value — appropriate to drop
  for CRAN's public `NEWS.md`. But `NEWS.Rmd`'s own citation-checklist convention (`CLAUDE.md`
  "Citation checklist") and this project's own audit practice (e.g. this review) rely on those
  numbers to trace a claim back to its originating issue.
- **Recommendation:** strip issue numbers only in the release-time pass, not before.

### Finding G4: Omit the `## Package` entry (CRAN 2.0.0 acceptance)
- **Verdict:** ADOPT, for a 3.0.0-scoped note specifically.
- **Location:** `NEWS.Rmd:17-19` vs. the draft's complete absence of any such entry.
- **Description:** `NEWS.Rmd`'s `## Package` section states "CRAN accepted the 2.0.0 submission
  (tagged `v2.0.0`); published 2026-07-26" — a fact about the *prior* release, not the *upcoming*
  one, and the draft correctly leaves it out of a 3.0.0-titled note.
- **Impact:** none — this finding simply confirms the draft's implicit answer to `BACKLOG.md`'s
  already-open "keep or delete the `## Package` entry" item is "delete, for a 3.0.0 note." It does
  not resolve whether to delete it from today's dev-block now; that stays the separate open decision.

### Finding S1: `## Pedigree diagrams` section
- **Verdict:** MODIFY.
- **Severity:** Minor (two omissions worth restoring; no inaccuracies found).
- **Location:** suggestion lines 15-42 vs. `NEWS.Rmd:21-192` (33 detailed bullets).
- **Description:** the 8 consolidated bullets are well-hedged — none reintroduces an unqualified
  "always"/"every"/"each" claim of the kind the sweep specifically removed (S789's male-left fix,
  S790's "every mating symbol" fix, S792's narration-tense fixes). Checked against the shipped
  feature and found accurate. Two omissions stand out as worth keeping even in consolidated form:
  1. **The display size cap** (400 animals with the default Rectilinear style, 750 with Direct;
     `NEWS.Rmd:24-27`, issue #129) is dropped entirely. This is an operational limit a curator with
     a large colony will actually hit — not a development-history detail — so it belongs in a
     release note, consolidated or not.
  2. **Which style is the default** is left unstated: "Two connector styles are available: direct
     connectors and a `kinship2`-style rectilinear layout" does not say Rectilinear is the default.
     This is the exact ambiguity class the S789 fix corrected in `NEWS.Rmd` itself (the pre-sweep
     text called Direct the default; it is Rectilinear). Re-omitting which one is the default in a
     new draft risks reintroducing that exact confusion for a reader who never sees `NEWS.Rmd`'s
     already-corrected wording.
- **Recommendation:** adopt the consolidation; add one clause naming Rectilinear as the default, and
  one short bullet on the display cap.

### Finding S2: `## Kinship and pedigree calculations` section
- **Verdict:** MODIFY (minor).
- **Severity:** Minor.
- **Location:** suggestion lines 44-57 vs. `NEWS.Rmd:193-216`.
- **Description:** close to a 1:1 match; correctly retains function names (`kinship()`, `reportGV()`,
  `gvaConvergence()`, `createSimKinships()`, `cumulateSimKinships()`, `shrinkPedigree()`) — verified
  all five still carry a `twinRelations` argument (`grep` against `R/kinship.R`, `R/reportGV.R`,
  `R/gvaConvergence.R`, `R/createSimKinships.R`, `R/cumulateSimKinships.R`), and `kinship()` still
  carries `chrtype`. One omission: `NEWS.Rmd:197-199` states the twin correction "applies
  everywhere relatedness is used in the app -- Summary Statistics, Breeding Groups, and Genetic
  Value Analysis -- regardless of which tab is opened first," a cross-tab consistency guarantee the
  draft drops (its bullet mentions only the script-side `twinRelations` argument).
- **Recommendation:** adopt the section as drafted; optionally restore one clause noting the app-wide
  consistency guarantee, since it reassures a Shiny-app user the correction is not tab-order-dependent.

### Finding S3: `## Marker Genetics` section
- **Verdict:** ADOPT.
- **Severity:** Minor (one acceptable omission, no inaccuracies).
- **Location:** suggestion lines 59-95 vs. `NEWS.Rmd:218-270`.
- **Description:** all 7 named sub-tabs (Kinship Comparison, Heterozygosity, Parentage Exclusion,
  Candidate Parent Assignment, Cross-Center, Linkage and LD Block Metrics, Genomic ROH) and all 10
  new function names are present and verified to still exist in `R/`
  (`markerParentageLikelihood`, `checkLocusMetadata`, `checkLinkageMarkerGenotypeFile`,
  `markerRealizedRelatednessVariance`, `markerLdBlock`, `obfuscateLdBlocks`,
  `checkSequenceGenotypeFile`, `computeGenomicROH`, `obfuscateGenotypeMatrix`,
  `obfuscateGenomicROH`). Drops the Candidate Parent Assignment "automatic suggestion covers the
  common case" nuance (issue #155) — an acceptable simplification for a release note.
- **Recommendation:** adopt as drafted.

### Finding S4: `## MHC haplotype reporting` section
- **Verdict:** ADOPT.
- **Severity:** none.
- **Location:** suggestion lines 97-110 vs. `NEWS.Rmd:272-303`.
- **Description:** near 1:1 with `NEWS.Rmd`, condensed only by dropping issue numbers (Finding G3).
  No inaccuracies or omissions found.

### Finding S5: `## Cross-center identity matching` section
- **Verdict:** ADOPT.
- **Severity:** none.
- **Location:** suggestion lines 112-122 vs. `NEWS.Rmd:305-315`. 1:1 match.

### Finding S6: `## Genetic Value Analysis` section
- **Verdict:** ADOPT.
- **Severity:** none.
- **Location:** suggestion lines 124-135 vs. `NEWS.Rmd:317-328`. Matches closely, including the
  "flagged" column / comparable-peer-group caveat.

### Finding S7: `## Breeding Group Formation` section
- **Verdict:** MODIFY.
- **Severity:** Moderate (one substantive caveat dropped; one factual mislabeling).
- **Location:** suggestion lines 137-162 vs. `NEWS.Rmd:330-380` (a single, unusually dense paragraph
  packed with the entire ancestry-guardrails feature).
- **Description:** the structural idea — splitting `NEWS.Rmd`'s one dense paragraph into 8 scannable
  bullets plus a function/argument list — is a genuine readability improvement **independent of the
  3.0.0-consolidation question**; this entry is noticeably harder to scan than the rest of the file
  even by the dev-block's own standard. Two concrete problems found on inspection:
  1. **Dropped caveat:** `NEWS.Rmd:371-374` states, as a deliberately documented limitation, "in
     harem formation the automatically chosen sire himself is not checked against the rules (his
     groupmates are checked against each other)." This is not incidental detail — it is a *known,
     owner-accepted gap* (`BACKLOG.md`'s open "Harem-sire conflict enforcement hole" item,
     `PROJECT_LEARNINGS.md` Learning 778) that a curator relying on ancestry guardrails needs to
     know about. The draft's consolidated bullets omit it entirely.
  2. **Factual mislabeling:** the draft's function-list sentence reads "...the corresponding
     `ancestryRules`, `overriddenRules`, `candidates`, `maxCandidates`, and `exhaustive` controls in
     `groupAddAssign()`," listing `candidates` as one of the new controls. Verified against
     `R/groupAddAssign.R:171` and its roxygen (`:21-23`, `:89-96`): `candidates` is
     `groupAddAssign()`'s **pre-existing first parameter** (the pool of animal ids to consider), not
     new. What *is* new (issue #125) is a `candidates` list item in the **return value** — confirmed
     by the roxygen `@return A list with list items \code{group}, \code{score}, \code{candidates}`
     — which `NEWS.Rmd:333-334` already states correctly ("`groupAddAssign()` gained a matching
     `candidates` field in its return value"). The draft's phrasing would mislead a script user into
     thinking `candidates` became a new input argument.
- **Recommendation:** adopt the bullet-splitting structure; restore the harem-sire caveat as its own
  bullet; correct the `candidates` reference to name it as a return-value field, matching
  `NEWS.Rmd`'s own already-accurate wording.

### Finding S8: `## Mate Pair Analysis` section
- **Verdict:** MODIFY (minor).
- **Severity:** Minor.
- **Location:** suggestion lines 164-178 vs. `NEWS.Rmd:382-405` (also one dense paragraph).
- **Description:** same readability win as Finding S7 — splitting the paragraph into 5 bullets is an
  improvement independent of the consolidation-timing question. No hidden-gap caveat is dropped here
  (checked: `NEWS.Rmd`'s Mate Pair Analysis entry does not itself carry a harem-sire-style caveat —
  consistent with the S764-ratified "inherit + document on Breeding Groups only" scope, so nothing
  new is lost). Dropped detail — the "block rule... moves to the Excluded tab with the reason
  `'ancestry rule'`" label, and that rules are loaded once on the Breeding Groups tab and shared with
  Mate Pair — are operational/UI specifics reasonable to omit from a release-note bullet.
- **Recommendation:** adopt the bullet-splitting structure as drafted.

### Finding S9: `## De-identified export` section
- **Verdict:** ADOPT.
- **Severity:** none.
- **Location:** suggestion lines 180-188 vs. `NEWS.Rmd:407-415`. Near-verbatim match, 2 bullets each.

### Finding S10: `## Longitudinal monitoring of colony genetic health` section
- **Verdict:** ADOPT.
- **Severity:** none.
- **Location:** suggestion lines 190-210 vs. `NEWS.Rmd:417-453` (4 dense paragraphs restructured into
  7 atomic bullets). No information loss found: retains all 6 new function names, the
  settings/software-version disambiguation caveat, and the trend-plot sampling-uncertainty caveat.
  A clean readability improvement with no accuracy risk.

### Finding S11: `## General improvements` / `## General Fixes` section
- **Verdict:** REJECT as literally drafted (drops 4 of 6 fixes with no substitute); MODIFY
  recommended as the alternative.
- **Severity:** Moderate — the most significant information loss found in this review.
- **Location:** suggestion lines 212-217 (2 bullets) vs. `NEWS.Rmd:455-495` (6 bullets, `## General
  Fixes`).
- **Description:** the draft keeps only the marker-genotype session-crash fix and the
  deterministic-sort fix, both accurate matches to `NEWS.Rmd`'s first and second bullets. It
  silently drops all four remaining fixes: `removeUnknownAnimals()`'s "added"-status handling,
  `convertDate()`'s added-row handling, the "Duplicate IDs found" false-positive fix, and
  `correctParentSex()`'s `NA`/skip fix — plus, separately, `getAncestors()`/`findLoops()`/
  `countLoops()`'s infinite-recursion-to-named-message fix.
- **Impact:** these are genuine correctness fixes to the pedigree QC pipeline, not cosmetic
  cleanup. A script user who hit the old "Duplicate IDs found" false positive, or an empty-pedigree
  result from `removeUnknownAnimals()`, has a concrete reason to search `NEWS.md` for exactly this
  fix. Dropping bug-fix disclosure entirely — rather than condensing it — is not standard release-
  note practice and risks looking like the fixes were never disclosed.
- **Recommendation:** do not drop these silently. Consolidate the four "added"-status fixes into one
  summarizing bullet (e.g., "Several pedigree-check functions — `removeUnknownAnimals()`,
  `convertDate()`, `removeDuplicates()`, `correctParentSex()` — now handle an animal whose 'added'
  status is blank, missing, or unrecognized correctly, instead of occasionally dropping, mislabeling,
  or erroring on it") and keep the `getAncestors()` loop-message fix as its own bullet, alongside the
  two the draft already retains.

## Items Audited

| Item | Verdict | Severity | Finding(s) |
|---|---|---|---|
| Opening release-summary paragraph | ADOPT | — | G1 |
| Overall consolidation strategy | MODIFY | — | G2 |
| Dropping issue-number citations | MODIFY | — | G3 |
| Omitting `## Package` | ADOPT | — | G4 |
| Pedigree diagrams | MODIFY | Minor | S1 |
| Kinship and pedigree calculations | MODIFY | Minor | S2 |
| Marker Genetics | ADOPT | Minor | S3 |
| MHC haplotype reporting | ADOPT | — | S4 |
| Cross-center identity matching | ADOPT | — | S5 |
| Genetic Value Analysis | ADOPT | — | S6 |
| Breeding Group Formation | MODIFY | Moderate | S7 |
| Mate Pair Analysis | MODIFY | Minor | S8 |
| De-identified export | ADOPT | — | S9 |
| Longitudinal monitoring | ADOPT | — | S10 |
| General improvements / General Fixes | REJECT (as drafted) | Moderate | S11 |

Coverage: 14 of 14 items examined (100%). No items excluded.

## Structural Observations

1. **The draft's editorial instinct is sound and its execution is mostly accurate.** Of 12 content
   sections, 6 need no change and 5 need only restoration of a dropped caveat or a small
   clarification — not a rewrite. The one section that fails outright (General Fixes) fails by
   *omission*, not by getting anything it kept wrong.
2. **Every dropped detail this review flagged as worth keeping is a *caveat or limit*, never a
   *feature description*.** The pattern across S1 (display cap, default style), S7 (harem-sire gap),
   and S11 (the four QC fixes) is the same: the draft is very good at describing what a feature
   *does*, and consistently drops what it *doesn't do* or *doesn't yet cover*. That is a useful,
   nameable pattern for whoever eventually writes the real 3.0.0 note — the operative check is "does
   this bullet still disclose the feature's known limits, not just its capabilities?"
3. **The two sections with the single densest, hardest-to-scan `NEWS.Rmd` paragraphs (Breeding Group
   Formation, Mate Pair Analysis) are exactly the two sections where the draft's bullet-splitting is
   most clearly a stand-alone improvement**, separate from the consolidation-for-3.0.0 question this
   review does not decide. That structural fix (splitting one mega-paragraph into scannable bullets)
   could be applied to `NEWS.Rmd` itself at any time without waiting for a 3.0.0 release, since it
   changes formatting, not content scope — unlike the sweep's other sections, which were already
   bulleted.
4. **The one confirmed factual error (`candidates` in Finding S7) is a case where `NEWS.Rmd`'s own
   existing wording is already correct** ("a matching `candidates` field in its return value") and
   the draft's compression accidentally lost the precision. This is a caution for whoever eventually
   merges suggestions into a release note: compress the wording, not the technical accuracy.

## Recommendations

1. **Immediately actionable, independent of the 3.0.0 timing decision:** if a future session
   restructures `NEWS.Rmd`'s Breeding Group Formation and Mate Pair Analysis entries into bullets
   (Findings S7/S8), that is a formatting change, not a scope change, and does not need to wait for
   a release — but it must restore the harem-sire caveat and fix the `candidates` mislabeling if it
   draws on this draft's wording.
2. **For the eventual 3.0.0 release note** (not this session, not the dev-block today): the draft is
   a strong starting template. Before use, apply Findings S1 (default style, display cap), S2 (twin
   cross-tab consistency), and S11 (restore condensed QC-fix disclosure) as corrections, and re-verify
   every function/argument name against `R/` at that time rather than trusting this review's snapshot.
3. **The disposition question this review does not answer** — whether/when to adopt the
   consolidation approach at all — remains `BACKLOG.md`'s open item, owner-ratified S791 to revisit
   now that the release-state sweep has closed (S792). This review supplies the evidence (which
   specific ideas hold up) that decision needs; it is not itself that decision.
