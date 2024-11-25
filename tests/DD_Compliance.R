

#### Quick Tests for DataDictionary

studyname <- "GINI_P2"

study_variables_all <- tibble(readxl::read_excel(here::here("rmonize/data_dictionary", paste0("DD_",studyname,".xlsx")), sheet = 1))
study_variables_categorical <- tibble(readxl::read_excel(here::here("rmonize/data_dictionary", paste0("DD_",studyname,".xlsx")), sheet = 2))


#### Testing which variable name is ducplicated in the "Variables" Sheet
duplicates_variables <- study_variables_all[which(duplicated(study_variables_all$name)),]

#### Testing what categorical variable is only listed in "Categories" and not "Variables" Sheet
cat_vars_missing_in_variables <- unique(study_variables_categorical$variable[which(!(study_variables_categorical$variable %in% study_variables_all$name))])

