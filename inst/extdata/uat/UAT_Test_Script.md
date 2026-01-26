# nprcgenekeepr User Acceptance Testing (UAT) Script

**Version:** Module Branch
**Date:** 2025-01-25
**Tester:** ___________________
**Test Environment:** ___________________

---

## Prerequisites

Before beginning UAT:

1. Install the module branch version:
   ```r
   devtools::install_github("rmsharp/nprcgenekeepr@module")
   ```

2. Prepare test data files (located in `inst/extdata/`):
   - `ExamplePedigree.csv` - Large standard pedigree file (clean)
   - `pedOne.csv` - Small pedigree with non-standard column names (triggers QC)
   - `2022-05-02_Deidentified_Pedigree.xlsx` - Excel pedigree file
   - `focalAnimals.csv` - Focal animals list

3. Launch the modular application:
   ```r
   library(nprcgenekeepr)
   runModularApp()
   ```
   Or for the original version: `runGeneKeepR()`

---

## Test Recording Instructions

For each test case:
- Mark **PASS** if behavior matches expected result
- Mark **FAIL** if behavior differs from expected result
- Mark **SKIP** if test cannot be performed (note reason)
- Record any observations in the Notes column

---

## Section 1: Home Tab and Navigation (NEW FEATURE)

| ID | Test Case | Steps | Expected Result | Status | Notes |
|----|-----------|-------|-----------------|--------|-------|
| 1.1 | Home tab displays on launch | Launch app | Home tab is visible and selected by default | [x] PASS [ ] FAIL | |
| 1.2 | Welcome message present | View Home tab | Welcome message with application name and version displayed | [x] PASS [ ] FAIL | |
| 1.3 | Data Input navigation button | Click "Data Input" button on Home tab | Navigates to Input tab | [x] PASS [ ] FAIL | |
| 1.4 | Pedigree Browser navigation button | Click "Pedigree Browser" button on Home tab | Navigates to Pedigree tab | [x] PASS [ ] FAIL | |
| 1.5 | Age-Sex Pyramid navigation button | Click "Go to Pyramid" button on Home tab | Navigates to Age-Sex Pyramid tab | [x] PASS [ ] FAIL | |
| 1.6 | Genetic Value Analysis | Click "Go to Genetic Value" button on Home tab | Navigates to Genetic Value Analysis tab | [x] PASS [ ] FAIL | |
| 1.7 | Summary Statistics navigation button | Click "Go to Summary" button on Home tab | Navigates to Summary Statistics tab | [x] PASS [ ] FAIL | |
| 1.8 | Breeding Groups navigation button | Click "Go to Breeding Groups" button on Home tab | Navigates to Breeding Groups tab | [x] PASS [ ] FAIL | |
| 1.9 | Visual design | Inspect Home tab layout | Jumbotron design with clear action panels | [x] PASS [ ] FAIL | |

---

## Section 2: Data Input Workflows

### 2.1 CSV File Input

| ID | Test Case | Steps | Expected Result | Status | Notes |
|----|-----------|-------|-----------------|--------|-------|
| 2.1.1 | Upload CSV pedigree | Select "Text File", upload ExamplePedigree.csv | File uploads successfully, data preview shown | [x] PASS [ ] FAIL | |
| 2.1.2 | Separator detection | Upload comma-separated file | Comma separator auto-detected or selectable | [x] PASS [ ] FAIL | |
| 2.1.3 | Tab-separated file | Upload TSV file | Tab separator works correctly | [x] PASS [ ] FAIL | |
| 2.1.4 | Semicolon-separated file | Upload semicolon-delimited file | Semicolon separator works correctly | [ ] PASS [ ] FAIL [x] SKIP | |

### 2.2 Excel File Input

