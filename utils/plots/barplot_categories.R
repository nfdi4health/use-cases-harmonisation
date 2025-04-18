
library(tidyverse)
library(readxl)
library(paletteer)


plot_studies <- c("KORA",
                  "GINI", 
                  "LISA", 
                  "KARMEN")

pilot_project <- c("P1", "P2")

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
variable_groups <- readxl::read_excel(here::here("utils/plots/", "Variable_Groups.xlsx"), sheet = 1) |> 
  select(-c("label"))
colnames(variable_groups) <- c("dataschema_variable", "group")

data_for_plot <- left_join(comparison_object, variable_groups, by = "dataschema_variable")

#### Correcting Mistakes in the DPE's
data_for_plot <- within(data_for_plot, KARMEN[KARMEN == "compatible"] <- "complete") 
data_for_plot <- within(data_for_plot, KORA_S1[KORA_S1 == "proximate"] <- "partial") 
data_for_plot <- within(data_for_plot, KORA_S3[KORA_S3 == "proximate"] <- "partial") 


## Across variable domain
data_for_plot <- data_for_plot |> 
  filter(dataschema_variable != "ID") |> 
  mutate(Score = (case_when(GINI == "impossible" ~ 0,
                            GINI == "partial" ~ 0.5,
                            GINI == "complete" ~ 1) +
                    case_when(LISA == "impossible" ~ 0,
                              LISA == "partial" ~ 0.5,
                              LISA == "complete" ~ 1) + 
                    case_when(KORA_S1 == "impossible" ~ 0,
                              KORA_S1 == "partial" ~ 0.5,
                              KORA_S1 == "complete" ~ 1) + 
                    case_when(KORA_S3 == "impossible" ~ 0,
                              KORA_S3 == "partial" ~ 0.5,
                              KORA_S3 == "complete" ~ 1) + 
                    case_when(KARMEN == "impossible" ~ 0,
                              KARMEN == "partial" ~ 0.5,
                              KARMEN == "complete" ~ 1)) / 5)



#### documentation 
plot <- data_for_plot |> 
  filter(dataschema_variable != "ID") |> 
  filter(group == "reproduction") |> 
  select(c("dataschema_variable", "GINI", "LISA", "KORA_S1", "KORA_S3", "KARMEN")) |> 
  pivot_longer(!(c(dataschema_variable)), names_to = "Study", values_to = "Status") |> 
  mutate(Study = factor(Study, levels = c("KORA_S1",
                                          "KORA_S3",
                                          "GINI",
                                          "LISA",
                                          "KARMEN"))) |> 
  mutate(Status = factor(Status, levels = c("complete",
                                            "partial",
                                            "impossible"))) |> 
  group_by(Study) |> 
  ggplot(aes(fill = Status, x = Study, y = dataschema_variable)) +
  geom_bar(position = "stack", stat = "identity") + 
  scale_fill_manual(values = c("green", "red")) +
  ylab("Variables") +
  xlab("Study") +
  theme(axis.ticks.y = element_blank(),
        axis.text.y = element_blank())


plot


ggsave(filename = here::here("utils/plots/figures", "reproduction.png"))
