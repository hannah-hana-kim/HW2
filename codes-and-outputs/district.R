library('tidyverse')
library('reshape2')

# READ THE DATA
df <- read.csv("../data/districts.csv")

# RENAME THE ID COLUMN
df <- df %>%
        rename(district_id = id)

# COPY THE DATAFRAME AND CHANGE THE COLUMN NAME
new_df <- df %>%
  rename(
    pop_500 = municipality_1,
    pop_500_1999 = municipality_2,
    pop_2000_9999 = municipality_3,
    pop_10000 = municipality_4
  )

# REMOVE SPACES FROM COLUMN NAMES
colnames(new_df) <- gsub(" ", "", colnames(new_df))

# REPLACE ALL CELLS THAT ARE ENTIRELY SPACE (OR EMPTY) WITH NAN 
new_df <- apply(new_df, 2, function(x) ifelse(grepl("^\\s*$", x), NA, x))

# COUNT THE NUMBER OF MISSING VALUES IN EACH COLUMN; none
missing_values_num <- colSums(is.na(new_df))

# TYPE CAST THE MATRIX TO DATA FRAME
new_df <- as.data.frame(new_df)

# SPLIT THE STRING IN 'UNEMPLOYMENT_RATE' COLUMN AND PUT IT IN A NEW COLUMN
split_data <- strsplit(new_df$unemployment_rate, ",")
new_df$unemployment_rate_95 <- sapply(split_data, "[", 1)
new_df$unemployment_rate_96 <- sapply(split_data, "[", 2)

# DROP THE OLD COLUMN
new_df <- subset(new_df, select = -c(unemployment_rate))

# CLEAN THE DATA IN THE NEW COLUMN
new_df$unemployment_rate_95 <- gsub("\\[", "", new_df$unemployment_rate_95)
new_df$unemployment_rate_96 <- gsub("\\]", "", new_df$unemployment_rate_96)

# SPLIT THE STRING IN 'UNEMPLOYMENT_RATE' COLUMN AND PUT IT IN A NEW COLUMN
split_data <- strsplit(new_df$commited_crimes, ",")
new_df$commited_crimes_95 <- sapply(split_data, "[", 1)
new_df$commited_crimes_96 <- sapply(split_data, "[", 2)

# DROP THE OLD COLUMN
new_df <- subset(new_df, select = -c(commited_crimes))

# CLEAN THE DATA IN THE NEW COLUMN
new_df$commited_crimes_95 <- gsub("\\[", "", new_df$commited_crimes_95)
new_df$commited_crimes_96 <- gsub("\\]", "", new_df$commited_crimes_96)

# SAVE THE DATAFRAME TO CSV FILE 
write.csv(new_df, file = 'districts_r.csv', row.names = FALSE, fileEncoding = 'UTF-8')