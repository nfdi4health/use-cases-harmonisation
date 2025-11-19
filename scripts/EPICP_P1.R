#### Script for harmonizing KORA_S1_P1 for NFDI4Health

#### Installation of Rmonize and its dependent packages (necessary R Version > 3.4)
#### To keep consistency and avoid using renv now, we install the Rmonize package and dependency directly from GitHub
# install.packages("remotes")
# library(remotes)
# remotes::install_github("cran/madshapR@1.1.0")
# remotes::install_github("cran/Rmonize@1.1.0")
# install.packages("readxl")
# install.packages("tidyverse")
# install.packages("here")
# install.packages("car")
# install.packages("writexl")
# install.packages("haven")

#### Load the package in order to conduct
library(Rmonize)
library(readxl)
library(tidyverse)
library(here)
library(car)
library(writexl)
library(haven)

#### all needs to be SAS files!!! => just switch after finish testing

#### Step 0: Name of the study
dataset_name <- "EPICP_P1"

#### Step 1: Import overall DataSchema
dataschema_1 <- tibble::tibble(readxl::read_excel(here::here("rmonize/data_schema/", "Dataschema_P1.xlsx"), sheet = 1))
dataschema_2 <- tibble::tibble(readxl::read_excel(here::here("rmonize/data_schema/", "Dataschema_P1.xlsx"), sheet = 2))

dataschema <- list(Variables = dataschema_1,
                   Categories = dataschema_2)


#### Step 2: Import Datasets 
#### Import check provided in case the csv file is in German style (delim = ";", dec.point = ",")

input_dataset <- haven::read_sas(here::here("data", paste0("DATA_", dataset_name,".sas7bdat")))

#### missing abschlus variable in P1 dataset, can be deleted when dataset is updated
id_matching <- haven::read_sas(here::here("data", paste0("matchtab_p1119_ffqquant_bygroup.sas7bdat")))
dataset_P2 <- haven::read_sas(here::here("data", paste0("DATA_", "EPICP_P2",".sas7bdat"))) |> 
  left_join(id_matching, by = "ident") |> 
  select(id_p1122, abschlus) |> 
  rename(ident = id_p1122)

input_dataset <- input_dataset |> 
  left_join(dataset_P2, by = "ident") |> 
  relocate(abschlus, .after = educc7)

#### Step 2a: Special Import of second data file containing FFQ data

input_dataset_FFQ <- haven::read_sas(here::here("data", paste0("DATA_", dataset_name,"_FFQ.sas7bdat")))


#### Step 2b: Resolve FFQ data
input_dataset_FFQ_Info <- tibble(readxl::read_excel(here::here(paste0("rmonize/data_proc_elem/", dataset_name,"_FFQ_Information.xlsx")), sheet = 1)) 

input_dataset_FFQ_Info <- input_dataset_FFQ_Info |> 
  mutate(across(c("GROUP", "subgroup1", "subgroup2"), ~ ifelse(is.na(.),NA,
                                                               ifelse(nchar(.) == 2, .,paste0("0",.))))) |> 
  rename(subgr1 = subgroup1,
         subgr2 = subgroup2)

filter1 <- input_dataset_FFQ_Info$GROUP
filter2 <- input_dataset_FFQ_Info$subgr1
filter3 <- input_dataset_FFQ_Info$subgr2
name <- input_dataset_FFQ_Info$Name


unique_participants <- unique(input_dataset_FFQ$ident)
ffq_result_study <- data.frame(matrix(ncol = 1, nrow = length(unique_participants)))
colnames(ffq_result_study) <- c("ident")
ffq_result_study$ident <- unique_participants



variable1 <- data.frame()


for (i in 1:length(input_dataset_FFQ_Info$Name)){

  if(is.na(filter2[i])){
    
    variable1 <- input_dataset_FFQ  |> 
      dplyr::filter(GROUP == filter1[i]) |> 
      dplyr::group_by(ident)  |> 
      summarise(variable = sum(cons_qty_fg)) 
    
    variable1[[paste0(name[i])]] <- variable1$variable 
    variable1 <- variable1[c(1,3)]
    
    ffq_result_study <- left_join(ffq_result_study, variable1, by = "ident")
    
  } else if(is.na(filter3[i])){
    
    variable1 <- input_dataset_FFQ  |> 
      dplyr::filter(GROUP == filter1[i],
                    subgr1 == filter2[i]) |> 
      dplyr::group_by(ident)  |> 
      summarise(variable = sum(cons_qty_fg)) 
    
    variable1[[paste0(name[i])]] <- variable1$variable 
    variable1 <- variable1[c(1,3)]
    
    ffq_result_study <- left_join(ffq_result_study, variable1, by = "ident")
    
  } else {
    
    variable1 <- input_dataset_FFQ  |> 
      dplyr::filter(GROUP == filter1[i],
                    subgr1 == filter2[i],
                    subgr2 == filter3[i]) |> 
      dplyr::group_by(ident)  |> 
      summarise(variable = sum(cons_qty_fg)) 
    
    variable1[[paste0(name[i])]] <- variable1$variable 
    variable1 <- variable1[c(1,3)]
    
    ffq_result_study <- left_join(ffq_result_study, variable1, by = "ident")
    
  }
  
  variable1 <- data.frame()
  
}

