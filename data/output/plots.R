library(magrittr) # needs to be run every time you start R and want to use %>%
library(dplyr)    # alternatively, this also loads %>%
library(ggplot2)
library(cowplot)



#results - n10h1

#log running time n10r1
data<-read.csv("n10r1.csv")
data<-read.csv("n10r3.csv")
data<-read.csv("n20r1.csv")
data<-read.csv("n20r3.csv")


ggplot(data,aes(x=factor(numprocs), y=log(runtime), color=factor(whichSNaQ), fill=factor(propQuartets)))+
  labs(title="Log running time (probQR x g)", y="Log running time (sec)", x="Number of processors")+
  scale_color_grey()+
  geom_violin()+
  facet_grid(numgt~probQR)+
  theme_half_open(12)+
  panel_border()
  
ggplot(data,aes(x=factor(numprocs), y=netRF, color=factor(whichSNaQ), fill=factor(propQuartets)))+
  labs(title="HWCD (probQR x g)", y="HWCD", x="Number of processors")+
  scale_color_grey()+
  #ylim(0,10)+
  geom_violin()+
  facet_grid(numgt~probQR)+
  theme_half_open(12)+
  panel_border()















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






#EVOLUTION
library(ggpubr)

data1<-read.csv("n10r1.csv")
data2<-read.csv("n10r3.csv")
data3<-read.csv("n20r1.csv")
data4<-read.csv("n20r3.csv")

a<-data1 %>%
  filter(propQuartets == 1) %>%
  filter(whichSNaQ==1) %>%  
  filter(numprocs==4) %>%    
  ggplot(aes(x=factor(numgt),y = runtime/3600))+
  labs(title="n=10, h=2", 
       y="Time (h)", 
       x="Number of loci")+
  geom_boxplot()+
  ylim(0,10)+
  geom_hline(yintercept=0.4, linetype="dashed", 
             color = "red", size=1)+
  annotate("text", x=0.5, y=0.85, label="0.5", color="red")+
  theme_cowplot(12)

b<-data2 %>%
  filter(propQuartets == 1) %>%
  filter(whichSNaQ==1) %>%  
  filter(numprocs==4) %>%    
  ggplot(aes(x=factor(numgt),y = runtime/3600))+
  labs(title="n=10, h=3", 
       y="Time (h)", 
       x="Number of loci")+
  geom_boxplot()+
  ylim(0,10)+
  geom_hline(yintercept=1.5, linetype="dashed", 
             color = "red", size=1)+
  annotate("text", x=0.5, y=2, label="1.5", color="red")+
  theme_cowplot(12)

c<-data3 %>%
  filter(propQuartets == 1) %>%
  filter(whichSNaQ==1) %>%  
  filter(numprocs==4) %>%    
  ggplot(aes(x=factor(numgt),y = runtime/3600))+
  labs(title="n=20, h=1", 
       y="Time (h)", 
       x="Number of loci")+
  geom_boxplot()+
  ylim(0,125)+
  geom_hline(yintercept=24, linetype="dashed", 
             color = "red", size=1)+
  annotate("text", x=0.5, y=30, label="24", color="red")+
  theme_cowplot(12)

d<-data4 %>%
  filter(propQuartets == 1) %>%
  filter(whichSNaQ==1) %>%  
  filter(numprocs==4) %>%    
  ggplot(aes(x=factor(numgt),y = runtime/3600))+
  labs(title="n=20, h=3", 
       y="Time (h)", 
       x="Number of loci")+
  geom_boxplot()+
  ylim(0,125)+
  geom_hline(yintercept=48, linetype="dashed", 
             color = "red", size=1)+
  annotate("text", x=0.5, y=53, label="48", color="red")+
  theme_cowplot(12)

ggarrange(a,b,c,d,
          labels = c("A", "B", "C", "D"),
          ncol = 2, nrow = 2)

data4 %>%
  filter(probQR == 0) %>%
  filter(numgt == 3000) %>%  
  ggplot(aes(x=factor(numprocs), y=log(runtime/3600), color=factor(whichSNaQ), fill=factor(propQuartets)))+
  labs(title="Log running time (n=20, h=3, gt=3000, probQR=0)", y="Log running time (h)", x="Number of processors")+
  scale_color_manual(values=c("red", "blue"))+
  scale_fill_manual(values=c("#999999", "#777777", "#555555", "#333333"))+
  geom_violin()+
  labs(fill = "propQuartets")+
  labs(color = "SNaQ version")+  
#  facet_grid(numgt~probQR)+
  theme_half_open(12)+
  panel_border()

data3 %>%
  #filter(probQR == 0) %>%
  filter(numgt == 3000) %>%  
  ggplot(aes(x=factor(numprocs), y=log(runtime/3600), color=factor(whichSNaQ), fill=factor(propQuartets)))+
  labs(title="Log running time (n=20, h=3, gt=3000)", y="Log running time (h)", x="Number of processors")+
  scale_color_manual(values=c("red", "blue"))+
  scale_fill_manual(values=c("#999999", "#777777", "#555555", "#333333"))+
  geom_violin()+
  labs(fill = "propQuartets")+
  labs(color = "SNaQ version")+  
  facet_grid(numgt~probQR)+
  theme_half_open(12)+
  panel_border()

data2 %>%
  filter(probQR == 0) %>%
  filter(numgt == 3000) %>%  
  ggplot(aes(x=factor(numprocs), y=netRF, color=factor(whichSNaQ), fill=factor(propQuartets)))+
  labs(title="Accuracy (n=10, h=3, gt=3000, probQR=0)", y="HWCD", x="Number of processors")+
  scale_color_manual(values=c("red", "blue"))+
  scale_fill_manual(values=c("#999999", "#777777", "#555555", "#333333"))+
  #ylim(0,10)+
  geom_violin()+
  labs(fill = "propQuartets")+
  labs(color = "SNaQ version")+    
  #facet_grid(numgt~probQR)+
  theme_half_open(12)+
  panel_border()

data2 %>%
  filter(probQR == 0) %>%
  #filter(numgt == 3000) %>%  
  ggplot(aes(x=factor(numprocs), y=netRF, color=factor(whichSNaQ), fill=factor(propQuartets)))+
  labs(title="Accuracy (n=10, h=3, probQR=0)", y="HWCD", x="Number of processors")+
  scale_color_manual(values=c("red", "blue"))+
  scale_fill_manual(values=c("#999999", "#777777", "#555555", "#333333"))+
  #ylim(0,10)+
  geom_violin()+
  labs(fill = "propQuartets")+
  labs(color = "SNaQ version")+    
  facet_grid(numgt~probQR)+
  theme_half_open(12)+
  panel_border()

empdata<-read.csv("/Users/khaosan/Dropbox/sungsik.kong-UWisc/2024-Evolution/talk/Figures/output-data.csv")

ggplot(empdata,aes(x = factor(nhybrids), y = (runtime/3600), color=factor(whichSNaQ)))+
  geom_point()+
  ylim(0,75)+  
  labs(color = "SNaQ version",y="Time (h)", x="Number of reticulations (hmax)")+   
  theme_half_open(12)

ggplot(empdata,aes(x = factor(nhybrids), y = (negloglik), color=factor(whichSNaQ)))+
  geom_point()+
  #ylim(0,75)+  
  labs(color = "SNaQ version",y="-log likelihood", x="Number of reticulations (hmax)")+   
  theme_half_open(12)
