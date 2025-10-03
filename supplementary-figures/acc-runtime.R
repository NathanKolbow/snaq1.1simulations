library(magrittr) # needs to be run every time you start R and want to use %>%
library(dplyr)    # alternatively, this also loads %>%
library(ggplot2)
library(cowplot)
library(patchwork)
library(ggh4x)
setwd("/mnt/dv/wid/projects4/SolisLemus-snaq2/data/output")


read_data <- function(path) {
    read.csv(path) %>%
        mutate(
            probQR = paste0("probQR = ", probQR),
            numgt = factor(paste0(numgt, " gt"), levels=c("300 gt", "1000 gt", "3000 gt")),
            whichSNaQ = if_else(whichSNaQ == 2, 1.1, 1)
        )
}
plot_runtime <- function() {
    ggplot(data,aes(x=factor(numprocs), y=log(runtime), color=factor(whichSNaQ), fill=factor(propQuartets))) +
        labs(
            y="Log2 Runtime (sec)", x="Number of Processors",
            color="SNaQ", fill="propQuartets"
        )+
        scale_color_grey()+
        geom_violin(linewidth=0.4)+ # Decrease the width of the violin plot
        facet_grid(numgt~probQR)+
        theme_half_open(12)+
        panel_border()+
        scale_fill_manual(values=c("#f1eef6", "#bdc9e1", "#74a9cf", "#0570b0"))+
        scale_color_manual(values=c("red", "black")) +
        ggtitle(paste0("N", data$ntaxa[1], "R", data$nhybrids_true[1]))
}
plot_accuracy <- function() {
    ggplot(data,aes(x=factor(numprocs), y=netRF, color=factor(whichSNaQ), fill=factor(propQuartets)))+
        labs(
            y="Accuracy (HWCD)", x="Number of Processors",
            color="SNaQ", fill="propQuartets"
        )+
        scale_color_grey()+
        #ylim(0,10)+
        geom_violin(linewidth=0.4)+
        facet_grid(numgt~probQR)+
        theme_half_open(12)+
        panel_border()+
        scale_fill_manual(values=c("#f1eef6", "#bdc9e1", "#74a9cf", "#0570b0"))+
        scale_color_manual(values=c("red", "black")) +
        ggtitle(paste0("N", data$ntaxa[1], "R", data$nhybrids_true[1]))
}


# For some reason putting this in a while loop just doesn't work, so we do them individually
data <- read_data("n10r1.csv")
pdf("../../supplementary-figures/runtime-n10r1.pdf", width=7.7, height=4.18)
r101 <- plot_runtime()
r101
dev.off()
pdf("../../supplementary-figures/accuracy-n10r1.pdf", width=7.7, height=4.18)
a101 <- plot_accuracy()
a101
dev.off()

data <- read_data("n10r3.csv")
pdf("../../supplementary-figures/runtime-n10r3.pdf", width=7.7, height=4.18)
r103 <- plot_runtime()
r103
dev.off()
pdf("../../supplementary-figures/accuracy-n10r3.pdf", width=7.7, height=4.18)
a103 <- plot_accuracy()
a103
dev.off()

data <- read_data("n20r1.csv")
pdf("../../supplementary-figures/runtime-n20r1.pdf", width=7.7, height=4.18)
r201 <- plot_runtime()
r201
dev.off()
pdf("../../supplementary-figures/accuracy-n20r1.pdf", width=7.7, height=4.18)
a201 <- plot_accuracy()
a201
dev.off()

data <- read_data("n20r3.csv")
pdf("../../supplementary-figures/runtime-n20r3.pdf", width=7.7, height=4.18)
r203 <- plot_runtime()
r203
dev.off()
pdf("../../supplementary-figures/accuracy-n20r3.pdf", width=7.7, height=4.18)
a203 <- plot_accuracy()
a203
dev.off()




plot_accuracy_by_ngt <- function() {
    data %>%
        group_by(numgt, whichSNaQ, propQuartets, probQR) %>%
        summarise(
            mean_hwcd = mean(netRF),
            se_hwcd = sd(netRF),
            ymin = quantile(netRF, 0.025),
            ymax = quantile(netRF, 0.975)
        ) %>%
        mutate(
            whichSNaQ = if_else(whichSNaQ == 1, "v1.0", "v1.1"),
            propQuartets = paste0("propQuartets = ", propQuartets),
            numgt = if_else(numgt == "300 gt", 300, if_else(numgt == "1000 gt", 1000, 3000))
        ) %>%
        ggplot(aes(x = numgt, y = mean_hwcd, shape = factor(whichSNaQ), color = factor(whichSNaQ))) +
        geom_point(size=3, position = position_dodge(width=300)) +
        geom_line(aes(group = interaction(whichSNaQ, probQR, propQuartets)), linetype = "dashed", alpha = 0.75) +
        geom_errorbar(aes(ymin = ymin, ymax = ymax), position = position_dodge(width=300), width=300) +
        facet_grid(probQR ~ propQuartets) +
        scale_shape_manual(values = c(1, 4)) +
        labs(
            x = "Number of gene trees",
            y = "Average Hardwired Cluster Distance",
            color = "SNaQ Version",
            shape = "SNaQ Version"
        ) +
        scale_x_continuous(
            breaks = c(300, 1000, 3000),
            limits = c(0, 3500)
        ) +
        expand_limits(x=0, y=0) +
        theme(panel.grid.minor = element_blank())
}

data <- read_data("n10r1.csv")
p1 <- plot_accuracy_by_ngt() + ggtitle("A: n10r1") + labs(x="")

data <- read_data("n10r3.csv")
p2 <- plot_accuracy_by_ngt() + ggtitle("B: n10r3") + labs(y="") + labs(x="")

data <- read_data("n20r1.csv")
p3 <- plot_accuracy_by_ngt() + ggtitle("C: n20r1")

data <- read_data("n20r3.csv")
p4 <- plot_accuracy_by_ngt() + ggtitle("D: n20r3") + labs(y="")

pdf("../../supplementary-figures/accuracy-by-ngt-all.pdf", width=15, height=7.5)
(p1 + p2) / (p3 + p4) + plot_layout(axis_titles = "collect", guides = "collect")
dev.off()
