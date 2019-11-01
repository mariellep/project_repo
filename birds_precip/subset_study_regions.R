#These are mandatory for the plotting!
library(ggplot2)
library(reshape2)

#This function subsets data from the given dataframe based on the
##lat/lon boundaries specified. Note that the month and year range
##are already specified
read_data<-function(df,minlat,maxlat,minlon,maxlon,
                         minyear=2015,maxyear=2019,
                         minmonth=3,maxmonth=8){
  df$DATE<-as.Date(df$DATE)
  df$YEAR<-as.numeric(format(df$DATE,"%Y"))
  df$MONTH<-as.numeric(format(df$DATE,"%m"))
  df_subset<-df[(df$LATITUDE>=minlat) & (df$LATITUDE<=maxlat) &
                  (df$LONGITUDE>=minlon) & (df$LONGITUDE<=maxlon) &
                  (df$YEAR>=minyear) & (df$YEAR<=maxyear) &
                  (df$MONTH>=minmonth) & (df$MONTH<=maxmonth),]
  return(df_subset)
}

#This function takes the processed dataframe from the previous step and outputs a plot
plot_timeseries<-function(df,figtitle){
  df_data<-df[,c("DATE","YEAR","LATITUDE","LONGITUDE","PRCP","TMAX","TMIN")]
  df_long<-melt(df_data,id.vars=c("DATE","YEAR","LATITUDE","LONGITUDE"))
  df_long$variable<-factor(df_long$variable)
  
  g=ggplot(data=df_long,aes(x=DATE,y=value,group=YEAR))+
    facet_grid(rows=vars(df_long$variable),scales='free_y',
               labeller = as_labeller(c(PRCP='Precip (in)',
                                        TMAX = "Max temp (F)", 
                                        TMIN = "Min temp (F)") ))+
    geom_point(aes(color=variable),alpha=0.3,size=1,na.rm=TRUE)+
    stat_summary(fun.y='mean',geom='line',color='black',na.rm=TRUE)+
    scale_x_date(breaks = function(x) seq.Date(from = as.Date('2015-01-01'), to = max(x), by = "3 month"))+
    ylab(NULL)+
    xlab("Date")+
    theme(legend.position = "none",
          axis.text.x = element_text(angle = 45, hjust = 1),
          axis.text=element_text(size=rel(1.2)),
          strip.text=element_text(size=rel(1.3))) 
  aspect_ratio <- 2.5
  ggsave(figtitle, height = 7 , width = 7 * aspect_ratio,device=png())
}



#As an example, read in the Napa csv
napa_files<-read.csv('napa_county_1990_2019.csv')
#Set the lat/lon boundaries
napa_study_region<-read_data(napa_files,38,39,-123,-121)
#if you wanted to look at more years, you could specify a different minyear
napa_extended<-read_data(napa_files,38,39,-123,-121,minyear=1995)
#Now we plot the data!
plot_timeseries(napa_study_region,"napa.png")
