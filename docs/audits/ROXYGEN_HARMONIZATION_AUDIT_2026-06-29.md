# roxygen2 Documentation Harmonization — Analysis & Recommendation

**Issue:** #102 (analysis / assessment — **not** the edits)
**Date:** 2026-06-29 (Session 244)
**Scope:** all 226 `R/*.R` source files
**Status:** Assessment complete. Implementation is a **separate follow-on session** (REFACTOR if pure-doc; RED→GREEN if any example/behaviour change).

---

## 1. Audit Summary

- **Criteria:** Is the roxygen2 `#'` **documentation** structure consistent across all `R/` functions, and what single convention should it be harmonized to? (The *copyright* `#'`-vs-`##` boundary was already resolved in S243 / Learning 229 — out of scope here, except its *placement*, see Finding 8.)
- **Coverage:** 226 of 226 files inventoried — exact mechanical counts (grep) over all 226, plus structured per-function deep reads of 225/226 (the package-doc stub `nprcgenekeepr-package.R` carries no function record).
- **Method:** (a) authoritative grep counts; (b) a 15-agent parallel deep-read producing one structured record per file; (c) a synthesis pass; (d) an **independent adversarial verification** pass; (e) **firsthand re-verification** by the session author of every headline claim. The adversarial pass caught one material error (examples coverage — see §7) which was corrected firsthand before this report was written.
- **Finding count:** 8 harmonization dimensions (1 already-consistent, 5 moderate, 2 low) + **8 classes of genuine rendered-doc DEFECT** worth fixing regardless of harmonization.

**Headline:** This is a **well-documented** package. The problem is style **consistency**, not missing documentation. The dominant pattern is a clean **two-era split** — legacy files embed the copyright between the title and body and order `@return` before `@param`; the newest files already follow a cleaner convention. **Harmonization is therefore a convergence task onto an already-emerging modern house style, not a green-field design.**

---

## 2. Strengths (calibrated — do not "fix" these)

- **`@param` coverage is essentially complete.** Every formal argument is documented in essentially every file (e.g. `reportGV.R` documents all 11 formals; `getAnimalsWithHighKinship.R` all 6). The only `@param`-free files (12) are legitimately zero-arg accessors or data docs (`data.R`, `defaultSiteParams.R`, `getRequiredCols.R`, `getEmptyErrorLst.R`, …).
- **`@return` is near-uniform.** Present on 222 files and spelled `@return` everywhere except **one** outlier (`set_seed.R:46` uses `@returns`) — a one-line fix from 100% uniform.
- **Clean slate for modern tags.** `@family`, `@inheritParams`, `@examplesIf` are used **zero** times — there is no conflicting partial adoption to untangle.
- **A modern exemplar tier already exists** (`getSpeciesGestation.R`, `getSpeciesMinBreedingAge.R`, `applyKinshipOverrides.R`, `hasInvalidIdChar.R`) demonstrating the target convention.
- **Tooling is already in place:** `DESCRIPTION` sets `Roxygen: list(markdown = TRUE)` with `Config/roxygen2/version: 8.0.0`, so either markup direction is supported.

> **Note (corrected):** examples coverage is **not** a strength — see Finding 1 and §7. An earlier count claiming "166/167 exported have examples" was wrong; the true figure is **145/167 (~87%)**.

---

## 3. Findings by Dimension

Severity is calibrated against rendered-doc impact and corpus prevalence — not inflated. "Effort" is for the follow-on implementer.

### Finding 1 — Tag presence / coverage  *(severity: moderate · effort: semi-mechanical)*

