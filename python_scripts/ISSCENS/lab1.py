#!/bin/python

"""Lab 1: Python
   Author: Marielle Pinheiro
   Changelog: Initial version 2015-05-27
"""

import sys

#Part 3 function to calculate sum from 1 to N
def sumNum(N):
  #check that integer is positive
  if (N<0):
    print("%d is negative. Please choose a value greater than 0."%N)
    sys.exit(1)

  L = range(1,(N+1))
  S = sum(L)
  return(S)

#Part 4 function conditional for Collatz conjecture
def collatz(N):
  #Odd numbers
  if (N%2!=0):
    X = (N*3) + 1
  else:
    X = N/2
  return(X)

#Part 4 function to loop over numbers from 1 to N and produce table
def collatzLoop(N):
  for n in range(1,(N+1)):
    nSteps = 0
    c = n
    while(c!=1):
      c = collatz(c)
      nSteps+=1
    print("%02d  | %d"%(n,nSteps))

#Part 5 function to obtain value of C and compute day 
def dayInWeek(year,month,day):
  #Check for valid year
  if (year<1400 | year>2599):
    print("This function does not work for this year.\
    Please choose a year in the range 1400-2599.")
    sys.exit(1)
  if (month<1 | month>12):
    print("Invalid month number. Please choose a month\
      between 1 and 12.")
    sys.exit(1)

  #D is merely the day value
  if (day<1 or day > 31):
    print("Invalid day value. Please choose a day in the \
      range 1-31.")
    sys.exit(1)

  D = day

  #Find Y and C
  strYear = str(year)
  strYearCheck = strYear[0:2]
  Y = int(strYear[3:])
  C = 0
  #Change C based on year number
  if (strYearCheck=='14' or strYearCheck=='18' or strYearCheck=='22'):
    C = 2
  elif (strYearCheck=='15' or strYearCheck=='19' or strYearCheck =='23'):
    C = 0
  elif (strYearCheck=='16' or strYearCheck=='20' or strYearCheck =='24'):
    C = 5
  elif (strYearCheck=='17' or strYearCheck=='21' or strYearCheck =='25'):
    C = 4
  else:
    print("Error. Invalid year.")
    sys.exit(1)

  #Find M
  monthList = [0,3,3,6,1,4,6,2,5,0,3,5]
  M = monthList[month-1]

  #Calculating L
  #Integer divide the last two digits of the year by 4
  #number of "ordinary" leap years
  L = Y//4
  #Remainder of last two digits and 4
  rem = Y%4
  #Is century divisible by 400?
  divCent = year%400
  if (divCent==0):
    print("Adding 1 to L.")
    L+=1
  elif (rem==0):
    print("Adding 1 to L.")
    L+=1
   

  if (divCent==0 and rem==0):
    print("Subtracting duplicate.")
    L-=1
 
  W = (C+Y+L+M+D)%7
  dayName = ["Monday","Tuesday","Wednesday","Thursday","Friday","Saturday","Sunday"]
  return(W)




#A function to convert from base 10 to other bases
def base10Change(N,base):
  rem = N%base
  div = N//base
  digits = [rem]
  while (div!=0):
    rem = div%base
    div = div//base
    digits+=[rem]
  #if remainder is greater than 9, use a letter placeholder
#  letterRem = ['A','B','C','D','E','F','G','H','I','J','K','L']
  result = str(digits[-1])
  for i in range((len(digits)-2),-1,-1):
    if (digits[i]>9):
      result+= chr(55+digits[i])
    else:
      result+= str(digits[i])   
  return(result)


##################################################################

#Project 3: Part A
#Sum of numbers from 1 to N

inputVal = [1,25,1000]

for num in inputVal:
  sum1 = sumNum(num)
  sum2 = (num*(num+1))/2
  print("The first sum is %d, and the second sum is %d."%(sum1,sum2))

#Project 3: Part B
#Print a table of the sums of the first 25 numbers

print("Int | Sum")
for i in range(1,26):
  tableSum = sumNum(i)
  print("%02d  | %02d"%(i,tableSum))

#Project 4: Collatz conjecture
N = [30,50]

for n in N:
  print("Int | nSteps")
  collatzLoop(n)

#Project 5: Compute day of the week
#  n = dayInWeek(2000,2,29)

#Project 6: Base 10 to other
for i in range(0,51):
  conv = base10Change(i,16)
  print("%d in base 16 is %s."%(i,conv))
