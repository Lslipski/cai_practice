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
grid.arrange(ethn_hist, race_hist, gend_hist, widths = c(1,1), ncol = 2,
             layout_matrix = rbind(c(1, 1),
                                   c(2, 0)))
combine_hist

# These plots give a rough outline of the population of the data set. Almost 100% of the patients are female, which
# is expected, given the incidence of breast cancer in men (https://www.cdc.gov/cancer/breast/men/index.htm). The 
# majority of patients are not hispanic or latino, although about a quarter of the of all patients are either Hispanic,
# Latino, or of unknown ethnicity. About 3/4 of the population is white, but notably, the next most frequent race category
# is unknown. (Sidenote: this is such an important determinant of health, I've always wondered about trying to use zip code
# to try and estimate income as a proxy since the two are historically related). Black and African American people make
# up about 1/8th of the population, and Asian and American Indian or Alaska Natives make up roughly the final 1/8th together.
#
# Finally, I overlayed gender and ethnicity and stratified by race just to see if there was any surprising. The only male-
# identifying person was white, which is expected given the skew in race. People who have race listed as other or unknown are
# also very likely to have ethnicity listed as unknown OR as Hispanic or Latino. 

#--------------------------------------------------------------------------------#
# Let's get an idea of some simple morbidity and healthcare resource utilization
#--------------------------------------------------------------------------------#

# first get simple counts of conditions, medications, and biomarkers
cond_count <- condition %>% count(patient_id) %>% rename(num_conditions = n)
med_count <- medication %>%  count(patient_id) %>% rename(num_medications = n)
biom_count <- filter(biomarker, str_detect(tolower(test_value_name), "positive")) %>%  count(patient_id) %>% rename(num_biomarkers = n)


# add counts to patient table to investigate
morbidity_tab <- patient %>%
  left_join(cond_count, by = "patient_id") %>% 
  left_join(med_count, by = "patient_id") %>% 
  left_join(biom_count, by = "patient_id")

# Look at some univariate box plots to get an idea of the spread of these features 
cond_box <- ggplot(data = filter(morbidity_tab, num_conditions < 250)) +
  geom_boxplot(mapping = aes(x=num_conditions)) +
  coord_flip()
med_box <- ggplot(data = filter(morbidity_tab, num_conditions < 250)) +
  geom_boxplot(mapping = aes(x=num_medications)) +
  coord_flip()
biom_box <- ggplot(data = filter(morbidity_tab, num_conditions < 250)) +
  geom_boxplot(mapping = aes(x=num_biomarkers)) +
  coord_flip()
grid.arrange(cond_box, med_box, biom_box, ncol = 3)
# I think these 



# Get an idea of the correlations between these 3
ggplot(data = morbidity_tab) + 
  geom_point(mapping = aes(x = num_conditions, y= num_medications, color = num_biomarkers)) 
# There are some super notable outliers in num_conditions that maybe aren't real, let's look without them
# and also get some univariate boxplots to look at spread of these measures
ggplot(data = filter(morbidity_tab, num_conditions < 250)) + 
  geom_point(mapping = aes(x = num_conditions, y= num_medications, color = num_biomarkers))


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
















