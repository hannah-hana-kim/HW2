import pandas as pd
import numpy as np

# LOAD THE DATA AND RENAME THE 'ID' COLUMN
df = pd.read_csv("../data/districts.csv")
df.rename(columns={'id': 'district_id'}, inplace=True)

# COPY THE DATAFRAME AND CHANGE THE COLUMN NAME
new_df = df.copy()
new_df.rename(columns={'municipality_1': 'pop_500'}, inplace=True)
new_df.rename(columns={'municipality_2': 'pop_500_1999'}, inplace=True)
new_df.rename(columns={'municipality_3': 'pop_2000_9999'}, inplace=True)
new_df.rename(columns={'municipality_4': 'pop_10000'}, inplace=True)

# REMOVE SPACES FROM COLUMN NAMES
new_df.rename(columns=lambda x: x.strip(), inplace=True)

# REPLACE ALL CELLS THAT ARE ENTIRELY SPACE (OR EMPTY) WITH NAN 
new_df.replace(r'^\s*$', np.nan, regex=True, inplace = True) # regex: regular expression

# COUNT THE NUMBER OF MISSING VALUES IN EACH COLUMN; none
missing_values_num = new_df.isna().sum()
print(missing_values_num)

# SPLIT THE STRING IN 'UNEMPLOYMENT_RATE' COLUMN AND PUT IT IN A NEW COLUMN
split_data = new_df['unemployment_rate'].str.split(',', expand=True)
new_df['unemployment_rate_95'] = split_data[0]
new_df['unemployment_rate_96'] = split_data[1]

# DROP THE OLD COLUMN
new_df = new_df.drop(columns=['unemployment_rate'])

# CLEAN THE DATA IN THE NEW COLUMN
new_df['unemployment_rate_95'] = new_df['unemployment_rate_95'].str.replace('[', '')
new_df['unemployment_rate_96'] = new_df['unemployment_rate_96'].str.replace(']', '')

# SPLIT THE STRING IN 'COMMITED_CRIMES' COLUMN AND PUT IT IN A NEW COLUMN
split_data = new_df['commited_crimes'].str.split(',', expand=True)
new_df['commited_crimes_95'] = split_data[0]
new_df['commited_crimes_96'] = split_data[1]

# DROP THE OLD COLUMN
new_df = new_df.drop(columns=['commited_crimes'])

# CLEAN THE DATA IN THE NEW COLUMN
new_df['commited_crimes_95'] = new_df['commited_crimes_95'].str.replace('[', '')
new_df['commited_crimes_96'] = new_df['commited_crimes_96'].str.replace(']', '')

# SAVE THE DATA IN THE FILE
new_df.to_csv('districts_py.csv', index = False, encoding='utf-8')