## ---- message=FALSE------------------------------------------------------
# Load packages
library(dplyr)
library(tidyr)
library(ggplot2); theme_set(theme_bw())
library(windowscanr)

## Simulate the data
set.seed(1)
group <- rep(c("A1", "A2"), each = 401)
pos <- c(sort(sample(1:600, 401)), sort(sample(1:1000, 401)))
value1 <- c(sin(seq(0, 4, 0.01)), sin(seq(0, 4, 0.01))) + rnorm(802, 0, 0.2)
value2 <- rnorm(802)

raw_data <- data.frame(group, pos, value1, value2)

head(raw_data)

## ------------------------------------------------------------------------
ggplot(raw_data, aes(pos, value1)) + geom_point() + 
	facet_grid(~ group, scales = "free_x", space = "free_x") +
	scale_x_continuous(breaks = seq(0, 5000, 500))

## ------------------------------------------------------------------------
rol_win <- winScan(x = raw_data, 
					 groups = "group", 
					 position = NULL, 
					 values = c("value1", "value2"), 
					 win_size = 100,
					 win_step = 50,
					 funs = c("mean", "sd"))

head(rol_win)

## ------------------------------------------------------------------------
# Add "rank" variable for each group
# in this case this is equivalent to c(1:401, 1:401)
raw_data <- raw_data %>%
	group_by(group) %>%
	mutate(rank = 1:n()) %>%
	as.data.frame()

# Make the plot
ggplot(raw_data, aes(rank, value1)) + geom_point(alpha = 0.5, colour = "grey") +
	geom_point(data = rol_win, aes(win_mid, value1_mean), colour = "red") +
	geom_line(data = rol_win, aes(win_mid, value1_mean), colour = "red") +
	facet_grid(~ group, scales = "free_x", space = "free_x") +
	scale_x_continuous(breaks = seq(0, 1000, 200)) + 
	ggtitle("Rolling window")

## ------------------------------------------------------------------------
pos_win <- winScan(x = raw_data, 
					 groups = "group", 
					 position = "pos", 
					 values = c("value1", "value2"), 
					 win_size = 100,
					 win_step = 50,
					 funs = c("mean", "sd"))

head(pos_win)

## ------------------------------------------------------------------------
ggplot(raw_data, aes(pos, value1)) + geom_point(alpha = 0.5, colour = "grey") + 
	geom_point(data = pos_win, aes(win_mid, value1_mean), colour = "red") +
	geom_line(data = pos_win, aes(win_mid, value1_mean), colour = "red") +
	facet_grid(~ group, scales = "free_x", space = "free_x") +
	scale_x_continuous(breaks = seq(0, 1000, 200)) + 
	ggtitle("Position window")

## ------------------------------------------------------------------------
table(rol_win$value1_n)
table(pos_win$value1_n)

## ------------------------------------------------------------------------
# Add variable with cumulative position
raw_data$cum_pos <- cumSumGroup(raw_data$pos, raw_data$group)
pos_win$cum_mid <- cumSumGroup(pos_win$win_mid, pos_win$group)

# Make plot
plot(raw_data$cum_pos, raw_data$value1, col = "grey")
for(i in unique(pos_win$group)){
	i <- which(pos_win$group == i)
	points(pos_win$cum_mid[i], pos_win$value1_mean[i], col = "red")
	lines(pos_win$cum_mid[i], pos_win$value1_mean[i], col = "red")
	rm(i)
}

