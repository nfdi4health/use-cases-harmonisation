#### Script for creating mock data

create_mock_data <- function(studyname = NULL,
                             single_dataset = TRUE,
                             vars_second_dataset = NULL){
  
  
  if(single_dataset == FALSE && is.null(vars_second_dataset)){
    stop("You indicated that there is more than 1 dataset from which variables will be included 
         but did not specify the variables in the second dataset!")
  }
  
  library(tidyverse)
  library(readr)
  
  study_variables_all <- tibble(readxl::read_excel(here::here("rmonize/data_dictionary", paste0("DD_",studyname,".xlsx")), sheet = 1))
  study_variables_categorical <- tibble(readxl::read_excel(here::here("rmonize/data_dictionary", paste0("DD_",studyname,".xlsx")), sheet = 2))
  
  study_variables <- study_variables_all |> 
    select(name, valueType)
  
  study_categories <- study_variables_categorical |> 
    select(variable, name)
  
  unique_categories <- unique(study_categories$variable)
  
  #### repeat command
  
  length_variables <- length(unique(study_variables$name))
  length_rows <- 100
  
  dataset_empty <- as.data.frame(matrix(ncol = length_variables, nrow = length_rows))
  colnames(dataset_empty) <- study_variables$name
  
  vars_text <- study_variables |> 
    filter(valueType == "text") |> 
    pull(name) 
  
  vars_integer <- study_variables |> 
    filter(valueType == "integer") |> 
    pull(name)
  
  vars_decimal <- study_variables |> 
    filter(valueType == "decimal") |> 
    pull(name)
  
  vars_categorical <- study_categories |> 
    distinct(variable) |> 
    pull(variable)
  
  dataset <- dataset_empty |> 
    mutate(across(all_of(vars_decimal), ~ rnorm(n = 100, mean = 100, sd = 15))) |> 
    mutate(across(all_of(vars_integer[!(vars_integer %in% vars_categorical)]), ~ as.integer(rnorm(n = 100, mean = 100, sd = 15)))) |> 
    mutate(across(all_of(vars_categorical), ~ 1)) |> 
    mutate(across(all_of(vars_text[tolower(vars_text) %in% "id"]), ~ rep(1:100,1)))
  
  
  for (i in 1:length(unique_categories)){
    
    relevant_categories <- study_categories |> 
      filter(variable == vars_categorical[i]) |> 
      pull(name)
    
    dataset <- dataset |> 
      mutate(across(all_of(vars_categorical[i]), ~ rep(relevant_categories, 50)[1:100]))
    
  }
  
  #### Make 10% of the test dataset NA
  level_na <- 0.1
  dataset <- as.data.frame(lapply(dataset, function(cc) cc[ sample(c(TRUE, NA), prob = c(1-level_na, level_na), size = length(cc), replace = TRUE) ]))
  
  
  #write_csv(dataset, file = here::here("data", paste0("DATA_", studyname, ".csv")),append = FALSE)
  readr::write_delim(x = dataset, 
                     file = here::here("data", paste0("DATA_", studyname, ".csv")),
                     delim = ",",
                     na = "")
  
}  
    
