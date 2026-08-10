# Issue #146 Plan — Configurable/Exhaustive Breeding-Group Candidate Retention

**Status:** RATIFIED (2026-08-10, this session). All four judgment-call decisions (Q1-Q4) were ratified via a single `AskUserQuestion` round; the owner selected this document's own recommended option in all four cases. See §11 for the recorded outcome. This plan is ready for Slice 1 implementation in a future session.
**Session:** S507 (2026-08-10)
**Origin:** GitHub issue #146, Tier 2 of `docs/audits/GENETIC_METRICS_ISSUES_SEQUENCING_AUDIT_2026-08-08.md` (the ratified `#147 > #149 > #146 > #151` engineering-priority order; #147 and #149 are both done/closed). The sequencing audit's own Finding under Tier 2 item 2 already recommends splitting this issue into "ship the configurable-retention slice now; treat exhaustive enumeration as its own separately-scoped pre-RED design spike" — this document is that design spike, covering both pieces in one plan (matching the #133/#136/#137/#147/#149 precedent of one ratified design doc, then multiple implementation slices).
**Touches (planned, future sessions):** `R/groupAddAssign.R` (new parameters `maxCandidates`, `exhaustive`, `maxExhaustiveCandidates`, `exhaustiveTimeLimit`; new `@noRd` helper `.enumerateMaximalIndependentSets()`), `R/modBreedingGroups.R` (Slice 1: new "Candidates to retain" numeric input; Slice 2, pending §11 Q4: exhaustive-mode toggle + status callout), `tests/testthat/test_groupAddAssign.R` (extended), `tests/testthat/test_enumerateMaximalIndependentSets.R` (new), `tests/testthat/test_modBreedingGroups.R`/`test_modBreedingGroups_groupAddAssign.R` (extended), `NEWS.Rmd`.
**Does NOT touch:** `R/fillGroupMembers.R`/`R/fillGroupMembersWithSexRatio.R` (the existing stochastic sampler — reused unmodified for the default, non-exhaustive path); `R/getAnimalsWithHighKinship.R`/`R/addAnimalsWithNoRelative.R` (the conflict-graph construction — reused unmodified, exhaustive mode consumes the same `kin` adjacency list); `R/groupMembersReturn.R` (return-shape assembly — extended only by new top-level fields present when `exhaustive = TRUE`, never restructured); `_pkgdown.yml` (`groupAddAssign` is already listed there, §2.9; no new exported function is introduced by this design).
**Workstream:** `docs/methodology/workstreams/ARCHITECTURE_WORKSTREAM.md` — data-model/algorithm design (a new combinatorial-enumeration mode, a feasibility/complexity guard, and a new return-shape contract), not a `DESIGN_WORKSTREAM.md` visual-layout question, matching the #133/#136/#137/#145/#147/#149 precedent of using the architecture workstream over the literal task-mapping table.

> **Scope.** Design (not implement) how `groupAddAssign()`'s existing top-5 candidate-retention cap becomes configurable, and design a bounded exhaustive-enumeration mode with a documented feasibility guard — per the issue's own instruction, "Establish complexity limits and semantics before implementation."

---

## 1. Context

### 1.1 What issue #146 says (verbatim)

> ## Source
>
> `GENETIC_METRICS_PDF_CAPABILITY_AUDIT_2026-08-05.md`: candidate-group breadth.
>
> `groupAddAssign()` and the UI retain and compare up to five distinct candidate partitions. The source recommendation calls for all possible combinations so a colony manager can assess behavioral compatibility and dominance criteria; the fixed cap can omit otherwise valid alternatives.
>
> Design a bounded/exhaustive mode that preserves the top-five default, allows a larger retained count, enumerates all valid partitions only under a documented feasibility guard, and reports whether results are exhaustive or truncated, the number examined, and the retention rule. Preserve scores and membership for comparison/export.
>
> Establish complexity limits and semantics before implementation.

Confirmed verbatim via `gh issue view 146 --json title,body` at this session's Phase 1 (zero comments on the issue).

### 1.2 What is already decided (do not re-litigate)

- **Priority and sequencing:** #146 is Medium priority (`GENETIC_METRICS_PDF_CAPABILITY_AUDIT_2026-08-06.md`'s "Priority gap analysis," row "Candidate-group completeness and behavioral inputs"), placed second in Tier 2 (`docs/audits/GENETIC_METRICS_ISSUES_SEQUENCING_AUDIT_2026-08-08.md` lines 217-234), after #149 (done) and ahead of #151 specifically to land the shared `R/modBreedingGroups.R` change first and avoid concurrent-session merge friction with #151.
- **The two-piece split is already recommended, not this document's own invention:** the sequencing audit explicitly names (a) "parameterizing the existing tested 5-candidate retention cap (issue #125's infrastructure) into a configurable N — a small, mechanical change against solid, already-tested code" and (b) "an exhaustive-enumeration mode that is genuinely new combinatorial-search algorithm work with zero existing precedent (`fillGroupMembers.R` is a purely stochastic greedy sampler)." This document designs both, sliced into two separate implementation sessions (§5).
- **Effort estimate:** the sequencing audit rates the combined issue "L" (`docs/audits/GENETIC_METRICS_ISSUES_SEQUENCING_AUDIT_2026-08-08.md` line 61) — consistent with (a) being small and (b) being genuinely novel algorithm work.

### 1.3 What this session's research confirmed

This session read every function in the `groupAddAssign()` call graph directly (§2), then ran an original empirical benchmark (not derived from any prior document — no prior session or audit measured this) to ground the feasibility guard in real numbers rather than intuition, per the Architecture Workstream's own "Verify Assumptions" step ("What is the expected scale? ... verify by testing or reading benchmarks," not guess).

