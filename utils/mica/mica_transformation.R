
library(tidyverse)

dataset_name <- list.files(here::here("scripts"))

for(i in 1:length(dataset_name)){
  
  
  #### part 1: the combined dataschema + dpe file
  
  
  datasets_variables <- as_tibble(dataset_name[i]) |> 
    mutate(value = stringr::str_split_i(string = value,
                                        pattern = "\\.R",
                                        i = 1)) |> 
    mutate(Project1 = stringr::str_detect(string = value,
                                          pattern = "_P1")) |> 
    mutate(dataschema = case_when(Project1 == TRUE ~ list(readxl::read_excel(here::here("rmonize/data_schema/", "Dataschema_P1.xlsx"), sheet = 1)),
                                  Project1 == FALSE ~ list(readxl::read_excel(here::here("rmonize/data_schema/", "Dataschema_P2.xlsx"), sheet = 1)))) |>
    select(-Project1) |> 
    rowwise() |> 
    mutate(dpe = list(readxl::read_excel(here::here("rmonize/data_proc_elem/", paste0("DPE_", value ,".xlsx")), sheet = 1))) |> 
    ungroup() |> 
    unnest(cols = c(dataschema, dpe), names_sep = "_") |> 
    rename(table = value,
           index = dataschema_index,
           valueType = dataschema_valueType,
           label = dataschema_label,
           name = dataschema_name) |> 
    select(-c(dpe_index,
              dpe_dataschema_variable,
              dpe_label,
              dpe_valueType)) |> 
    mutate(entityType = "Participant",
           referencedEntityType = "",
           mimeType = "",
           repeatable = "0",
           occurrenceGroup = "") |> 
    mutate(unit = stringr::str_squish(string = stringr::str_remove(string = stringr::str_split_i(string = label,
                                                                                                 pattern = "\\[",
                                                                                                 i = 2),
                                                                   pattern = "\\]"))) |> 
    mutate(across(everything(), ~ifelse(is.na(.), "", .))) |> 
    rename_with(.cols = all_of(starts_with("dpe_")), .fn = ~ stringr::str_replace(string = .x,
                                                                                  pattern = "dpe_",
                                                                                  replacement = "")) |> 
    mutate(input_dataset = stringr::str_split_i(string = input_dataset,
                                                pattern = "_",
                                                i = 1)) |> 
    rename("Mlstr_harmo::dataschema_variable" = input_variables,
           "Mlstr_harmo::dataschema_table" = input_dataset)
  
  
  
  
  
  
  datasets_categories <- as_tibble(dataset_name[i]) |> 
    mutate(value = stringr::str_split_i(string = value,
                                        pattern = "\\.R",
                                        i = 1)) |> 
    mutate(Project1 = stringr::str_detect(string = value,
                                          pattern = "_P1")) |> 
    mutate(dataschema = case_when(Project1 == TRUE ~ list(readxl::read_excel(here::here("rmonize/data_schema/", "Dataschema_P1.xlsx"), sheet = 2)),
                                  Project1 == FALSE ~ list(readxl::read_excel(here::here("rmonize/data_schema/", "Dataschema_P2.xlsx"), sheet = 2)))) |> 
    select(-Project1) |> 
    unnest(cols = c(dataschema)) |> 
    rename(table = value) |> 
    mutate(missing = "0") |> #### this feels wrong !!!, 0 could mean FALSE, and we have in RKI and NAKO datasets missing = TRUE !!!
    mutate(code = "")
  
  
  
  dataschema <- list(Variables = datasets_variables,
                     Categories = datasets_categories)
  
  
  writexl::write_xlsx(dataschema, here::here("mica/", paste0("NFDI4Health.", dataset_name[i], "-dictionary.xlsx")))
  
  
  
  #### Part 2: the DD files
  
  dd_variables <- as_tibble(dataset_name[i]) |> 
    mutate(value = stringr::str_split_i(string = value,
                                        pattern = "\\.R",
                                        i = 1)) |> 
    mutate(dd = list(readxl::read_excel(here::here("rmonize/data_dictionary/", paste0("DD_", value ,".xlsx")), sheet = 1))) |> 
    unnest(cols = c(dd)) |> 
    rename(table = value) |> 
    relocate(index)
    
  
  dd_categories <- as_tibble(dataset_name[i]) |> 
    mutate(value = stringr::str_split_i(string = value,
                                        pattern = "\\.R",
                                        i = 1)) |> 
    mutate(dd = list(readxl::read_excel(here::here("rmonize/data_dictionary/", paste0("DD_", value ,".xlsx")), sheet = 2))) |> 
    unnest(cols = c(dd)) |> 
    rename(table = value) 
   
  
  dd <- list(Variables = dd_variables,
                     Categories = dd_categories)
  
  
  writexl::write_xlsx(dd, here::here("mica/", paste0("DD_", dataset_name[i], "_1.xlsx")))
  
  
  
  
  
  
  
}
