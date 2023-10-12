# import library
library('tidyverse')
library('reshape2')
library('dplyr')

# READ THE DATA
df <- read.csv("../data/accounts.csv")

# RENAME THE ID COLUMN
df <- df %>% rename(account_id = id)
df <- df %>% rename(open_date = date)

# REMOVE SPACES FROM COLUMN NAMES
colnames(df) <- gsub(" ", "", colnames(df))

# COUNT THE NUMBER OF MISSING VALUES IN EACH COLUMN; none
missing_values_num <- colSums(is.na(df))

# TYPE CAST THE MATRIX TO DATA FRAME
df <- as.data.frame(df)

# TYPE CAST THE DATE COLUMN
df$open_date <- as.Date(df$open_date, format = "%m/%d/%y")

# LOAD DISTRCICT DATA, MERGE TO THE MAIN DATA AND CHANGE THE COLUMN NAME
district_df <- read.csv("./districts_r.csv")
df <- left_join(df, district_df, by = "district_id")

# CHANGE THE COLUMN FROM DISTRICT_ID TO DISTRICT_NAME
df$district_id <- df$name
df <- df %>% rename(district_name = district_id)
df <- df[,c("account_id", "district_name", "open_date", "statement_frequency")]

# LOAD THE LINKS DATA FOR NUM_CUSTOMERS COLUMN
link_df <- read.csv("../data/links.csv")
temp <- data.frame(table(link_df$account_id))
names(temp) <- c("account_id", "num_customers")
df <- merge(df, temp, by.x = "account_id", by.y = "account_id", all.x = TRUE)

# CREDIT CARDS
card_df <- read.csv("../data/cards.csv")
temp <- merge(link_df, card_df, by.x = "id", by.y = "link_id", all.x = TRUE)
temp <- aggregate(id.y ~ account_id, data = temp, FUN = length)
names(temp) <- c("account_id", "credit_cards")
df <- left_join(df, temp, by = "account_id")

# LOAN
loan_df <- read.csv("./loans_r.csv")
df <- merge(df, loan_df, by = "account_id", all.x = TRUE)
df <- df %>%
  mutate(loan = ifelse(!is.na(loan_id), 'True', 'False'))
df <- df[, !(names(df) %in% c("loan_id"))]

# LOAN_AMOUNT
df <- df %>% rename(loan_amount = amount)

# LOAN PAYMENT
df <- df %>% rename(loan_payment = payments)

# LOAN TERM
df <- df %>% rename(loan_term = terms)

# LOAN STATUS
df$loan_status <- ifelse(is.na(df$status), NA,
                         ifelse(df$status %in% c('A', 'B'), 'expired', 'current'))

# LOAN_DEFAULT:
df$loan_default <- ifelse(is.na(df$status), NA,
                          ifelse(df$status %in% c('B', 'D'), 'True', 'False'))

# MAX WITHDRAWAL
trans_df <- read.csv("../data/transactions.csv")

max_withdrawal <- aggregate(trans_df$amount[trans_df$type == 'debit'],
                            by=list(account_id=trans_df$account_id[trans_df$type == 'debit']),
                            FUN=max)

colnames(max_withdrawal) <- c("account_id", "max_withdrawal")
df <- merge(df, max_withdrawal, by="account_id", all.x=TRUE)

# MIN WITHDRAWAL
min_withdrawal <- aggregate(trans_df$amount[trans_df$type == 'debit'],
                            by=list(account_id=trans_df$account_id[trans_df$type == 'debit']),
                            FUN=min)

colnames(min_withdrawal) <- c("account_id", "min_withdrawal")
df <- merge(df, min_withdrawal, by="account_id", all.x=TRUE)

## CC payments
temp <- trans_df[trans_df$type == 'debit' & trans_df$method == 'credit card', ]
cc_payments <- aggregate(temp$amount, by=list(account_id=temp$account_id), FUN=length)
colnames(cc_payments) <- c("account_id", "cc_payments")

df <- merge(df, cc_payments, by="account_id", all.x=TRUE)

# MAX BALANCE
temp <- aggregate(balance ~ account_id, data = trans_df, FUN = max)
max_bal <- data.frame(account_id = temp$account_id, max_balance = temp$balance)
df <- merge(df, max_bal, by = 'account_id', all.x = TRUE)
names(df)[names(df) == 'balance'] <- 'max_balance'

# MIN BALANCE
temp <- aggregate(balance ~ account_id, data = trans_df, FUN = min)
min_bal <- data.frame(account_id = temp$account_id, min_balance = temp$balance)
df <- merge(df, min_bal, by = 'account_id', all.x = TRUE)
names(df)[names(df) == 'balance'] <- 'min_balance'

# LAST CLEANING
columns_order <- c('account_id', 'district_name', 'open_date', 'statement_frequency', 'num_customers', 'credit_cards', 'loan', 'loan_amount', 'loan_payment', 'loan_term', 'loan_status', 'loan_default', 'max_withdrawal', 'min_withdrawal', 'cc_payments', 'max_balance', 'min_balance')

df <- df[columns_order]

# WRITE CSV FILE
write.csv(df, file = "analytics_r.csv", row.names = FALSE, fileEncoding = "UTF-8")