library(magrittr) # needs to be run every time you start R and want to use %>%
library(dplyr)    # alternatively, this also loads %>%
library(ggplot2)
library(cowplot)
setwd("/mnt/dv/wid/projects4/SolisLemus-snaq2/data/output")

#results - n10h1

#log running time n10r1
data<-read.csv("n10r1.csv")
data<-read.csv("n10r3.csv")
data<-read.csv("n20r1.csv")
data<-read.csv("n20r3.csv")


data <- data %>%
  mutate(
    probQR = paste0("probQR = ", probQR),
    numgt = factor(paste0(numgt, " gt"), levels=c("300 gt", "1000 gt", "3000 gt")),
    whichSNaQ = if_else(whichSNaQ == 2, 1.1, 1)
  )


pdf("runtime.pdf", width=7.7, height=4.18)
ggplot(data,aes(x=factor(numprocs), y=log(runtime), color=factor(whichSNaQ), fill=factor(propQuartets)))+
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
  scale_color_manual(values=c("red", "black"), labels=c("1"="v1.0", "1.1"="v1.1"))
dev.off()



pdf("acc.pdf", width=7.7, height=4.18)
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
  scale_color_manual(values=c("red", "black"), labels=c("1"="V1.0", "1.1"="V1.1"))
dev.off()











ggplot(data,aes(x=factor(numprocs), y=majortreeRF, color=factor(propQuartets)))+#, fill=factor(propQuartets)))+
  labs(title="HWCD (probQR x g)", y="HWCD", x="Number of processors")+
  #ylim(0,30)+
  scale_color_grey()+
  geom_jitter()+
  facet_grid(numgt~probQR)+
  theme_half_open(12)+
  panel_border()




library(plotly)
data<-read.csv("n20r1.csv")
data %>%
  #filter(numprocs == 16) %>%
  filter(whichSNaQ == 2) %>%
  filter(propQuartets == 1) %>%  
  ggplot(aes(x=factor(probQR), y=log(netRF/runtime)))+
  geom_boxplot()+
  facet_grid(numgt~numprocs)+
  theme_half_open(12)+
  panel_border()
  #plot_ly(x=data$probQR, y=log(data$runtime), z=data$netRF, type="scatter3d", mode="markers", color="data$whichSNaQ")


  ggplot(aes(x=factor(probQR), y=log(netRF/runtime)))+
  geom_boxplot()+
  theme_half_open(12)+
  panel_border()
#










data %>%
  filter(numprocs == 8) %>%
  ggplot(aes(x=factor(numprocs), y=netRF, color=factor(whichSNaQ), shape=factor(probQR), alpha=0.5))+
  labs(title="Mean HWCD (probQR x g)", y="HWCD", x="Number of processors")+
  #ylim(0,30)+
  geom_point(stat = "summary", fun = "mean", size=3)+
  facet_grid(numgt~propQuartets)+
  theme_half_open(12)+
  panel_border()







ggplot(data,aes(x=factor(numprocs),y = netRF, color=factor(whichSNaQ), shape=factor(probQR)))+
#  ylim(0,5)+
  geom_point(stat = "summary", 
             fun = "mean", 
             size=3)+
  facet_grid(numgt~propQuartets)


ggplot(data,aes(x=factor(numprocs),y = log(runtime), color=factor(whichSNaQ), fill=factor(probQR)))+
  #ylim(0,25)+
  geom_violin()+
  facet_grid(numgt~propQuartets)

ggplot(data,aes(x=factor(numprocs),y = netRF, color=factor(whichSNaQ), fill=factor(probQR)))+
  #ylim(0,1)+
  geom_violin()+
  facet_grid(numgt~propQuartets)

#runtime vs accuracy





#sanity check
data <- read.csv(file = 'n10r1.csv', header = TRUE)

data %>%
  filter(propQuartets == 1.0) %>%
  filter(probQR == 0) %>%
  ggplot(mapping = aes(x=factor(whichSNaQ),y=netRF,color=factor(probQR)))+
    geom_violin()

