# EasyMultiProfiler Output Management Utilities
# Functions for automatic folder creation and result saving

#' Create Output Folder Structure
#'
#' Creates a standardized folder structure for organizing analysis outputs
#'
#' @param base_dir Base directory path (default: "EMP_Results")
#' @param subfolders Vector of subfolder names to create
#' @param timestamp Whether to add timestamp to base folder name (default: TRUE)
#' @return Path to the created base directory
#' @export
#'
#' @examples
#' output_dir <- EMP_create_folders()
#' output_dir <- EMP_create_folders(base_dir = "MyAnalysis", timestamp = FALSE)
EMP_create_folders <- function(base_dir = "EMP_Results",
                               subfolders = c("data", "figures", "figures_html", "reports"),
                               timestamp = TRUE) {

  # Add timestamp to base directory name if requested
  if (timestamp) {
    timestamp_str <- format(Sys.time(), "%Y%m%d_%H%M%S")
    base_dir <- paste0(base_dir, "_", timestamp_str)
  }

  # Create base directory
  if (!dir.exists(base_dir)) {
    dir.create(base_dir, recursive = TRUE)
    message(paste("Created base directory:", base_dir))
  }

  # Create subfolders
  for (subfolder in subfolders) {
    subfolder_path <- file.path(base_dir, subfolder)
    if (!dir.exists(subfolder_path)) {
      dir.create(subfolder_path, recursive = TRUE)
      message(paste("Created subfolder:", subfolder_path))
    }
  }

  return(invisible(base_dir))
}


#' Save EMP Plot
#'
#' Save plots from EMPT or EMP objects to file
#'
#' @param obj EMPT or EMP object containing plots
#' @param output_dir Output directory path
#' @param prefix Prefix for output filename
#' @param info Plot info name (e.g., "EMP_assay_boxplot"). If NULL, uses current info
#' @param plot_type Type of plot to save: "pic" (ggplot), "html" (interactive), or "both"
#' @param width Plot width in inches (default: 8)
#' @param height Plot height in inches (default: 6)
#' @param dpi Resolution for static plots (default: 300)
#' @param format Format for static plots: "pdf", "png", "svg" (default: "pdf")
#' @return The original object (for piping)
#' @export
#'
#' @examples
#' result <- MAE |>
#'   EMP_assay_extract() |>
#'   EMP_alpha_analysis() |>
#'   EMP_boxplot(estimate_group = 'Group') |>
#'   EMP_save_plot(output_dir = "results", prefix = "alpha_diversity")
EMP_save_plot <- function(obj,
                          output_dir = ".",
                          prefix = "plot",
                          info = NULL,
                          plot_type = "both",
                          width = 8,
                          height = 6,
                          dpi = 300,
                          format = "pdf") {

  # Get plot info
  if (is.null(info)) {
    if (inherits(obj, "EMPT")) {
      info <- .get.info.EMPT(obj)
    } else if (inherits(obj, "EMP")) {
      info <- .get.info.EMP(obj)
    } else {
      stop("Object must be of class EMPT or EMP")
    }
  }

  # Get plot deposit
  if (inherits(obj, "EMPT")) {
    plot_data <- .get.plot_deposit.EMPT(obj, info = info)
  } else if (inherits(obj, "EMP")) {
    plot_data <- .get.plot_deposit.EMP(obj, info = info)
  }

  if (is.null(plot_data)) {
    warning(paste("No plot found for info:", info))
    return(invisible(obj))
  }

  # Create output directory if it doesn't exist
  if (!dir.exists(output_dir)) {
    dir.create(output_dir, recursive = TRUE)
  }

  # Save static plot
  if (plot_type %in% c("pic", "both") && !is.null(plot_data$pic)) {
    static_file <- file.path(output_dir, paste0(prefix, ".", format))

    if (format == "pdf") {
      pdf(static_file, width = width, height = height)
      print(plot_data$pic)
      dev.off()
    } else if (format == "png") {
      png(static_file, width = width * dpi, height = height * dpi, res = dpi)
      print(plot_data$pic)
      dev.off()
    } else if (format == "svg") {
      svg(static_file, width = width, height = height)
      print(plot_data$pic)
      dev.off()
    }

    message(paste("Saved static plot:", static_file))
  }

  # Save HTML plot
  if (plot_type %in% c("html", "both") && !is.null(plot_data$html)) {
    html_file <- file.path(output_dir, paste0(prefix, ".html"))
    htmlwidgets::saveWidget(plot_data$html, html_file, selfcontained = TRUE)
    message(paste("Saved HTML plot:", html_file))
  }

  return(invisible(obj))
}


