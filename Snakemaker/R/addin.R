my_addin <- function() {
suppressPackageStartupMessages(library(shiny))
suppressPackageStartupMessages(library(callr))
suppressPackageStartupMessages(library(later))
suppressPackageStartupMessages(library(rstudioapi))
suppressPackageStartupMessages(library(httr))
suppressPackageStartupMessages(library(jsonlite))
suppressPackageStartupMessages(library(bslib))
suppressPackageStartupMessages(library(keyring))
library(keyring)

  get_storage_dir <- function() {
    # Create OS-specific storage directory
    if (Sys.info()[["sysname"]] == "Windows") {
      # Windows: Use AppData/Local folder
      path <- file.path(Sys.getenv("LOCALAPPDATA"), "Snakemaker")
    } else if (Sys.info()[["sysname"]] == "Darwin") {
      # macOS: Use ~/Library/Application Support
      path <- file.path(path.expand("~"), "Library", "Application Support", "Snakemaker")
    } else {
      # Linux/Unix: Use ~/.config
      path <- file.path(path.expand("~"), ".config", "Snakemaker")
    }
    
    # Create directory if it doesn't exist
    if (!dir.exists(path)) {
      dir.create(path, recursive = TRUE, showWarnings = FALSE)
    }
    return(path)
  }

  get_file_path <- function(filename) {
    file.path(get_storage_dir(), filename)
  }

  get_api_key <- function(model) {
    service <- paste0("Snakemaker_", model)
    api_key <- tryCatch(key_get(service = service, username = Sys.info()[["user"]]), error = function(e) "")
    if (identical(api_key, "")) {
      api_key <- rstudioapi::askForPassword(paste("Enter your API key for", model))
      if (!is.null(api_key) && api_key != "") {
        key_set_with_value(service = service, username = Sys.info()[["user"]], password = api_key)
      } else stop(paste("API key for", model, "is required."))
    }
    api_key
  }

  generate_rule <- function(input_text, model) {
    api_key <- get_api_key(model)
    url <- if (model == "nvidia/llama-3.1-nemotron-70b-instruct") {
      "https://integrate.api.nvidia.com/v1/chat/completions"
    } else if (model == "gpt-4o-mini") {
      "https://api.openai.com/v1/completions"
    } else {
      "https://api.groq.com/openai/v1/chat/completions"
    }

    source_flag_path <- get_file_path("source_flag.txt")
    source_flag <- if (file.exists(source_flag_path)) {
      readLines(source_flag_path, warn = FALSE)
    } else {
      "Either R or Bash"
    }

    body <- list(
      model = model,
      messages = list(
        list(role = "user", content = input_text),
        list(
          role = "system",
          content = paste0("
Convert the following command into a valid Snakemake rule.
Automatically deduce whether the command is written in R or Bash.
Follow these guidelines:

1. Deduce input and output filenames from the command. If unavailable, use '-' for none or 'Unknown' if uncertain.
2. Generate a rule name based on the command.
3. Where appropriate, use wildcards in inputs/outputs.
4. Include a log directive (e.g., log: logs/{rule}.log) if files are processed or wildcards are present.
5. Preserve any newlines in the command for readability.
6. Return only the Snakemake rule with no extra text.
Example of acceptable output:
rule [rulename]:
    input: ...
    output: ...
    log: logs/{rulename}.log
    shell: ...
Provide ONLY the Snakemake rule based on the given command, no additional text, no comments (e.g. markdown), NO ``` before and after the rule.
")
        )
      )
    )

    if (model == "nvidia/llama-3.1-nemotron-70b-instruct") {
      body$temperature <- 0.6
      body$top_p <- 0.7
      body$max_tokens <- 4096
      body$stream <- FALSE
    }

    response <- POST(
      url,
      add_headers(`Content-Type` = "application/json", Authorization = paste("Bearer", api_key)),
      encode = "json",
      body = body
    )

    if (http_type(response) != "application/json") {
      stop("Unexpected response format: ", content(response, as = "text", encoding = "UTF-8"))
    }

    parsed <- fromJSON(content(response, as = "text", encoding = "UTF-8"), simplifyVector = FALSE)
    if (!is.null(parsed$error)) stop(parsed$error$message)
    if (!is.null(parsed$choices) && length(parsed$choices) > 0) {
      choice <- parsed$choices[[1]]
      if (!is.null(choice$message$content)) {
        return(choice$message$content)
      } else {
        stop("Unexpected response format: 'content' missing in 'message'.")
      }
    } else {
      stop("Unexpected response format: 'choices' missing or empty.")
    }
  }

  is_port_ready <- function(port = 8080, retries = 5) {
    for (i in 1:retries) {
      tryCatch({
        con <- suppressWarnings(socketConnection("localhost", port = port,
                                                 server = FALSE,
                                                 blocking = FALSE,
                                                 timeout = 1))
        close(con)
        return(TRUE)
      }, error = function(e) {
        Sys.sleep(0.2)
        FALSE
      })
    }
    FALSE
  }

  get_r_history <- function() {
    history_file <- tempfile(fileext = ".Rhistory")
    tryCatch({
      utils::savehistory(history_file)
      if (file.exists(history_file)) {
        hist_lines <- unique(rev(readLines(history_file)))
        filtered <- hist_lines[!grepl("Snakemaker:::my_addin\\(\\)", hist_lines)]
        writeLines(filtered, get_file_path("r_history.txt"))
        filtered
      } else {
        "No R history available!"
      }
    }, error = function(e) paste("Error accessing R history:", e$message))
  }

  get_term_history <- function() {
    history_file <- path.expand("~/.bash_history")
    if (file.exists(history_file)) {
      history_lines <- readLines(history_file)
      unique_lines <- unique(rev(history_lines))
      writeLines(unique_lines, get_file_path("bash_history.txt"))
      unique_lines
    } else {
      "No terminal history available!"
    }
  }

  rstudioapi::registerCommandCallback("newTerminal", function(...) {

    later::later(function() {
      termId <- rstudioapi::terminalVisible()
      rstudioapi::terminalSend(termId, "PROMPT_COMMAND='history -a'\n")
    }, delay = 3)
  })

  history <- get_r_history()
  term_history <- get_term_history()

  selected_model_path <- get_file_path("selected_model.txt")
  ui <- create_ui(
    history,
    term_history,
    character(),
    selected_model = if (file.exists(selected_model_path)) {
      readLines(selected_model_path, warn = FALSE)
    } else {
      "llama3-8b-8192"
    }
  )

  app <- shinyApp(ui, server)

  shiny_bg_process <- callr::r_bg(function(app) {
    shiny::runApp(app, port = 8080)
  }, args = list(app))

  Sys.sleep(0.5)
  attempts <- 0
  while (!is_port_ready() && attempts < 10) {
    Sys.sleep(0.2)
    attempts <- attempts + 1
  }

  Sys.sleep(1)
  viewer <- getOption("viewer")
  if (!is.null(viewer)) {
    viewer("http://localhost:8080")
  } else {
    showNotification("Shiny app is running at http://localhost:8080", duration = 5, type = "message")
  }

  recursive_check <- function(interval = 0.2) {
    selected_model_path <- get_file_path("selected_model.txt")
    current_model <- if (file.exists(selected_model_path)) {
      sel <- readLines(selected_model_path, warn = FALSE)
      if (length(sel) == 0 || sel == "") "llama3-8b-8192" else sel
    } else {
      "llama3-8b-8192"
    }

    flag_file <- get_file_path(paste0("delete_api_key_", current_model, ".txt"))
    if (file.exists(flag_file)) {
      Sys.unsetenv(current_model)
      file.remove(flag_file)
    }

    selected_line_path <- get_file_path("selected_line.txt")
    if (file.exists(selected_line_path)) {
      selected_line_lines <- readLines(selected_line_path)
      writeLines("", selected_line_path)
      selected_line <- paste(selected_line_lines, collapse = "\n")
    } else {
      selected_line <- ""
    }
    if (nchar(selected_line) > 0) {
      context <- rstudioapi::getActiveDocumentContext()
      if (!is.null(context)) {
        tryCatch({
          snakemake_rule <- generate_rule(selected_line, model = current_model)
          rstudioapi::insertText(location = context$selection[[1]]$range, text = snakemake_rule)
        }, error = function(e) {
          message <- paste("Error generating rule:", e$message)
          rstudioapi::showDialog("Error", message)
        })
      }
    }

    # Update history files
    get_r_history()
    get_term_history()

    later::later(recursive_check, interval)
  }

  recursive_check()
}

