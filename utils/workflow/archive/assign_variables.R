assign_and_compare <- function(studyname) {
  dataschema_p1 <- list(Variables =  tibble::tibble(readxl::read_excel(here::here("rmonize/data_schema/", "Dataschema_P1.xlsx"), sheet = 1)),
                        Categories = tibble::tibble(readxl::read_excel(here::here("rmonize/data_schema/", "Dataschema_P1.xlsx"), sheet = 2)))
  dataschema_p2 <- list(Variables =  tibble::tibble(readxl::read_excel(here::here("rmonize/data_schema/", "Dataschema_P2.xlsx"), sheet = 1)),
                        Categories = tibble::tibble(readxl::read_excel(here::here("rmonize/data_schema/", "Dataschema_P2.xlsx"), sheet = 2)))
  
  union <- union(dataschema_p1$Variables$name, dataschema_p2$Variables$name)
  
  franzi_vars <-union[9:127]
  tracy_vars <-union[c(1:4,6, 128, 129, 131:139, 144:185)] 
  ines_vars <- union[c(5, 7, 8, 130, 140:143, 186:212)]
  
  dpe_p1 <- readxl::read_excel(here::here("rmonize/data_proc_elem", paste0("DPE_", studyname, "_P1.xlsx")), sheet = 1)
  dpe_p2 <- readxl::read_excel(here::here("rmonize/data_proc_elem", paste0("DPE_", studyname, "_P2.xlsx")), sheet = 1)
  # Initialize output lists for each person
  tracy <- list()
  ines <- list()
  franzi <- list()
  
  # Get the list of all unique variables
  all_vars <- union(dpe_p1$dataschema_variable, dpe_p2$dataschema_variable)
  
  for (var in all_vars) {
    # Validation logic
    if (var %in% dataschema_p1$Variables$name && var %in% dataschema_p2$Variables$name) {
      # Check against both dpe_p1 and dpe_p2
      if (!var %in% dpe_p1$dataschema_variable) {
        warning(sprintf("Warning: 'var' (%s) is in 'dataschema_p1' but does not match 'dpe_p1$dataschema_variable' (%s).", var, dpe_p1$dataschema_variable))
      }
      if (!var %in% dpe_p2$dataschema_variable) {
        warning(sprintf("Warning: 'var' (%s) is in 'dataschema_p2' but does not match 'dpe_p2$dataschema_variable' (%s).", var, dpe_p2$dataschema_variable))
      }
    } else if (var %in% dataschema_p1$Variables$name) {
      # Check against dpe_p1 only
      if (!var %in% dpe_p1$dataschema_variable) {
        warning(sprintf("Warning: 'var' (%s) is in 'dataschema_p1' but does not match 'dpe_p1$dataschema_variable' (%s).", var, dpe_p1$dataschema_variable))
      }
    } else if (var %in% dataschema_p2$Variables$name) {
      # Check against dpe_p2 only
      if (!var %in% dpe_p2$dataschema_variable) {
        warning(sprintf("Warning: 'var' (%s) is in 'dataschema_p2' but does not match 'dpe_p2$dataschema_variable' (%s).", var, dpe_p2$dataschema_variable))
      }
    } else {
      # Handle case where 'var' is in neither dataschema
      warning(sprintf("Warning: 'var' (%s) is not found in 'dataschema_p1$Variables$name' or 'dataschema_p2$Variables$name'.", var))
    }
    
    # Get indices of the variable in dpe_p1 and dpe_p2
    idxA <- which(dpe_p1$dataschema_variable == var)
    idxB <- which(dpe_p2$dataschema_variable == var)
   
    # Determine the source of the variable and compare if necessary
    if (length(idxA) > 0 && length(idxB) > 0) { # Exists in both
      # Get rows from dpe_p1 and dpe_p2
      valueA <- dpe_p1[idxA, ]
      valueB <- dpe_p2[idxB, ]
      
      # Exclude the $input_dataset column for comparison
      compareA <- valueA[, !(colnames(valueA) %in% "input_dataset"), drop = FALSE]
      compareB <- valueB[, !(colnames(valueB) %in% "input_dataset"), drop = FALSE]
      
      # Compare rows and decide the value
      if (identical(compareA, compareB)) {
        value <- valueA
      } else {
        value <- valueA
        value$`Mlstr_harmo::comment` <- "ERROR" # Indicate mismatch
      }
    } else if (length(idxA) > 0) { # Exists only in dpe_p1
      value <- dpe_p1[idxA, ]
    } else if (length(idxB) > 0) { # Exists only in dpe_p2
      value <- dpe_p2[idxB, ]
    } else {
      next # Skip if it doesn't exist in either
    }
    # Set $input_dataset to ""
    value$input_dataset <- ""
    
    # Assign the variable to the appropriate person
    if (var %in% tracy_vars) {
      tracy <- rbind(tracy, value)
    } else if (var %in% ines_vars) {
      ines <- rbind(ines, value)
    } else if (var %in% franzi_vars) {
      franzi <- rbind(franzi, value)
    }
  }
  # Combine results into a named list
  result <- list(
    Tracy = tracy,
    Ines = ines,
    Franzi = franzi
  )
  writexl::write_xlsx(result$Tracy, paste0("Tracy/DPE_", studyname, "_TRACY.xlsx"))
  writexl::write_xlsx(result$Ines, paste0("Ines/DPE_", studyname, "_INES.xlsx"))
  writexl::write_xlsx(result$Franzi, paste0("Franzi/DPE_", studyname, "_FRANZI.xlsx"))
  return(result)
}
