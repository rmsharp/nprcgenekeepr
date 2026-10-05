# Shard verify-script failures: characterization and draft upstream report (S901, 2026-10-04)

> **Status:** characterization DONE; the upstream report is a **draft and has not been posted anywhere.** The place to
> post it is an owner decision (see "Where it can go" below), because the channel the S898 ruling named does not exist
> as an issue tracker.

## Audit summary

- **Scope:** all 54 `docs/archive/*-through-*.md.verify.sh` scripts, the self-checking losslessness proofs that
  `methodology_trim.py` writes beside each archive shard (CHANGELOG 16, HANDOFFS 15, SESSION_NOTES 23).
- **Criteria:** does each script exit 0, and when it does not, is the trim it checks actually lossy, or is the script
  wrong? "Lossy" is decided by diffing the records themselves, never by the script's own verdict.
- **Coverage:** 54 of 54 run. **44 pass, 10 fail** (re-measured today; S898 measured the same 10, so nothing changed).
  Generator versions: 18 scripts written by `methodology_trim.py` v1.1.2 (2 fail), 36 by v1.5.0 (8 fail).
- **Result:** **0 of the 10 failures is a real loss.** Every one is a false alarm on a lossless trim, from three causes.
  S898's open question ("cause not yet known for 7 of the 8 L1 failures") is closed: 7 are Finding 1, 1 is Finding 2.

| Finding | Cause | Scripts | Generator | What the script wrongly reports |
|---|---|---|---|---|
| 1 | The trim commit also finalized the newest ("frontier") record (BL-27, kept as a loud FAIL on purpose) | 7 (6 SESSION_NOTES, 1 HANDOFFS) | v1.5.0 | `FAIL: L1 ...` and `FAIL: L3 ... MISSING` |
| 2 | A record count baked in at generation time (`INJECTED=0`); the trim commit added one record | 1 (SESSION_NOTES) | v1.1.2 | `FAIL: L1 ...` and `FAIL: L3 record count 79 != 78` |
| 3 | The L2 "leak" test is a substring test, so a mid-line quote of a front-matter line counts as a leak | 2 (HANDOFFS, CHANGELOG) | v1.5.0, v1.1.2 | `FAIL: L2 FRONT MATTER leaked N line(s)` |

## Findings

### Finding 1: a close-out commit that also trims always trips L1 and L3 (7 scripts)

- **Severity:** Moderate. Not a loss, but a close-out commit that also carries a trim ends with a red proof.
- **Location:** generated script, `frontier_edit` and the `L1`/`L3` blocks (BL-27 fix 2, BL-36 re-expression).
- **Description:** in these 7 trims the archive write and the session's close-out edit landed in one commit, so record 0
  (the newest) differs between the commit's parent and the commit. The script reports it as `MISSING` plus `added`, prints
  `NOTE ... matches a known, accepted pattern (BL-27)` and still exits 1. The NOTE ends "manually diff record 0 by hand".
- **Evidence (the by-hand diff, done for all 7):** in each case record 0 before the trim is the session's own claim
  stub, and after it is the finalized record under the same anchor; every other record is byte-identical.

| Shard | Record 0 | Before (stub) | After (finalized) |
|---|---|---|---|
| `HANDOFFS-through-2026-09-26-3` | receipt `S790` | `status: pending`; `active_task` filled, the other 10 lines `pending` | `status: complete`, all 11 lines filled; **7 receipts before, 7 after** |
| `SESSION_NOTES-through-2026-09-20-2` | `What Session 745 Did` | 14 lines, 807 B | 121 lines, 7,899 B |
| `SESSION_NOTES-through-2026-09-21-2` | `What Session 758 Did` | 9 lines, 432 B | 139 lines, 8,915 B |
| `SESSION_NOTES-through-2026-09-21` | `What Session 752 Did` | 11 lines, 553 B | 105 lines, 6,931 B |
| `SESSION_NOTES-through-2026-09-26-4` | `What Session 791 Did` | 9 lines, 536 B | 166 lines, 14,846 B |
| `SESSION_NOTES-through-2026-09-28-2` | `What Session 806 Did` | 6 lines, 565 B | 105 lines, 6,460 B |
| `SESSION_NOTES-through-2026-09-28` | `What Session 801 Did` | 8 lines, 592 B | 94 lines, 8,074 B |

  The six SESSION_NOTES trims also add one new `Session N Handoff Evaluation` record each; the script already handles
  that (an added record is not a failure since BL-36).
- **Impact:** a reader cannot tell this pattern from a real loss without doing the diff above, and 7 of the 38 SESSION_NOTES
  and HANDOFFS proofs here (18%) end red this way.
- **Recommendation:** keep a real loss red, but make the pattern machine-distinguishable: have the script print the
  record-0 diff itself, and use a distinct exit status (or an `OK-with-note` line) when `frontier_edit` holds and every
  other record is proven identical. This changes BL-27's "stays a FAIL" judgement, so it is the upstream author's call.

### Finding 2: v1.1.2 scripts hard-code how many records the trim injected (1 script)

