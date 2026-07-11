# `read.csv()` F/T/TRUE/FALSE Type-Coercion Audit

**BACKLOG item:** "Audit other `read.csv()` calls in `tests/` for the same F/T/TRUE/FALSE
type-coercion risk that recurred in S355" (discovered S355, 2026-07-11)
**Date:** 2026-07-11 (Session 356)
**Scope gate:** All `read.csv(`/`utils::read.csv(` call sites in `tests/testthat/*.R`
found by a fresh grep this session (not a re-use of S355's list — see §4 Structural
Observation 4).
**Status:** Audit complete. This report is the deliverable; **no code was changed in
this session** — zero findings required a fix (see §1).

---

## 1. Audit Summary

- **Criteria.** For every `read.csv()` call in `tests/testthat/*.R` that reads back a
  downloaded/exported CSV: (a) which column(s) does the test actually assert on
  afterward, (b) could that column's real value set, for any plausible fixture/test
  data, consist *entirely* of tokens from `{T, F, TRUE, FALSE, True, False, true,
  false}` (the set base R's `read.csv()`/`type.convert()` silently coerces to logical,
  regardless of `stringsAsFactors = FALSE` — that argument does not prevent this), and
  (c) if so, is there an explicit `colClasses` (or equivalent) guard already in place?
  Verdict per site: **FAIL** (vulnerable — plausible all-T/F-token column, no guard),
  **ALREADY-FIXED** (plausible all-T/F-token column, guard present), or **PASS** (no
  column actually asserted on could ever collapse to that token set).
- **Method.** Fresh `grep -rn "read\.csv("` across `tests/` (not a re-use of S355's
  count — see §4.4), which found **27 call sites across 12 files** (S355's own sweep
  had found "roughly a dozen" across 9 files — it undercounted by one whole file and
  several sites within an already-named file). One file (`test_modBreedingGroups.R`,
  4 sites) was audited directly by the orchestrating session; the other 11 files (23
  sites) were each audited by an independent agent given the exact mechanism above,
  instructed to read the full (possibly multi-line) call, trace the CSV's real data
  origin (an `R/mod*.R` `downloadHandler` content function, or an in-test fixture), and
  verify continuation-line `colClasses` before concluding a site was unguarded.
- **Coverage.** 27 / 27 call sites classified. 12 / 12 files fully read (no partial
  reads or skips).
- **Finding count.** **0 FAIL.** 6 ALREADY-FIXED, 21 PASS, 0 vulnerable sites found.

