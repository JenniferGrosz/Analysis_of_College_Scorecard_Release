# Load relevant libraries
library(vtable)
library(tidyverse)
library(tidylog)
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
  bind_rows() %>%
  na.omit()


##############################################################################
############################### TIDY DATA ####################################
##############################################################################

# Tidy four_year
four_year <- four_year %>%
  # Rename variables
  rename(unitid = UNITID, institution = INSTNM, 
         grad_earnings = `md_earn_wne_p10-REPORTED-EARNINGS`) %>%
  # Filter data to include predom. 4 year degree colleges only
  # and remove NULL / PrivacySuppressed values from earnings col.
  filter(PREDDEG == 3, grad_earnings != "PrivacySuppressed",
         grad_earnings != "NULL") %>%
  # Select relevant variables to include
  mutate(grad_earnings = as.numeric(grad_earnings))

mean(four_year$grad_earnings)
# Create dummy variable to distinguish between high earning v.
# low earning colleges based on the mean of graduates earnings
# ten years after graduating for colleges that have been included
# in the data set
four_year <- four_year %>%
  mutate(high_earning = case_when(
    grad_earnings >= mean(grad_earnings) ~ 1,
    grad_earnings < mean(grad_earnings) ~ 0))


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

########### Merge ###########
# Merge data sets on schname
full_data <- left_join(four_year, trends_df, by = "schname")
# Filter out NA 
full_data <- full_data %>%
  filter(index != "NA")

# Standardize Index Scores  
full_data <- full_data %>%
  # group by keyword to calculate standardized index
  group_by(institution, keyword)%>%
  # New column and caluclation for standardized index value
  mutate(standardizedIndex = ((index - mean(index)) / sd(index))) %>%
  ungroup()


# Aggregate Index per college by month
full_data <- full_data %>%
  # split column
  separate(monthorweek, into = c("Wkstartdate", "Wkenddate"), 
           sep = " - ") %>%
  # convert to date data type
  mutate(Wkstartdate = ymd(Wkstartdate)) %>%
  # split column
  separate(Wkstartdate, into = c("year", "month"), 
           sep = "-", remove = FALSE) %>%
  # convert to numeric data type
  mutate(year = as.numeric(year),
         month = as.numeric(month)) %>% 
  # group data set
  group_by(institution, year, month) %>%
  # New column and caluclation for aggregated standardized index value
  mutate(aggIndex = mean(standardizedIndex)) %>%
  ungroup()


# Create unique identifier to filter out duplicates
final_data_set <- full_data %>%
  # remove unnecessary columns
  select(unitid, institution, grad_earnings, year, month, 
         aggIndex, high_earning, Wkstartdate) %>%
  # Unite columns to generate unique identifier
  unite(col = "ID", c(unitid, year, month), 
        sep = "_", remove = FALSE) %>%
  # filter out duplicates in data
  filter(!duplicated(ID))

## Create time variable
final_data_set <- final_data_set %>%
  mutate(time = as.character(Wkstartdate)) %>%
  mutate(time = time %>% str_replace_all("-", "")) %>%
  mutate(time = time %>% str_sub(start = 1, end = 6)) %>%
  mutate(time = as.numeric(time)) %>%
  # order data set by time
  arrange(time)  %>%
  # create incrementally increasing variable
  mutate(time1 = cumsum(c(1,as.numeric(diff(time))!=0))) %>%
  # remove unnecessary column
  select(-time) %>%
  rename(time = time1) %>%
  mutate(time_var = time)

# Create dummy variable to distinguish between index scores from
# before the College Scorecard was released and after it was 
# released at the beginning of September 2015 
final_data_set <- final_data_set %>%
  # Create college scorecard dummy variable
  mutate(CollegeScorecard = case_when(
    year > 2015  ~ 1,
    year < 2015  ~ 0,
    year == 2015 & month >= 9 ~ 1,
    year == 2015 & month < 9 ~ 0)) 

PostCollegeScorecard <- final_data_set %>%
  filter(CollegeScorecard == 1)

PostCollegeScorecard <- PostCollegeScorecard %>% 
  # order data set by time
  arrange(time) %>%
  # create incrementally increasing variable
  mutate(time1 = cumsum(c(1,as.numeric(diff(time))!=0)))%>%
  # remove unnecessary column
  select(-time) %>%
  # rename column
  rename(time = time1) 

PreCollegeScorecard <- final_data_set %>%
  filter(CollegeScorecard == 0)


PreCollegeScorecard <- PreCollegeScorecard %>% 
  # order data set by time
  arrange(-time) %>%
  # create incrementally increasing variable
  mutate(time1 = cumsum(c(1,as.numeric(diff(time))!=0)))%>%
  # create descending time scale
  mutate(time1 = (time1 * -1)) %>%
  # remove unnecessary column
  select(-time) %>%
  # rename column
  rename(time = time1) 

final_data_set <- bind_rows(PreCollegeScorecard, PostCollegeScorecard)

final_data_set <- final_data_set %>%
  select(-ID, -Wkstartdate, -grad_earnings, -year, -month)
  

# Write final data set to file for regression analysis
write_csv(final_data_set,
          file = "../data/mydata.csv",
          na = "NA",
          append = FALSE,
          col_names = TRUE,
          quote_escape = "double",
          eol = "\n")
