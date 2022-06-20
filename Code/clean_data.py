# Code created by: Daniela Chanci Arrubla
# Clean data extracted from MIMIC for Mechanically Ventilated Patients

import pandas as pd
import numpy as np
from sklearn.experimental import enable_iterative_imputer
from sklearn.impute import IterativeImputer

# Load file
data = pd.read_csv('F:/Users/user/Desktop/EMORY/Classes/Spring_2022/CS_570/Project/mv_dataset.csv')

# Drop subject_id, hadm_id, and icustay_id
data = data.drop(['subject_id', 'hadm_id', 'icustay_id', 'blood_loss_anemia', 'psychoses', 'deficiency_anemias', 'paralysis'], axis=1)

# Modify Gender Column (Female):
data['gender'] = data['gender'].replace(['F', 'M'], [1, 0])
data = data.rename(columns={'gender': 'female'})

# Initialize list to print
print_list = []
print_list.append('Initial dataset size: ' + str(data.shape) + '\n')

# Inspect Nan values
for column in data.columns:
    count_nan = data[column].isnull().sum()
    print_list.append(column + ' - Nan values: ' + str(count_nan) + ', Nan percentage: ' + str((count_nan/data.shape[0])*100))
    if (count_nan/data.shape[0])*100 > 20:
        print(column)

# Delete columns with more than 30% of Nan values
data = data.drop(['albumin_min', 'albumin_max', 'bands_min', 'bands_max', 'lactate_min', 'lactate_max'], axis=1)
print_list.append('\n' + 'Drop columns: albumin_min, albumin_max, bands_min, bands_max, lactate_min, and lactate_max' + '\n')

# Impute Nan values
imp = IterativeImputer(max_iter=20, random_state=0)
imp_data = imp.fit_transform(data)
imp_data = pd.DataFrame(imp_data, columns=data.columns)

print_list.append('Final dataset size: ' + str(imp_data.shape))

# Save CSV file
imp_data.to_csv('F:/Users/user/Desktop/EMORY/Classes/Spring_2022/CS_570/Project/clean_mv_dataset.csv', index=False)

# Save summary file
f = open('F:/Users/user/Desktop/EMORY/Classes/Spring_2022/CS_570/Project/data_summary.txt', 'w')
for elem in print_list:
    f.write(elem + '\n')
f.close()