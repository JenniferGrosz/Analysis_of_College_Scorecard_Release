
# Load relevant libraries
#library(haven)
library(vtable)
library(tidyverse)
library(tidylog)
#library(readr)
library(purrr)
library(lubridate)

##############################################################################
############################ Relevant Functions ##############################
##############################################################################

# Function to check for duplicates 
check_dupes <- function(data, vars) {
  data %>% 
    select(vars) %>%
    duplicated() %>%
    max()
}

# Function to process the files into a data frame
process_file <- function(df) {
  schname <- df[,2]
  keyword <- df[,3]
  monthorweek <- df[,5]
  index <- df[,6]
  return(data.frame(schname = schname, keyword = keyword, 
                    monthorweek = monthorweek, index = index))
}

##############################################################################
############################### LOAD DATA ####################################
##############################################################################

# Load Scorecard Dictionary Data
scorecard_dictionary <- read.csv("../data/CollegeScorecardDataDictionary-09-08-2015.csv")

# Load Most Recent Cohorts Data
four_year <- read_csv("../data/Most+Recent+Cohorts+(Scorecard+Elements).csv") 

# Load ID Name Link Data
id_link <- read_csv("../data/id_name_link.csv")

# Load Google Trends Data - 12 files
# Generate list of files
trends_filelist <- list.files(path = "../data/",
                       pattern = 'trends',
                       full.names = TRUE)

# Load Google trends data using the process file function 
trends_df <- trends_filelist %>%
  map(read_csv) %>%
  map(process_file) %>%
  bind_rows() 


##############################################################################
############################### TIDY DATA ####################################
##############################################################################

# Tidy four_year
four_year <- four_year %>%
  # Rename variables
  rename(unitid = UNITID, institution = INSTNM, 
         earnings = `md_earn_wne_p10-REPORTED-EARNINGS`) %>%
  # Filter data to include predom. 4 year degree colleges only
  # and remove NULL / PrivacySuppressed values from earnings col.
  filter(PREDDEG == 3, earnings != "PrivacySuppressed",
         earnings != "NULL") %>%
  # Select relevant variables to include
  select(unitid, institution, earnings) %>%
  # Change data types
  mutate(earnings = as.numeric(earnings),
         institution = factor(institution))


# Tidy id_link
id_link %>%
  # Remove unnecessary column
  select(-opeid)


##### Duplicates Check ######
# Check for duplicates on Key (unitid)
check_dupes(four_year, 'unitid') # 0 = no duplicates
# Check for duplicates 
check_dupes(id_link, 'unitid') # 0 = No Duplicates

########### Merge ###########
# Merge data sets on unitid
four_year <- inner_join(four_year, id_link, by = "unitid")

##### Duplicates Check ######
# Check joined data set for duplicates on Key (schname)
check_dupes(four_year, 'schname') # 1 = Duplicates in data set
# Create a duplicates data set
dups <- four_year %>%
  filter(schname %in% unique(.[["schname"]][duplicated(.[["schname"]])]))
# Remove all universities that share an exact name with another university
four_year <- four_year %>%
  filter(!(institution %in% dups$institution))

# Create dummy variable to distinguish between high_earning v.
# low earning colleges based on the mean of graduates earnings
# ten years after graduating for colleges that have been included 
# in the data set
four_year <- four_year %>%
  mutate(high_earning = case_when(
    earnings >= mean(earnings) ~ 1,
    earnings < mean(earnings) ~ 0))


# Tidy trends_df 
trends_df <- trends_df %>%
  # Filter to only include 4 year colleges in df
  filter((schname %in% four_year$schname)) %>%
  # Remove NA's
  filter(index != "NA") %>%
  # Split monthorweek column
  separate(monthorweek, into = c("BeginningOfWeek", "EndOfWeek"), 
           sep = " - ") %>%
  # Convert to date data type
  mutate(BeginningOfWeek = as.Date(BeginningOfWeek),
         EndOfWeek = as.Date(EndOfWeek))  %>%
  # Create unique identifier 
  unite(col = "ID", c(schname, keyword, BeginningOfWeek), 
        sep = "--", remove = FALSE) 

##### Duplicates Check ##### 
# Check for duplicates
check_dupes(trends_df, "ID") # 1 = Duplicates in data set
# Remove duplicates from data set
trends_df <- trends_df %>%
  filter(!duplicated(ID))

# Standardize Index Scores  
trends_df <- trends_df %>%
  # group by keyword to calculate standardized index
  group_by(schname, keyword) %>%
  # New column and caluclation for standardized index value
  mutate(standardizedIndex = ((index - mean(index)) / sd(index))) 

# Aggregate standardized indexes by institution per month per year 
trends_df <- trends_df %>%
  # Split up column to get month and Year
  separate(BeginningOfWeek, into = c("Year", "Month", "Day"), 
           sep = "-", remove = FALSE) %>%
  # group by institution, year, and month 
  group_by(schname, Year, Month) %>%
  # Create new column with mean of standardized index as aggregate 
  mutate(aggIndex = mean(standardizedIndex)) %>%
  ungroup()

#### Clean up data set
trends_df <- trends_df %>%
  # Remove unnecessary columns 
  select(schname, Year, Month, aggIndex) %>%
  # Convert to numeric data type
  mutate(Year = as.numeric(Year),
         Month = as.numeric(Month)) %>%
  unite(col = "ID", c(schname, Year, Month, aggIndex), 
        sep = "--", remove = FALSE)

##### Duplicates Check ##### 
# Check for duplicates
check_dupes(trends_df, "ID") # 0 = No Duplicates
# Remove duplicates from data set
trends_df <- trends_df %>%
  filter(!duplicated(ID))


# Create dummy variable to distinguish between index scores from
# before the College Scorecard was released and after it was 
# released at the beginning of September 2015 
trends_df <- trends_df %>%
  # Create college scorecard dummy variable
  mutate(CollegeScorecard = case_when(
    Year > 2015  ~ 1,
    Year < 2015  ~ 0,
    Year == 2015 & Month >= 9 ~ 1,
    Year == 2015 & Month < 9 ~ 0)) 


########### Merge ###########
# Merge data sets on schname
df <- left_join(four_year, trends_df, by = "schname") 


df <- df %>%
  select(unitid, institution, Year, Month, aggIndex,
         high_earning, CollegeScorecard) %>%
  filter(aggIndex != "NA")

write_csv(df,
          file = "../data/mydata.csv",
          na = "NA",
          append = FALSE,
          col_names = TRUE,
          quote_escape = "double",
          eol = "\n")






