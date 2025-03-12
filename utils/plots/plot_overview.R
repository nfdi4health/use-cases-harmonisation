
library(tidyverse)
library(readxl)


plot_studies <- c("KORA",
                  "GINI", 
                  "LISA", 
                  "KARMEN")

pilot_project <- c("P1")

#### Step 1: Identify DPE's of interest

existing_files <- data.frame(list.files(path = here::here("rmonize", "data_proc_elem")))
colnames(existing_files) <- "files"
wanted_files <- existing_files |> 
  filter(str_detect(files, paste(plot_studies, collapse = "|"))) |> 
  filter(str_detect(files, paste(pilot_project, collapse = "|")))
  
#### Step 2: Create data.frame for ggplot

temp_df <- data.frame()
df_list <- list()

for (i in 1:length(wanted_files$files)){
  
  temp_df <- readxl::read_excel(here::here("rmonize/data_proc_elem/", paste0(wanted_files[i,])), sheet = 1)
  temp_df <- temp_df[,c(2,10)]
  name <- stringr::str_replace_all(string = wanted_files[i,],
                                   pattern = "DPE_",
                                   replacement = "")
  
  if(length(pilot_project) == 2){
    
    name <- stringr::str_replace_all(string = name,
                                     pattern = ".xlsx",
                                     replacement = "")
    
  } else if(pilot_project == "P1"){
    
    name <- stringr::str_replace_all(string = name,
                                     pattern = "_P1.xlsx",
                                     replacement = "")
    
  } else if(pilot_project == "P2"){
    
    name <- stringr::str_replace_all(string = name,
                                     pattern = "_P2.xlsx",
                                     replacement = "")
    
  }
  
  colnames(temp_df) <- c("dataschema_variable", name)
  df_list[[i]] <- temp_df
  
}

comparison_object <- purrr::reduce(df_list, full_join, by = "dataschema_variable")

if(length(pilot_project) == 2){
  
  comparison_object$GINI <- comparison_object$GINI_P1
  comparison_object$LISA <- comparison_object$LISA_P1
  comparison_object$KORA_S1 <- comparison_object$KORA_S1_P1
  comparison_object$KORA_S3 <- comparison_object$KORA_S3_P1
  comparison_object$KARMEN <- comparison_object$KARMEN_P1
  
  
  for (k in 1:length(comparison_object$dataschema_variable)){
    
    if(is.na(comparison_object$GINI[k])){
      comparison_object$GINI[k] <- comparison_object$GINI_P2[k]
    }
    
    if(is.na(comparison_object$LISA[k])){
      comparison_object$LISA[k] <- comparison_object$LISA_P2[k]
    }
    
    if(is.na(comparison_object$KORA_S1[k])){
      comparison_object$KORA_S1[k] <- comparison_object$KORA_S1_P2[k]
    }
    
    if(is.na(comparison_object$KORA_S3[k])){
      comparison_object$KORA_S3[k] <- comparison_object$KORA_S3_P2[k]
    }
    
    if(is.na(comparison_object$KARMEN[k])){
      comparison_object$KARMEN[k] <- comparison_object$KARMEN_P2[k]
    }
    
  }
  
  
  comparison_object <- comparison_object[,c(1,12:16)]
  
}

## Clean-Up
rm(df_list,
   temp_df,
   existing_files,
   wanted_files,
   i,
   k,
   name,
   pilot_project,
   plot_studies)

#### Step 3: Create ggplot figures
variable_groups <- readxl::read_excel(here::here("utils/plots/", "Variable_Groups.xlsx"), sheet = 1)

data_for_plot <- left_join(comparison_object, variable_groups, by = c("dataschema_variable = name"))

## Across Pilot-Project
data_for_plot |> 
  pivot_longer(!dataschema_variable, names_to = "Study", values_to = "Status") |> 
  group_by(Study, Status) |> 
  summarise(Variables = n()) |> 
  ggplot(aes(fill = Status, x = Study, y = Variables)) +
  geom_bar(position = "stack", stat = "identity")

## Across variable domain




#### Step 4: Save figures in a folder
