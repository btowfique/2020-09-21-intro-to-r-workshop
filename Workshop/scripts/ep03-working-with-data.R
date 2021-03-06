#####################
# MANIPULATING DATA #
#       using       #
#     TIDYVERSE     #
#####################
#
#
# Based on: https://datacarpentry.org/R-ecology-lesson/03-dplyr.html

# Data is available from the following link (we should already have it)
download.file(url = "https://ndownloader.figshare.com/files/2292169",
              destfile = "data_raw/portal_data_joined.csv")

#---------------------
# Learning Objectives
#---------------------

#    Describe the purpose of the dplyr and tidyr packages.
#    Select certain columns in a data frame with the dplyr function select.
#    Select certain rows in a data frame according to filtering conditions with the dplyr function filter .
#    Link the output of one dplyr function to the input of another function with the ‘pipe’ operator %>%.
#    Add new columns to a data frame that are functions of existing columns with mutate.
#    Use the split-apply-combine concept for data analysis.
#    Use summarize, group_by, and count to split a data frame into groups of observations, apply summary statistics for each group, and then combine the results.
#    Describe the concept of a wide and a long table format and for which purpose those formats are useful.
#    Describe what key-value pairs are.
#    Reshape a data frame from long to wide format and back with the pivit_wider and pivit_longer commands from the tidyr package.
#    Export a data frame to a .csv file.
#----------------------

#------------------
# Lets get started!
#------------------
install.packages("tidyverse") 
library(tidyverse) # load the library 'tidyverse'

# dplyr used to manipulate data
# tidyr used for reshaping data

# Load the dataset
surveys <- read_csv("data_raw/portal_data_joined.csv")

# Check structure
str(surveys)

#---------------

#-----------------------------------
# Selecting columns & filtering rows
#-----------------------------------

# selects columns plot_id, species_id and weight from data 'surveys'
select(surveys, plot_id, species_id, weight) 

# selects all columns except record_id and species_id
select(surveys, -record_id, -species_id) 

# Filter for a particular year
surveys_1995 <- filter(surveys, year == 1995)

surveys2 <- filter(surveys, weight < 5)
surveys_sml <- select(surveys2, species_id, sex, weight)
surveys_sml <- select(filter(surveys, weight < 5), species_id, sex, weight)


#-------
# Pipes
#-------






#-----------
# CHALLENGE
#-----------

# Using pipes, subset the ```surveys``` data to include animals collected before 1995 and 
# retain only the columns ```year```, ```sex```, and ```weight```.

surveys_1995 <- surveys %>% 
  filter(year < 1995) %>% 
  # ordering your columns does matter. If you put weight second, it will be in the second column
  select(year, sex, weight)





#--------
# Mutate : to convert one column to another column
#--------
surveys_weight <- surveys %>%
  mutate(weight_kg=weight/1000,
         weight_lb=weight_kg*2.2)
  

surveys %>%
  mutate(weight_kg=weight/1000,
         weight_lb=weight_kg*2.2)
  head(surveys)
  
surveys%>%
  filter(!is.na(weight))%>%
  mutate(weight_kg=weight/1000)%>%
  head(20)



#-----------
# CHALLENGE
#-----------

# Create a new data frame from the ```surveys``` data that meets the following criteria: 
# contains only the ```species_id``` column and a new column called ```hindfoot_cm``` containing 
# the ```hindfoot_length``` values converted to centimeters. In this hindfoot_cm column, 
# there are no ```NA```s and all values are less than 3.

# Hint: think about how the commands should be ordered to produce this data frame!

#My solution
surveys_hindfoot <- surveys %>%
  select(surveys, species_id)
  mutate(hindfoot_cm=hindfoot_length/10)
  
surveys_hindfoot %>%
  (!is.na(hindfoot_cm))%>%

#solution 1  
  new_dataframe <- surveys %>% 
  filter(!is.na(hindfoot_length)) %>% 
  mutate(hindfoot_cm = hindfoot_length / 10) %>% 
  select(species_id, hindfoot_cm) %>% 
  filter(hindfoot_cm < 3)

#solution 2
surveys %>%  
  filter(!is.na(hindfoot_length)) %>%  
  mutate(hindfoot_cm = hindfoot_length / 10) %>% 
  filter(hindfoot_cm < 3) %>% 
  select(species_id, hindfoot_cm)

#solution 3
new_dataframe <- surveys %>% 
  filter(!is.na(hindfoot_length), hindfoot_length < 30) %>% 
  mutate(hindfoot_cm = hindfoot_length / 10) %>% 
  select(species_id, hindfoot_cm)


  
  



#---------------------
# Split-apply-combine
#---------------------
#Solution
surveys %>%
  group_by (sex) %>%
  summarise(mean_weight=mean(weight, na.rm = TRUE))

  summary(surveys)
  
# Using dplyr - not sure what this is
surveys %>%
    dplyr:: group_by(sex) %>%
    summarise(mean_weight=mean(weight, na.rm = TRUE))

#Another solution 
surveys %>%
  filter(!is.na(weight))%>%
  group_by (sex, species_id) %>%
  summarise(mean_weight=mean(weight))

