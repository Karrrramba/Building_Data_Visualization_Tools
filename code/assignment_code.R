library(dplyr)
library(ggplot2)
library(grid)
library(magrittr)
library(readr)
library(stringr)
library(tidyr)

library(tidyverse)

colnames(hurricanes) <- c("ID", "Name", "Date", "Year", "Latitude", "Longitude",
                          "Knot_34", "Knot_50", "Knot_64")

hr_txt <- readLines("data/ebtrk_atlc_1988_2015.txt", n = -1,)
hr_txt <- gsub("NOT\\s+NAMED", "NOTNAMED", hr_txt)
hurricanes <- read.table(text = gsub("\\s{2,}", " ", hr_txt), 
                         sep = " ", header = F, fill = TRUE, na.strings = "-99")
