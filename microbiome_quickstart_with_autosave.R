# Microbiome Analysis Quick Start with Automatic Output Saving
# This script demonstrates EasyMultiProfiler workflows with automatic folder creation and result saving

rm(list = ls())
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

library(EasyMultiProfiler)

# Source the output utility functions
source('EMP_output_utils.R')

# Create output folder structure
output_dir <- EMP_create_folders(base_dir = "EMP_Results", timestamp = TRUE)
cat("All results will be saved to:", output_dir, "\n")


### 1. Data Import ----
meta_data <- read.table('coldata.txt', header = T, row.names = 1)
data <- read.table('tax.txt', header = T, sep = '\t')

MAE <- EMP_easy_import(data = data, coldata = meta_data, type = 'tax')


### 2. Data Extraction and Exploration ----

# Extract assay data
MAE |>
  EMP_assay_extract()

# Collapse to different taxonomic levels
MAE |>
  EMP_assay_extract() |>
  EMP_collapse(collapse_by = 'row', estimate_group = 'Phylum')

MAE |>
  EMP_assay_extract() |>
  EMP_collapse(collapse_by = 'row', estimate_group = 'Class')


### 3. Data Rarefaction (Optional) ----
MAE |>
  EMP_assay_extract() |>
  EMP_rrarefy(raresize = 5000)


### 4. Data Normalization ----

# Relative abundance
MAE |>
  EMP_assay_extract() |>
  EMP_collapse(collapse_by = 'row', estimate_group = 'Genus') |>
  EMP_decostand(method = 'relative')

# CLR transformation
MAE |>
  EMP_assay_extract() |>
  EMP_collapse(collapse_by = 'row', estimate_group = 'Genus') |>
  EMP_decostand(method = 'clr')

# Log2 transformation
MAE |>
  EMP_assay_extract() |>
  EMP_collapse(collapse_by = 'row', estimate_group = 'Genus') |>
  EMP_decostand(method = 'log2')


### 5. Batch Correction ----
MAE |>
  EMP_assay_extract() |>
  EMP_coldata_extract()

MAE |>
  EMP_assay_extract() |>
  EMP_collapse(collapse_by = 'row', estimate_group = 'Genus') |>
  EMP_adjust_abundance(.factor_unwanted = 'Region',
                      .factor_of_interest = 'Group',
                      method = 'combat_seq')


### 6. Core Microbiome Identification ----
MAE |>
  EMP_assay_extract() |>
  EMP_collapse(collapse_by = 'row', estimate_group = 'Genus') |>
  EMP_identify_assay(estimate_group = 'Group', method = 'default',
                    min = 0.001, min_ratio = 0.7)


### 7. Alpha Diversity Analysis ----
MAE |>
  EMP_assay_extract() |>
  EMP_collapse(collapse_by = 'row', estimate_group = 'Genus') |>
  EMP_identify_assay(estimate_group = 'Group', method = 'default',
                    min = 0.001, min_ratio = 0.7) |>
  EMP_alpha_analysis() |>
  EMP_boxplot(estimate_group = 'Group') |>
  EMP_autosave(name = "01_alpha_diversity", base_dir = output_dir)


### 8. Beta Diversity Analysis ----
MAE |>
  EMP_assay_extract() |>
  EMP_collapse(collapse_by = 'row', estimate_group = 'Genus') |>
  EMP_identify_assay(estimate_group = 'Group', method = 'default',
                    min = 0.001, min_ratio = 0.7) |>
  EMP_dimension_analysis(method = 'pcoa', distance = 'bray') |>
  EMP_scatterplot(estimate_group = 'Group', show = 'p12html') |>
  EMP_autosave(name = "02_beta_diversity_PCoA", base_dir = output_dir)


### 9. Differential Abundance Analysis ----

# Wilcoxon test
MAE |>
  EMP_assay_extract() |>
  EMP_collapse(collapse_by = 'row', estimate_group = 'Genus') |>
  EMP_diff_analysis(method = 'wilcox.test', estimate_group = 'Group') |>
  EMP_filter(feature_condition = pvalue < 0.05) |>
  EMP_autosave(name = "03_diff_analysis_wilcox", base_dir = output_dir)

