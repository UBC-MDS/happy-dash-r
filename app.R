library(dash)
library(dashCoreComponents)
library(dashHtmlComponents)
library(dashBootstrapComponents)
library(tidyverse)
library(plotly)


app <- Dash$new(external_stylesheets = dbcThemes$BOOTSTRAP)

#********************************* Define constants *******************************************

summary_df <- read.csv("data/processed/summary_df.csv") %>%
  arrange(country)

feature_dict <- tibble(
  "GDP Per Capita" = "gdp_per_capita",
  "Family" = "family",
  "Life Expectancy" = "health_life_expectancy",
  "Freedom" = "freedom",
  "Corruption" = "perceptions_of_corruption",
  "Generosity" = "generosity",
  "Dystopia baseline + residual" = "dystopia_residual"
)

year_range <- summary_df$year %>% unique()
year_range <- setNames(as.list(as.character(year_range)), as.integer(year_range))

#************************************** Layout building************************************

sidebar <- dbcCol(
  list(
    htmlH1("World Happiness Report Explorer", className = "display-5"),
    htmlHr(),
    htmlH2("Features", className = "display-6"),
    htmlHr(),
    dbcChecklist(
      id = "feature-select-1",
      options = purrr::map(feature_dict %>% colnames(), function(col) list(label = col, value = feature_dict[[col]])),
      value = feature_dict %>% slice(1) %>% unlist(., use.names = FALSE)
    ),
    htmlHr(),
    htmlH3("Year Range", className = "display-6"),
    dccRangeSlider(
      id = "year-select-1",
      min = min(summary_df$year),
      max = max(summary_df$year),
      step = 1,
      value = c(2015, 2019),
      pushable = 1,
      marks = year_range,
    ),
    htmlHr(),
    htmlH3("Countries", className = "display-6"),
    dbcCol(
      list(
        dccDropdown(
          id = "country-select-1",
          multi = TRUE,
          options = purrr::map(summary_df$country %>% unique(), function(con) list(label = con, value = con)),
          value = c("Canada", "Switzerland", "China"),
        )
      ),
      width = 12,
      style = list("padding" = "10px 10px 10px 0px"),
    )
  ),
  style = list("background-color" = "#f8f9fa"),
  md = 3,
)

content <- dbcCol(
  children =
    list(dccLoading(
      children =
        list(
          dccGraph(id = "happiness-over-time",
                   style = list("height" = "30vh")
                   ),
          dccGraph(id = "features-over-time", style = list("height" = "70vh"))
        ), type = "cube"
    )),
  md = 9,
)

app$layout(
  dbcContainer(
    list(dbcRow(
      list(sidebar, content),
      className = "h-100"
    )),
    fluid = TRUE,
    style = list("height" = "100vh", "width"="80%")
  )
)

#******************************************* Callback definition***************************

filter_df <- function(summary_df, country_list, feat_list, year_range) {
  years = seq.int(year_range[[1]],year_range[[2]])
  ret_df <- summary_df %>%
    filter(country %in% country_list) %>%
    filter(year %in% years)

  add_to_feat <- c("country", "happiness_score", "year")
  feat_list <- c(feat_list,add_to_feat)
  ret_df <- ret_df[,as.character(feat_list)]
  return(ret_df)
}



app$callback(
  output = list(output("happiness-over-time", "figure"),output("features-over-time", "figure")),
  params = list(input("country-select-1", "value"), input("feature-select-1", "value"), input("year-select-1", "value")),
  function(country_list, feat_list, year_range) {

    all_feats = as.character(feature_dict %>% slice(1))

    if (length(feat_list)==0) {
      feat_list = all_feats
    }

    if (length(country_list)==0) {
      country_list = list("Canada")
    }

    filtered_df <- filter_df(summary_df = summary_df,country_list = country_list,feat_list = feat_list,year_range = year_range) %>%
      mutate(year = lubridate::as_date(paste(year,1,1,sep='-')))

    happiness_plot <- filtered_df %>%
      ggplot(aes(year, happiness_score,color=country)) +
      geom_line() +
      geom_point() +
      ggtitle("Happiness Score Over Time by Country")


  features_plot <- filtered_df %>%
    select(-c("happiness_score")) %>%
    pivot_longer(as.character(feat_list)) %>%
    left_join(feature_dict %>%
                pivot_longer(everything(), names_to = "feature_label", values_to = "feature"),
              by = c("name" = "feature")) %>%
    ggplot(aes(x = year, y = value, color = country)) +
    geom_line() +
    geom_point() +
    facet_wrap(~feature_label, ncol = 2, scales = "free_y") +
    ggtitle("Impact Of Features Over Time On Happiness Score")


    plot_out <- ggplotly(happiness_plot) %>% layout(dragmode = 'select')
    plot_out2 <- ggplotly(features_plot) %>% layout(dragmode = 'select')
    return(list(plot_out,plot_out2))
  }
)

app$run_server(host = '0.0.0.0')
