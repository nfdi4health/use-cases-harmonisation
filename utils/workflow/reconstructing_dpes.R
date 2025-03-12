# Load necessary libraries----
library(dplyr)
library(readxl)
library(writexl)
library(here)

# Define studyname----
studyname = ""

# Load dataschemas P1 and P2 ----
dataschema_p1 <- list(Variables =  tibble::tibble(readxl::read_excel(here::here("rmonize/data_schema/", "Dataschema_P1.xlsx"), sheet = 1)),
                      Categories = tibble::tibble(readxl::read_excel(here::here("rmonize/data_schema/", "Dataschema_P1.xlsx"), sheet = 2)))
dataschema_p2 <- list(Variables =  tibble::tibble(readxl::read_excel(here::here("rmonize/data_schema/", "Dataschema_P2.xlsx"), sheet = 1)),
                      Categories = tibble::tibble(readxl::read_excel(here::here("rmonize/data_schema/", "Dataschema_P2.xlsx"), sheet = 2)))

# 1. Create DPE P1 and DPE P2 ----
## 1.1 Load individual DPEs for Tracy, Ines, Franzi ----
dpe_tracy <- readxl::read_excel(here::here(paste0("analyst/Tracy/rmonize/data_proc_elem/DPE_", studyname, "_TRACY.xlsx")), sheet = 1)
dpe_ines <- readxl::read_excel(here::here(paste0("analyst/Ines/rmonize/data_proc_elem/DPE_", studyname, "_INES.xlsx")), sheet = 1)
dpe_franzi <- readxl::read_excel(here::here(paste0("analyst/Franzi/rmonize/data_proc_elem/DPE_", studyname, "_FRANZI.xlsx")), sheet = 1)

## 1.2 Combine individual DPEs into one ----
combined_dpe <- bind_rows(dpe_tracy, dpe_ines, dpe_franzi)

## 1.3 Create subsets of DPE ----
### 1.3.1 DPE P1 ----
dpe_p1 <- combined_dpe %>%
  filter(dataschema_variable %in% dataschema_p1$Variables$name) %>%
  mutate(index = match(dataschema_variable, dataschema_p1$Variables$name)) %>%
  arrange(index) %>%
  mutate(input_dataset = paste0(studyname,"_P1"))

### 1.3.2 DPE P2 ----
dpe_p2 <- combined_dpe %>%
  filter(dataschema_variable %in% dataschema_p2$Variables$name) %>%
  mutate(index = match(dataschema_variable, dataschema_p2$Variables$name)) %>%
  arrange(index) %>%
  mutate(input_dataset = paste0(studyname, "_P2"))

## 1.4 Export files into respective folders ----
writexl::write_xlsx(dpe_p1, paste0("rmonize/data_proc_elem/DPE_", studyname, "_P1.xlsx"))
writexl::write_xlsx(dpe_p2, paste0("rmonize/data_proc_elem/DPE_", studyname, "_P2.xlsx"))

# 2. Create DD P1 and DD P2 ----
## 2.1 Load individual DDs for Tracy, Ines, Franzi ----
### 2.1.1 Tracy ----
dd_tracy <-list(Variables = tibble::tibble(readxl::read_excel(here::here("analyst/Tracy/rmonize/data_dictionary/", paste0("DD_",studyname, "_TRACY.xlsx")), sheet = 1)),
     Categories = tibble::tibble(readxl::read_excel(here::here("analyst/Tracy/rmonize/data_dictionary/", paste0("DD_",studyname, "_TRACY.xlsx")), sheet = 2)))

dd_tracy$Categories$variable <- as.character(dd_tracy$Categories$variable)
dd_tracy$Categories$name <- as.numeric(dd_tracy$Categories$name)
dd_tracy$Categories$label <- as.character(dd_tracy$Categories$label)

### 2.1.2 Ines ----
dd_ines <-list(Variables = tibble::tibble(readxl::read_excel(here::here("analyst/Ines/rmonize/data_dictionary/", paste0("DD_",studyname, "_INES.xlsx")), sheet = 1)),
                Categories = tibble::tibble(readxl::read_excel(here::here("analyst/Ines/rmonize/data_dictionary/", paste0("DD_",studyname, "_INES.xlsx")), sheet = 2)))

dd_ines$Categories$variable <- as.character(dd_ines$Categories$variable)
dd_ines$Categories$name <- as.numeric(dd_ines$Categories$name)
dd_ines$Categories$label <- as.character(dd_ines$Categories$label)

### 2.1.3 Franzi ----
dd_franzi <-list(Variables = tibble::tibble(readxl::read_excel(here::here("analyst/Franzi/rmonize/data_dictionary/", paste0("DD_",studyname, "_FRANZI.xlsx")), sheet = 1)),
                Categories = tibble::tibble(readxl::read_excel(here::here("analyst/Franzi/rmonize/data_dictionary/", paste0("DD_",studyname, "_FRANZI.xlsx")), sheet = 2)))

dd_franzi$Categories$variable <- as.character(dd_franzi$Categories$variable)
dd_franzi$Categories$name <- as.numeric(dd_franzi$Categories$name)
dd_franzi$Categories$label <- as.character(dd_franzi$Categories$label)

## 2.2 Combine individual DDs into one ----
merged_vars <- dplyr::bind_rows(dd_tracy$Variables, dd_ines$Variables, dd_franzi$Variables) %>%
  dplyr::distinct(name, .keep_all = TRUE)

merged_cat <- dplyr::bind_rows(dd_tracy$Categories, dd_ines$Categories, dd_franzi$Categories) %>%
  dplyr::distinct(variable, label, name, .keep_all = TRUE)

merged_dd <- list(
  Variables = merged_vars,
  Categories = merged_cat
)

## 2.3 Get input_variables from DPE ----
vars_p1 <- dpe_p1$input_variables[!dpe_p1$input_variables %in% c("impossible", "__BLANK__", NA)]
vars_p1 <- unlist(strsplit(vars_p1, ";"))

vars_p2 <- dpe_p2$input_variables[!dpe_p2$input_variables %in% c("impossible", "__BLANK__", NA)]
vars_p2 <- unlist(strsplit(vars_p2, ";"))


### 2.3.1 Manual tests ----
setdiff(vars_p1, merged_dd$Variables$name)
setdiff(vars_p2, merged_dd$Variables$name)
merged_dd$Variables$name[!(merged_dd$Variables$name %in% union(vars_p1, vars_p2))]

## 2.4 Create subsets of DDs ----
dd_p1 <- list(Variables = merged_dd$Variables[merged_dd$Variables$name %in% vars_p1, ],
              Categories = merged_dd$Categories[merged_dd$Categories$variable %in% vars_p1, ])
dd_p1$Variables$index <- seq_len(nrow(dd_p1$Variables))
setdiff(vars_p1, dd_p1$Variables$name)

### HERE I MANUALLY ADD "FR_android" for KARMEN (remove for other studies)
dd_p2 <- list(Variables = merged_dd$Variables[merged_dd$Variables$name %in% vars_p2 | merged_dd$Variables$name == "FR_android" ,],
              Categories = merged_dd$Categories[merged_dd$Categories$variable %in% vars_p2, ])
dd_p2$Variables$index <- seq_len(nrow(dd_p2$Variables))
setdiff(vars_p2, dd_p2$Variables$name)

## 2.5 Export files into respective folders
writexl::write_xlsx(dd_p1, paste0("rmonize/data_dictionary/DD_", studyname, "_P1.xlsx"))
writexl::write_xlsx(dd_p2, paste0("rmonize/data_dictionary/DD_",studyname, "_P2.xlsx"))