input_dataset <- dplyr::left_join(input_dataset, ffq_result_study, by = "ident")

maelstrom_id_match <- data.frame(DIFE = input_dataset$ident,
                                 MAEL = 1:length(input_dataset$ident))

input_dataset <- input_dataset |> 
  mutate(ident = row_number())

#### Step 3: Import Data Dictionaries of the study
dd_var <- tibble::tibble(readxl::read_excel(here::here("rmonize/data_dictionary", paste0("DD_",dataset_name, ".xlsx")), sheet = 1))
dd_cat <- tibble::tibble(readxl::read_excel(here::here("rmonize/data_dictionary/", paste0("DD_",dataset_name, ".xlsx")), sheet = 2))

dd <- list(Variables = dd_var,
           Categories = dd_cat)

#### Step 4: Import prepared Data Processing Elements (DPE)
data_proc_elem <- readxl::read_excel(here::here("rmonize/data_proc_elem", paste0("DPE_",dataset_name, ".xlsx")), sheet = 1)

#### Step 5: Combine input datasets and data dictionaries into a dossier
dataset <- madshapR::data_dict_apply(
  dataset = input_dataset,
  data_dict = dd)

dossier <- madshapR::dossier_create(dataset_list = list(
  dataset))

#### Step 6: Create the harmonized dossier using the dossier, overall dataschema and DPE's
harmonized_dossier <- Rmonize::harmo_process(
  dossier, 
  dataschema, 
  data_proc_elem)

#### Step 7: Evaluate and summarize a harmonized dossier containing multiple harmonized datasets
harmonized_dossier_evaluation <- Rmonize::harmonized_dossier_evaluate(harmonized_dossier)
harmonized_dossier_summary <- Rmonize::harmonized_dossier_summarize(harmonized_dossier)
harmonized_dossier_summary[[1]][2,2] <- dataset_name


#### Step 8: Create Reports on the harmonized dossiers; Folder name will include study name, date and time
system_time <- Sys.time()
system_name <- stringr::str_replace_all(string = system_time,
                                        pattern = "[-:]",
                                        replacement = "")
system_name <- stringr::str_replace_all(string = system_name,
                                        pattern = " ",
                                        replacement = "_")
system_name <- stringr::str_split(string = system_name,pattern = "[.]")[[1]][1]

bookdown_path <- here::here("output/rmonize_report/", paste0(dataset_name, "_", system_name))
Rmonize::harmonized_dossier_visualize(harmonized_dossier, 
                                      bookdown_path,
                                      harmonized_dossier_summary = harmonized_dossier_summary)

ifelse(!dir.exists(file.path(here::here("output/rmonize_summary/"))), dir.create(file.path(here::here("output/rmonize_summary/"))), FALSE)
ifelse(!dir.exists(file.path(here::here("output/opal_dd/"))), dir.create(file.path(here::here("output/opal_dd/"))), FALSE)


dir.create(here::here("output/rmonize_summary/", paste0(dataset_name, "_", system_name)))
file.copy(here::here("output/rmonize_report/", paste0(dataset_name, "_", system_name, "/docs")), 
          here::here("output/rmonize_summary/", paste0(dataset_name, "_", system_name)),  recursive=TRUE)

dir.create(here::here("output/opal_dd/", paste0(dataset_name, "_", system_name)))
opal_dd <- dataschema
opal_dd$Variables$table <- dataset_name
opal_dd$Categories$table <- dataset_name
opal_dd$Variables <- opal_dd$Variables[c(1,5,2:4)]
opal_dd$Categories <- opal_dd$Categories[c(4,1:3)]

writexl::write_xlsx(opal_dd, here::here("output/opal_dd/", paste0(dataset_name, "_", system_name, "/", dataset_name, "_DD.xlsx")))


# Open the visual report in a browser.
fabR::bookdown_open(bookdown_path)

#### Step 9: Extract and save harmonized data into a pre-set folder
harmonized_dataset <- Rmonize::pooled_harmonized_dataset_create(harmonized_dossier)
harmonized_dataset <- left_join(harmonized_dataset, maelstrom_id_match, by = c("ID" = "MAEL")) |> 
  select(-ID) |> 
  mutate(ID = DIFE) |> 
  select(-DIFE) |> 
  relocate(ID, .before = SEX)

ifelse(!dir.exists(file.path(here::here("output/harmonised_dataset/", paste0(dataset_name, "_", system_name)))),dir.create(here::here("output/harmonised_dataset/", paste0(dataset_name, "_", system_name))), FALSE)

readr::write_delim(x = harmonized_dataset, 
                   file = here::here(paste0("output/harmonised_dataset/", dataset_name, "_", system_name, "/", dataset_name,"_harmonized.csv")),
                   delim = ",",
                   na = "")

