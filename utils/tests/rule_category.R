library(dplyr)

impossible_rows <- data_proc_elem %>%
  filter(`Mlstr_harmo::algorithm` == "impossible") %>%
  pull(`dataschema_variable`)


# Step 2: Subset harmonized dataset column names with 100 NAs
na_100_cols <- harmonized_dataset %>%
  select(where(~ sum(is.na(.)) == 100)) %>%
  names()

setdiff(impossible_rows, na_100_cols)
setdiff(na_100_cols, impossible_rows)


