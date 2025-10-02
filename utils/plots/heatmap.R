
library(tidyverse)
library(readxl)
library(treemapify)
library(paletteer)
library(MexBrewer)



## Across variable domain
data_for_plot_heatmap <- data_for_plot |> 
  filter(dataschema_variable != "ID") |> 
  mutate(Score = as.factor((case_when(GINI == "impossible" ~ 0,
                                      GINI == "partial" ~ 0.5,
                                      GINI == "complete" ~ 1) +
                              case_when(LISA == "impossible" ~ 0,
                                        LISA == "partial" ~ 0.5,
                                        LISA == "complete" ~ 1) + 
                              case_when(KORA_S1 == "impossible" ~ 0,
                                        KORA_S1 == "partial" ~ 0.5,
                                        KORA_S1 == "complete" ~ 1) + 
                              case_when(KORA_S3 == "impossible" ~ 0,
                                        KORA_S3 == "partial" ~ 0.5,
                                        KORA_S3 == "complete" ~ 1) + 
                              case_when(KARMEN == "impossible" ~ 0,
                                        KARMEN == "partial" ~ 0.5,
                                        KARMEN == "complete" ~ 1) +
                              case_when(DONALD == "impossible" ~ 0,
                                        DONALD == "partial" ~ 0.5,
                                        DONALD == "complete" ~ 1) +
                              case_when(ACTIVE == "impossible" ~ 0,
                                        ACTIVE == "partial" ~ 0.5,
                                        ACTIVE == "complete" ~ 1) +
                              case_when(EPICP == "impossible" ~ 0,
                                        EPICP == "partial" ~ 0.5,
                                        EPICP == "complete" ~ 1)) / 8)) |> 
  mutate(Number = 1)


# Interpolation smooths the surface & is most helpful when rendering images.
#### documentation 
ggplot(data_for_plot_heatmap, aes(area = Number, fill = Score, label = dataschema_variable,
                          subgroup = group)) +
  geom_treemap() +
  scale_fill_paletteer_d("ggsci::default_gsea") +
  geom_treemap_subgroup_border(colour = "red") +
  geom_treemap_subgroup_text(place = "centre", grow = T, alpha = 1, colour =
                               "white", fontface = "italic", min.size = 0) 
  #scale_fill_mex_c("Alacena") +
  #geom_treemap_text(colour = "white", place = "topleft", reflow = T)


ggsave(filename = here::here("utils/plots/figures", "Heatmap.png"))


#### Step 4: Save figures in a folder
