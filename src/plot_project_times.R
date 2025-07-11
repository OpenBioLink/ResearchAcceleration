
# libraries
library(ggplot2)
library(tidyverse)
library(patchwork)

# Set working directory 
setwd("/home/sreichl/projects/GPAI")  

# configs

# input
input_path  <- file.path("data", "anonymized_data_project_times.csv")

# output
output_dir  <- file.path("results", "plots")
dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)

# plotting
theme_set(theme_minimal(base_size = 8, base_family = "Arial"))
# colors <- c("Cognitive" = "#3498db", "Physical" = "#e74c3c")

# plot sizes
height_in <- 4
width_in  <- 6
options(repr.plot.width = width_in, repr.plot.height = height_in)

# Load data
df_long <- read.csv(input_path, check.names = FALSE) |>
  pivot_longer(cols = everything(),
               names_to  = "task",
               values_to = "months") |>
  mutate(task = str_trim(task))

# split into major tasks and total-project rows
df_tasks <- df_long |> filter(!grepl("Total", task, ignore.case = TRUE))
df_total <- df_long |> filter( grepl("Total", task, ignore.case = TRUE))

task_levels <- unique(df_tasks$task)             # preserve file order
df_tasks$task <- factor(df_tasks$task, levels = task_levels)

# ── Summary statistics ────────────────────────────────────────────────────────
total_mean <- mean(df_total$months)

# attention: round() does round-to-even ie round(2.25,1) -> 2.2 not 2.3
summ_tasks <- df_tasks %>%
  group_by(task) %>%
  summarise(
    mean_months = mean(months),
    .groups     = "drop"
  ) %>%
  mutate(
    percentage    = 100 * mean_months / total_mean,
    mean_months   = round(mean_months,   1),
    percentage    = round(percentage,     1)
  )

# ── Major-tasks bubble plot ───────────────────────────────────────────────────
plot_tasks <- ggplot() +
geom_segment(
  data        = summ_tasks,
  aes(x       = 0, xend = mean_months, y = task, yend = task),
  colour      = "black",
  linewidth        = 0.5,
  inherit.aes = FALSE
) +
geom_point(
  data        = summ_tasks,
  aes(x       = mean_months, y = task),
  shape       = 19,
  colour      = "black",
  size        = 3,
  inherit.aes = FALSE
)+
geom_dotplot(
  data       = df_tasks,
  aes(x      = months, y = task),
  binaxis    = "x",        # stack along x-axis
    binwidth   = 1,
  stackdir   = "center",   # center the stacks
  stackratio = 0.5,        # spacing between dots
  dotsize    = 0.75,        # size of each dot
  fill       = "#3498db",
  color      = "black",
    stroke     = 0.5,
  alpha      = 1
) +
  scale_y_discrete(limits = rev(task_levels)) +
  labs(title = NULL,
       x = NULL, y = "Major research tasks")+
  scale_x_continuous(
    breaks = seq(0, ceiling(max(df_tasks$months)), by = 6),
    expand = c(0, 0)
  )+ # seed legend entries via invisible numeric NA coords
  geom_point(
    data        = data.frame(months = NA_real_, task = NA_character_),
    aes(x        = months, y = task, size = "Individual estimates"),
    shape       = 21, fill = "#3498db", color = "black",
    stroke      = 0.1, alpha = 1,
    show.legend = TRUE
  ) +
  geom_point(
    data        = data.frame(months = NA_real_, task = NA_character_),
    aes(x        = months, y = task, size = "Mean estimates"),
    shape       = 19, color = "black",
    show.legend = TRUE
  ) +
  scale_size_manual(
    name   = NULL,
    values = c(
      "Individual estimates" = 2,
      "Mean estimates"       = 3
    ),
    guide  = guide_legend(
      override.aes = list(
        shape  = c(21, 19),
        fill   = c("#3498db", "black"),
        color  = c("black", "black"),
        stroke = c(0.1, NA),
        size   = c(2, 3),
        alpha  = c(1, 1)
      )
    )
  )

# ── Text tables (means & % of total) ──────────────────────────────────────────
tbl_mean <- ggplot(summ_tasks,
                   aes(y = task, x = 1, label = sprintf("%.1f", mean_months))) +
  geom_text(hjust = 0.5, size = 2.5) +