**Current state.** Coverage is mostly a strength (see §2). Real inconsistencies:
- **Examples coverage gap:** 22 of 167 exported files have **no** `@examples` (true coverage 145/167 — see §7 for the full list and the proposed carve-out).
- **`@return` vs `@returns`:** uniform `@return` except `set_seed.R:46`.
- **Implicit vs explicit title/description:** titles are implicit everywhere except `nprcgenekeeper.R` (explicit `@title`); a handful of files use explicit `@description` (`calcGU.R`, `calculateSexRatio.R`, `fillGroupMembersWithSexRatio.R`, `findGeneration.R`, `groupAddAssign.R`, `kinship.R`, `nprcgenekeeper.R`) — and `calcGU.R`'s is a defect (Finding D1).
- **Example guard style varies:** runnable vs `\dontrun{}` (7) vs `\donttest{}` vs `if (interactive())` — e.g. `getDemographics.R:11` `\donttest`, `readKinshipOverrides.R:30` `\dontrun`, `runModularApp.R:34` `if(interactive())`.
- **`@seealso`** in 31 files, sometimes split across multiple consecutive tags (`makeFounderStatsTable.R:35-37`, `runQcStudbook.R:26-28`). `@family` unused.

**Recommendation.** Keep implicit title + implicit description (do **not** convert to explicit `@title`/`@description`, except the package doc). Fix the one `@returns`. Define an explicit **examples policy** (see §7): every *directly callable* exported function carries `@examples`; exempt Shiny `mod*` UI/Server and app entry points; pick **one** guard ladder — bare-runnable when cheap/side-effect-free, `\donttest` for slow-but-safe, `\dontrun` only for genuinely un-runnable (LabKey/network/file-writing) code; retire `if(interactive())` guards. Collapse multiple `@seealso` into one tag. Leave `@family` for a later enhancement (Finding 6).

### Finding 2 — Tag ordering & grouping  *(severity: moderate · effort: semi-mechanical)*

**Current state.** The package-dominant order is `title, description, @return, @param, @export/@noRd, @examples` — i.e. **`@return` BEFORE `@param`**, which inverts the roxygen2/CRAN-conventional `@param`-before-`@return`. Roughly 180+ files put `@return` first; only the newest files invert it correctly (`applyKinshipOverrides.R`, `checkKinshipOverrides.R`, `classifyParentage.R`, `hasInvalidIdChar.R`, `correctUnknownParentMeanKinship.R`, `getSpeciesGestation.R`, `getSpeciesMinBreedingAge.R`, …). Secondary disorders: `@examples` before `@param` (`addBackSecondParents.R:13` vs `:30`; `addGenotype.R:15` vs `:24`); `@export` before `@examples` (`addUIds.R:21`; `makeRelationClassesTable.R:15`); `@details` before `@return`/`@param`; `@author`/`@references` interleaved mid-block (`kinship.R:36`, `:58`).

**Recommendation.** Adopt the roxygen2-standard block order for every function:

```
1. title line              6. @return
2. (blank #')              7. @seealso
3. description paragraph(s) 8. @references
4. @details (if any)       9. @importFrom (grouped)
5. @param (signature order) 10. @export | @noRd | @keywords internal
                           11. @examples (last)
```

The single highest-volume change is **moving `@return` to after the `@param` block**.

### Finding 3 — Title / description style  *(severity: moderate · effort: judgment-heavy)*

**Current state.** Titles are sentence-case and almost universally period-less (a clear minority of ~15 carry a trailing period, e.g. `allTrueNoNA.R:1`, `isEmpty.R:1`, `orderReport.R:1`). **Voice is split four ways:** imperative ("Get/Add/Calculate"), descriptive-3rd-person ("Gets/Calculates/Converts"), **function-name-prefixed** ("`checkErrorLst examines list…`", "`addIdRecords Adds…`"), and noun-phrase ("Main Application Server", mod* "X Module – UI Function"). A few titles embed Rd markup (`allTrueNoNA.R:1`, `calcA.R:1`, `makeRoundUp.R:1`), which renders `\code{}` literally in some index contexts. **Several are outright defects** (typos/grammar) — see Finding D6.

**Recommendation.** One title convention: a short **imperative-voice** phrase (e.g. "Apply kinship overrides", "Calculate animal ages"), sentence case, **no** trailing period, **no** function-name prefix, **no** Rd/markdown markup, one line (≲60 chars). Move any narrative into the description paragraph. *Voice normalization is judgment-heavy — do not bulk find/replace; the typo and trailing-period fixes are mechanical.*

