studyname = "LISA"

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

comparison <- data_proc_elem_P1 %>% filter(dataschema_variable %in% common_variables)  %>% arrange(dataschema_variable)==
  data_proc_elem_P2 %>% filter(dataschema_variable %in% common_variables) %>% arrange(dataschema_variable)

comparison[,2] <- sort(common_variables)

# Checking individual discrepancies
variable = "CAKES_12"

data_proc_elem_P1%>% filter(dataschema_variable == variable)%>%select(input_variables)
data_proc_elem_P2%>% filter(dataschema_variable == variable)%>%select(input_variables)
