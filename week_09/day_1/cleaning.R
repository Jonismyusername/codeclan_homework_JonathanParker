library(tidyverse)
library(janitor)

# Read in cancer data and geographic codes and clean names using the Janitor library.
cancer_data <- read_csv("data/cancer_data.csv") %>% 
  clean_names()

cancer_data_age_groups <- read_csv("data/cancer_data_2015_2019.csv") %>% 
  clean_names()

hb_codes <- read_csv("data/geography_codes_and_labels_hb2014_01042019.csv") %>% 
  clean_names()

# Join cancer data to codes and select relevant variables
cancer_data <- cancer_data %>% 
  left_join(hb_codes, by = "hb") %>% 
  select(hb, hb_name, cancer_site, sex, year, incidences_all_ages, crude_rate, easr, wasr)

# Repeat for cancer data with age groups
cancer_data_age_groups <- cancer_data_age_groups %>% 
  left_join(hb_codes, by = "hb") %>% 
# Pivot longer on columns for incidence rates to enable analysis of age groups
  pivot_longer(
    cols = contains("incidence_rate_"),
    names_to = "age_group",
    values_to = "incidence_rate"
  ) %>%
# Tidying up new age group column to make more legible  
  mutate(age_group = str_sub(age_group, start = 19),
         age_group = str_replace(age_group, "to", " - "),
         age_group = recode(age_group,
                            "_under5" = "0 - 4",
                            "5 - 9" = "05 - 09",
                            "85and_over" = "85+"
         )) %>% 
# Selecting relevant variables 
  select(cancer_site, sex, crude_rate, easr, wasr, hb_name, 
         age_group, incidence_rate, incidences_all_ages)

cancer_top_ten <- cancer_data %>% 
  filter(cancer_site != "All cancer types" 
         & sex == "All"
         & hb_name %in% southern_scotland
         & year == "2019"
  ) %>% 
  group_by(cancer_site) %>% 
  # mutate(total_incidences = sum(incidences_all_ages)) %>% 
  # view()
  summarise(total_incidences = sum(incidences_all_ages), hb_name) %>% 
  arrange(desc(total_incidences)) %>% 
  distinct(cancer_site) %>% 
  head(10) %>% 
  pull()

cancer_top_ten_scotland <- cancer_data %>% 
  filter(cancer_site != "All cancer types" 
         & sex == "All"
         # & hb_name %in% southern_scotland
         & year == "2019"
  ) %>% 
  group_by(cancer_site) %>% 
  # mutate(total_incidences = sum(incidences_all_ages)) %>% 
  # view()
  summarise(total_incidences = sum(incidences_all_ages), hb_name) %>% 
  arrange(desc(total_incidences)) %>% 
  distinct(cancer_site) %>% 
  head(10) %>% 
  pull()

cancer_top_ten_female <- cancer_data %>% 
  filter(cancer_site != "All cancer types" 
         & sex == "Female"
         & hb_name %in% southern_scotland
         & year == "2019"
  ) %>% 
  group_by(cancer_site) %>% 
  # mutate(total_incidences = sum(incidences_all_ages)) %>% 
  # view()
  summarise(total_incidences = sum(incidences_all_ages), hb_name) %>% 
  arrange(desc(total_incidences)) %>% 
  distinct(cancer_site) %>% 
  head(10) %>% 
  pull()

cancer_top_ten_male <- cancer_data %>% 
  filter(cancer_site != "All cancer types" 
         & sex == "Male"
         & hb_name %in% southern_scotland
         & year == "2019"
  ) %>% 
  group_by(cancer_site) %>% 
  # mutate(total_incidences = sum(incidences_all_ages)) %>% 
  # view()
  summarise(total_incidences = sum(incidences_all_ages), hb_name) %>% 
  arrange(desc(total_incidences)) %>% 
  distinct(cancer_site) %>% 
  head(10) %>% 
  pull()

# southern_scotland <- c("NHS Borders", "NHS Dumfries and Galloway", "NHS Ayrshire and Arran",
#                        "NHS Lanarkshire", "NHS Lothian", "NHS Greater Glasgow and Clyde")

  