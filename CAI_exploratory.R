''' Using data analysis software (preferably R), describe this patient population. Create
some output either in the form of tables(s), graphs(s) etc. Show your code, including
exploratory analysis, and annotate throughout. '''

library(tidyverse)

# Load patient data
patient <- read_csv("/Users/lukie/Documents/concert_AI/Data/patient.csv", na = ".")

# condition <- read_csv("/Users/lukie/Documents/concert_AI/Data/condition.csv", na= ".")
# medication <- read_csv("/Users/lukie/Documents/concert_AI/Data/medication.csv", na = ".")
# biomarker <- read_csv("/Users/lukie/Documents/concert_AI/Data/biomarker.csv", na = ".")

# Take a look at raw data
head(patient)
# Looks like almost all of the date_of_death field is missing. Typical.

