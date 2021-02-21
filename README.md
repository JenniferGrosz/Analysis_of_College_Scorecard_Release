# Data_Exploration_Assignment_5300
OMSBA 5300 Winter 2021 Data Exploration Assignment
#### Author: Jennifer Grosz

## Data Overview
The analysis performed here is at the “by month by college level” meaning the Google Trends index per college has been standardized and aggregated by month. The data set used for this analysis is composed of data from the College Scorecard and Google Trends data files. From the College Scorecard data file, I have included institutions that predominantly grant bachelor’s degrees and a variable distinguishing between high earning and low earning colleges as a calculation of the mean of all median earnings for students 10 years after graduation, which is approximately $42,000. The mean has been used in the determination of this variable rather than the median because it takes into consideration all median earnings in its calculation and I felt that was the best measure for deafferenting between high and low earning colleges.

From the Google Trends data files, I have used the dates associated with college keyword Google searches and their provided indices. To standardize the index values grouped by keyword, the mean has been subtracted from the index for each keyword grouping and divided by the standard deviation of the index. Then, to get an aggregate of the standardized index I calculated the mean of the standardized index values per month per college resulting in the final “aggIndex” variable found in the data set. To create the binary CollegeScorecard variable 1 has been assigned to all rows of data associated with a time during or after September 2015 and 0 to all rows of data prior to the release of the College Scorecard in September 2015. 

The resulting data set used in this analysis contains data collected between March 2013 through December 2016. It includes aggregated index data for 1785 institutions, a time variable representing the passage of time in 1-unit incrementally increasing values over the span of 37 months and two dummy variables I created to represent high-earning vs low-earning college graduate earnings and pre-scorecard vs post-scorecard to represent data released before and after the College Scorecard was released.

## Research Question
This analysis determines the effect of the College Scorecard being released to the public on interest in high-earning colleges relative to low-earning ones as proxied by Google searches for keywords associated with those colleges. The primary regression model that will be analyzing to address this research question is:

#### model <- lm(aggIndex ~ CollegeScorecard + high_earning + time_var + CollegeScorecard * time_var + CollegeScorecard * high_earning, mydata)

This regression model addresses the research question because the results will return the effect the College Scorecard being released proxied by Google searches for keywords associated with the dates after the College Scorecard was released relative to Google searches for keywords associated with dates prior to the release of the College Scorecard. 

It will also return the effect of high-earning colleges relative to low-earning colleges as proxied by Google searches for keywords associated with those colleges as well as the effect of the interaction between the College Scorecard being released and how that resulted in student interest for high-earnings colleges relative to low-earnings ones, so the interaction between CollegeScorecard and high_earning has been included in the model as well.

Additionally, this regression model controls for the time variable to more accurately determine the causal effect of the treatment variable, the College Scorecard being released. Time has a direct affect on the College Scorecard variable and not including it in the model would cause bias and an misrepresent the effect of the College Scorecard on the dependent variable. 

Finally, the interaction between time and the CollegeScorecard variable has been included in the model because the effect of the CollegeScorecard is dependent upon the level of the time variable. There is an interaction between these variables that needs to be included in the model. 


## Additional Analysis
Some additional analysis I conducted was creating a 1-unit scaled variable that incrementally decreased from -30 to 0 to and increased to +7 in centered at 0 to indicate a passage of time before and after the College Scorecard was released, but this scale proved ineffective and ultimately too complex in regard to determining the results of my regression model and the interaction with the College Scorecard variable, so it was unused in the data set. 

I looked at the summary statistics for aggIndex and time variables in the data set as well as the standard deviation for the variable aggIndex which was 0.5791552. 

Summary Statistics: 
    aggIndex            time_var    
 Min.   :-2.828712   Min.   : 1.00  
 1st Qu.:-0.378690   1st Qu.:10.00  
 Median :-0.018279   Median :19.00  
 Mean   : 0.005998   Mean   :19.21  
 3rd Qu.: 0.356663   3rd Qu.:28.00  
 Max.   : 6.854021   Max.   :37.00 

Then, I looked at the correlation between my independent variables to be used in the model and found the following results:

                 CollegeScorecard  high_earning     time_var