#' Save EMP Result Data
#'
#' Save analysis results from EMPT or EMP objects to file
#'
#' @param obj EMPT or EMP object containing results
#' @param output_dir Output directory path
#' @param prefix Prefix for output filename
#' @param info Result info name. If NULL, uses current info
#' @param format Format for saving: "csv", "tsv", "rds", or "all" (default: "csv")
#' @param save_raw Whether to also save the raw object as RDS (default: FALSE)
#' @return The original object (for piping)
#' @export
#'
#' @examples
#' result <- MAE |>
#'   EMP_assay_extract() |>
#'   EMP_diff_analysis(method = 'wilcox.test', estimate_group = 'Group') |>
#'   EMP_save_data(output_dir = "results/data", prefix = "diff_analysis")
EMP_save_data <- function(obj,
                          output_dir = ".",
                          prefix = "data",
                          info = NULL,
                          format = "csv",
                          save_raw = FALSE) {

  # Get result info
  if (is.null(info)) {
    if (inherits(obj, "EMPT")) {
      info <- .get.info.EMPT(obj)
    } else if (inherits(obj, "EMP")) {
      info <- .get.info.EMP(obj)
    } else {
      stop("Object must be of class EMPT or EMP")
    }
  }

  # Get result data
  if (inherits(obj, "EMPT")) {
    result_data <- .get.result.EMPT(obj, info = info)
  } else if (inherits(obj, "EMP")) {
    result_data <- .get.result.EMP(obj, info = info)
  }

  if (is.null(result_data)) {
    warning(paste("No result found for info:", info))
    return(invisible(obj))
  }

  # Create output directory if it doesn't exist
  if (!dir.exists(output_dir)) {
    dir.create(output_dir, recursive = TRUE)
  }

  # Handle list results (save each component)
  if (is.list(result_data) && !is.data.frame(result_data)) {
    for (name in names(result_data)) {
      component_data <- result_data[[name]]
      component_prefix <- paste0(prefix, "_", name)

      if (is.data.frame(component_data) || inherits(component_data, "tbl")) {
        .save_table(component_data, output_dir, component_prefix, format)
      } else if (is.matrix(component_data)) {
        .save_table(as.data.frame(component_data), output_dir, component_prefix, format)
      }
    }
  } else if (is.data.frame(result_data) || inherits(result_data, "tbl")) {
    .save_table(result_data, output_dir, prefix, format)
  } else if (is.matrix(result_data)) {
    .save_table(as.data.frame(result_data), output_dir, prefix, format)
  }

  # Save raw object if requested
  if (save_raw) {
    rds_file <- file.path(output_dir, paste0(prefix, "_object.rds"))
    saveRDS(obj, rds_file)
    message(paste("Saved raw object:", rds_file))
  }

  return(invisible(obj))
}


#' Internal function to save table data
#' @keywords internal
.save_table <- function(data, output_dir, prefix, format) {
  if (format %in% c("csv", "all")) {
    csv_file <- file.path(output_dir, paste0(prefix, ".csv"))
    write.csv(data, csv_file, row.names = TRUE)
    message(paste("Saved CSV:", csv_file))
  }

  if (format %in% c("tsv", "all")) {
    tsv_file <- file.path(output_dir, paste0(prefix, ".tsv"))
    write.table(data, tsv_file, sep = "\t", row.names = TRUE, quote = FALSE)
    message(paste("Saved TSV:", tsv_file))
  }

  if (format %in% c("rds", "all")) {
    rds_file <- file.path(output_dir, paste0(prefix, ".rds"))
    saveRDS(data, rds_file)
    message(paste("Saved RDS:", rds_file))
  }
}


#' Save Both Plot and Data
#'
#' Convenience function to save both plot and data from an analysis result
#'
#' @param obj EMPT or EMP object
#' @param output_dir Output directory path
#' @param prefix Prefix for output filenames
#' @param save_plot Whether to save plots (default: TRUE)
#' @param save_data Whether to save data (default: TRUE)
#' @param ... Additional arguments passed to EMP_save_plot and EMP_save_data
#' @return The original object (for piping)
#' @export
#'
#' @examples
#' result <- MAE |>
#'   EMP_assay_extract() |>
#'   EMP_alpha_analysis() |>
#'   EMP_boxplot(estimate_group = 'Group') |>
#'   EMP_save_all(output_dir = "results", prefix = "alpha_diversity")
EMP_save_all <- function(obj,
                        output_dir = ".",
                        prefix = "result",
                        save_plot = TRUE,
                        save_data = TRUE,
                        ...) {

  if (save_data) {
    obj <- EMP_save_data(obj,
                         output_dir = file.path(output_dir, "data"),
                         prefix = prefix,
                         ...)
  }

  if (save_plot) {
    obj <- EMP_save_plot(obj,
                         output_dir = file.path(output_dir, "figures"),
                         prefix = paste0(prefix, "_static"),
                         plot_type = "pic",
                         ...)

    obj <- EMP_save_plot(obj,
                         output_dir = file.path(output_dir, "figures_html"),
                         prefix = prefix,
                         plot_type = "html",
                         ...)
  }

  return(invisible(obj))
}


#' Auto-save Wrapper for Analysis Pipelines
#'
#' Wraps an analysis pipeline and automatically saves outputs with smart naming
#'
#' @param obj EMPT or EMP object (typically from a pipeline)
#' @param name Descriptive name for this analysis step
#' @param base_dir Base output directory
#' @param save_plot Whether to save plots (default: TRUE)
#' @param save_data Whether to save data (default: TRUE)
#' @param ... Additional arguments
#' @return The original object (for piping)
#' @export
#'
#' @examples
#' MAE |>
#'   EMP_assay_extract() |>
#'   EMP_alpha_analysis() |>
#'   EMP_boxplot(estimate_group = 'Group') |>
#'   EMP_autosave(name = "alpha_diversity", base_dir = "results")
EMP_autosave <- function(obj,
                        name = "analysis",
                        base_dir = "EMP_Results",
                        save_plot = TRUE,
                        save_data = TRUE,
                        ...) {

  # Clean name for use in filenames
  clean_name <- gsub("[^[:alnum:]_-]", "_", name)

  # Save with smart defaults
  EMP_save_all(obj,
               output_dir = base_dir,
               prefix = clean_name,
               save_plot = save_plot,
               save_data = save_data,
               ...)

  return(invisible(obj))
}
