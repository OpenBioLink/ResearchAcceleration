
# libraries
library(ggplot2)

# Set working directory 
setwd("/home/sreichl/projects/ResearchAcceleration")  

# configs

# input
input_path  <- file.path("data", "Acceleration_Factors_with_Ranges_and_Midpoints_clean.csv")

# output
output_dir  <- file.path("results", "plots")
dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)

# plotting
theme_set(theme_minimal(base_size = 8, base_family = "Arial"))
colors <- c("Cognitive" = "#3498db", "Physical" = "#e74c3c")

# plot sizes
height_in <- 4
width_in  <- 4
options(repr.plot.width = width_in, repr.plot.height = height_in)

# Load data
df <- read.csv(input_path, stringsAsFactors = FALSE)

# add acceleration level column: "Maximum" if accel > 10, otherwise "Next"
df$level <- ifelse(df$acceleration > 10, "Maximum", "Next")

# add our acceleration factors
df <- rbind(df, data.frame(acceleration = 2, type = "Cognitive", reference = "Next-level GPAI", level = "Next", stringsAsFactors = FALSE))
df <- rbind(df, data.frame(acceleration = 2, type = "Physical", reference = "Next-level GPAI", level = "Next", stringsAsFactors = FALSE))
df <- rbind(df, data.frame(acceleration = 100, type = "Cognitive", reference = "Maximum-level GPAI", level = "Maximum", stringsAsFactors = FALSE))
df <- rbind(df, data.frame(acceleration = 25, type = "Physical", reference = "Maximum-level GPAI", level = "Maximum", stringsAsFactors = FALSE))

# plot: x-axis the tasks and the y-axis acceleration and plot it on a log scale, split and colored by task
# overlay scatter on semi‐transparent violins with black‐bordered points
violin_scatter_plot <- ggplot(df, aes(x = type, y = acceleration)) +
  # draw horizontal dashed lines at the four GPAI points
  geom_hline(
    data   = subset(df, reference %in% c("Next-level GPAI","Maximum-level GPAI")),
    aes(yintercept = acceleration),
    linetype = "dashed",
    size     = 0.3,
    color    = "black",
    alpha = 0.5
      
  ) +
    geom_violin(aes(fill = type), alpha = 0.2, linewidth=0) + 
  geom_jitter(
      data        = subset(df, !(reference %in% c("Next-level GPAI","Maximum-level GPAI"))),
    aes(shape = level, fill = type),
    position = position_jitter(width = 0.2, seed = 42),
    color    = "black", size = 2, stroke = 0.2, alpha = 1 
  ) +
  geom_point(
    data        = subset(df, reference %in% c("Next-level GPAI","Maximum-level GPAI")),
    aes(x = type, y = acceleration, shape = level),
    fill        = "black", color = "black", size = 3, stroke = 0,
    inherit.aes = FALSE
  ) +
  scale_fill_manual(values = colors) +
  scale_shape_manual(
    name   = "Acceleration level",         
      breaks = c("Next", "Maximum"),
    values = c("Next" = 25, "Maximum" = 24),
      guide  = guide_legend(override.aes = list(size = 2))
  ) +
geom_label(
  data        = subset(df, reference %in% c("Next-level GPAI","Maximum-level GPAI")),
  aes(x     = Inf, y = acceleration, label = paste0(acceleration, "x")),
  hjust       = 1,
  vjust       =  0.5,
  family      = "Arial",
  size        = 3,
  fill        = "white",                    # white background
  label.size  = 0,                          # no border
  label.padding = unit(0.1, "lines"),       # small padding
  inherit.aes = FALSE
) +
# allow annotations outside plot area
coord_cartesian(clip = "off")+
  scale_y_log10() +
  guides(fill = "none") + 
  labs(x = "Task type", y = "Acceleration factor") +
  theme_minimal()+
theme(
  legend.position  = "bottom",
  legend.direction = "horizontal"
)

violin_scatter_plot

# Save the plot using ggsave.
ggsave(file.path(output_dir, "accelerations_plot.png"),  violin_scatter_plot, width = width_in, height = height_in, dpi = 300, bg = "white")