| ID | Test Case | Steps | Expected Result | Status | Notes |
|----|-----------|-------|-----------------|--------|-------|
| 2.2.1 | Upload Excel file | Select "Excel File", upload .xlsx | File uploads and parses correctly | [x] PASS [ ] FAIL | |
| 2.2.2 | Sheet selection | Upload multi-sheet Excel | Sheet selector appears if multiple sheets | [ ] PASS [ ] FAIL [x] SKIP | |

### 2.3 File Content Types

| ID | Test Case | Steps | Expected Result | Status | Notes |
|----|-----------|-------|-----------------|--------|-------|
| 2.3.1 | Pedigree only | Select "Pedigree File Only" | Only pedigree fields expected | [ ] PASS [ ] FAIL | |
| 2.3.2 | Pedigree + Genotype combined | Select "Combined Pedigree and Genotype" | Both data types processed from single file | [ ] PASS [ ] FAIL | |
| 2.3.3 | Separate Pedigree and Genotype | Select "Separate Files" | Two file upload fields appear | [ ] PASS [ ] FAIL | |
| 2.3.4 | Focal Animals file | Select "Focal Animals" | Single column ID file accepted | [ ] PASS [ ] FAIL | |

---

## Section 3: QC Error Detection and Display (ENHANCED)

### 3.1 QC Summary Tab

| ID | Test Case | Steps | Expected Result | Status | Notes |
|----|-----------|-------|-----------------|--------|-------|
| 3.1.1 | QC Summary appears | Upload pedOne.csv (has non-standard column names) | QC Summary tab/section displays | [ ] PASS [ ] FAIL | |
| 3.1.2 | Error count displayed | View QC Summary | Total error count shown | [ ] PASS [ ] FAIL | |
| 3.1.3 | Warning count displayed | View QC Summary | Total warning count shown | [ ] PASS [ ] FAIL | |
| 3.1.4 | Clean file summary | Upload ExamplePedigree.csv | Summary shows 0 errors, 0 warnings | [ ] PASS [ ] FAIL | |

### 3.2 Dynamic Error Tab (NEW FEATURE)

| ID | Test Case | Steps | Expected Result | Status | Notes |
|----|-----------|-------|-----------------|--------|-------|
| 3.2.1 | Error tab appears when errors exist | Upload file with QC errors | "Errors" tab dynamically inserted | [x] PASS [ ] FAIL | |
| 3.2.2 | Error tab shows error details | Click Errors tab | Table listing each error with Type, ID, Description | [x] PASS [ ] FAIL | |
| 3.2.3 | Error tab hidden when no errors | Upload clean file | Errors tab not visible | [x] PASS [ ] FAIL | |
| 3.2.4 | Female sire detection | Upload file with female listed as sire | "Female Sire" error displayed | [ ] PASS [ ] FAIL | |
| 3.2.5 | Male dam detection | Upload file with male listed as dam | "Male Dam" error displayed | [ ] PASS [ ] FAIL | |
| 3.2.6 | Download errors | Click "Download Errors" button | CSV file downloads with error list | [ ] PASS [ ] FAIL | |

### 3.3 Dynamic Changed Columns Tab (NEW FEATURE)

| ID | Test Case | Steps | Expected Result | Status | Notes |
|----|-----------|-------|-----------------|--------|-------|
| 3.3.1 | Changed Cols tab appears | Upload file with non-standard column names | "Changed Columns" tab inserted | [ ] PASS [ ] FAIL | |
| 3.3.2 | Column changes listed | Click Changed Columns tab | Table showing original → standardized names | [ ] PASS [ ] FAIL | |
| 3.3.3 | Case changes detected | Upload file with "ID" instead of "id" | Case change reported | [ ] PASS [ ] FAIL | |
| 3.3.4 | Space removal detected | Upload file with "birth date" column | Space removal reported | [ ] PASS [ ] FAIL | |
| 3.3.5 | Tab hidden when no changes | Upload file with standard column names | Changed Columns tab not visible | [ ] PASS [ ] FAIL | |

### 3.4 Warnings Tab

