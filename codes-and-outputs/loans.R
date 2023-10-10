library('tidyverse')

# READ THE DATA
df <- read.csv("../data/loans.csv")
head(df)
# CHANGE THE 'ID' COLUMN NAME TO 'LOAN_ID'
colnames(df)[1] <- 'loan_id'

# REMOVE SPACES FROM COLUMN NAMES
names(df) <- gsub(" ", "", names(df))

# CONVERT DATE COLUMN TO DATE FORMAT
df$date <- as.Date(df$date)

# MELT THE DATAFRAME AND DROP A COLUMN
melt_df <- df %>% pivot_longer(cols = c(-religion), names_to = 'income_groups', values_to = 'counts')