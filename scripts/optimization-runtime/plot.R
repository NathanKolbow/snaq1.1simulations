library(ggplot2)
library(tidyverse)
library(magrittr) # needs to be run every time you start R and want to use %>%
library(dplyr)    # alternatively, this also loads %>%
library(ggplot2)
library(cowplot)
library(patchwork)
library(ggh4x)

setwd("scripts/optimization-runtime")
rtdf <- rbind(
  read.csv("v1.0/rt.csv"),
  read.csv("v1.1/rt.csv")
) %>%
  mutate(runtime = runtime / 60) %>%
  filter(threads %in% c(1, 2, 4, 8))

rtmeandf <- rtdf %>%
  group_by(ntaxa, nhybrids, snaqV, threads) %>%
  summarise(
    y = median(runtime),
    ymax = quantile(runtime, 0.975),
    ymin = quantile(runtime, 0.025)
  )

pdf("runtime-all.pdf", width=7.7, height=4.18)
rtdf %>%
  ggplot(aes(x = ntaxa, y = runtime, color = factor(threads), linetype = snaqV)) +
  geom_smooth(method = "loess", se = FALSE, linewidth = 1) +
  labs(
    x = "Number of Taxa",
    y = "Runtime (minutes)",
    color = "Threads",
    linetype = "SNaQ"
  ) +
  scale_x_continuous(
    limits = c(5, 30),
    breaks = seq(5, 30, by=5)
  ) +
  scale_color_manual(values=c("#0571b0", "#92c5de", "#f4a582", "#ca0020")) +
  theme_half_open(12)+
  panel_border()+
  background_grid()
dev.off()

rtmeandf %>%
  filter(nhybrids == 1) %>%
  ggplot(aes(x = factor(ntaxa), y = y, color = snaqV)) +
  geom_point() +
  geom_line() +
  facet_wrap(~threads) +
  scale_x_discrete(breaks = c(5, 10, 15, 20, 25, 30, 35, 40, 45, 50))