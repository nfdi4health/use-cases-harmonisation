#### This function creates csv files from Excel files in order to have better overview of changes
#### since Excel (binary) files cannot be used for git-diff
#### DPE's will only have 1 csv file, DataSchema and DataDictionary 1 csv each for Variables and Categories (also named as such)

create_comparable_files <- function(folder_to_update = "rmonize"){

  library(readxl)
  library(tidyverse)
  
  
  if(folder_to_update == "rmonize") {
    
    
    #### distinction between DD, DPE and DataSchema necessary here
    #### DataSchema
    list_dataschema_files_rmonize <- list.files(path = here::here("rmonize","data_schema"))
    
    for(i in 1:length(list_dataschema_files_rmonize)){
      
      name_file <- list_dataschema_files_rmonize[i]
      
      name_dataschema <- stringr::str_split(string = name_file,
                                            pattern = "[.]")[[1]][1]
      
      dataschema_1 <- tibble::tibble(readxl::read_excel(here::here("rmonize/data_schema/", list_dataschema_files_rmonize[i]), sheet = 1))
      dataschema_2 <- tibble::tibble(readxl::read_excel(here::here("rmonize/data_schema/", list_dataschema_files_rmonize[i]), sheet = 2))
      
      readr::write_delim(x = dataschema_1,
                         file = here::here("utils/compare_binary/rmonize/data_schema", paste0(name_dataschema,"_Variables.csv")),
                         delim = ";",
                         na = "")
      readr::write_delim(x = dataschema_2,
                         file = here::here("utils/compare_binary/rmonize/data_schema", paste0(name_dataschema,"_Categories.csv")),
                         delim = ";",
                         na = "")
    }
    
    
    #### Data Dictionaries
    list_datadictionary_files_rmonize <- list.files(path = here::here("rmonize","data_dictionary"))
    
    for(i in 1:length(list_datadictionary_files_rmonize)){
      
      name_file <- list_datadictionary_files_rmonize[i]
      
      name_datadictionary <- stringr::str_split(string = name_file,
                                                pattern = "[.]")[[1]][1]
      
      datadictionary_1 <- tibble::tibble(readxl::read_excel(here::here("rmonize/data_dictionary/", list_datadictionary_files_rmonize[i]), sheet = 1))
      datadictionary_2 <- tibble::tibble(readxl::read_excel(here::here("rmonize/data_dictionary/", list_datadictionary_files_rmonize[i]), sheet = 2))
      
      readr::write_delim(x = datadictionary_1,
                         file = here::here("utils/compare_binary/rmonize/data_dictionary", paste0(name_datadictionary,"_Variables.csv")),
                         delim = ";",
                         na = "")
      readr::write_delim(x = datadictionary_2,
                         file = here::here("utils/compare_binary/rmonize/data_dictionary", paste0(name_datadictionary,"_Categories.csv")),
                         delim = ";",
                         na = "")
    }
    
    
    
    #### DPE
    list_data_proc_elem_files_rmonize <- list.files(path = here::here("rmonize","data_proc_elem"))
    
    for(i in 1:length(list_data_proc_elem_files_rmonize)){
      
      name_file <- list_data_proc_elem_files_rmonize[i]
      
      name_data_proc_elem <- stringr::str_split(string = name_file,
                                                pattern = "[.]")[[1]][1]
      
      data_proc_elem <- tibble::tibble(readxl::read_excel(here::here("rmonize/data_proc_elem/", list_data_proc_elem_files_rmonize[i]), sheet = 1))
      
      readr::write_delim(x = data_proc_elem,
                         file = here::here("utils/compare_binary/rmonize/data_proc_elem", paste0(name_data_proc_elem,".csv")),
                         delim = ";",
                         na = "")
      
    }
    
  }
  
  
  
  
  
  if(folder_to_update == "analyst") {
    
    
    
    analysts <- c("Franzi",
                  "Ines",
                  "Tracy")
    
    
    
    for (j in 1:length(analysts)){
      
      
      
      
      #### DataSchema
      list_dataschema_files_rmonize <- list.files(path = here::here(paste0("analyst/",analysts[j],"/rmonize"),"data_schema"))
      
      for(i in 1:length(list_dataschema_files_rmonize)){
        
        name_file <- list_dataschema_files_rmonize[i]
        
        name_dataschema <- stringr::str_split(string = name_file,
                                              pattern = "[.]")[[1]][1]
        
        dataschema_1 <- tibble::tibble(readxl::read_excel(here::here(paste0("analyst/",analysts[j],"/rmonize/data_schema/"), list_dataschema_files_rmonize[i]), sheet = 1))
        dataschema_2 <- tibble::tibble(readxl::read_excel(here::here(paste0("analyst/",analysts[j],"/rmonize/data_schema/"), list_dataschema_files_rmonize[i]), sheet = 2))
        
        readr::write_delim(x = dataschema_1,
                           file = here::here(paste0("utils/compare_binary/analyst/", analysts[j],"/rmonize/data_schema"), paste0(name_dataschema,"_Variables.csv")),
                           delim = ";",
                           na = "")
        readr::write_delim(x = dataschema_2,
                           file = here::here("utils/compare_binary/analyst/", analysts[j],"/rmonize/data_schema", paste0(name_dataschema,"_Categories.csv")),
                           delim = ";",
                           na = "")
      }
      
      
      #### Data Dictionaries
      list_datadictionary_files_rmonize <- list.files(path = here::here(paste0("analyst/",analysts[j],"/rmonize"),"data_dictionary"))
      
      for(i in 1:length(list_datadictionary_files_rmonize)){
        
        name_file <- list_datadictionary_files_rmonize[i]
        
        name_datadictionary <- stringr::str_split(string = name_file,
                                                  pattern = "[.]")[[1]][1]
        
        datadictionary_1 <- tibble::tibble(readxl::read_excel(here::here(paste0("analyst/",analysts[j],"/rmonize/data_dictionary/"), list_datadictionary_files_rmonize[i]), sheet = 1))
        datadictionary_2 <- tibble::tibble(readxl::read_excel(here::here(paste0("analyst/",analysts[j],"/rmonize/data_dictionary/"), list_datadictionary_files_rmonize[i]), sheet = 2))
        
        readr::write_delim(x = datadictionary_1,
                           file = here::here("utils/compare_binary/analyst/", analysts[j],"/rmonize/data_dictionary", paste0(name_datadictionary,"_Variables.csv")),
                           delim = ";",
                           na = "")
        readr::write_delim(x = datadictionary_2,
                           file = here::here("utils/compare_binary/analyst/", analysts[j],"/rmonize/data_dictionary", paste0(name_datadictionary,"_Categories.csv")),
                           delim = ";",
                           na = "")
      }
      
      
      
      #### DPE
      list_data_proc_elem_files_rmonize <- list.files(path = here::here(paste0("analyst/",analysts[j],"/rmonize"),"data_proc_elem"))
      
      for(i in 1:length(list_data_proc_elem_files_rmonize)){
        
        name_file <- list_data_proc_elem_files_rmonize[i]
        
        name_data_proc_elem <- stringr::str_split(string = name_file,
                                                  pattern = "[.]")[[1]][1]
        
        data_proc_elem <- tibble::tibble(readxl::read_excel(here::here(paste0("analyst/",analysts[j],"/rmonize/data_proc_elem/"), list_data_proc_elem_files_rmonize[i]), sheet = 1))
        
        readr::write_delim(x = data_proc_elem,
                           file = here::here("utils/compare_binary/analyst/", analysts[j],"/rmonize/data_proc_elem", paste0(name_data_proc_elem,".csv")),
                           delim = ";",
                           na = "")
        
      }
      
      
    }
    
    
  }

}
