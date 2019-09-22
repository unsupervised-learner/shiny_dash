library(shiny)
library(reticulate)
library(ggplot2)
library(dplyr)
os<-reticulate::import('os')

#edit to where the stock data is located
data_path <- '/home/vernon/Desktop/stockData/'

d_path2 <- '/home/vernon/Desktop/'
path <- paste(d_path2, 'combined_stocks.csv', sep='')
dataframe <- read.csv(path)

#load names of stocks
load_names <- function(){
  names<-read.csv(paste(d_path2, 'names.csv', sep=''))
  return(names)
}

# user interface ###########
ui<-fluidPage(
  textOutput(
    outputId = 'Name'
  ),
  
  sidebarLayout(
    sidebarPanel(
      tags$h2('Options'),
      tags$br(),
      dateRangeInput(
        inputId = 'date_selector',
        label = 'Select date range',
        start = '2010-01-01',
        end = '2019-01-01',
        min = '2000-01-01',
        max = '2019-01-01'
      ),
      tags$br(),
      
      uiOutput(
        outputId = 'ticker_selection_dynamic'
      ),
      
      selectInput(
        inputId = 'ticker_select',
        label = 'select ticker to visualize',
        choices = load_names()
      ),
      wellPanel(
      tags$h4('advanced options'),
      selectInput(
        inputId = 'second_ticker',
        label = 'select second ticker to visualize',
        choices = load_names()
      )),
      
      textOutput(
        outputId = 'last_refreshed'
      ),
      
      actionButton(
        inputId = 'button1',
        label = 'refresh'
      ),
      uiOutput(
        outputId = 'moving_average_options'
      )
    ),
    mainPanel(
      textOutput(
        outputId = 'ticker_label'
      ),
      
      plotOutput(
        outputId = 'ticker_viz_hist',
        height = '200px'
      ),
      plotOutput(
        outputId = 'time_series',
        height = '250px'
      ),
      plotOutput(
        outputId = 'time_series2',
        height = '250px'
      )
    )
  )
)
## application logic ########
server<-function( input, output ){
  stock_dataframe<-reactive({
    tick_to_load<-input$ticker_select
    start<-as.Date(start_date())
    end_date<-as.Date(end_date())
    things<-as.character(data['Date'])
    targ<-as.Date(data['Date'][[1]])
    bool_vect<-(targ > start) & (targ < end_date)
    data_sub<-subset(dataframe, bool_vect)
    data_sub2<-subset(data_sub, data_sub$ticker_name == input$ticker_select)
    return(data_sub2)
  })
  
  second_dataframe<-reactive({
    tick_to_load<-input$second_ticker
    start<-as.Date(start_date())
    end_date<-as.Date(end_date())
    things<-as.character(data['Date'])
    targ<-as.Date(data['Date'][[1]])
    bool_vect<-(targ > start) & (targ < end_date)
    data_sub<-subset(dataframe, bool_vect)
    data_sub2<-subset(data_sub, data_sub$ticker_name == tick_to_load )
    return(data_sub2)
  })
  
  var_selected<-reactive({
    return(input$var_select)
  })
  
  start_date<-reactive({
    date<-input$date_selector
    start_date<-date[1]
    return(start_date)
  })
  
  end_date<-reactive({
    date<-input$date_selector
    end_date<-date[2]
    return(end_date)
  })
  
  output$ticker_label<-renderText({
    return(paste('ticker selected:',input$ticker_select))
  })
  
  output$ticker_viz_hist<-renderPlot({
    ggplot(data=stock_dataframe(),aes(x=Volume))+geom_histogram()+stat_bin(bins=30)+xlab('Volume')
  })
  
  output$time_series<-renderPlot({
    varname<-input$var_select
      lst_tick1<-lm(stock_dataframe()$Adj.Close ~ seq(length(stock_dataframe()$Adj.Close)))
      lst_tick2<-lm(second_dataframe()$Adj.Close ~ seq(length(second_dataframe()$Adj.Close)))
      plot(stock_dataframe()$Adj.Close, type='l', main='Adjusted Close vs. time', ylab ='Adj Close', xlab = 'time', lwd=5)
      abline(lst_tick1, col='red')
      lines(as.array(second_dataframe()$Adj.Close))
      abline(lst_tick2, col='blue')  
    #ggplot(data=stock_dataframe(), aes(x='Date', y=varname))+geom_line()
  })
  
  output$time_series2<-renderPlot({
    plot(stock_dataframe()$Volume, type='l', lwd=3, xlab='time', ylab='Volume', main='Volume vs time')
  })
  
  output$last_refreshed<-renderText({
    return(paste('last updated on:',Sys.time()))
  })
 
}

shinyApp(ui=ui, server=server)