- **Severity:** Minor. Already fixed in the generator; the old frozen script cannot benefit.
- **Location:** `SESSION_NOTES-through-2026-08-15.md.verify.sh` lines 17 (`INJECTED=0`), 161, 172, 231.
- **Description:** the script skips the first `INJECTED` positions of the live file and then demands equal counts. The
  trim commit (`850e367`, "S594 -- close out") also added `### Session 593 Handoff Evaluation (by Session 594)`, which
  the generator could not know at write time, so L3 says `record count 79 != 78`.
- **Evidence:** headings absent after the trim: **none**; headings added: that one. The generator's own version note
  (1.2.0) describes exactly this and says BL-36 replaced the constant with a measured set.
- **Recommendation:** none for the generator. The existing script needs regenerating (see Structural observation 1).

### Finding 3: the L2 leak test is a substring test (2 scripts)

- **Severity:** Minor.
- **Location:** generated script, `leaked = [ln for ln in bfront.splitlines() if ... (ln in sfront or ln in "".join(sr))]`.
- **Description:** `ln in "".join(sr)` is true when a front-matter line occurs *anywhere inside* any archived record, so
  a record that quotes the line in backticks counts as the front matter having "leaked". The same script's "lost line"
  check was already changed to exact-line-set membership (BL-28) for the mirror-image reason.
- **Evidence (a patched scratch copy of each script, run with its own `zones()`):**

| Shard | Front-matter line flagged | Substring test | Exact whole-line test | Where it actually occurs |
|---|---|---|---|---|
| `HANDOFFS-through-2026-09-26` | `python3 methodology_trim.py --file HANDOFFS.md --check` | flags 1 | flags 0 | mid-line, inside one receipt's `next_steps:` |
| `CHANGELOG-through-2026-08-10` | `## Size, and when to archive` | flags 2 | flags 0 | mid-line, inside two ledger entries ("inserted a ## Size, and when to archive section into ...") |
| (same script) | `python3 methodology_trim.py --file CHANGELOG.md --check` | | | mid-line, inside one ledger entry |

  L1 and L3 pass in both (the only `FAIL` line each prints is the L2 one).
- **Impact:** an archived record that merely mentions a command or heading can never be archived without a red proof.
- **Recommendation:** test exact lines (`ln in set(sfront.splitlines()) or ln in set(record_lines)`), as BL-28 did.

## Items audited

| Shard | Script | Failing check(s) | Finding | Lossless? |
|---|---|---|---|---|
| `HANDOFFS-through-2026-09-26-3` | v1.5.0 | L1, L3 | 1 | yes (receipt finalize; 7 = 7) |
| `SESSION_NOTES-through-2026-09-20-2` | v1.5.0 | L1, L3 | 1 | yes |
| `SESSION_NOTES-through-2026-09-21-2` | v1.5.0 | L1, L3 | 1 | yes |
| `SESSION_NOTES-through-2026-09-21` | v1.5.0 | L1, L3 | 1 | yes |
| `SESSION_NOTES-through-2026-09-26-4` | v1.5.0 | L1, L3 | 1 | yes |
| `SESSION_NOTES-through-2026-09-28-2` | v1.5.0 | L1, L3 | 1 | yes |
| `SESSION_NOTES-through-2026-09-28` | v1.5.0 | L1, L3 | 1 | yes |
| `SESSION_NOTES-through-2026-08-15` | v1.1.2 | L1, L3 | 2 | yes (0 absent, 1 added) |
| `HANDOFFS-through-2026-09-26` | v1.5.0 | L2 | 3 | yes (L1, L3 hold) |
| `CHANGELOG-through-2026-08-10` | v1.1.2 | L2 | 3 | yes (L1, L3 hold) |

"Lossless? yes" means the two sides were diffed, not that the script said so. Not done: an independent identity-keyed
re-derivation over these 10 (the script comments cite one for the earlier BL-36 audit, in the methodology repo at
`docs/audits/2026-08-15-bl36-archive-losslessness.md`); the by-hand diff above is narrower.

## Structural observations

1. **The scripts are frozen at write time, so an upstream fix does not reach them.** Each header says it embeds the
   grammar it was written against "so a later change to the trimmer cannot silently change what this shard's proof
   means". Fixing the generator therefore repairs future shards only; the 10 red scripts stay red. The trimmer has no
   option to regenerate a script (`--help`: `--file --write --cut --budget-bytes --force --check --version`).
2. **A mechanical invariant with a manual escape hatch.** "Diff record 0 by hand" is in the failure message, so each of
   the 7 pattern cases costs a person a manual diff or an ignored red line.
3. **Carried from S898, not re-checked here:** nothing in this repo runs these scripts (no CI job, test or tool); only
   the dashboard recognizes the suffix. Until fixed, do not quote front-matter command lines verbatim in receipts
   (Learning 797e); that avoids Finding 3 for new records only.

## Where it can go (the S898 ruling assumed a channel that does not exist)

Read-only checks today (nothing changed anywhere):

- `rmsharp/methodology` (the fork named in the S898 ruling) has **issues disabled** (`hasIssuesEnabled: false`), so an
  issue cannot be filed there. It is a fork of `KJ5HST/methodology`; the fork is 1,280 commits ahead and 102 behind.