### Finding 4 — Markdown vs raw Rd  *(severity: moderate · effort: semi-mechanical)*

**Current state.** `markdown = TRUE` **is** enabled globally (DESCRIPTION:81), yet the corpus is overwhelmingly **raw Rd**: `\code{}` ×1270 vs backtick ×48 (across 37 files); `\link{}` ×224 vs markdown links ×0; `\emph{}` ×38; `\strong{}` ×14. The 48 backticks are **not** a deliberate migration — they are stray single-token leaks (almost always `` `Pedigree` ``) sitting in otherwise raw-Rd blocks, making those 37 files "mixed". Because markdown is on, the backticks **do** render (they are *inconsistent*, not *broken*).

> *Caveat for the implementer:* several deep-read agents asserted "markdown is not enabled package-wide." That is **false** — `DESCRIPTION:81` sets `list(markdown = TRUE)`. Do not act on that mistaken premise.

**Recommendation.** Harmonize **toward raw Rd** (`\code{}` / `\link{}`) as the single inline-markup style — it already dominates 1270-to-48 and 224-to-0. Converting 48 stray backticks → `\code{}` is a tiny, safe, mechanical edit; converting 1270 `\code{}` + 224 `\link{}` → markdown is a large, error-prone rewrite (markdown `[func()]` auto-linking has different semantics needing per-site verification). Keep `markdown = TRUE` enabled (harmless, future-friendly). *(Separately, the escaped-brace pseudo-Rd lists are defects — Finding D3.)*

### Finding 5 — Internal vs exported split  *(severity: moderate · effort: semi-mechanical)*

**Current state.** Unexported helpers are marked almost exclusively with `@noRd` (61 files) — consistent. `@keywords internal` appears in only 4 files and is the *real* inconsistency: `nprcgenekeepr-package.R:4` (correct — package doc), `nprcgenekeeper.R` (the duplicate legacy package doc — Finding D2), and **`modPotentialParents.R:16-17` + `readFocalAnimalIds.R:16-17` carry BOTH `@noRd` AND `@keywords internal`** (redundant).

**Recommendation.** Policy: unexported helpers use **`@noRd` only**; reserve `@keywords internal` exclusively for the single package-level doc (`nprcgenekeepr-package.R`). Remove the redundant `@keywords internal` from `modPotentialParents.R` and `readFocalAnimalIds.R`. (The duplicate `_PACKAGE` block is Finding D2.)

### Finding 6 — De-duplication opportunities  *(severity: low · effort: judgment-heavy)*

**Current state.** Zero `@inheritParams`, zero `@family`. The same `@param` descriptions are re-typed across dozens of files (`ped`, `kmat`, `ids`, `threshold`) — and copy-paste has introduced **real bugs** (Findings D4/D5). Natural `@family` clusters (genetic-value `calc*`, direct-relatives getters, Shiny `mod*` modules, the `obfuscate*` family) are uncross-linked.

**Recommendation.** Introduce a small set of `@inheritParams` donor functions for the most-repeated formals (define `ped` once on a canonical function, `@inheritParams` it elsewhere) to **kill the copy-paste `@param` drift at the source**. Add `@family` tags for the obvious clusters. *Stage this AFTER the mechanical passes* — it requires choosing canonical donors and verifying inherited text fits each callee.

### Finding 7 — Import-tag style  *(severity: low · effort: semi-mechanical)*

**Current state.** `@importFrom` already dominates (75 files / 164 occ) — the correct namespace-hygiene choice. Whole-namespace `@import` survives in **10 files**:

