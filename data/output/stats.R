library(tidyverse)
library(ggplot2)
library(cowplot)
setwd("/mnt/dv/wid/projects4/SolisLemus-snaq2/data/output")

#results - n10h1

#log running time n10r1
df <- rbind(
    read.csv("n10r1.csv") %>% mutate(netid = "n10r1"),    
    read.csv("n10r3.csv") %>% mutate(netid = "n10r3"),
    read.csv("n20r1.csv") %>% mutate(netid = "n20r1"),
    read.csv("n20r3.csv") %>% mutate(netid = "n20r3")    
) %>% mutate(netid = as.factor(netid))




runtime_props <- c()
j <- 0
for(nid in c("n10r1", "n10r3", "n20r1", "n20r3")) {
  nid_df <- filter(df, netid == nid)
  for(pQR in c(0, 0.5, 1)) {
    for(ngt in c(300, 1000, 3000)) {
      for(pQuar in c(0.5, 0.7, 0.9, 1.0)) {
        for(nprocs in c(4, 8, 16)) {
          j <- j + 1
          iter_df <- filter(nid_df, numgt == ngt & numprocs == nprocs)
          s1_runtime <- mean(filter(iter_df, whichSNaQ == 1)$runtime)
          s2_runtime <- mean(filter(iter_df, propQuartets == pQuar & probQR == pQR & whichSNaQ == 2)$runtime)
          runtime_props <- c(runtime_props, s1_runtime / s2_runtime)
          print(paste0(j, " netid: ", nid, ", nprocs: ", nprocs, ", ngt: ", ngt, ", propQuartets: ", pQuar, ", probQR: ", pQR, " - ", s1_runtime/s2_runtime))
        }
      }
    }
  }
}
runtime_props
min(runtime_props)
max(runtime_props)
which(runtime_props == max(runtime_props))



df <- filter(df, numprocs == 16)
pqr_1 <- c()
pqr_9 <- c()
pqr_7 <- c()
pqr_5 <- c()
for(ngt in c(300, 1000, 3000)) {
  iter_df <- filter(df, numgt == ngt)
  s2_runtime <- mean(filter(iter_df, whichSNaQ == 1)$runtime)

  pqr_1 <- c(pqr_1, s2_runtime/mean(filter(iter_df, propQuartets == 1 & whichSNaQ == 2)$runtime))
  pqr_9 <- c(pqr_9, s2_runtime/mean(filter(iter_df, propQuartets == 0.9)$runtime))
  pqr_7 <- c(pqr_7, s2_runtime/mean(filter(iter_df, propQuartets == 0.7)$runtime))
  pqr_5 <- c(pqr_5, s2_runtime/mean(filter(iter_df, propQuartets == 0.5)$runtime))
}
mean(pqr_1)
mean(pqr_9)
mean(pqr_7)
mean(pqr_5)
mean(pqr_1) / mean(pqr_9)
mean(pqr_1) / mean(pqr_7)
mean(pqr_1) / mean(pqr_5)



library(car)
# TEST THE EFFECT OF PROBQR
fit <- lm(log2(runtime) ~ (numgt * propQuartets * probQR * numprocs) * netid, filter(df, whichSNaQ == 2))
Anova(fit, type = 3)



fit <- lm(netRF ~ (numgt * as.factor(propQuartets) * probQR * numprocs) * netid, filter(df, whichSNaQ == 2))
Anova(fit, type = 3)
