dataschema_p1 <- list(Variables =  tibble::tibble(readxl::read_excel(here::here("rmonize/data_schema/", "Dataschema_P1.xlsx"), sheet = 1)),
                      Categories = tibble::tibble(readxl::read_excel(here::here("rmonize/data_schema/", "Dataschema_P1.xlsx"), sheet = 2)))
dataschema_p2 <- list(Variables =  tibble::tibble(readxl::read_excel(here::here("rmonize/data_schema/", "Dataschema_P2.xlsx"), sheet = 1)),
                      Categories = tibble::tibble(readxl::read_excel(here::here("rmonize/data_schema/", "Dataschema_P2.xlsx"), sheet = 2)))
library(dplyr)


# Merge the 'Variables' tibbles
merged_variables <- dplyr::bind_rows(dataschema_p1$Variables, dataschema_p2$Variables) %>%
  dplyr::distinct(name, .keep_all = TRUE)

# Set the 'index' column to blank
merged_variables$index <- NA  # Use NA or "" for an empty string if needed

# Merge the 'Categories' tibbles
merged_categories <- dplyr::bind_rows(dataschema_p1$Categories, dataschema_p2$Categories) %>%
  dplyr::distinct(variable, label, name, .keep_all = TRUE)

# Combine into a single list
merged_dataschema <- list(
  Variables = merged_variables,
  Categories = merged_categories
)

# Check the result
merged_dataschema

union <- union(dataschema_p1$Variables$name, dataschema_p2$Variables$name)
franzi_vars <-union[9:128]
tracy_vars <-union[c(1:6,129:140, 145:186)] 
ines_vars <- union[c(7, 8, 141:144, 187:215)]

# Function to filter the dataschema based on variable names
filter_dataschema <- function(dataschema, var_names) {
  variables_filtered <- dataschema$Variables %>%
    dplyr::filter(name %in% var_names)
  
  categories_filtered <- dataschema$Categories %>%
    dplyr::filter(variable %in% var_names)
  
  list(Variables = variables_filtered, Categories = categories_filtered)
}

# Separate the dataschema into three
Dataschema_TRACY <- filter_dataschema(merged_dataschema,tracy_vars)
Dataschema_INES <- filter_dataschema(merged_dataschema, ines_vars)
Dataschema_FRANZI <- filter_dataschema(merged_dataschema, franzi_vars)

# writexl::write_xlsx(Dataschema_TRACY, "Tracy/rmonize/data_schema/Dataschema_TRACY.xlsx")
# writexl::write_xlsx(Dataschema_FRANZI, "Franzi/rmonize/data_schema/Dataschema_FRANZI.xlsx")
# writexl::write_xlsx(Dataschema_INES, "Ines/rmonize/data_schema/Dataschema_INES.xlsx")

# DPEs based on Dataschema
studyname = ""

DPE_TRACY <- Dataschema_TRACY[["Variables"]]
names(DPE_TRACY)[2] <- "dataschema_variable"
DPE_TRACY[, c("input_dataset", "input_variables","Mlstr_harmo::rule_category","Mlstr_harmo::algorithm" ,"Mlstr_harmo::comment","Mlstr_harmo::status","Mlstr_harmo::status_detail")] <- NA
writexl::write_xlsx(DPE_TRACY, paste0("analyst/Tracy/rmonize/data_proc_elem/DPE_", studyname, "_TRACY.xlsx"))

DPE_FRANZI <- Dataschema_FRANZI[["Variables"]]
names(DPE_FRANZI)[2] <- "dataschema_variable"
DPE_FRANZI[, c("input_dataset", "input_variables","Mlstr_harmo::rule_category","Mlstr_harmo::algorithm" ,"Mlstr_harmo::comment","Mlstr_harmo::status","Mlstr_harmo::status_detail")] <- NA
writexl::write_xlsx(DPE_FRANZI, paste0("analyst/Franzi/rmonize/data_proc_elem/DPE_", studyname, "_FRANZI.xlsx"))

DPE_INES <- Dataschema_INES[["Variables"]]
names(DPE_INES)[2] <- "dataschema_variable"
DPE_INES[, c("input_dataset", "input_variables","Mlstr_harmo::rule_category","Mlstr_harmo::algorithm" ,"Mlstr_harmo::comment","Mlstr_harmo::status","Mlstr_harmo::status_detail")] <- NA
writexl::write_xlsx(DPE_INES, paste0("analyst/Ines/rmonize/data_proc_elem/DPE_", studyname, "_INES.xlsx"))

dd <-list(
  Variables = tibble::tibble(
    index = integer(),
    name = character(), 
    label = character(),
    valueType = character()
    
  ),
  Categories = tibble::tibble(
    variable = character(),
    name = integer(),
    label = character()
  )
)

writexl::write_xlsx(dd, paste0("analyst/Tracy/rmonize/data_dictionary/DD_", studyname, "_TRACY.xlsx"))
writexl::write_xlsx(dd, paste0("analyst/Franzi/rmonize/data_dictionary/DD_", studyname, "_FRANZI.xlsx"))
writexl::write_xlsx(dd, paste0("analyst/Ines/rmonize/data_dictionary/DD_", studyname, "_INES.xlsx"))

# Scripts creation
source(here::here("utils/workflow", "update_script.R"))
update_script(script_path = "utils/workflow/script_template.R", dataset_name =paste0(studyname, "_TRACY"), folder_name = "analyst/Tracy")
update_script(script_path = "utils/workflow/script_template.R", dataset_name =paste0(studyname, "_FRANZI"), folder_name = "analyst/Franzi")
update_script(script_path = "utils/workflow/script_template.R", dataset_name =paste0(studyname, "_INES"), folder_name = "analyst/Ines")
