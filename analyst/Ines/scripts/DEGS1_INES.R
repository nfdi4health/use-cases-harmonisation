#### Script for harmonizing data for NFDI4Health

####Installation of Rmonize and its dependent packages (necessary R Version > 3.4)
# install.packages("Rmonize")
# install.packages("readxl")
# install.packages("tidyverse")
# install.packages("here")
# install.packages("car")
# install.packages("writexl")

#### Load the package in order to conduct
library(Rmonize)
library(readxl)
library(tidyverse)
library(here)
library(car)
library(writexl)


#### Step 0: Name of the study and creation of mock data
dataset_name <- 'DEGS1_INES'
folder_name <- 'analyst/Ines'

source(here::here("utils/create_mock_data", "mock_data_function.R"))
create_mock_data(studyname = dataset_name, folder_name = folder_name)

#### Step 1: Import overall DataSchema
dataschema_1 <- tibble::tibble(readxl::read_excel(here::here(paste0(folder_name, "/rmonize/data_schema/", paste0("Dataschema_", toupper(strsplit(folder_name, "/")[[1]][2]), ".xlsx"))), sheet = 1))
dataschema_2 <- tibble::tibble(readxl::read_excel(here::here(paste0(folder_name, "/rmonize/data_schema/", paste0("Dataschema_", toupper(strsplit(folder_name, "/")[[1]][2]), ".xlsx"))), sheet = 2))

dataschema <- list(Variables = dataschema_1,
                   Categories = dataschema_2)

#### Step 2: Import Datasets 
#### Import check provided in case the csv file is in German style (delim = ";", dec.point = ",")

input_dataset <- readr::read_csv(here::here(paste0(folder_name, "/data/", paste0("DATA_", dataset_name, ".csv"))))

if(dim(input_dataset)[2] == 1){
  input_dataset <- read.csv(here::here(paste0(folder_name, "/data", paste0("DATA_", dataset_name, ".csv"))), sep = ";", dec = ",")
}

#### Step 3: Import Data Dictionaries of the study
dd_var <- tibble::tibble(readxl::read_excel(here::here(paste0(folder_name, "/rmonize/data_dictionary/"), paste0("DD_",dataset_name, ".xlsx")), sheet = 1))
dd_cat <- tibble::tibble(readxl::read_excel(here::here(paste0(folder_name,"/rmonize/data_dictionary/"), paste0("DD_",dataset_name, ".xlsx")), sheet = 2))

dd <- list(Variables = dd_var,
           Categories = dd_cat)

#### Step 4: Import prepared Data Processing Elements (DPE)
data_proc_elem <- readxl::read_excel(here::here(paste0(folder_name, "/rmonize/data_proc_elem"), paste0("DPE_",dataset_name, ".xlsx")), sheet = 1)

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

#### Step 9: Extract and save harmonized data into a pre-set folder
harmonized_dataset <- Rmonize::pooled_harmonized_dataset_create(harmonized_dossier)


