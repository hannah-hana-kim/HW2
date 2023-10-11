library('tidyverse')
library('reshape2')

# READ THE DATA
df <- read.csv("../data/loans.csv")

# RENAME THE ID COLUMN
df <- df %>%
        rename(loan_id = id)

# REMOVE SPACES FROM COLUMN NAMES
colnames(df) <- gsub(" ", "", colnames(df))

# CONVERT DATE COLUMN TO DATE FORMAT
df$date <- as.Date(df$date)

# CHANGE THE COLUMN NAME
colnames(df) <- gsub("X", "", colnames(df))

# MELT THE DATAFRAME AND DROP A COLUMN
melt_df <- df
melt_df <- melt(melt_df, id.vars = c('loan_id', 'account_id', 'date', 'amount', 'payments'))
melt_df <- subset(melt_df, value == 'X')

# REPLACE ALL CELLS THAT ARE ENTIRELY SPACE (OR EMPTY) WITH NAN 
melt_df <- apply(melt_df, 2, function(x) ifelse(grepl("^\\s*$", x), NA, x))

# COUNT THE NUMBER OF MISSING VALUES IN EACH COLUMN; none
missing_values_num <- colSums(is.na(melt_df))

# TYPE CAST THE MATRIX TO DATA FRAME
melt_df <- as.data.frame(melt_df)

# TYPE CAST THE ID COLUMN TO NUMERIC VALUE AND SORT
melt_df$loan_id <- as.numeric(melt_df$loan_id)
melt_df <- melt_df[order(melt_df$loan_id), ]

# DROP A COLUMN
melt_df <- melt_df[, -ncol(melt_df)]

# SPLIT THE DATA INTO NEW COLUMNS
split_data <- strsplit(as.character(melt_df$variable), "_", fixed = TRUE)

melt_df$terms <- sapply(split_data, `[`, 1)
melt_df$status <- sapply(split_data, `[`, 2)

# DROP THE COLUMN
melt_df <- subset(melt_df, select = -c(variable))

# SAVE THE DATAFRAME TO CSV FILE 
write.csv(melt_df, file = 'loans_r.csv', row.names = FALSE, fileEncoding = 'UTF-8')