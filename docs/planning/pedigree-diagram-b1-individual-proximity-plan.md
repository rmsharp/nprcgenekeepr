# Design: B1-individual-vs-unrelated-individual proximity near-misses

**Status:** RATIFIED (owner, `AskUserQuestion`, S661, 2026-08-31) — "Yes, ratify as recommended":
19-pair scope (§1.2/§2.1), the new additive per-generation pass at the §2.2/§2.3 placement. See
§10 for the full ratification record.
**Session:** S661 (2026-08-31). Planning-only session (`ARCHITECTURE_WORKSTREAM.md`) — no code
or test changes ship in this session; implementation is a separate future session, per
`SESSION_RUNNER.md`'s Planning Sessions rule ("the plan is the deliverable, do not start
implementing it").
**BACKLOG item:** "4 B1-individual-vs-unrelated-individual proximity near-misses on the real
375-individual fixture, no duplicate involved — same root cause as [the shipped duplicate-side
fix] but a different, unaddressed call site" (found S658, 2026-08-30, `BACKLOG.md` Up Next,
lines 756–777 — READY tag, Effort M as originally estimated, standing pedigree-fidelity top
priority; explicitly deferred out of S658/S660's own scope pending its own design session).

---

## 1. Context

### 1.1 Problem statement (as filed)

`.deCollideIndividualPoints()` (a closure nested inside `.positionMatingUnitForest()`,
`R/makePedigreeDiagramData.R:866-940`) is the only de-collision mechanism for individual-shaped
render nodes (genuine Tier-1 individuals, B1 "free-pass" individuals, and `__dup_*` B3
duplicates — all rendered as 25px-radius circles). It intervenes **only on an exact coordinate
tie** (`abs(x0-forbidden) < 1e-9`, `:888`) — it has no near-miss *radius* check at all. The
shipped duplicate-vs-individual fix (design doc
`docs/planning/pedigree-diagram-duplicate-individual-proximity-plan.md`, implemented S660,
commit `11649f6e`) closed this gap for the `dupIds` call path (`:1115-1117`) by adding a second,
post-hoc, threshold-based push (`individualClearance = (25+25)/120 = 0.41667`, `:1004`). It
explicitly did **not** touch the sibling `b1Ids` call path (`:958-960`), because — per that
design's own §1.4 — the same root cause produces a **structurally different** defect there: at
least one side of every affected pair is a B1 "free pass" individual (positioned via `tier3X`,
the same weak mechanism duplicates use), never two genuine Tier-1 individuals. That deferred item
is this design's subject: `D0Z114`/`S0022Z` (0.100), `XEE9GT`/`JB7EW2` (0.100), `PQX22G`/`Y7IUMX`
(0.400), `HKTQ40`/`8P17E3` (0.401), all on the real 375-individual/237-mating-unit fixture
(`inst/extdata/examples/obfuscated_rhesus_mhc_ped.csv`).

### 1.2 Re-derived measurement (this session): the named 4 are accurate — but "exactly 4" does not describe the defect's true size

Re-running the measurement this session (`scratchpad/b1-proximity-measure.R`, current `HEAD`
commit `5628509f`, no local modifications to `R/`) against every same-generation pair of
individual-shaped render nodes (`pos$id %in% realIds`, 375 nodes: 308 genuine + 67 `b1Ids`)
using the geometrically correct `individualClearance = 0.41667` reproduces **the same 4 pairs
BACKLOG names, with matching ids, matching distances, and matching tier classification** — so
those 4, taken individually, are confirmed accurate.

