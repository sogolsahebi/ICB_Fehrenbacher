# Rna-seq Data Processing
# File: Save Format_EXPR.csv (dimension is 29485 x 192)

# Read libraries
library(data.table)

# Data Reading
# expr is Log2(TPM + 1)
expr <- as.data.frame(fread("files/EXPR.txt.gz", sep = "\t", dec = ",", stringsAsFactors = FALSE))

# Set the first column as row names
rownames(expr) <- expr[, 1]
expr <- expr[, -1] # dimension is 29485 x 192

# Convert to numeric
expr[] <- lapply(expr, function(x) as.numeric(as.character(x)))

# Convert Log2(TPM + 1) to Log2(TPM + 0.001)
expr <- log2((2^expr - 1) + 0.001)   # range of expr is -9.965784 to 17.734833

# Data Filtering
case <- read.csv("files/cased_sequenced.csv", sep = ";")

# Filter the 'expr' dataset to include patients with expr value of 1 in the 'case' dataset
expr <- expr[, colnames(expr) %in% case[case$expr == 1, ]$patient]
expr <- as.data.frame(lapply(expr, as.numeric), row.names = rownames(expr))

# Write the transformed data to a CSV file
write.table(expr, "files/EXPR.csv", quote = FALSE, sep = ";", col.names = TRUE, row.names = TRUE)