| ID | Test Case | Steps | Expected Result | Status | Notes |
|----|-----------|-------|-----------------|--------|-------|
| 3.4.1 | Warnings displayed | Upload file with warnings | Warnings tab shows warning list | [ ] PASS [ ] FAIL | |
| 3.4.2 | Download warnings | Click "Download Warnings" | CSV file downloads with warnings | [ ] PASS [ ] FAIL | |

### 3.5 Cleaned Data Tab

| ID | Test Case | Steps | Expected Result | Status | Notes |
|----|-----------|-------|-----------------|--------|-------|
| 3.5.1 | Cleaned data displayed | After QC completes | Cleaned Data tab shows processed pedigree | [ ] PASS [ ] FAIL | |
| 3.5.2 | Download cleaned data | Click "Download Cleaned Data" | CSV file downloads with cleaned pedigree | [ ] PASS [ ] FAIL | |

---

## Section 4: Pedigree Browser (ENHANCED)

### 4.1 Basic Pedigree Display

| ID | Test Case | Steps | Expected Result | Status | Notes |
|----|-----------|-------|-----------------|--------|-------|
| 4.1.1 | Pedigree table displays | Navigate to Pedigree tab after data loaded | DataTable shows pedigree records | [ ] PASS [ ] FAIL | |
| 4.1.2 | Column sorting | Click column headers | Table sorts by clicked column | [ ] PASS [ ] FAIL | |
| 4.1.3 | Search functionality | Use search box | Table filters to matching records | [ ] PASS [ ] FAIL | |
| 4.1.4 | Pagination | Navigate pages | Pagination controls work | [ ] PASS [ ] FAIL | |

### 4.2 Focal Animal Management (ENHANCED)

| ID | Test Case | Steps | Expected Result | Status | Notes |
|----|-----------|-------|-----------------|--------|-------|
| 4.2.1 | Focal animals textarea | View Pedigree tab | Textarea for entering focal animal IDs visible | [ ] PASS [ ] FAIL | |
| 4.2.2 | Enter focal animals manually | Type IDs in textarea (one per line) | IDs accepted | [ ] PASS [ ] FAIL | |
| 4.2.3 | Upload focal animals CSV | Upload CSV with focal animal IDs | File parsed and IDs loaded | [ ] PASS [ ] FAIL | |
| 4.2.4 | Trim pedigree checkbox | Check "Trim pedigree based on focal animals" | Pedigree filtered to focal animals + ancestors | [ ] PASS [ ] FAIL | |
| 4.2.5 | Invalid focal ID handling | Enter non-existent ID | Warning or error message displayed | [ ] PASS [ ] FAIL | |

### 4.3 Display Options

| ID | Test Case | Steps | Expected Result | Status | Notes |
|----|-----------|-------|-----------------|--------|-------|
| 4.3.1 | Show/hide unknown IDs | Toggle "Display unknown IDs" checkbox | Unknown sire/dam IDs shown or hidden | [ ] PASS [ ] FAIL | |
| 4.3.2 | Population marking | View pedigree with population column | Population field auto-calculated | [ ] PASS [ ] FAIL | |
| 4.3.3 | Generation calculation | View pedigree with generation column | Generation numbers auto-calculated | [ ] PASS [ ] FAIL | |

### 4.4 Export

| ID | Test Case | Steps | Expected Result | Status | Notes |
|----|-----------|-------|-----------------|--------|-------|
| 4.4.1 | Export pedigree CSV | Click export/download button | CSV file downloads | [ ] PASS [ ] FAIL | |
| 4.4.2 | Export respects filters | Export after trimming to focal animals | Only trimmed pedigree exported | [ ] PASS [ ] FAIL | |

---

## Section 5: Genetic Value Analysis (ENHANCED)

### 5.1 Analysis Configuration

