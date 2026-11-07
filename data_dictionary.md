# Data dictionary

The models use 52 inputs. I kept 37 measurements that all three feature selection methods picked and added 15 columns that show which measurements were available. The tables also explain how I marked injuries and split the data.

## How I prepared the data

Each row in the prepared dataset is one athlete on one day. The same profile values, such as age, appear on each of that athlete’s rows. If an athlete had several sessions in one day, I combined them in R. For averages, each session with a recorded value counted equally. If every session was missing a value, the daily value started out missing.

I used zero in some fields on days without activity or when a measurement did not apply to the sport. In those fields, zero can be a placeholder. The availability columns show which values were present before I filled in missing values in Python.

Each prediction uses 14 days of data, including the prediction day. I used 14-day averages to choose features and gave the models the values for each day. I scaled the inputs using the mean and standard deviation from the training athletes. The tables show the units before scaling.

An asterisk (*) means I inferred the unit or meaning from the field name and values. The source does not give a formula or scale for some scores.

## Daily measurements

| Variable | Unit or scale | What it means |
| --- | --- | --- |
| `stress` | Score | Simulated daily stress. The source does not say what kind of stress it represents. |
| `hrv` | Unit unspecified | How much the time between heartbeats varies. The source does not say how it was calculated. |
| `resting_hr` | Beats per minute* | Resting heart rate for that day. |
| `body_battery_evening` | Score | Simulated evening energy or recovery score. |
| `deep_sleep` | Hours* | Time spent in deep sleep. |
| `body_battery_morning` | Score | Simulated morning energy or recovery score. |
| `sleep_quality` | Score | Sleep quality for that day. |
| `light_sleep` | Hours* | Time spent in light sleep. |
| `planned_tss` | Training stress score* | Planned training load for the day. |
| `actual_tss` | Training stress score* | Actual training load from `daily_data.csv`. The activity data have a separate `tss` column. |

## Athlete profiles

| Variable | Unit or scale | What it means |
| --- | --- | --- |
| `stress_factor` | Scale unspecified | The athlete’s profile value for stress. Daily stress is stored separately. |
| `sleep_quality_athlete` | Scale unspecified | Sleep quality from the athlete’s profile. |
| `drinking_factor` | Scale unspecified | A profile value related to drinking. The source gives no amounts or frequency. |
| `resting_hr_athlete` | Beats per minute* | Resting heart rate from the athlete’s profile. |
| `sleep_time_norm` | Hours* | Usual sleep time from the athlete’s profile. The source does not explain what `norm` means. |
| `age` | Years* | Age in the athlete’s profile. |
| `hrv_baseline` | Unit unspecified | The athlete’s usual heart rate variability. The source does not say how it was calculated. |
| `recovery_rate` | Scale unspecified | A profile value for recovery. The source does not say how it was calculated. |

## Training sessions

The heart rate and power zones come from `hr_zones` and `power_zones`. I treated each zone value as the percentage of a session spent in that zone. The daily zone values are averages of those percentages.

| Variable | Unit or scale | What it means |
| --- | --- | --- |
| `hr_z4` | Percent* | Average time in heart rate zone 4 as a share of each session. |
| `hr_z3` | Percent* | Average time in heart rate zone 3 as a share of each session. |
| `hr_z2` | Percent* | Average time in heart rate zone 2 as a share of each session. |
| `hr_z1` | Percent* | Average time in heart rate zone 1 as a share of each session. |
| `power_z1` | Percent* | Average time in power zone 1 as a share of each session. |
| `avg_pace_min_km` | Minutes per kilometre | Average running pace across the day’s sessions with a pace value. |
| `avg_pace_min_100m` | Minutes per 100 metres | Average swimming pace across the day’s sessions with a pace value. |
| `distance_m` | Metres | Total distance from the metre field, used for swimming. |
| `power_z3` | Percent* | Average time in power zone 3 as a share of each session. |
| `max_hr_activity` | Beats per minute* | Highest recorded heart rate across the day’s sessions. |
| `avg_hr` | Beats per minute* | Average of the session heart rates for the day. |
| `training_effect_aerobic` | Score | Average of the aerobic training effect scores for the day. |
| `avg_power` | Watts* | Average of the session power values for the day. |
| `avg_speed_kph` | Kilometres per hour | Average of the session speeds for the day. |
| `duration_minutes` | Minutes | Total time spent training that day. |
| `power_z4` | Percent* | Average time in power zone 4 as a share of each session. |
| `distance_km` | Kilometres | Total distance from the kilometre field, kept separate from `distance_m`. |
| `elevation_gain` | Metres* | Total elevation gained across the day’s sessions. |
| `intensity_variability` | Index with no unit* | Average of the session intensity variability values. The source gives no formula. |

## Which measurements were available

Before filling in missing values in Python, I marked each of these daily measurements as 1 if a value was present and 0 if it was missing. A 1 means there was a daily value. Some sessions on that day could still have missing values. I scaled these columns along with the other inputs.

| Variable | Measurement |
| --- | --- |
| `hr_z4__available` | Heart rate zone 4 |
| `hr_z3__available` | Heart rate zone 3 |
| `hr_z2__available` | Heart rate zone 2 |
| `hr_z1__available` | Heart rate zone 1 |
| `power_z1__available` | Power zone 1 |
| `avg_pace_min_km__available` | Running pace |
| `avg_pace_min_100m__available` | Swimming pace |
| `power_z3__available` | Power zone 3 |
| `max_hr_activity__available` | Highest activity heart rate |
| `avg_hr__available` | Average activity heart rate |
| `training_effect_aerobic__available` | Aerobic training effect |
| `avg_power__available` | Average power |
| `avg_speed_kph__available` | Average speed |
| `power_z4__available` | Power zone 4 |
| `intensity_variability__available` | Intensity variability |

## Injury labels and other fields

| Variable | What it means |
| --- | --- |
| `athlete_id` | ID used to match the same athlete across files and keep their rows together. |
| `date` | Calendar day for that row. |
| `injury` | 1 if the athlete was marked as injured that day, 0 otherwise. The data give no injury type or severity. |
| `injury_next_7d` | 1 if the athlete was marked as injured on any of the next seven days, 0 if all seven days had no injury. The value is missing if fewer than seven follow-up days are available. |
| `eligible_prediction` | True when the athlete has a full 14-day history, seven follow-up days and no recorded injury on the prediction day. The history can include earlier injury days. |
| `split` | The athlete’s group. I assigned 70% of athletes to training, 15% to validation and 15% to testing, using random seed 42. |
| `activity_present` | 1 if the athlete had at least one recorded session that day, 0 otherwise. |

Two predictions with overlapping follow-up days can refer to the same injury.

## Source

Rossi, L. (2025). [*Synthetic Triathlete Dataset for Injury Prediction Research (2024)*](https://doi.org/10.5281/zenodo.15401061) (Version v1) [Data set]. Zenodo.

See the [R script](01_build_athlete_day_dataset.R) and [notebook](02_athlete_injury_prediction.ipynb) for the preparation steps.
