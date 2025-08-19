library(tidyverse) 
library(here)
library(dbplyr)
library(stringr)


cleaning <- function(df, na_option = "drop", column_type, column_name, trim = FALSE){
  
  #drops the repeat rows
  df <- distinct(df, .data[[column_name]], .keep_all = TRUE)
  
  #performs the desired handling option for na/empty rows
  if (tolower(na_option) == "fill"){
    
    if(toupper(column_type) == "DATE"){
    
    #temp variable holding the column without the NA values
    temp <- df[[column_name]][!is.na(df[[column_name]])]
    
    #takes the mean value for the date from the data, then it will replace them will the average
    df[[column_name]][is.na(df[column_name])] <- as.Date(mean(as.numeric(temp)), origin = "1970-01-01")
  
  } else if(toupper(column_type) == "NUM"){
      
      #temp variable holding the column without the NA values
      temp <- df[[column_name]][!is.na(df[[column_name]])]
      
      df[[column_name]][is.na(df[[column_name]])] <- mean(as.numeric(temp), na.rm = TRUE)
      
  } else{
      stop("the column_name given is not an accepted option, try 'DATE' or 'NUM'.")
    }
  } 
  else if(tolower(na_option) == "drop"){
    df <- drop_na(df, {{ column_name }})
  }
  else{
    stop("provide an na_option that is drop or fill")
  }
  if (trim == TRUE & (column_type == "AGE" | column_type == "DATE")){
    df[[column_name]] <- str_remove_all(df[[column_name]], " ")
    }
  
  return(df)
}

checks <- function(DOB,
                   Admis_dt = 0, Age = "0"
){
  
  if(type == "Date"){
    max_age = 130
    min_age = 0
    
    if(is.date(Admiss_date) != TRUE & Admis_dt != 0){
      stop("the admission date returned non dates")
    }
    else if((Age <= min_age | Age >= max_age) & Age != "0"){
      stop("Age showed values outside of accepted range")
    }
    else if(Admis_dt < DOB){
      stop("the admission date is earlier than the date of birth, this isn't possible")
    }
    }
  
}
