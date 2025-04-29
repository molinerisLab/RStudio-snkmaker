# Common utility functions for Snakemaker

# Get storage directory based on OS
get_storage_dir <- function() {
  if (Sys.info()[["sysname"]] == "Windows") {
    path <- file.path(Sys.getenv("LOCALAPPDATA"), "Snakemaker")
  } else if (Sys.info()[["sysname"]] == "Darwin") {
    path <- file.path(path.expand("~"), "Library", "Application Support", "Snakemaker")
  } else {
    path <- file.path(path.expand("~"), ".config", "Snakemaker")
  }

  if (!dir.exists(path)) {
    dir.create(path, recursive = TRUE, showWarnings = FALSE)
  }
  return(path)
}

# Helper function to build file paths in the storage directory
get_file_path <- function(filename) {
  file.path(get_storage_dir(), filename)
}

