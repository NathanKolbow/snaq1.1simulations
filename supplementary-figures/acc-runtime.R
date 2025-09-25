library(magrittr) # needs to be run every time you start R and want to use %>%
library(dplyr)    # alternatively, this also loads %>%
library(ggplot2)
library(cowplot)
library(patchwork)
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
