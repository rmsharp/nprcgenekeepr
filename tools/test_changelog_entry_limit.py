"""Tests for tools/changelog_entry_limit.py. Run: python3 tools/test_changelog_entry_limit.py

These live in tools/, beside the script, because the script is project tooling
outside the package build (.Rbuildignore: ^tools$).
"""
import os
import re
import subprocess
import sys
import tempfile
import unittest

HERE = os.path.dirname(os.path.abspath(__file__))
SCRIPT = os.path.join(HERE, "changelog_entry_limit.py")
MARKER_HEADING = "### 2026-10-31 · [ad hoc] S1107 claim (in progress): the first entry the limit covers"
FRONT_MATTER = "# Changelog\n\nFront matter that is no entry.\n\n"


def entry(size, heading="### 2026-11-01 · [ad hoc] S2000 DONE: something", fill="x"):
    """One entry of exactly `size` bytes of text, followed by the usual blank line."""
    padding = size - len(heading.encode("utf-8")) - 1
    return heading + "\n" + fill * padding + "\n\n"


def run_script(*args, cwd=None):
    proc = subprocess.run(
        [sys.executable, SCRIPT, *args],
        capture_output=True,
        text=True,
        cwd=cwd,
    )
    return proc.returncode, proc.stdout + proc.stderr


def over_count(output):
    """The number the quality gate's `extract` reads, or None when no count is reported."""
    match = re.search(r"entries over the limit: (\d+)", output)
    return int(match.group(1)) if match else None


class LedgerCase(unittest.TestCase):
    def check(self, text):
        with tempfile.TemporaryDirectory() as folder:
            path = os.path.join(folder, "CHANGELOG.md")
            with open(path, "w", encoding="utf-8") as ledger:
                ledger.write(text)
            return run_script(path)


class TestLimit(LedgerCase):
    def test_exactly_at_the_limit_passes(self):
        code, output = self.check(FRONT_MATTER + entry(1000) + entry(100, MARKER_HEADING))
        self.assertEqual(over_count(output), 0)
        self.assertEqual(code, 0)

    def test_one_byte_over_fails_and_names_the_entry(self):
        code, output = self.check(FRONT_MATTER + entry(1001) + entry(100, MARKER_HEADING))
        self.assertEqual(over_count(output), 1)
        self.assertEqual(code, 1)
        self.assertIn("S2000 DONE", output)
        self.assertIn("1001", output)

    def test_size_is_bytes_not_characters(self):
        # 600 two-byte characters: 600 characters long but over 1,200 bytes.
        code, output = self.check(
            FRONT_MATTER + entry(1300).replace("x" * 1200, "·" * 600)
            + entry(100, MARKER_HEADING)
        )
        self.assertEqual(over_count(output), 1)
        self.assertEqual(code, 1)

    def test_every_entry_over_the_limit_is_counted(self):
        code, output = self.check(
            FRONT_MATTER
            + entry(2000, "### 2026-11-02 · [ad hoc] S2001 DONE: one")
            + entry(100, "### 2026-11-02 · [ad hoc] S2001 claim: short")
            + entry(3000, "### 2026-11-01 · [ad hoc] S2000 DONE: two")
            + entry(100, MARKER_HEADING)
        )
        self.assertEqual(over_count(output), 2)
        self.assertIn("S2001 DONE", output)
        self.assertIn("S2000 DONE", output)
        self.assertNotIn("S2001 claim", output)