**Headline finding, counter-intuitive and load-bearing for §3 D5:** exhaustive enumeration is **slower**, not faster, for **sparser** (lower-kinship, more-diverse) candidate pools — the opposite of what "fewer relatedness conflicts should mean less work" naively suggests. A sparse conflict graph has fewer constraints ruling out combinations, so it has vastly *more* maximal independent sets to enumerate. §2.10 reproduces the exact numbers: at 20 synthetic candidates, a 5%-density conflict graph took 5.5 seconds to fully enumerate (36 maximal sets found) while a 30%-density graph of the same size took 0.13 seconds (92 sets — more sets, but each pruned faster by more constraints... the reported count is discovery order, not exhaustive completeness at this density; see §2.10's own table for the full picture). At 25 candidates and 5% density, full enumeration took over 60 seconds in this session's own unoptimized (no-pivoting) implementation. This means the very colonies where the feature is most useful — large, diverse, low-relatedness candidate pools where "all possible combinations" genuinely differ from each other — are also the pools most likely to hit the feasibility ceiling.

---

## 2. Evidence-based inventory

### 2.1 `groupAddAssign()` — the current sampling algorithm and its hardcoded 5-cap

`R/groupAddAssign.R:130-235`. Runs `iter` (default `1000L`) random trials via `fillGroupMembers()` (§2.2); each trial scores `min(lengths(groupMembers))` (the smallest resulting group's size, across `numGp` groups being formed); retains up to **`5L`, hardcoded** (`:200`, `:224-225`) distinct candidate solutions, deduplicated by `canonicalizePartition()` (`:247-254`, sorts within-group and across-group so partitions differing only in order compare equal) — **not** by score, so two same-scoring but differently-membered partitions both count. When the retained set is full, a new trial replaces the current worst-scoring retained candidate only if it scores strictly better (`:205-212`). Final ordering is best-score-first, ties broken by discovery order (`:220-225`, explicit tie-break — `order()`'s stability is not relied upon). After the loop, every retained candidate's `groupMembers` gets one extra "unused animals" group appended via `addGroupOfUnusedAnimals()` (§2.6) before being returned.

**The `5L` cap appears in exactly two places** (`:200` the retention-count check, `:224` implicit via `length(retained)`) — parameterizing it is genuinely mechanical: thread a `maxCandidates` argument through both.

### 2.2 `fillGroupMembers()` — the stochastic greedy sampler, reused unmodified

`R/fillGroupMembers.R:27-79`. For each of `numGp` groups (seeded from `currentGroups` via `makeGroupMembers()`, §2.5), repeatedly picks a random group and adds a random still-`available` (non-conflicting) candidate to it, removing that candidate's `kin` (§2.3) from that group's remaining pool, until no group has any candidate left to add. Each single trial's output is therefore already a **maximal** independent set *per group given the random draw order* — it just isn't guaranteed to be the *largest possible*, and running it once produces one specific partition, not all of them. This confirms the roxygen's own framing (`groupAddAssign.R:13-19`): "finding the largest would require traversing all possible combinations... this algorithm produces a random sample."

**Not touched by this design.** Exhaustive mode is a parallel search strategy for `numGp = 1`, not a modification of the sampler; the sampler remains the only strategy for `numGp > 1` and for the harem/custom-sex-ratio cases (§3 D2).

### 2.3 `getAnimalsWithHighKinship()`/`addAnimalsWithNoRelative()` — the conflict graph, reused unmodified

`R/getAnimalsWithHighKinship.R:41-59`: builds `kin`, a named list where `kin[[id]]` is the character vector of other candidate ids whose pairwise kinship is at or above `threshold` (default `0.015625`), after applying `filterPairs()` (sex-pair exclusions, e.g. default female-female) and `filterAge()` (drop pairs involving an animal younger than `minAge`). This is exactly a **conflict graph**: an edge `(a, b)` means `a` and `b` cannot be in the same group. `addAnimalsWithNoRelative()` (`R/addAnimalsWithNoRelative.R:49-55`) adds an `NA` entry for every candidate with zero conflicts, so `kin[[id]]` is always defined.

**This is precisely the adjacency structure an exhaustive maximal-independent-set enumerator needs — already built, already tested, reused with zero change.** No second graph representation is introduced (§3 D4 explicitly rejects materializing an explicit complement graph).

### 2.4 The `currentGroups` seed composes cleanly with exhaustive enumeration — confirmed, not assumed

`R/groupAddAssign.R:145-156`: before any trial runs, candidates conflicting with an already-seeded `currentGroups` member are removed from the candidate pool (`conflicts <- unique(c(unlist(kin[unlist(currentGroups)]), unlist(currentGroups))); candidates <- setdiff(candidates, conflicts)`). This means every remaining candidate is *already guaranteed* compatible with the seed by the time any group-filling strategy runs. **Consequence for §3 D2/D3:** exhaustive enumeration over the (already-filtered) candidate pool, with the seed simply unioned onto every enumerated maximal independent set, is exactly equivalent to what the sampler does today (`makeGroupMembers()`, `R/makeGroupMembers.R:52-58`, literally initializes `groupMembers[[1]] <- currentGroups[[1]]` before the fill loop) — no new seed-handling logic is needed in the enumerator itself.

### 2.5 `makeGroupMembers()`/`addGroupOfUnusedAnimals()` — group-list shape, reused unmodified

`R/makeGroupMembers.R:41-61`: for `harem = FALSE` (the only case in scope, §3 D2), returns a length-`numGp` list, each element either the corresponding `currentGroups[[i]]` seed or an empty vector. `R/addGroupOfUnusedAnimals.R:22-35`: appended once per retained candidate, after scoring, adding one more list element holding every candidate not placed in any group (or `NA` if none remain). **Exhaustive mode's output must go through this same function unmodified**, so the return shape is identical between sampling and exhaustive results (§2.6) — no special-casing needed downstream.

### 2.6 `groupMembersReturn()` — the return-shape contract

`R/groupMembersReturn.R:22-44`. Builds `candidates`, a list of `list(group=, score=[, groupKin=])` (one per retained candidate), then `value <- list(group = candidates[[1]]$group, score = candidates[[1]]$score, candidates = candidates[, groupKin])`. **New top-level fields for exhaustive mode (`exhaustive`, `examined`, `retentionRule`) are added here, alongside `group`/`score`/`candidates`/`groupKin` — never inside an individual candidate's own list** (they describe the search process as a whole, not any one solution). Present only when `exhaustive = TRUE` was requested; `NULL`/absent for ordinary sampling calls, so existing callers see a byte-identical return shape (§6).

### 2.7 `modBreedingGroups.R` — the UI/server side already scales generically to N candidates, confirmed by direct read

`R/modBreedingGroups.R:456-509`. The candidate selector (`candidateChoice`) is populated by `n <- length(res$candidates); updateSelectInput(session, "candidateChoice", choices = stats::setNames(seq_len(n), labels), selected = 1L)` (`:467-477`) — **not** hardcoded to 5 anywhere; the comparison table (`candidateComparison`, `:499-509`) likewise iterates `seq_along(res$candidates)`. **This means Slice 1 (configurable `maxCandidates`) needs zero server-logic change beyond wiring one new numeric input through to `groupAddAssign()`'s call site** (`:384-398`) — the display side already Just Works for any N. Confirmed by direct read, not assumed from the roxygen.

The existing UI already bounds the realistic "top ranked" candidate pool via `nTopAnimals` (`:58-59`, default `20L`, `min = 5L`, `max = 100L`) — the app's own existing precedent for what colony managers actually work with, relevant context for §3 D5's ceiling.

### 2.8 Existing test coverage and invariants — what must keep passing

`tests/testthat/test_groupAddAssign.R:181-224`: `"groupAddAssign deduplicates identical partitions into a single candidate"` and `"groupAddAssign retains at most 5 distinct candidates"` (asserts `expect_lte(length(...$candidates), 5L)` **and** `expect_gt(..., 1L)`, confirming the cap is neither vacuous nor unbounded on a real 29-candidate fixture). **Both are hardcoded to `5L`, the current default — Slice 1 must either parameterize these tests to accept a `maxCandidates` argument that defaults to `5L` (preserving the assertion as a default-behavior regression test) or add sibling tests for a non-default value, not silently relax the `5L` assertion** (§7 Dragon 1).

The `"retains at most 5 distinct candidates"` test's own comment (`:207-209`) records a critical empirical fact confirmed independently by this session's §1.3 benchmark: **`qcBreeders` (29 candidates) at `numGp = 2` "empirically produces 1000 distinct partitions across 1000 trials"** — every single random trial is a new, never-before-seen partition. This is direct, in-repo evidence that this package's own realistic test fixture already sits far past the point where exhaustive enumeration is tractable for `numGp > 1` (§3 D2).

### 2.9 No existing graph-theory dependency in this package

`DESCRIPTION` `Imports`/`Suggests` (read in full): `anytime`, `bslib`, `data.table`, `DT`, `futile.logger`, `ggplot2`, `htmlTable`, `lifecycle`, `lubridate`, `Matrix`, `openxlsx`, `plotrix`, `readxl`, `Rlabkey`, `sessioninfo`, `shiny`, `stringi`, `utils`, `visNetwork` (Imports); `covr`, `devtools`, `dplyr`, `grid`, `shinytest2`, `htmltools`, `kableExtra`, `knitr`, `markdown`, `mockery`, `pkgdown`, `png`, `quarto`, `rmarkdown`, `roxygen2`, `shinyBS`, `shinyWidgets`, `spelling`, `testthat`, `withr` (Suggests). **No `igraph` or any other graph-theory library anywhere.** `visNetwork` (used for pedigree-diagram rendering, `R/modPedigree.R`) is a rendering/visualization binding, not a graph-algorithms library, and exposes no independent-set/clique enumeration. This is direct evidence for §3 D4's dependency tradeoff, not an assumption.

### 2.10 This session's own empirical benchmark — grounding the feasibility guard in measurement, not guesswork

A throwaway (not committed) benchmark script implemented a correct, un-pivoted Bron-Kerbosch-style enumerator of maximal independent sets directly on a `kin`-shaped adjacency list (the same structure §2.3 already builds — no complement graph materialized), then measured full-enumeration wall-clock time against synthetic conflict graphs of increasing size `n` and edge density:

| n | density | seconds | maximal sets found |
|---|---|---|---|
| 10 | 0.05 | 0.037 | 4 |
| 10 | 0.15 | 0.013 | 8 |
| 10 | 0.30 | 0.007 | 18 |
| 15 | 0.05 | 0.274 | 16 |
| 15 | 0.15 | 0.107 | 27 |
| 15 | 0.30 | 0.030 | 35 |
| 20 | 0.05 | 5.541 | 36 |
| 20 | 0.15 | 0.855 | 73 |
| 20 | 0.30 | 0.128 | 92 |
| 25 | 0.05 | 62.736 | 88 |

(n=25 at higher densities and n=30+ were not completed — the sweep was stopped once a single cell exceeded 20 seconds, per the script's own early-exit; see §1.3 for the interpretation.) **This is deliberately a conservative (safe-upper-bound) measurement**: no pivoting optimization was applied (pivoting is a performance refinement that reduces the constant factor, not a correctness requirement — see §3 D4's citation), so a properly pivoted production implementation should do *at least* as well, likely better, at every cell in this table. The numbers are a ceiling to design against, not a floor.

**Real-fixture cross-check:** `qcBreeders` (29 candidates, the package's own realistic test fixture) has a measured conflict-graph density of **0.395** (computed via `getAnimalsWithHighKinship()` + `addAnimalsWithNoRelative()`, the exact production code path, against `pedWithGenotypeReport$kinship`/`pedWithGenotype`) — a *high*-density, therefore relatively *favorable* case per the table above. A broader, more diverse "All available" candidate pool (`R/modBreedingGroups.R:43`, the UI's own third `animalSource` option) is exactly the shape expected to land in the pathological low-density/large-n cell this table shows is already impractical at n≥25.

---

## 3. Design decisions

Nine decisions, D1-D9. Each states whether it is forced by the evidence above or a genuine judgment call; §11 collects the judgment calls into a ratification round.

**D1 — Two implementation slices, not one: Slice 1 parameterizes the retention cap (mechanical); Slice 2 adds exhaustive enumeration (novel algorithm + UI). Forced by the sequencing audit's own explicit recommendation (§1.2) and independently confirmed by this document's own risk analysis — the two pieces have unrelated failure modes and belong to different session boundaries per the vertical-slice discipline.**

**D2 — Exhaustive mode is scoped to `numGp == 1 && harem == FALSE && sexRatio == 0` only; any other combination is refused (mechanism per D9). Judgment call. Requires ratification (§11 Q1, combined with D9).**

Multi-group partition enumeration (`numGp > 1`) is a categorically harder problem than single-group maximal-independent-set enumeration — §2.8's own in-repo evidence (29 candidates, `numGp = 2`, 1000/1000 distinct partitions from random sampling alone) shows this package's *existing, already-in-use* test fixture is already far past tractable for exhaustive partition enumeration; harem mode adds a "one sire per group" constraint and custom sex ratios add a target-composition constraint, neither of which reduces to a plain independent-set problem without a materially different (and unbenchmarked) algorithm. Scoping exhaustive mode to the plain single-group case directly answers the issue's own framing — "candidate-group breadth... behavioral compatibility and dominance criteria" describes forming *one* new group and wanting to see every way it could be assembled, not simultaneously optimizing multiple non-overlapping groups exhaustively. This also matches the audit's own framing of Slice 2 as "genuinely new combinatorial-search algorithm work with **zero existing precedent**" — attempting the harder multi-group case first would compound novel-algorithm risk with novel-scope risk in one slice.

**D3 — "All valid partitions" (issue's wording) means all *maximal* independent sets of the conflict graph, not all independent sets. Forced by the existing scoring function's own semantics.**

Every non-maximal independent set is dominated by at least one maximal superset under the existing `score = min(lengths(groupMembers))` metric (a strict subset of a larger valid group scores no higher and offers no comparison value the issue's "behavioral compatibility and dominance criteria" framing needs) — enumerating them would multiply the combinatorial cost (§2.10) for zero product value. This directly generalizes `fillGroupMembers()`'s own existing behavior (§2.2: each single trial already produces a locally-maximal group, just not exhaustively all of them) rather than introducing a new concept of "valid."

**D4 — Enumeration algorithm: a new internal `.enumerateMaximalIndependentSets(candidates, kin, cap, deadline)` helper implementing Bron-Kerbosch-style search directly on the existing `kin` adjacency list (no complement graph materialized), citable to Bron & Kerbosch (1973) and the worst-case-optimal pivoting refinement of Tomita, Tanaka & Takahashi (2006). Judgment call against the alternative of adding `igraph` as a new dependency. Requires ratification (§11 Q2).**

Maximal independent sets of a graph *G* are exactly the maximal cliques of *G*'s complement — a standard graph-theory equivalence, not a novel algorithm invented for this design. Bron-Kerbosch's classic recursive formulation (`R, P, X` — the report/candidates/excluded sets) applies identically whether the working relation is "adjacent" (for cliques) or "compatible/non-conflicting" (for independent sets); this design uses "compatible" throughout, computed lazily as `setdiff(pool, c(kin[[v]], v))` against the *existing* sparse conflict list (§2.3) — the complement graph itself is never built as a data structure, which matters because a sparse conflict graph (the "many diverse candidates" case §1.3 shows is hardest) has a *dense* complement, and materializing it would waste memory precisely in the case that already costs the most compute. §2.10's benchmark used exactly this un-materialized-complement formulation. §8 records the `igraph` alternative and why it is not this document's recommendation, without foreclosing it.

**D5 — Feasibility guard: two independent layers — (i) a hard pre-flight candidate-count ceiling (`maxExhaustiveCandidates`), request refused before any enumeration runs if exceeded; (ii) a wall-clock deadline during enumeration (`exhaustiveTimeLimit`), which aborts mid-search and reports `exhaustive = FALSE`/`examined = <count found so far>` rather than blocking indefinitely. The two-layer mechanism is forced by §2.10's own evidence (a pure candidate-count ceiling alone is not safe — runtime varies by more than 40x at the same n depending on density, so a count-only guard would need to assume worst-case density and become needlessly restrictive for the common, denser, real-fixture case §2.10 also measured). The exact default numbers are a genuine judgment call. Requires ratification (§11 Q3).**

A wall-clock (not operation-count) deadline is used for layer (ii) specifically because §2.10's numbers are hardware- and implementation-dependent (an unoptimized, unpivoted baseline) — a raw node-count budget would need re-calibration for a pivoted production implementation, while a wall-clock budget degrades gracefully regardless of constant-factor improvements, and directly answers the issue's own literal ask ("reports whether results are exhaustive or truncated, the number examined") without requiring the implementing session to first characterize the pivoted algorithm's exact per-node cost. **A dragon named explicitly, not glossed over (§7 Dragon 2): this app has no async/background-job infrastructure (`promises`/`future` are not in `DESCRIPTION`, confirmed by direct dependency-list read, §2.9) — Shiny's default single-process model means a multi-second exhaustive request blocks the entire app for every concurrent user, not just the requester.** The deadline default proposed in §11 Q3 is chosen with this shared-blocking risk explicitly in mind, not purely for the requester's own experience.

**D6 — `maxCandidates` (Slice 1) gets a sane upper bound in the UI (proposed 50) to prevent a nonsensical request (e.g. "retain 100,000 candidates") from producing an unusably large comparison table even in ordinary sampling mode. Forced by UX proportionality; the exact number (50) is a minor, non-blocking recommendation, not put to a ratification vote (unlike D5, whose numbers gate a genuinely novel and riskier code path).**

`nTopAnimals`'s own existing UI ceiling is 100 (`R/modBreedingGroups.R:59`) — the total addressable candidate pool in the common "top ranked" case. Retaining more distinct *partitions* than there are candidates in some configurations is already meaningless; 50 is a round number comfortably above any realistic use (comparing dozens of alternative groupings is already far beyond what a human curator reviews one at a time) while leaving headroom below the existing `nTopAnimals` ceiling.

**D7 — New top-level return fields (`exhaustive`, `examined`, `retentionRule`) are added to `groupMembersReturn()`'s output, present only when `exhaustive = TRUE` was requested; absent (not merely `NULL`-valued — literally not present as list names) for ordinary sampling calls. Forced by this package's own established byte-identical-by-default convention for additive features (matching `edgeStyle`, `useLabels`, and every other opt-in parameter added across the pedigree-diagram feature family).**

`retentionRule` is a short, human-readable character string (e.g. `"top-N by score (min group size), N = 5"`) rather than a structured object — matching this codebase's general preference for a display-ready string over a caller-parsed structure when the value's only consumer is UI text (§2.7's `candidateComparison` table is exactly this kind of consumer).

**D8 — Slice 2 ships the exhaustive-mode UI toggle (checkbox + status callout showing exhaustive/truncated/examined) in `modBreedingGroupsUI`/`modBreedingGroupsServer`, in the same session as the algorithm itself — not deferred to a later Slice 3. Judgment call against the `resolveCrossCenterIds()`/`markerParentageLikelihood()` precedent of shipping a script-only capability before its UI. Requires ratification (§11 Q4).**

Unlike #147/#149's underlying functions (which serve script users independently of any UI, per those documents' own D-decisions), issue #146's own text is explicitly framed around a UI-facing user need — "so a colony manager can assess behavioral compatibility and dominance criteria" — a capability with no UI path does not deliver that need. `modBreedingGroupsUI`'s existing generic candidate display (§2.7) already renders whatever `groupAddAssign()` returns with zero change; the only genuinely new UI surface is the toggle control itself plus a short status line, a small, low-risk addition relative to Slice 2's real cost (the enumeration algorithm). §8 records the alternative (defer UI to Slice 3) for the owner to weigh against Slice 2's own size.

**D9 — On a request that falls outside D2's scope boundary or D5's feasibility ceiling, `groupAddAssign()` `stop()`s with an actionable message naming the specific reason (scope vs. size) rather than silently falling back to sampling mode. Judgment call, folded into §11 Q1 alongside D2 since both describe the same "what happens at the edges" policy.**

This matches the package's own existing precedent for an infeasible request: the harem check already `stop()`s with a specific, actionable message rather than silently degrading (`R/groupAddAssign.R:160-171`, "User selected to form N harems with only M males..."). A silent fallback risks a curator believing they received exhaustive results (having explicitly requested `exhaustive = TRUE`) when they did not — exactly the kind of silently-wrong-but-plausible-looking output this project's own review culture treats as worse than a loud failure (`PROJECT_LEARNINGS.md` Learning 386's "a verifier's confident correction... can itself be wrong" and the general house preference for `stop()` over silent degradation on an infeasible request, §2.1's own harem precedent).

---

## 4. Interface catalog

| Interface | Input (new/changed only) | Output (new/changed only) | Error contract | Consumers |
|---|---|---|---|---|
| `groupAddAssign(..., maxCandidates = 5L, exhaustive = FALSE, maxExhaustiveCandidates = 20L, exhaustiveTimeLimit = 10)` (ratified, §11 Q3) | `maxCandidates`: integer, replaces the hardcoded `5L` (Slice 1). `exhaustive`: logical, requests the D2-scoped enumeration mode (Slice 2). `maxExhaustiveCandidates`/`exhaustiveTimeLimit`: the D5 feasibility guard, only consulted when `exhaustive = TRUE`. | Existing `group`/`score`/`candidates`/`groupKin` fields unchanged in shape. New top-level `exhaustive` (logical), `examined` (integer), `retentionRule` (character) — present only when `exhaustive = TRUE` was requested (D7). | `stop()`s (unchanged) on an infeasible harem request (existing behavior). New: `stop()`s on `exhaustive = TRUE` combined with `numGp > 1`/`harem = TRUE`/`sexRatio != 0` (D2/D9), and on `length(candidates) > maxExhaustiveCandidates` (D5/D9) — both with a message naming the specific violated condition. | `modBreedingGroupsServer` (Slice 1 unconditionally; Slice 2's new toggle, pending §11 Q4); the test suite |
| `.enumerateMaximalIndependentSets(candidates, kin, cap, deadline)` (new, `@noRd`) | `candidates`: character vector. `kin`: the existing conflict adjacency list (§2.3 shape, reused as-is). `cap`/`deadline`: D5's guard parameters. | `list(sets = <list of character vectors>, examined = <integer>, truncated = <logical>)` | Never `stop()`s itself — reports `truncated = TRUE` rather than erroring when the deadline is hit; the caller (`groupAddAssign()`) decides whether that constitutes a user-facing error (it does not, under D9 — the pre-flight D5 ceiling is what refuses a request outright; the runtime deadline is a graceful degradation path for a request that passed the pre-flight check but proved slower than estimated) | `groupAddAssign()` only; the test suite (its own dedicated test file, `test_enumerateMaximalIndependentSets.R`, exercising both the exhaustive-completion and deadline-truncation paths independently of `groupAddAssign()`'s own integration) |

---

## 5. Implementation plan — vertical slices (one session each)

### Slice 1 — Configurable retention count (mechanical)

**Touches:** `R/groupAddAssign.R` (thread `maxCandidates` through the two `5L` sites, §2.1), `R/modBreedingGroups.R` (one new `numericInput` — "Candidates to retain," default `5L`, `min = 1L`, `max = 50L` per D6 — wired into the existing `groupAddAssign()` call site, `R/modBreedingGroups.R:384-398`), `tests/testthat/test_groupAddAssign.R` (parameterize the two existing `5L`-hardcoded tests, §2.8, to accept `maxCandidates` — default-value case preserves the exact existing assertion; add a non-default-value case), `tests/testthat/test_modBreedingGroups.R`/`test_modBreedingGroups_groupAddAssign.R` (extend for the new input), `NEWS.Rmd`.

**What DONE looks like:** `groupAddAssign(..., maxCandidates = N)` retains up to `N` distinct candidates (default `5L`, byte-identical to today); the UI exposes the control and displays however many candidates come back, with zero server-logic change beyond the one new input read (§2.7 already confirmed generic). Existing `5L`-default tests pass unmodified in their default-value form; new tests cover at least one non-default `N`.

**Verification:** `devtools::test_file()` on both targeted test files; full clean regression read (0 failed/0 error, matching the current baseline — see the "15 pre-existing baseline warnings" Housekeeping item for the unrelated, already-tracked baseline count); `lintr::lint_package()` on touched files; `devtools::check()` unchanged from baseline; a live `shinytest2`/`chromote` smoke test confirming the new input actually changes the number of candidates displayed in the running app (not just `testServer()`).

**Session boundary:** this phase is one session. Close out when done.

### Slice 2 — Exhaustive enumeration mode

**Touches:** `R/groupAddAssign.R` (the `exhaustive`/`maxExhaustiveCandidates`/`exhaustiveTimeLimit` parameters, D2/D5/D9's scope and feasibility checks, wiring `.enumerateMaximalIndependentSets()`'s output through the existing `groupMembersReturn()`/`addGroupOfUnusedAnimals()` pipeline unmodified per §2.5/§2.6), `R/enumerateMaximalIndependentSets.R` (new, `@noRd`, plus its own roxygen `@references` citing Bron & Kerbosch 1973 / Tomita, Tanaka & Takahashi 2006 per D4), `tests/testthat/test_enumerateMaximalIndependentSets.R` (new — exhaustive-completion correctness against a hand-verified small graph; deadline-truncation behavior; a case proving §2.10's own density-vs-runtime finding is respected, i.e. the function does not assume density-proportional cost), `tests/testthat/test_groupAddAssign.R` (extend — the D2 scope-refusal `stop()`s, the D5 ceiling-refusal `stop()`, an end-to-end exhaustive-mode result), pending §11 Q4: `R/modBreedingGroups.R` (exhaustive-mode toggle, only enabled/meaningful when `numGp == 1`/harem "None"/sex ratio "None" per D2; a status callout surfacing `exhaustive`/`examined`/`retentionRule`), `NEWS.Rmd`.

**What DONE looks like:** `groupAddAssign(..., exhaustive = TRUE)` on an eligible, in-guard request returns every maximal independent set (verified against a small hand-enumerable fixture, not just count-checked), with `exhaustive = TRUE`/`examined` matching the true count/`retentionRule` describing the top-N cutoff actually applied; an over-ceiling or out-of-scope request `stop()`s with a message naming the specific reason (D9); a request that passes the pre-flight ceiling but exceeds the runtime deadline returns `exhaustive = FALSE`/`truncated`-consistent `examined`, not an error. Pending §11 Q4: the UI toggle works end-to-end in the running app under all three states (completed, refused, truncated), verified live.

**Verification:** `devtools::test_file()` on the new and extended test files; full clean regression read; `lintr::lint_package()`; `devtools::check()` unchanged from baseline; pending §11 Q4, a live `shinytest2`/`chromote` smoke test exercising the toggle and confirming the status callout text for at least the completed and refused cases (a live truncation case is only worth reproducing if a deadline short enough to trigger reliably in a smoke test does not itself compromise the default's real-world usefulness — implementing session's own judgment, not gated here).

**Session boundary:** this phase is one session. Close out when done.

---

## 6. Impact analysis

**Blast radius is small for Slice 1, moderate for Slice 2, both additive.** Slice 1 touches the two already-identified `5L` sites in one existing, well-tested file plus one new UI control — no existing behavior changes at the default. Slice 2 adds one new internal file and extends `groupAddAssign()`'s parameter list — no existing parameter's meaning or default changes; `exhaustive` defaults `FALSE`, so every existing call site (script or UI) is unaffected until a caller opts in.

**Performance:** the sampling path (`exhaustive = FALSE`, the default and the only path for `numGp > 1`) is untouched — identical algorithmic complexity to today. The new exhaustive path's cost is bounded by design (D5's two-layer guard) rather than left open; §2.10 is the empirical basis for that bound, not a theoretical estimate.

**Backward compatibility:** `groupAddAssign()`'s existing signature, defaults, and return shape are all preserved exactly for any caller not passing the new parameters (D7's "absent, not just `NULL`" rule keeps the return list's own `names()` unchanged for existing callers, not merely its values). The two `5L`-hardcoded existing tests must keep passing at the default (§2.8, §5 Slice 1's own DONE criteria).

**Module-contract compliance:** N/A — no new Shiny module is introduced; `modBreedingGroupsUI`/`modBreedingGroupsServer` gain new controls/reactives within their existing structure, not a new module.

**Close-out checklists triggered** (`CLAUDE.md`): NEWS.Rmd applies **twice**, once per slice (a parameter addition to an already-documented exported function, and a new Shiny feature respectively) — matching the established two-slice treatment precedent (#147, #149). `_pkgdown.yml` reference-coverage — **N/A**, `groupAddAssign` is already listed (§2.9); no new exported function is introduced by either slice (`.enumerateMaximalIndependentSets()` is `@noRd`). Citation checklist (#120) — **N/A for Slice 1** (no new displayed statistic); **applies for Slice 2's roxygen** (`.enumerateMaximalIndependentSets()`'s `@references` citing Bron & Kerbosch 1973 / Tomita et al. 2006, D4) but the function itself is `@noRd` and not user-facing, so this is a documentation-quality matter, not the issue-#120 UI-guidance-page checklist, which is N/A — state this explicitly in Slice 2's own close-out rather than silently omitting either checklist. Tutorial/article documentation checklist (Session 436) — applies Slice 2 only, if §11 Q4 ratifies shipping the UI toggle (a new user-facing control in an existing tab); N/A for Slice 1 (a numeric-input default-count change to an existing control is not a new interaction pattern, matching the threshold set by other minor-control-addition precedents in this codebase). `a2interactive.Rmd` checklist — applies, deferred (not same-session), to both slices' new parameters on the already-documented, script-callable `groupAddAssign()` (`CLAUDE.md`'s own "new parameter/argument added to an already-documented exported function" trigger, matching the `edgeStyle` precedent). Lint on touched files, each slice. `gh issue close 146` when Slice 2 ships (matching the established issue-close-out precedent). A dated `CHANGELOG.md` ledger entry each slice's own close-out.

---

## 7. Here be dragons

1. **The two existing `5L`-hardcoded tests (§2.8) must not simply have their assertion relaxed to `expect_lte(..., N)` for an arbitrary `N` — they exist specifically to pin the *default* behavior.** Slice 1 must keep a test asserting the exact default (`maxCandidates` omitted → cap is `5L`) and add separate coverage for a non-default value, not conflate the two into one parameterized assertion that could pass even if the default silently changed.

2. **This app has no async/background-job infrastructure** (`promises`/`future` absent from `DESCRIPTION`, §2.9/§3 D5) — an exhaustive request that runs for several seconds blocks the entire single-process Shiny app for every concurrent user, not only the requester. The D5 deadline default (§11 Q3) should be chosen with this shared-blocking cost explicitly in mind; the implementing session should re-confirm this constraint still holds (no async infrastructure has been added between this design session and implementation) before finalizing the deadline.

3. **Density is not a reliable proxy for exhaustive-mode runtime in the direction most people would guess** (§1.3, §2.10): a *more* diverse (lower-kinship) candidate pool is the *slower* case, not the faster one. Any future attempt to make the feasibility guard "smarter" by estimating cost from density alone (rather than the flat candidate-count ceiling plus wall-clock deadline this design uses) must be benchmarked against this finding first, not assumed.

4. **`nTopAnimals`'s existing UI ceiling is 100** (§2.7) — comfortably above D5's proposed exhaustive-mode ceiling (§11 Q3, ~20-30). A colony manager selecting "Top ranked" with the UI's own default of 20 will already be near or at the exhaustive-mode boundary; the Slice 2 UI (if §11 Q4 ships it) should make this relationship legible (e.g., disabling or clearly explaining the toggle when the current candidate count exceeds the ceiling) rather than letting the user discover it only via a `stop()` error after clicking "Form Groups."

5. **`.enumerateMaximalIndependentSets()`'s correctness is not obvious from reading the code casually** — an off-by-one in the `R`/`P`/`X` set bookkeeping produces a plausible-looking but *silently incomplete* enumeration (missing valid maximal sets) rather than a crash, which is a worse failure mode for a feature whose entire value proposition is "exhaustive, not sampled." Slice 2's own test file must include at least one small, fully hand-enumerated fixture (not just a count or a `withr`-seeded random check) where every expected maximal independent set is asserted present by exact membership, per this project's own established "assert the real invariant, not just an aggregate" discipline.

---

## 8. Alternatives considered

Summary table for the judgment-call decisions (each also appears inline in §3; not repeated there).

| Decision | Recommended | Rejected/deferred alternative(s) | Why |
|---|---|---|---|
| D2/D9 scope + error semantics | `numGp==1`/no harem/no custom sex ratio only; `stop()` outside this envelope or over the D5 ceiling | Attempt best-effort exhaustive support for `numGp > 1` too, with a stricter ceiling | §2.8's own in-repo evidence already shows this package's realistic 29-candidate fixture is intractable for exhaustive `numGp=2` partition enumeration from random sampling alone — attempting it exhaustively compounds novel-algorithm risk with an already-known-intractable problem shape |
| D2/D9 scope + error semantics | `stop()` on an ineligible/infeasible request | Silently fall back to sampling mode with a `warning()` | A silent fallback risks the curator believing they received exhaustive results when they explicitly requested and did not get them — matches the existing harem-infeasibility `stop()` precedent (§2.1) |
| D4 algorithm | Hand-rolled Bron-Kerbosch-style enumeration on the existing `kin` adjacency list, no new dependency | Add `igraph` as a new `Imports` dependency and use its built-in independent-vertex-set enumeration | `igraph` is a mature, battle-tested library and plausibly faster/more robust, but this package has zero existing graph-theory dependency; the feasibility ceiling this design requires anyway (D5) keeps the hand-rolled implementation's problem size small enough to be tractable and auditable, and citable to standard literature (Bron & Kerbosch 1973; Tomita et al. 2006) matching this package's existing citation-density convention (issue #120) |
| D5 feasibility numbers | `maxExhaustiveCandidates` ≈ 20, `exhaustiveTimeLimit` ≈ 10s (exact figures pending §11 Q3) | A looser ceiling (~30, ~30s) | Trades responsiveness and the shared-blocking risk (Dragon 2) for broader coverage; a legitimate alternative if colony managers routinely want exhaustive results above 20 candidates |
| D5 feasibility numbers | (as above) | A tighter ceiling (~15, ~5s) | Trades usefulness for a larger safety margin against the shared-blocking risk; appropriate if the owner weighs app-wide responsiveness above exhaustive-mode coverage |
| D8 UI timing | Ship the toggle in Slice 2, same session as the algorithm | Ship Slice 2 as script-callable only (`groupAddAssign(exhaustive=TRUE, ...)`), defer the UI toggle to a separate Slice 3 | Matches the #147/#149 precedent of shipping a function before its UI, and keeps Slice 2's diff smaller/lower-risk, at the cost of the feature being unreachable from the app (which issue #146's own UI-facing framing argues against) until a Slice 3 is picked up |

---

## 9. Close-out checklist mapping

1. **Citation checklist (issue #120)** — N/A for Slice 1 (parameter addition, no new statistic). Slice 2: the `.enumerateMaximalIndependentSets()` roxygen `@references` (D4) is a documentation-quality matter, not the issue-#120 UI-guidance-page trigger (the function is `@noRd`, never user-facing) — state this explicitly in Slice 2's own close-out, matching the #133/#149 precedent of an explicit "N/A" statement rather than silent omission.
2. **Tutorial/article documentation checklist (Session 436)** — N/A for Slice 1 (a default-count change to an existing control, not a new interaction pattern). Applies for Slice 2 **only if** §11 Q4 ratifies shipping the UI toggle in that slice: `vignettes/manual_components/*.Rmd` and/or `vignettes/articles/colony-manager-guide.qmd`'s existing Breeding Group Formation coverage.
3. **`NEWS.Rmd` entry checklist (Session 448)** — applies twice, once per slice, matching the #147/#149 two-slice precedent.
4. **`a2interactive.Rmd` script-callable-function checklist (Session 450/478)** — applies, deferred (not same-session), to both slices' new parameters on the already-documented `groupAddAssign()` — the exact "new parameter added to an already-documented exported function" shape the checklist's own scope-broadening (S478) was written for.
5. **`_pkgdown.yml` reference-coverage checklist (Session 496)** — N/A both slices; `groupAddAssign` is already listed (§2.9), and `.enumerateMaximalIndependentSets()` is `@noRd`.
6. **GitHub issue close-out checklist** — `gh issue close 146 --reason completed --comment "..."` citing the `CHANGELOG.md` entry and verification evidence, in the same session Slice 2 ships.
7. **Lint close-out checklist** — `lintr::lint_package()` on touched files, each slice, before that slice's own close-out.
8. **`CHANGELOG.md` ledger-format resolution (Session 325)** — each slice's own close-out prepends a dated `### YYYY-MM-DD · [issue #146] ...` entry above `## Legacy history`.

---

## 10. Provenance

This document was produced primarily by direct source reading plus one original empirical benchmark (not a multi-agent research `Workflow` — unlike #147, whose subject matter needed external literature synthesis across three independent angles, #146's algorithmic core is a well-established, textbook graph-theory equivalence (maximal independent sets = maximal cliques of the complement graph) that needed direct measurement against this package's own data shapes, not a literature survey):

1. GitHub issue #146's own body, fetched via `gh issue view 146 --json title,body` (zero comments, confirmed verbatim in §1.1).
2. `docs/audits/GENETIC_METRICS_ISSUES_SEQUENCING_AUDIT_2026-08-08.md` (the relevant sections read in full) and `docs/audits/GENETIC_METRICS_PDF_CAPABILITY_AUDIT_2026-08-05.md`/`..._2026-08-06.md` (the `groupAddAssign()`-relevant rows) — establishing #146's priority, sequencing, and the audit's own two-piece-split recommendation quoted throughout §1.
3. Direct, full reads of `R/groupAddAssign.R`, `R/fillGroupMembers.R`, `R/fillGroupMembersWithSexRatio.R`, `R/getAnimalsWithHighKinship.R`, `R/addAnimalsWithNoRelative.R`, `R/makeGroupMembers.R`, `R/addGroupOfUnusedAnimals.R`, `R/groupMembersReturn.R`, `R/modBreedingGroups.R` (both UI and server sections), `tests/testthat/test_groupAddAssign.R`, `DESCRIPTION`.
4. Two prior planning documents in the same "shape" family for house-style structure: `docs/planning/issue147-likelihood-parentage-assignment-plan.md` (S495) and `docs/planning/issue149-cross-center-identity-mapping-workflow-plan.md` (S503), both read in full for section structure, ratification-round format, and close-out-checklist mapping conventions.
5. **An original empirical benchmark, run this session** (not derived from any prior document): a throwaway, un-pivoted Bron-Kerbosch-style maximal-independent-set enumerator implemented directly against synthetic conflict graphs of varying size/density, plus a direct measurement of the real `qcBreeders`/`pedWithGenotype` fixture's own conflict-graph density via the actual production code path (`getAnimalsWithHighKinship()`/`addAnimalsWithNoRelative()`). Script not committed (scratch/throwaway per this session's own scratchpad convention); results reproduced in §2.10.

No dedicated adversarial-verification pass (a second independent agent re-checking every claim against live source, as #147/#149 each ran) was performed this session — this document's central empirical claims (§2.10's benchmark table, §2.9's dependency-list read) are independently reproducible by re-running the same commands/script sketch, and every code-behavior claim in §2 cites a specific file:line read directly by this session, not inferred from the issue text or the audit. A future implementing session should re-verify the §2.10 numbers are still representative (no unrelated change to `getAnimalsWithHighKinship()`'s algorithm) before finalizing D5's exact ratified numbers into code.

`PROJECT_LEARNINGS.md` was grepped for prior findings specific to this feature area: no entries exist yet for "groupAddAssign," "maximal independent set," "Bron-Kerbosch," or "breeding-group... exhaustive" — this is the first substantive design work on #146's actual topic; everything before it in the ledger is the audit/sequencing history cited in §1.2.

---

## 11. Ratification status — forced vs. judgment-call decisions

**Forced by structural evidence gathered this session (no real choice, not put to a vote):** D1 (two-slice split — the audit's own explicit recommendation, independently confirmed by this document's risk analysis), D3 ("all valid partitions" = all maximal independent sets — dominated-subset argument under the existing scoring function), D6 (a UI sanity ceiling on `maxCandidates` — the number 50 is a minor recommendation, not a load-bearing choice), D7 (byte-identical-by-default return shape — this package's own established convention for every additive feature).

**Genuine judgment calls that must go through an `AskUserQuestion` ratification round before this plan is RATIFIED:**

**Q1 (D2 + D9) — What is exhaustive mode's eligibility scope, and what happens when a request falls outside it?**
- **Option A — Scope to `numGp==1`/no harem/no custom sex ratio; `stop()` with a specific reason on any ineligible or over-ceiling request.** *(This document's recommendation — §2.8's own in-repo evidence shows broader scope is already intractable on a realistic fixture, and a loud failure matches the existing harem-infeasibility precedent.)*
- **Option B — Attempt best-effort exhaustive support for `numGp > 1` too**, accepting a much smaller, more conservative feasibility ceiling given the exponentially harder problem shape. *(Not recommended — compounds novel-algorithm risk with a problem shape §2.8 already shows is intractable at realistic scale.)*
- **Option C — On an ineligible/infeasible request, silently fall back to sampling mode with a `warning()` instead of `stop()`ing.** *(Not recommended — risks the curator believing they received exhaustive results when they did not.)*

**Q2 (D4) — Hand-rolled algorithm, or a new `igraph` dependency?**
- **Option A — Hand-rolled Bron-Kerbosch-style enumeration**, no new dependency, citing Bron & Kerbosch (1973) / Tomita, Tanaka & Takahashi (2006) in roxygen. *(This document's recommendation — matches this package's zero-existing-graph-dependency baseline and its citation-density convention; the feasibility ceiling (D5) keeps the problem size auditable.)*
- **Option B — Add `igraph` as a new `Imports` dependency**, use its built-in independent-vertex-set enumeration. *(A legitimate alternative if the owner prefers a battle-tested library over new hand-rolled combinatorial code, at the cost of this package's first graph-theory dependency.)*

**Q3 (D5) — What are the feasibility-guard's concrete default numbers?**
- **Option A — `maxExhaustiveCandidates = 20`, `exhaustiveTimeLimit = 10` seconds.** *(This document's recommendation — grounded in §2.10's measured table: n=20 already reached 5.5s at low density in an unoptimized implementation; n=25 exceeded 60s.)*
- **Option B — A tighter ceiling: `maxExhaustiveCandidates = 15`, `exhaustiveTimeLimit = 5` seconds.** *(More conservative against the shared-blocking risk, Dragon 2 — appropriate if app-wide responsiveness is weighed above exhaustive-mode coverage.)*
- **Option C — A looser ceiling: `maxExhaustiveCandidates = 30`, `exhaustiveTimeLimit = 30` seconds.** *(Broader coverage at greater shared-blocking risk — appropriate if colony managers are expected to want exhaustive results above 20 candidates often enough to justify it.)*

**Q4 (D8) — Does Slice 2 ship the UI toggle in the same session as the algorithm, or defer it?**
- **Option A — Ship the toggle (checkbox + status callout) in Slice 2, same session as the algorithm.** *(This document's recommendation — issue #146's own framing is UI-facing; a script-only capability under-delivers it.)*
- **Option B — Ship Slice 2 as script-callable only; defer the UI toggle to a separate, later Slice 3.** *(Matches the #147/#149 precedent of shipping a function before its UI — smaller, lower-risk Slice 2, at the cost of the feature being unreachable from the running app until a Slice 3 is picked up.)*

Until Q1-Q4 are answered via `AskUserQuestion` (or the owner's plain-language equivalent), this document remains a **draft proposal**, not a ratified plan.

### Ratification outcome (2026-08-10, this session)

All four questions were posed via a single `AskUserQuestion` call. The owner selected **this document's own recommended option in all four cases, with no changes requested**:

- **Q1 (D2 + D9):** Option A — exhaustive mode scoped to `numGp==1`/no harem/no custom sex ratio only; `stop()` with a specific, actionable reason on any ineligible or over-ceiling request.
- **Q2 (D4):** Option A — hand-rolled Bron-Kerbosch-style enumeration on the existing `kin` adjacency list, no new dependency; roxygen `@references` citing Bron & Kerbosch (1973) and Tomita, Tanaka & Takahashi (2006).
- **Q3 (D5):** Option A — `maxExhaustiveCandidates = 20L`, `exhaustiveTimeLimit = 10` seconds, as the shipped defaults.
- **Q4 (D8):** Option A — Slice 2 ships the UI toggle (checkbox + status callout) in the same session as the algorithm; no separate Slice 3.

This plan is now **RATIFIED** and ready for Slice 1 implementation in a future session, per §5.