- `KJ5HST/methodology` (the original) has issues **enabled**, the owner's permission there is `WRITE`, and the local clone
  `~/Development/methodology` lists `starter-kit/methodology_trim.py` on both its `origin/main` and `upstream/main`.
  Posting there is visible to that project's maintainers, so it is an owner call.
- The local clone is at `fae8ed1` with 2 unrelated modified files (`.context-budget-history.jsonl`,
  `dashboard_history.jsonl`); its trimmer is clean. It was only read.

## Is the problem still in the current methodology version? (checked S901, read-only, after the owner asked)

The first pass compared only a local clone. This check read `starter-kit/methodology_trim.py` from the current `main` of
**both** repos through the GitHub API (head commits `rmsharp/methodology` `c8215af`, 2026-10-02, and `KJ5HST/methodology`
`f34769f`, 2026-10-03):

| Test on the current file | `rmsharp/methodology` main | `KJ5HST/methodology` main |
|---|---|---|
| Version | 1.5.0 | 1.5.0 |
| Size and identity | 113,754 B | 113,754 B, **byte-identical** to the fork's |
| Finding 3: substring leak test (`ln in sfront or ln in "".join(sr)`) | present | present |
| Finding 1: `frontier_edit` prints the BL-27 note and still fails | present | present |
| Finding 2: baked-in `INJECTED=` constant in the template | absent (fixed by BL-36, v1.2.0) | absent |
| A regenerate/reverify option | none | none |

So **Findings 1 and 3 are present in the current upstream trimmer, and Finding 2 is already fixed there** (it only
affects the 18 already-written v1.1.2 scripts). The local clone's trimmer (`fae8ed1`) is also byte-identical to the
fork's `main`. Duplicate check on the parent: no issue (open or closed) matched "verify.sh", "methodology_trim",
"L2 front matter leaked" or "frontier BL-27"; the trimmer's four commits on the parent's `main` (latest 2026-09-18) are
the original ship plus documentation changes, none touching the verify template.

---

## Draft upstream report (ready to paste; NOT posted)

**Title:** Generated `.verify.sh` reports FAIL on lossless trims: 10 of 54 proofs in one adopter repo, three causes

**Environment:** `methodology_trim.py` v1.5.0 (`starter-kit/methodology_trim.py`); the failing scripts were written by v1.1.2
(18 scripts, 2 fail) and v1.5.0 (36 scripts, 8 fail). Adopter repo: `rmsharp/nprcgenekeepr` (public); run
`for s in docs/archive/*.verify.sh; do bash "$s" >/dev/null 2>&1 || echo "$s"; done` from its root.

**What we measured:** 54 shard proofs, 44 pass, 10 fail. For all 10 we diffed the records themselves and **none is a real
loss**. The failures come from three causes in the generated script.

**1. A close-out commit that also trims always fails L1 and L3 (7 scripts, v1.5.0).** The commit that archives a ledger
also finalizes the session's own newest record (a `status: pending` receipt becomes `complete`; a claim stub becomes the
full record). `frontier_edit` recognizes this, prints "matches a known, accepted pattern (BL-27) ... manually diff record 0
by hand", and exits 1. We did the diff for all 7: record 0 differs only by the finalize, every other record is
byte-identical, and the receipt count is unchanged (7 before, 7 after). 7 of the 38 SESSION_NOTES and HANDOFFS proofs here
end red this way. *Suggestion:* when `frontier_edit` holds, print the unified diff of
record 0 and use a distinct exit status (or an `OK` line with the note) so a caller can tell "record 0 finalized, the rest
proven identical" from a loss. A loss, an edit to any other record, or a reorder would still fail.

**2. L2 "leak" is a substring test (2 scripts).** `leaked = [ln for ln in bfront.splitlines() if ... (ln in sfront or ln in
"".join(sr))]` is true when a front-matter line occurs anywhere inside an archived record. An archived entry that quotes
`` `## Size, and when to archive` `` or `` `python3 methodology_trim.py --file CHANGELOG.md --check` `` in backticks mid-line
therefore "leaks". On the two failing shards the substring test flags 1 and 2 lines; an exact whole-line test flags 0. The
same script already moved the "lost line" check to exact-line-set membership (BL-28) for the mirror-image reason.
*Suggestion:* use exact whole-line membership for `leaked` too.

**3. Frozen scripts are not repaired by generator fixes (1 script, v1.1.2).** The v1.1.2 template bakes in `INJECTED`
(here `INJECTED=0`); the trim commit also added a `Session N Handoff Evaluation` record, so L3 says `record count 79 != 78`
although 0 records are absent and 1 was added. BL-36 (v1.2.0) already replaced the constant with a measured set, but the
generated scripts are frozen, so this one can never benefit. *Suggestion:* a regenerate mode (for example `--reverify
<shard>`) that rewrites a shard's `.verify.sh` from the current template while keeping the shard's record grammar, or a
documented rule that a proof-semantics change (a MINOR bump) is followed by regenerating existing scripts.

Happy to share the per-shard evidence (before/after record sizes, the patched-script output) on request.