But "exactly 4" is not a stable description of the defect once the natural exclusion this
project already applies elsewhere (own-mating-unit/mate proximity is intentional, not a defect —
established by the duplicate-side design's own `dup-own-parent` exclusion) is applied
consistently here too:

| Scoping | Count | What the extra pairs are |
|---|---|---|
| **BACKLOG's literal "4"** | 4 | The 4 named pairs — real, but not the full picture |
| **Unrelated pairs only (correct scope, matching this project's own established exclusion precedent)** | **19** | The 4 named near-misses **+ 15 previously-undocumented pairs — all EXACT ties (distance = 0.000000), not "near"** |
| **Every same-gen pair under threshold, any relationship (fully literal reading of the task)** | 44 | The 19 above **+ 25 "mates" pairs** — a B1 individual and her own anchor, intentionally close by the `derivedX()`/`b1AnchorRelativeX()` formula itself |

The 25 "mates" pairs are **by design**, not a defect: they are the direct, intended output of the
Track 7 Phase 1 widened-offset formula (`b1AnchorRelativeX()`, `:805-810`, and `derivedX()`'s
fallback branch, `:812-818`) placing a B1 individual `minSep` or `minSep*0.4` from her own
anchor — the same shape of by-design proximity the duplicate-side design excluded via its
`ownParents` check. **This session independently re-verified the 25 count directly** (script:
`scratchpad/b1-design-verification.R`, Question 2): exactly **25 of the 67 `b1Ids` members
(37.3%) sit within `individualClearance` of their own anchor's final `tier1X`** — this is the
`b1Ids`-side analogue of the duplicate-side design's own "90 of 102 duplicates collide with their
own parent" collateral-damage measurement, confirming the same shape of risk exists here (§3.2).

The correct target scope for this design is therefore **19 pairs, not 4** — 4 strictly-positive
near-misses (BACKLOG's original count) plus 15 exact ties that satisfy the same "unrelated"
relationship test but were not previously surfaced. Of the full 19: **4 are B1-vs-B1**
(`UWJKEQ`/`ZZ646X`, `XEE9GT`/`JB7EW2`, `PQX22G`/`Y7IUMX`, `HKTQ40`/`8P17E3`), **15 are
genuine-vs-B1**, and **0 are genuine-vs-genuine** — impossible by construction, `sweepMinSep()`
(`:734-749`) guarantees `minSep = 1 > individualClearance = 0.41667` between every pair of
genuine Tier-1 individuals at the same generation.

**The 19, in full** (relationship column: `sireOf`/`damOf`/shared-mating-unit check, per-pair,
re-verified this session):

| Pair | Gen | Distance | Tiers | New this session? |
|---|---|---|---|---|
| `GQUCRY`/`WS6D1B` | 0 | 0.000 (exact tie) | genuine/B1 | Yes |
| `8ZK9LV`/`Y7IUMX` | 0 | 0.000 (exact tie) | genuine/B1 | Yes |
| `6VUC6R`/`UWJKEQ` | 0 | 0.000 (exact tie) | genuine/B1 | Yes |
| `6VUC6R`/`ZZ646X` | 0 | 0.000 (exact tie) | genuine/B1 | Yes |
| `PH0IXL`/`UXVHSF` | 0 | 0.000 (exact tie) | genuine/B1 | Yes |
| `P87V3K`/`UCXEK5` | 0 | 0.000 (exact tie) | genuine/B1 | Yes |
| `RKBTHH`/`UTU9S7` | 0 | 0.000 (exact tie) | genuine/B1 | Yes |
| `8WG9U2`/`UKJFYA` | 0 | 0.000 (exact tie) | genuine/B1 | Yes |
| `N2C1PW`/`U5VLXP` | 0 | 0.000 (exact tie) | genuine/B1 | Yes |
| `UWJKEQ`/`ZZ646X` | 0 | 0.000 (exact tie) | **B1/B1** | Yes |
| `AU22BC`/`1BYXWJ` | 1 | 0.000 (exact tie) | genuine/B1 | Yes |
| `EE4BJC`/`677E7M` | 1 | 0.000 (exact tie) | genuine/B1 | Yes |
| `BH6ZQK`/`8933XB` | 1 | 0.000 (exact tie) | genuine/B1 | Yes |
| `L5KNS5`/`BRI2MW` | 1 | 0.000 (exact tie) | genuine/B1 | Yes |
| `I2G9D6`/`QL6GH4` | 2 | 0.000 (exact tie) | genuine/B1 | Yes |
| `D0Z114`/`S0022Z` | 1 | 0.100 | genuine/B1 | No (BACKLOG's original) |
| `XEE9GT`/`JB7EW2` | 1 | 0.100 | **B1/B1** | No (BACKLOG's original) |
| `PQX22G`/`Y7IUMX` | 0 | 0.400 | **B1/B1** | No (BACKLOG's original) |
| `HKTQ40`/`8P17E3` | 1 | 0.401 | **B1/B1** | No (BACKLOG's original) |

### 1.3 Root cause of the 15 previously-undocumented exact ties

These 15 are not a gap in the existing mechanism's *detection* — `.deCollideIndividualPoints()`
correctly identifies each as an exact tie and enters its capped bidirectional search
(`.kMaxIndividualPush = 2L`, `:649`, `:888-917`). The gap is in the search's own **disclosed
fallback**: when neither direction finds a free slot within 2 steps, the code reverts outright —

```r
# R/makePedigreeDiagramData.R:912-914
if (k >= .kMaxIndividualPush) {
  x0 <- rawX0     # silently keeps the original, still-colliding position
  break
}
```

— and the residual small-epsilon pass that would otherwise nudge a leftover tie is **explicitly
skipped** in exactly this branch, by design:

```r
# R/makePedigreeDiagramData.R:923-926 (comment on the guard at :927)
## Skipped when the search above fell back to rawX0 (an individual tie by
## definition) -- nudging that case would silently reintroduce the unbounded
## drift the cap exists to prevent.
```

This is a **disclosed, intentional** trade-off from Track 7 Phase 1 (S647) — the cap exists to
bound collateral damage from a *different* problem (see §3.3), not to guarantee every tie
resolves — but it means the implicit assumption that "exact ties are already handled, only
strict near-misses are an open gap" does not hold on this fixture for at least 15 pairs. Any
design for this BACKLOG item that targets only strictly-positive distances (the original "4"
framing) would leave 15 more defects of the identical relationship-and-visual shape unaddressed.

### 1.4 Scope boundary: individual-vs-individual only — B1-vs-union is already covered

This design's mechanism (§2) is scoped to **individual-vs-individual** proximity only, matching
BACKLOG's own item title. B1-vs-**union** proximity is a different, already-solved problem:
Track 7 Phase 2's union sweep (`:1016-1103`) already pushes a mating-union dot away from a B1
individual's position, using `unionClearanceIndividual = (25+6)/120 = 0.2583` (`:996`), reading
`tier3X[b1Ids]` at `:1028` as ground truth. §2.3 shows why this design's own placement decision
means Phase 2 correctly reacts to this design's *new* B1 positions with zero code changes of its
own — so no B1-vs-union check needs to be added here.

### 1.5 Evidence-base note: two corrections to the material handed into this design

- **A citation error caught and corrected.** Prior research referenced "issue #158" as if it
  were a tracking issue for this proximity work. Verified directly this session
  (`gh issue view 158`): issue #158 is real, closed, but **unrelated** — "Propagate
  consanguineous-marker color/width onto `edgeStyle=\"rectilinear\"` dogleg-rerouted edges." This
  BACKLOG item has no dedicated GitHub issue (confirmed against `BACKLOG.md:756-777`'s own text,
  which cites only session numbers); it is tracked via `BACKLOG.md` alone, consistent with this
  project's established "no GitHub issue for a scoped internal finding" convention. No issue
  number is cited for this work anywhere in this document. (Issue **#159**, cited in §1.6/§4
  below, is unrelated to this correction and was independently verified real and on-topic via the
  same method.)
- **A gap this session filled empirically, not assumed.** The provided research flagged
  "own-anchor exclusion" as necessary by analogy to the duplicate-side design's `ownParents`
  exclusion, but did not measure it for `b1Ids` directly. §1.2 above and §3.2/§3.5 below report
  this session's own direct measurement (`scratchpad/b1-design-verification.R`) rather than
  carrying the analogy forward unverified.

### 1.6 Relationship to issue #159

Issue #159 ("sibling subtree-width asymmetry — rigid-subtree layout paradigm needs replacing")
was closed S590 after three independently-designed whole-algorithm-replacement candidates all
regressed the real fixture. Its closure forecloses only *that* — swapping the Walker/BJL rigid
subtree engine for a different global layout. It does not constrain, and is the explicit
precedent cited by, narrow local post-hoc collision-avoidance mechanisms strictly within the
existing engine's own downstream formulas — exactly Track 7 Phases 1/2/4 and the S660 fix, and
exactly the category this design falls into.

---

## 2. Decision

### 2.1 Fix scope

**In scope:** all 19 "unrelated" pairs from §1.2 — both the 4 strictly-positive near-misses and
the 15 exact ties — via one uniform mechanism (§2.2 explains why one threshold check naturally
covers both classes). **Out of scope:** the 25 "mates" pairs (excluded by construction, §2.2's
own-anchor exclusion) and B1-vs-union proximity (already handled, §1.4).

### 2.2 Mechanism: a new, additive, sequential near-miss/tie-repair pass over `b1Ids`

**Recommendation:** a **second, separate pass over `b1Ids`**, run immediately after the existing
exact-tie call (`:958-960`) completes, structurally mirroring that closure's own per-generation,
x-sorted, incrementally-tracked search — but as its **own new code**, not a modification to
`.deCollideIndividualPoints()` itself (§3.1 explains why reuse-without-modification is not
possible, and §3.2 why modification is rejected). It reuses the **already-shipped**
`individualClearance` constant (`:1004`) — no new threshold constant is needed, since both sides
of this check are the same 25px-radius individual-shaped geometry the duplicate-side fix already
established the correct clearance for.

```r
## New: B1-vs-unrelated-individual near-miss/tie repair (this design).
## Placed after individualClearance exists (:1004) and before the union
## sweep begins (:1016) -- see §2.3 for why both bounds are load-bearing.
## Needs its OWN cap: NOT .kMaxIndividualPush=2 (tuned against a different
## problem, see §3.3) and NOT assumed equal to .kMaxUnionPush=5 either --
## empirically re-derive at GREEN (§8).
.kMaxB1ProximityPush <- <EMPIRICALLY TBD AT GREEN>

if (length(b1Ids) > 0L) {
  for (g in sort(unique(tier3Gen[b1Ids]))) {
    theseIds <- b1Ids[tier3Gen[b1Ids] == g]
    theseIds <- theseIds[order(tier3X[theseIds], theseIds, method = "radix")]
    pushedThisGen <- numeric(0L)          # incremental: sibling B1s already
                                           # processed THIS generation, so a
                                           # B1-vs-B1 pair (4 of the 19) is
                                           # seen by whichever member is
                                           # processed second (§3.3).
    for (fp in theseIds) {
      ownAnchor <- anchorOf[[b1UnitOf[[fp]]]]           # already computed,
                                                         # :660 / :820-825
      forbidden <- c(tier1X[dispGenOf == g], pushedThisGen)
      forbidden <- forbidden[!is.na(forbidden) &
                                names(forbidden) != ownAnchor]   # §3.5
      x0 <- tier3X[[fp]]
      if (length(forbidden) > 0L &&
            any(abs(x0 - forbidden) < individualClearance)) {
        rawX0 <- x0
        sign <- b1PushSign[[fp]]                        # reuse existing
                                                          # direction (§3.4)
        k <- 1L
        repeat {
          candPref <- rawX0 + sign * k * individualClearance
          if (!any(abs(candPref - forbidden) < individualClearance)) {
            x0 <- candPref; break
          }
          candOther <- rawX0 - sign * k * individualClearance
          if (!any(abs(candOther - forbidden) < individualClearance)) {
            x0 <- candOther; break
          }
          if (k >= .kMaxB1ProximityPush) { x0 <- rawX0; break }
          k <- k + 1L
        }
        tier3X[[fp]] <- x0
      }
      pushedThisGen <- c(pushedThisGen, stats::setNames(tier3X[[fp]], fp))
    }
  }
}
```

One new cap constant, one new per-generation loop with its own incremental `pushedThisGen`
accumulator, one per-member own-anchor exclusion, reuse of the already-shipped
`individualClearance` and the already-computed `b1PushSign`/`b1UnitOf`/`anchorOf`. The
`.deCollideIndividualPoints()` closure used by the `dupIds` call path is not touched.

### 2.3 Placement and ordering — corrected from the source research's own approximation

The downstream-impact analysis for this design described the placement as "immediately after
line 960... before the line 963 [comment block]." That is directionally right but not textually
exact: `individualClearance` — which this mechanism reuses rather than redefines — is not itself
defined until `:1004`, after the Track 7 Phase 1 revert comment block (`:963-981`) and partway
through the Track 7 Phase 2 comment block (`:983-1004`). The load-bearing constraint the source
analysis actually identified is **"before line 1016" (the union sweep's own loop start)**, not
literally line 961. This design places the new pass concretely **between line 1014
(`.kMaxUnionPush <- 5L`) and line 1016** — after every value it reads is final, before the one
downstream computation whose correctness depends on seeing `b1Ids`'s truly final positions.

This ordering is load-bearing for three separate reasons, all confirmed by direct reading of the
downstream code (not merely asserted):

1. **The union sweep** (`:1016-1103`) reads `tier3X[b1Ids]` at `:1028`
   (`b1AtGen <- tier3X[b1Ids[tier3Gen[b1Ids] == orderedUnits$gen[i]]]`) as ground truth for its
   own `individualOccupied`/`individualOccupiedForPush` sets, used by its own capped push
   (`.kMaxUnionPush = 5`, `unionClearanceIndividual`) to keep every union dot away from every B1
   point. Placed before line 1016, this design's new pass is fully finished by the time any union
   is swept — so **every union sees this design's corrected B1 positions as its own baseline**,
   and needs no code change to stay correct (§6). Placed after, the sweep would have already
   positioned unions relative to the *old*, still-colliding B1 positions, and nothing downstream
   re-checks or re-runs the sweep — reproducing the exact "stale intermediate" bug class Track 7's
   own S647 fix (`:773-789`) already found and fixed once for a different value.
2. **The duplicate de-collision seed** (`:1115-1117`) passes `tier3X[b1Ids]` as
   `seedIndividuals`, and the duplicate formula itself (`derivedX(..., isB1 = FALSE)`, called at
   `:1112`) depends transitively on `unitX`, which the union sweep computed using whatever
   `tier3X[b1Ids]` held *at sweep time*. Both are downstream of the union sweep, so both
   automatically see this design's final values as long as this design's pass precedes line 1016.
3. **Track 7 Phase 4's duplicate push** (`:1132-1191`) reads
   `tier3X[b1Ids[tier3Gen[b1Ids] == g]]` again at `:1146`, later still in execution order — same
   conclusion.

**Net: with this placement, all three existing downstream consumers require zero code changes**
— they read `tier3X[b1Ids]` by simple indexing with no knowledge of how it was computed, and by
construction see this design's fully-corrected values (§6 restates this as the Impact Analysis
answer to the item BACKLOG explicitly flagged as needing re-checking).

---

## 3. Rationale

### 3.1 Why not simply call `.deCollideIndividualPoints()` again with a wider threshold

Not mechanically possible without modifying it: its exact-tie epsilon (`1e-9`, `:888`, `:903`,
`:908`, `:929-930`) is a hardcoded literal in the closure body, not a parameter. Reusing it for a
wider check requires either (a) modifying the closure to accept a threshold parameter — which is
Alternative B in §4, rejected for blast-radius reasons — or (b) a separate mechanism, which is
what this design proposes.

### 3.2 Why not modify `.deCollideIndividualPoints()`'s own shared threshold generally

The duplicate-side design measured this exact move for `dupIds` and found a 45:1
collateral-to-benefit ratio (90 of 102 duplicates newly colliding with their own parent) — a
result strong enough that it also constrains this design: **"Must NOT modify
`.deCollideIndividualPoints()`'s shared exact-tie-only epsilon behavior/threshold for either the
`dupIds` or `b1Ids` call path"** (that design's own explicit constraint list). This session's own
direct measurement (§1.2, Question 2 of `scratchpad/b1-design-verification.R`) confirms the same
shape of risk on the `b1Ids` side: **25 of 67 `b1Ids` members (37.3%)** sit within
`individualClearance` of their own anchor. Widening the shared closure's threshold with no
family exclusion would trip all 25 as false-positive collisions — a smaller absolute ratio than
the duplicate side's 90/102 (25:19 ≈ 1.3:1 against the correct 19-pair scope, or 25:4 ≈ 6.25:1
against BACKLOG's original 4), but still large enough, and still large enough to very likely
perturb several of the pinned exact-position tests in §6, to reject outright.

### 3.3 Why not a Phase-4-style frozen-snapshot post-hoc pass

Phase 4's duplicate push (`:1132-1191`) checks each duplicate against an **entirely external,
already-frozen** population (`tier1X` and the fully-final `tier3X[b1Ids]`) — no duplicate is ever
checked against another duplicate in that loop, because duplicate-vs-duplicate collision is
already handled earlier, by the sequential `.deCollideIndividualPoints(dupIds, ...)` call at
`:1115-1117`. That frozen-snapshot pattern is *not* structurally sufficient for `b1Ids`, because
**4 of the 19 in-scope pairs are B1-vs-B1** (`UWJKEQ`/`ZZ646X`, `XEE9GT`/`JB7EW2`,
`PQX22G`/`Y7IUMX`, `HKTQ40`/`8P17E3`) — collisions *within* the very population this mechanism is
finalizing, not against an external population. A literal copy of Phase 4's pattern onto
`b1Ids` — checking each B1 member against a snapshot of `tier1X` plus every *other* `b1Ids`
member's **pre-this-pass** position, taken once before the loop starts — would either miss
correcting these 4 pairs entirely, or (worse) let two members independently "resolve" against
each other's stale position and land on a new coincidence neither one's own check would catch.
This is why §2.2's design instead mirrors `.deCollideIndividualPoints()`'s own incremental
`placedThisGen`-style tracking (renamed `pushedThisGen`): the member processed second in x-order
within a generation sees the first member's **already-updated** position, exactly the same
self-referential design the *existing* mechanism already uses correctly for `b1Ids` (proven by
the fact that `b1Ids`-vs-`b1Ids` exact ties *are* currently detected — `UWJKEQ`/`ZZ646X` is
proof — it is only the capped search's fallback, not the detection, that fails on this fixture).
This is a genuine structural reason task alternative (a) — "mechanically copy Phase 4's exact
pattern onto `b1Ids`" — is not merely more work than this design, but **incomplete** for the
B1-vs-B1 sub-case without this modification (see §4).

### 3.4 Why bidirectional with `b1PushSign`, not unidirectional like Phase 4's push

Phase 4's duplicate push is deliberately unidirectional (always rightward), matching
`derivedX()`'s own always-rightward B3 fallback convention — reusing a bidirectional search there
was tried and rejected (a documented false start, pushing a duplicate too close to its own owning
union on all 3 shipped cases). `b1Ids` has the **opposite** existing convention: Track 7 Phase 1
established a direction-*preserving* bidirectional search specifically because `b1PushSign`
(`:944-956`) already encodes the correct per-member direction (`-1` for a female-anchor/male-mate
pair per issue #145's convention, `+1` otherwise) to avoid crossing a mate to the wrong side of
her anchor. This design reuses that same already-computed, already-tested signal rather than
introducing a new, inconsistent unidirectional convention for the same population.

### 3.5 Own-anchor exclusion: necessary, and — on current evidence — sufficient

Necessary per §3.2's 25/67 measurement. Whether it is *sufficient* — i.e., whether excluding only
each member's own anchor also correctly clears every genuine defect pair without missing a
different intentional-proximity shape (a "co-wife" case: two different mates of the same
polygamous anchor, in two different mating units, positioned close to each other) — is answered
empirically, not assumed, by this session's own check (`scratchpad/b1-design-verification.R`,
Question 1): **zero of the 19 known "unrelated" pairs share a common anchor across different
units, and zero involve one member being the other's own anchor.** This closes the one open
question this design would otherwise have had to leave unresolved. It is confirmed only for the
19 *currently known* pairs, not proven impossible in general — §7 files the corresponding RED-phase
test recommendation as an explicit, disclosed residual risk, mirroring the duplicate-side
design's own treatment of its early-exit guard edge case.

### 3.6 Why this pass needs no union-avoidance logic of its own

Given the placement in §2.3, the union sweep (`:1016-1103`) runs **after** this pass completes and
reacts to *whatever* `tier3X[b1Ids]` holds at that point, symmetric and order-tolerant by
construction — it does not matter, from the sweep's perspective, whether a given B1 position is
its original Tier-3 value or a value this new pass moved. Every union gets its own chance, at
sweep time, to check against the then-current B1 positions and push itself away if needed. Adding
a duplicate, B1-side union check to this design's own pass would be redundant with work Phase 2
already and unconditionally performs after this pass runs.

---

## 4. Alternatives Considered

| Alternative | Pros | Cons | Why Rejected / Deferred |
|---|---|---|---|
| **RECOMMENDED — a new, additive, sequential (`pushedThisGen`-tracked) near-miss/tie pass over `b1Ids`, chained after the existing exact-tie call and before the union sweep (§2)** | Reuses the already-shipped `individualClearance` constant and `b1PushSign` direction signal; correctly handles the 4 B1-vs-B1 pairs via the same incremental design the existing mechanism already uses; downstream passes need zero code changes (§2.3); does not touch `.deCollideIndividualPoints()` at all, so the `dupIds` call path and every already-pinned `b1Ids` test are provably unreachable by this change unless the new pass itself acts | New code (a full per-generation loop, not a one-line extension); needs its own empirically-derived cap, which could take more than one iteration (§8/§9) | — (this is the recommendation) |
| **(a) Mechanically copy Track 7 Phase 4's exact post-hoc-pass pattern onto `b1Ids` verbatim** | Smallest possible diff; exactly reuses an already-shipped, already-tested pattern | **Structurally incomplete, not just more invasive**: Phase 4's pattern checks only against a frozen *external* population and never against other members of the very population being pushed — but 4 of the 19 in-scope pairs are B1-vs-B1, a self-referential case Phase 4's own pattern was never designed to handle (§3.3). A literal copy would silently miss or mis-resolve those 4. | **Rejected** — not a smaller/larger-effort trade-off against the recommendation, a correctness gap against 4 of the 19 known cases |
| **(b) Widen `.deCollideIndividualPoints()`'s own shared exact-tie epsilon to `individualClearance`, no family exclusion, applied to the `b1Ids` call (or both call paths)** | Simplest possible code (change one literal) | Measured this session: 25/67 (37.3%) of `b1Ids` members would newly "collide" with their own anchor — the intentional, formulaic offset itself — a false-positive rate large enough to very likely perturb several pinned exact-position tests (§6) and, because the closure is shared with `dupIds`, risks the already-verified duplicate-side behavior too | **Rejected** — confirmed by direct measurement, not conjecture (§3.2) |
| **(c) Widen the shared closure's threshold for the `b1Ids` call only, with an added own-anchor exclusion parameter added to the closure itself** | Fixes the same 19 cases; keeps all de-collision logic in one function | Strictly more invasive than the recommendation for an equivalent result: touches a closure also used by `dupIds` (adding a new parameter changes its contract, and any future caller must now reason about two different threshold regimes) instead of leaving it completely untouched; still needs the same B1-vs-B1 self-reference fix as the recommendation, just inside a shared function instead of a dedicated one | **Rejected** — no benefit over the recommendation, larger blast radius for an identical result |
| **(d) Accept as a permanent, disclosed limitation — do nothing (matching issue #159's "not feasible to fix generally" precedent)** | Zero implementation risk; zero risk to any pinned test | Issue #159's precedent does not actually apply here — it forecloses *whole-algorithm replacement* after 3 failed candidates, not a narrow local fix of a kind this codebase has shipped 4 times already (Track 7 Phases 1/2/4, S660) with a well-understood, low-novelty mechanism. Leaves 19 (not 4) real proximity defects on the standing top-priority pedigree-fidelity track indefinitely, with a known, budgetable fix available. | **Rejected** — the "no feasible fix" framing this alternative borrows from #159 does not transfer to a scoped local mechanism; see §1.6 |
| **(e) Defer further — fold into a larger, dedicated `b1Ids`-mechanism redesign session (not this narrow fix)** | Would be the natural place to revisit `.kMaxIndividualPush=2` itself, or the widened-offset formula, if either were independently found wanting | No such larger redesign is currently planned, scoped, or motivated by other evidence; this design's own mechanism (§2) does not touch Track 7 Phase 1/2's ratified formulas at all (purely additive), so there is no coupling that requires waiting for a hypothetical bigger session; matches this project's own repeated preference for narrow, incremental shipping (Track 7's own phase-by-phase history; S660's own 2-pair scoping) over batching unrelated concerns | **Rejected for now** — revisit only if a *separate* motivation for a larger `b1Ids` redesign emerges; see §9 |

---

## 5. Migration Path

This is not a system migration in the traditional sense — no data model, no API version, no
persisted state, and no consumer outside this one rendering pipeline. The "migration" is a
single implementing session's RED→GREEN cycle, matching every prior Track 7 phase and the S660
precedent.

**Step-by-step:**
1. Pre-RED: re-derive §1.2's 19-pair measurement against unmodified `HEAD` at implementation time
   (do not assume this document's counts are still current — see §8).
2. RED: add the failing tests named in §8 (case-reproduction + updated aggregate pins).
3. GREEN: implement the pass in §2.2 at the exact placement in §2.3; empirically derive
   `.kMaxB1ProximityPush` (§8).
4. Live chromote render verification, lint, close-out — per §8.

**Rollback:** at any point before merge, `git revert` of the single implementing commit fully
restores current (post-S660) behavior. Nothing persists between renders — every position is
recomputed fresh from `ped`/`forest` on each call to `.positionMatingUnitForest()` — so there is
no data-migration or backward-compatibility concern of any kind.

**Incremental vs. cutover:** the fix itself is atomic (one new pass, one commit) — there is no
partial-rollout state to design for. The **cap value** is the one place a phased approach may be
warranted: Track 7 Phase 1's own history (three owner-gated iterations — epsilon nudge, then
uncapped bidirectional push, then a capped fallback — each verified against a full regression run
before the next was tried) is the direct precedent. If GREEN-phase simulation finds a first
candidate cap reintroduces the D1 sibship-bar-overlap class Phase 1's own cap was tuned against
(§3's own `.kMaxIndividualPushRationale` evidence), the implementing session should treat the cap
as its own incremental sub-decision, re-gated via `AskUserQuestion` exactly as S647 did, rather
than block the whole fix on getting the cap right in a single attempt.

---

## 6. Impact Analysis

**Hardcoded position assertions at risk of needing re-pinning.** The inventory for this design
found materially fewer live assertions than BACKLOG's own informal "~20" estimate: **11 hard,
`b1Ids`-dependent assertions in `test_positionMatingUnitForest.R`** (9 exact-position pins + 2
aggregate `nColliding = 27L`-style regression counts), **+2 more indirectly-dependent aggregate
counts in `test_makePedigreeMatingLayout.R`** (node count, `__jog_` count) = **13 total**, plus
**2 soft/bound (not exact-value) checks**. Risk is not uniform across these:

| Assertion | File:line | Risk under this design |
|---|---|---|
| `expectPos("8DKELJ", 1.5, 0L)` | `test_positionMatingUnitForest.R:268` | Low — raw formula output, no collision currently involved in its small fixture; only at risk if that fixture happens to also place an unrelated node within `individualClearance` — unconfirmed, needs live re-check |
| `mateX == anchX+1` | `:1682` | Low, same reasoning |
| `yX == gxX-1` | `:1774` | Low, same reasoning |
| `aX==0`/`cX==1` (setup) | `:1922-1923` | Low, same reasoning (feeds `:1933`) |
| `bX == 2` | `:1933` | **Elevated** — this pin is itself the *result* of the current exact-tie push (a k=1 step); this design's new pass runs on top of that result and could act further if that specific small fixture also has a THIRD nearby node — needs live re-check, not assumed safe |
| `mateX == anchX-1` | `:1957`, `:2050` | Low, same reasoning as the raw-formula pins above |
| `mateX == anchX-2` | `:2100` | **Elevated**, same reasoning as `:1933` — this is also a push *result*, not a raw formula value |
| `nCollidingNodes == 27L` | `:488` | **High** — this design's entire purpose is to reduce some of the 27 exact-tie residual nodes; almost certainly needs a new value, not just re-confirmation |
| `nColliding == 27L, info=...` | `:1081` | **High**, same reasoning |
| `nrow(result$nodes) == 1460L` | `test_makePedigreeMatingLayout.R:666` | Moderate — depends on whether the shrunk Track-B fixture (distinct from the real 375-fixture) has any `b1Ids` near-miss/tie pairs at all; unknown from this design's own evidence base, needs live re-check |
| `sum(grepl("^__jog_", ...)) == 202L` | `:676` | Moderate, same reasoning |
| `diff(range(hubReps)) > 1L` | `:1806` | Low — a directional/qualitative bound (not clustered), unlikely to flip sign from an additive push; re-confirm, not re-value |
| `all(drift <= 6)` | `:2451` | **Elevated** — this bound directly measures union-dot/B1-mate visual drift for `qualifies()`-gated unions, the same subject matter this design's own pushes touch; worth explicit re-measurement, not assumed to hold |

**An additional ripple this design's own evidence base did not enumerate, found by this session's
own check of the actual test suite:** `test_resolveEdgeNodeCollisions.R:490-491`
(`nrow(baselineEdges) == 100L`, `nrow(baseline) == 1766L`) is a real-375-fixture, same-row
edge/node collision count. It was not part of the `b1Ids`-specific assertion inventory handed
into this design, but it is structurally analogous to the one file the *duplicate*-side design's
own Impact Analysis flagged for exactly this reason — and that file's counts did in fact move
under the S660 fix (98→100 / 1762→1766, per `BACKLOG.md`'s own S660 close-out). Since `b1Ids`
positions feed the identical rendering pipeline, this file should be treated as an **unconfirmed
but plausible** additional ripple, re-measured at implementation time alongside the rest of §6,
not assumed unaffected simply because it wasn't in the given inventory.

**Does the `nColliding = 27L` count need re-verification?** Yes, with high confidence it needs a
*new value*, not just re-confirmation of the old one — see the two "High" rows above. This
design's mechanism is specifically built to resolve some fraction (up to 15, the exact-tie subset
of the 19 in-scope pairs) of whatever currently contributes to that 27. The exact new number
depends on how many of those 15 pairs the empirically-derived cap actually clears and is not
something this design predicts — matching this project's own "re-measure, never hand-derive"
discipline (§8).

**Do the 2 downstream passes need code changes of their own?** No — established with high
confidence in §2.3. The union sweep (`:1016-1103`) and the duplicate seed/Phase 4 push
(`:1112-1191`) both read `tier3X[b1Ids]` by simple indexing, with no dependency on how those
values were computed. Given this design's placement (before line 1016), both automatically see
the fully-corrected values. This is a genuinely *lower*-risk finding than BACKLOG's own framing
anticipated ("re-check of the 2 downstream passes" is now, on this design's evidence, a
verification task — re-run their existing tests and confirm — not a code-change task.)

**`BACKLOG.md`'s own item text.** Needs correcting at ratification, mirroring the precedent this
project already set for the duplicate-side item: the "4" framing should be replaced with §1.2's
19/25/44 breakdown, regardless of which mechanism ultimately ships.

---

## 7. Explicitly Out of Scope (report, don't fix here)

- **B1-vs-union proximity** — not a gap; already handled by Track 7 Phase 2, made correct for
  this design's new B1 positions specifically *because of* the placement decision in §2.3, not
  because it was independently re-verified as a separate mechanism.
- **The "co-anchor" edge case** (two different mates of the same polygamous anchor, in different
  mating units, landing close to each other) — confirmed absent from all 19 currently-known
  pairs (§3.5), but not structurally prevented by this design's own own-anchor-only exclusion.
  The implementing session's RED phase should add a dedicated synthetic-fixture test for this
  shape even though it does not bite on the real fixture today, mirroring the duplicate-side
  design's own treatment of its early-exit-guard edge case (that design's §6).
- **Revisiting `.kMaxIndividualPush = 2` itself**, or the Track 7 Phase 1 widened-offset formula
  it protects — this design is strictly additive on top of both; changing either is a separate,
  larger-scoped effort (§4, Alternative (e)) with no current motivation of its own.
- **The 25 "mates" pairs** — confirmed by-design (§1.2/§3.2), not filed as a defect of any kind.

---

## 8. Verification Plan

- **Pre-RED empirical re-validation:** re-run this document's own §1.2 measurement
  (`scratchpad/b1-proximity-measure.R`, extended per `scratchpad/b1-design-verification.R`)
  against unmodified `HEAD` at implementation time — do not assume this document's counts (19
  in-scope pairs, 25 own-anchor collateral, 0 co-anchor false negatives) are still current.
- **RED:** tests reproducing at minimum: (a) one dedicated case-reproduction test covering a
  representative sample of the 19 in-scope pairs (including at least one B1-vs-B1 pair, to
  directly exercise §3.3's self-reference handling); (b) the co-anchor synthetic-fixture test from
  §7; (c) updated assertions for every "High" and "Elevated" row in §6's table, confirmed
  genuinely failing against unmodified `HEAD`, not assumed.
- **GREEN:** implement §2.2 at the placement in §2.3. Empirically derive `.kMaxB1ProximityPush`
  against the **same D1 sibship-bar-overlap regression class** `.kMaxIndividualPush = 2` was
  originally tuned against (Track 7 Phase 1's own 3-iteration process, §5) — do not assume a
  starting value; if a first candidate reintroduces that regression class, treat the cap as its
  own owner-gated sub-decision (`AskUserQuestion`), matching S647's precedent exactly. Prove
  safety against every already-shipped case (Track 7 Phases 1/2/4, S660) both by an
  OR-monotonicity-style argument (this pass only ever *further* constrains an already-placed
  point; it cannot loosen an existing guarantee) and by direct reconstruct-and-simulate comparison
  from an identical pre-change snapshot, matching the duplicate-side design's own two-part
  verification bar.
- **Mandatory live chromote render check** (non-negotiable, per every prior Track 7 phase and this
  project's own repeated finding that raw-unit R-side arithmetic alone is insufficient): every
  pair among the 19 that this design's mechanism claims to resolve must render at
  `>= individualClearance × xScale` px apart at its actual DOM position, sampled through the full
  R → htmlwidgets → vis.js pipeline (`getLiveRenderedPositions()`), not computed x-values alone.
- **Full clean regression** (`pkgload::load_all()` then `testthat::test_dir(...)`, `NOT_CRAN=true`)
  — 0 new failures/errors beyond the pre-existing baseline.
- **`lintr::lint_package()`** (package loaded first via `pkgload::load_all()`) on all touched
  files — 0 lints or a documented `# nolint`.
- **Re-measure, never hand-derive**, every count named "at risk" in §6 — including the
  `test_resolveEdgeNodeCollisions.R:490-491` ripple this design's own evidence base did not
  originally enumerate.
- Correct `BACKLOG.md`'s item text per §6's final row, in the same close-out.

---

## 9. Effort Estimate and Recommendation

**Effort:** BACKLOG's own pre-design tag was Effort M. This design's evidence both **confirms**
part of that concern and **relieves** another part of it:

- *Harder than a first glance at "4 pairs" suggests:* the true scope is 19 pairs, not 4; the
  mechanism needs genuinely new code (not a drop-in reuse of an existing closure or a verbatim
  copy of Phase 4's pattern, §3.1/§3.3); and the new cap is a **known, but not small**, risk —
  Track 7 Phase 1's own precedent for tuning an analogous cap took 3 owner-gated iterations, each
  requiring a full regression run.
- *Easier than BACKLOG's own framing feared:* the 2 downstream passes BACKLOG explicitly worried
  about need **zero code changes** (§2.3/§6) — only re-verification. The mechanism pattern itself
  (per-generation, sorted-x, incrementally-tracked, capped bidirectional search with a
  direction-preference signal) is not novel — this exact function already contains three working
  instances of close variants of it (`b1Ids`'s own first pass, Phase 2's union sweep, Phase 4's
  duplicate push), so the implementation risk is "a fourth instance of an established,
  well-understood pattern family," not unexplored territory.

Net: **Medium**, trending toward the upper end of Medium if cap-tuning needs more than one
iteration — not the Large/XL scale a true `b1Ids`-mechanism redesign (Alternative (e), §4) would
be, since this design touches none of Track 7 Phase 1/2's own ratified formulas.

**Recommendation: proceed**, as its own dedicated implementing session — not deferred, not folded
into a larger redesign.

- **Against deferring further:** deferral leaves 19 (not 4) real, now-quantified proximity defects
  open on the standing top-priority pedigree-fidelity track; waiting produces no new information
  that would make the cap-tuning work any smaller when it eventually happens.
- **Against folding into a larger `b1Ids` redesign:** no such redesign is currently planned,
  scoped, or independently motivated (§4, Alternative (e)); this design's mechanism does not touch
  Track 7 Phase 1/2's ratified formulas at all, so there is no technical coupling forcing the two
  to ship together; and batching this scoped fix into a hypothetical future mega-session would run
  against this project's own repeated preference for narrow, incremental delivery (Track 7's own
  phase-by-phase shipping history, S660's own narrow 2-pair scoping, `SESSION_RUNNER.md`'s "1 and
  done" rule).
- **Against issue #159's "accept as inherent" precedent:** does not transfer — §1.6/§4 establish
  that #159's closure forecloses only whole-algorithm replacement, and this is a scoped local
  mechanism of a kind this codebase has already shipped four times successfully.

---

## 10. Owner ratification record

**RATIFIED**, 2026-08-31, via `AskUserQuestion` ("Ratify this B1-individual proximity design?" —
"Yes, ratify as recommended"): the 19-pair scope (§2.1) and the §2.2/§2.3 mechanism/placement
ship as designed here. Implementation is explicitly a separate future session (Planning Sessions
rule) — this document does not authorize any RED-phase work in S661 itself.

**Verification provenance, for a future implementing session's own Pre-RED trust calibration:**
this design was produced by a 7-agent research/synthesis/verify workflow (4 parallel research
agents — empirical re-measurement, code/test inventory, precedent review, downstream-impact
tracing — feeding one synthesis/drafting pass, followed by 2 independent adversarial verification
agents), then independently spot-checked a second time by the main session directly (not merely
re-reading the agents' own claims): re-ran `scratchpad/b1-design-verification.R` against current
`HEAD` and reproduced, byte-for-byte, both the 25/67 own-anchor collateral count (§3.2/§3.5) and
the 0-co-anchor-collision finding; independently confirmed the cited `individualClearance`
(`:1004`), `b1PushSign` (`:944-956`), and placement-boundary line numbers (`:1014`/`:1016`)
against the actual source; independently confirmed the `nColliding == 27L` (`:488`, `:1081`) and
`test_resolveEdgeNodeCollisions.R:490-491` citations against the actual test files. All checks
matched the draft's own claims with zero discrepancies found. This does not substitute for the
implementing session's own mandatory Pre-RED re-validation (§8) — code and data can move between
now and then — but it means this document's numbers were live-verified twice, independently, at
design time, not merely computed once and trusted.