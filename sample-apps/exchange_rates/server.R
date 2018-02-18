
library("shiny")
library("XML")
library("plotly")

#fetching the XML data frrom the ECB's site
currencyxml = xmlParse("http://www.ecb.europa.eu/stats/eurofxref/eurofxref-hist.xml?8b1f39196fc90744834af6c3cb878bc5")


#The currencies which can be displayed,  and their three letter codes
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

#Name space for the Xpath functions
namespaces = c(ns="http://www.ecb.int/vocabulary/2002-08-01/eurofxref")

output = list()
                 
shinyServer(function(input, output) {
  
  # This option disables the warning regarding Shiny ignoring widget IDs
  options(warn = -1)
  
  # Using XPath to find the rate nodes with currency equal to the selected input
  nodes = reactive({
    ratesxpath = paste0("//ns:Cube[@currency='", input$currency, "']")
    getNodeSet(currencyxml, ratesxpath, namespaces)
                    })
  
  # Using xpath to find the date nodes with the currency as a parent node
  indexcalc = reactive({
    datesxpath = paste0("//ns:Cube[*/@currency='",input$currency ,"']")
    datenodes = getNodeSet(currencyxml, datesxpath, namespaces )
    as.Date(sapply(datenodes, xmlGetAttr, "time"), format='%Y-%m-%d')
                      })
  
  #The dataframe required per the marking scheme
  df = reactive({data.frame(indexcalc(), nodes())})
  
  # This function calculaates the year on year change, defined as the latest
  # exchange rate value minus the earliest value in thhe last 365 days, divided
  # by thaat same earliest value.
  output$change = renderText({
    rateindex = indexcalc()
    ratelist = as.numeric(sapply(nodes(), xmlGetAttr, "rate") )
    currentdate = max(rateindex)
    previousdate = min(rateindex[rateindex >= currentdate - 365])
    currentrate = max(ratelist[rateindex == currentdate])
    previousrate = max(ratelist[rateindex == previousdate])
    rm(rateindex, ratelist)
    percentage = round(100*(currentrate-previousrate)/previousrate,2)
    percentage = paste0("<div style = \"text-align:center\"><b>", toString(percentage), "%</b></div>")
    HTML(percentage)
                            })
  
  # Finds the earliest date for which we have a value for the currency
  # Output as a string
  output$earlydate = renderText({
    earliest = format(min(indexcalc()), "%d/%b/%Y")
    earliest = toString(earliest)
    earliest = paste0("<div style = \"text-align:center\"><b>", toString(earliest), "</b></div>")
    HTML(earliest)
                                })
  
  # The latest date for which we have a value for the currency
  # Output as a string
  output$latedate = renderText({
    latest = format(max(indexcalc()), "%d/%b/%Y")
    latest = toString(latest)
    latest = paste0("<div style = \"text-align:center\"><b>", toString(latest), "</b></div>")
    HTML(latest)
                                })
  
  #Label for the percentage change value
  output$changelabel = renderText({HTML(paste0("<h4>Year-on-Year change in ", input$currency, ":</h4>"))})
  
  #Label for the earliest date value
  output$earlylabel = renderText({HTML("<h4>Earliest  Available Data:</h4>")})
  
  #Output for the latest date value
  output$latelabel = renderText({HTML("<h4>Latest  Available Data:</h4>")})
  
  #The main plot of exchange rate plotted against date value
  output$mainplot =
    renderPlotly({
      plotcurrency = input$currency
      
      rates = as.numeric( sapply(nodes(), xmlGetAttr, "rate") )
      
      index = indexcalc()
      
      plot_ly(x = index, y = rates, mode = 'lines', type = "scatter") %>%
        config(displayModeBar = FALSE) %>%
        layout(title = paste('Euro to',plotcurrency, 'Exchange Rate'),
               paper_bgcolor = "#ffffff",
               plot_bgcolor = "rgb(229, 229, 229)",
               xaxis = list(title = "Time", 
                            gridcolor = "rgb(255, 255, 255)",
                            rangeslider = list(type = "date"),
                            rangeselector = list(
                              buttons = list(
                                list(
                                  count = 3, 
                                  label = "3 mo", 
                                  step = "month",
                                  stepmode = "backward"),
                                list(
                                  count = 1, 
                                  label = "1 yr", 
                                  step = "year",
                                  stepmode = "backward"),
                                list(step = "all")))),
               yaxis = list (title = "Exchange Rate",
                             gridcolor = "rgb(255, 255, 255)")
                              )
    })})
