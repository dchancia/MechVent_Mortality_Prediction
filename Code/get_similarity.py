# Code created by: Daniela Chanci Arrubla
# Analyze patients' similarity and define links

import pandas as pd
import numpy as np
import math
import json
import matplotlib.pyplot as plt
import seaborn as sns
from scipy import spatial
from sklearn.metrics import jaccard_score
from sklearn.preprocessing import StandardScaler

# Load file
data = pd.read_csv('F:/Users/user/Desktop/EMORY/Classes/Spring_2022/CS_570/Project/clean_mv_dataset.csv')
data = data.iloc[:2000]

# Drop target
features = data.drop(['mech_expire_flag'], axis=1)

# Define lists
lab_list = ['bicarbonate_min', 'bicarbonate_max', 'creatinine_min', 'creatinine_max', 'chloride_min', 'chloride_max', 
'glucose_min', 'glucose_max', 'hematocrit_min', 'hematocrit_max', 'hemoglobin_min', 'hemoglobin_max', 'platelet_min',
'platelet_max', 'potassium_min', 'potassium_max', 'sodium_min', 'sodium_max', 'bun_min', 'bun_max', 'wbc_min', 'wbc_max']
com_list = ['congestive_heart_failure', 'hypertension', 'diabetes_uncomplicated', 'diabetes_complicated', 'metastatic_cancer',
'solid_tumor', 'peripheral_vascular', 'hypothyroidism', 'liver_disease', 'chronic_pulmonary', 'lymphoma', 'coagulopathy']

# Normalize lab values
scaler = StandardScaler()
features[lab_list] = pd.DataFrame(scaler.fit_transform(features[lab_list].values), columns=lab_list, index=features.index)

# Obtain Euclidean distance
e_dict = {}
e_list = []
for i in range(features.shape[0] - 1):
    for j in range(i+1, features.shape[0]):
        # Euclidean distance
        e = math.sqrt(np.sum((features.iloc[i][lab_list] - features.iloc[j][lab_list]) ** 2))
        e_dict[(i,j)] = e
        e_list.append(e)

# Obtain patient similarity
sim_dict = {}
for i in range(features.shape[0] - 1):
    for j in range(i+1, features.shape[0]):
        # Feature similarity for age
        FSA = min(features.iloc[i]['admission_age'], features.iloc[j]['admission_age']) / max(features.iloc[i]['admission_age'], features.iloc[j]['admission_age'])

        # Feature similarity for gender
        if (features.iloc[i]['female'] == features.iloc[j]['female']):
            FSS = 1
        else:
            FSS = 0
        
        # Feature similarity for lab tests
        FSL = 1 - ((e_dict[(i,j)] - min(e_list)) / (max(e_list) - min(e_list)))

        # Feature similarity for comorbidities
        FSC = 1 - spatial.distance.hamming(np.array(features.iloc[i][com_list]), np.array(features.iloc[j][com_list]))

        # Patient similarity
        PS = (0.4 * FSC) + (0.4 * FSL) + (0.1 * FSA) + (0.1 * FSS)
        sim_dict['(' + str(i) + ',' + str(j) + ')'] = PS

# Save similarities
with open("F:/Users/user/Desktop/EMORY/Classes/Spring_2022/CS_570/Project/similarities_2000.json", "w") as outfile:
    json.dump(sim_dict, outfile)