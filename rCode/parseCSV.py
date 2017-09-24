import csv
import sys
import pandas as pd
import glob, os
import matplotlib.pyplot as plt
from time import sleep
import json
from itertools import cycle, islice
import operator
import numpy as np
from pylab import *

from pylab import *



filePath = '/Users/jmiller/Projects/dataMining/projectOne/rCode/newCleanData'
#fileName = '/Users/jmiller/Projects/dataMining/projectOne/rCode/cleanData2002_PURE.csv'
# df = pd.read_csv(fileName, dtype={"PseudoID": int, "Date": int, "Age": int}, nrows=1500000)
# saved_column = df[['PseudoID','Date','Age']]

nameKeys = {
'20010331': '01',
'20010630': '01',
'20010930': '01',
'20011213': '01',

'20020331': '02',
'20020630': '02',
'20020930': '02',
'20021213': '02',

'20030331': '03',
'20030630': '03',
'20030930': '03',
'20031213': '03',

'20040331': '04',
'20040630': '04',
'20040930': '04',
'20041213': '04',

'20050331': '05',
'20050630': '05',
'20050930': '05',
'20051213': '05',

'20060331': '06',
'20060630': '06',
'20060930': '06',
'20061213': '06',

'20070331': '07',
'20070630': '07',
'20070930': '07',
'20071213': '07',

'20080331': '08',
'20080630': '08',
'20080930': '08',
'20081213': '08',

'20090331': '09',
'20090630': '09',
'20090930': '09',
'20091213': '09',

'20100331': '10',
'20100630': '10',
'20100930': '10',
'20101213': '10',

'20110331': '11',
'20110630': '11',
'20110930': '11',
'20111213': '11',

'20120331': '12',
'20120630': '12',
'20120930': '12',
'20121213': '12',

'20130331': '13',
'20130630': '13',
'20130930': '13',
'20131213': '13',

'20140331': '14',
'20140630': '14',
'20140930': '14',
'20141213': '14'

}

quarterList = [

                 '05',
                 '05',
                 '05',
                 '05',

                 '06',
                 '06',
                 '06',
                 '06',

                 '07',
                 '07',
                 '07',
                 '07',

                 '08',
                 '08',
                 '08',
                 '08',

                '09',
                 '09',
                 '09',
                 '09',

                 '10',
             '10',
                 '10',
                '10',

                 '11',
                 '11',
                 '11',
                 '11',

                 '12',
                 '12',
                '12',
                '12'
]


ageDict = {}
payDict = {}
ageVsPayDict = {}
agencyCount = {}
count = 15
for x in range(0,13):
    ageVsPayDict[str(count)] = []
    count += 5
print(ageVsPayDict)
agencyDict = {}
educationDict = {}
os.chdir(filePath)
count = 0
bushList = []
obamaList = []
borderDict = {}
salaryList = []
month = ['Q1','Q2,','Q3','Q4']
year = ['2005','2006','2007','2008','2009','2010','2011','2012']
fullTimeList = []
partTimeList = []
numberOfQuarters = list(range(32))
testTick = ['Q1','Q2','Q3','Q4']
test = list(range(4))
x = 0
y = 0
ughList = []
for file in glob.glob("*.csv"):
    print(str((count/len(glob.glob("*.csv")))*100) + "% complete")
    count += 1
    # print (file[15:19])
    # #testDf = pd.DataFrame.from_csv(file)
    # tempDf = pd.DataFrame.from_csv(file)
    # tempDf['Pay']=tempDf.Pay.mask(tempDf.Pay == 0,tempDf['Pay'].median())
    #
    # if int(file[15:19]) > 2008:
    #     obamaList.append(tempDf)
    # else:
    #     bushList.append(tempDf)


    df = pd.read_csv(file, dtype={"PseudoID": int, "Date": int, "Age": int, "Pay": int, "EducationName": str, "AgencyName": str})
    saved_column = df[['PseudoID','Date','Age', 'Pay', 'EducationName', 'AgencyName','NSFTPTrans']]
