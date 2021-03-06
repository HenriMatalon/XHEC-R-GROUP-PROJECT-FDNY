#' Give the statistic dataframe
#'
#' @param df main data frame
#' @param input shiny /list/ inputs
#'
#' @return data frame filtered and data frame with corresponding statistics
#' @import dplyr purrr
#'
#' @export
#' @rdname statistic_fdny
#'

statistic_fdny <- function(df, input){

  #call filter function to go from raw data to filtered data
  filtered_df <- filter_fdny(df, input)

  if(dim(filtered_df)[1]==0) {
    output <- list()
    messageEmpty <- data.frame(Message = c("No intervention match the filter."))
    output$filtered_df <- messageEmpty
    output$statistic_df <- messageEmpty
    output$number_intervention_per_type <- messageEmpty
    return(output)
  }

  #create list of each element we want
  elements1 <- list(
    get_deployment_time(filtered_df),
    get_inteventions_per_box(filtered_df),
    get_nb_units(filtered_df),
    get_intervention_duration(filtered_df)
  )

  #extract col from each element of the list
  elements2 <- map(elements1, "col") %>%
    set_names(c("Intervention Duration", "Nb of intervention per box per day", "Nb of Units Deployed", "Duration of the Intervention"))


  stat_df <- map_dfr(elements2, build_stat_df, .id = "statistic")

  n_per_type <- filtered_df %>%
    group_by(inc_type) %>%
    summarize(n = n()) %>%
    rename("Number of interventions"="n", "Type of incidents"="inc_type")

  output <- list()
  output$filtered_df <- filtered_df
  output$statistic_df <- stat_df
  output$number_intervention_per_type <- n_per_type
  return(output)
}
