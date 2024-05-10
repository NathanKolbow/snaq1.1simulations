library(ggplot2)
library(cowplot)

data<-read.csv("n10r1.csv")
data<-read.csv("n10r3.csv")
data<-read.csv("n20r1.csv")
data<-read.csv("n20r3.csv")

ggplot(data=data, aes(x=factor(numprocs), 
                      color=factor(whichSNaQ),
                      shape=factor(probQR),
                      size=factor(propQuartets)))+
  geom_point(aes(y = netRF),#netRF,majortreeRF,runtime/60
             stat = "summary", 
             fun = "mean", 
             alpha=0.4)+
  theme_half_open()+
  facet_wrap(~numgt+ils)
  