| Package | Files | Conversion |
|---|---|---|
| `futile.logger` ×7 | `getPedigree.R`, `getPedigreeSource.R`, `getFocalAnimalPed.R`, `getGenotypes.R`, `getFocalAnimalPedFromFile.R`, `getPedDirectRelatives.R`, `getLkDirectAncestors.R` | **Mechanical** → `@importFrom futile.logger flog.*`. Already redundant: `futile.logger` is *also* imported via `@importFrom` elsewhere (5×), and several of these files already carry `@importFrom` lines for other packages right beside the `@import`. |
| `RColorBrewer` ×1 | `makeGeneticDiversityDashboard.R` | **Mechanical** → `@importFrom RColorBrewer brewer.pal` (note: this file documents a *commented-out* function — Finding D7). |
| `shiny` ×1 | `nprcgenekeepr-package.R` (package-level) | **Judgment** — large API surface; 52 files already use `@importFrom shiny`. A full enumeration is verbose but CRAN-clean. |
| `Matrix` ×1 | `kinship.R` | **Judgment** — S4/method-heavy; after converting, verify method dispatch still resolves. |

**Recommendation.** **CRAN/R packaging guidance prefers `@importFrom` (or `pkg::fn()`) over `@import`** — `@import` pulls an entire namespace and invites masking between packages, while `@importFrom` is explicit and minimal *(owner-confirmed during this session)*. Convert the 8 easy holdouts mechanically; treat `shiny`/`Matrix` as a verified judgment call. Group all import tags immediately before `@export`/`@noRd` (Finding 2). This is the **most nearly-consistent** dimension — low severity.

### Finding 8 — Copyright-comment **placement**  *(severity: moderate — high-volume / low rendered-impact · effort: mechanical)*

**Current state.** The two-line `## Copyright(c) 2017-2026 …` / `## This file is part of nprcgenekeepr` pair (text normalized by S243) is **interleaved inside** the roxygen block — between the title line and the description body — in the large majority of files, visually splitting the title from its description (e.g. `addAnimalsWithNoRelative.R:3-4`, `calcGU.R:3-4`, `applyKinshipOverrides.R:3-4`). A minority of newer files correctly place it **above** the block (`getSpeciesGestation.R:1-2`). roxygen still renders titles correctly (`##` lines are plain comments), so **rendered-doc impact is nil** — but it is the **single most-repeated structural inconsistency** in the corpus.

**Recommendation.** Move the `## Copyright` / `## This file is part of` pair to the **top of every file, above the first `#'` line**, separated by one blank line (the `getSpeciesGestation.R` pattern) — a deterministic, scriptable transform. Fold the bare-blank-line block-break DEFECTS (Finding D8) into the same pass, since they are adjacent structural cleanups and *are* rendered-impacting.

---

## 4. Genuine Rendered-Doc DEFECTS (fix regardless of harmonization)

These are not style preferences — they are wrong output. Several are **CRAN-facing** (exported → shipped man pages). All firsthand-verified.

| # | Defect | Location | Rendered impact | Severity |
|---|---|---|---|---|
| D1 | Malformed explicit `@description` overrides the real description | `R/calcGU.R:42` → `man/calcGU.Rd` `\description{}` shows only `\{Genome Uniqueness Functions\}\{\}` | **exported**; ~34 lines of real description suppressed | high |
| D2 | Duplicate `_PACKAGE` sentinel (two package docs) | `R/nprcgenekeepr-package.R:5` **and** `R/nprcgenekeeper.R:107` | two package-doc definitions; roxygen ambiguity | high |
| D3 | Escaped-brace pseudo-Rd lists render literally | `convertSexCodes.R:9-15` → `man/convertSexCodes.Rd:26-30`; also `checkParentAge.R:10-16`, `nprcgenekeeper.R:18-39`, `qcStudbook.R:18-45`, `getSiteInfo.R`, `makeCEPH.R`, `kinship.R:29` | **exported**; literal `\item\{F\} \{…\}` braces shown to users | moderate |
| D4 | `@param` documents a **nonexistent** argument (`candidates`) | `addParents.R:28` (sig is `function(ped)`), `addSexAndAgeToGroup.R:15` (`ids`,`ped`), `getAnimalsWithHighKinship.R:13` | roxygen mismatch; stale doc | moderate |
| D5 | `@return` text copy-pasted from the wrong function | `findPedigreeNumber.R:7` (says "generation numbers", copied from `findGeneration`); `getOffspring.R:6` (says "ancestor IDs" for an offspring fn) | **exported**; wrong semantics documented | moderate |
| D6 | Title typos / grammar | `obfuscateDate.R:1` "obfucateDate", `obfuscateId.R:1` "obfucateId", `getPotentialParents.R:4` "portential", `getDatedFileName.R:1` "with an file name", `getEmptyErrorLst.R:1` "Creates a empty", `fixColumnNames.R:1` "and into" | **exported**; misspelled titles on man pages | moderate |
| D7 | Dead `@importFrom`/`@import` for a commented-out function | `makeGeneticDiversityDashboard.R:8-10` | dangling import directives | low |
| D8 | Bare non-`#'` blank lines breaking roxygen blocks mid-description | `geneDrop.R:40`, `kinshipMatrixToKValues.R:34`, `makeCEPH.R:13`; stray `#` at `kinshipMatricesToKValues.R:26` | description truncated at the break | moderate |

