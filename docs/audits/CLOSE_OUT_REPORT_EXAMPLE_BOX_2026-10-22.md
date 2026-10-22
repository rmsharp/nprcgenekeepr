# `close_out_report.py` v1.2.0 refuses on every ledger that has the seed's example box: finding and draft upstream report (S1032, 2026-10-22)

> **Status:** measured and a candidate fix tested; the upstream report is a **draft and has not been posted anywhere.** Where to
> post it is an owner decision (the fork `rmsharp/methodology` has issues disabled, so S901's report went to `KJ5HST/methodology`).

## Summary

- **What was run:** `starter-kit/close_out_report.py` (v1.2.0, methodology checkout `515b3a7e`, new file in the sync) against this
  project's `methodology/HANDOFFS.md`, in print mode and in `--check` mode.
- **Result:** both stop with `refused: newest receipt (S<N>) is <pending | complete>, not complete: write the close-out receipt first`.
  The "newest receipt" it found is the placeholder in the file's front matter, not a session's receipt.
- **Consequence:** the runner text it ships with (`starter-kit/SESSION_RUNNER.md` §3G, commit `8f63492b`) tells every session to run
  the script and print its output as the last message. On a ledger with the example box that command can never succeed, and the
  `--hook` mode ("every uncertainty resolves to allow") would stay silent for the same reason.
- **Decision taken here:** the owner chose to hold back `SESSION_RUNNER.md`, `SAFEGUARDS.md` and `close_out_report.py` at the S1032
  sync and copy the other 7 files. `bin/status` lists those three as behind until the script is fixed.

## Cause

`parse_receipts()` (`close_out_report.py:76`) matches `^```handoff\n(.*?)^```$` over the whole file, and `live_facts()` (`:123`, the refusal at
`:132-133`) uses the first match as "the newest receipt". The front matter of every `HANDOFFS.md` seeded from `starter-kit/HANDOFFS.md` holds an
example inside a four-backtick fence; the three-backtick `handoff` block inside it matches the pattern and comes first in the file.

| Ledger | Blocks found | First block |
|---|---|---|
| `starter-kit/HANDOFFS.md` (the seed) | 1 | `S<N>`, `<pending \| complete>` |
| `nprcgenekeepr/methodology/HANDOFFS.md` | 5 | `S<N>`, `<pending \| complete>` |
| the methodology repo's own `HANDOFFS.md` | 6 | `S362`, `complete` (no four-backtick box in that file) |

The third row is why it was not seen where the script was written. **Inference, not checked:** `bin/tests.sh:295` runs
`tools/test_close_out_report.py`, and the script's docstring says its property test feeds it every archived receipt; I did not read that
test, but a test fed from the methodology repo's own ledger would never meet the box.

## Tested fix

A scratch copy of the script with the box removed before matching (the change is 4 lines):

```python
_BOX = re.compile(r"^````.*?^````$", re.S | re.M)   # the example box in a HANDOFFS.md front matter

def parse_receipts(text):
    text = _BOX.sub("", text)
    ...
```

| Ledger | Original | With the fix |
|---|---|---|
| the seed | 1 block, `S<N>` | 0 blocks |
| this project's | 5 blocks, `S<N>` | 4 blocks, newest `S1032` (pending) |
| the methodology repo's own | 6 blocks, `S362` | 6 blocks, `S362` (unchanged) |

With the fix, print mode on a copy of this project's ledger whose newest receipt is complete prints a 632-byte report (heading, five
labelled lines, `Session over.`). Not tested: the `--hook` mode, and a test for the seed (it should assert that the seed yields no
receipt, and that a seed with one receipt added above the box yields that one).

## Where it can go

Same options as S901's report: an issue on `KJ5HST/methodology` (as #93 was), or a note carried to the fork's own backlog. Posting
publishes the text, so it waits for the owner's word.
