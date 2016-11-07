#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)

convert_units<-function(val,unit_in,unit_out){
  if (unit_out=="Kg"){
    return(ifelse(unit_in=="Kg",val,val*0.453592))
  }
  else if (unit_out=="Lb"){
    return(ifelse(unit_in=="Lb",val,val*2.20462))
  }
  else if (unit_out=="cm"){
    return(ifelse(unit_in=="cm",val,val*2.54))
  }
  else if (unit_out=="in"){
    return(ifelse(unit_in=="in",val,val*0.393701))
  }
}

#This is a simple TDEE calculator. 
#The BMR is calculated using one of two methods:
#Mifflin-St. Jeor for no BF%
MSJ_BMR<-function(age,sex,height_val,height_unit,weight_val,weight_unit){
  add_sex=ifelse(sex=="F",-161,5)
  add_height=6.25*convert_units(height_val,height_unit,"cm")
  add_weight=10*convert_units(weight_val,weight_unit,"Kg")
  add_age=-5*age
  return(add_sex + add_height + add_weight + add_age)
}
#Katch-McArdle for BF%
KM_BMR<-function(weight_val,weight_unit,bf_pct){
  bf_pct=ifelse(bf_pct<1,bf_pct*100,bf_pct)
  lean_mass_pct=100-bf_pct
  correct_weight=convert_units(weight_val,weight_unit,"kg")
  lean_mass=(lean_mass_pct/100)*correct_weight
  return(370 + 21.6*lean_mass)
}
#TDEE
tdee_calc<-function(bmr,activity){
  activity_mult=ifelse(activity=="Sedentary",1.2,
                       ifelse(activity=="Light",1.375,
                              ifelse(activity=="Moderate",1.55,
                                     ifelse(activity=="Heavy",1.725,
                                            1.9))))
  return(bmr*activity_mult)
}
#Caloric intake calculation
calorie_count<-function(tdee,weight_goal,weight_change=0,weight_unit="Kg"){
  if (weight_goal=="Maintenance"){
    return(tdee)
  }else{
    cal_change=ifelse(weight_unit=="Lb",(weight_change*3500)/7,
                      (weight_change*2.205*3500)/7)
    if (weight_goal=="Cutting"){
      cal_change=-cal_change
    }
    return(tdee+cal_change)
  }
}

# Define UI for application that generates table
ui <- fluidPage(
   
   # Application title
   titlePanel("Daily Caloric Intake Calculation"),
   
   # Sidebar with a slider input for number of bins 
   sidebarLayout(
      sidebarPanel(
         helpText("Note: for all numerical entries, only enter the number (no other characters)."),
         helpText("Make sure you select the correct units!"),
         selectInput("sex", "Select Sex:",
                     choices=c("F","M")),
         textInput("age", "Enter Age:"),
         textInput("height","Enter Height:"),
         selectInput("height_units","Units:",
                     choices=c("cm","in")),
         textInput("weight","Enter Weight:"),
         selectInput("weight_units","Units:",
                     choices=c("Kg","Lb")),
         textInput("bf","Enter % Body Fat (optional):"),
         selectInput("active","Select Activity Level:",
                     choices=c("Sedentary","Light","Moderate",
                               "Heavy","Very Heavy")),
         selectInput("goal","Weight Goal:",
                     choices=c("Cutting","Maintenance","Bulking")),
         textInput("weight_change","Weight change per week (optional):"),
         selectInput("change_units","Units weight change:",
                     choices=c("Kg","Lb")),
         submitButton("Calculate Daily Caloric Intake")
      ),   
      # Display a table with 
      mainPanel(
        h4("Calculations"),
        helpText("If the body fat percentage is provided, ",
                 "the Katch-McArdle formula is used for BMR. ",
                 "Otherwise, the Mifflin-St. Jeor formula is used for BMR."),
        h5("Clarification on activity level:"),
        helpText("Sedentary: Desk job, little activity"),
        helpText("Light: 1-2 times exercise per week"),
        helpText("Moderate: 3-5 times exercise per week"),
        helpText("Heavy: 6-7 times exercise per week"),
        helpText("Very heavy: a physically demanding job or exercise more than once a day"),
        tableOutput("TDEEout")
      )
   )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
   
   output$TDEEout <- renderTable({
      # generate BMR based on inputs
     age=as.numeric(input$age)
     height=as.numeric(input$height)
     weight=as.numeric(input$weight)
     if (input$bf==""){
       bmr=MSJ_BMR(age,input$sex,
                   height,input$height_units,
                   weight,input$weight_units)
     }else{
       bf=as.numeric(input$bf)
       bmr=KM_BMR(weight,input$weight_units,bf)
     }
     #Calculate TDEE and Calorie Budget
     tdee=tdee_calc(bmr,input$active)
     weight_change=as.numeric(input$weight_change)
     cals=calorie_count(tdee,input$goal,weight_change,input$change_units)
     
     #Create a table
     out_table=data.frame(BMR=as.integer(round(bmr)),
                          TDEE=as.integer(round(tdee)),
                          Calories=as.integer(round(cals)))
     #print(out_table)
   })
}

# Run the application 
shinyApp(ui = ui, server = server)

