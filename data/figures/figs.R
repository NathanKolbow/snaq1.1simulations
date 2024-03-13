library(tidyverse)

n10r1_df <- read.csv("/mnt/home/nkolbow/repos/snaq2/data/output/n10r1.csv")
n10r3_df <- read.csv("/mnt/home/nkolbow/repos/snaq2/data/output/n10r3.csv")
n20r1_df <- read.csv("/mnt/home/nkolbow/repos/snaq2/data/output/n20r1.csv")
n20r3_df <- read.csv("/mnt/home/nkolbow/repos/snaq2/data/output/n20r3.csv")

n10r1_df$estnet <- NA
n10r3_df$estnet <- NA
n20r1_df$estnet <- NA
n20r3_df$estnet <- NA
n10r1_df$netabbr <- "n10r1"
n10r3_df$netabbr <- "n10r3"
n20r1_df$netabbr <- "n20r1"
n20r3_df$netabbr <- "n20r3"
n10r1_df$whichSNaQ <- factor(n10r1_df$whichSNaQ)
n10r3_df$whichSNaQ <- factor(n10r3_df$whichSNaQ)
n20r1_df$whichSNaQ <- factor(n20r1_df$whichSNaQ)
n20r3_df$whichSNaQ <- factor(n20r3_df$whichSNaQ)

gg_df <- rbind(n10r1_df, n10r3_df, n20r1_df, n20r3_df) %>%
    mutate(netid = paste0(netabbr, "_", numgt, "gt_",
    numprocs, "proc_S", whichSNaQ, "_", probQR, ",", propQuartets)) %>%
    mutate(runtimehours = runtime / 3600) %>%
    mutate(numgt = factor(
        numgt, levels = c(100, 300, 1000, 3000), 
        labels = c("100 gt", "300 gt", "1000 gt", "3000 gt")
    ),
    numprocs = factor(
        numprocs,
        levels = c(4, 8, 16),
        labels = paste0(c(4, 8, 16), " procs")
    ),
    snaq2params = paste0("probQR:",probQR,",propQrt=",propQuartets))
gg_df$snaq2params[gg_df$whichSNaQ == 1] <- "SNaQ 1"

# Basic summary stats
median(filter(gg_df, netabbr == "n10r1", whichSNaQ == 1)$runtimehours) * 60
median(filter(gg_df, netabbr == "n10r1", whichSNaQ == 2,
                     propQuartets == 1, probQR == 0)$runtimehours) * 60
median(filter(gg_df, netabbr == "n10r1", whichSNaQ == 2,
                     propQuartets == 0.7, probQR == 0.5)$runtimehours) * 60

median(filter(gg_df, netabbr == "n10r3", whichSNaQ == 1)$runtimehours) * 60
median(filter(gg_df, netabbr == "n10r3", whichSNaQ == 2,
                     propQuartets == 1, probQR == 0)$runtimehours) * 60
median(filter(gg_df, netabbr == "n10r3", whichSNaQ == 2,
                     propQuartets == 0.7, probQR == 0.5)$runtimehours) * 60

median(filter(gg_df, netabbr == "n20r1", whichSNaQ == 1)$runtimehours)
median(filter(gg_df, netabbr == "n20r1", whichSNaQ == 2,
                     propQuartets == 1, probQR == 0)$runtimehours)
median(filter(gg_df, netabbr == "n20r1", whichSNaQ == 2,
                     propQuartets == 0.7, probQR == 0.5)$runtimehours)




# cp_ggdf <- c()
# snaq1entries <- filter(n10r3_df, whichSNaQ == 1)
# temp_df <- n10r3_df

# idx <- 1
# maxval <- 1
# for (rowidx in seq_len(1):nrow(snaq1entries)) {
#     row <- snaq1entries[rowidx, ]
#     matchidxs <- which(
#         temp_df$numgt == row$numgt &
#         temp_df$numprocs == row$numprocs &
#         # temp_df$probQR == row$probQR &
#         # temp_df$propQuartets == row$propQuartets &
#         temp_df$whichSNaQ == 2 &
#         temp_df$replicateid == row$replicateid
#     )
#     match <- temp_df[matchidxs, ]

#     if (nrow(match) != 0) {
#         # Row: the SNaQ 2 entry
#         # match: the SNaQ 1 entry
#         cp_ggdf <- rbind(cp_ggdf, data.frame(
#             whichSNaQ = c(rep("SNaQ1", nrow(match)),
#                           paste0("SNaQ2-", match$propQuartets)),
#             runtimehours = c(rep(row$runtime / 3600, nrow(match)),
#                              match$runtime / 3600),
#             id = rep(idx:(idx + (nrow(match) - 1)), 2)
#         ))
#         idx <- idx + nrow(match)

#         if ((idx - 1) %% 10 == 0) {
#             print(paste0("Processed ", idx - 1, " entries"))
#         }
#         temp_df <- temp_df[-matchidxs, ]
#     }
# }
# dim(cp_ggdf)[1] / 2

# cp_ggdf %>%
#     ggplot(aes(x = whichSNaQ, y = runtimehours, color = whichSNaQ)) +
#     geom_point(alpha = 0.1) +
#     geom_boxplot() +
#     geom_line(aes(group = id), alpha = 0.01, color = "black")

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

p1 <- make_relevant_boxplot("n10r1", "runtimehours",
    savefile = "/mnt/ws/home/nkolbow/repos/snaq2/data/figures/n10r1_runtime.png")
p2 <- make_relevant_boxplot("n10r1", "netRF",
    savefile = "/mnt/ws/home/nkolbow/repos/snaq2/data/figures/n10r1_accuracy.png")

p3 <- make_relevant_boxplot("n10r3", "runtimehours",
    savefile = "/mnt/ws/home/nkolbow/repos/snaq2/data/figures/n10r3_runtime.png")
p4 <- make_relevant_boxplot("n10r3", "netRF",
    savefile = "/mnt/ws/home/nkolbow/repos/snaq2/data/figures/n10r3_accuracy.png")

sum(n20r1_df$whichSNaQ == 1)
sum(n20r1_df$whichSNaQ == 2)
make_relevant_boxplot("n20r1", "netRF")
make_relevant_boxplot("n20r1", "runtimehours")

n10r1_df %>% filter(whichSNaQ == 1)