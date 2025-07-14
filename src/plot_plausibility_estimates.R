# libraries ----
library(ggplot2)
library(readr)
library(dplyr)
library(tidyr)
library(stringr)
library(patchwork)
library(scales)

# Set working directory ----
setwd("/home/sreichl/projects/ResearchAcceleration/")

# input / output ----
plausibility_path <- file.path("data", "anonymized_data_plausibility_estimates.csv")
output_dir        <- file.path("results", "plots")
dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)

# plotting defaults ---------------------------
theme_set(theme_minimal(base_size = 8, base_family = "Arial"))

# colour palette (same grey for the two neutral halves) 
cols <- c(
  "Significant underestimate" = "#2980b9",
  "Moderate underestimate"    = "#3498db",
  "Plausible L"               = "#95a5a6",
  "Plausible R"               = "#95a5a6",
  "Moderate overestimate"     = "#e74c3c",
  "Significant overestimate"  = "#c0392b"
)

height_in    <- 3
width_in     <- 6
options(repr.plot.width = width_in, repr.plot.height = height_in)

# load data & prepare data for plotting  -----------------------------------
raw_df <- read_csv(plausibility_path, show_col_types = FALSE)

long_df <- raw_df |>
  pivot_longer(everything(),
               names_to  = "task",
               values_to = "estimate",
               values_drop_na = TRUE) |>
  mutate(
    estimate = str_to_title(str_squish(estimate)),
    estimate = recode(
      estimate,
      "Significant Underestimate" = "Significant underestimate",
      "Moderate Underestimate"    = "Moderate underestimate",
      "Plausible Estimate"        = "Plausible estimate",
      "Moderate Overestimate"     = "Moderate overestimate",
      "Significant Overestimate"  = "Significant overestimate"
    )
  )

# counts per task & split neutral category
count_df <- long_df |>
  count(task, estimate, name = "n")

# split the neutral answers into left / right halves
neutral_left  <- count_df |>
  filter(estimate == "Plausible estimate") |>
  mutate(estimate = "Plausible L", n_signed = -n / 2)

neutral_right <- neutral_left |>
  mutate(estimate = "Plausible R", n_signed =  n / 2)

others <- count_df |>
  filter(estimate != "Plausible estimate") |>
  mutate(n_signed = ifelse(estimate %in% c("Significant underestimate","Moderate underestimate"),-n, n))

plot_df <- bind_rows(neutral_left, neutral_right, others)

# fix task order --------------------------------------------
task_order <- c("Knowledge synthesis", "Idea & hypothesis generation",
                 "Experiment design", "Ethics approval & permits",
                 "Experiment execution", "Data analysis",
                 "Results interpretation", "Manuscript preparation",
                 "Publication process")

plot_df <- plot_df |> mutate(task = factor(task,levels = rev(task_order)))

# stacking order  --------------------------------------------
ord <- c("Significant underestimate",
         "Moderate underestimate",
         "Plausible L",
         "Significant overestimate",
         "Moderate overestimate", 
         "Plausible R")
plot_df$estimate <- factor(plot_df$estimate, levels = ord)

# set max_cnt for symmetric axis limits --------------------------------------------
max_cnt <- 8 

# plot ------------------------------------------------------------------------
p <- ggplot(plot_df, aes(x = task, y = n_signed, fill = estimate)) +
  geom_col(width = 0.8) +
# add response numbers for not-plausible
geom_text(
  aes(label = ifelse(estimate %in% c("Plausible L", "Plausible R"),
                     "",      # full total for neutral
                     abs(n_signed))),        # raw count for all others
  position = position_stack(vjust = 0.5),
  colour   = "white",
  size     = 3
) +
# add response numbers for plausible
geom_text(
  data = plot_df %>% filter(estimate == "Plausible L"),   # one row per task
  aes(x = task, y = 0,                               # centre (x-axis after flip)
      label = abs(n_signed) * 2),                         # full neutral count
  colour = "white",
  size   = 3,
  inherit.aes = FALSE
) +
# add total response numbers per task
geom_text(
  data = plot_df %>%                                   # reuse current data-frame
         group_by(task) %>%                           # one row per task
         summarise(total = sum(abs(n_signed)), .groups = "drop") %>%
         mutate(task = factor(task, levels = task_order)),
  aes(x = task, y = -8, label = paste0("N=", total)), # fixed left position
  inherit.aes = FALSE,
  hjust = 0, vjust = 0.5,
  size  = 3
) +
  coord_flip() +
    scale_x_discrete(
  labels = function(l)
    ifelse(l == "Experiment execution",
           paste0(l, " (25x)"),
           paste0(l, " (100x)"))
) +
# x-axis
  scale_y_continuous(limits = c(-max_cnt, max_cnt),,
                     breaks = seq(-max_cnt, max_cnt, 1),
                     labels = abs) +
scale_fill_manual(
  values = cols,
  # show each category once, collapse the two neutrals to one label
  breaks = c("Significant underestimate",
             "Moderate underestimate",
             "Plausible L",
             "Moderate overestimate",
             "Significant overestimate"),
  labels = c("Significant underestimate",
             "Moderate underestimate",
             "Plausible",
             "Moderate overestimate",
             "Significant overestimate"),
  name   = NULL,
) +
  labs(x = "Major research tasks", y = "Underestimate    ←    Number of responses    →    Overestimate") +
  theme(
    panel.grid.major.x = element_blank(),   # remove vertical major grid-lines
  panel.grid.minor.x = element_blank(),   # remove vertical minor grid-lines
      panel.grid.major.y = element_blank(),
    panel.grid.minor   = element_blank(),
    axis.line.x        = element_blank(),   # no centre line
      axis.text.x  = element_blank(),
      # LEGEND
    legend.position      = "bottom",
  legend.location      = "plot",        # use whole plot (not just panel) as anchor
  legend.justification = "left",        # left-align legend box to plot
  legend.box.just      = "left",        # left-align items inside the box
      legend.text      = element_text(size = 7),       # smaller text
  legend.key.size  = unit(0.3, "cm"),              # smaller colour swatches
  legend.spacing.y = unit(0.1, "cm")               # tighter rows
  )

# show plot -------------------------------------------------------------------
print(p)

# save plot -------------------------------------------------------------------
ggsave(file.path(output_dir, "plausibility_estimates_plot.png"),
       plot = p, width = width_in, height = height_in,
       dpi = 300, bg = "white")
