library(dplyr)

variable1 <- dataset_FFQ %>%
  dplyr::filter(GROUP == 1) %>%
  dplyr::group_by(id) %>%
  summarise(POTATOES_TUB_01 = sum(quant_grp17))



EPICP_P1_FFQ_Info <- tibble(readxl::read_excel(here::here("rmonize/data_proc_elem/", "EPICP_P1_FFQ_Information.xlsx"), sheet = 1))

filter1 <- EPICP_P1_FFQ_Info$GROUP
filter2 <- EPICP_P1_FFQ_Info$subgroup1
filter3 <- EPICP_P1_FFQ_Info$subgroup2
name <- EPICP_P1_FFQ_Info$Name


ffq_result <- data.frame(matrix(ncol = 101, nrow = 4))
colnames(ffq_result) <- c("id",name)
ffq_result$id <- c(1,2,3,4)
#### NA treatment is wrong; need negative number to account for that
#### https://stackoverflow.com/questions/28857653/removing-na-observations-with-dplyrfilter
for (i in 1:length(EPICP_P1_FFQ_Info$Name)){
  
  variable1 <- EPICP_P1_FFQ %>%
  dplyr::filter(GROUP == filter1[i],
                subgroup1 == filter2[i],
                subgroup2 == filter3[i]) |> 
  dplyr::group_by(id)  |> 
  summarise(variable = sum(quant_grp17)) 
  
  variable1[[paste0(name[i])]] <- variable1$variable 
  variable1 <- variable1[c(1,3)]
  
  ffq_result[variable1$id, i] <- variable1[,2]
  
}

i <- 1

ffq_result[4,100]

