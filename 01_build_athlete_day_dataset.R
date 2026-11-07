library(dplyr)
library(tidyr)
library(stringr)
library(lubridate)

# LOAD DATA
activity_data <- read.csv("activity_data.csv",stringsAsFactors = FALSE)
daily_data <- read.csv("daily_data.csv",stringsAsFactors = FALSE)
athletes <- read.csv("athletes.csv",stringsAsFactors = FALSE)

dim(activity_data)
dim(daily_data)
dim(athletes)
names(activity_data)
names(daily_data)
names(athletes)

# DATE VARIABLES
activity_data$date <- as.Date(activity_data$date)
daily_data$date <- as.Date(daily_data$date)

class(activity_data$date)
class(daily_data$date)
head(activity_data$date)
head(daily_data$date)

# CHECK DUPLICATES
daily_duplicates <- daily_data %>% count(athlete_id, date) %>% filter(n > 1)
nrow(daily_duplicates)

athlete_duplicates <- athletes %>% count(athlete_id) %>% filter(n > 1)
nrow(athlete_duplicates)

# SAFE AGGREGATION FUNCTIONS
safe_sum <- function(x) if (all(is.na(x))) NA_real_ else sum(x, na.rm = TRUE)
safe_mean <- function(x) if (all(is.na(x))) NA_real_ else mean(x, na.rm = TRUE)
safe_max <- function(x) if (all(is.na(x))) NA_real_ else max(x, na.rm = TRUE); safe_min <- function(x) if (all(is.na(x))) NA_real_ else min(x, na.rm = TRUE)

# NO. OF ACTIVITIES PER ATHLETE-DAY
activity_count <- activity_data %>% group_by(athlete_id, date) %>% summarise(number_of_activities = n(), .groups = "drop")
head(activity_count)

# AGGREGATE ACTIVITY DATA TO ATHLETE-DAY
activity_daily <- activity_data %>% group_by(athlete_id, date) %>%
  summarise(number_of_activities = n(), duration_minutes = safe_sum(duration_minutes),
    tss = safe_sum(tss), distance_km = safe_sum(distance_km), distance_m = safe_sum(distance_m),
    work_kilojoules = safe_sum(work_kilojoules), elevation_gain = safe_sum(elevation_gain),
    intensity_factor = safe_mean(intensity_factor), intensity_variability = safe_mean(intensity_variability),
    avg_hr = safe_mean(avg_hr),max_hr_activity = safe_max(max_hr),
    avg_speed_kph = safe_mean(avg_speed_kph), avg_power = safe_mean(avg_power), normalized_power = safe_mean(normalized_power),
    avg_pace_min_km = safe_mean(avg_pace_min_km), avg_pace_min_100m = safe_mean(avg_pace_min_100m),
    training_effect_aerobic = safe_mean(training_effect_aerobic),
    training_effect_anaerobic = safe_mean(training_effect_anaerobic),
    .groups = "drop")

head(activity_daily)
dim(activity_daily)
names(activity_daily)

# CHECK ACTIVITY AGGREGATION
activity_daily_duplicates <- activity_daily %>% count(athlete_id, date) %>% filter(n > 1)

nrow(activity_daily_duplicates)
summary(activity_daily$number_of_activities)
table(activity_daily$number_of_activities)

# SPORT FEATURES
sport_daily <- activity_data %>% count(athlete_id, date, sport) %>%
  pivot_wider(names_from = sport, values_from = n, names_prefix = "sport_", values_fill = 0)

head(sport_daily)
names(sport_daily)

# WORKOUT TYPE FEATURES
workout_daily <- activity_data %>% count(athlete_id, date, workout_type) %>%
  pivot_wider(names_from = workout_type, values_from = n,
              names_prefix = "workout_", values_fill = 0)
names(workout_daily) <- make.names(names(workout_daily), unique = TRUE)

head(workout_daily)
names(workout_daily)

# EXTRACT HR ZONE
head(activity_data$hr_zones, 10)
extract_zone <- function(x, zone)
  as.numeric(str_match(x, paste0("'", zone, "':\\s*([0-9.]+)"))[, 2])

