dataschema_1 <- tibble::tibble(readxl::read_excel(here::here("rmonize/data_schema/", "Dataschema_P1.xlsx"), sheet = 1))
dataschema_2 <- tibble::tibble(readxl::read_excel(here::here("rmonize/data_schema/", "Dataschema_P1.xlsx"), sheet = 2))

dataschema_p1 <- list(Variables = dataschema_1,
                   Categories = dataschema_2)
dataschema_1 <- tibble::tibble(readxl::read_excel(here::here("rmonize/data_schema/", "Dataschema_P2.xlsx"), sheet = 1))
dataschema_2 <- tibble::tibble(readxl::read_excel(here::here("rmonize/data_schema/", "Dataschema_P2.xlsx"), sheet = 2))

dataschema_p2 <- list(Variables = dataschema_1,
                   Categories = dataschema_2)
intersect <- intersect(dataschema_p1$Variables$name, dataschema_p2$Variables$name)
union <- union(dataschema_p1$Variables$name, dataschema_p2$Variables$name)

franzi_vars <-union[9:127]
tracy_vars <-union[c(1:4,6, 128, 129, 131:139, 144:185)] 
ines_vars <- union[c(5, 7, 8, 130, 140:143, 186:212)]

P1_P2_intersect <- cbind(intersect, dataschema_p1$Variables$index[dataschema_p1$Variables$name %in% intersect], dataschema_p2$Variables$index[dataschema_p2$Variables$name %in% intersect])
colnames(P1_P2_intersect) <- c("name", "index_P1", "index_P2")

P1_P2_union <- data.frame(
  name = union,
  index_P1 = match(union, dataschema_p1$Variables$name), # Index of variables in dfA (NA if not present)
  index_P2 = match(union, dataschema_p2$Variables$name)  # Index of variables in dfB (NA if not present)
)

dpe_P1 <- readxl::read_excel(here::here("rmonize/data_proc_elem/DPE_KARMEN_P1.xlsx"), sheet = 1)
dpe_P2 <- readxl::read_excel(here::here("rmonize/data_proc_elem/DPE_KARMEN_P2.xlsx"), sheet = 1)

assign_and_compare <- function(dfA, dfB, tracy_vars, ines_vars, franzi_vars) {
  # Initialize output lists for each person
  tracy <- list()
  ines <- list()
  franzi <- list()
  
  # Get the list of all unique variables
  all_vars <- union(dfA$dataschema_variable, dfB$dataschema_variable)
  
  for (var in all_vars) {
    # Get indices of the variable in dfA and dfB
    idxA <- which(dfA$dataschema_variable == var)
    idxB <- which(dfB$dataschema_variable == var)
   
    # Determine the source of the variable and compare if necessary
    if (length(idxA) > 0 && length(idxB) > 0) { # Exists in both
      # Get rows from dfA and dfB
      valueA <- dfA[idxA, ]
      valueB <- dfB[idxB, ]
      
      # Exclude the $input_dataset column for comparison
      compareA <- valueA[, !(colnames(valueA) %in% "input_dataset"), drop = FALSE]
      compareB <- valueB[, !(colnames(valueB) %in% "input_dataset"), drop = FALSE]
      
      # Compare rows and decide the value
      if (identical(compareA, compareB)) {
        value <- valueA
      } else {
        value <- valueA
        value$`Mlstr_harmo::status` <- "ERROR" # Indicate mismatch
      }
    } else if (length(idxA) > 0) { # Exists only in dfA
      value <- dfA[idxA, ]
    } else if (length(idxB) > 0) { # Exists only in dfB
      value <- dfB[idxB, ]
    } else {
      next # Skip if it doesn't exist in either
    }
    # Set $input_dataset to "KARMEN_PX"
    value$input_dataset <- "KARMEN_PX"
    
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
  
  return(result)
}

writexl::write_xlsx(result$Tracy, "tests/DPE_KARMEN_TRACY.xlsx")
writexl::write_xlsx(result$Ines, "tests/DPE_KARMEN_INES.xlsx")
writexl::write_xlsx(result$Franzi, "tests/DPE_KARMEN_FRANZI.xlsx")
