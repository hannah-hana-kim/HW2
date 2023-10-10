import pandas as pd
import numpy as np
import os 

df = pd.read_csv("../data/loans.csv")
df = df.rename(columns={'id':'loan_id'})

# REMOVE SPACES FROM COLUMN NAMES
df.rename(columns=lambda x: x.strip(), inplace=True)

# COUNT THE NUMBER OF MISSING VALUES IN EACH COLUMN; none
missing_values_num = df.isna().sum()

# CONVERT DATE COLUMN TO DATE FORMAT
df['date'] = pd.to_datetime(df['date'])

# MELT THE DATAFRAME AND DROP A COLUMN
melt_df = df.copy()
melt_df = melt_df.melt(id_vars=['loan_id','account_id','date','amount','payments'])
melt_df = melt_df.drop(melt_df[melt_df['value'] != 'X'].index)

# TYPE CAST THE ID COLUMN TO NUMERIC VALUE AND SORT
melt_df['loan_id'] = pd.to_numeric(melt_df['loan_id'])
melt_df = melt_df.sort_values(by='loan_id', ascending=True)

# DROP A COLUMN
melt_df = melt_df.drop(columns=['value'])

# SPLIT THE DATA INTO NEW COLUMNS
split_data = melt_df['variable'].str.split('_', expand=True)
melt_df['terms'] = split_data[0]
melt_df['status'] = split_data[1]

# DROP THE COLUMN
melt_df = melt_df.drop(columns=['variable'])

# SAVE THE DATAFRAME TO CSV FILE 
melt_df.to_csv('loans_py.csv', index = False, encoding='utf-8')