activity_data <- activity_data %>% mutate(hr_z1 = extract_zone(hr_zones, "Z1"), hr_z2 = extract_zone(hr_zones, "Z2"), hr_z3 = extract_zone(hr_zones, "Z3"),
                                          hr_z4 = extract_zone(hr_zones, "Z4"), hr_z5 = extract_zone(hr_zones, "Z5"), hr_z6 = extract_zone(hr_zones, "Z6"))

head(activity_data[, c("hr_zones", paste0("hr_z", 1:6))])

# DAILY HEART RATE ZONES
hr_zone_daily <- activity_data %>%
  group_by(athlete_id, date) %>%
  summarise(across(c(hr_z1, hr_z2, hr_z3, hr_z4, hr_z5, hr_z6), safe_mean), .groups = "drop")

# POWER ZONES
head(activity_data$power_zones, 10)
activity_data <- activity_data %>%
  mutate(power_z1 = extract_zone(power_zones, "Z1"), power_z2 = extract_zone(power_zones, "Z2"),
         power_z3 = extract_zone(power_zones, "Z3"), power_z4 = extract_zone(power_zones, "Z4"),
         power_z5 = extract_zone(power_zones, "Z5"), power_z6 = extract_zone(power_zones, "Z6"))

power_zone_daily <- activity_data %>%
  group_by(athlete_id, date) %>%
  summarise(across(c(power_z1, power_z2, power_z3, power_z4, power_z5, power_z6), safe_mean),
            .groups = "drop")

# COMBINE ALL ACTIVITY 
activity_daily_complete <- activity_daily %>%
  left_join(sport_daily, by = c("athlete_id", "date")) %>%
  left_join(workout_daily, by = c("athlete_id", "date")) %>%
  left_join(hr_zone_daily, by = c("athlete_id", "date")) %>%
  left_join(power_zone_daily, by = c("athlete_id", "date"))

dim(activity_daily_complete)
names(activity_daily_complete)

activity_daily_complete %>% count(athlete_id, date) %>% filter(n > 1) #duplicate check

# MERGE WITH DAILY DATA
final_data <- daily_data %>%
  left_join(activity_daily_complete, by = c("athlete_id", "date"))

dim(final_data)
head(final_data)
names(final_data)
nrow(final_data)

# ADD ATHLETE CHARACTERISTICS
final_data <- final_data %>%
  left_join(athletes, by = "athlete_id", suffix = c("", "_athlete"))

dim(final_data)
names(final_data)
nrow(final_data)

# ACTIVITY PRESENT
final_data <- final_data %>%
  mutate(activity_present = ifelse(is.na(number_of_activities), 0, 1))

table(final_data$activity_present)

# MISSING ACTIVITY COUNT = ZERO
final_data <- final_data %>%
  mutate(number_of_activities = replace_na(number_of_activities, 0))

# ZERO FOR NO ACTIVITY
final_data <- final_data %>%
  mutate(
    duration_minutes = replace_na(duration_minutes, 0),
    tss = replace_na(tss, 0),
    distance_km = replace_na(distance_km, 0),
    distance_m = replace_na(distance_m, 0),
    work_kilojoules = replace_na(work_kilojoules, 0),
    elevation_gain = replace_na(elevation_gain, 0)
  )

# FINAL CHECK
dim(final_data)
nrow(final_data)
ncol(final_data)
names(final_data)
str(final_data)

# FINAL DUPLICATE CHECK
final_data %>% count(athlete_id, date) %>%
  filter(n > 1)

# DATE RANGE CHECK
min(final_data$date)
max(final_data$date)
length(unique(final_data$date))

# INJURY CHECK
table(final_data$injury, useNA = "ifany")
summary(final_data$injury)

# ACTIVITY VS NO ACTIVITY
table(final_data$activity_present)
table(final_data$injury, final_data$activity_present, useNA = "ifany")

# MISSING VALUES
missing_summary <- data.frame(
  variable = names(final_data),
  missing_count = sapply(final_data, function(x) sum(is.na(x))),
  missing_percent = sapply(final_data, function(x) mean(is.na(x)) * 100))

missing_summary <- missing_summary %>% arrange(desc(missing_percent))
head(missing_summary,30)


# SORT DATA
final_data <- final_data %>% arrange(athlete_id, date)

# SAVE 
write.csv(final_data, "athlete_day_final.csv", row.names = FALSE)

# TEST
test_data <- read.csv("athlete_day_final.csv")

dim(test_data)
head(test_data)
names(test_data)