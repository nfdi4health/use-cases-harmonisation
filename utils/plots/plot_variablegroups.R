
vars_of_interest <- variable_groups |> 
  select(group) |> 
  unique() |> 
  pull()

data_prep_groups <- data_for_plot |> 
  select(c(dataschema_variable, group, KORA_S1, KORA_S3, GINI, LISA, KARMEN, DONALD, ACTIVE, EPICP)) |> 
  pivot_longer(!(c(dataschema_variable, group)), names_to = "Study", values_to = "Status") |> 
  mutate(group = factor(group, levels = vars_of_interest)) |>
  mutate(Status = factor(Status, levels = c("impossible",
                                            "partial",
                                            "complete"))) |>
  rename(Variable = dataschema_variable) |> 
  group_by(group, Status) |> 
  summarise(Variables = n()) |> 
  group_by(group) |> 
  mutate(total= sum(Variables)) |> 
  mutate(Percent = round(Variables/total*100,2)) |> 
  filter(group != "ident") |> 
  rename(Variable_Group = group) |> 
  ggplot(aes(fill = Status, x = Variable_Group, y = Percent)) +
  geom_bar(position = "stack", stat = "identity", colour = "black") +
  scale_fill_paletteer_d("MexBrewer::Aurora") +
  scale_y_continuous(limits = c(0, NA), expand = c(0,0)) +
  labs(title = "Harmonisation Potential across variable groups", x = "Variable Group") +
  theme_classic() +
  theme(axis.text.x=element_text(colour="black", size=28),
        axis.text.y=element_text(colour="black", size=28),
        axis.title=element_text(size=34,face="bold"),
        axis.ticks.x=element_line(colour="black"),
        axis.ticks.y=element_line(colour="black"),
        plot.title = element_text(color="black", size=48, face="bold.italic", hjust = 0.5),
        legend.text = element_text(size=32),
        legend.title = element_text(size=40))

data_prep_groups


#### Step 4: Save figures in a folder

ggsave(filename = here::here("utils/plots/figures", "Variable_Groups.png"),
       width = 40, height = 20)