#
#     # Parse throgh DataFrames to match up Salaries, Ages, and other variables as necessary
#     for x in range(len(saved_column['PseudoID'])):
#         # Determine dict keys
#         ageKey = nameKeys[str(saved_column['Date'][x])]
#         payKey = str(saved_column['Age'][x])
#         agencyKey = str(saved_column['AgencyName'][x])
#         # Add to dictionary using Date aas the key
#         if ageKey in ageDict:
#             ageDict[ageKey].append(saved_column['Age'][x])
#             payDict[ageKey].append(saved_column['Pay'][x])
#         else:
#             ageDict[ageKey] = []
#             ageDict[ageKey].append(saved_column['Age'][x])
#             payDict[ageKey] = []
#             payDict[ageKey].append(saved_column['Pay'][x])
#         ageVsPayDict[str(payKey)].append(saved_column['Pay'][x])
#
#
#
# # Convert dict to DataFrame
# dfOfAge = pd.DataFrame(dict([(k,pd.Series(v)) for k,v in ageDict.items()]))
# dfOfPay = pd.DataFrame(dict([(k,pd.Series(v)) for k,v in payDict.items()]))
# dfOfAgeVsPay = pd.DataFrame(dict([(k,pd.Series(v)) for k,v in ageVsPayDict.items()]))
#
# # Fine means
# meanDf = pd.DataFrame.mean(dfOfAge)
# meanPayDf = pd.DataFrame.mean(dfOfPay)
# meanAgeVsPay = pd.DataFrame.mean(dfOfAgeVsPay)
#
# # Set up plots for all relationships
# payBox = dfOfPay.boxplot()
# payBox.set_xlabel("Year")
# payBox.set_ylabel("Salary")
# plt.title('Salary Boxplot')
#
# plt.figure()
#
# # Look at trend of Age vs Pay (scatter plot)
# ageVsPayPlot = meanAgeVsPay.plot(title="Age vs Pay")
# ageVsPayPlot.set_xlabel("Average Age")
# ageVsPayPlot.set_ylabel("Average Pay")
#
# plt.figure()
#
# # Look at Age vs Pay Box Plot
#
# # Trend of age over time
# agePlot = meanDf.plot(title='Average Age of Employee by Quarter')
# agePlot.set_xlabel("Quarter and Year")
# agePlot.set_ylabel("Average Age")
#
# plt.figure()
#
# # Tren of pay over time
# payPlot = meanPayDf.plot(title='Average Pay of Employee by Quarter')
# payPlot.set_xlabel("Quarter and Year")
# payPlot.set_ylabel("Average Pay")
#
# plt.figure()
# plt.show()




    print('reading throagePlot one')
    print('travs')
    print((df.AgencyName == 'CUSTOMS AND BORDER PROTECTION').sum())
    borderDict[year[y] + '/' + month[x]] = (df.AgencyName == 'CUSTOMS AND BORDER PROTECTION').sum()
    ughList.append((df.AgencyName == 'CUSTOMS AND BORDER PROTECTION').sum())
    fullTimeList.append((df.NSFTPTrans == 'Non-Seasonal, FUll-Time, Permanent Employees').sum())
    partTimeList.append((df.NSFTPTrans == 'Not Non-Seasonal, Full-Time, Permanent Employees').sum())
    if x == 3:
        x = 0
        y += 1
    else:
        x += 1
    #salaryList.append(tempDf['Pay'].mean())


# Create line chart over time showing fluctuations in Customs employees
# x = np.array(numberOfQuarters)
# my_xticks = quarterList
# plt.xticks(x, my_xticks)
# plt.plot(x,ughList)
# plt.title("Average Salary over Time Against Inflation")
# plt.xlabel('Year')
# plt.ylabel('Average Salary')
# plt.grid(True)
# plt.show()
#
# plt.figure()

# Create line chart comparing # of employees Part-Time and Full-Time
x = np.array(numberOfQuarters)
my_xticks = quarterList
plt.xticks(x, my_xticks)
plt.plot(x,fullTimeList)
plt.plot(x,partTimeList)
plt.title("Comparing Full-Time and Part-Time Employment")
plt.xlabel('Year')
plt.ylabel('# of Employees')
plt.grid(True)
plt.show()

sys.exit()

inflationList = []
startSalary = 67641
for x in range(32):
    inflationList.append(startSalary)
    startSalary += 371
x = np.array(numberOfQuarters)
my_xticks = quarterList
plt.xticks(x, my_xticks)
plt.plot(x,salaryList)
plt.plot(x,inflationList)
plt.title("Average Salary over Time Against Inflation")
plt.xlabel('Year')
plt.ylabel('Average Salary')
plt.grid(True)
plt.show()



bushCombinedDf = pd.concat(bushList)

# bushStateDict = bushCombinedDf['States'].value_counts().to_dict()
# topStates = dict(sorted(bushStateDict.items(), key=operator.itemgetter(1), reverse=True)[:5])
# bushStateDf = pd.DataFrame(dict([(k,pd.Series(v)) for k,v in topStates.items()]))
# bushStatesPlot = bushStateDf.plot(kind="bar", title="State where Employees Worked under Bush")
# bushStatesPlot.set_xlabel("State")
# bushStatesPlot.set_ylabel("# of Employees")

plt.figure()