CollegeScorecard     1.0000000000 -0.0005919931  0.681418961
high_earning        -0.0005919931  1.0000000000 -0.002098281
time_var             0.6814189610 -0.0020982814  1.000000000

There is a strong positive correlation between Time and CollegeScorecard (correlation coefficient of 0.681418961) which indicates that the interaction term used in my model is valid. Additionally, there is a very low negative correlation for both CollegeScorecard and time with the high_earning variables in my model. 

Next, I generated histogram plots for the variables used in my regression analysis to determine see how they are distributed in the data set. While not detrimentally problematic, I found it worth noting that due to the timeline in this dataset (2013 – 2016) there is an imbalance for the variable CollegeScorecard and data prior to the release of the College Scorecard is oversampled in the data set.

![collegescorecard histogram](/images/https://github.com/JenniferGrosz/Data_Exploration_Assignment_5300/blob/main/images/collegescorecard_histogram.png?raw=true)

![indexHistogram](https://github.com/JenniferGrosz/Data_Exploration_Assignment_5300/blob/main/images/indexHistogram.png?raw=true)

Additionally, I generated a scatterplot of aggregated Google Trends indices over time and colored the points to represent high-earning colleges compared to low-earning colleges where high-earning = 1 in the plot.

![Aggregated Index over Time Scatterplot](../images/indexovertimeplot.png)

## Analysis

     ─────────────────────────────────────────────────────────────────────────────────────────────────
                                                                                             Model 1  
                                                     ─────────────────────────────────────────────────
       (Intercept)                                                                         0.426 ***  
                                                                                          (0.006)     
       CollegeScorecard                                                                    1.945 ***  
                                                                                          (0.086)     
       high_earning                                                                        0.014 **   
                                                                                          (0.005)     
       time_var                                                                           -0.024 ***  
                                                                                          (0.000)     
       CollegeScorecard:time_var                                                          -0.050 ***  
                                                                                          (0.003)     
       CollegeScorecard:high_earning                                                      -0.053 ***  
                                                                                          (0.011)     
                                                     ─────────────────────────────────────────────────
       N                                                                               65285          
       R2                                                                                  0.142      
     ─────────────────────────────────────────────────────────────────────────────────────────────────
       Standard errors are heteroskedasticity robust.  *** p < 0.001; ** p < 0.01; * p < 0.05.                         


## Linear Hypothesis Test:
Hypothesis:
CollegeScorecard = 0

Model 1: restricted model
Model 2: aggIndex ~ CollegeScorecard + high_earning + time_var + CollegeScorecard * 
    time_var + CollegeScorecard * high_earning

Note: Coefficient covariance matrix supplied.

  Res.Df Df      F    Pr(>F)    
1  65280                        
2  65279  1 512.37 < 2.2e-16 ***




## Conclusion
All I am going to discuss are effects are statistically significant at the 1% level except for the effect of high-earning college graduates relative to low-earning college graduates, that effect is statistically significant at the 10% level.

The results of this analysis show that the public release of the College Scorecard had a statistically significant effect on Google Searches for keywords associated with dates after the scorecard was released as proxied by the Google Trend Index. Holding all other variables constant, effect of the College Scorecard being released resulted in aggregate Google Trend indices 1.92 higher than Google Trend indices prior to the release of the College Scorecard. 

The effect of the high-earning college graduates ten years after graduation relative to low-earning college graduates ten years after graduation has a very small, yet statistically significant positive effect of 0.014 on aggregate Google Trend Index. 

The effect of a one month increase in time decreases aggregate Google Trend Index by 0.024. 

The effect of the College Scorecard being released and a one month increase in time decreases the aggregate Google Index -0.050 more than if the College Scorecard had not been released and there was a one month increase in time. In other words, this interaction says the effect of a one month increase in time when the College Scorecard has been released results in an average aggregate Google Trend Index of 2.297. 

And finally, the effect of the College Scorecard being released on interest in high-earning colleges relative to low earning colleges is a decrease in aggregate Gogle Trend index of 0.053. This means that the effect of the College Scorecard coming out for high-earning colleges results in an average aggregate Google Trends of 2.332. While the effect of the College Scorecard coming out for low-earning colleges results in an average aggregate Google Trends index of 2.371.









