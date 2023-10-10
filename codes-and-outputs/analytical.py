import pandas as pd
import numpy as np

# LOAD THE DATA AND RENAME THE COLUMN
# ACCOUNT CSV FILE
df = pd.read_csv("../data/accounts.csv")

df.rename(columns={'id': 'account_id'}, inplace=True)
df.rename(columns={'date': 'open_date'}, inplace=True)

# REMOVE SPACES FROM COLUMN NAMES
df.rename(columns=lambda x: x.strip(), inplace=True)

# COUNT THE NUMBER OF MISSING VALUES IN EACH COLUMN; none
missing_values_num = df.isna().sum()

# TYPE CAST THE DATE COLUMN
df['open_date'] = pd.to_datetime(df['open_date'])

# LOAD DISTRCICT DATA AND GET THE DISTRICT NAME
district_df = pd.read_csv("./districts_py.csv")

df = pd.merge(df, district_df, on='district_id', how ='left')
df['district_id'] = df['name']

# CHANGE THE COLUMN NAME AND DROP THE COLUMNS
df.rename(columns={'district_id': 'district_name'}, inplace=True)
df = df.iloc[:, :4]

# LOAD THE LINKS DATA FOR NUM_CUSTOMERS COLUMN
link_df = pd.read_csv("../data/links.csv")
temp = pd.DataFrame(link_df.groupby('account_id')['client_id'].count())
temp = temp.rename(columns = {'client_id':'num_customers'})
transpose = temp.T
temp['account'] = transpose.columns

df= df.merge(temp, left_on = "account_id", right_on = "account", how = "left")
df = df.drop("account", axis = 1)

# CREDIT_CARDS
card_df = pd.read_csv("../data/cards.csv")
temp = link_df.merge(card_df, left_on = "id", right_on = "link_id", how = "left")

temp = pd.DataFrame(temp.groupby("account_id")['id_y'].count())
temp = temp.rename(columns = {"id_y": "credit_cards"})

column_extract = temp.T

column_extract
temp['account'] = column_extract.columns

pd.unique(temp['credit_cards'])

df = df.merge(temp, left_on = "account_id", right_on="account", how = "left")
df.drop("account", axis = 1, inplace = True)

# LOAN
loan_df = pd.read_csv("./loans_py.csv")
df = pd.merge(df,loan_df, on='account_id', how='outer')
df['loan'] = df['loan_id'].apply(lambda x: 'True' if pd.notna(x) else 'False')

# LOAN_AMOUNT
df.rename(columns={'amount':'loan_amount'}, inplace=True)

# LOAN PAYMENT
df.rename(columns={'payments':'loan_payment'}, inplace=True)

# LOAN_TERM
df.rename(columns={'terms':'loan_term'}, inplace=True)

# LOAN_STATUS
df['loan_status'] = df['status'].apply(lambda x: np.nan if pd.isna(x) else ("expired" if x == 'A' or x== 'B' else 'current')) # x: A, B, C, D, NaN / every row in loan_status

# LOAN_DEFAULT:
df['loan_default'] = df['status'].apply(lambda x: np.nan if pd.isna(x) else ('True' if x == 'B' or x== 'D' else 'False')) # x: A, B, C, D, NaN / every row in loan_status

# MAX_WITHDRAWAL
trans_df = pd.read_csv("../data/transactions.csv")

# return the maximum value of each account

# maximum value of debit
temp = trans_df[trans_df['type'] == 'debit'] # filter out
temp.groupby('account_id')

max_with = temp.groupby('account_id')['amount'].max()
max_with = pd.DataFrame(max_with)

df = pd.merge(df, max_with, on='account_id', how='left')
df.rename(columns = {'amount':'max_withdrawal'}, inplace=True)

min_with = temp.groupby('account_id')['amount'].min()
min_with = pd.DataFrame(min_with)

df = pd.merge(df, min_with, on='account_id', how='left')
df.rename(columns = {'amount':'min_withdrawal'}, inplace=True)

## CC payments
temp = trans_df[(trans_df['type'] == 'debit') & (trans_df['method'] == 'credit card')] # filter out
temp = temp.groupby('account_id')['amount'].count()

temp = pd.DataFrame(temp)

df = pd.merge(df, temp, on='account_id', how='left')
df.rename(columns = {'amount':'cc_payments'}, inplace=True)

# MAX BALANCE
temp = trans_df.groupby('account_id')['balance'].max() # filter out

max_bal = pd.DataFrame(temp)

df = pd.merge(df, max_bal, on='account_id', how='left')
df.rename(columns = {'balance':'max_balance'}, inplace=True)

# MIN BALANCE
temp = trans_df.groupby('account_id')['balance'].min() # filter out

min_bal = pd.DataFrame(temp)

df = pd.merge(df, min_bal, on='account_id', how='left')
df.rename(columns = {'balance':'min_balance'}, inplace=True)

columns_order = ['account_id', 'district_name', 'open_date','statement_frequency', 'num_customers', 'credit_cards', 'loan', 'loan_amount', 'loan_payment', 'loan_term', 'loan_status', 'loan_default','max_withdrawal','min_withdrawal','cc_payments','max_balance','min_balance']
df = df[columns_order]

df.to_csv('analytics_py.csv', index = False, encoding='utf-8') # open csv preview