# # Get count of all different variables and only shopw the top 10 for Bush
# bushSummary = pd.DataFrame.describe(bushCombinedDf)
# bushNsftpCount = bushCombinedDf[['NSFTPTrans']].apply(pd.value_counts).head(10)
# bushpayPlanCount = bushCombinedDf[['PayPlanTrans']].apply(pd.value_counts).head(10)
# bushpayScheduleCount = bushCombinedDf[['ScheduleTrans']].apply(pd.value_counts).head(10)
# bushpayStatesCount = bushCombinedDf[['States']].apply(pd.value_counts).head(10)
# bushpayApptCount = bushCombinedDf[['ApptTrans']].apply(pd.value_counts).head(10)
# bushpayOccCount = bushCombinedDf[['OccTrans']].apply(pd.value_counts).head(10)
# bushAgencyCount = bushCombinedDf[['AgencyName']].apply(pd.value_counts).head(10)
# bushEducationCount = bushCombinedDf[['EducationName']].apply(pd.value_counts).head(10)
# bushLOSCount = bushCombinedDf[['LOS']].apply(pd.value_counts).head(10)
#
# # Get most frequently lived in states by employees
# obamaCombinedDf = pd.concat(obamaList)
# # obamaStateDict = obamaCombinedDf['States'].value_counts().to_dict()
# # obamaTopStates = dict(sorted(obamaStateDict.items(), key=operator.itemgetter(1), reverse=True)[:5])
# # obamaStateDf = pd.DataFrame(dict([(k,pd.Series(v)) for k,v in obamaTopStates.items()]))
# # obamaStatesPlot = obamaStateDf.plot(kind="bar", title="State where Employees Worked under Obama")
# # obamaStatesPlot.set_xlabel("State")
# # obamaStatesPlot.set_ylabel("# of Employees")
#
# # plt.figure()
# #
# # plt.show()
#
# # Get count of all different variables and only shopw the top 10 for Obama
# obamaSummary = pd.DataFrame.describe(obamaCombinedDf)
# obamaNsftpCount = obamaCombinedDf[['NSFTPTrans']].apply(pd.value_counts).head(10)
# obamapayPlanCount = obamaCombinedDf[['PayPlanTrans']].apply(pd.value_counts).head(10)
# obamapayScheduleCount = obamaCombinedDf[['ScheduleTrans']].apply(pd.value_counts).head(10)
# obamapayStatesCount = obamaCombinedDf[['States']].apply(pd.value_counts).head(10)
# obamapayApptCount = obamaCombinedDf[['ApptTrans']].apply(pd.value_counts).head(10)
# obamapayOccCount = obamaCombinedDf[['OccTrans']].apply(pd.value_counts).head(10)
# obamaAgencyCount = obamaCombinedDf[['AgencyName']].apply(pd.value_counts).head(10)
# obamaEducationCount = obamaCombinedDf[['EducationName']].apply(pd.value_counts).head(10)
# obamaLOSCount = obamaCombinedDf[['LOS']].apply(pd.value_counts).head(10)
#
# # Write to a text file the values for easy graphing. Was having issues creating a double bar graph, so Excel was my best option.
# file = open("/Users/jmiller/Projects/dataMining/projectOne/rCode/testfile.txt","w")
#
# file.write("Bush Agency Count\n")
# file.write(str(bushAgencyCount))
# file.write("Obama Agency Count\n")
# file.write(str(obamaAgencyCount))
# file.write("Bush NSFTP Count\n")
# file.write(str(bushNsftpCount))
# file.write("Obama NSFTP Count\n")
# file.write(str(obamaNsftpCount))
# file.write("Bush PayPlan Count\n")
# file.write(str(bushpayPlanCount))
# file.write("Obama PayPlan Count\n")
# file.write(str(obamapayPlanCount))
# file.write("Bush Schedule Count\n")
# file.write(str(bushpayScheduleCount))
# file.write("Obama Schedule Count\n")
# file.write(str(obamapayScheduleCount))
# file.write("Bush States Count\n")
# file.write(str(bushpayStatesCount))
# file.write("Obama States Count\n")
# file.write(str(obamapayStatesCount))
# file.write("Bush Appt Count\n")
# file.write(str(bushpayApptCount))
# file.write("Obama Appt Count\n")
# file.write(str(obamapayApptCount))
# file.write("Bush Occ Count\n")
# file.write(str(bushpayOccCount))
# file.write("Obama Occ Count\n")
# file.write(str(obamapayOccCount))
# file.write("Bush LOS Count\n")
# file.write(str(bushLOSCount))
# file.write("Obama LOS Count\n")
# file.write(str(obamaLOSCount))
#
# file.write("Bush Education Count\n")
# file.write(str(bushEducationCount))
# file.write("Obama Education Count\n")
# file.write(str(obamaEducationCount))
#
# file.write("Bush Summary\n")
# file.write(str(bushSummary))
# file.write("Age Median under Bush\n")
# file.write(str(bushCombinedDf[['Age']].median()))
# file.write("Age Mode under Bush\n")
# file.write(str(bushCombinedDf[['Age']].mode()))
# file.write("Salary Median under Bush\n")
# file.write(str(bushCombinedDf[['Pay']].median()))
# file.write("Salary Mode under Bush\n")
# file.write(str(bushCombinedDf[['Pay']].mode()))
#
# file.write("Obama Summary\n")
# file.write(str(obamaSummary))
# file.write("Age Median under Obama\n")
# file.write(str(obamaCombinedDf[['Age']].median()))
# file.write("Age Mode under Obama\n")
# file.write(str(obamaCombinedDf[['Age']].mode()))
# file.write("Salary Median under Obama\n")
# file.write(str(obamaCombinedDf[['Pay']].median()))
# file.write("Salary Mode under Obama\n")
# file.write(str(obamaCombinedDf[['Pay']].mode()))
#
# file.close()

    # df = pd.read_csv(file, dtype={"PseudoID": int, "Date": int, "Age": int, "Pay": int, "EducationName": str, "AgencyName": str})
    # saved_column = df[['PseudoID','Date','Age', 'Pay', 'EducationName', 'AgencyName']]
    #
    # len(saved_column['Date'])
    # #print('reading throagePlot one')
    # for x in range(len(saved_column['PseudoID'])):
    #
    #     ageKey = nameKeys[str(saved_column['Date'][x])]
    #     payKey = str(saved_column['Age'][x])
    #     agencyKey = str(saved_column['AgencyName'][x])
        # if ageKey in ageDict:
        #     ageDict[ageKey].append(saved_column['Age'][x])
        #     payDict[ageKey].append(saved_column['Pay'][x])
        #     # print(saved_column['Pay'][x])
        # else:
        #     ageDict[ageKey] = []
        #     ageDict[ageKey].append(saved_column['Age'][x])
        #     payDict[ageKey] = []
        #     payDict[ageKey].append(saved_column['Pay'][x])
        # ageVsPayDict[str(payKey)].append(saved_column['Pay'][x])


        # Create data file containing organization names
