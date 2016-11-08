library(shiny)
library(shinydashboard)

setwd("~/project_repo/R/TDEE/")
source("./tdee_app_functions.R")

header <- dashboardHeader(disable=TRUE)

sidebar <- dashboardSidebar(
  sidebarMenu(
    menuItem("About",tabName = "about",icon=icon("question",lib="font-awesome")),
    menuItem("Daily Calories Calculation", tabName ="cals", icon=icon("table")),
    menuItem("Macros Calculation", tabName="macros",icon=icon("calculator",lib="font-awesome")),
    menuItem("Source code", icon=icon("code-fork",lib="font-awesome"),
             href='https://github.com/mariellep/project_repo/tree/master/R/TDEE')
  )
)

body <- dashboardBody(
  tabItems(
    tabItem(tabName = "about",
            h2("Calorie Calculations"),
            helpText("If the body fat percentage is provided, ",
                     "the Katch-McArdle formula is used for BMR. ",
                     "Otherwise, the Mifflin-St. Jeor formula is used for BMR."),

            h4("Katch-McArdle:"),
            helpText("370 + 21.6 * (lean body mass in kg)"),
            h4("Mifflin-St. Jeor: "),
            helpText("Men: 10*(weight in kg) + 6.25*(height in cm) -5*(age in years) + 5"),
            helpText("Women: 10*(weight in kg) + 6.25*(height in cm) - 5*(age in years) - 161"),
            h2("Clarification on activity level:"),            
            helpText("Sedentary: Desk job, little activity"),
            helpText("Light: 1-2 times exercise per week"),
            helpText("Moderate: 3-5 times exercise per week"),
            helpText("Heavy: 6-7 times exercise per week"),
            helpText("Very heavy: a physically demanding job or exercise more than once a day"),
            h2("Macros"),
            helpText("Proteins and carbohydrates contain 4 calories per gram.",
                     "Fat contains 9 calories per gram."),
            helpText("Grams per day=(Total daily calories*%macro)/(calories per gram)")
            ),
    tabItem(tabName = "cals",
            h2("Daily Calories Calculation"),
            fluidRow(
              box(title="Stats",background = "black",
                selectInput("weight_units","Weight Units:",
                            choices=c("Kg","Lb")),
                selectInput("height_units","Height Units:",
                            choices=c("cm","in")),
                selectInput("sex", "Select Sex:",
                            choices=c("F","M")),
                textInput("age", "Enter Age:"),
                textInput("height","Enter Height (in or cm):"),
                textInput("weight","Enter Weight (lb or kg):"),
                textInput("bf","Enter % Body Fat (optional, number from 0-100):")
              ),
              box(title="Goals",
                selectInput("active","Select Activity Level:",
                            choices=c("Sedentary","Light","Moderate",
                                      "Heavy","Very Heavy")),
                selectInput("goal","Weight Goal:",
                            choices=c("Cutting","Maintenance","Bulking")),
                textInput("weight_change","Weight change per week:","0"),
                submitButton("Calculate Daily Caloric Intake")
              ),
              box(
                tableOutput("TDEEout")
              )
            )
    ),
    tabItem(tabName = "macros",
            h2("Macros Calculation"),
            fluidRow(
              box(
                numericInput("fatpct","Percent Fat",35),
                numericInput("carbpct","Percent Carbs",40),
                numericInput("propct","Percent Protein",25),
                numericInput("cals","Daily Calories",2000)
              ),
              box(title="Macros split (in grams per day)",
                tableOutput("Macros")
              )
            )
    )
  )
)

ui<- dashboardPage(header, sidebar, body)

server <- function(input, output) {

  output$TDEEout<-renderTable({
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
    cals=calorie_count(tdee,input$goal,weight_change,input$weight_units)
    out_table=data.frame(BMR=as.integer(round(bmr)),
                         TDEE=as.integer(round(tdee)),
                         Calories=as.integer(round(cals)))
  })
  output$Macros<-renderTable({
    pro=macros("Protein",input$propct,input$cals)
    carb=macros("Carbs",input$carbpct,input$cals)
    fat=macros("Fat",input$fatpct,input$cals)
    
    out_table=data.frame(Fat=as.integer(round(fat)),
                         Carbs=as.integer(round(carb)),
                         Protein=as.integer(round(pro)))
  })
}
# Run the application 
shinyApp(ui = ui, server = server)

