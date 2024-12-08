
# Load necessary libraries
library(dplyr)
library(readxl)
library(writexl)
library(here)

# Your code that uses these libraries


##### Creating DPE_P1 and DPE_P2
dpe_tracy <- readxl::read_excel(here::here("Tracy/DPE_KARMEN_TRACY.xlsx"), sheet = 1)
dpe_ines <- readxl::read_excel(here::here("Ines/DPE_KARMEN_INES.xlsx"), sheet = 1)
dpe_franzi <- readxl::read_excel(here::here("Franzi/DPE_KARMEN_FRANZI.xlsx"), sheet = 1)


dataschema_p1 <- list(Variables =  tibble::tibble(readxl::read_excel(here::here("rmonize/data_schema/", "Dataschema_P1.xlsx"), sheet = 1)),
                      Categories = tibble::tibble(readxl::read_excel(here::here("rmonize/data_schema/", "Dataschema_P1.xlsx"), sheet = 2)))
dataschema_p2 <- list(Variables =  tibble::tibble(readxl::read_excel(here::here("rmonize/data_schema/", "Dataschema_P2.xlsx"), sheet = 1)),
                      Categories = tibble::tibble(readxl::read_excel(here::here("rmonize/data_schema/", "Dataschema_P2.xlsx"), sheet = 2)))

# Assuming these are data.frames
combined_data <- bind_rows(dpe_tracy, dpe_ines, dpe_franzi)

# Subset for dpe_p1
dpe_p1 <- combined_data %>%
  filter(dataschema_variable %in% dataschema_p1$Variables$name) %>%
  slice(match(dataschema_p1$Variables$index, row_number())) %>%
  mutate(input_dataset = "KARMEN_P1")

# Subset for dpe_p2
dpe_p2 <- combined_data %>%
  filter(dataschema_variable %in% dataschema_p2$Variables$name) %>%
  slice(match(dataschema_p2$Variables$index, row_number())) %>%
  mutate(input_dataset = "KARMEN_P2")

writexl::write_xlsx(dpe_p1, paste0("rmonize/DPE_KARMEN_P1_test.xlsx"))
writexl::write_xlsx(dpe_p2, paste0("rmonize/DPE_KARMEN_P2_test.xlsx"))
