# Data_Exploration_Assignment_5300
OMSBA 5300 Winter 2021 Data Exploration Assignment

The analysis performed here is at the “by month by college level” meaning the Google Trends index per college has been standardized and aggregated by month. The data set used for this analysis is composed of data from the College Scorecard and Google Trends data files. From the College Scorecard data file I have included institutions that predominantly grant bachelor’s degrees and a variable distinguishing between high earning and low earning colleges as a calculation of the mean of all median earnings for students 10 years after graduation, which is approximately $42,000. The mean has been used in the determination of this variable rather than the median because it takes into consideration all median earnings in its calculation and I felt that was the best measure for differienating between high and low earning colleges.

From the Google Trends data files I have used the dates associated with college keyword Google searches and their provided indecies. To standardize the index values grouped by keyword, the mean has been subrtacted from the index for each keyword grouping and divided by the standard deviation of the index. Then, to get an aggregate of the standardized index I calculated the mean of the standardized index values per month per college resulting in the final “aggIndex” variable found in the data set. To create the binary CollegeScorecard variable 1 has been assigned to all rows of data associated with a time during or after September 2015 and 0 to all rows of data prior to the release of the College Scorecard in September 2015. 

The resulting data set used in this analysis contains data collected between March 2013 through December 2016. It includes aggregated index data for 1785 institutions, a time variable representing the passage of time in 1-unit incrementally increasing values over the span of 37 months and two dummy variables I created to represent high-earning vs low-earning college graduate earnings and pre-scorecard vs post-scorecard to represent data released before and after the College Scorecard was released.

This analysis determines the effect of the College Scorecard being released to the public on interest in high-earning colleges relative to low-earning ones as proxied by Google searches for keywords associated with those colleges. The primary regression model that will be analyzing to address this research question is:

model <- lm(aggIndex ~ CollegeScorecard + high_earning + time_var 
            + CollegeScorecard*time_var, mydata)

This regression model addresses the research question because the results will return the effect the College Scorecard being released proxied by Google searches for keywords associated with the dates after the College Scorecard was released relative to Google searches for keywords associated with dates prior to the release of the College Scorecard. 

It will also return the effect of high-earning colleges relative to low-earning colleges as proxied by Google searches for keywords associated with those colleges.

Additionally, this regression model controls for the time variable to more accurately determine the causal effect of the treatment variable, the College Scorecard being released. Time has a direct affect on the College Scorecard variable and not including it in the model would cause bias and an misrepresent the effect of the College Scorecard on the dependent variable. 

Finally, the interaction between time and the CollegeScorecard variable has been included in the model because the effect of the CollegeScorecard is dependent upon the level of the time variable. There is an interaction between these variables that needs to be included in the model. 

Some additional analysis I conducted was creating a 1-unit scaled variable that incrementally decreased from -30 to 0 to and increased to +7 in centered at 0 to indicate a passage of time before and after the College Scorecard was released, but this scale proved ineffective and ultimately too complex in regard to determining the results of my regression model and the interaction with the College Scorecard variable so it was unused in the data set. I looked at the summary statistics for aggIndex and time variables in the data set as well as the standard deviation for the variable aggIndex which was 0.5791552. 

Then, I looked at the correlation between my independent variables to be used in the model and found the following results:

#[[image]]]]]

There is a strong positive correlation between Time and CollegeScorecard (correlation coefficient of 0.681418961) which indicates that the interaction term used in my model is valid. Additionally, there is a very low negative correlation for both CollegeScorecard and time with the high_earning variables in my model. 

Next, I generated histogram plots for the variables used in my regression analysis to determine see how they are distributed in the data set. While not detrimentally problematic, I found it worth noting that due to the timeline in this dataset (2013 – 2016) there is an imbalance for the variable CollegeScorecard and data prior to the release of the College Scorecard is oversampled in the data set.

Finally, I generated a scatterplot of aggregated Google Trends indcies over time and colored the points to represent high-earning colleges compared to low-earning colleges where high-earning = 1 in the plot.