| ID | Test Case | Steps | Expected Result | Status | Notes |
|----|-----------|-------|-----------------|--------|-------|
| 5.1.1 | Gene drop iterations input | View Genetic Value tab | Numeric input for iterations (default 5000) | [ ] PASS [ ] FAIL | |
| 5.1.2 | Iteration range validation | Enter value outside 100-10000 | Input constrained to valid range | [ ] PASS [ ] FAIL | |
| 5.1.3 | Kinship analysis checkbox | Check "Calculate Kinship" | Kinship analysis included | [ ] PASS [ ] FAIL | |
| 5.1.4 | Genome uniqueness checkbox | Check "Calculate Genome Uniqueness" | GU analysis included | [ ] PASS [ ] FAIL | |

### 5.2 Rankings Tab

| ID | Test Case | Steps | Expected Result | Status | Notes |
|----|-----------|-------|-----------------|--------|-------|
| 5.2.1 | Rankings table displays | Run analysis, view Rankings tab | DataTable with ranked animals | [ ] PASS [ ] FAIL | |
| 5.2.2 | TopN control | Adjust "Show top N" control | Table updates to show N animals | [ ] PASS [ ] FAIL | |
| 5.2.3 | Download rankings | Click "Download Rankings" | CSV file with rankings downloads | [ ] PASS [ ] FAIL | |

### 5.3 Visualizations Tab (NEW FEATURE)

| ID | Test Case | Steps | Expected Result | Status | Notes |
|----|-----------|-------|-----------------|--------|-------|
| 5.3.1 | Scatter plot displays | Click Visualizations tab | Mean Kinship vs Genome Uniqueness scatter plot | [ ] PASS [ ] FAIL | |
| 5.3.2 | Ranking colors | View scatter plot | Points colored by ranking category | [ ] PASS [ ] FAIL | |
| 5.3.3 | Plot interactivity | Hover over points | Tooltip or identification appears | [ ] PASS [ ] FAIL | |

### 5.4 Founder Statistics Display (NEW FEATURE)

| ID | Test Case | Steps | Expected Result | Status | Notes |
|----|-----------|-------|-----------------|--------|-------|
| 5.4.1 | Total founders displayed | View Summary tab | Count of known founders shown | [ ] PASS [ ] FAIL | |
| 5.4.2 | Male founders count | View Summary tab | Number of male founders shown | [ ] PASS [ ] FAIL | |
| 5.4.3 | Female founders count | View Summary tab | Number of female founders shown | [ ] PASS [ ] FAIL | |
| 5.4.4 | Founder Equivalents (FE) | View Summary tab | FE value calculated and displayed | [ ] PASS [ ] FAIL | |
| 5.4.5 | Founder Genome Equivalents (FG) | View Summary tab | FG value calculated and displayed | [ ] PASS [ ] FAIL | |

---

## Section 6: Breeding Group Formation (ENHANCED)

### 6.1 Animal Source Selection

| ID | Test Case | Steps | Expected Result | Status | Notes |
|----|-----------|-------|-----------------|--------|-------|
| 6.1.1 | Top ranked source | Select "Top Ranked Animals" | Uses animals from genetic value rankings | [ ] PASS [ ] FAIL | |
| 6.1.2 | Custom list source | Select "Custom List" | Textarea appears for entering IDs | [ ] PASS [ ] FAIL | |
| 6.1.3 | All animals source | Select "All Animals" | Uses entire population | [ ] PASS [ ] FAIL | |

### 6.2 Group Parameters

