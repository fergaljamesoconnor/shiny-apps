library(shiny)


currencylist = c("Australian Dollar"="AUD",
                 "Canadian Dollar"="CAD",
                 "Chinese Yuan" = "CNY",
                 "Czech Republic Koruna"="CZK",
                 "Danish Krone"="DKK",
                 "Hong Kong Dollar"="HKD",
                 "Hungarian Forint"="HUF",
                 "Indian Rupee" = "INR",
                 "Japanese Yen"="JPY",
                 "Korean (South) Won"="KRW",
                 "New Zealand Dollar"="NZD",
                 "Norwegian Krone"="NOK",
                 "Polish Zloty"="PLN",
                 "Swedish Krona"="SEK",
                 "Singaporean Dollar"="SGD",
                 "South African Rand"="ZAR",
                 "Swiss Franc"="CHF",
                 "United Kingdom Pound"="GBP",
                 "United States Dollar"="USD")

 shinyUI(fluidPage(
                tags$head(tags$style(HTML("body {background-color: #ffffff;}
                                           h2 {color: #2d3047;
                                               font-family: verdana;}
                                           #sidebar {background-color: #f7b736}
                                           hr {border-top: 1px solid #000000;}"))),
                titlePanel("Euro Exchange Rate Explorer", windowTitle = "Exchange Rate Explorer"),
                sidebarLayout(sidebarPanel(id = "sidebar", style = "border-width: 0px",
                 selectInput("currency", "Currency: ", currencylist),
                 hr(),
                 uiOutput("changelabel"),
                 uiOutput("change"),
                 hr(),
                 uiOutput("latelabel"),
                 uiOutput("latedate"),
                 uiOutput("earlylabel"),
                 uiOutput("earlydate")),
                 
                 mainPanel(id = "mainpanel", plotlyOutput(outputId = "mainplot"))),
               fluidRow()))

