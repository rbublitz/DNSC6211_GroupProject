library(shiny)
library(shinythemes)


df<- read.csv("rentals3.csv",header=FALSE)
colnames(df)<-c("Street Address","City","Zip","Price","Beds","Baths","Latitude","Longitude","Sqft","Type")

zips<-unique(c(df$Zip))
# Define UI for application'

fluidPage(    
  theme = shinythemes::shinytheme("flatly"),
  # Give the page a title
  titlePanel("Rental Distribution by Price"),
  
  sidebarLayout(
  
  
  sidebarPanel(
    h4("Property Explorer"),
           #numericInput("bed_num", label = h5("Bedrooms: "), value = 1)
    numericInput("sale_price", label = h6("Sale Price: "), value = 200000),
    numericInput("down_payment",label=h6("Down Payment: "), value=50000),
    numericInput("target",label=h6("Target Profit Per Month: "), value=500),       
    selectInput('zipcode',label=h6('Zipcode'),zips)),
  
  mainPanel(
    tabsetPanel(type = "tabs", 
                tabPanel("Plot",br(), plotOutput("main_plot"),
                         h5("Assumptions:"),
                         h5("Interest rate: 2.84% (Freddie Mac average for 15yr FRM, Nov. 2, 2016)"),
                         h5("Mortgage Length: 15 Years"),
                         h5("Baltimore City Property Tax: $2.248 per $100 for non-resident owners")),
                tabPanel("Trend",br(), plotOutput("sale_plot"),h5("Data sourced from Trulia databases")),
                tabPanel("PRR Trend",br(), plotOutput("prr_plot"),plotOutput("ts"),h5("Data sourced from quandl databases"))
                
      )
    )
  )
)
