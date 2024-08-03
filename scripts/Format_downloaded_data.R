# Format_downloaded_data.R

# This script formats and cleans clinical and expression data.
# - Creates "CLIN.txt" ,dimension 192 x 13
# - Creates "EXPR.txt.gz", dimension 29485 x 192

# Load required libraries
library(data.table)

# Read clinical data
clin1 <- read.csv("source data/EGAD00001008548/EGAF00005797821/go28573_anon_subsetted_BYN_n192.csv") # dim 192 x 10
clin2 <- read.csv("source data/EGAD00001008548/EGAF00006143195/ss.csv") # 891 x 11

# Clean and prepare the data in one step
clin1 <- clin1[, colSums(!is.na(clin1)) > 0]
clin2 <- clin2[, colSums(!is.na(clin2)) > 0]
clin2$subjectId <- gsub("^PAT-", "", clin2$subjectId)
clin1$UNI_ID <- substr(clin1$UNI_ID, 1, 12)

# Merge clin1 and clin2
clin_merged <- merge(clin1, clin2, by.x = "UNI_ID", by.y = "subjectId") # dim 192 x 13

# Set patient column
colnames(clin_merged)[colnames(clin_merged) == "alias"] <- "patient"

# Add "EA-" prefix to the patient column
clin_merged$patient <- paste0("EA-", clin_merged$patient)

# Save clinical data as CLIN.txt
write.table(clin_merged, "files/CLIN.txt", quote = FALSE, sep = "\t", row.names = FALSE)

# Read and process expression data
expr <- as.data.frame(fread("source data/EGAD00001008390/EGAF00005797825/anonymized_POPLAR-TPMs2_n192.csv")) 

# Set Rownames as gene names
rownames(expr) <- expr[,1]
expr <- expr[, -1]

# Sort the rownames of 'expr'
expr <- expr[sort(rownames(expr)), ]

# Save expression data as EXPR.txt.gz
gz_conn <- gzfile("files/EXPR.txt.gz", "w")
write.table(expr, gz_conn, sep = "\t", row.names = TRUE, quote = FALSE)
close(gz_conn)
