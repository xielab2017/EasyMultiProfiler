# EasyMultiProfiler Output Management Utilities

This document describes utility functions for automatic folder creation and output saving in EasyMultiProfiler workflows.

## Overview

The `EMP_output_utils.R` script provides functions to:
- Create standardized folder structures for organizing results
- Automatically save plots (both static and interactive HTML)
- Automatically save analysis results as CSV/TSV/RDS files
- Integrate seamlessly into EasyMultiProfiler pipelines

## Quick Start

```r
# Load the utility functions
source('EMP_output_utils.R')

# Create output folders
output_dir <- EMP_create_folders()

# Use in your pipeline
MAE |>
  EMP_assay_extract() |>
  EMP_alpha_analysis() |>
  EMP_boxplot(estimate_group = 'Group') |>
  EMP_autosave(name = "alpha_diversity", base_dir = output_dir)
```

---

## Function Reference

### 1. `EMP_create_folders()`

Creates a standardized folder structure for organizing analysis outputs.

**Parameters:**
- `base_dir`: Base directory path (default: `"EMP_Results"`)
- `subfolders`: Vector of subfolder names (default: `c("data", "figures", "figures_html", "reports")`)
- `timestamp`: Add timestamp to folder name (default: `TRUE`)

**Returns:** Path to the created base directory

**Example:**
```r
# Create default folder structure with timestamp
output_dir <- EMP_create_folders()
# Creates: EMP_Results_20250428_143022/
#          ├── data/
#          ├── figures/
#          ├── figures_html/
#          └── reports/

# Create custom folder structure without timestamp
output_dir <- EMP_create_folders(
  base_dir = "MyAnalysis",
  subfolders = c("tables", "plots", "raw_data"),
  timestamp = FALSE
)
```

---

### 2. `EMP_save_plot()`

Saves plots from EMPT or EMP objects to file.

**Parameters:**
- `obj`: EMPT or EMP object containing plots
- `output_dir`: Output directory path (default: `"."`)
- `prefix`: Prefix for output filename (default: `"plot"`)
- `info`: Plot info name (e.g., `"EMP_assay_boxplot"`). If NULL, uses current info
- `plot_type`: Type to save: `"pic"` (static), `"html"` (interactive), or `"both"` (default: `"both"`)
- `width`: Plot width in inches (default: `8`)
- `height`: Plot height in inches (default: `6`)
- `dpi`: Resolution for static plots (default: `300`)
- `format`: Static plot format: `"pdf"`, `"png"`, `"svg"` (default: `"pdf"`)

**Returns:** The original object (for piping)

**Example:**
```r
# Save both static PDF and interactive HTML
result <- MAE |>
  EMP_assay_extract() |>
  EMP_alpha_analysis() |>
  EMP_boxplot(estimate_group = 'Group') |>
  EMP_save_plot(
    output_dir = "figures",
    prefix = "alpha_boxplot",
    plot_type = "both",
    format = "pdf"
  )

# Save only PNG at high resolution
result |>
  EMP_save_plot(
    output_dir = "figures",
    prefix = "alpha_boxplot_hires",
    plot_type = "pic",
    format = "png",
    width = 10,
    height = 8,
    dpi = 600
  )
```

---

### 3. `EMP_save_data()`

Saves analysis results from EMPT or EMP objects to file.

**Parameters:**
- `obj`: EMPT or EMP object containing results
- `output_dir`: Output directory path (default: `"."`)
- `prefix`: Prefix for output filename (default: `"data"`)
- `info`: Result info name. If NULL, uses current info
- `format`: Save format: `"csv"`, `"tsv"`, `"rds"`, or `"all"` (default: `"csv"`)
- `save_raw`: Also save the raw object as RDS (default: `FALSE`)

**Returns:** The original object (for piping)

**Example:**
```r
# Save results as CSV
result <- MAE |>
  EMP_assay_extract() |>
  EMP_diff_analysis(method = 'wilcox.test', estimate_group = 'Group') |>
  EMP_save_data(
    output_dir = "data",
    prefix = "diff_analysis_wilcox",
    format = "csv"
  )

# Save in all formats including raw object
result |>
  EMP_save_data(
    output_dir = "data",
    prefix = "diff_analysis_complete",
    format = "all",
    save_raw = TRUE
  )
```

---

### 4. `EMP_save_all()`

Convenience function to save both plots and data in one call.

**Parameters:**
- `obj`: EMPT or EMP object
- `output_dir`: Output directory path (default: `"."`)
- `prefix`: Prefix for output filenames (default: `"result"`)
- `save_plot`: Whether to save plots (default: `TRUE`)
- `save_data`: Whether to save data (default: `TRUE`)
- `...`: Additional arguments passed to `EMP_save_plot()` and `EMP_save_data()`

**Returns:** The original object (for piping)

**Example:**
```r
# Save both data and plots with organized folder structure
result <- MAE |>
  EMP_assay_extract() |>
  EMP_alpha_analysis() |>
  EMP_boxplot(estimate_group = 'Group') |>
  EMP_save_all(
    output_dir = "results",
    prefix = "alpha_diversity"
  )
# Creates:
#   results/data/alpha_diversity.csv
#   results/figures/alpha_diversity_static.pdf
#   results/figures_html/alpha_diversity.html
```

---

### 5. `EMP_autosave()` ⭐ Recommended

