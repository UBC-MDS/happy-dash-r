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

intiliaztion_ggplot <- ggplot(summary_df %>% dplyr::filter(country == "Canada"), aes(year, family)) +
  geom_line()

intiliaztion_plotly <- ggplotly(intiliaztion_ggplot)

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
                   figure = intiliaztion_plotly, 
                   style = list("height" = "30vh")
                   )
          # dccGraph(id = "features-over-time", style = list("height" = "70vh"))
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
    style = list("height" = "100vh")
  )
)

#******************************************* Callback definition***************************

filter_df <- function(summary_df, country_list, feat_list, year_range) {
  ret_df <- summary_df %>%
    dplyr::filter(country %in% country_list)
}


# output("features-over-time", "figure")
app$callback(
  output = list(output("happiness-over-time", "figure")),
  params = list(input("country-select-1", "value"), input("feature-select-1", "value"), input("year-select-1", "value")),
  function(country_list, feat_list, year_range) {
    happiness_plot <- summary_df %>%
      dplyr::filter(country %in% country_list) %>%
      ggplot(aes(year, family)) +
      geom_line()

    # features_plot <- ggplot(summary_df,aes(year,family)) +
    #  geom_line()
    # fig_list <- list(happiness_plot,features_plot)
    plot_out <- ggplotly(happiness_plot) %>% layout(dragmode = 'select')
    return(plot_out)
  }
)

app$run_server(debug = T)
