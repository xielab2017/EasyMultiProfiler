# Auto-Save Quick Guide for EasyMultiProfiler

## What's New?

New utility functions have been added to automatically save your analysis results and figures into organized folders!

## Files Added

1. **`EMP_output_utils.R`** - Core utility functions for automatic saving
2. **`microbiome_quickstart_with_autosave.R`** - Complete workflow with auto-save
3. **`example_basic_autosave.R`** - Simple example to get started quickly
4. **`EMP_output_utils_README.md`** - Detailed documentation
5. **`AUTOSAVE_QUICK_GUIDE.md`** - This file

## Quick Start (30 seconds)

Add just 2 lines to your existing script:

```r
# Add at the beginning of your script
source('EMP_output_utils.R')
output_dir <- EMP_create_folders()

# Add |> EMP_autosave(...) to any analysis pipeline
MAE |>
  EMP_assay_extract() |>
  EMP_alpha_analysis() |>
  EMP_boxplot(estimate_group = 'Group') |>
  EMP_autosave(name = "alpha_diversity", base_dir = output_dir)  # <- ADD THIS LINE
```

That's it! Your results are now automatically saved to organized folders.

## What Gets Saved?

After running your analysis, you'll have:

```
EMP_Results_20250428_143022/
├── data/
│   └── alpha_diversity.csv              (your result data)
├── figures/
│   └── alpha_diversity_static.pdf       (publication-ready plot)
└── figures_html/
    └── alpha_diversity.html             (interactive plot)
```

## Key Functions

| Function | Purpose | Usage |
|----------|---------|-------|
| `EMP_create_folders()` | Create output folders | `output_dir <- EMP_create_folders()` |
| `EMP_autosave()` | Auto-save everything | Add to pipeline: `\|> EMP_autosave(name = "my_analysis", base_dir = output_dir)` |
| `EMP_save_plot()` | Save only plots | `\|> EMP_save_plot(output_dir = "figs", prefix = "plot1")` |
| `EMP_save_data()` | Save only data | `\|> EMP_save_data(output_dir = "data", prefix = "results")` |

## Examples

### Example 1: Basic Auto-Save

```r
library(EasyMultiProfiler)
source('EMP_output_utils.R')

# Create folders
output_dir <- EMP_create_folders()

# Import data
MAE <- EMP_easy_import(data = data, coldata = meta_data, type = 'tax')

# Run analysis with auto-save
MAE |>
  EMP_assay_extract() |>
  EMP_collapse(collapse_by = 'row', estimate_group = 'Genus') |>
  EMP_diff_analysis(method = 'wilcox.test', estimate_group = 'Group') |>
  EMP_autosave(name = "differential_analysis", base_dir = output_dir)
```

### Example 2: Multiple Analyses

```r
source('EMP_output_utils.R')
output_dir <- EMP_create_folders(base_dir = "MyProject")

# Alpha diversity
MAE |> ... |> EMP_autosave(name = "01_alpha", base_dir = output_dir)

# Beta diversity
MAE |> ... |> EMP_autosave(name = "02_beta", base_dir = output_dir)

# Differential analysis
MAE |> ... |> EMP_autosave(name = "03_diff", base_dir = output_dir)
```

### Example 3: Save Only Plots

```r
MAE |>
  EMP_assay_extract() |>
  EMP_fitline_plot(var_select = c('Blautia', 'BMI')) |>
  EMP_autosave(name = "fitline", base_dir = output_dir, save_data = FALSE)
```

### Example 4: Custom Output Formats

```r
result |>
  EMP_save_plot(
    output_dir = "figures",
    prefix = "my_plot",
    format = "png",    # or "pdf", "svg"
    width = 10,
    height = 8,
    dpi = 600
  ) |>
  EMP_save_data(
    output_dir = "data",
    prefix = "my_data",
    format = "all",    # saves CSV, TSV, and RDS
    save_raw = TRUE    # also saves the raw R object
  )
```

## Getting Started

### Option 1: Use the Complete Example

Run the complete workflow:

```r
source('microbiome_quickstart_with_autosave.R')
```

### Option 2: Use the Basic Example

Run a simpler version:

```r
source('example_basic_autosave.R')
```

### Option 3: Add to Your Existing Script

Just add these lines:

```r
source('EMP_output_utils.R')                    # Load functions
output_dir <- EMP_create_folders()              # Create folders

# ... your existing analysis code ...

# Add this to any pipeline:
|> EMP_autosave(name = "descriptive_name", base_dir = output_dir)
```

## Benefits

✅ **Organized**: All results in structured folders
✅ **Timestamped**: Never overwrite previous results
✅ **Automated**: No manual file management
✅ **Flexible**: Works with any EMP analysis
✅ **Pipe-friendly**: Integrates seamlessly into pipelines
✅ **Multiple formats**: Saves both static and interactive plots

## Need More Help?

- **Detailed documentation**: See `EMP_output_utils_README.md`
- **Complete examples**: See `microbiome_quickstart_with_autosave.R`
- **Basic examples**: See `example_basic_autosave.R`

## Tips

1. **Use descriptive names**: `name = "alpha_diversity_by_treatment"` instead of `name = "plot1"`
2. **Number your analyses**: `name = "01_alpha"`, `name = "02_beta"`, etc.
3. **Keep timestamps enabled**: Track your analysis runs over time
4. **Choose appropriate formats**: PDF for publications, PNG for presentations, HTML for exploration

---

**That's all you need to know to get started!** The functions handle everything automatically.