data %>%
  filter(propQuartets == 1.0) %>%
  filter(probQR == 0) %>%
  ggplot(mapping = aes(x=factor(whichSNaQ),y=netRF,color=factor(propQuartets)))+
  geom_violin()

data %>%
  filter(propQuartets == 1.0) %>%
  filter(probQR == 0) %>%
  ggplot(mapping = aes(x=factor(whichSNaQ),y=netRF,color=factor(numprocs)))+
  geom_violin()

data %>%
  filter(propQuartets == 1.0) %>%
  filter(probQR == 0) %>%
  ggplot(mapping = aes(x=factor(whichSNaQ),y=netRF,color=factor(numgt)))+
  geom_violin()

data %>%
  filter(propQuartets == 1.0) %>%
  filter(probQR == 0) %>%
  ggplot(mapping = aes(x=factor(whichSNaQ),y=runtime,color=factor(numprocs)))+
  geom_violin()

#results

#accuracy
#effect of propQuartets
ggplot(data=data, aes(x=factor(propQuartets),color=factor(whichSNaQ)))+
  geom_violin(aes(y = netRF))
#effect of propQR
ggplot(data=data, aes(x=factor(probQR),color=factor(whichSNaQ)))+
  geom_violin(aes(y = netRF))

#speed
data %>%
  filter(propQuartets == 1.0) %>%
  ggplot(aes(x=factor(numprocs),y = runtime/3600, color=factor(whichSNaQ)))+
  #ylim(0,20)+
  geom_violin()+
  facet_grid(numgt~probQR)

data %>%
  filter(propQuartets == 0.9) %>%
  ggplot(aes(x=factor(numprocs),y = runtime/3600, color=factor(whichSNaQ)))+
  #ylim(0,20)+
  geom_violin()+
  facet_grid(numgt~probQR)

data %>%
  filter(propQuartets == 0.7) %>%
  ggplot(aes(x=factor(numprocs),y = runtime/3600, color=factor(whichSNaQ)))+
  #ylim(0,20)+
  geom_violin()+
  facet_grid(numgt~probQR)

data %>%
  filter(propQuartets == 1.0) %>%
  ggplot(aes(x=factor(numprocs),y = netRF, color=factor(whichSNaQ)))+
  #ylim(0,20)+
  geom_violin()+
  facet_grid(numgt~probQR)


#data %>%
#  filter(propQuartets == 0.7) %>%
  ggplot(data,aes(x=factor(numprocs),y = runtime, color=factor(whichSNaQ), fill=factor(probQR)))+
  #ylim(0,20)+
  geom_violin()+
  facet_grid(numgt~propQuartets)

  ggplot(data=data, aes(x=factor(propQuartets),#factor(numprocs), 
                      color=factor(whichSNaQ)))+
#                      shape=factor(probQR),
                      #size=factor(propQuartets)))+
  geom_point(aes(y = netRF))+#,#netRF,majortreeRF,runtime/60
#             stat = "summary", 
#             fun = "mean", 
             #alpha=0.4)+
  theme_half_open()+
  facet_wrap(~numgt+probQR)

ggplot(data=data, aes(x=factor(numprocs), 
                      color=factor(whichSNaQ),
                      y=runtime)+
  geom_boxplot(aes(y=runtime))+
  theme_half_open()
#runtime (#steps ie. exhastiveness of space searching) vs accuracy  
#high comomplxity of network == more complex space == so many local optima
#==having propQR=1, high risk of stuck at local opt 
###EVI: reduced running time, and bad accuracy at propQR as net complexity increase

#propQuartes , 1, 0.9, 0.7 does not really matter in accuracy but
#ends the analysis faster

##Snaq1vs2: when we have more proc, snaq2 scales with processors
#accuracy--not much diff. in most cases


ggplot(data,aes(x=factor(numprocs), y=log(runtime), color=factor(whichSNaQ), shape=factor(probQR), alpha=0.5))+
  labs(title="Mean log running time n10r1", y="Log running time (sec)", x="Number of processors")+
  #ylim(0,30)+
  geom_point(stat = "summary", fun = "mean", size=3)+
  facet_grid(numgt~propQuartets)+
  theme_half_open(12)+
  panel_border()