| ID | Test Case | Steps | Expected Result | Status | Notes |
|----|-----------|-------|-----------------|--------|-------|
| 6.2.1 | Number of groups | Set number of groups to form | Groups created according to setting | [ ] PASS [ ] FAIL | |
| 6.2.2 | Group size limits | Set min/max group size | Groups respect size constraints | [ ] PASS [ ] FAIL | |
| 6.2.3 | Sex ratio - None | Select "None" for sex handling | Sex ignored in group formation | [ ] PASS [ ] FAIL | |
| 6.2.4 | Sex ratio - Harem | Select "Harem (1M:NF)" | One male per group with multiple females | [ ] PASS [ ] FAIL | |
| 6.2.5 | Sex ratio - Custom | Select "Custom" | Custom M:F ratio input appears | [ ] PASS [ ] FAIL | |
| 6.2.6 | Kinship threshold | Set kinship threshold (0.0-0.5) | Groups respect max kinship constraint | [ ] PASS [ ] FAIL | |
| 6.2.7 | Min parent age | Set minimum parent age | Only breeding-age animals included | [ ] PASS [ ] FAIL | |

### 6.3 Group Display (ENHANCED)

| ID | Test Case | Steps | Expected Result | Status | Notes |
|----|-----------|-------|-----------------|--------|-------|
| 6.3.1 | Multiple group panels | Form groups | Each group displayed in separate panel | [ ] PASS [ ] FAIL | |
| 6.3.2 | Group headers | View group panels | Header shows "Group #" and animal count | [ ] PASS [ ] FAIL | |
| 6.3.3 | Group members table | Expand group panel | Table listing animals in group | [ ] PASS [ ] FAIL | |
| 6.3.4 | Group kinship matrix | View group detail | Kinship matrix for group members | [ ] PASS [ ] FAIL | |
| 6.3.5 | Group statistics | View summary | M/F/Total counts per group | [ ] PASS [ ] FAIL | |
| 6.3.6 | Unassigned animals | View after grouping | List of animals not assigned to any group | [ ] PASS [ ] FAIL | |

### 6.4 Export

| ID | Test Case | Steps | Expected Result | Status | Notes |
|----|-----------|-------|-----------------|--------|-------|
| 6.4.1 | Export group assignments | Click export button | CSV with animal ID and group assignment | [ ] PASS [ ] FAIL | |

---

## Section 7: Summary Statistics and Plots (ENHANCED)

### 7.1 Summary Metrics

| ID | Test Case | Steps | Expected Result | Status | Notes |
|----|-----------|-------|-----------------|--------|-------|
| 7.1.1 | Summary statistics display | Navigate to Summary Stats tab | HTML formatted statistics table | [ ] PASS [ ] FAIL | |
| 7.1.2 | Population count | View summary | Total animals in analysis shown | [ ] PASS [ ] FAIL | |
| 7.1.3 | Mean kinship stats | View summary | Min, Q1, Mean, Median, Q3, Max for MK | [ ] PASS [ ] FAIL | |
| 7.1.4 | Genome uniqueness stats | View summary | Min, Q1, Mean, Median, Q3, Max for GU | [ ] PASS [ ] FAIL | |

### 7.2 Histograms

| ID | Test Case | Steps | Expected Result | Status | Notes |
|----|-----------|-------|-----------------|--------|-------|
| 7.2.1 | Mean kinship histogram | View histogram | Distribution of MK values displayed | [ ] PASS [ ] FAIL | |
| 7.2.2 | Z-score histogram | View histogram | Distribution of z-scores displayed | [ ] PASS [ ] FAIL | |
| 7.2.3 | Genome uniqueness histogram | View histogram | Distribution of GU values displayed | [ ] PASS [ ] FAIL | |

### 7.3 Box Plots with Popovers (NEW FEATURE)

| ID | Test Case | Steps | Expected Result | Status | Notes |
|----|-----------|-------|-----------------|--------|-------|
| 7.3.1 | Mean kinship boxplot | View boxplot | Box and whisker plot for MK | [ ] PASS [ ] FAIL | |
| 7.3.2 | Z-score boxplot | View boxplot | Box and whisker plot for z-scores | [ ] PASS [ ] FAIL | |
| 7.3.3 | Genome uniqueness boxplot | View boxplot | Box and whisker plot for GU | [ ] PASS [ ] FAIL | |
| 7.3.4 | Boxplot popover - hover | Hover over boxplot | Popover appears with description | [ ] PASS [ ] FAIL | |
| 7.3.5 | Popover content - whiskers | Read popover | Explains whisker calculation (1.5 * IQR) | [ ] PASS [ ] FAIL | |
| 7.3.6 | Popover content - IQR | Read popover | Explains inter-quartile range | [ ] PASS [ ] FAIL | |
| 7.3.7 | Popover content - outliers | Read popover | Explains outlying points | [ ] PASS [ ] FAIL | |

