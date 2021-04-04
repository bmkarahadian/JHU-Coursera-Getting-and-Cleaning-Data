# Getting and Cleaning Data: Course Project

The "HAR" dataset created in the "run_analysis.R" script compiles data from the UCI HAR Dataset and selects only the mean and standard deviation measurements. Transformations of the original dataset are outlined in the description of the "summary_stats" variable. This codebook is best understood after reading the documentation and original codebook of the UCI HAR Dataset included in this repository. The original data can be downloaded [here](https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip).

## Variable List

1. "fold" - 
*Factor variable.* Designates to which set the observation was assigned. Takes values of "train" and "test".

2. "subject" - 
*Factor variable.* Designates which test subject was observed. Takes values of 1 through 30.

3. "recording" - 
*Integer variable.* When paired with the *subject* variable, orders observations temporally. Recordings were measured at a frequency of 50 Hz and the summary statistics were generated across fixed-width windows of 2.45 seconds, so all observations of a single subject are temporally related.

4. "activity" - 
*Factor variable.* Designates in which activity the subject was engaged at the instant of observation. Takes values of "laying", "sitting", "standing", "walking", "walking_downstairs", and "walking-upstairs".

5. "summary_stats" - 
*Tibble/Data Frame* Contains the following specifiers
	+ "axis" - *Factor variable.* Designates across which axis the measurement was taken. Takes values of "X", "Y", "Z", and "euclid_mag". "euclid_mag" indicates the magnitude of the three-dimensional signals calculated using the Euclidean norm. Derived from (for example): tBodyAcc-mean()-**X**, tBodyAcc-mean()-**Y**, tBodyAcc-mean()-**Z**, tBodyAcc**Mag**-mean(), etc. from the original dataset.
	+ "ref" - *Factor variable.* Designates to which reference the measurement is situated. Takes values of "body" and "gravity". "body" is calculated as the absolute measurement minus the "gravity" measurement. Derived from (for example): t**Body**Acc-mean()-X, t**Gravity**Acc-mean()-X, etc. from the original dataset.
	+ "domain" - *Factor variable.* Designates whether the measurement was subject to a Fast Fourier Transformation. Takes values of "time" and "fourier". Derived from (for example): **t**BodyAcc-mean()-X, **f**BodyAcc-mean()-X, etc. from the original dataset.
	+ "instrument" - *Factor variable.* Designates which instrument took the measurement. Takes values of "accelerometer" and "gyroscope". Derived from (for example): tBody**Acc**-mean()-X, tBody**Gyro**-mean()-X, etc. from the original dataset.
	+ "jerk" - *Logical variable.* Designates whether the measurement is of the jerk signal. Takes values of TRUE and FALSE. Derived from (for example): tBodyAcc-mean()-X, tBodyAcc**Jerk**-mean()-X, etc. from the original dataset.
	+ "mean" - *Numerical variable.* Designates the average value across each 2.45 second window of the raw 50 Hz measurement. Measured in standard gravity units (g). Takes values between -1 and +1. Derived from (for example): tBodyAcc-**mean()**-X, etc. from the original dataset.
	+ "sd" - *Numerical variable.* Designates the standard deviation of the set of values across each 2.45 second window of the raw 50 Hz measurement. Measured in standard gravity units (g). Takes values between -1 and +1. Derived from (for example): tBodyAcc-**std()**-X, etc. from the original dataset.