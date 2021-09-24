# Using data analysis software (preferably R), describe this patient population. Create
# some output either in the form of tables(s), graphs(s) etc. Show your code, including
# exploratory analysis, and annotate throughout.

library(tidyverse)
library(gridExtra)
library(corrplot)

# Load all tables
patient <- read_csv("/Users/lukie/Documents/concert_AI/Data/patient.csv", na = ".")
condition <- read_csv("/Users/lukie/Documents/concert_AI/Data/condition.csv", na= ".")
medication <- read_csv("/Users/lukie/Documents/concert_AI/Data/medication.csv", na = ".")
biomarker <- read_csv("/Users/lukie/Documents/concert_AI/Data/biomarker.csv", na = ".")

# Take a look at raw data
head(patient)
# Looks like almost all of the date_of_death field is missing!

# make some simple histograms to get an idea of data distributions
# throw on some colored legends since the names are clunky
gend_hist <- ggplot(data = patient) + 
  geom_bar(mapping = aes(x = gender, fill = gender))

race_hist <- ggplot(data = patient) + 
  geom_bar(mapping = aes(x = race, fill = race))

ethn_hist <- ggplot(data = patient) + 
  geom_bar(mapping = aes(x = ethnicity, fill = ethnicity))

combine_hist <- ggplot(data = patient) + 
  geom_bar(mapping = aes(x = gender, color = ethnicity), fill = NA, position = 'identity') +
  facet_grid(~ race)

# plot together to see univariate histograms and stratified by gender, race, and ethnicity
grid.arrange(gend_hist, ethn_hist, race_hist, combine_hist, ncol = 2)

#--------------------------------------------------------------------------------#
# Let's get an idea of some simple morbidity and healthcare resource utilization
#--------------------------------------------------------------------------------#

# first get simple counts of conditions, medications, and biomarkers
cond_count <- condition %>% count(patient_id) %>% rename(num_conditions = n)
med_count <- medication %>%  count(patient_id) %>% rename(num_medications = n)
biom_count <- biomarker %>% count(patient_id) %>% rename(num_biomarkers = n)


# add counts to patient table to investigate
morbidity_tab <- patient %>%
  left_join(cond_count, by = "patient_id") %>% 
  left_join(med_count, by = "patient_id") %>% 
  left_join(biom_count, by = "patient_id")

# Get an idea of how co-linear these rough measures are
ggplot(data = morbidity_tab) + 
  geom_point(mapping = aes(x = num_conditions, y= num_medications, color = num_biomarkers)) 

# There are some super notable outliers in num_conditions that maybe aren't real, let's look without them
# and also get some univariate boxplots to look at spread of these measures
cond_v_med <- ggplot(data = filter(morbidity_tab, num_conditions < 250)) + 
  geom_point(mapping = aes(x = num_conditions, y= num_medications, color = num_biomarkers)) 
cond_box <- ggplot(data = filter(morbidity_tab, num_conditions < 250)) +
  geom_boxplot(mapping = aes(x=num_conditions),notch=TRUE, orientation = "x")


# Ok, so it looks like num_conditions and num_medications are highly correlated, but I think its kind of
# unclear what their respective correlations look like in relation to biomarkers, lets plot a quick correlation
# matrix just to check it out. Ill use casewise deletion for biomarkers. I know that there are at least4 
# patients with no biomarkers, so theyll be null

#create full correlation matrix
cormat <- cor(select(morbidity_tab, num_conditions, num_medications, num_biomarkers), use = "complete.obs")
corplot <- corrplot(cormat, addCoef.col = 'black',type = "full", order = "hclust", 
         tl.col = "black", tl.srt = 45)

# Out of curiosity, what are the VIFs?
mod1 <- lm(num_conditions ~ num_medications + num_biomarkers, data = filter(morbidity_tab, num_conditions < 250))
summary(mod1)
car::vif(mod1)
















