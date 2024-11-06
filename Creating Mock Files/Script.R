#### Script for creating mock data

library(tidyverse)

study_variables_all <- tibble(readxl::read_excel(here::here("Rmonize Files/DataDictionary", "DD_KORA_S1_P1.xlsx"), sheet = 1))
study_variables_categorical <- tibble(readxl::read_excel(here::here("Rmonize Files/DataDictionary", "DD_KORA_S1_P1.xlsx"), sheet = 2))

study_variables <- study_variables_all |> 
  select(name, valueType)

study_categories <- study_variables_categorical |> 
  select(variable, name)

#### repeat command