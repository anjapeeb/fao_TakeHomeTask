# ---- LOAD IN RELEVANT LIBRARIES
library(plotly)
library(stringr)
library(ggplot2)
library(shiny)
library(data.table)
library(hrbrthemes)

# ---- READ IN PRE-CLEANED PLOT DATA 
plot_data <- fread("./data/plot_data.csv")

ui <- fluidPage(    
  
  # PAGE TITLE
  titlePanel("Agriculture Production Value between 2014 and 2018"),
  
  # SIDEBAR
  sidebarLayout(      
    
    # DEFINE SIDEBAR INPUTS
    sidebarPanel(
      checkboxGroupInput("region", label = h3("World Bank Country regions"), 
                         choices = unique(plot_data$wb_group2021),
                         selected = "World"),
      hr(),
      helpText("World Bank Country regions")
    ),
    
    # LINE PLOTLY OUTPUT
    mainPanel(
      plotlyOutput("Plot")  
    )
    
  )
)
server <- function(input, output) {
  


  # ---- SET GLOBAL COLOURS
  colours <- ipsum_pal()(9)
  global_colors <- setNames(colours, unique(plot_data$wb_group2021))

  
  # ---- BUILD REACTIVE DATASET BASED ON USER SELECTION
  data <- reactive({
    data <- plot_data[plot_data$wb_group2021 %in% input$region,]
    return(data)
  })

  # ---- PLOT GRAPH
  plot <- reactive({
    
    data <- data()
    ggplot(data) +
      geom_line(aes(x=year_code, 
                    y=agriculture_production_value_per_capita_countrygroup, group =wb_group2021, colour =wb_group2021 ), size=1.5, linetype = "dashed") +
      geom_point(aes(x=year_code, 
                     y=agriculture_production_value_per_capita_countrygroup, group = wb_group2021, colour =wb_group2021 ), size=3) +
      scale_colour_manual(values = global_colors) +
      labs(
        colour = "Region",
        title="Per capita Agriculture Production Value",
        subtitle="by World Bank Country Regions and Year",
        caption="Source: World Bank & FAO",
        x = "Year", y = "Agriculture Production Value per Capita"
      ) +
      theme_ipsum() +
      theme(
        plot.title = element_text(),
        legend.title = element_text(),
        plot.subtitle = element_text(),
        plot.caption = element_text()
      )
  
  })
  

  # ---- RENDER PLOT AS A PLOTLY OBJECT
  output$Plot <- renderPlotly({
    plotly_plot <- ggplotly(plot())%>%
      layout(annotations = 
               list(x = 1, y = -0.1, text = "Source: World Bank & FAO", 
                    showarrow = F, xref='paper', yref='paper', 
                    xanchor='right', xshift=25, yshift=-40,
                    font=list(size=15, color="grey"))
      )  
    
    for (i in 1:length(plotly_plot$x$data)){
      if (!is.null(plotly_plot$x$data[[i]]$name)){
        plotly_plot$x$data[[i]]$name =  gsub("\\(","",str_split(plotly_plot$x$data[[i]]$name,",")[[1]][1])
      }
    }
    plotly_plot
  })
  


}

shinyApp(ui, server)