### 7.4 Export Buttons with Popovers (ENHANCED)

| ID | Test Case | Steps | Expected Result | Status | Notes |
|----|-----------|-------|-----------------|--------|-------|
| 7.4.1 | Export kinship matrix | Click "Export Kinship Matrix" | CSV file downloads | [ ] PASS [ ] FAIL | |
| 7.4.2 | Export male founders | Click "Export Male Founders" | CSV file downloads | [ ] PASS [ ] FAIL | |
| 7.4.3 | Export female founders | Click "Export Female Founders" | CSV file downloads | [ ] PASS [ ] FAIL | |
| 7.4.4 | Export first-order relationships | Click export button | CSV with parent-offspring, sibling pairs | [ ] PASS [ ] FAIL | |
| 7.4.5 | Export all relationships | Click "Export All Relationships" | CSV file downloads | [ ] PASS [ ] FAIL | |
| 7.4.6 | Export relationship classes (NEW) | Click "Export Relationship Classes" | CSV with relationship categories | [ ] PASS [ ] FAIL | |
| 7.4.7 | Button popovers | Hover over export buttons | Description popover appears | [ ] PASS [ ] FAIL | |

### 7.5 Plot Downloads

| ID | Test Case | Steps | Expected Result | Status | Notes |
|----|-----------|-------|-----------------|--------|-------|
| 7.5.1 | Download MK histogram | Click download for MK histogram | PNG file downloads | [ ] PASS [ ] FAIL | |
| 7.5.2 | Download MK boxplot | Click download for MK boxplot | PNG file downloads | [ ] PASS [ ] FAIL | |
| 7.5.3 | Download z-score histogram | Click download | PNG file downloads | [ ] PASS [ ] FAIL | |
| 7.5.4 | Download z-score boxplot | Click download | PNG file downloads | [ ] PASS [ ] FAIL | |
| 7.5.5 | Download GU histogram | Click download | PNG file downloads | [ ] PASS [ ] FAIL | |
| 7.5.6 | Download GU boxplot | Click download | PNG file downloads | [ ] PASS [ ] FAIL | |

---

## Section 8: Age-Sex Pyramid Plot (ENHANCED)

### 8.1 Basic Pyramid

| ID | Test Case | Steps | Expected Result | Status | Notes |
|----|-----------|-------|-----------------|--------|-------|
| 8.1.1 | Pyramid plot displays | Navigate to Pyramid tab | Age-sex pyramid visualization shown | [ ] PASS [ ] FAIL | |
| 8.1.2 | Male/Female bars | View pyramid | Males on one side, females on other | [ ] PASS [ ] FAIL | |
| 8.1.3 | Age bins | View pyramid | Animals grouped by age | [ ] PASS [ ] FAIL | |

### 8.2 Enhanced Controls (NEW FEATURES)

| ID | Test Case | Steps | Expected Result | Status | Notes |
|----|-----------|-------|-----------------|--------|-------|
| 8.2.1 | Age unit selection | Select "Years" or "Months" | Pyramid updates with selected unit | [ ] PASS [ ] FAIL | |
| 8.2.2 | Bin size control | Adjust bin size (1-10) | Pyramid rebins data accordingly | [ ] PASS [ ] FAIL | |
| 8.2.3 | Color scheme - Default | Select "Default" | Default color palette applied | [ ] PASS [ ] FAIL | |
| 8.2.4 | Color scheme - Viridis | Select "Viridis" | Viridis color palette applied | [ ] PASS [ ] FAIL | |
| 8.2.5 | Show/hide counts | Toggle "Show counts" | Count labels appear/disappear on bars | [ ] PASS [ ] FAIL | |
| 8.2.6 | Plot height slider | Adjust height (400-1500 px) | Plot resizes vertically | [ ] PASS [ ] FAIL | |
| 8.2.7 | Age label size slider | Adjust size (0.5-2.0) | Age labels resize | [ ] PASS [ ] FAIL | |

