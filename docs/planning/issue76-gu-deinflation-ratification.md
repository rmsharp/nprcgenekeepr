# Issue #76 — De-inflate the genome-uniqueness statistic for both-unknown founders (Reading A)

> **RATIFIED — this section is authoritative for issue #76.** Ratified by the
> owner (R. Mark Sharp) in **Session 190 (2026-06-24)** via four `AskUserQuestion`
> gates, grounded in a 10-agent research + adversarial-critique workflow
> (`wf_67d4c94a-691`: gene-drop mechanism, inflation chain with worked R
> examples, golden-test inventory, Reading-B consistency, conservation-genetics
> literature; then candidate design + per-candidate adversarial verification).
> Where this record conflicts with the issue body's framing, this record wins —
> the issue framed Reading A as a deep `calcGU`/`calcA`/gene-drop change; the
> ratified realization is materially less invasive (see §A, §C, §E).

This is the **ratification deliverable** required by issue #76 acceptance
criterion #1. **Implementation is a separate, strict-TDD session** (criterion
#2). Do **not** bundle the two (SESSION_RUNNER FM #18).

---

## A. Load-bearing finding (reframes #76)

**The visible problem is already fixed; this corrects the displayed number.**
Reading B (issue #9 Slice 3, PR #75) demotes the target animals to the bottom of
the displayed rank *regardless of `gu`* (they are labelled `"Undetermined"`,
`rankSubjects.R:37-44`). So the user-facing harm #76 was filed against — founders
falsely top-ranking — is **gone**. Reading A corrects the *reported `gu`
number*, which no longer drives the rank.

**The de-inflation resolves to a single value: reported `gu` = 0.** The target
population is, by construction, animals whose **both** parents are unknown.
Every such animal's two gene-drop alleles therefore trace entirely to
unknown-parent phantom mints (`assignAlleles.R:33-36`: a missing parent mints a
brand-new unique founder allele). "Decline to credit alleles whose apparent
uniqueness is an artifact of unknown parentage" thus excludes **all** of the
animal's alleles, collapsing its reported `gu` to **0**. There is no formula to
tune and no per-animal computation — the value is unambiguous.

**No replacement gene-drop golden values are needed.** Issue #76 acceptance
criterion #1 anticipated "replacement golden values for
`calcGU`/`calcA`/gene-drop." The adversarial review showed that expectation came
from a *more invasive* reading (untargeted exclusion, allele-pooling, or
denominator rescale — all rated **unsound**/**risky**, see §H). The ratified
targeted decline-to-credit, realized at the **report layer**, changes **none** of
those functions or their golden tests. Criterion #1 is satisfied by *this agreed
design* plus *new report-layer tests*, not by replaced gene-drop goldens.

---

## B. Why this realization (the genetics + design rationale)

**B1 — Decline-to-credit, not assumed relatedness.** The conservation-genetics
literature is explicit that there is no assumption-free choice (PMx/PedScope;
Jiménez-Mena et al. 2016): treating unknown parents as unique founders
*overstates* uniqueness (the bug); assuming them related *understates* kinship;
pooling erases real signal. The owner ratified the most conservative position —
**we do not know the ancestry, so we report no credited uniqueness (`gu` = 0)** —
over the heavier "assume shared founder ancestry" pool (candidate A3), which
would embed a contestable relatedness policy as a default and inject
per-iteration randomness.

**B2 — Report layer, not `calcGU`.** Both placements produce *identical reported
numbers* (owner-confirmed gate 4). The report-layer realization is strictly
cleaner: `calcGU`/`calcA`/`geneDrop` and **all** their golden tests stay
byte-identical, and the documented stance at `calcGU.R:10-34` (and the
PedScope founder-genome-uniqueness alignment at `calcGU.R:30-34`) is **not
reversed** — `calcGU` keeps computing the textbook statistic; `reportGV` applies
a documented colony policy that declines to credit unknown-origin animals. This
inverts the issue's premise that Reading A "reverses the documented stance at
`R/calcGU.R:10-34`": under the ratified design it does not.

**B3 — Test-author caveat (do not over-target).** The target predicate is
**U-id-aware**: a parent is unknown when it is `NA` **or** an auto-generated
placeholder id (`classifyParentage.R:21`: `is.na(x) | isGeneratedUnknownId(x)`).
Raw `is.na()` on an un-normalized pedigree returns 0 unknowns because U-ids are
present as strings (the §8-C adversary-confirmed trap from issue #9). Equally, do
**not** target the gene-drop founder set (`isFounder`/`getFounders`): after
`addParents` synthesizes U-stub rows with `NA` parents, the gene-drop founders
and the classification "both unknown" set are **different animals** (a
U-id-parented proband is "both unknown" by classification but inherits from its
U-stub parents at the gene-drop level). The target is the **classification /
report** set, where `origin` is known — exactly `orderReport`'s `noParentage`
bucket. Targeting the gene-drop founder set instead was the fatal flaw that made
candidate A2 unsound (§H).

---

## C. Authoritative rule (RATIFIED)

**C1 — Target predicate (the "Undetermined" / `noParentage` set).** For the
probands in the report, an animal is a de-inflation target iff:

```
undetermined = classifyParentage(sire, dam) == "both unknown"   # U-id aware
               AND  is.na(origin)                                # ONPRC-born
```

where `origin` is `demographics$origin` when present, else `rep(NA, n)` (absent
origin → all both-unknown animals are ONPRC-born). This is **identical** to
`orderReport`'s `noParentage` split (`orderReport.R:38-62`), so the de-inflated
set equals the demoted set by construction. **Imports** (both-unknown **with** a
recorded `origin`, `orderReport.R:50-51`) are **preserved** — their `gu` is left
exactly as `calcGU` computed it.

**C2 — The value.** For every targeted row, set reported genome uniqueness to
`0`. Apply to **both** surfaces `reportGV` exposes: the report's `gu` column
(via the `cbind` at `reportGV.R:186-188` feeding `orderReport`) **and** the
returned standalone `$gu` element (`reportGV.R:193`) — one coherent "reported
genome uniqueness" everywhere (owner-confirmed: report-layer, applied
consistently).

**C3 — Invariants (preserve / total-function / NA-safety).**
- `gu >= 0` preserved (0 is the floor). `gu` is a percentage, **not** bounded to
  `[0,1]` (`test_modGeneticValue.R:741` comment) — only the floor matters here.
- **Never** inject `NA` into `gu` (it would poison `rank()`/`order()` in
  `orderReport`/the module). The rule writes `0`, never `NA`.
- The classification-aware demotion (`rankSubjects.R:37-44`,
  module `rank(indivMeanKin - gu)`) keys on `value == "Undetermined"`, **not** on
  `gu` magnitude, so it remains correct on top of the de-inflated `gu`; the two
  corrections compose, they do not fight.
- No overlap with the Slice 2 mean-kinship correction
  (`reportGV.R:116-122` touches `indivMeanKin` for **one-unknown** animals only;
  this rule touches `gu` for **both-unknown** animals only).

---

## D. New infrastructure

**None.** Unlike issue #9 §8-D (which added a species/sex breeding-age table),
this rule needs no new data, no new accessor, no new config knob, and no new
exported function. It is a ~3–5 line addition inside `reportGV` reusing
`classifyParentage` (already called at `reportGV.R:184`) and the `origin` column
(already in `getIncludeColumns()`/`demographics`).

---

## E. Downstream RED → GREEN charter (the implementation session spec)

Strict TDD. Declare phase every response; gate every transition with
`AskUserQuestion`.

### RED (new tests — all must fail for the right reason first)

1. **`test_reportGV.R` — the core behavior.** Build a fixture pedigree carrying
   an `origin` column with: (a) an **ONPRC-born** both-unknown founder
   (`sire=NA, dam=NA, origin=NA`); (b) a both-unknown **import**
   (`origin = "CHINA"` or similar); (c) a fully-known animal. Run
   `reportGV(...)`. Assert:
   - the ONPRC-born founder's `gu` is `0` in **both** `$report` (its `gu`
     column) and `$gu`;
   - the import's `gu` is **unchanged** (equal to a reference `calcGU` value /
     `> 0` if the fixture makes it high-gu) — imports are preserved;
   - the known animal's `gu` is unchanged.
   *(A fixture WITH an `origin` column is required to exercise the
   import-preservation branch — `makeValidTestPed` lacks `origin`; see issue #9
   §8-F, which flagged the same fixture need.)*
2. **`test_modGeneticValue.R` — displayed value.** Extend the existing
   both-unknown-founder test (`:782-810`, `makeValidTestPed`, no `origin` → all
   founders are `noParentage`): in addition to the demotion assertions
   (`:798-808`, which must still pass), assert the displayed `results$gu` for the
   Undetermined founders is `0`.
3. **Targeting guard.** Assert a **U-id-parented** both-unknown, no-origin
   proband (sire/dam are generated U-ids, not literal `NA`) is also de-inflated
   to `gu = 0` — proving the predicate is U-id-aware, not raw `is.na`.

### GREEN (minimal)

- **`R/reportGV.R`** — after `parentage <- classifyParentage(...)`
  (`reportGV.R:184`) and **before** the `cbind` (`:186`) and the `gu = gu` list
  element (`:193`), compute the `undetermined` mask of §C1 and set
  `gu$gu[undetermined] <- 0` (the `gu` rows are in `probands` order ==
  `demographics`/`parentage` order, so the logical index aligns). Mirror
  `orderReport`'s origin-absence handling (`"origin" %in% names(demographics)`
  else all-NA). Add a comment citing issue #76 Reading A.
- **`R/reportGV.R` roxygen** — document that reported genome uniqueness is set to
  `0` for unknown-origin both-unknown ("Undetermined") animals (decline-to-credit
  policy), and regenerate `man/reportGV.Rd`.
- **`R/calcGU.R:10-34`** — add ONE clarifying sentence: `calcGU` itself is
  unchanged and still includes living founders' alleles; the *report*
  (`reportGV`) applies a decline-to-credit policy for unknown-origin animals.
  This keeps the PedScope-alignment prose accurate (it remains true for
  `calcGU`).

### DONE looks like

`reportGV` reports `gu = 0` for the `noParentage`/Undetermined set in both
`$report` and `$gu`; imports and known animals unchanged; the Slice-3 demotion
still correct; **all existing golden tests pass unmodified**
(`test_calcGU`/`test_calcA`/`test_geneDrop` untouched;
`test_modGeneticValue.R:742-743,798-808,1394-1395` and `test_reportGV.R:20,45`
hold — verified S190); new RED tests green.

### Verify

- Build-equivalent `devtools::check(vignettes = FALSE)` = **0/0/0** (Learning
  161).
- `spell_check_package(".")` = 0 (Learning 175 — a 0/0/0 check does not imply
  spelling-clean).
- Targeted: `test_reportGV.R` + `test_modGeneticValue.R`; full regression clean
  (ignore baseline `test-app-*`/`test-e2e-*` noise — CLAUDE.md "Clean regression
  read").
- **Phase-3E (mandatory — changes a displayed value, FM #24):** `runModularApp()`
  smoke; load a pedigree with an Undetermined founder; confirm the GVA table
  shows `gu = 0` for it and it remains ranked last. Mind the `getSiteInfo` boot
  trap (Learning 176) — boot with the example config.

### Session boundary

ONE implementation session. Close out when DONE. **Publish is a separate
session** (PR body `"Closes #76"`; fold the NEWS entry into the same PR, Learning
157a; watch CI + fresh non-watch re-query, 157b).

---

## F. Accepted residuals & follow-on

- **Descendant residual (accepted, by owner ratification — "founder's own row
  only").** A descendant of an Undetermined founder that *inherited* a phantom
  allele keeps a small residual `gu` bump — its own row is **not** de-inflated
  (it is not "both unknown"). De-inflating descendants too would require marking
  the phantom alleles at the mint point and excluding them from the population
  rare-count everywhere (a heavier, targeted variant of the **unsound** candidate
  A2, which also changes `calcA`). Documented as an accepted limitation; raise a
  separate issue only if the residual proves material in practice.
- **`$gu` consistency (resolved).** The de-inflation is applied to both the
  report column and the `$gu` element (§C2), so a caller reading `geneticValue$gu`
  sees the same de-inflated values as the displayed report.

---

## G. Follow-up issues

None mandatory. The descendant residual (§F) is the only candidate future
enhancement and should be filed only if observed to matter.

---

## H. Candidates considered and rejected (adversarial review, `wf_67d4c94a-691`)

| Cand. | Approach | Verdict | Decisive reason |
|---|---|---|---|
| **A1 (refined → RATIFIED)** | Targeted decline-to-credit; report-layer in `reportGV` | **adopted** | Only non-unsound path. Refined to target the `noParentage` set (not the full "both unknown" set, which would wrongly de-inflate imports) and to live at the report layer (leaving `calcGU`/goldens untouched). |
| A2 | Tag phantom alleles at the gene-drop mint point, exclude in `calcA` | **unsound** | After `addParents`, *every* founder has `NA` parents — so it marks **all** founders, and its gene-drop predicate diverges from the U-id-aware classification (false positives **and** false negatives). Wrong population, wrong pipeline stage. |
| A3 | Draw both-unknown founder alleles from a shared pool | **unsound** | Injects new per-iteration randomness (founder alleles stop being constant), breaks all seeded goldens, and bakes a contestable relatedness *policy* into a default. |
| A4 | Rescale the `calcGU` denominator | **unsound** | The inflation is in the **numerator** (`rowSums(rare)`, `calcGU.R:91`); rescaling the denominator moves every row by the same factor, leaving the founder's *relative* standing unchanged. Does not de-inflate. |

---

## I. Firsthand anchors (verified Session 190)

- `R/assignAlleles.R:33-36` — the phantom-allele mint point (`rep(counter, n)`;
  `counter++`).
- `R/calcGU.R:91,94` — `gu = rowSums(rare)/(2L*iterations)*100`;
  `:10-34` documented stance (NOT reversed by this design); `:30-34` PedScope
  alignment (stays valid for `calcGU`).
- `R/reportGV.R:141-142` (`calcGU` call + `gu[probands,]`), `:184`
  (`classifyParentage`), `:186-188` (`cbind`), `:190` (`orderReport`), `:193`
  (`$gu`) — the GREEN insertion site is after `:184`, before `:186`.
- `R/orderReport.R:38-42` (bothUnknown), `:43-47` (origin-absence → all-NA),
  `:50-51` (imports kept), `:62-69` (noParentage demoted).
- `R/classifyParentage.R:20-28` (U-id-aware labels), `:21` (`isU` predicate).
- `R/rankSubjects.R:37-44` (`noParentage` → `value="Undetermined"`, `rank=NA`).
- `R/getIncludeColumns.R:16` — `origin` is in the include set, so
  `demographics$origin` is available in `reportGV` when present.
- Untouched golden tests confirmed to hold: `test_modGeneticValue.R:742-743`
  (gu≥0), `:798-808` (demotion), `:1394-1395` (determinism), `test_reportGV.R:20,45`
  (nrow). `test_calcGU`/`test_calcA`/`test_geneDrop` goldens
  (110/43/53/0; 318/325/313/328; seeded `geneDrop` tallies) are untouched because
  `calcGU`/`calcA`/`geneDrop` are unchanged.
