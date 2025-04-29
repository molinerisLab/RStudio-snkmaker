suppressPackageStartupMessages(library(shiny))
suppressPackageStartupMessages(library(callr))
suppressPackageStartupMessages(library(later))
suppressPackageStartupMessages(library(rstudioapi))
suppressPackageStartupMessages(library(httr))
suppressPackageStartupMessages(library(jsonlite))
suppressPackageStartupMessages(library(bslib))

source("R/utils.R")  # Source the common utilities
source("R/ui.R")
source("R/server.R")
source("R/addin.R")

# Use get_file_path from utils.R
selected_model_path <- get_file_path("selected_model.txt")
shinyApp(
  ui = create_ui(
    history = if (file.exists("r_history.txt")) readLines("r_history.txt", warn = FALSE) else character(),
    term_history = if (file.exists("bash_history.txt")) readLines("bash_history.txt", warn = FALSE) else character(),
    archived_rules = character(),
    selected_model = if (file.exists(selected_model_path)) {
      readLines(selected_model_path, warn = FALSE)
    } else {
      "llama3-8b-8192"
    }
  ),
  server = server
)
