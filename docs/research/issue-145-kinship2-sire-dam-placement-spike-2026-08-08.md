# Issue #145 verification spike: does kinship2 actually enforce "sire left, dam right"?

**Date:** 2026-08-08 (Session 482)
**Trigger:** Tier 1 step (2) of
`docs/audits/PEDIGREE_DIAGRAM_BACKLOG_SEQUENCING_AUDIT_2026-08-08.md`'s Finding #1/#2 recommendation
— before any design work on [issue #145](https://github.com/rmsharp/nprcgenekeepr/issues/145),
check kinship2's actual *default* (no-hints) sire/dam left-right placement behavior directly, rather
than accepting issue #145's own framing ("the pedigree drawing layout **is to follow** standard
genetic counseling conventions where the male... is placed to the left and the female... is placed
to the right") at face value.
**Scope:** Investigation only. No `R/`/`tests/` package code changed — TDD RED/GREEN/REFACTOR gates
do not apply (matches the established audit-only precedent, e.g. S480's sequencing audit). No
design or implementation decision for #145 is made here.

---

## Method

1. Confirmed `kinship2` (v1.9.6.2) is already installed locally in this project's `renv` library
   (not added to `DESCRIPTION`/`renv.lock` — same local-only, one-off-reference-material pattern
   established by `docs/planning/pedigree-diagram-kinship2-reference-comparison.qmd`'s Setup chunk).
2. Read kinship2's actual alignment source directly — `align.pedigree()`, `alignped1()`,
   `autohint()` — extracted via `deparse(get(fn, envir = asNamespace("kinship2")))`, not from any
   secondary description.
3. Read kinship2's own shipped help documentation (`?align.pedigree`) for any textual claim about a
   sex-based ordering rule.
4. Built 5 small synthetic pedigrees exercising the specific scenarios issue #145's own body
   describes (single pair; multi-mate "crowding"; role-reversed crowding; an explicit-hint
   override) and called `align.pedigree()`/`autohint()` directly, reading the real `$nid` output —
   not inferring behavior from documentation alone.
5. Cross-checked against the project's own existing worked example
   (`sample.ped` family 2, the `.qmd` comparison doc's "cleanest comparison" fixture).

Full source dump and R scripts used are not committed (scratch files); the code excerpts and R
output below are the evidence, reproduced directly from real runs.

---

## Finding: there is no `if (sex == "male") place-left` rule anywhere in kinship2

`align.pedigree()`'s own construction of the internal spouse list, for the ordinary case (a real
parent pair taken directly from the pedigree's `sire`/`dam` — i.e., the path every actual
mother/father pair in a real pedigree takes, with no explicit `hints` supplied):

```r
if (any(dad > 0 & mom > 0)) {
    who <- which(dad > 0 & mom > 0)
    spouselist <- rbind(spouselist, cbind(dad[who], mom[who], 0, 0))
}
```

Column 1 is the father index, column 2 the mother index — but only because `dad`/`mom` (from
`ped$findex`/`ped$mindex`) are those slots *by construction*, not because of any sex check in this
line. Contrast this with the two other spouselist-construction branches a few lines above it
(hinted spouse pairs, and `relation` type-4 "marriage" rows) — both of *those* branches explicitly
inspect `ped$sex` and swap columns to force the male into column 1:

```r
tsex <- ped$sex[hints$spouse[, 1]]
spouselist[, 1] <- ifelse(tsex == "male", hints$spouse[, 1], hints$spouse[, 2])
spouselist[, 2] <- ifelse(tsex == "male", hints$spouse[, 2], hints$spouse[, 1])
```

The direct-pedigree branch (the one that governs an ordinary sire/dam pair with no hints — i.e.
the actual default case for essentially every real colony pedigree) has **no such check**. The
left/right split that later happens in `alignped1()` for that branch is driven entirely by
`spouselist[sprows, 3] == 0` bookkeeping and an `nleft` count derived from array position — never
by `ped$sex`.

`autohint()`'s own crossing-resolution machinery (`duporder()`/`shift()`, used only to reposition an
individual who is *duplicated* across the plot because they have multiple mates elsewhere in the
tree) likewise never reads `ped$sex` to decide a left/right order — `findspouse()` uses `ped$sex`
only to *locate* which neighboring plot position holds the opposite-sex partner, not to rank them.

kinship2's own shipped help page (`?align.pedigree`) describes the `hints$spouse` override purely
positionally, with zero mention of sex:

> *"...usually only a few marriages in a pedigree will need an added hint, for instance reverse the
> plot order of a husband/wife pair. Each row contains the index of the left spouse, the right hand
> spouse, and the anchor: 1=left, 2=right, 0=either."*

That "reverse the plot order of a husband/wife pair" is offered as the canonical *example* of when a
hint is needed is itself telling: the package's own documentation treats male-left as a thing you
sometimes have to explicitly override, not a rule it enforces.

---

## Empirical confirmation

| Case | Setup | Default (no-hints) result | Sex determines the split? |
|---|---|---|---|
| 1 | 1 sire, 1 dam, 2 kids (simple pair) | `S1(M), D1(F)` — sire left | Coincidental (see below), not a rule |
| 2 | 1 sire, 2 dams (crowding) | `D1(F), S1(M), D2(F)` — sire **centered**, dams flank | No — split by discovery order |
| 3 | 1 dam, 2 sires (role-reversed crowding) | `S1(M), D1(F), S2(M)` — dam **centered**, sires flank | No — split by discovery order |
| 4 | `sample.ped` family 2 (project's own existing fixture, no multi-mate individuals) | consistent with Case 1's pattern at every level | Coincidental, same mechanism as Case 1 |
| 5 | Case-1 pair + explicit `hints$spouse` requesting dam-left | `D1(F), S1(M)` — hint honored, dam **left** of sire | N/A — explicit override, not sex-driven |

Case 3 is the decisive result: with a dam mated to two sires, `S2` is placed to the **immediate
right of the dam**, and `S1` to her **immediate left** — a direct, concrete violation of "sire is
always to the left of dam" at the level of an individual pair, produced by kinship2 itself, under
its own default (no-hints) algorithm, on ordinary pedigree data with no synthetic tricks. Case 5
shows the single-pair default is a hint, not an invariant — a two-row explicit hint flips it with no
error, no warning, no special-casing required.

The mechanism explaining Case 1's/Case 4's apparent "sire-left" result: for an individual with
exactly one mate, kinship2's `nleft` split formula happens to route the internally-recorded father
slot into the left group regardless of whether alignment recursion starts from the father or the
mother — an artifact of the formula and of `dad`/`mom` always occupying columns 1/2 respectively,
not a conditional branch on `ped$sex`. The moment an individual has *more than one* mate — the exact
"crowding" scenario issue #145's own body raises in its "Resolution of the Male-Left Rule Conflict"
section — that artifact stops holding, and left/right is decided purely by which mate's pairing was
encountered first while scanning the pedigree (i.e., data row order), independent of sex.

---

## Answer to the audit's Finding #1/#2 question

**Hard invariant vs. soft default: kinship2 implements neither a hard invariant, nor a
crossing-minimizing soft default keyed to sex.** It implements a sex-*agnostic*, discovery-order
default that happens to look like "male-left" in the simplest case (one mate, no crowding) purely as
an artifact of internal father/mother-slot indexing, and abandons even that appearance the moment an
individual has multiple mates. There is no code path in kinship2 that inspects `ped$sex` to decide
left/right placement for an ordinary parent pair, and the package's own documentation frames
sire/dam ordering as an overridable hint, not a rule.

This sharpens (does not overturn) the prior audit's Finding #1/#2: Finding #1 correctly identified
#145 as new-feature design work, not a bug fix, since `nprcgenekeepr`'s own code has zero sex-based
positioning logic to be "corrected." Finding #2 correctly found the cited nomenclature reference
document does not textually support a male-left rule. This session adds a third, independent data
point: **kinship2 itself — the reference implementation issue #145's own body invokes — does not
implement or document a general male-left rule either.** Issue #145's inline citations ("[2]",
"[3]", etc., already flagged by the prior audit as unresolved against this project's own reference
document) also do not match kinship2's actual algorithm in a specific, checkable way: the citation
text describes the multi-mate case as minimizing "line crossing for their offspring" via the
placement itself, but no crossing-minimization computation exists in kinship2's direct-pedigree
spouse-split path — the split is pure discovery order. Whatever those citations describe, it is not
an accurate account of kinship2's own current source.

## Recommendation for a future #145 design session

- Treat "male typically left, female typically right" as **common genetic-pedigree drawing
  practice worth defaulting to for the simple single-mate case** (matching kinship2's own
  incidental behavior there) — not as a hard invariant to enforce unconditionally, and not
  attributed to kinship2 as a deliberately-implemented rule (it isn't one).
- For the multi-mate/crowding case, the natural analog of kinship2's actual behavior is
  **anchor-centered, mates split by data order** (already `nprcgenekeepr`'s own existing tie-break
  convention in `.positionMatingUnitForest()` for unrelated reasons) — not a sex-based split, since
  kinship2 itself has none to emulate.
- Do not cite kinship2 as authority for a strict per-pair "sire always left of dam" behavior — Case
  3 above is a direct, reproducible counter-example from kinship2's own default output.
- Do not cite issue #145's own inline citations ([2]-[7]) as verified technical sources without
  independently re-deriving whatever specific claim is being cited — this session found one
  concrete point (crossing-minimization in the direct spouse split) that does not match kinship2's
  actual source.
- `docs/planning/pedigree-diagram-kinship2-reference-comparison.qmd`'s refresh (Tier 1 step 3, not
  this session's scope) would benefit from adding a "multi-mate crowding" worked example
  demonstrating kinship2's actual centered-anchor/discovery-order behavior, since none of its
  current 3 examples exercises this specifically.
