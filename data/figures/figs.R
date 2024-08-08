library(tidyverse)
library(ggplot2)
library(cowplot)

setwd("data/output")
n10r1_df <- read.csv("~/repos/snaq2/data/output/n10r1.csv")
n10r3_df <- read.csv("~/repos/snaq2/data/output/n10r3.csv")
n20r1_df <- read.csv("~/repos/snaq2/data/output/n20r1.csv")
n20r3_df <- read.csv("~/repos/snaq2/data/output/n20r3.csv")

n10r1_df$estnet <- NA
n10r3_df$estnet <- NA
n20r1_df$estnet <- NA
n20r3_df$estnet <- NA
n10r1_df$netabbr <- "N10R1"
n10r3_df$netabbr <- "N10R3"
n20r1_df$netabbr <- "N20R1"
n20r3_df$netabbr <- "N20R3"
n10r1_df$whichSNaQ <- factor(n10r1_df$whichSNaQ)
n10r3_df$whichSNaQ <- factor(n10r3_df$whichSNaQ)
n20r1_df$whichSNaQ <- factor(n20r1_df$whichSNaQ)
n20r3_df$whichSNaQ <- factor(n20r3_df$whichSNaQ)

gg_df <- rbind(n10r1_df, n10r3_df, n20r1_df, n20r3_df) %>%
    mutate(netid = paste0(netabbr, "_", numgt, "gt_",
    numprocs, "proc_S", whichSNaQ, "_", probQR, ",", propQuartets)) %>%
    mutate(runtimehours = runtime / 3600, ngt = numgt) %>%
    mutate(
        numgt = factor(
        numgt, levels = c(100, 300, 1000, 3000), 
        labels = c("100 gt", "300 gt", "1000 gt", "3000 gt")
    ),
    numprocs = factor(
        numprocs,
        levels = c(4, 8, 16),
        labels = paste0(c(4, 8, 16))
    ),
    propQ = factor(paste0("propQ = ",propQuartets), levels = paste0("propQ = ", c(1.0, 0.9, 0.7, 0.5))),
    snaq2params = paste0("probQR:",probQR,",propQrt=",propQuartets))
gg_df$snaq2params[gg_df$whichSNaQ == 1] <- "SNaQ 1"

# Basic summary stats
median(filter(gg_df, netabbr == "N10R1", whichSNaQ == 1)$runtimehours) * 60
median(filter(gg_df, netabbr == "N10R1", whichSNaQ == 2,
                     propQuartets == 1, probQR == 0)$runtimehours) * 60
median(filter(gg_df, netabbr == "N10R1", whichSNaQ == 2,
                     propQuartets == 0.7, probQR == 0.5)$runtimehours) * 60

median(filter(gg_df, netabbr == "N10R3", whichSNaQ == 1)$runtimehours) * 60
median(filter(gg_df, netabbr == "N10R3", whichSNaQ == 2,
                     propQuartets == 1, probQR == 0)$runtimehours) * 60
median(filter(gg_df, netabbr == "N10R3", whichSNaQ == 2,
                     propQuartets == 0.7, probQR == 0.5)$runtimehours) * 60

median(filter(gg_df, netabbr == "N20R1", whichSNaQ == 1)$runtimehours)
median(filter(gg_df, netabbr == "N20R1", whichSNaQ == 2,
                     propQuartets == 1, probQR == 0)$runtimehours)
median(filter(gg_df, netabbr == "N20R1", whichSNaQ == 2,
                     propQuartets == 0.7, probQR == 0.5)$runtimehours)



p1 <- ggplot(filter(gg_df, probQR == 0), aes(x = factor(numprocs), y=log(runtime), color=whichSNaQ)) +
    geom_violin() +
    facet_grid(numgt ~ netabbr) +
    theme_half_open(12) +
    panel_border() +
    labs(
        x = "Number of CPUs",
        y = "Log Runtime (hours)",
        color = "Version"
    )
p1

p2 <- filter(gg_df, propQuartets != 0.5 & numgt == "1000 gt") %>%
    ggplot(aes(x = factor(numprocs), y=log(runtime), color=factor(probQR), fill = factor(whichSNaQ))) +
        geom_violin() +
        facet_grid(netabbr ~ propQ, scales="free_y") +
        theme_half_open(12) +
        panel_border() +
        scale_fill_manual(values = c("gray", "transparent")) +
        labs(
            x = "Number of CPUs",
            y = "Log Runtime (hours)",
            color = "probQR",
            fill = "SNaQ"
        )
p2

p3 <- filter(gg_df, propQuartets != 0.5) %>%
    ggplot(aes(x = factor(ngt), y = netRF, color = factor(probQR), fill = factor(whichSNaQ))) +
        facet_grid(netabbr~propQ, scales="free_y") +
        geom_violin() +
        theme_half_open(12) +
        panel_border() +
        scale_fill_manual(values = c("gray", "transparent")) +
        labs(
            x = "Number of Gene Trees",
            y = "Estimation Error (HWCD)",
            color = "probQR",
            fill = "SNaQ"
        )
p3

pdf("runtime.pdf", width=6, height=5)
p2
dev.off()

pdf("acc.pdf", width=6, height=5)
p3
dev.off()

make_relevant_boxplot <- function(netabbrparam, yvar, savefile="") {
    plot <- NULL
    if(yvar == "runtimehours")
        plot <- gg_df %>%
            filter(netabbr == netabbrparam) %>%
            ggplot(aes(x = whichSNaQ, y = runtimehours, color = snaq2params)) +
            geom_violin(aes(group = snaq2params)) +
            ylab("Runtime (hours)") +
            xlab("Which SNaQ?") +
            ggtitle(paste0("Network: ", netabbrparam))
    else if(yvar == "netRF")
        plot <- gg_df %>%
            filter(netabbr == netabbrparam) %>%
            ggplot(aes(x = whichSNaQ, y = netRF, color = snaq2params)) +
            geom_boxplot(aes(group = snaq2params)) +
            ylab("Accuracy (HWCD)") +
            xlab("Which SNaQ?") +
            ggtitle(paste0("Network: ", netabbrparam))
    else {
        print(paste0("Error, yvar \"", yvar, "\" not recognized."))
        return(invisible())
    }

    if(savefile != "")
        ggsave(savefile, plot, device="png", width=8, height=5)

    return(plot)
}

p1 <- make_relevant_boxplot("N10R1", "runtimehours",
    savefile = "/mnt/ws/home/nkolbow/repos/snaq2/data/figures/n10r1_runtime.png")
p2 <- make_relevant_boxplot("N10R1", "netRF",
    savefile = "/mnt/ws/home/nkolbow/repos/snaq2/data/figures/n10r1_accuracy.png")

p3 <- make_relevant_boxplot("N10R3", "runtimehours",
    savefile = "/mnt/ws/home/nkolbow/repos/snaq2/data/figures/n10r3_runtime.png")
p4 <- make_relevant_boxplot("N10R3", "netRF",
    savefile = "/mnt/ws/home/nkolbow/repos/snaq2/data/figures/n10r3_accuracy.png")

sum(n20r1_df$whichSNaQ == 1)
sum(n20r1_df$whichSNaQ == 2)
make_relevant_boxplot("N20R1", "netRF")
make_relevant_boxplot("N20R1", "runtimehours")

n10r1_df %>% filter(whichSNaQ == 1)