class TestWhichEntriesAreCovered(LedgerCase):
    def test_entries_older_than_the_marker_are_ignored(self):
        code, output = self.check(
            FRONT_MATTER + entry(100) + entry(100, MARKER_HEADING)
            + entry(5000, "### 2026-10-30 · [ad hoc] S1099 DONE: older and long")
        )
        self.assertEqual(over_count(output), 0)
        self.assertEqual(code, 0)

    def test_the_marker_entry_itself_is_covered(self):
        code, output = self.check(FRONT_MATTER + entry(1001, MARKER_HEADING))
        self.assertEqual(over_count(output), 1)
        self.assertEqual(code, 1)

    def test_all_entries_are_covered_once_a_trim_archived_the_marker(self):
        code, output = self.check(FRONT_MATTER + entry(100) + entry(5000))
        self.assertEqual(over_count(output), 1)
        self.assertEqual(code, 1)

    def test_a_newer_heading_quoting_the_marker_does_not_move_the_boundary(self):
        quoting = "### 2026-11-03 · [ad hoc] S2002 note: about the S1107 claim (in progress) line"
        code, output = self.check(
            FRONT_MATTER + entry(100, quoting)
            + entry(1001, "### 2026-11-02 · [ad hoc] S2001 DONE: covered and long")
            + entry(100, MARKER_HEADING)
        )
        self.assertEqual(over_count(output), 1)
        self.assertIn("S2001 DONE", output)

    def test_marker_text_in_an_entry_body_does_not_move_the_boundary(self):
        # An older long entry's body quotes the marker text: searching bodies would wrongly cover it.
        older = entry(5000, "### 2026-10-30 · [ad hoc] S1099 DONE: older and long").replace(
            "x" * 25, "S1107 claim (in progress)", 1
        )
        code, output = self.check(FRONT_MATTER + entry(100, MARKER_HEADING) + older)
        self.assertEqual(over_count(output), 0)
        self.assertEqual(code, 0)


class TestEntryBoundaries(LedgerCase):
    def test_front_matter_is_not_an_entry(self):
        code, output = self.check("x" * 5000 + "\n\n" + entry(100) + entry(100, MARKER_HEADING))
        self.assertEqual(over_count(output), 0)
        self.assertEqual(code, 0)

    def test_a_multi_line_entry_counts_whole(self):
        paragraphs = "### 2026-11-01 · [ad hoc] S2000 DONE: long\n\n" + ("y" * 600 + "\n\n") * 2
        code, output = self.check(FRONT_MATTER + paragraphs + entry(100, MARKER_HEADING))
        self.assertEqual(over_count(output), 1)

    def test_a_subheading_without_a_date_does_not_split_an_entry(self):
        paragraphs = (
            "### 2026-11-01 · [ad hoc] S2000 DONE: long\n"
            + "y" * 600 + "\n### not a dated heading\n" + "y" * 600 + "\n\n"
        )
        code, output = self.check(FRONT_MATTER + paragraphs + entry(100, MARKER_HEADING))
        self.assertEqual(over_count(output), 1)

    def test_blank_lines_after_an_entry_do_not_count(self):
        padded = entry(1000) + "\n\n\n\n"
        code, output = self.check(FRONT_MATTER + padded + entry(100, MARKER_HEADING))
        self.assertEqual(over_count(output), 0)

    def test_the_last_entry_in_the_file_is_measured(self):
        code, output = self.check(FRONT_MATTER + entry(1001).rstrip("\n"))
        self.assertEqual(over_count(output), 1)


class TestNothingToMeasure(LedgerCase):
    """No count may be printed here: the gate's `extract` then reads UNMEASURED, never a pass."""

    def test_a_missing_file_reports_no_count(self):
        with tempfile.TemporaryDirectory() as folder:
            code, output = run_script(os.path.join(folder, "absent.md"))
        self.assertIsNone(over_count(output))
        self.assertEqual(code, 3)

    def test_a_file_with_no_entries_reports_no_count(self):
        code, output = self.check(FRONT_MATTER)
        self.assertIsNone(over_count(output))
        self.assertEqual(code, 3)

    def test_an_empty_file_reports_no_count(self):
        code, output = self.check("")
        self.assertIsNone(over_count(output))
        self.assertEqual(code, 3)


class TestDefaultPath(unittest.TestCase):
    def test_with_no_argument_it_reads_the_project_ledger_from_any_folder(self):
        with tempfile.TemporaryDirectory() as folder:
            code, output = run_script(cwd=folder)
        self.assertIsNotNone(over_count(output), output)


if __name__ == "__main__":
    unittest.main()
