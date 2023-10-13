#sungsik kong 2023

# assuming you have python script from Erin Molloy fastMULrfs to run compare_two_trees.py.
# assuming you are at the folder with two files:
#	sim_gene.trees: a file that contains the list of simulated gene trees (in newick)
#	iq_genetrees.tree: a file that contains the list of estimated gene trees from iqtree

for ngenes in 500 1000 3000 5000  #number of gene trees in the data
    do
    for rep in {1..100}
        do
		#check if two files has same number of gene trees. Sometimes some run in iqtree fails and end up having different number of gene trees.
        if [ "$(wc -l < sim_gene.trees)" -eq "$(wc -l < iq_genetrees.treefile)" ]; then echo 'Match!'; else echo 'Warning: No Match!'; fi 
            for i in $(eval echo "{1..$ngenes}")
            do
                sed "${i}q;d" sim_gene.trees > temp1_sim_gene_$i.txt #extract nth tree from sim gene trees and store it to temp1_sim_gene_$i.txt
                sed "${i}q;d" iq_genetrees.trees > temp1_iq_gene_$i.txt #extract nth tree from iq gene trees and store it to temp1_iq_gene_$i.txt

				#get normalized rf distance between the two trees and store that value for all gene trees to gtee.csv
                python compare_two_trees.py -t1 temp1_sim_gene_$i.txt -t2 temp1_iq_gene_$i.txt >> gtee.csv

                rm temp1* #remove temp1 files
            done
			#get all distances for all 100 reps
            cat gtee.csv >> ../full_gtee_sc1_$ngenes.csv
        done
    done
