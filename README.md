## New Pipeline Parameters

- ILS: med
- probQR: 0, 0.5, 1
- propQuartets: 1, 0.9, 0.7
- topologies: n10h1, n10h3, n20h1, n20h3
- ngt: 300, 1000, 3000
- processors: 16, 8, 4

Bash script for `n20r1`, 16 processors (started on `21 Nov 2023, 11:32 AM`):

```bash
for ils in med
do
    for ngt in 300 1000 3000
    do
        ./run-one.sh "n20r1" ../results/results.csv $ngt 16 $ils
    done
done
```