> The implementer should re-confirm exact line numbers before editing (cheap `grep`) — a few cited lines shift by ±1–2 across files, and S243's copyright normalization re-numbered some headers.

---

## 5. The Recommended Single Convention

A follow-on session should converge every block onto this template (the `getSpeciesGestation.R` shape):

```r
## Copyright(c) 2017-2026 R. Mark Sharp        # ← ABOVE the block, plain ## comments
## This file is part of nprcgenekeepr
                                                # ← one blank line
#' Imperative title, sentence case, no period   # implicit @title (no \code{} markup)
#'
#' One or more description paragraphs.           # implicit @description (no explicit tag)
#'
#' @details ...                                  # only if needed
#' @param x   Description of x.                   # one per formal, signature order
#' @param y   Description of y.
#' @return Description of the return value.       # AFTER @param; spelled @return
#' @seealso \code{\link{relatedFn}}              # single tag; raw Rd inline markup
#' @family <cluster>                              # optional, staged later
#' @importFrom pkg fn1 fn2                        # grouped, before @export
#' @export                                        # OR @noRd (helpers) / @keywords internal (pkg doc only)
#' @examples                                      # LAST; guard ladder: runnable | \donttest | \dontrun
#' someExample()
```

**Inline markup:** raw Rd (`\code{}`, `\link{}`, `\emph{}`) everywhere; keep `markdown = TRUE` enabled but author in Rd. **Internal marking:** `@noRd` for helpers; `@keywords internal` only on the package doc. **Imports:** `@importFrom` (or `pkg::fn`), never `@import`.

**Reference exemplars (use as templates):** `getSpeciesGestation.R`, `getSpeciesMinBreedingAge.R`, `applyKinshipOverrides.R`, `hasInvalidIdChar.R`.

---

## 6. Implementation Roadmap (for the follow-on session)

Staged mechanical-first so each stage is independently verifiable; `man/` regenerates via `devtools::document()`. **`R/` + `man/` ship → every doc edit re-stales the `--as-cran` gate (Learning 226/227) → re-gate after.** Consider splitting across sessions ("1 and done").

1. **Defects first (highest value, mostly mechanical):** D1 `calcGU` description; D2 duplicate `_PACKAGE`; D3 escaped-brace lists → real `\itemize{\item …}`; D4 nonexistent-`candidates` `@param`; D5 wrong `@return` text; D6 title typos; D7 dead imports; D8 bare-blank-line breaks. → re-`document()`, re-gate.
2. **Copyright-placement sweep (Finding 8, scriptable):** move the `##` pair above each block. Highest volume, deterministic.
3. **Block-order normalization (Finding 2):** move `@return` after `@param`; fix `@examples`/`@export` ordering. Largely scriptable with per-file review.
4. **Markup unification (Finding 4):** convert the 48 stray backticks → `\code{}` (37 files). Small, safe.
5. **Import conversion (Finding 7):** 8 easy `@import` → `@importFrom`; verify `shiny`/`Matrix` separately.
6. **Internal-marker cleanup (Finding 5):** drop redundant `@keywords internal` from the two `mod`/`readFocal` files.
7. **Examples policy (Finding 1 / §7):** add `@examples` to the ~7 callable utilities; document the Shiny/app exemption.
8. **Title voice + de-duplication (Findings 3, 6 — judgment-heavy, last):** imperative-voice rewrites; `@inheritParams` donors; `@family` clusters. Per-file human review; not bulk-scriptable.

