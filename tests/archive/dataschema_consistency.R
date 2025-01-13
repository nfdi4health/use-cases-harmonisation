dataschema1 <- list(Variables = tibble::tibble(readxl::read_excel(here::here("rmonize/data_schema/", "Dataschema_P1.xlsx"), sheet = 1)),
                    Categories = tibble::tibble(readxl::read_excel(here::here("rmonize/data_schema/", "Dataschema_P1.xlsx"), sheet = 2)))

dataschema2 <- list(Variables = tibble::tibble(readxl::read_excel(here::here("rmonize/data_schema/", "Dataschema_P2.xlsx"), sheet = 1)),
                   Categories = tibble::tibble(readxl::read_excel(here::here("rmonize/data_schema/", "Dataschema_P2.xlsx"), sheet = 2)))

intersect <- intersect(dataschema1$Variables$name, dataschema2$Variables$name)

for (var in intersect){
  idxA <- which(dataschema1$Variables$name == var)
  idxB <- which(dataschema2$Variables$name == var)
  print(idxB)
  
  print(var)
  print((dataschema1$Variables[idxA,3] == dataschema2$Variables[idxB,3]))
}
# DPEs need to be loaded
data_proc_elem_S1P1 <- readxl::read_excel(here::here("rmonize/data_proc_elem", paste0("DPE_","KORA_S1_P1", ".xlsx")), sheet = 1)
data_proc_elem_S1P2 <- readxl::read_excel(here::here("rmonize/data_proc_elem", paste0("DPE_","KORA_S1_P2", ".xlsx")), sheet = 1)
data_proc_elem_S3P1 <- readxl::read_excel(here::here("rmonize/data_proc_elem", paste0("DPE_","KORA_S3_P1", ".xlsx")), sheet = 1)
data_proc_elem_S3P2 <- readxl::read_excel(here::here("rmonize/data_proc_elem", paste0("DPE_","KORA_S3_P2", ".xlsx")), sheet = 1)


data_proc_elem_S1P1[,1:3] == dataschema1$Variables[,1:3]
data_proc_elem_S1P2[,1:3] == dataschema2$Variables[,1:3]
data_proc_elem_S3P1[,1:3] == dataschema1$Variables[,1:3]
data_proc_elem_S3P2[,1:3] == dataschema2$Variables[,1:3]