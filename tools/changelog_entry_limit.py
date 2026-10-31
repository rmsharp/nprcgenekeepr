"""Count methodology/CHANGELOG.md entries over the 1,000-byte limit (owner ruling, S1107).

Run by the quality gate changelog_entries_over_limit, which reads the "entries over the
limit: N" line. Entries from the S1107 claim upward are covered; older ones stay as written.
Once a trim has archived that claim, every entry left in the file is newer, so all are covered.
With nothing to measure no count is printed, so the gate reads UNMEASURED, never a pass.
"""
import os
import re
import sys

LIMIT_BYTES = 1000
FIRST_COVERED = "S1107 claim (in progress)"
DEFAULT_LEDGER = os.path.join(
    os.path.dirname(os.path.abspath(__file__)), "..", "methodology", "CHANGELOG.md"
)
ENTRY_START = re.compile(r"(?m)^(?=### \d{4}-\d{2}-\d{2})")
NOTHING_TO_MEASURE = 3


def covered_entries(text):
    """The entries the limit applies to, newest first, without their trailing blank lines."""
    entries = [e.rstrip() for e in ENTRY_START.split(text)[1:]]
    headings = [e.split("\n", 1)[0] for e in entries]
    marked = [i for i, heading in enumerate(headings) if FIRST_COVERED in heading]
    return entries[: marked[-1] + 1] if marked else entries


def main(argv):
    path = argv[1] if len(argv) > 1 else DEFAULT_LEDGER
    try:
        with open(path, encoding="utf-8") as ledger:
            entries = covered_entries(ledger.read())
    except OSError as problem:
        print(f"cannot read the ledger: {problem}")
        return NOTHING_TO_MEASURE
    if not entries:
        print(f"no dated entries in {path}")
        return NOTHING_TO_MEASURE
    over = [e for e in entries if len(e.encode("utf-8")) > LIMIT_BYTES]
    print(f"entries over the limit: {len(over)} (limit {LIMIT_BYTES} B, {len(entries)} covered)")
    for e in over:
        print(f"  {len(e.encode('utf-8'))} B: {e.split(chr(10), 1)[0][:100]}")
    return 1 if over else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
