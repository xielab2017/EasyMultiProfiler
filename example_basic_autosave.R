# Basic Example: Quick Start with Auto-Save
# This script shows the simplest way to use the auto-save functionality

rm(list = ls())
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

library(EasyMultiProfiler)

# Load the output utility functions
source('EMP_output_utils.R')

### STEP 1: Create output folders ----
# This creates a timestamped folder with subfolders for data, figures, etc.
output_dir <- EMP_create_folders(base_dir = "EMP_Results", timestamp = TRUE)
cat("Results will be saved to:", output_dir, "\n\n")


### STEP 2: Import your data ----
meta_data <- read.table('coldata.txt', header = T, row.names = 1)
data <- read.table('tax.txt', header = T, sep = '\t')

MAE <- EMP_easy_import(data = data, coldata = meta_data, type = 'tax')


### STEP 3: Run analyses with automatic saving ----

# Example 1: Alpha diversity analysis
cat("Running alpha diversity analysis...\n")
MAE |>
  EMP_assay_extract() |>
  EMP_collapse(collapse_by = 'row', estimate_group = 'Genus') |>
  EMP_identify_assay(estimate_group = 'Group', method = 'default',
                    min = 0.001, min_ratio = 0.7) |>
  EMP_alpha_analysis() |>
  EMP_boxplot(estimate_group = 'Group') |>
  EMP_autosave(name = "alpha_diversity", base_dir = output_dir)

cat("\n")

# Example 2: Beta diversity analysis
cat("Running beta diversity analysis...\n")
MAE |>
  EMP_assay_extract() |>
  EMP_collapse(collapse_by = 'row', estimate_group = 'Genus') |>
  EMP_identify_assay(estimate_group = 'Group', method = 'default',
                    min = 0.001, min_ratio = 0.7) |>
  EMP_dimension_analysis(method = 'pcoa', distance = 'bray') |>
  EMP_scatterplot(estimate_group = 'Group', show = 'p12html') |>
  EMP_autosave(name = "beta_diversity", base_dir = output_dir)

cat("\n")

# Example 3: Differential abundance analysis
cat("Running differential abundance analysis...\n")
MAE |>
  EMP_assay_extract() |>
  EMP_collapse(collapse_by = 'row', estimate_group = 'Genus') |>
  EMP_diff_analysis(method = 'wilcox.test', estimate_group = 'Group') |>
  EMP_filter(feature_condition = pvalue < 0.05) |>
  EMP_autosave(name = "differential_abundance", base_dir = output_dir)

cat("\n")

### STEP 4: Check your results ----
cat("=== Analysis Complete! ===\n")
cat("All results saved to:", output_dir, "\n\n")
cat("Check these folders:\n")
cat("  -", file.path(output_dir, "data"), "         : Result tables (CSV files)\n")
cat("  -", file.path(output_dir, "figures"), "      : Static plots (PDF files)\n")
cat("  -", file.path(output_dir, "figures_html"), " : Interactive HTML plots\n\n")

# List saved files
cat("Files saved:\n")
cat("Data files:\n")
print(list.files(file.path(output_dir, "data")))
cat("\nStatic plots:\n")
print(list.files(file.path(output_dir, "figures")))
cat("\nHTML plots:\n")
print(list.files(file.path(output_dir, "figures_html")))


### ADVANCED: Manual control over saving ----
# If you need more control, you can use individual functions:

# Save only data (no plots)
# MAE |>
#   EMP_assay_extract() |>
#   EMP_collapse(collapse_by = 'row', estimate_group = 'Genus') |>
#   EMP_save_data(output_dir = file.path(output_dir, "data"),
#                prefix = "genus_abundance",
#                format = "csv")

# Save only plots (no data)
# MAE |>
#   EMP_assay_extract() |>
#   EMP_alpha_analysis() |>
#   EMP_boxplot(estimate_group = 'Group') |>
#   EMP_save_plot(output_dir = file.path(output_dir, "figures"),
#                prefix = "alpha_boxplot",
#                plot_type = "both",
#                format = "png",
#                dpi = 300)

# Save with custom formats
# result |>
#   EMP_save_data(output_dir = file.path(output_dir, "data"),
#                prefix = "my_analysis",
#                format = "all",        # Save as CSV, TSV, and RDS
#                save_raw = TRUE)       # Also save the raw R object