**Headline.** No currently-vulnerable `read.csv()` call sites exist in `tests/`. The
defect fixed in S355 (`test_modBreedingGroups.R`'s `downloadGroup` test) was, on the
evidence gathered here, the only real instance of this bug — everywhere else, either
the column actually asserted on can never collapse to an all-T/F-token set (the large
majority: IDs, kinship floats, integer counts, multi-word category labels, fixed
literal strings), or an explicit `colClasses` guard was already present, in three cases
predating this audit entirely (`test-e2e-potential-parents-module.R`,
`test-e2e-orip-module.R`, `test_modPotentialParents_coverage.R` — all three shipped
with the guard already in their first commit). Two of the six `ALREADY-FIXED` sites
(`test_modSummaryStats_coverage.R:128,134`) are in fact the *original* site Learning
269(e) (S290) itself fixed — the module where this defect class was first discovered.

---

## 2. Findings

No FAIL findings. Zero.

---

## 3. Items Audited

| File | Sites | Verdict(s) | Notes |
|---|---|---|---|
| `test_modBreedingGroups.R` | 4 | 1 ALREADY-FIXED, 3 PASS | The ALREADY-FIXED site is the exact test S355 fixed this session's predecessor. |
| `test_getFocalAnimalPed.R` | 2 (302, 545) | 2 PASS | Only an `id` (animal-ID string) column read/asserted; no Sex column touched. |
| `test_modPedigree_coverage.R` | 1 (56) | 1 PASS | Only `id` asserted; underlying fixture has a mixed-sex `sex` column, never read back — dormant risk, see §4.3. |
| `test-e2e-potential-parents-module.R` | 1 (119) | 1 ALREADY-FIXED | `colClasses = "character"` recycled across all 5 columns; none are Sex-like regardless. |
| `test_modGeneticValue.R` | 1 (1423) | 1 PASS | Only `id` asserted (`F<n>`/`O<n>` strings); dormant risk if a future edit asserts on `sex`, see §4.3. |
| `test_modSummaryStats_coverage.R` | 5 (128, 134, 155, 179, 185) | 2 ALREADY-FIXED, 3 PASS | 128/134 are the male/female founder handlers — the original S290 fix site for Learning 269(e); the other 3 read count/kinship/multi-word-label columns, immune by shape. |
| `test_modORIPReporting_server.R` | 4 (177, 208, 226, 242) | 4 PASS | `Category`/`Metric`/`Note` are fixed literal/categorical strings, never T/F tokens; `id` at 226 is asserted, not `sex` — dormant risk, see §4.3. |
| `test_modInput_coverage.R` | 3 (258, 259, 260) | 3 PASS | Only `is.data.frame()`/`nrow()` asserted; no column value ever compared. |
| `test_modInput.R` | 2 (762, 860) | 2 PASS | Static fixture (`focalAnimalsShortList.csv`), single `id` column of animal-ID strings, used only for `%in%` membership. |
| `test-e2e-orip-module.R` | 1 (141) | 1 ALREADY-FIXED | `colClasses = "character"` present since the file's first commit; also inherently low-risk shape (heterogeneous `Value` column). |
| `test_modPotentialParents_coverage.R` | 1 (79) | 1 ALREADY-FIXED | Same guard/shape reasoning as the e2e potential-parents site above. |
| `test_species_first_class.R` | 1 (71) | 1 PASS | Only the CSV *header* (`names()`) is read; no row/column values touched at all. |
| **Total** | **27** | **6 ALREADY-FIXED / 21 PASS / 0 FAIL** | |

---

## 4. Structural Observations

1. **The defect is narrowly shaped, not a general `read.csv()` risk.** It requires a
   column that is (a) actually read back **and** asserted on after the `read.csv()`
   call, and (b) capable of holding *only* T/F-token values for some plausible fixture
   (in practice: a Sex/M-F column filtered or subset down to a single sex). The large
   majority of this project's `read.csv()` call sites read ID strings, numeric counts,
   kinship floats, or multi-word category labels — none of which can collapse into
   `{T,F,TRUE,FALSE,...}` regardless of guard presence.
2. **Every site that both reads back a Sex column AND asserts on it already has a
   guard.** The two real-risk sites this audit found (`test_modSummaryStats_coverage.R`
   founder handlers) are the *original* Learning 269(e) fix from S290 — the module
   where this defect class was first discovered and where the fix pattern
   (`colClasses = "character"`) originates. Three other sites
   (`test-e2e-potential-parents-module.R`, `test-e2e-orip-module.R`,
   `test_modPotentialParents_coverage.R`) carry a single-length `colClasses =
   "character"` (which base R recycles across every column) from their very first
   commit — these were written defensively, not retrofitted.
3. **Dormant risk (not a finding, no action needed today): three sites read a fixture
   whose underlying data has a mixed-sex `sex`/`Sex` column, but the current test never
   asserts on it** — `test_modPedigree_coverage.R:56`, `test_modGeneticValue.R:1423`,
   `test_modORIPReporting_server.R:226`. If a future edit to any of these three tests
   adds an assertion on that column, it should add a `colClasses` guard at the same
   time, per the established Learning 269(e)/327 remedy — but there is nothing to fix
   in the code as it stands, since an unread column cannot be miscoerced into a wrong
   assertion.
4. **A prior session's grep-based inventory is a starting point, not ground truth —
   re-run it fresh.** S355's own sweep (Learning 327(d)) found "roughly a dozen" sites
   across 9 files; this session's fresh grep found 27 sites across 12 files, including
   an entire file (`test_modSummaryStats_coverage.R`) the S355 sweep missed outright.
   Neither sweep was wrong to file the follow-up as a separate audit rather than
   trusting the count — but this confirms the project's established "verify
   empirically, don't trust a prior session's numbers verbatim" discipline
   ([[consult-project-source-of-truth]], Learning 325(iii)/326(e)/327(d)) applies to
   a predecessor session's own grep output, not just to `BACKLOG.md` prose claims.

---

## 5. Comparison with Prior Audits

No prior audit of this exact defect class exists — S355 fixed one instance as part of a
flaky-test fix session (not an audit) and filed this follow-up. The closest prior
audit in shape is `docs/audits/ISSUE_37_UNUSED_EXPORTS_AUDIT_2026-06-27.md` (a
grep-based inventory audit with no code changes); no finding overlap (different defect
class entirely).

| Metric | Prior | Current | Trend |
|---|---|---|---|
| Total findings | N/A (first audit of this class) | 0 | — |
| Sites in scope | ~12 (S355 estimate, unverified) | 27 (verified) | scope grew on fresh grep |
| Already-guarded sites | 1 (the S355 fix itself) | 6 | 5 pre-existing guards this audit surfaced were not previously inventoried |
| Coverage | N/A | 27 / 27 sites, 12 / 12 files (100%) | — |

---

## 6. Recommendations

1. **No code changes required.** All 27 sites are either safe by column shape or
   already guarded; there is nothing to fix.
2. **No new BACKLOG item.** The three dormant-risk sites (§4.3) require no action until
   a future test edit actually adds an assertion on the at-risk column — flagging them
   speculatively now would create BACKLOG noise for work that may never become
   necessary. If any of those three tests is edited in a future session to assert on
   its `sex`/`Sex` column, that session should add the `colClasses` guard as part of
   its own change, per Learning 269(e)/327.
3. **Close the BACKLOG item that requested this audit** (`BACKLOG.md`'s "Audit other
   `read.csv()` calls..." entry) — its stated deliverable (a decision on whether each
   site needs a fix) is now fully answered: none do.
