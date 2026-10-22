# The ten red shard proofs, re-derived with `--reverify` (S1033, 2026-10-22)

> **Status:** measurement DONE; nothing was changed in `methodology/`, nothing was posted anywhere. It follows
> `docs/audits/SHARD_VERIFY_SCRIPT_FAILURES_2026-10-04.md` (S901), which characterized the same ten.

## Summary

- **The same ten scripts are red; none of them is a loss.** Today there are 60 `*.md.verify.sh` files in
  `methodology/archive/`; 50 exit 0 and 10 exit 1. The ten are the ones S901 listed (CHANGELOG 1, HANDOFFS 2,
  SESSION_NOTES 7).
- **Under today's logic (`methodology_trim.py` v1.8.1, read-only `--reverify`) 2 of the ten hold, 1 is named a
  "stub finalize" (exit 4, still a FAIL by upstream's design) and 7 still fail with exit 1.** All 47 old-path shards that
  passed before still pass, so the new check turns nothing green into red.
- **The 7 SESSION_NOTES failures are the same shape as the one HANDOFFS shard that is named.** Record 0 was this
  project's own claim stub, and the trim commit finalized it in the same commit. The tool names that shape only when the
  ledger's spec declares a stub marker; this project's local `SESSION_NOTES.md` spec declares none. With a one-line
  marker (tried in a scratch clone only) all 7 become exit 4, "the other N records are byte-identical, in order,
  and L2 holds".
- **`--reverify` cannot run in place on 57 of the 60 shards.** Their frozen proofs name `docs/archive/<shard>`;
  the shards moved to `methodology/archive/` in `0e2663642` (2026-10-11), and the tool refuses a shard whose path
  differs from the path its proof names (`REVERIFY_SHARD_MISMATCH`, exit 3). Only the three shards written since the
  move (HANDOFFS 2026-10-14, HANDOFFS 2026-10-21, CHANGELOG 2026-10-14) re-derive in place; all three exit 0.
- **`--reverify` writes nothing, so the ten files on disk stay red.** There is still no regenerate path upstream, and for
  the eight stub-finalize shards a regenerated proof would exit 4, which is red too.
- **Nothing here runs these scripts.** `git grep` over `tests/`, `.github/`, `R/`, `bin/` and the gate manifests finds
  only tests that check each shard has a `.verify.sh` file beside it (`tests/testthat/test_archivePointersResolve.R`).

## The ten

"Frozen" is the `.verify.sh` as written on disk. "`--reverify`" is the v1.8.1 trimmer re-deriving the proof from the
grammar lifted out of the frozen script (see "How it was run"). "+ marker" is the same call in the scratch clone after
adding one line to the local `SESSION_NOTES.md` spec (see "The marker test").

| Shard (`methodology/archive/…-through-…`) | Written by | S901 cause | Frozen | `--reverify` | + marker |
|---|---|---|---|---|---|
| `CHANGELOG-through-2026-08-10` | v1.1.2 | 3, substring leak test | exit 1 | **exit 0, holds** | |
| `HANDOFFS-through-2026-09-26` | v1.5.0 | 3, substring leak test | exit 1 | **exit 0, holds** | |
| `HANDOFFS-through-2026-09-26-3` | v1.5.0 | 1, claim stub finalized | exit 1 | **exit 4**, stub 606 B, other 5 records identical | |
| `SESSION_NOTES-through-2026-08-15` | v1.1.2 | 2, baked-in count | exit 1 | exit 1, record 0 `What Session 594 Did` | exit 4, stub 1,960 B, other 77 identical |
| `SESSION_NOTES-through-2026-09-20-2` | v1.5.0 | 1 | exit 1 | exit 1, record 0 `What Session 745 Did` | exit 4, stub 815 B, other 14 identical |
| `SESSION_NOTES-through-2026-09-21-2` | v1.5.0 | 1 | exit 1 | exit 1, record 0 `What Session 758 Did` | exit 4, stub 438 B, other 13 identical |
| `SESSION_NOTES-through-2026-09-21` | v1.5.0 | 1 | exit 1 | exit 1, record 0 `What Session 752 Did` | exit 4, stub 557 B, other 15 identical |
| `SESSION_NOTES-through-2026-09-26-4` | v1.5.0 | 1 | exit 1 | exit 1, record 0 `What Session 791 Did` | exit 4, stub 536 B, other 6 identical |
| `SESSION_NOTES-through-2026-09-28-2` | v1.5.0 | 1 | exit 1 | exit 1, record 0 `What Session 806 Did` | exit 4, stub 565 B, other 12 identical |
| `SESSION_NOTES-through-2026-09-28` | v1.5.0 | 1 | exit 1 | exit 1, record 0 `What Session 801 Did` | exit 4, stub 592 B, other 15 identical |

Two readings the table supports:

- **Cause 3 is gone from the current template.** The two shards that hold were red only because the old leak test is a
  substring test (`ln in "".join(sr)`); the proofs the current trimmer writes test whole lines (`ln in sr_lines`, a set
  membership; see `methodology/archive/HANDOFFS-through-2026-10-21.md.verify.sh:304-307` against
  `HANDOFFS-through-2026-09-26.md.verify.sh:291-292`). So the S901 advice not to quote front-matter command lines in
  receipts is no longer needed for shards the current trimmer writes.
- **S901 named one cause for the 2026-08-15 shard (a baked-in record count), and the re-derivation finds a second.**
  Its trim commit also finalized record 0, the claim stub for Session 594 (1,960 B). The count problem is gone under the
  current template; the stub finalize is what remains. This matches the comment on upstream issue #93 (2026-10-05) that
  the v1.1.2 shard "still fails for cause 1's reason once regenerated".

## How it was run

The proofs were run first as they stand, then re-derived. Both are read-only on this repository.

1. **Frozen proofs, as written:** `bash methodology/archive/<shard>.md.verify.sh` for all 60. They read
   `git show <trim commit>^:<live path>`, `<trim commit>:<live path>` and `<trim commit>:<shard path>` from history
   at the paths of their day, so they judge the trim commit as committed, not today's file.
2. **`--reverify` in place:** `python3 methodology/methodology_trim.py --reverify methodology/archive/<shard>.md`.
   57 answer `REVERIFY_SHARD_MISMATCH` (exit 3): `<shard>.md.verify.sh names the shard docs/archive/<shard>.md, not
   methodology/archive/<shard>.md`. The 3 newest re-derive and exit 0.
3. **`--reverify` at the old path, in a scratch clone:**
   ```
   git clone -q <this repo> <scratch>/clone && cd <scratch>/clone
   mkdir -p docs/archive
   cp methodology/archive/*-through-*.md methodology/archive/*.verify.sh docs/archive/
   python3 methodology/methodology_trim.py --reverify docs/archive/<shard>.md
   ```
   The re-derivation finds the trim commit with `git log --diff-filter=A -- docs/archive/<shard>.md`, so it needs
   only a file at that path, not a move of history. Result for the 57 shards whose proofs name `docs/archive/`:
   49 exit 0 (the 47 that already passed plus the 2 above), 1 exit 4, 7 exit 1. The 3 shards whose proofs name
   `methodology/archive/` answer exit 3 in the clone (their copies sit at the wrong path there); in place they exit 0.

`--reverify` states its own limit in its banner: it is "a claim about today's logic against this shard, NOT the artifact
that was shipped; the frozen proof is untouched. Nothing was written."

## The marker test

In the scratch clone only, the `"SESSION_NOTES.md"` entry of `LEDGERS` in `methodology/methodology_trim.py` was given
`stub_marker=re.compile(r"^\*\*Status:\*\* Session claimed", re.M)`, the line every claim stub carries. The seven
SESSION_NOTES shards then exit 4 with `record 0 was a pending stub (N B) and was finalized in the trim commit; the other M
record(s) are byte-identical across the move, in order, and L2 holds` (the N and M are in the table). Exit 4 is still a
FAIL: upstream keeps it red on purpose, "because a real loss can have this exact shape too", so the marker names the shape and does not
turn the files green. The edit exists only in the scratch clone; `methodology/methodology_trim.py` here is unchanged (it
is the synced v1.8.1 plus the project's `SESSION_NOTES.md` spec from `e90a9b997`).

## What this does not show

- It does not prove the finalized record 0 is *right*; the proof certifies only that nothing but record 0 changed and
  that record 0 was a stub. S901's by-hand diff of record 0 for its seven Finding 1 shards stands as that check; record 0
  of the 2026-08-15 shard (Session 594) has not been diffed by hand.
- The stub sizes in the table are the re-derivation's; S901 counted some by lines and bytes slightly differently
  (for example 807 B against 815 B for Session 745).
- It says nothing about upstream's decision on exit 4 (BL-27); that is upstream's.

## Choices (not decided here)

- **A. Leave the ten as they are and drop the backlog item.** They are documented false alarms and nothing runs them.
- **B. Add the one-line stub marker to the local `SESSION_NOTES.md` spec**, so a re-check names all ten shapes. A second
  local change to a synced file (the first is `e90a9b997`), lost at the next sync unless re-applied.
- **C. Tell upstream that `--reverify` refuses a shard a project moved** (57 of 60 here), and that a project-local
  ledger spec has no way to declare a stub marker. Nothing is drafted or posted; where to post is the owner's call.

Recommended: A. It is the only choice that needs no change to a synced file and no outside contact; B and C buy a
clearer message from a check nobody runs.
