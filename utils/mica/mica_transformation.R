
library(tidyverse)

dataset_name <- list.files(here::here("scripts"))

for(i in 1:length(dataset_name)){
  
  
  #### Part 1: DPE
  
  datasets_variables <- as_tibble(dataset_name[i]) |> 
    mutate(value = stringr::str_split_i(string = value,
                                        pattern = "\\.R",
                                        i = 1)) |> 
    rowwise() |> 
    mutate(dpe = list(readxl::read_excel(here::here("rmonize/data_proc_elem/", paste0("DPE_", value ,".xlsx")), sheet = 1))) |> 
    ungroup() |> 
    unnest(cols = c(dpe)) |> 
    rename(table = value,
           name = dataschema_variable,
           "Mlstr_harmo::dataschema_variable" = input_variables) |> 
    relocate(index) |> 
    mutate(unit = stringr::str_squish(string = stringr::str_remove(string = stringr::str_split_i(string = label,
                                                                                                 pattern = "\\[",
                                                                                                 i = 2),
                                                                   pattern = "\\]"))) |> 
    relocate(unit, .before = valueType) |> 
    select(-input_dataset) |> 
    mutate(across(everything(), ~ifelse(is.na(.), "", .)))
  
  
  
  
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
    rename(table = value) 
  
  
  
  dataschema <- list(Variables = datasets_variables,
                     Categories = datasets_categories)
  
  
  writexl::write_xlsx(dataschema, here::here("mica/dpe/", paste0(stringr::str_split_i(string = dataset_name[i],
                                                                                  pattern = "\\.R",
                                                                                  i = 1), 
                                                             ".xlsx")))
  
  
  
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
  
  
  writexl::write_xlsx(dd, here::here("mica/dd/", paste0("DD_", 
                                                        stringr::str_split_i(string = dataset_name[i],
                                                                             pattern = "\\.R",
                                                                             i = 1), 
                                                        ".xlsx")))
  
  
}


pilot_project <- c("P1", "P2")

for (i in 1:length(pilot_project)){
  
  
  dataschema_harmonization_variable <- as_tibble(readxl::read_excel(here::here("rmonize/data_schema/", paste0("Dataschema_", pilot_project[i],".xlsx")), sheet = 1)) |> 
    mutate(unit = stringr::str_squish(string = stringr::str_remove(string = stringr::str_split_i(string = label,
                                                                                                 pattern = "\\[",
                                                                                                 i = 2),
                                                                   pattern = "\\]"))) |> 
    mutate(across(everything(), ~ifelse(is.na(.), "", .))) |> 
    relocate(unit, .before = valueType) |> 
    mutate(table = "Harmonization") |> 
    relocate(table, .before = name)
  
  
  
  dataschema_harmonization_category <- as_tibble(readxl::read_excel(here::here("rmonize/data_schema/", paste0("Dataschema_", pilot_project[i],".xlsx")), sheet = 2)) |> 
    mutate(across(everything(), ~ifelse(is.na(.), "", .))) |> 
    mutate(table = "Harmonization") |> 
    relocate(table, .before = variable)
  
  
  
  dataschema <- list(Variables = dataschema_harmonization_variable,
                     Categories = dataschema_harmonization_category)
  
  
  writexl::write_xlsx(dataschema, here::here("mica/ds/", paste0("Dataschema_", pilot_project[i], ".xlsx")))
  
}
