# Athlete injury prediction in synthetic triathletes

MATH1332 Minor Thesis · Semester 2, 2026 · Mariangela Chandler

I used two weeks of training and wellbeing data to see if I could predict an injury in the next week. I compared three models and looked at what the LSTM relied on most when making predictions.

## Repository files

| File | Purpose |
| --- | --- |
| [`01_build_athlete_day_dataset.R`](01_build_athlete_day_dataset.R) | Aggregates training sessions by athlete and date, joins daily measurements and athlete profiles, and exports one row per athlete per day. |
| [`02_athlete_injury_prediction.ipynb`](02_athlete_injury_prediction.ipynb) | Checks and prepares the data, selects predictors, trains and compares the models, and explains selected predictions. |
| [`data_dictionary.md`](data_dictionary.md) | Defines the model inputs, outcome and supporting fields. |
| [`requirements.txt`](requirements.txt) | Lists the Python packages used to run the notebook. |

## Run the analysis

Run these steps from the repository root.

1. Download `activity_data.csv`, `daily_data.csv` and `athletes.csv` from the [Zenodo dataset](https://doi.org/10.5281/zenodo.15401061) and place them beside the R script.
2. Install the R packages and build `athlete_day_final.csv`.

   ```sh
   Rscript -e 'install.packages(c("dplyr", "tidyr", "stringr", "lubridate"), repos = "https://cloud.r-project.org")'
   Rscript 01_build_athlete_day_dataset.R
   ```

3. In an activated Python environment, install the notebook dependencies and launch JupyterLab. The notebook was authored in Python 3.13.

   ```sh
   python -m pip install -r requirements.txt
   python -m jupyterlab 02_athlete_injury_prediction.ipynb
   ```

4. Select the Python kernel for that environment and run the notebook from top to bottom. The notebook reads `athlete_day_final.csv` and saves figures under `output/`.

## Data source

Rossi, L. (2025). *Synthetic Triathlete Dataset for Injury Prediction Research (2024)* (Version v1) [Data set]. Zenodo. [doi:10.5281/zenodo.15401061](https://doi.org/10.5281/zenodo.15401061)