### 8.3 Statistics and Export

| ID | Test Case | Steps | Expected Result | Status | Notes |
|----|-----------|-------|-----------------|--------|-------|
| 8.3.1 | Statistics table | View statistics section | Total, Males, Females counts displayed | [ ] PASS [ ] FAIL | |
| 8.3.2 | Download pyramid PNG | Click download button | PNG file downloads with current settings | [ ] PASS [ ] FAIL | |

---

## Section 9: ORIP Reporting (ENHANCED - Previously Stub)

### 9.1 Site Information

| ID | Test Case | Steps | Expected Result | Status | Notes |
|----|-----------|-------|-----------------|--------|-------|
| 9.1.1 | ORIP tab accessible | Navigate to ORIP Reporting tab | Tab loads without error | [ ] PASS [ ] FAIL | |
| 9.1.2 | Site information table | View site info section | Center, node, user, system displayed | [ ] PASS [ ] FAIL | |
| 9.1.3 | Center name | View site info | Correct primate center name | [ ] PASS [ ] FAIL | |

### 9.2 Colony Summary (NEW FEATURE)

| ID | Test Case | Steps | Expected Result | Status | Notes |
|----|-----------|-------|-----------------|--------|-------|
| 9.2.1 | Colony summary table | View colony summary | Demographics table displayed | [ ] PASS [ ] FAIL | |
| 9.2.2 | Total colony size | View summary | Total animal count shown | [ ] PASS [ ] FAIL | |
| 9.2.3 | Age breakdown | View summary | Age categories displayed | [ ] PASS [ ] FAIL | |
| 9.2.4 | Sex breakdown | View summary | Male/Female counts shown | [ ] PASS [ ] FAIL | |

### 9.3 Genetic Diversity Metrics (NEW FEATURE)

| ID | Test Case | Steps | Expected Result | Status | Notes |
|----|-----------|-------|-----------------|--------|-------|
| 9.3.1 | Mean kinship displayed | View genetic metrics | Colony mean kinship shown | [ ] PASS [ ] FAIL | |
| 9.3.2 | Genome uniqueness displayed | View genetic metrics | Mean genome uniqueness shown | [ ] PASS [ ] FAIL | |
| 9.3.3 | Founder information | View founder section | Founder counts and statistics | [ ] PASS [ ] FAIL | |

### 9.4 Report Export (NEW FEATURE)

| ID | Test Case | Steps | Expected Result | Status | Notes |
|----|-----------|-------|-----------------|--------|-------|
| 9.4.1 | Export ORIP Report | Click "Export ORIP Report" | Report file downloads | [ ] PASS [ ] FAIL | |
| 9.4.2 | Export Demographics | Click "Export Demographics" | Demographics CSV downloads | [ ] PASS [ ] FAIL | |

---

## Section 10: Error Handling and Logging (NEW FEATURE)

### 10.1 Error Recovery

| ID | Test Case | Steps | Expected Result | Status | Notes |
|----|-----------|-------|-----------------|--------|-------|
| 10.1.1 | Invalid file upload | Upload non-data file (e.g., image) | Graceful error message, app continues | [ ] PASS [ ] FAIL | |
| 10.1.2 | Malformed CSV | Upload CSV with inconsistent columns | Error displayed, no crash | [ ] PASS [ ] FAIL | |
| 10.1.3 | Empty file | Upload empty file | Appropriate error message | [ ] PASS [ ] FAIL | |
| 10.1.4 | Missing required columns | Upload pedigree missing ID column | Clear error about missing column | [ ] PASS [ ] FAIL | |

