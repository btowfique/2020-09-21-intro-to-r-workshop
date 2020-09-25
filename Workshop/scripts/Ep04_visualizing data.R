#Visualizing datat with ggplot

#load ggplot

library(ggplot2)

#to read other packages 

library(tidyverse)

#load data

surveys_complete <- read.csv("data_raw/surveys_complete.csv")

#create a plot

ggplot(data=surveys_complete)

#mapping - identify x n y axis

ggplot(data=surveys_complete, mapping=aes(x=weight, y=hindfoot_length))

# what plot do u want ? histogram, box plot?

ggplot(data=surveys_complete, mapping=aes(x=weight, y=hindfoot_length)) + geom_point()

#assign a plot to an object

surveys_plot <- ggplot(data=surveys_complete, mapping=aes(x=weight, y=hindfoot_length))

# draw a plot

surveys_plot+geom_point()

#challenge 1

surveys_plot <- ggplot(data = surveys_complete, mapping = aes(x = hindfoot_length, y = weight)) + 
  geom_point()


#challenge 2

challenge2 <-  ggplot(data = surveys_complete,
                      mapping = aes(weight)) + geom_histogram()

#another solution: width specified

ggplot(data = surveys_complete, aes(x=weight)) + 
  geom_histogram(binwidth=10)

