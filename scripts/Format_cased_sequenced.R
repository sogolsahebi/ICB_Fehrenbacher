# File: Format_cased_sequnced.R
# Goal: Save cased_sequenced.csv, dimension 192 x 4

# Load the clinical merged data from the specified file path.
clin <- read.table("files/CLIN.txt", sep="\t", header=TRUE)

# Extract unique patients and sort them.
patient <- sort(unique(clin$patient))

# Initialize a data frame for 'case' with the unique patients and default values
case <- as.data.frame(cbind(patient, rep(0, length(patient)), rep(0, length(patient)), rep(0, length(patient))))
colnames(case) <- c("patient", "snv", "cna", "expr")
rownames(case) <- patient

# Convert the case values to numeric.
case$snv <- as.numeric(as.character(case$snv))
case$cna <- as.numeric(as.character(case$cna))
case$expr <- as.numeric(as.character(case$expr))

# Load the RNA data
expr <- read.csv("files/EXPR.txt.gz", stringsAsFactors=FALSE , sep="\t", check.names = FALSE)

# Check the overlap of patient IDs between the 'case' and 'expr' data
#sum(rownames(case) %in% colnames(expr))

# Update 'expr' column in 'case' if patient IDs in 'case' are in 'expr'
for(i in 1:nrow(case)) {
  if(rownames(case)[i] %in% colnames(expr)) {
    case$expr[i] = 1
  }
}

# Save the updated 'case' data frame to a CSV file.
write.table( case , "files/cased_sequenced.csv" , quote=FALSE , sep=";" , col.names=TRUE , row.names=FALSE )

