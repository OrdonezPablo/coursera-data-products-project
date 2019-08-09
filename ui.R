library(shiny)
library(leaflet)

shinyUI(navbarPage("Equity Market Valuations",
               tabPanel("Global Overview",
                        mainPanel(
                            h1("Global Equity Market Valuations by Country"),
                            h2("Price to Earnings Ratio"),
                            leafletOutput('plotleaflet')
                                )
                        ),
               tabPanel("Country Detail",
                   pageWithSidebar(
                       headerPanel('P/E Forward by Index'),
                       sidebarPanel(
                           selectInput('index', 'P/E Index', unique(pe_ts_long$index))
                       ),
                       mainPanel(
                           plotlyOutput('plot1')
                                )
                                )
                        ),
               tabPanel("Reference",
                        mainPanel(
                            h5("This Shiny App is the Coursera Developing Data Products course final project"),
                            h5("The objective is to explore equity market valuations around the globe"),
                            h5("We use the price-to-earnings or P/E multiple as the main valuation metric."),
                            h5("Reference for P/E ratio:"),
                            a(href= "https://www.investopedia.com/terms/p/price-earningsratio.asp",
                              "https://www.investopedia.com/terms/p/price-earningsratio.asp",
                              target = "_blank"),
                            h5("Github Code:"),
                            a(href = "http://github.com",
                              "http://github.com",
                              target = "_blank")
                        ))
                )
        )
