# Clinical Data Processing
# Goal: save CLIN.csv (dimensions: 192 x 26).
# Data Curation for Clinical Data

# Libraries and Source Files
library(tibble)

# Source clinical data processing functions from GitHub
source("https://raw.githubusercontent.com/BHKLAB-Pachyderm/ICB_Common/main/code/Get_Response.R")
source("https://raw.githubusercontent.com/BHKLAB-Pachyderm/ICB_Common/main/code/format_clin_data.R")
source("https://raw.githubusercontent.com/BHKLAB-Pachyderm/ICB_Common/main/code/annotate_tissue.R")
source("https://raw.githubusercontent.com/BHKLAB-Pachyderm/ICB_Common/main/code/annotate_drug.R")

# Loading Clinical Data
clin_original <- read.csv("files/CLIN.txt", stringsAsFactors = FALSE, sep = "\t") # dim 192 x 13

# Selecting specific Columns 
selected_cols <- c("patient", "ACTARM", "HIST", "OS_CENSOR", "OS_MONTHS", "PFS_CENSOR", "PFS_MONTHS", "gender","BCOR"  )

#Combine selected columns with additional columns.
clin <- cbind(clin_original[,selected_cols ], "Lung", "rnaseq", "tpm", NA, NA, NA, NA, NA, NA)

# Set new column names.
colnames(clin) <- c("patient", "drug_type", "histo", "os", "t.os", "pfs","t.pfs", "sex", "recist", "primary", "rna", "rna_info", "response.other.info", "age", "stage", "dna", "dna_info", "response")

# Replace 'female' with 'F' and 'male' with 'M' in the 'sex' column
clin$sex <- ifelse(clin$sex == "female", "F", "M")

# Define "response" based on values in "recist"
clin$response <- Get_Response(data = clin) 

# Reordering Columns for Structured Data
clin <- clin[, c("patient", "sex", "age", "primary", "histo", "stage", "response.other.info", "recist", "response", "drug_type", "dna","dna_info", "rna","rna_info", "t.pfs", "pfs", "t.os", "os")]

# Formatting clinical data using a custom function
clin <- format_clin_data(clin_original, "patient", selected_cols, clin)

# Annotating Tissue Data
# Survival_unit and survival_type columns will be added in annotate_tissue
annotation_tissue <- read.csv("https://raw.githubusercontent.com/BHKLAB-DataProcessing/ICB_Common/main/data/curation_tissue.csv")
clin <- annotate_tissue(clin=clin, study='Fehrenbacher', annotation_tissue= annotation_tissue, check_histo=FALSE)

# Set treatmentid based on curation_drug.csv file.
annotation_drug <- read.csv("https://raw.githubusercontent.com/BHKLAB-DataProcessing/ICB_Common/main/data/curation_drug.csv")
clin <- add_column(clin, treatmentid=annotate_drug('Fehrenbacher', clin$drug_type, annotation_drug), .after='tissueid')

# Update 'drug_type' column based  category for specific 'treatmentid'
clin$drug_type[clin$treatmentid == 'Docetaxel' ] <- 'chemo'
clin$drug_type[clin$treatmentid == 'Atezolizumab'] <- 'PD-1/PD-L1'

# Save the processed data as CLIN.csv file
write.table(clin, "files/CLIN.csv", quote=TRUE, sep=";", col.names=TRUE, row.names=FALSE)



