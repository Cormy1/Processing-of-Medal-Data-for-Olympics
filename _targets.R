rm(list = ls())
library(targets)
library(tarchetypes) 

#' Discrepancies in London 2012 - USA 1 short in total, China 1 short, RUS 3 too many, SOutch Korea 1 short - presumably doping bans for Russia? Jamacia, Kenya 1 short each, azerrberjann 1 too many, Ethiopia 1 short - Overall 4 short in total!
#' 2008- Jamacia 1 short, 1 short overall (Chelsea Hammond missing for womans long jump - bronze medal,  "In 2017, the second-place finisher, Tatyana Lebedeva had a positive test for turinabol and was disqualified from her silver medal. The medals were redistributed and Blessing Okagbare was advanced to silver, and Chelsea Hammond was advanced to bronze.")- doesn't explain why i am one short overall still
#' 2004 seems to be done correctly


# Set target options:
tar_option_set(
  packages = c("tidyverse", "countrycode") 
)

tar_source("R/utils.R") #source of functions used in this workflow

#TO DO - Winter Olympics medal counts
list(
  tar_target(
    name = rawdata_medals, 
    command = "0_data/0_raw/medallists_1896-2024.csv",
    format = "file",
    description = "Medal winners at Olympic Games 2004 - 2024"
  ),
  tar_target(
    name = rawdata_populations,
    command = "0_data/0_raw/un_population_estimates_1950-2024.csv",
    format = "file", 
    description = "Population estimates from United Nations 1950 - 2024"
  ),
  tar_target(
    name = rawdata_nocs, 
    command = "0_data/0_raw/nocs_2000-2024.csv",
    format = "file", 
    description = "Nations competing in Games 2000 - 2024"
  ),
  tar_target(
    name = data_processed, 
    command = tidy_medal_n(rawdata_medals, rawdata_populations, rawdata_nocs), 
    description = "Counting single medal winners, double, triple, ... across each Games 2004 - 2024 for each country and combining with population estimate for July in year of Games"
  ),
  tar_target(
    name= export_medals.2024,
    command = {
      output_file = "0_data/1_output/Medalcounts_paris-2024.csv"
      df <- data_processed%>%filter(slug_game == "paris-2024")
      write.csv(df, output_file)
      output_file
    },
    format = "file",
    description = "Outputing results into csv file for back up"
  ),
  tar_target(
    name= export_medals.2020,
    command = {
      output_file = "0_data/1_output/Medalcounts_tokyo-2020.csv"
      df <- data_processed%>%filter(slug_game == "tokyo-2020")
      write.csv(df, output_file)
      output_file
    },
    format = "file",
    description = "Outputing results into csv file for back up"
  ),
  tar_target(
    name= export_medals.2016,
    command = {
      output_file = "0_data/1_output/Medalcounts_rio-2016.csv"
      df <- data_processed%>%filter(slug_game == "rio-2016")
      write.csv(df, output_file)
      output_file
    },
    format = "file",
    description = "Outputing results into csv file for back up"
  ),
  tar_target(
    name= export_medals.2012,
    command = {
      output_file = "0_data/1_output/Medalcounts_london-2012.csv"
      df <- data_processed%>%filter(slug_game == "london-2012")
      write.csv(df, output_file)
      output_file
    },
    format = "file",
    description = "Outputing results into csv file for back up"
  ),
  tar_target(
    name= export_medals.2008,
    command = {
      output_file = "0_data/1_output/Medalcounts_beijing-2008.csv"
      df <- data_processed%>%filter(slug_game == "beijing-2008")
      write.csv(df, output_file)
      output_file
    },
    format = "file",
    description = "Outputing results into csv file for back up"
  ),
  tar_target(
    name= export_medals.2004,
    command = {
      output_file = "0_data/1_output/Medalcounts_athens-2004.csv"
      df <- data_processed%>%filter(slug_game == "athens-2004")
      write.csv(df, output_file)
      output_file
    },
    format = "file",
    description = "Outputing results into csv file for back up"
  )
)