labs(title = "Mean\n(months)") +
  scale_y_discrete(limits = rev(task_levels), position = "right") +
  coord_cartesian(xlim = c(1, 1)) +
  theme_void() +
theme(
    plot.title  = element_text(family = "Arial", size = 8, face = "bold", hjust = 0.5)
)

tbl_pct  <- ggplot(summ_tasks,
                   aes(y = task, x = 1, label = sprintf("%.1f%%", percentage))) +
  geom_text(hjust = 0.5, size = 2.5) +
labs(title = "Percentage\nof total") +
  scale_y_discrete(limits = rev(task_levels), position = "right") +
  coord_cartesian(xlim = c(1, 1)) +
  theme_void() +
theme(
    plot.title  = element_text(family = "Arial", size = 8, face = "bold", hjust = 0.5)
)
    

# ── Total-project-time bubble plot (separate axis) ────────────────────────────
plot_total <- ggplot() +
geom_segment(
  aes(x       = 0, xend = total_mean, y = "Total project time", yend = "Total project time"),
  colour      = "black",
  linewidth        = 0.5,
  inherit.aes = FALSE
) +
geom_point(
  aes(x       = total_mean, y = "Total project time"),
  shape       = 19,
  colour      = "black",
  size        = 3,
  inherit.aes = FALSE
)+
geom_dotplot(
  data       = df_total,
  aes(x      = months, y = "Total project time"),
  binaxis    = "x",        # stack along x-axis
    binwidth   = 1,
  stackdir   = "center",   # center the stacks
  stackratio = 0.5,        # spacing between dots
  dotsize    = 2.5,        # size of each dot
  fill       = "#e74c3c",
  color      = "black",
    stroke     = 0.5, 
  alpha      = 1
) +
  scale_y_discrete(limits = "Total project time") +
  labs(x = "Time (months)", y = NULL)+
  scale_x_continuous(
    breaks = seq(0, ceiling(max(df_total$months) / 12) * 12, by = 12),
      limits = c(0, ceiling(max(df_total$months) / 12) * 12),
    expand = c(0, 0)
  )#+ # seed legend entries via invisible numeric NA coords
  # geom_point(
  #   data        = data.frame(months = NA_real_, task = NA_character_),
  #   aes(x        = months, y = task, size = "Individual estimates"),
  #   shape       = 21, fill = "#e74c3c", color = "black",
  #   stroke      = 0.1, alpha = 1,
  #   show.legend = TRUE
  # ) +
  # scale_size_manual(
  #   name   = "Estimate type",
  #   values = c(
  #     "Individual estimates" = 2
  #   ),
  #   guide  = guide_legend(
  #     override.aes = list(
  #       shape  = c(21),
  #       fill   = c("#e74c3c"),
  #       color  = c("black"),
  #       stroke = c(0.1),
  #       size   = c(2),
  #       alpha  = c(1)
  #     )
  #   )
  # )

# ── add statistics panels for total-project time ──────────────────────────────
total_tbl <- data.frame(task = "Total project time",
                        mean_months = total_mean,
                        percentage  = 100)

tbl_total_mean <- ggplot(total_tbl,
                         aes(y = task, x = 1, label = sprintf("%.1f", mean_months))) +
  geom_text(hjust = 0.5, size = 2.5) +
  scale_y_discrete(limits = "Total project time", position = "right") +
  coord_cartesian(xlim = c(1, 1)) +
  theme_void()

tbl_total_pct  <- ggplot(total_tbl,
                         aes(y = task, x = 1, label = "100%")) +
  geom_text(hjust = 0.5, size = 2.5) +
  scale_y_discrete(limits = "Total project time", position = "right") +
  coord_cartesian(xlim = c(1, 1)) +
  theme_void()

# ──  assembly ─────────────────────────────────────────────────────────
final_plot <- ((plot_tasks | tbl_mean | tbl_pct)+plot_layout(widths = c(6,1,1))) /
              ((plot_total | tbl_total_mean | tbl_total_pct)+plot_layout(widths = c(6,1,1))) +
              plot_layout(heights = c(9, 1), guides = "collect") &
  theme(
    legend.position  = "bottom",
    legend.direction = "horizontal"
  )

final_plot



# Save the plot using ggsave.
ggsave(file.path(output_dir, "project_times_plot.png"),  final_plot, width = width_in, height = height_in, dpi = 300, bg = "white")
