library(shiny)
library(ggplot2)

# Define server logic required to plot data and regression line
shinyServer(function(input, output,session) {

  df <- read.csv("rentals3.csv",header=FALSE)
  colnames(df)<-c("Street Address","City","Zip","Price","Beds","Baths","Latitude","Longtitude","Sqft","Type")
  
  msp_zip<-read.csv("msp_zip.csv")
  msp_zip$Date <- as.Date(msp_zip$Date, "%Y-%m-%d")
  
  df_prr<-read.csv("prr.csv")
  df_prr$Date <- as.Date(df_prr$Date, "%Y-%m-%d")
  #df_PRR<-read.table("prr.csv",header = TRUE)
  #scolnames(df_PRR)<-c('Date','PRR','Zip')
  mon_rate<-.0284/12
  mon_num<-15*12
  tax_rate<-2.248
  
  month_pay<-reactive({(input$sale_price - input$down_payment)*((mon_rate*(1+mon_rate)^mon_num)/((1+mon_rate)^mon_num-1))+(input$sale_price/100*tax_rate/12)})



  
  # Generate plot
  output$main_plot <- renderPlot({
    
    # Get min and max values based on input
    #bed_input <- input$bed_num
    #bath_input <- input$bath_num
    zip_input<-input$zipcode
    req_rent<-input$target+month_pay()
    # Create a subset of data
    df_subset <- subset(df, Zip==zip_input) #& Beds==bed_input )
    

    # Plot data, subset data, and regression line
    g <-ggplot(df_subset,aes(x=Price)) + 
      geom_histogram(bins=30, fill="#56B4E9")+
      geom_vline(aes(xintercept=median(Price, na.rm=T)), color="#0072B2", linetype="dashed", size=1)+
      geom_vline(aes(xintercept=req_rent), color="#D55E00", linetype="dashed", size=1)+
      geom_text(aes(x=median(Price, na.rm=T)), label="\nMedian rent", y=5, colour="#0072B2", angle=90,size=5)+
      geom_text(aes(x=req_rent), label="\nTarget rent", y=5, colour="#D55E00", angle=90,size=5)+
      ggtitle("Distribution of Rental Units by Price per Selected Zipcode")
    print(g)
  })
  
  output$sale_plot <- renderPlot({
  
    zip_input<-input$zipcode
    df2_subset <- subset(msp_zip, X3==zip_input)

    g2<-ggplot(df2_subset,aes(x=Date,y=Value))+geom_line()+ggtitle("Median Sale Price for Selected ZipCode")
    print(g2)
    })
  
  output$prr_plot <- renderPlot({
    
    zip_input<-input$zipcode
    df3_subset <- subset(df_prr, X3==zip_input)
    req_prr<-median(df_prr$Value)
    g3<-ggplot(df3_subset,aes(x=Date,y=Value))+geom_line()+
      geom_hline(aes(yintercept=req_prr), color="#D55E00", linetype="dashed", size=1)+
      ggtitle("Price-to-rent-ratio for Selected ZipCode")
    print(g3)
  })

  output$ts <- renderPlot({
    zip<-input$zipcode
    dfts<-subset(df_prr, X3==zip )
    dfts$X3<-NULL
    dfts$Date<-NULL
    dfts<-ts(dfts,start = c(2010,10),frequency = 12)
    dftsde<-decompose(dfts)
    plot(dftsde)
  })
})