### 10.2 Logging (Developer Verification)

| ID | Test Case | Steps | Expected Result | Status | Notes |
|----|-----------|-------|-----------------|--------|-------|
| 10.2.1 | Console logging | Open R console, perform actions | Log messages appear with timestamps | [ ] PASS [ ] FAIL | |
| 10.2.2 | Error logging | Trigger error condition | Error logged with [ERROR] prefix | [ ] PASS [ ] FAIL | |
| 10.2.3 | Warning logging | Trigger warning condition | Warning logged with [WARN] prefix | [ ] PASS [ ] FAIL | |

---

## Section 11: Cross-Feature Integration

### 11.1 Data Flow

| ID | Test Case | Steps | Expected Result | Status | Notes |
|----|-----------|-------|-----------------|--------|-------|
| 11.1.1 | Input to Pedigree | Upload data, go to Pedigree tab | Data appears in pedigree browser | [ ] PASS [ ] FAIL | |
| 11.1.2 | Pedigree to Genetic Value | Process pedigree, run genetic analysis | Analysis uses processed pedigree | [ ] PASS [ ] FAIL | |
| 11.1.3 | Genetic Value to Breeding Groups | Get rankings, form groups | Top-ranked animals available for grouping | [ ] PASS [ ] FAIL | |
| 11.1.4 | All tabs to Summary Stats | Complete analysis | Summary reflects all calculations | [ ] PASS [ ] FAIL | |

### 11.2 State Persistence

| ID | Test Case | Steps | Expected Result | Status | Notes |
|----|-----------|-------|-----------------|--------|-------|
| 11.2.1 | Tab switching preserves data | Switch between tabs | Data and settings preserved | [ ] PASS [ ] FAIL | |
| 11.2.2 | Re-upload replaces data | Upload new file | Old data replaced, analysis reset | [ ] PASS [ ] FAIL | |

---

## Section 12: Performance

| ID | Test Case | Steps | Expected Result | Status | Notes |
|----|-----------|-------|-----------------|--------|-------|
| 12.1 | Large file handling | Upload pedigree with 5000+ animals | App remains responsive | [ ] PASS [ ] FAIL | |
| 12.2 | Gene drop performance | Run 10000 iterations | Completes in reasonable time with progress | [ ] PASS [ ] FAIL | |
| 12.3 | UI responsiveness | Interact during calculations | UI remains responsive, shows progress | [ ] PASS [ ] FAIL | |

---

## Test Summary

| Section | Total Tests | Passed | Failed | Skipped |
|---------|-------------|--------|--------|---------|
| 1. Home Tab (NEW) | 6 | | | |
| 2. Data Input | 10 | | | |
| 3. QC Detection (ENHANCED) | 15 | | | |
| 4. Pedigree Browser (ENHANCED) | 12 | | | |
| 5. Genetic Value (ENHANCED) | 12 | | | |
| 6. Breeding Groups (ENHANCED) | 14 | | | |
| 7. Summary Stats (ENHANCED) | 21 | | | |
| 8. Pyramid Plot (ENHANCED) | 12 | | | |
| 9. ORIP Reporting (NEW) | 11 | | | |
| 10. Error Handling (NEW) | 6 | | | |
| 11. Integration | 6 | | | |
| 12. Performance | 3 | | | |
| **TOTAL** | **128** | | | |

---

## Sign-Off

**Testing completed by:** ___________________
**Date:** ___________________
**Overall Result:** [ ] PASS [ ] FAIL

**Critical Issues Found:**
1. ___________________
2. ___________________
3. ___________________

**Recommendations:**
1. ___________________
2. ___________________
3. ___________________

**Tester Signature:** ___________________
