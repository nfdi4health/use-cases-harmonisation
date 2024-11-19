#### Script for harmonizing KORA_S1_P1 for NFDI4Health

####Installation of Rmonize and its dependent packages (necessary R Version > 3.4)
# install.packages("Rmonize")
# install.packages("readxl")
# install.packages("tidyverse")
# install.packages("here")
# install.packages("car")

#### Load the package in order to conduct
library(Rmonize)
library(readxl)
library(tidyverse)
library(here)
library(car)

dataset_name <- "KORA_S1_P1"

#### Step 1: Import overall DataSchema (need to update path)
dataschema_1 <- tibble(readxl::read_excel(here::here("rmonize/data_schema/", "Dataschema_P1.xlsx"), sheet = 1))
dataschema_2 <- tibble(readxl::read_excel(here::here("rmonize/data_schema/", "Dataschema_P1.xlsx"), sheet = 2))

dataschema <- list(Variables = dataschema_1,
                   Categories = dataschema_2)

#### Step 2: Import Datasets (need to update path)
input_dataset <- read_csv(here::here("data", paste0("DATA_", dataset_name, ".csv")))

#### Step 3: Import Data Dictionaries of the study (need to update path)
dd_var <- tibble(readxl::read_excel(here::here("rmonize/data_dictionary", paste0("DD_",dataset_name, ".xlsx")), sheet = 1))
dd_cat <- tibble(readxl::read_excel(here::here("rmonize/data_dictionary/", paste0("DD_",dataset_name, ".xlsx")), sheet = 2))

dd <- list(Variables = dd_var,
           Categories = dd_cat)

#### Step 4: Import prepared Data Processing Elements (DPE)
data_proc_elem <- readxl::read_excel(here::here("rmonize/data_proc_elem", paste0("DPE_",dataset_name, ".xlsx")), sheet = 1)

#### Step 5: Combine input datasets and data dictionaries in a dossier
dataset <- data_dict_apply(
  dataset = input_dataset,
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
# must not previously exist. include with paste0 the datetime of report and study name


bookdown_path <- here::here("output/rmonize_report/", paste0(dataset_name, "_", Sys.Date()))
dir.create(bookdown_path)
bookdown_path <- dir.create(here::here("output/rmonize_report/", paste0(dataset_name, "_", Sys.Date())))

harmonized_dossier_visualize(harmonized_dossier, bookdown_path)

# Open the visual report in a browser.
bookdown_open(bookdown_path)

#### Step 8: Extract and save harmonized data into a pre-set folder


# Extracting the harmonized dataset
harmonized_dataset <- pooled_harmonized_dataset_create(harmonized_dossier)

# Saving the data as a csv file for upload into Opal/DataSHIELD
write.csv(harmonized_dataset, file = here::here(paste0("output/harmonised_dataset/", dataset_name, "_harmonized.csv")))
