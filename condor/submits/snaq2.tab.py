for netabbr in ["n10r1", "n10r3", "n20r1", "n20r3"]:
    with open(f"snaq2-{netabbr}.tab", "w") as file:
        for ngt in [300, 1000, 3000]:
            for rep in range(100):
                for probQR in [0, 0.5, 1]:
                    for propQuartets in [1, 0.9, 0.7]:
                        repnum = rep + 1
                        file.write(f"{netabbr},{ngt},16,med,{repnum},{probQR},{propQuartets}\n")
                        file.write(f"{netabbr},{ngt},8,med,{repnum},{probQR},{propQuartets}\n")
                        file.write(f"{netabbr},{ngt},4,med,{repnum},{probQR},{propQuartets}\n")