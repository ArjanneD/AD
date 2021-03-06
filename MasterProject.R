### MASTER PROJECT ###
#This code is to analyze the interaction data robot Pepper stores. Confidential.

#Installation: download the following required packages 
install.packages("ngram")
library(dplyr)
library(tidyverse)
library(readr)
library(ggplot2)
library(timelineR)
library(lubridate)
library(ngram)

# Support 
# if you are having issues, please let me know. You can email: arjanne.dekker@hva.nl


### STEP 1 - LOADING IN THE DATA ###
heards <- read_csv("1. HvA - Digital Driven Business/3.3 Master Project/datasetWelbo/heards.csv")
View(heards)

says <- read_csv("1. HvA - Digital Driven Business/3.3 Master Project/datasetWelbo/says.csv")
View(says)

clients <- read_csv("1. HvA - Digital Driven Business/3.3 Master Project/datasetWelbo/clients.csv")
View(clients)

# Merge these dataframes to one dateframe 

# Make a new dataframe to combine the says / heards of the files 'says' and 'heards'
says_new <- says %>%
  mutate(type_conversation = "says")

heards_new <- heards %>%
  mutate(type_conversation = "heards")

files_merged <- bind_rows(heards_new, says_new)

unique(files_merged$type_conversation)

# Merge the 'clients' and 'files_merged'

# Remove values of ClientId and robotId which aren't Id's 
unique(files_merged$clientId)

files_merged = files_merged[(which(nchar(files_merged$clientId) == 24)),]
files_merged = files_merged[(which(nchar(files_merged$robotId) == 24)),]
unique(files_merged$robotId)

# Name ClientId's to company name (debatable for privacy)
files_merged = merge(files_merged, clients, by = "clientId", all.files_merged = TRUE)

# Exclude companies in 'clientName' that are not a company
unique(files_merged$clientName)

files_merged <- files_merged[!(files_merged$clientName == "Demo2"),]
files_merged <- files_merged[!(files_merged$clientName == "WELBO_Dev"),]

# Add an index (numeric ID) column 
files_merged$ID <- seq.int(nrow(files_merged))

# Delete unnecessary dataframes
remove(clients, heards, heards_new, says, says_new)

### STEP 2 - CLEANING THE DATA ###

## STEP 2.1 - EXPLORING RAW DATA 
class(files_merged) # class of data object 
dim(files_merged) # dimensions of data
names(files_merged) # column names 
str(files_merged) # structure, compact summary of its internal structure
summary(files_merged) # summary of data

head(files_merged)

## STEP 2.2 - TIDYING DATA 

# Reshape the variable types     
# Make "CreatedAt" which is a character into a 'timestamp'
mid = substr(files_merged$createdAt, 5, 25)
files_merged <- files_merged %>% 
  mutate(date_of_conversation = mid)

files_merged$date_of_conversation <- mdy_hms(files_merged$date_of_conversation)
head(files_merged)

# Change company names into sector 
# Receptel, Receptelbelgium, Callexcell, demo and demo1 are missing in the heards/says files. 
files_merged$sector[files_merged$clientName == "DNB" | files_merged$clientName == "Rabobank" | files_merged$clientName == "Rabobank-Event"] = "Bank"
files_merged$sector[files_merged$clientName == "HU" | files_merged$clientName == "HvA"] = "Education"
files_merged$sector[files_merged$clientName == "Engie" | files_merged$clientName == "SHELL" | files_merged$clientName == "Shell-Hague" | files_merged$clientName == "SHELLTOUR"] = "Energy"
files_merged$sector[files_merged$clientName == "SchakelRing"] = "Healthcare"
files_merged$sector[files_merged$clientName == "decos" | files_merged$clientName == "Lagardere"] = "Information Technology"
files_merged$sector[files_merged$clientName == "KPMG" | files_merged$clientName == "TNO" | files_merged$clientName == "Unilever" | files_merged$clientName == "VodafoneZiggo Store"] = "Large commercial company"
files_merged$sector[files_merged$clientName == "NEMO"] = "Museum"
files_merged$sector[files_merged$clientName == "Alphen" | files_merged$clientName == "Ministerie EZK" | files_merged$clientName == "Police" | files_merged$clientName == "Woerden"] = "Public Service"
files_merged$sector[files_merged$clientName == "WELBO" | files_merged$clientName == "WELBO_Dev" | files_merged$clientName == "Zebrastraat"] = "Small commercial company"
files_merged$sector[files_merged$clientId == "demo2" | files_merged$clientName == "LV" | files_merged$clientName == "VZTraining" | files_merged$clientName == "Event Account"] = "Unknown"
unique(files_merged$sector)      

