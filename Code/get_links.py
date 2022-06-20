# Code created by: Daniela Chanci Arrubla
# Analyze patients' similarity and define links

import json

# Extract patients with similarity > 0.8
with open('F:/Users/user/Desktop/EMORY/Classes/Spring_2022/CS_570/Project/similarities.json') as json_file:
    data = json.load(json_file)

sim_dict_80 = {}
for pair in list(data.keys()):
    if data[pair] >= 0.8:
        sim_dict_80[pair] = data[pair]

# Save similarities
with open("F:/Users/user/Desktop/EMORY/Classes/Spring_2022/CS_570/Project/similarities_80.json", "w") as outfile:
    json.dump(sim_dict_80, outfile)