
# libraries
library(ggplot2)

# Set working directory 
setwd("/home/sreichl/projects/ResearchAcceleration")  

# configs

# output
output_dir  <- file.path("results", "plots")
dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)

# plotting
theme_set(theme_minimal(base_size = 8, base_family = "Arial"))

# plot sizes
height_in <- 4
width_in  <- 4
options(repr.plot.width = width_in, repr.plot.height = height_in)


# generate heatmap data
levels <- c("No GPAI","Next-level capability","Maximum-level capability")
autonomy_mat <- matrix(c(0,1,2,
                         1,3,4,
                         2,4,5),
                       nrow = 3, byrow = TRUE,
                       dimnames = list(cognitive = levels,
                                       physical  = levels))
df_heat <- as.data.frame(as.table(autonomy_mat))
names(df_heat) <- c("cognitive","physical","autonomy")
df_heat$cognitive <- factor(df_heat$cognitive, levels = rev(levels))
df_heat$physical  <- factor(df_heat$physical,  levels = levels)


# plot heatmap without values, colored blues with legend “Autonomy”
capability_model_heatmap <- ggplot(df_heat, aes(x = physical, y = cognitive, fill = autonomy)) +
  geom_tile(color = "white") +
  scale_fill_gradientn(
    colours = c("#f7fbff","#c6dbef","#9ecae1","#6baed6","#3182bd","#08519c"),
    name    = "Autonomy",
    guide   = guide_colorbar(title.position = "left",
                             direction = "horizontal", 
                             ticks = FALSE,
                             label = FALSE
                            )
  ) +
  scale_x_discrete(position = "top", labels = function(x) stringr::str_wrap(x, width = 10), expand   = c(0, 0)) +
  scale_y_discrete(labels = function(x) stringr::str_wrap(x, width = 10), expand   = c(0, 0)) +
  labs(x = "Physical tasks", y = "Cognitive tasks") +
  theme_minimal() +
  theme(
    axis.ticks = element_blank(),
      axis.ticks.length = unit(0, "pt"),
      legend.position  = "bottom",
  legend.direction = "horizontal"
  ) 

capability_model_heatmap

# Save the plot using ggsave
ggsave(file.path(output_dir, "capability_model_plot.png"),  capability_model_heatmap, width = width_in, height = height_in, dpi = 300, bg = "white")
