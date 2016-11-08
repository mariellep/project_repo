#Functions for the web app
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
  correct_weight=convert_units(weight_val,weight_unit,"Kg")
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
calorie_count<-function(tdee,weight_goal,weight_change,weight_unit="Kg"){
  if(weight_change==""){
    weight_change=0
  }
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

#Macro calculation
macros<-function(macro,pct,cals){
  cpg=ifelse(macro=="Fat",9,4)
  pct_dec=pct/100
  return(cals*pct_dec/cpg)
}