---

## 7. Examples-Coverage — Corrected Finding (transparency)

An initial mechanical count (and the synthesis built on it) claimed **166/167** exported functions had `@examples`, listing `withinIntegerRange.R` as the lone gap. The **adversarial verification pass flagged this as false**, and firsthand re-verification confirmed: `withinIntegerRange.R:19` **has** `@examples`, and **22** exported files lack one. **True coverage: 145/167 (~87%).**

The 22 gaps cluster, and most are a **defensible exemption**:

- **Shiny `mod*` modules (9):** `modBreedingGroups`, `modGeneticValue`, `modGvAndBgDesc`, `modInput`, `modORIPReporting`, `modPedigree`, `modPotentialParents`, `modPyramid`, `modSummaryStats` — framework-invoked, not directly callable.
- **App entry points (2):** `appUI`, `appServer`.
- **QC / tab UI builders (4):** `getChangedColsTab`, `getErrorTab`, `shouldShowChangedColsTab`, `processQcStudbookResult`.
- **Callable utilities that arguably SHOULD have examples (7):** `loadSiteConfig`, `loadSpeciesOverrides`, `saveDataframesAsFiles`, `getPotentialParents`, `makeGroupMembers`, `makeGroupNum`, `makeSimPed`.

**Recommendation:** state an explicit policy — **exempt** Shiny `mod*` UI/Server + app entry points (+ pure-UI tab builders) from the `@examples` requirement and document why; **add** examples to the 7 callable utilities. Do **not** chase a literal 167/167.

---

## 8. Items Audited & Coverage

| Area | Items | Coverage |
|---|---|---|
| `R/*.R` mechanical grep counts | 226 / 226 | 100% |
| `R/*.R` structured per-function deep read | 225 / 226 | 100% of function-bearing files (package-doc stub has no function record) |
| Headline defect claims firsthand re-verified | D1, D2, D3, examples-coverage, set_seed `@returns` | yes |
| `man/*.Rd` rendered-output spot checks | `calcGU.Rd`, `convertSexCodes.Rd` | confirmed defects reach shipped docs |

**Adversarial verification verdict:** *sound-with-minor-corrections* — 10 of 11 evidence spot-checks passed firsthand; the one failure (examples coverage) is corrected in §7; severity calibration adjusted (examples → moderate finding not strength; copyright-placement → "high-volume / low-impact" moderate, with the genuinely-impacting bare-blank-line defects broken out as D8).

---

## 9. Notes & Constraints for the Implementer

- **CRAN gate:** `R/` and `man/` ship in the tarball, so any doc edit re-stales the documented `--as-cran` gate (0/0/2). Re-run `R CMD build .` + `R CMD check --as-cran` from the package root after each implementation stage (Learning 226/227).
- **Process-tag hygiene:** newer `@noRd` blocks cite GitHub issue/"Slice" numbers (`checkFgDegeneracy.R:7`, `classifyParentage.R:10`). These are `@noRd` (non-rendering) so out of S239's published-surface scope — but if the implementer touches those blocks, prefer not to reintroduce dev-process tags into any *rendered* surface ([[keep-dev-process-refs-out-of-user-docs]]).
- **Spelling:** fixing the title typos (D6) changes prose; re-run `spell_check_package` and hand-add any new legitimate terms to the wordlist (never `update_wordlist` — [[avoid-reconcile-tools-on-curated-files]]).
- **This is analysis only.** No `R/` was modified in this session.