Auto-save wrapper for analysis pipelines with smart naming.

**Parameters:**
- `obj`: EMPT or EMP object (typically from a pipeline)
- `name`: Descriptive name for this analysis step
- `base_dir`: Base output directory (default: `"EMP_Results"`)
- `save_plot`: Whether to save plots (default: `TRUE`)
- `save_data`: Whether to save data (default: `TRUE`)
- `...`: Additional arguments

**Returns:** The original object (for piping)

**Example:**
```r
# Simple autosave in pipeline
MAE |>
  EMP_assay_extract() |>
  EMP_alpha_analysis() |>
  EMP_boxplot(estimate_group = 'Group') |>
  EMP_autosave(name = "alpha_diversity", base_dir = "results")

# Save only plot, skip data
MAE |>
  EMP_assay_extract() |>
  EMP_fitline_plot(var_select = c('Blautia', 'BMI')) |>
  EMP_autosave(
    name = "fitline_blautia_bmi",
    base_dir = "results",
    save_data = FALSE
  )
```

---

## Complete Workflow Example

```r
library(EasyMultiProfiler)
source('EMP_output_utils.R')

# Step 1: Create folder structure
output_dir <- EMP_create_folders(base_dir = "MyProject_Results")

# Step 2: Import data
meta_data <- read.table('coldata.txt', header = T, row.names = 1)
data <- read.table('tax.txt', header = T, sep = '\t')
MAE <- EMP_easy_import(data = data, coldata = meta_data, type = 'tax')

# Step 3: Analysis pipeline with automatic saving
MAE |>
  EMP_assay_extract() |>
  EMP_collapse(collapse_by = 'row', estimate_group = 'Genus') |>
  EMP_identify_assay(estimate_group = 'Group', method = 'default',
                    min = 0.001, min_ratio = 0.7) |>
  EMP_alpha_analysis() |>
  EMP_boxplot(estimate_group = 'Group') |>
  EMP_autosave(name = "01_alpha_diversity", base_dir = output_dir)

MAE |>
  EMP_assay_extract() |>
  EMP_collapse(collapse_by = 'row', estimate_group = 'Genus') |>
  EMP_diff_analysis(method = 'DESeq2', .formula = ~Group) |>
  EMP_filter(feature_condition = pvalue < 0.05, keep_result = TRUE) |>
  EMP_autosave(name = "02_differential_analysis", base_dir = output_dir)

MAE |>
  EMP_assay_extract() |>
  EMP_collapse(collapse_by = 'row', estimate_group = 'Genus') |>
  EMP_identify_assay(estimate_group = 'Group', method = 'default',
                    min = 0.001, min_ratio = 0.7) |>
  EMP_marker_analysis(method = 'boruta', estimate_group = 'Group') |>
  EMP_filter(feature_condition = Boruta_decision != 'Rejected') |>
  EMP_heatmap_plot(palette = 'Spectral', clust_row = TRUE, clust_col = TRUE) |>
  EMP_autosave(name = "03_feature_selection", base_dir = output_dir)
```

---

## Output Organization

The default folder structure is:

```
EMP_Results_20250428_143022/
├── data/
│   ├── 01_alpha_diversity.csv
│   ├── 02_differential_analysis.csv
│   └── 03_feature_selection.csv
├── figures/
│   ├── 01_alpha_diversity_static.pdf
│   ├── 02_differential_analysis_static.pdf
│   └── 03_feature_selection_static.pdf
├── figures_html/
│   ├── 01_alpha_diversity.html
│   ├── 02_differential_analysis.html
│   └── 03_feature_selection.html
└── reports/
```

---

## Tips and Best Practices

1. **Use descriptive names**: Name your analyses clearly (e.g., `"alpha_diversity_genus_level"` instead of `"analysis1"`)

2. **Number your analyses**: Prefix with numbers to maintain order (e.g., `"01_alpha"`, `"02_beta"`)

3. **Timestamp folders**: Keep timestamps enabled to track analysis runs over time

4. **Custom formats**: Choose appropriate formats based on your needs:
   - PDF for publications
   - PNG for presentations
   - SVG for editing in Illustrator
   - HTML for interactive exploration

5. **Save raw objects**: For complex analyses, save raw objects to reload later:
   ```r
   result |> EMP_save_data(..., save_raw = TRUE)
   ```

6. **Chain multiple saves**: You can save with different formats in the same pipeline:
   ```r
   result |>
     EMP_save_plot(output_dir = "pub_figures", format = "pdf") |>
     EMP_save_plot(output_dir = "presentation", format = "png", dpi = 300) |>
     EMP_save_data(output_dir = "data", format = "csv")
   ```

---

## Troubleshooting

**Problem**: Functions not found
```r
Error: could not find function "EMP_autosave"
```
**Solution**: Make sure to source the utility file:
```r
source('EMP_output_utils.R')
```

**Problem**: Plots not saving
**Solution**: Check that your object contains a plot. Some functions only create data without plots.

**Problem**: Permission denied when creating folders
**Solution**: Ensure you have write permissions in the working directory, or specify a different `base_dir`.

---

## Dependencies

These functions require the following packages:
- `EasyMultiProfiler` (core package)
- `htmlwidgets` (for saving interactive HTML plots)

Install missing packages with:
```r
install.packages("htmlwidgets")
```