#         if agencyKey in agencyCount:
#             if ageKey in agencyCount[agencyKey]:
#                 agencyCount[agencyKey][ageKey] += 1
#             else:
#                 agencyCount[agencyKey][ageKey] = 1
#         else:
#             agencyCount[agencyKey] = {}
#             agencyCount[agencyKey][ageKey] = 1
#
# with open('/Users/jmiller/Projects/dataMining/projectOne/rCode/test.txt', 'w') as file:
#      file.write(json.dumps(agencyCount))
# print(agencyCount)


# dfOfAge = pd.DataFrame(dict([(k,pd.Series(v)) for k,v in ageDict.items()]))
# dfOfPay = pd.DataFrame(dict([(k,pd.Series(v)) for k,v in payDict.items()]))
# dfOfAgeVsPay = pd.DataFrame(dict([(k,pd.Series(v)) for k,v in ageVsPayDict.items()]))
# dfOfAdminConf = pd.DataFrame(dict([(k,pd.Series(v)) for k,v in agencyCount['nan'].items()]))
# print(dfOfAdminConf)
#
# meanDf = pd.DataFrame.mean(dfOfAge)
# meanPayDf = pd.DataFrame.mean(dfOfPay)
# meanAgeVsPay = pd.DataFrame.mean(dfOfAgeVsPay)

# Look at trend of Age vs Pay (scatter plot)
# ageVsPayPlot = meanAgeVsPay.plot(title="Age vs Pay")
# ageVsPayPlot.set_xlabel("Average Age")
# ageVsPayPlot.set_ylabel("Average Pay")

# Look at Age vs Pay Box Plot

# Trend of age over time
#agePlot = meanDf.plot(title='Average Age of Employee by Quarter')
#agePlot.set_xlabel("Quarter and Year")
#agePlot.set_ylabel("Average Age")

#ageBox = dfOfAge.boxplot()


# adminPlot = dfOfAdminConf.plot()
# plt.show()

# Tren of pay over time
# payPlot = meanPayDf.plot(title='Average Pay of Employee by Quarter')
# payPlot.set_xlabel("Quarter and Year")
# payPlot.set_ylabel("Average Pay")
# plt.show()

#print(pd.DataFrame.describe(dfOfAge))
