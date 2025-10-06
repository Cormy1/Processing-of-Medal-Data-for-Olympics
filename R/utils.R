medal_counter <- function(medal.athlete.df, 
                          populations, 
                          nocs){
  
  #' Function for counting the medals each athlete won with teams treated as a nominal athlete
  #' 1) I have previously gone through and changed all team/ pair events to have the athlete name as the country name to make this process easier. This was combination of code and some ad hoc changes as I couldn't find a datset with this consitantly done in
  #' 2) Frist count all team medals as a single medallits
  #' 3) categorise individual medallists as single, double, triple, etc. medallists (For teh sapn of what I looked at 5 was enough as no athltete won more than 5 medals in individual events)
  
  # Goal: Satisy poisson assumption
  # Counting team medals
  team.medals <- medal.athlete.df %>%
    group_by(slug_game, country_long, name) %>%
    summarise(team_meds = n(), .groups = 'drop')%>%
    filter(name == country_long)
  
  # Categorising and counting types of individual medallists
  ind.medals <- medal.athlete.df%>%
    filter(name != country_long) %>%
    group_by(slug_game, country_long, name) %>%
    summarise(total_medals = n(), .groups = 'drop')%>%
    group_by(slug_game, country_long, name)%>%
    summarise(medals.1 = sum(total_medals==1), 
              medals.2 = sum(total_medals==2), 
              medals.3 = sum(total_medals==3),
              medals.4 = sum(total_medals==4),
              medals.5 = sum(total_medals==5),.groups = 'drop')%>%
    group_by(slug_game, country_long)%>%
    summarise(Medals.1 = sum(medals.1),
              Medals.2 = sum(medals.2),
              Medals.3 = sum(medals.3),
              Medals.4 = sum(medals.4), 
              Medals.5 = sum(medals.5))
  
  # Joining individual and team medallists and adding team medals to count of single medallists
  medal.df <- full_join(ind.medals, team.medals, by = c("country_long", "slug_game"))%>%
    mutate(
      Medals.1 = ifelse(is.na(Medals.1), 0, Medals.1),
      Medals.2 = ifelse(is.na(Medals.2), 0, Medals.2),
      Medals.3 = ifelse(is.na(Medals.3), 0, Medals.3),
      Medals.4 = ifelse(is.na(Medals.4), 0, Medals.4),
      Medals.5 = ifelse(is.na(Medals.5), 0, Medals.5), 
      Medals.team = ifelse(is.na(team_meds), 0, team_meds)
    )%>%
    select(-c(name, team_meds))%>%
    mutate(Medals.1.team = Medals.1 + Medals.team,
           Medals.total = Medals.1.team + 2*Medals.2 + 3*Medals.3 + 4*Medals.4 + 5*Medals.5, 
           Medals.unique = Medals.1.team + Medals.2 + Medals.3 + Medals.4 + Medals.5)
  
  return(medal.df %>%
           select(slug_game, country_long,
                  Medals.1, Medals.2, Medals.3, Medals.4, Medals.5,
                  Medals.team, Medals.1.team, Medals.total, Medals.unique))
}

