with open("treefile_generation.tab", "w") as file:
    for netabbr in ["n10r1", "n10r3", "n20r1", "n20r3"]:
        for rep in range(100):
            repnum = rep + 1
            file.write(f"{netabbr},med,8,{repnum}\n")