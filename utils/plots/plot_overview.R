
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

## Across Pilot-Project


plot <- data_for_plot |> 
  select(c(dataschema_variable, group, KORA_S1, KORA_S3, GINI, LISA, KARMEN)) |> 
  pivot_longer(!(c(dataschema_variable, group)), names_to = "Study", values_to = "Status") |> 
  mutate(Study = factor(Study, levels = c("KORA_S1",
                                          "KORA_S3",
                                          "GINI",
                                          "LISA",
                                          "KARMEN"))) |> 
  mutate(Status = factor(Status, levels = c("impossible",
                                            "partial",
                                            "complete"))) |>
  group_by(Study, Status) |> 
  summarise(Variables = n()) |> 
  ggplot(aes(fill = Status, x = Study, y = Variables)) +
  geom_bar(position = "stack", stat = "identity", colour = "black") +
  scale_fill_paletteer_d("MexBrewer::Aurora") +
  labs(title = "Harmonisation Potential across studies") +
  theme_classic() +
  theme(axis.text.x=element_text(colour="black"),
        axis.text.y=element_text(colour="black"),
        axis.title=element_text(size=12,face="bold"),
        axis.ticks.x=element_line(colour="black"),
        axis.ticks.y=element_line(colour="black"),
        plot.title = element_text(color="black", size=18, face="bold.italic", hjust = 0.5))

plot


#### Step 4: Save figures in a folder

ggsave(filename = here::here("utils/plots/figures", "Harmonisation_Overview.png"))


my_colors <- paletteer::paletteer_d("PrettyCols::Beach")
print(my_colors)