tidy_medal_n <- function(rawdata_medals, 
                         rawdata_populations, 
                         rawdata_nocs
                         ){
  
  medals <- read.csv(rawdata_medals)
  populations <- read.csv(rawdata_populations)
  nocs <- read.csv(rawdata_nocs)
  
  # Removing medal wins from nocs without an associated population
  medal.athlete.df <- medals %>% filter(
                                        !(country_long %in% c("Independent Olympic Athletes", "Refugee Olympic Team", "AIN" )))
  
  medal.df <- medal_counter(medal.athlete.df, 
                            populations, 
                            nocs)
  
  custom_codes <- c(Kosovo = "XKX", `Serbia and Montenegro` = "SRB", ROC = "RUS", `Virgin Islands` = "VIR") #Manually adding codes for Kosovo and Serbia and Montenegro (2004 games) # remove if not applicable to analysis
  
  country_code <- countrycode(medal.df$country_long, "country.name", "iso3c" , custom_match = custom_codes)
  
  medal.df$iso_a3 = country_code
  
  # medal.df <- medal.df[,c(1,2,12, 3:11)] #just rearranging the columns; probaly not needed 
  
  nocs <- nocs %>% select(-yr2000)%>%
    rowwise() %>%
    filter(any(c_across(yr2004:yr2024)))
  
  country_code <- countrycode(nocs$country, "country.name", "iso3c", custom_match = custom_codes)
  
  nocs$iso_a3 <- country_code
  
  # combine Russia and ROC to same row
  nocs[nocs$country =="Russia", 4:9] <- nocs[nocs$country == "Russia",4:9 ] + nocs[nocs$country == "ROC", 4:9] 
  
  #Combine Serbia and Serbia & Montenegro to same row
  nocs[nocs$country == "Serbia", 4:9] <- nocs[nocs$country == "Serbia and Montenegro", 4:9] + nocs[nocs$country == "Serbia", 4:9]
  
  #Removing countries that don't exist/ nomlectture awkward and no medal counts
  nocs.df <- nocs %>% filter(!country %in% c( "Individual Neutral Athletes", "ROC", "Serbia and Montenegro","Netherlands Antilles")) %>%
    select(-code)
  
  
  pops <- populations %>% filter(ISO3 %in% nocs.df$iso_a3, #countries of interest
                                 Year %in% c(2004, 2008, 2012, 2016, 2021, 2024)) %>%  #years of interest
    select(ISO3, Year, total_pop_july) %>% 
    mutate(total_pop_july = gsub("\\s", "", total_pop_july),  # Remove spaces
           total_pop_july = as.numeric(total_pop_july)*1000)  # Convert to numeric and scale appropriately
  
  year_to_games <- c(
    "2024" = "paris-2024",
    "2021" = "tokyo-2020",
    "2016" = "rio-2016",
    "2012" = "london-2012",
    "2008" = "beijing-2008",
    "2004" = "athens-2004"
  )
  
  year_to_slug_game <- c(
    "yr2004" = "athens-2004",
    "yr2008" = "beijing-2008",
    "yr2012" = "london-2012",
    "yr2016" = "rio-2016",
    "yr2020" = "tokyo-2020",
    "yr2024" = "paris-2024"
  )
  
  pops <- pops %>%
    mutate(slug_game = year_to_games[as.character(Year)])%>% 
    select(ISO3, total_pop_july, slug_game)
  
  #combined data frame of whether competed or not
  pop.comp.df <- nocs.df %>% 
    pivot_longer(cols = starts_with("yr"), #converting to long format by year
                 names_to = "year", 
                 values_to = "competed")%>%  
    mutate(slug_game = year_to_slug_game[year])%>% # add slug_game variable
    select(country, iso_a3, slug_game, competed)%>% 
    left_join(pops, by = c("iso_a3" = "ISO3", "slug_game")) # join by year and country name with population
  
  medal.pop_df <-pop.comp.df%>% 
    left_join(medal.df, by = c("iso_a3", "slug_game")) %>% 
    replace_na(list(
      Medals.1 = 0, Medals.2 = 0, Medals.3 = 0, Medals.4 = 0, 
      Medals.5 = 0, Medals.team = 0, Medals.1.team = 0, 
      Medals.total = 0, Medals.unique = 0
    ))%>%select(-country_long)
  # %>%
  #   mutate(pop_cat = case_when(
  #     total_pop_july < 1e6 ~ "Small [0, 1mil)",
  #     total_pop_july  >= 1e6 & total_pop_july < 10e6 ~ "Small mid [1mil, 10mil)",
  #     total_pop_july  >= 10e6 & total_pop_july < 50e6 ~ "Mid [10 mil, 50mil)",
  #     total_pop_july  >= 50e6 & total_pop_july < 100e6 ~ "Large Mid [50mil, 100mil)",
  #     total_pop_july  >= 100e6  ~ "Large >=100mil"
  #   ))
  
  medal.pop_df
}