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
plausibility_path <- file.path("data", "anonymized_data_limiting_factors.csv")
output_dir        <- file.path("results", "plots")
dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)

# plotting defaults ---------------------------
theme_set(theme_minimal(base_size = 8, base_family = "Arial"))

# colour palette (same grey for the two neutral halves) 
cols <- c(
  "Insignificant limit" = "#2980b9",
  "Minor limit"    = "#3498db",
  "Moderate limit L"               = "#95a5a6",
  "Moderate limit R"               = "#95a5a6",
  "Major limit"     = "#e74c3c",
  "Crucial limit"  = "#c0392b"
)

height_in    <- 3
width_in     <- 6
options(repr.plot.width = width_in, repr.plot.height = height_in)

# load data & prepare data for plotting  -----------------------------------
raw_df <- read_csv(plausibility_path, show_col_types = FALSE)

long_df <- raw_df |>
  pivot_longer(everything(),
               names_to  = "limit",
               values_to = "estimate",
               values_drop_na = TRUE) |>
  mutate(
    estimate = str_to_title(str_squish(estimate)),
    estimate = recode(
      estimate,
      "Insignificant Limit" = "Insignificant limit",
      "Minor Limit"    = "Minor limit",
      "Moderate Limit"        = "Moderate limit",
      "Major Limit"     = "Major limit",
      "Crucial Limit"  = "Crucial limit"
    )
  )

# counts per limit & split neutral category
count_df <- long_df |>
  count(limit, estimate, name = "n")

# split the neutral answers into left / right halves
neutral_left  <- count_df |>
  filter(estimate == "Moderate limit") |>
  mutate(estimate = "Moderate limit L", n_signed = -n / 2)

neutral_right <- neutral_left |>
  mutate(estimate = "Moderate limit R", n_signed =  n / 2)

others <- count_df |>
  filter(estimate != "Moderate limit") |>
  mutate(n_signed = ifelse(estimate %in% c("Insignificant limit","Minor limit"),-n, n))

plot_df <- bind_rows(neutral_left, neutral_right, others)

# fix limit order --------------------------------------------
limit_order <- c('Biological/Physical time limits',
                 'Resource & infrastructure',
                 'Input data limitations',
                 'Human strategic direction',
                 'Human ethical judgment',
                 'Human accountability',
                 'Institutional adaptation',
                 'Empirical validation',
                 'Stakeholder coordination',
                 'Safety & security',
                 'Scientific community assimilation',
                 'Data volume management')

plot_df <- plot_df |> mutate(limit = factor(limit,levels = rev(limit_order)))

# stacking order  --------------------------------------------
ord <- c("Insignificant limit",
         "Minor limit",
         "Moderate limit L",
         "Crucial limit",
         "Major limit", 
         "Moderate limit R")
plot_df$estimate <- factor(plot_df$estimate, levels = ord)

# set max_cnt for symmetric axis limits --------------------------------------------
max_cnt <- 8 

# plot ------------------------------------------------------------------------
p <- ggplot(plot_df, aes(x = limit, y = n_signed, fill = estimate)) +
  geom_col(width = 0.8) +
# add response numbers for not-plausible
geom_text(
  aes(label = ifelse(estimate %in% c("Moderate limit L", "Moderate limit R"),
                     "",      # full total for neutral
                     abs(n_signed))),        # raw count for all others
  position = position_stack(vjust = 0.5),
  colour   = "white",
  size     = 3
) +
# add response numbers for plausible
geom_text(
  data = plot_df %>% filter(estimate == "Moderate limit L"),   # one row per limit
  aes(x = limit, y = 0,                               # centre (x-axis after flip)
      label = abs(n_signed) * 2),                         # full neutral count
  colour = "white",
  size   = 3,
  inherit.aes = FALSE
) +
# add total response numbers per limit
geom_text(
  data = plot_df %>%                                   # reuse current data-frame
         group_by(limit) %>%                           # one row per limit
         summarise(total = sum(abs(n_signed)), .groups = "drop") %>%
         mutate(limit = factor(limit, levels = limit_order)),
  aes(x = limit, y = -8, label = paste0("N=", total)), # fixed left position
  inherit.aes = FALSE,
  hjust = 0, vjust = 0.5,
  size  = 3
) +
  coord_flip() +
    scale_x_discrete(
  labels = function(l)
    ifelse(l == "Biological/Physical time limits",
           "Biological/physical time limits",
           l)
) +
# x-axis
  scale_y_continuous(limits = c(-max_cnt, max_cnt),,
                     breaks = seq(-max_cnt, max_cnt, 1),
                     labels = abs) +
scale_fill_manual(
  values = cols,
  # show each category once, collapse the two neutrals to one label
  breaks = c("Insignificant limit",
             "Minor limit",
             "Moderate limit L",
             "Major limit",
             "Crucial limit"),
  labels = c("Insignificant limit",
             "Minor limit",
             "Moderate limit",
             "Major limit",
             "Crucial limit"),
  name   = NULL,
) +
  labs(x = "Limiting factors", y = "Less limiting    ←    Number of responses    →    More limiting") +
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
  legend.justification = "center",        # left-align legend box to plot
  legend.box.just      = "center",        # left-align items inside the box
      legend.text      = element_text(size = 7),       # smaller text
  legend.key.size  = unit(0.3, "cm"),              # smaller colour swatches
  legend.spacing.y = unit(0.1, "cm")               # tighter rows
  )

# show plot -------------------------------------------------------------------
print(p)

# save plot -------------------------------------------------------------------
ggsave(file.path(output_dir, "limitation_estimates_plot.png"),
       plot = p, width = width_in, height = height_in,
       dpi = 300, bg = "white")
