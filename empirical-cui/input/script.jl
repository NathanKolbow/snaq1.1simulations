using PhyloNetworks

%ADD MAX PROCESSORS 

pqr=1 %fully weighted
pqt=0.7 %use a portion of quartets

t=readTopology("cui_etal_data.msbum.QMC.tre")
d=readTableCF("cui_etal_data.msbum.CFs.csv")

net0=snaq!(t,d,hmax=0,probQR=pqr,propQuartets=pqt,seed=42)
net1=snaq!(t,net0,hmax=1,probQR=pqr,propQuartets=pqt,seed=42)
net2=snaq!(t,net1,hmax=2,probQR=pqr,propQuartets=pqt,seed=42)
net3=snaq!(t,net2,hmax=3,probQR=pqr,propQuartets=pqt,seed=42)
net4=snaq!(t,net3,hmax=4,probQR=pqr,propQuartets=pqt,seed=42)
net5=snaq!(t,net4,hmax=5,probQR=pqr,propQuartets=pqt,seed=42)