# small <100, medium 101-500, medium-large 501-1.000,  large >1.001, company > 5.000, unknown 
files_merged$company_size[files_merged$clientName == "NEMO" | files_merged$clientName == "decos" | files_merged$clientName == "Zebrastraat" | files_merged$clientName == "WELBO"] = "Small company"
files_merged$company_size[files_merged$clientName == "Woerden" | files_merged$clientName == "receptel" | files_merged$clientName == "receptelbelgium"] = "Medium company"
files_merged$company_size[files_merged$clientName == "Alphen" | files_merged$clientName == "callexcell"] = "Medium-large company"
files_merged$company_size[files_merged$clientName == "HvA" | files_merged$clientName == "DNB" | files_merged$clientName == "Ministerie EZK" | files_merged$clientName == "HU" | files_merged$clientName == "SchakelRing"] = "Large company"
files_merged$company_size[files_merged$clientName == "TNO" | files_merged$clientName == "VodafoneZiggo Store" | files_merged$clientName == "SHELL" | files_merged$clientName == "Shell-Hague" | files_merged$clientName == "SHELLTOUR"| files_merged$clientName == "Engie" | files_merged$clientName == "Police" | files_merged$clientName == "KPMG" | files_merged$clientName == "Lagardere" | files_merged$clientName == "Rabobank" |  files_merged$clientName == "Unilever" | files_merged$clientName == "Rabobank-Event" ] = "Company > 5.000"
files_merged$company_size[files_merged$clientName == "VZTraining" | files_merged$clientName == "LV" | files_merged$clientName == "Event Account"] = "Unknown"

# Convert variable types 'character' to factor 
files_merged$type_conversation <- as.factor(files_merged$type_conversation)  
files_merged$sector <- as.factor(files_merged$sector)
files_merged$robotId <- as.factor(files_merged$robotId)
files_merged$clientName <- as.factor(files_merged$clientName)
files_merged$company_size <- as.factor(files_merged$company_size)
files_merged$clientId <- as.factor(files_merged$clientId)
summary(files_merged)


### Deal with NA's in data fame
summary(files_merged)
# Count total NA 
sum(is.na(files_merged))
# Count NA per column 
colSums(is.na(files_merged))

# File_merged without NA's 
df_final <- drop_na(files_merged)
colSums(is.na(df_final))

summary(df_final)

## Exploring assumptions (Chapter 5 - Discovering statistics using R)

# Check normally distributed data
plot(df_final$company_size)
companysize <- df_final %>% 
  group_by(company_size) %>%
  summarise(no_rows = length(company_size))
  # Delete "unknown", "medium company" and "medium-large company"

plot(df_final$robotId)
robotid <- df_final %>% 
  group_by(robotId) %>%
  summarise(no_rows = length(robotId))
  # Delete robotId's <500 observations:  "5b11223e5f7c7019a491935a", "5b11239cd4b6031b677c7b24", "5bcdb774ce8583179651a618", "5d6e2d8c7371972d193852eb", "5dc955a14510936a74ccbd57", "5e38154249d7eb7bc2c8cc1b", "5e5fd1490a6de80010d09839"

plot(df_final$sector)
sector <- df_final %>% 
  group_by(sector) %>%
  summarise(no_rows = length(sector))
  # Delete sector <1000 observations: "education"
unique(df_final$company_size)

plot(df_final$type_conversation)

## Exclude categories with to few observations 
df_final <- df_final[!(df_final$company_size == "Unknown"),]
df_final <- df_final[!(df_final$company_size == "Medium company"),]
df_final <- df_final[!(df_final$company_size == "Medium-large company"),]

df_final <- df_final[!(df_final$robotId == "5b11223e5f7c7019a491935a"),]
df_final <- df_final[!(df_final$robotId == "5b11239cd4b6031b677c7b24"),]
df_final <- df_final[!(df_final$robotId == "5bcdb774ce8583179651a618"),]
df_final <- df_final[!(df_final$robotId == "5d6e2d8c7371972d193852eb"),]
df_final <- df_final[!(df_final$robotId == "5dc955a14510936a74ccbd57"),]
df_final <- df_final[!(df_final$robotId == "5e38154249d7eb7bc2c8cc1b"),]
df_final <- df_final[!(df_final$robotId == "5e5fd1490a6de80010d09839"),]

df_final <- df_final[!(df_final$sector == "Education"),]

remove(sector, companysize, robotid, files_merged)

# Add extra variable for counting the number of seconds per sentence
df_final$wordcount <- sapply(df_final$text, function(x) length(unlist(strsplit(as.character(x), "\\W+"))))
df_final$wordcount <- as.numeric(df_final$wordcount)

# the number of seconds per sentence 
df_final$wordcount <- (df_final$wordcount / 2)
df_final$wordcount <- as.numeric(df_final$wordcount)


# save document on local computer 
write.csv(df_final, "C:/Users/arjan/Documents/1. HvA - Digital Driven Business/Final-version.csv", row.names = TRUE)