# DESeq2 analysis
MAE |>
  EMP_assay_extract() |>
  EMP_collapse(collapse_by = 'row', estimate_group = 'Genus') |>
  EMP_diff_analysis(method = 'DESeq2', .formula = ~Group) |>
  EMP_filter(feature_condition = pvalue < 0.05, keep_result = TRUE) |>
  EMP_autosave(name = "04_diff_analysis_DESeq2", base_dir = output_dir)


### 10. Machine Learning - Feature Selection ----

# Boruta algorithm
MAE |>
  EMP_assay_extract() |>
  EMP_collapse(collapse_by = 'row', estimate_group = 'Genus') |>
  EMP_identify_assay(estimate_group = 'Group', method = 'default',
                    min = 0.001, min_ratio = 0.7) |>
  EMP_marker_analysis(method = 'boruta', estimate_group = 'Group') |>
  EMP_filter(feature_condition = Boruta_decision != 'Rejected') |>
  EMP_heatmap_plot(palette = 'Spectral', legend_bar = 'auto',
                   clust_row = TRUE, clust_col = TRUE) |>
  EMP_autosave(name = "05_ML_boruta", base_dir = output_dir)

# LASSO regression
MAE |>
  EMP_assay_extract() |>
  EMP_collapse(collapse_by = 'row', estimate_group = 'Species') |>
  EMP_identify_assay(estimate_group = 'Group', method = 'default',
                    min = 0.001, min_ratio = 0.7) |>
  EMP_marker_analysis(method = 'lasso', estimate_group = 'Height') |>
  EMP_filter(feature_condition = lasso_coe > 0) |>
  EMP_collapse(method = 'mean', estimate_group = 'Group',
              collapse_by = 'col') |>
  EMP_heatmap_plot(palette = 'Spectral', legend_bar = 'auto') |>
  EMP_autosave(name = "06_ML_lasso", base_dir = output_dir)


### 11. Correlation Analysis ----
phylum_data <- MAE |>
  EMP_assay_extract() |>
  EMP_collapse(collapse_by = 'row', estimate_group = 'Phylum')

meta_data <- MAE |>
  EMP_coldata_extract(action = 'add')

(phylum_data + meta_data) |>
  EMP_cor_analysis(method = 'spearman') |>
  EMP_heatmap_plot() |>
  EMP_autosave(name = "07_correlation_analysis", base_dir = output_dir)


### 12. Linear Fitting Analysis ----
MAE |>
  EMP_assay_extract() |>
  EMP_collapse(collapse_by = 'row', estimate_group = 'Genus') |>
  EMP_fitline_plot(var_select = c('Blautia', 'BMI')) |>
  EMP_autosave(name = "08_linear_fitting", base_dir = output_dir,
              save_data = FALSE)  # Only save plot for this analysis


### 13. Network Analysis ----
MAE |>
  EMP_assay_extract() |>
  EMP_collapse(estimate_group = 'Genus', collapse_by = 'row') |>
  EMP_diff_analysis(method = 'wilcox.test', estimate_group = 'Group') |>
  EMP_filter(feature_condition = pvalue < 0.05) |>
  EMP_network_analysis(coldata_to_assay = c('BMI', 'PHQ9', 'GAD7')) |>
  EMP_network_plot(node_info = 'Phylum', label.cex = 1, edge.labels = TRUE) |>
  EMP_autosave(name = "09_network_analysis", base_dir = output_dir)


### Summary ----
cat("\n=== Analysis Complete ===\n")
cat("All results have been saved to:", output_dir, "\n")
cat("\nFolder structure:\n")
cat("  - data/           : CSV files with analysis results\n")
cat("  - figures/        : Static plots (PDF format)\n")
cat("  - figures_html/   : Interactive HTML plots\n")
cat("  - reports/        : (Reserved for future use)\n")
