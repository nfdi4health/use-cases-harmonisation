library(dplyr)
library(here)
library(readxl)

studyname = ""

dataschema1 <- list(Variables = tibble::tibble(readxl::read_excel(here::here("rmonize/data_schema/", "Dataschema_P1.xlsx"), sheet = 1)),
                    Categories = tibble::tibble(readxl::read_excel(here::here("rmonize/data_schema/", "Dataschema_P1.xlsx"), sheet = 2)))

dataschema2 <- list(Variables = tibble::tibble(readxl::read_excel(here::here("rmonize/data_schema/", "Dataschema_P2.xlsx"), sheet = 1)),
                    Categories = tibble::tibble(readxl::read_excel(here::here("rmonize/data_schema/", "Dataschema_P2.xlsx"), sheet = 2)))

# DPEs need to be loaded
data_proc_elem_P1 <- readxl::read_excel(here::here("rmonize/data_proc_elem", paste0("DPE_",studyname, "_P1", ".xlsx")), sheet = 1)
data_proc_elem_P2 <- readxl::read_excel(here::here("rmonize/data_proc_elem", paste0("DPE_",studyname,"_P2", ".xlsx")), sheet = 1)

# data_proc_elem_P1 <- data_proc_elem_P1 %>%
#   mutate(across(
#     c(2,5:8),
#     ~ gsub("\\s+", "", .)
#   ))
# 
# data_proc_elem_P2 <- data_proc_elem_P2 %>%
#   mutate(across(
#     c(2,5:8),
#     ~ gsub("\\s+", "", .)
#   ))

# Comparing dpes with dataschemas
data_proc_elem_P1[,1:4] == dataschema1$Variables[,1:4]
data_proc_elem_P2[,1:4] == dataschema2$Variables[,1:4]


# Comparing common variables in P1 and P2
common_variables <- intersect(data_proc_elem_P1$dataschema_variable, data_proc_elem_P2$dataschema_variable)

comparison <- data_proc_elem_P1 %>%
  filter(dataschema_variable %in% common_variables)  %>%
  arrange(dataschema_variable) == data_proc_elem_P2 %>%
  filter(dataschema_variable %in% common_variables) %>%
  arrange(dataschema_variable)

comparison[,2] <- sort(common_variables)

# Checking individual discrepancies
variable = ""

data_proc_elem_P1 %>%
  filter(dataschema_variable == variable) %>%
  select(`Mlstr_harmo::algorithm`)

data_proc_elem_P2 %>%
  filter(dataschema_variable == variable) %>%
  select(`Mlstr_harmo::algorithm`)


# Checking DDs
# Function to load Data Dictionary
load_dd <- function(study_name, phase) {
  file_path <- here("rmonize/data_dictionary", paste0("DD_", study_name, "_", phase, ".xlsx"))
  
  dd_var <- tibble(read_excel(file_path, sheet = 1))
  dd_cat <- tibble(read_excel(file_path, sheet = 2))
  
  list(Variables = dd_var, Categories = dd_cat)
}

# Load P1 and P2 data dictionaries
dd_p1 <- load_dd(studyname, "P1")
dd_p2 <- load_dd(studyname, "P2")

# Compare Variables based on name
var_comparison <- dd_p1$Variables %>%
  inner_join(dd_p2$Variables, by = "name", suffix = c("_p1", "_p2")) %>%
  mutate(
    label_match = label_p1 == label_p2,
    valueType_match = valueType_p1 == valueType_p2
  )

# Compare Categories only where name matches in Variables
# Get common variables between P1 and P2
common_vars <- intersect(dd_p1$Categories$variable, dd_p2$Categories$variable)

# Compare categories for each common variable
category_comparison <- lapply(common_vars, function(var) {
  cat_p1 <- dd_p1$Categories %>% filter(variable == var) %>% select(name, label)
  cat_p2 <- dd_p2$Categories %>% filter(variable == var) %>% select(name, label)
  
  comparison <- full_join(cat_p1, cat_p2, by = "name", suffix = c("_p1", "_p2")) %>%
    mutate(match = label_p1 == label_p2)
  
  list(variable = var, comparison = comparison)
})

# Print results
for (res in category_comparison) {
  print(paste("Variable:", res$variable))
  print(res$comparison)
}


