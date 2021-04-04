library(tidyverse)
setwd(#"insert your directory with the UCI HAR dataset")


clean <- function(set = c("train", "test")) {
  #create location for x data
  x_loc <- str_c("UCI HAR Dataset/", set, "/X_", set, ".txt", sep = "")
  
  x <- #read x data and transform to numeric values
    read_lines(x_loc) %>%
    map(function(x) {
      x %>%
        str_squish() %>%
        str_split(" ") %>%
        unlist() %>%
        as.numeric()
    })
  
  #create location for activity data
  y_loc <- str_c("UCI HAR Dataset/", set, "/y_", set, ".txt", sep = "")
  
  y <- #read activity values and transform to numeric
    read_lines(y_loc) %>%
    as.numeric()
  
  #invert x list for easier conversion to tibble
  #list with i elements each of length j is converted to
  #list with j elements each of length i
  x_inv <- vector("list", length(x[[1]]))
  for (i in 1:length(x)) {
    for (j in 1:length(x[[1]])) {
      x_inv[[j]][i] <- x[[i]][j]
    }
  }
  
  #read features for tibble colnames
  vars <- 
    read_lines("UCI Har Dataset/features.txt") %>%
    str_remove("^[:digit:]{1,3} ")
  
  #subset feature list to those that are means and standard deviations
  which_vars <- 
    vars %>%
    str_detect("(mean\\(\\)|std\\(\\))") %>%
    which()
  
  #create location for subject data
  subject_loc <- str_c("UCI HAR Dataset/", set, "/subject_", set, ".txt", sep = "")
  
  #read subject values and transform to numeric
  subjects <- 
    read_lines(subject_loc) %>%
    as.numeric()
  
  #create final test/train tibble
  x_inv %>%
    `names<-`(vars) %>%
    `[`(which_vars) %>%
    as_tibble() %>%
    mutate(activity_num = y,
           subject = subjects,
           fold = set) %>%
    relocate(fold, subject, activity_num)
}

#generate descriptive character labels
activities <-
  read_lines("UCI HAR Dataset/activity_labels.txt") %>%
  str_remove_all("[:digit:]") %>%
  str_squish() %>%
  str_to_lower() %>%
  as_tibble() %>%
  `colnames<-`("activity") %>%
  mutate(activity_num = 1:6)

#compile full dataset
dat <- 
  clean("train") %>%
  bind_rows(clean("test")) %>%
  left_join(activities, by = "activity_num") %>%
  select(-activity_num) %>%
  relocate(fold, subject, activity) %>%
  mutate(fold = factor(fold),
         subject = factor(subject),
         activity = factor(activity))


#create unique identifier variables
colnames(dat)[4:length(dat)] %>%
  as_tibble() %>%
  mutate(axis = if_else(str_detect(value, "[:upper:]$"), str_extract(value, "[:upper:]$"), NA_character_),
         axis = if_else(is.na(axis), "euclid_mag", axis),
         stat = if_else(str_detect(value, "mean\\(\\)"), "mean", "sd"),
         ref = if_else(str_detect(value, "Body"), "Body", "Gravity"),
         domain = if_else(str_detect(value, "^t"), "time", "fourier"),
         instrument = if_else(str_detect(value, "Gyro"), "gyroscope", "accelerometer"),
         jerk = if_else(str_detect(value, "Jerk"), TRUE, FALSE)) %>%
  group_by(axis, stat, ref, domain, instrument, jerk) %>%
  summarize(count = n()) %>%
  `$`(count) %>%
  unique()


#compile complete tidy dataset
HAR <- 
  dat %>%
    group_by(fold, subject) %>%
    nest() %>%
    mutate(data = map(data, function(x) {
      x %>%
        mutate(recording = 1:nrow(x))
    })) %>%
    unnest(cols = data) %>%
    ungroup() %>%
    pivot_longer(where(is_double), names_to = "full_var", values_to = "value") %>%
    mutate(axis = if_else(str_detect(full_var, "[:upper:]$"), str_extract(full_var, "[:upper:]$"), NA_character_),
           axis = if_else(is.na(axis), "euclid_mag", axis),
           axis = factor(axis),
           stat = if_else(str_detect(full_var, "mean\\(\\)"), "mean", "sd"),
           ref = if_else(str_detect(full_var, "Body"), "body", "gravity"),
           ref = factor(ref),
           domain = if_else(str_detect(full_var, "^t"), "time", "fourier"),
           domain = factor(domain),
           instrument = if_else(str_detect(full_var, "Gyro"), "gyroscope", "accelerometer"),
           instrument = factor(instrument),
           jerk = if_else(str_detect(full_var, "Jerk"), TRUE, FALSE)) %>%
    select(-full_var) %>%
    pivot_wider(names_from = stat, values_from = value) %>%
    relocate(fold, subject, recording, activity) %>%
    group_by(fold, subject, recording, activity) %>%
    nest() %>%
    ungroup() %>%
    rename(summary_stats = data)



#create final summarized dataset for step 5

final <- 
  HAR %>%
    select(-fold, -recording) %>%
    unnest(summary_stats) %>%
    group_by(subject, activity, axis, ref, domain, instrument, jerk) %>%
    summarize(avg_mean = mean(mean), avg_sd = mean(sd))

write.table(final, row.names = FALSE, file = "final.txt")
