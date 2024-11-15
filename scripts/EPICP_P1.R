#### Script for harmonizing KORA_S1_P1 for NFDI4Health

#### Installation of Rmonize and its dependent packages (necessary R Version > 3.4)
# install.packages("Rmonize")
# install.packages("readxl")
# install.packages("tidyverse")
# install.packages("here")

#### Load the package in order to conduct
library(Rmonize)
library(readxl)
library(tidyverse)
library(here)

#### Step 1: Import overall DataSchema (need to update path)
dataschema_1 <- tibble(readxl::read_excel(here::here("rmonize/data_schema/", "Dataschema_P1.xlsx"), sheet = 1))
dataschema_2 <- tibble(readxl::read_excel(here::here("rmonize/data_schema/", "Dataschema_P1.xlsx"), sheet = 2))

dataschema <- list(Variables = dataschema_1,
                   Categories = dataschema_2)

#### Step 2: Import Datasets (need to update path)
EPICP_P1 <- read.csv(here::here("data", "DATA_EPICP_P1.csv"), sep = ";", dec = ",")

EPICP_P1_FFQ <- read.csv(here::here("data", "DATA_EPICP_P1_FFQ.csv"), sep = ";", dec = ",")


EPICP_P1_FFQ_condensed <- EPICP_P1_FFQ |> 
  filter(GROUP == 2) |> 
  group_by(id) |> 
  summarise(VEGETABLES_02 = sum(quant_grp17))



EPICP_P1 <- dplyr::left_join(EPICP_P1, ffq_condensed_Epic, by = "id")


#### Step 3: Import Data Dictionaries of the study (need to update path)
dd_var <- tibble(readxl::read_excel(here::here("rmonize/data_dictionary", "DD_EPICP_P1.xlsx"), sheet = 1))
dd_cat <- tibble(readxl::read_excel(here::here("rmonize/data_dictionary", "DD_EPICP_P1.xlsx"), sheet = 2))

dd <- list(Variables = dd_var,
               Categories = dd_cat)

#### Step 4: Import prepared Data Processing Elements (DPE)
data_proc_elem <- readxl::read_excel(here::here("rmonize/data_proc_elem", "DPE_EPICP_P1.xlsx"), sheet = 1)

#### Step 5: Combine input datasets and data dictionaries in a dossier
dataset <- data_dict_apply(
  dataset = EPICP_P1,
  data_dict = dd)

dossier <- dossier_create(dataset_list = list(
  dataset))

#### Step 6: Create the harmonized dossier using the dossier, overall dataschema and DPE's
harmonized_dossier <- harmo_process(
  dossier, 
  dataschema, 
  data_proc_elem)

#### Step 7: Create Reports on the harmonized dossiers

# Evaluate and summarize a harmonized dossier containing multiple harmonized datasets.

harmonized_dossier_evaluation <- harmonized_dossier_evaluate(harmonized_dossier)
harmonized_dossier_summary <- harmonized_dossier_summarize(harmonized_dossier)

# place your harmonized dossier in a folder. This folder name is mandatory, and 
# must not previously exist.

bookdown_path_FFQ <- paste0('temp/',basename(tempdir()))
harmonized_dossier_visualize(harmonized_dossier_FFQ, bookdown_path)

# Open the visual report in a browser.
bookdown_open(bookdown_path_FFQ)