# Solution to filter out NA from both weight n Sex
surveys %>%
  filter(!is.na(weight),!is.na(sex))%>%
  group_by (sex, species_id) %>%
  summarise(mean_weight=mean(weight))

# For asking for a certain number of rows
surveys %>%
  filter(!is.na(weight),!is.na(sex))%>%
  group_by (sex, species_id) %>%
  summarise(mean_weight=mean(weight)) %>%
  print(n=20)
  
#to order the data by min weight
surveys %>%
  filter(!is.na(weight),!is.na(sex))%>%
  group_by (sex, species_id) %>%
  summarise(mean_weight=mean(weight),
            min_weight=min(weight))%>%
  arrange(min_weight)



#to order the data by mean weight
surveys %>%
  filter(!is.na(weight),!is.na(sex))%>%
  group_by (sex, species_id) %>%
  summarise(mean_weight=mean(weight),
            min_weight=min(weight))%>%
  arrange(mean_weight)

#to order the data by max weight
surveys %>%
  filter(!is.na(weight),!is.na(sex))%>%
  group_by (sex, species_id) %>%
  summarise(mean_weight=mean(weight),
            min_weight=min(weight))%>%
  arrange(-min_weight)

#to order the data by max weight
surveys %>%
  filter(!is.na(weight),!is.na(sex))%>%
  group_by (sex, species_id) %>%
  summarise(mean_weight=mean(weight),
            min_weight=min(weight))%>%
  arrange(desc(min_weight))

#to count
surveys %>%
  count(sex)

# Alternate solution  
surveys %>%
  group_by(sex) %>%
  summarise(count=n())

#group by several variables
surveys %>%
  group_by(sex, species, taxa) %>%
  summarise(count=n())

#-----------
# CHALLENGE
#-----------

# 1. How many animals were caught in each ```plot_type``` surveyed?

# My solution
surveys %>%
  count(plot_type)


# 2. Use ```group_by()``` and ```summarize()``` to find the mean, min, and max hindfoot length 
#    for each species (using ```species_id```). Also add the number of observations 
#    (hint: see ```?n```).


# solution
  hindfoot_info <- surveys %>%
    filter(!is.na(hindfoot_length)) %>% 
    group_by(species_id) %>% 
    summarise(mean_length = mean(hindfoot_length),
              min_length = min(hindfoot_length), 
              max_length = max(hindfoot_length),
              count = n())
  
  
# 3. What was the heaviest animal measured in each year? 
#    Return the columns ```year```, ```genus```, ```species_id```, and ```weight```.

  
#Solution
  heaviest_year <- surveys %>% 
    group_by(year) %>%
    select(year, genus, species_id, weight) %>%  
    mutate(max_weight=max(weight, na.rm = TRUE)) %>%
    ungroup
heaviest_year

#Another solution
surveys %>% 
  filter(!is.na(weight)) %>%
  group_by(year) %>%
  filter(weight == max(weight)) %>% 
  select(year, genus, species, weight) %>%
  arrange(year) %>% 
  distinct()




#-----------
# Reshaping
#-----------


surveys.gw <- surveys%>%
  filter(!is.na(weight))%>%
  group_by(plot_id, genus)%>%
  summarise(mean_weight=mean(weight))
surveys.gw
          
surveys_wider <- surveys.gw %>%
  spread(key=genus, value=mean_weight)
str(surveys_wider)
surveys_wider

surveys_gather <- (surveys_wider)%>%
  gather (key=genus, value = mean_weight, -plot_id)




#-----------
# CHALLENGE
#-----------

# 1. Spread the surveys data frame with year as columns, plot_id as rows, 
#    and the number of genera per plot as the values. You will need to summarize before reshaping, 
#    and use the function n_distinct() to get the number of unique genera within a particular chunk of data. 
#    It’s a powerful function! See ?n_distinct for more.


surveys_spread_genera <- surveys %>% 
  group_by(plot_id, year) %>% 
  summarise(n_genera = n_distinct(genus)) %>% 
  spread(year, n_genera)

head(surveys_spread_genera)


# 2. Now take that data frame and pivot_longer() it again, so each row is a unique plot_id by year combination.

surveys_spread_genera2 <- surveys_spread_genera %>% 
  gather(key = year, value = n_genera, -plot_id)

# 3. The surveys data set has two measurement columns: hindfoot_length and weight. 
#    This makes it difficult to do things like look at the relationship between mean values of each 
#    measurement per year in different plot types. Let’s walk through a common solution for this type of problem. 
#    First, use pivot_longer() to create a dataset where we have a key column called measurement and a value column that 
#    takes on the value of either hindfoot_length or weight. 
#    Hint: You’ll need to specify which columns are being pivoted.


surveys_long <- surveys %>% 
  gather("measurement", "value", hindfoot_length, weight)




# 4. With this new data set, calculate the average of each measurement in each year for each different plot_type. 
#    Then pivot_wider() them into a data set with a column for hindfoot_length and weight. 
#    Hint: You only need to specify the key and value columns for pivot_wider().


surveys_long2 <- surveys_long %>% 
  group_by(year, measurement, plot_type) %>% 
  summarise(mean_value = mean(value, na.rm = TRUE)) %>% 
  spread(measurement, mean_value)

tail(surveys_long2)





#----------------
# Exporting data
#----------------












