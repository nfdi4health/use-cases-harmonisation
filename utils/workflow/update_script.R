update_script <- function(script_path, dataset_name, folder_name) {
  # Ensure the folder_name/scripts directory exists
  scripts_dir <- file.path(folder_name, "scripts")
  if (!dir.exists(scripts_dir)) {
    dir.create(scripts_dir, recursive = TRUE)
  }
  
  # Read the script into a character vector
  lines <- readLines(script_path)
  
  # Update line 21 and 22 with the new values
  lines[21] <- paste0("dataset_name <- '", dataset_name, "'")
  lines[22] <- paste0("folder_name <- '", folder_name, "'")
  
  # Define the new script path
  new_script_path <- file.path(scripts_dir, paste0(dataset_name, ".R"))
  
  # Write the modified script to the new location
  writeLines(lines, new_script_path)
}

