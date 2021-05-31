library(shiny)
library(jsonlite)
library(httr)
library(data.table)


id <<- 0
results <<- data.frame(all=c(0, 0, 0), alive=c(0, 0, 0), dead=c(0, 0, 0))


server <- function(input, output) {
  config <- rjson::fromJSON(file = "config.json") 

  path <- config$host_url
  res <- GET(url = path)
  new_data = jsonlite::fromJSON(content(res, 'text'))
  new_data = jsonlite::fromJSON(new_data)
  id <<- new_data
  print(id)
  
  observeEvent(input$add, {
  
    data_ <- list("lifetime" = input$lifetime, "p_for_death" = input$death,
                          "p_for_reproduction" = input$reproduct, "type" = input$indiv_type)
    print(data_)
    json_data <- toJSON(data_, pretty = TRUE, auto_unbox = TRUE)
    print(json_data)
    path <- paste0(config$host_url, id, '/add/')
    res <- httr::POST(url = path, content_type_json(), body = json_data)
    
    new_data = jsonlite::fromJSON(content(res, 'text'))
    new_data = jsonlite::fromJSON(new_data)
    id <<- new_data
    
    print(id)
  })
  
  
  observeEvent(input$build, {
    data_ <- list('s_t' = input$selector_type,"s_m" = input$selector_mode,
                            "m_t" = input$mutator_type, "m_m" = input$mutator_mode,
                            "n" = input$iter, "name" = input$save_res_name)
    
    json_data <- toJSON(data_, pretty = TRUE, auto_unbox = TRUE)
    path <- paste0(config$host_url, id, '/run/')
    res <- httr::POST(url = path, content_type_json(), body = json_data)
    
    results <<- jsonlite::fromJSON(content(res, 'text'))
    
    output$plot <- renderPlot({
      df<- data.frame(all=unlist(results[c('all')]), alive=unlist(results[c('alive')]), dead=unlist(results[c('dead')]))
      print(df)
      barplot(t(as.matrix(df)), beside=TRUE)
    })
  })


  observeEvent(input$reset, {
    path <- paste0(config$host_url, id, '/delete/')
    res <- GET(url = path)
    
  })
  
  observeEvent(input$load_pop, {
    path <- paste0(config$host_url, 'db/populations/')
    res <- GET(url = path)
    new_data = fromJSON(rawToChar(res$content))
    print(new_data)
    output$table_1 <- DT::renderDataTable({data.frame(new_data)})
  })
  
  observeEvent(input$get_pop, {
    path <- paste0(config$host_url, input$load_pop_num)
    res <- GET(url = path)
    new_data = jsonlite::fromJSON(content(res, 'text'))
    new_data = jsonlite::fromJSON(new_data)
    id <<- new_data
    print(id)
  })
  
  observeEvent(input$load_res, {
    path <- paste0(config$host_url, 'db/results/')
    res <- GET(url = path)
    new_data = fromJSON(rawToChar(res$content))
    output$table_1 <- DT::renderDataTable({data.frame(new_data)})
  })
  
  observeEvent(input$get_res, {
    path <- paste0(config$host_url, input$load_pop_num)
    res <- GET(url = path)
    new_data = jsonlite::fromJSON(content(res, 'text'))
    new_data = jsonlite::fromJSON(new_data)
    id <<- new_data
    print(id)
  })
  
  
  observeEvent(input$save_pop, {
    data_ <- list("name" = input$save_pop_name)
    json_data <- toJSON(data_, pretty = TRUE, auto_unbox = TRUE)
    path <- paste0(config$host_url, id, '/save/')
    res <- httr::POST(url = path, content_type_json(), body = json_data)
  })

}