# read.csv() and read.delim() add byte 0xFF to a quoted last value in a short file with no final newline, on Linux aarch64

**Version:** R 4.6.2 (2026-10-29). **Hardware and OS:** aarch64, Linux (Ubuntu 26.04.1 and Debian forky/sid).

## Summary

On Linux aarch64, where `char` is unsigned, `read.csv()` and `read.delim()` return a wrong value when a file has no final newline, is at most 5 lines long, and ends in a quoted field.

```r
f <- tempfile()
writeChar('a,b\n1,"x"', f, eos = NULL)
charToRaw(read.csv(f)$b)
# Linux aarch64:                    [1] 78 ff
# Linux x86_64 and macOS aarch64:   [1] 78
```

In a UTF-8 locale, a quoted number stops the read:

```r
writeChar('a,b\n1,"7"', f, eos = NULL)
read.csv(f)
# Linux aarch64:  Error in type.convert.default(...): invalid multibyte string at '<ff>'
# Linux x86_64:   the column is integer 7
```

The only warning is "incomplete final line found by readTableHeader", which is also given where the value is correct.

One command reproduces it on any machine with Docker:

```sh
docker run --rm --platform linux/arm64 r-base:4.6.2 Rscript --vanilla -e 'f <- tempfile(); writeChar("a,b\n1,\"x\"", f, eos = NULL); print(charToRaw(read.csv(f)$b))'
```

The problem was found through the linux-arm64 additional check of CRAN package nprcgenekeepr. Searching Bugzilla for readtablehead, scanchar, and read.csv and read.table with arm64 and aarch64 found no earlier report.

## Cause

`readtablehead()`, `src/library/utils/src/io.c`, line 910:

```c
char c2 = (char) scanchar(true, &data);
```

After a closing quote at the end of the file, `scanchar()` returns `R_EOF` (-1). Where `char` is unsigned, `c2` becomes 255, `unscanchar()` pushes it back, and the next `scanchar()` returns it as a data byte instead of `R_EOF`.

This branch is reached only when `sep` is not empty, so `read.table()` with its default separator is not affected. `read.table()` passes only the first lines of a file through this function, so a file with 5 or more data rows after a header is not affected.

Where `char` is signed, the same line has a smaller effect: a real byte 0xFF straight after a closing quote is lost. For the bytes `a,b\n1,"x"\xff\n2,"y"\n3,"z"\n`, column `b` of row 1 reads `78` on Linux x86_64 and macOS aarch64, and `78 ff` on Linux aarch64.

## Patch

```diff
--- a/src/library/utils/src/io.c
+++ b/src/library/utils/src/io.c
@@ -907,7 +907,7 @@
 		    if(data.sepchar == 0)
 			quote = 0;
 		    else { /* need to check for doubled quote */
-			char c2 = (char) scanchar(true, &data);
+			int c2 = scanchar(true, &data);
 			if(c2 == quote)
 			    buf[nbuf++] = (char) c; /* and c = c2 */
 			else {
```

## Testing

R 4.6.2 was built from the CRAN tarball, without recommended packages, on Ubuntu 26.04 aarch64 (GCC 15.2.0) and on Ubuntu 24.04 x86_64 under Docker emulation (GCC 13.3.0). Each build was run unchanged, then with only this patch and `utils` rebuilt.

Bytes of the last value, no final newline unless stated:

| Case | aarch64 unchanged | aarch64 patched | x86_64 unchanged | x86_64 patched |
|---|---|---|---|---|
| `read.csv()`, `"x"` | **78 ff** | 78 | 78 | 78 |
| `read.delim()`, `"x"` | **78 ff** | 78 | 78 | 78 |
| `read.csv2()`, `"x"` | **78 ff** | 78 | 78 | 78 |
| `read.csv()`, doubled quote `"x""y"` | **78 22 79 ff** | 78 22 79 | 78 22 79 | 78 22 79 |
| `read.csv()`, empty `""` | **ff** | (empty) | (empty) | (empty) |
| `read.csv()`, embedded newline in `"x` `y"` | **78 0a 79 ff** | 78 0a 79 | 78 0a 79 | 78 0a 79 |
| `read.csv()`, `"7"` | **error** | integer 7 | integer 7 | integer 7 |
| `read.csv()`, `"x"`, 4 data rows | **78 ff** | 78 | 78 | 78 |
| `read.csv()`, `"x"`, 5 data rows | 78 | 78 | 78 | 78 |
| `read.csv()`, `"x"`, final newline | 78 | 78 | 78 | 78 |
| `read.table()`, default `sep`, `"x"` | 78 | 78 | 78 | 78 |
| 0xFF after a closing quote, first of 3 rows | 78 ff | 78 ff | **78** | 78 ff |

`make check` passes with the patch on both builds. `io.c` is identical in the R-4-6-2 tag and in trunk as of 2026-10-31, so trunk has the same line, but the patch was not run on an R-devel build.
