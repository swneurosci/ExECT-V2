# Validation of ExECT output on GS 200 synthetic letters  

#For all outputs analysed  here prefix/suffix GS refers to Gold Standard, prefix/suffix Ex refers to ExECT


# validation using synthetic-letter based gold standard for selected  annotation types 


library(readr)
library(dplyr)
# library(zoo) #for dates = but experimented here with origin
library(lubridate)
library(readxl)


options(scipen = 999) #numbers should not be displayed in scientific notation
options(digits = 6) #Number of digits to be displayed

setwd("C:/Users/Beata/Documents/SyntheticLetters/ForBFS/ExECTValidationGS_corrected/")# set working dir

# 1 Patient history (PH) ---- 


PHEx <- read_csv("PH_ExECT.csv", na = c("","NA","null", "NULL"), col_names = FALSE)
# Adding col_names - previously used header but this may add a space in front of each value, not sure if this is to do with the way CSV was saved
colnames(PHEx) <- c("Letter","Start","End","CUI","PREF", "TimePeriod", "NumberOfTimePeriods",
                  "LowerNumberOfTimePeriods","UpperNumberOfTimePeriods",
                  "YearDate","MonthDate","DayDate","PointInTime","Age","AgeLower","AgeUpper","AgeUnit",
                  "Certainty","Negation","Experiencer","Rule" )


PHEx <- PHEx %>% 
  select(Letter,Start,End,CUI,TimePeriod, NumberOfTimePeriods,
         LowerNumberOfTimePeriods,UpperNumberOfTimePeriods,
         YearDate,MonthDate,DayDate,PointInTime,Age,AgeLower,AgeUpper,AgeUnit,
         Certainty,Negation)


#View(PHEx)


PHGS <- read_csv("MarkupPatientHistory.csv",na = c("","NA","null", "NULL"), col_names = FALSE )

colnames(PHGS) <- c("Letter","Start","End","CUI","PREF", "PHRASE", "TimePeriod", "NumberOfTimePeriods",
                    "LowerNumberOfTimePeriods","UpperNumberOfTimePeriods",
                    "YearDate","MonthDate","DayDate","PointInTime","Age","AgeLower","AgeUpper","AgeUnit",
                    "Certainty","Negation")

PHGS<- PHGS %>% 
  select(- PHRASE, - PREF)

#View(PHGS)

# testing the method - comparing the results with GATE for all Patient History annotations 

# trying out this https://dplyr.tidyverse.org/reference/join_by.html  and it seems to be working for overlapping
# annotations


PHEx$MonthDate <- as.numeric(PHEx$MonthDate)


by <- join_by(Letter, CUI, TimePeriod, NumberOfTimePeriods,
              LowerNumberOfTimePeriods,UpperNumberOfTimePeriods,
              YearDate,MonthDate,DayDate,PointInTime,Age,AgeLower,AgeUpper,AgeUnit,
              Certainty,Negation, overlaps(x$Start, x$End, y$Start, y$End)) 


TP <- inner_join(PHEx, PHGS, by) %>% 
  count()

View(TP)

# In GATE PH gives  486TP  (matches and Overlaps) here we get 481- 
# Not sure why as the same features were selected - missing values in GATE are not seen as errors whereas in R they are


FP <- anti_join(PHEx, PHGS, by) %>% 
  count() # 97, GATE produced 88

View(FP)

FN <- anti_join(PHGS, PHEx, by) %>% 
  count() # 175 and in GATE 170

View(FN)


# Precision, recall, F score for Patient History per-item result

prec <- (TP/(TP+FP))
View(prec) # 0.83218

recall <- (TP/(TP+FN))
View(recall) # 	0.733232

F1 <- 2*((prec*recall)/(prec+recall))
View(F1) # 0.779579

# Per letter scores - at least one correct annotation for specific CUI with features


PHExLetter <- PHEx %>% 
  select(Letter, CUI, Negation) %>% 
  distinct()
View(PHExLetter)

PHGSLetter <- PHGS %>% 
  select(Letter, CUI, Negation) %>% 
  distinct()


by <- join_by(Letter, CUI, Negation)

TP <- inner_join(PHExLetter,PHGSLetter,by) %>% 
  count()


FP <- anti_join(PHExLetter,PHGSLetter,by) %>% 
  count()

#View(FP)

FN <- anti_join(PHGSLetter, PHExLetter, by) %>% 
  count()


prec <- (TP/(TP+FP))
View(prec) # 	0.930233

recall <- (TP/(TP+FN))
View(recall) # 0.85287

F1 <- 2*((prec*recall)/(prec+recall))
View(F1) # 0.889878


# generic and non-specific seizures - per item

# filtering for seizures (C0036572), myoclonus (C0027066), vacant episodes (C0563606), C3203523 cluster of seizures
# there appears to be a space in front of CUI it isn't in the Groovy script ... 

SeizuresPHEx <- PHEx %>% 
  filter(CUI == 'C0036572'| CUI == "C0027066" | CUI == "C0563606" | CUI == "C3203523" ) %>% 
  filter(Certainty >= 4) %>% 
  select(Letter, Start, End, CUI) %>% 
  distinct

View(SeizuresPHEx)


SeizurePHGS <- PHGS %>% 
  filter(CUI == "C0036572" | CUI == "C0027066" | CUI == "C0563606" | CUI == "C3203523" ) %>%  
filter(Certainty >= 4) %>% 
select(Letter, Start, End, CUI ) %>% 
  distinct
View(SeizurePHGS)



by <- join_by(Letter, CUI, overlaps(x$Start, x$End, y$Start, y$End))

TP <- inner_join(SeizuresPHEx, SeizurePHGS, by) %>% 
  count()
  
View(TP)

FP <- anti_join(SeizuresPHEx, SeizurePHGS,by) %>% 
  count()

View(FP)

FN <- anti_join(SeizurePHGS, SeizuresPHEx, by) %>% 
  count()

View(FN)

prec <- (TP/(TP+FP))
View(prec) # 0.895

recall <- (TP/(TP+FN))
View(recall) # 0.755274

F1 <- 2*((prec*recall)/(prec+recall))
View(F1) # 	0.819222

# generic and non-specific seizures - per letter

SeizuresPHEx <- PHEx %>% 
  filter(CUI == 'C0036572'| CUI == "C0027066" | CUI == "C0563606" | CUI == "C3203523" ) %>% 
  filter(Certainty >= 4) %>% 
  select(Letter) %>% 
  distinct

View(SeizuresPHEx)


SeizurePHGS <- PHGS %>% 
  filter(CUI == "C0036572" | CUI == "C0027066" | CUI == "C0563606" | CUI == "C3203523" ) %>%  
  filter(Certainty >= 4) %>% 
  select(Letter) %>% 
  distinct
View(SeizurePHGS)


by <- join_by(Letter)

TP <- inner_join(SeizuresPHEx, SeizurePHGS, by) %>% 
  count()

View(TP)

FP <- anti_join(SeizuresPHEx, SeizurePHGS,by) %>% 
  count()

View(FP)

FN <- anti_join(SeizurePHGS, SeizuresPHEx, by) %>% 
  count()

View(FN)

prec <- (TP/(TP+FP))
View(prec) # 	0.944444

recall <- (TP/(TP+FN))
View(recall) # 	0.83606

F1 <- 2*((prec*recall)/(prec+recall))
View(F1) # 	0.886957



# comorbidities: all statements of comorbidities excluding generic seizures but including febrile seizures (CUI == 'C0009952'| CUI == 'C0751057' | CUI == 'C0149886' ) which are done separately
# for per letter scores just add distinct
ComorbPHEx <- PHEx %>% 
  filter(CUI != 'C0036572'| CUI != "C0027066" | CUI != "C0563606" | CUI != "C3203523" ) %>% 
  #filter(Certainty >= 4) %>%  # As we are including febrile seizures which may heve a negation and certainty of 1 this has to be switched off
  select(Letter, CUI, Negation) %>%  #for per item add Start, End to the selection
  distinct

View(ComorbPHEx)


ComorbPHGS <- PHGS %>% 
  filter(CUI != 'C0036572'| CUI != "C0027066"| CUI != "C0563606" | CUI != "C3203523" ) %>%  
  #filter(Certainty >= 4) %>%   # As we are including febrile seizures which may heve a negation and certainty of 1 this has to be switched off
  select(Letter, CUI, Negation) %>% #for per item add Start, End to the selection
  distinct
View(ComorbPHGS)

#by <- join_by(Letter, CUI,Negation,  overlaps(x$Start, x$End, y$Start, y$End))

by <- join_by(Letter, CUI, Negation)


TP <- inner_join(ComorbPHEx, ComorbPHGS, by) %>% 
  count()

View(TP)

FP <- anti_join(ComorbPHEx, ComorbPHGS, by) %>% 
  count()

View(FP)

FN <- anti_join(ComorbPHGS, ComorbPHEx, by) %>% 
  count()

View(FN)

prec <- (TP/(TP+FP))
View(prec) # 0.917241 per item, and per letter 0.93023

recall <- (TP/(TP+FN))
View(recall) # 0.80484 per item, and per letter 0.85287

F1 <- 2*((prec*recall)/(prec+recall))
View(F1) # 0.85737 per item, and per	0.889878


# if we need to look for other main comorbidities here are the CUIs

#  NON-epileptic  seizures (dissociative seizures_ CUI == "C3495874"| CUI == "C1142430" 

# Brain tumours
# filter(CUI == "C0017639"| CUI == "C2026258" | CUI == "C0006118" | CUI == "C0349604"| CUI == "C0010280" | CUI == "C0018552" | CUI == "C0750935" | CUI == "C3695127" | CUI == "C1096492" | CUI == "C3695127" | CUI == "C1096493" )

#migraines    CUI == "C0149931" | CUI == "C0151293" 



# 2 Diagnosis (Diag)----


DiagEx <- read_csv("Diag_ExECT.csv", na = c("","NA","null", "NULL"), col_names = FALSE)


colnames(DiagEx) <- c("Letter","Start","End","CUI","PREF","Negation","DiagCategory", "Certainty","Rule","DoBDD","DoBMD",	"DoBYD"	,"ClinicDD","ClinicMD","ClinicYD","LetDD","LetMD","LetYD","Hosp_No","NHS_No","PostCode")

View(DiagEx)

DiagEx <- DiagEx %>% 
   select(Letter, Start, End, CUI, DiagCategory, Certainty)



DiagGS <- read_csv("MarkupDiagnosis.csv", na = c("","NA","null", "NULL"), col_names = FALSE)

colnames(DiagGS) <- c("Letter","Start","End","CUI","PREF", "Phrase" ,"Negation","DiagCategory", "Certainty")

DiagGS <- DiagGS %>% 
  select(- Phrase, - Negation, - PREF)


View(DiagGS)



by <- join_by(Letter, CUI, DiagCategory,
              Certainty, overlaps(x$Start, x$End, y$Start, y$End)) 



TP <- inner_join(DiagEx, DiagGS, by) %>% 
count()

FP <- anti_join(DiagEx, DiagGS, by) %>% 
  count()

View(FP)

FN <- anti_join(DiagGS, DiagEx, by) %>% 
  count()

View(FN)

prec <- (TP/(TP+FP))
View(prec) # 	0.85689 GATE 0.8863

recall <- (TP/(TP+FN))
View(recall) # 0.847902  GATE 0.8724

F1 <- 2*((prec*recall)/(prec+recall))
View(F1) # 0.852373 GATE 0.8793


	

# Diagnosis per letter, we can select those with epilepsy or multiple seizures and certainty level of 4-5 but the validation is still for specific epilepsy / seizure type

DiagExLetter <- DiagEx %>% 
  filter(DiagCategory != "SingleSeizure") %>% 
  filter(Certainty > 3) %>% 
  select(Letter, CUI) %>% 
  distinct()

#View(DiagExLetter)

DiagGSLetter <- DiagGS %>% 
  filter(DiagCategory != "SingleSeizure") %>% 
  filter(Certainty > 3) %>% 
select(Letter, CUI) %>% 
  distinct()

#View(DiagGSLetter)


by <- join_by(Letter, CUI) 

TP <- inner_join(DiagExLetter, DiagGSLetter, by) %>% 
  count()

FP <- anti_join(DiagExLetter, DiagGSLetter, by) %>% 
  count()

FN <- anti_join(DiagGSLetter, DiagExLetter, by) %>% 
  count()

#View(FN)

prec <- (TP/(TP+FP))
View(prec) # 0.950935

recall <- (TP/(TP+FN))
View(recall) # 	0.922902

F1 <- 2*((prec*recall)/(prec+recall))
View(F1) # 	0.936709


# For a less specific validation of whether epilepsy diagnosis was identified we can do a match without CUI which gives epilepsy per letter results

DiagExLetter <- DiagEx %>% 
  filter(DiagCategory != "SingleSeizure") %>% 
  filter(Certainty > 3) %>% 
  select(Letter) %>% 
  distinct()

#View(DiagExLetter)

DiagGSLetter <- DiagGS %>% 
  filter(DiagCategory != "SingleSeizure") %>% 
  filter(Certainty > 3) %>% 
  select(Letter) %>% 
  distinct()

#View(DiagGSLetter)


by <- join_by(Letter) 

TP <- inner_join(DiagExLetter, DiagGSLetter, by) %>% 
  count()

FP <- anti_join(DiagExLetter, DiagGSLetter, by) %>% 
  count()

FN <- anti_join(DiagGSLetter, DiagExLetter, by) %>% 
  count()



prec <- (TP/(TP+FP))
View(prec) # 0.97872

recall <- (TP/(TP+FN))
View(recall) # 	1

F1 <- 2*((prec*recall)/(prec+recall))
View(F1) # 0.989247


# 3 Birth History (BH) ----

BHEx <- read_csv("BH_ExECT.csv", na = c("","NA","null", "NULL"), col_names = FALSE)

colnames(BHEx) <- c("Letter","Start","End","CUI","PREF","Negation","Experiencer", "Certainty","Rule")

BHEx <- BHEx %>% 
  select(Letter, Start, End, CUI)

View(BHEx)

BHGS<- read_csv("MakupBirthHist.csv", na = c("","NA","null", "NULL"), col_names = FALSE)

colnames(BHGS) <- c("Letter","Start","End","CUI","PREF","Phrase","Negation","Certainty")

BHGS <- BHGS %>% 
  select(Letter, Start, End, CUI)

View(BHGS)

by <- join_by(Letter, CUI,  overlaps(x$Start, x$End, y$Start, y$End)) 

TP <- inner_join(BHEx, BHGS, by) %>% 
  count()

FP <- anti_join(BHEx, BHGS, by) %>% 
  count()

FN <- anti_join(BHGS, BHEx, by) %>% 
  count()
View(FN)

prec <- (TP/(TP+FP))
View(prec) # 1

recall <- (TP/(TP+FN))
View(recall) # 0.93617

F1 <- 2*((prec*recall)/(prec+recall))
View(F1) # 0.967033

# Per letter score based on specific CUI match

BHExLetter <- BHEx %>% 
  select(Letter, CUI) %>% 
  distinct()
#View(BHExLetter)

 BHGSLetter <- BHGS %>% 
   select(Letter, CUI) %>% 
   distinct()
# View(BHGSLetter)
 
 by <- join_by(Letter, CUI)
 
 TP <- inner_join(BHExLetter,BHGSLetter,by) %>% 
   count()
 
 
 FP <- anti_join(BHExLetter, BHGSLetter,by) %>% 
   count()
 
 FN <- anti_join(BHGSLetter, BHExLetter, by) %>% 
   count()
 View(FN)
 
 prec <- (TP/(TP+FP))
 View(prec) # 1
 
 recall <- (TP/(TP+FN))
 View(recall) # 0.95555
 
 F1 <- 2*((prec*recall)/(prec+recall))
 View(F1) # 0.977273
 
 # 4 Epilepsy Cause (EpiCause) ----
 
 EpiCauseEx <- read_csv("EpiCause_ExECT.csv", na = c("","NA","null", "NULL"), col_names = FALSE)
 
 colnames(EpiCauseEx) <- c("Letter","Start","End","CUI","PREF","Negation","Experiencer", "Certainty","Rule")
 
 EpiCauseEx <- EpiCauseEx %>% 
   select(Letter, Start, End, CUI)
 
 View(EpiCauseGS)
 
 EpiCauseGS<- read_csv("MarkupEpiCause.csv", na = c("","NA","null", "NULL"), col_names = FALSE)
 
 colnames(EpiCauseGS) <- c("Letter","Start","End","CUI","PREF","Phrase","Negation","Certainty")
 
 EpiCauseGS <- EpiCauseGS %>% 
   select(Letter, Start, End, CUI)
 
 
 
 by <- join_by(Letter, CUI,  overlaps(x$Start, x$End, y$Start, y$End)) 
 
 TP <- inner_join(EpiCauseEx, EpiCauseGS, by) %>% 
   count()
 
 FP <- anti_join(EpiCauseEx, EpiCauseGS, by) %>% 
   count()
 
 FN <- anti_join(EpiCauseGS, EpiCauseEx, by) %>% 
   count()
 View(FN)
 
 prec <- (TP/(TP+FP))
 View(prec) # 0.967742
 
 recall <- (TP/(TP+FN))
 View(recall) # 0.833333
 
 F1 <- 2*((prec*recall)/(prec+recall))
 View(F1) # 0.895522
 
 # Per letter score based on specific CUI match
 
 EpiCauseExLetter <- EpiCauseEx %>% 
   select(Letter, CUI) %>% 
   distinct()
 #View(BHExLetter)
 
 EpiCauseGSLetter <- EpiCauseGS %>% 
   select(Letter, CUI) %>% 
   distinct()
 View(BHGSLetter)
 
 by <- join_by(Letter, CUI)
 
 TP <- inner_join(EpiCauseExLetter,EpiCauseGSLetter,by) %>% 
   count()
 
 
 FP <- anti_join(EpiCauseExLetter, EpiCauseGSLetter,by) %>% 
   count()
 
 FN <- anti_join(EpiCauseGSLetter, EpiCauseExLetter, by) %>% 
   count()
 View(FN)
 
 prec <- (TP/(TP+FP))
 View(prec) # 0.965517
 
 recall <- (TP/(TP+FN))
 View(recall) # 0.875
 
 F1 <- 2*((prec*recall)/(prec+recall))
 View(F1) # 0.918033
 
 # 5 Investigations (Invest) ----
 
 InvestEx <- read_csv("Investigations_ExECT.csv", na = c("","NA","null", "NULL"), col_names = FALSE)
 colnames(InvestEx) <- c("Letter","Start","End","CUI","CT_Performed","CT_Results",
                               "MRI_Performed","MRI_Results","EEG_Performed","EEG_Type",
                               "EEG_Results" )
 
 InvestEx <- InvestEx %>% 
   select(Letter,Start,End,CUI,CT_Performed,CT_Results,
          MRI_Performed,MRI_Results,EEG_Performed,EEG_Type,
          EEG_Results)
View(InvestEx) 


InvestGS <- read_csv("MarkupInvestigations.csv", na = c("","NA","null", "NULL"), col_names = FALSE)

colnames(InvestGS) <- c("Letter","Start","End","CUI","PREF","Phrase", "CT_Performed","CT_Results",
                        "MRI_Performed","MRI_Results","EEG_Performed","EEG_Type",
                        "EEG_Results" )
View(InvestGS)

InvestGS <- InvestGS %>% 
  select(Letter,Start,End,CUI,CT_Performed,CT_Results,
         MRI_Performed,MRI_Results,EEG_Performed,EEG_Type,
         EEG_Results)

by <- join_by(Letter, CUI, overlaps(x$Start, x$End, y$Start, y$End)) 

TP <- inner_join(InvestEx, InvestGS, by) %>% 
  count()

FP <- anti_join(InvestEx, InvestGS, by) %>% 
  count()

FN <- anti_join(InvestGS, InvestEx, by) %>% 
  count()
View(FN)

prec <- (TP/(TP+FP))
View(prec) # 0.955556

recall <- (TP/(TP+FN))
View(recall) # 0.939891

F1 <- 2*((prec*recall)/(prec+recall))
View(F1) # 0.947658

# Per letter score based on specific CUI match

InvestExLetter <- InvestEx %>% 
  select(Letter, CUI) %>% 
  distinct()
#View(BHExLetter)

InvestGSLetter <- InvestGS %>% 
  select(Letter, CUI) %>% 
  distinct()


by <- join_by(Letter, CUI)

TP <- inner_join(InvestExLetter,InvestGSLetter,by) %>% 
  count()


FP <- anti_join(InvestExLetter,InvestGSLetter,by) %>% 
  count()

FN <- anti_join(InvestGSLetter, InvestExLetter, by) %>% 
  count()
#View(FN)

prec <- (TP/(TP+FP))
View(prec) # 	0.95858

recall <- (TP/(TP+FN))
View(recall) # 0.94186

F1 <- 2*((prec*recall)/(prec+recall))
View(F1) # 0.95014


# 6 Onset ----

OnsetEx <- read_csv("Onset_ExECT.csv", na = c("","NA","null", "NULL"), col_names = FALSE)
# Adding col_names - previously used header but this may add a space in front of each value, not sure if this is to do with the way CSV was saved
colnames(OnsetEx ) <- c("Letter","Start","End","CUI","PREF", "TimePeriod", "NumberOfTimePeriods",
                    "LowerNumberOfTimePeriods","UpperNumberOfTimePeriods",
                    "YearDate","MonthDate","DayDate","PointInTime","Age","AgeLower","AgeUpper","AgeUnit",
                    "Certainty","Negation","Experiencer","Rule" )

OnsetEx  <- OnsetEx  %>% 
  select(Letter,Start,End,CUI,TimePeriod, NumberOfTimePeriods,
         LowerNumberOfTimePeriods,UpperNumberOfTimePeriods,
         YearDate,MonthDate,DayDate,PointInTime,Age,AgeLower,AgeUpper,AgeUnit)


OnsetGS <- read_csv("MarkupOnset.csv",na = c("","NA","null", "NULL"), col_names = FALSE )

colnames(OnsetGS) <- c("Letter","Start","End","CUI","PREF", "PHRASE", "TimePeriod", "NumberOfTimePeriods",
                       "LowerNumberOfTimePeriods","UpperNumberOfTimePeriods",
                       "YearDate","MonthDate","DayDate","PointInTime","Age","AgeLower","AgeUpper","AgeUnit",
                       "Certainty","Negation")

OnsetGS <- OnsetGS%>% 
  select(Letter,Start,End,CUI,TimePeriod, NumberOfTimePeriods,
         LowerNumberOfTimePeriods,UpperNumberOfTimePeriods,
         YearDate,MonthDate,DayDate,PointInTime,Age,AgeLower,AgeUpper,AgeUnit)

#View(OnsetGS)
by <- join_by(Letter, CUI, overlaps(x$Start, x$End, y$Start, y$End)) 

TP <- inner_join(OnsetEx, OnsetGS, by) %>% 
  count()
View(TP)
FP <- anti_join(OnsetEx, OnsetGS, by) %>% 
  count()
View(FP)

FN <- anti_join(OnsetGS, OnsetEx, by) %>% 
  count()
View(FN)

prec <- (TP/(TP+FP))
View(prec) # 1

recall <- (TP/(TP+FN))
View(recall) # 0.923077

F1 <- 2*((prec*recall)/(prec+recall))
View(F1) # 0.96

# Per letter score based on specific CUI match

OnsetExLetter <- OnsetEx %>% 
  select(Letter, CUI) %>% 
  distinct()
#View(OnsetExLetter)

OnsetGSLetter <- OnsetGS %>% 
  select(Letter, CUI) %>% 
  distinct()


by <- join_by(Letter, CUI)

TP <- inner_join(OnsetExLetter,OnsetGSLetter,by) %>% 
  count()


FP <- anti_join(OnsetExLetter,OnsetGSLetter,by) %>% 
  count()

View(FP)

FN <- anti_join(OnsetGSLetter, OnsetExLetter, by) %>% 
  count()
#View(FN)

prec <- (TP/(TP+FP))
View(prec) # 	1

recall <- (TP/(TP+FN))
View(recall) # 0.91304

F1 <- 2*((prec*recall)/(prec+recall))
View(F1) # 	0.954545

# 7 Prescriptions (Presc) ----

PrescEx <- read_csv("Prescription_ExECT.csv", na = c("","NA","null", "NULL"), col_names = FALSE)
colnames(PrescEx) <- c("Letter","Start","End","CUI","DrugName","DrugDose","DoseUnit","Frequency","String","Rule" )
#View(PrescEx)

PrescEx <- PrescEx %>% 
  select(Letter, Start, End, CUI, DrugDose, DoseUnit, Frequency)


PrescGS <- read_csv("MarkupPrescriptions.csv", na = c("","NA","null", "NULL"), col_names = FALSE)

colnames(PrescGS) <- c("Letter","Start","End","CUI","DrugName","Phrase", "DrugDose","DoseUnit","Frequency","String")
View(PrescGS)

PrescGS <- PrescGS %>% 
  select(Letter, Start, End, CUI, DrugDose, DoseUnit, Frequency)



by <- join_by(Letter, CUI, DrugDose, DoseUnit, Frequency,
               overlaps(x$Start, x$End, y$Start, y$End)) 



TP <- inner_join(PrescEx, PrescGS, by) %>% 
  count()

FP <- anti_join(PrescEx, PrescGS, by) %>% 
  count()

View(FP)

FN <- anti_join(PrescGS, PrescEx, by) %>% 
  count()

View(FN)

prec <- (TP/(TP+FP))
View(prec) # 	0.920455  GATE gives 0.9237

recall <- (TP/(TP+FN))
View(recall) # 0.820946  GATE gives 0.8231

F1 <- 2*((prec*recall)/(prec+recall))
View(F1) # 0.867857 GATE 0.8705

# per letter - based on the complete prescription (CUI, dose, measurement, frequency) for each drug not on the full list of drugs

PrescExLetter <- PrescEx %>% 
  select(Letter, CUI,DrugDose, DoseUnit, Frequency) %>% 
  distinct()

PrescGSLetter <- PrescGS %>% 
  select(Letter, CUI,DrugDose, DoseUnit, Frequency) %>% 
  distinct()

by <- join_by(Letter, CUI, DrugDose, DoseUnit, Frequency)
    
TP <- inner_join(PrescExLetter, PrescGSLetter, by) %>% 
  count()

FP <- anti_join(PrescExLetter, PrescGSLetter, by) %>% 
  count()

#View(FP)

FN <- anti_join(PrescGSLetter, PrescExLetter, by) %>% 
  count()

#View(FN)

prec <- (TP/(TP+FP))
View(prec) # 0.918919

recall <- (TP/(TP+FN))
View(recall) # 0.82638

F1 <- 2*((prec*recall)/(prec+recall))
View(F1) # 	0.870201           

# 8 Seizure Frequency (SF) ----

SFEx <-read.csv(file = "SF_ExECT.csv", sep = ",", na = c("","NA","null", "NULL"), header = FALSE)
colnames(SFEx) <- c("Letter","Start","End","CUI","String","FreqChange",	"NofS",	"LNofS"	,"UNofS","TP",	"NofTP","LNofTP",	"UNofTP",	"Sin_Dur","YD",	"MD",	"DD",	"PinT",	
                  "Age","AgeLower",	"AgeUpper",	"AgeUnit", "Certainty",	"Negation",	"Rule")

SFEx <- SFEx %>% 
  select(Letter,Start,End ,CUI,FreqChange,	NofS,	LNofS	,UNofS,TP,	NofTP,LNofTP,	UNofTP,	Sin_Dur,YD,	MD,	DD,	PinT,	
         Age,AgeLower,	AgeUpper,	AgeUnit)

View(SFEx)

SFGS <-read.csv(file = "MarkupSeizureFrequency.csv", sep = ",", na = c("","NA","null", "NULL"), header = FALSE)
colnames(SFGS) <- c("Letter","Start","End","CUI","String", "PREF","FreqChange",	"NofS",	"LNofS"	,"UNofS","TP",	"NofTP","LNofTP",	"UNofTP",	"Sin_Dur","YD",	"MD",	"DD",	"PinT",	
                    "Age","AgeLower",	"AgeUpper",	"AgeUnit", "Certainty",	"Negation")



SFGS$CUI <- gsub(" ", "", as.character(SFGS$CUI))# for some reason there is a space in front of CUI in the Markup output. It is not in the groovy , this corrects it

SFGS <- SFGS %>% 
  select(Letter,Start,End, CUI,FreqChange,NofS,LNofS	,UNofS,TP,NofTP,LNofTP,	UNofTP,	Sin_Dur,YD,	MD,	DD,	PinT,	
         Age,AgeLower,AgeUpper,	AgeUnit)
View(SFGS)


by <- join_by(Letter, CUI, FreqChange,NofS,	LNofS,UNofS,TP,NofTP,LNofTP,UNofTP,	Sin_Dur,YD,	MD,	DD,	PinT,	
Age, AgeLower,AgeUpper,	AgeUnit,overlaps(x$Start, x$End, y$Start, y$End))

TP <- inner_join(SFEx, SFGS, by) %>% 
  count()
View(TP) # 160  Gate gives 170

FP <- anti_join(SFEx, SFGS, by) %>% 
  count()

View(FP) # 61 GATE gives 51

FN <- anti_join(SFGS, SFEx, by) %>% 
  count()

View(FN) # 103 GATE gives 93

prec <- (TP/(TP+FP))
View(prec) # 	0.723982


recall <- (TP/(TP+FN))
View(recall) # 0.608365

F1 <- 2*((prec*recall)/(prec+recall))
View(F1) # 	0.661157 

# per letter results CUI is not included is we are more interested in whether seizure frequency is picked up for any seizure type


SFExLetter <- SFEx %>% 
  select(Letter,FreqChange,	NofS,	LNofS	,UNofS,TP,	NofTP,LNofTP,	UNofTP,	Sin_Dur,YD,	MD,	DD,	PinT,	
         Age,AgeLower, AgeUpper,	AgeUnit) %>% 
  distinct()



SFGSLetter <- SFGS %>% 
  select(Letter, FreqChange,NofS,LNofS	,UNofS,TP,NofTP,LNofTP,	UNofTP,	Sin_Dur,YD,	MD,	DD,	PinT,	
         Age,AgeLower, AgeUpper,	AgeUnit) %>% 
  distinct()
View(SFGSLetter)


by <- join_by(Letter, FreqChange,NofS,	LNofS,UNofS,TP,NofTP,LNofTP,UNofTP,	Sin_Dur,YD,	MD,	DD,	PinT,	
              Age, AgeLower,AgeUpper,	AgeUnit)

TP <- inner_join(SFExLetter, SFGSLetter, by) %>% 
  count()
View(TP) # 157 

FP <- anti_join(SFExLetter, SFGSLetter, by) %>% 
  count()

View(FP) # 55

FN <- anti_join(SFGSLetter, SFExLetter, by) %>% 
  count()

View(FN) # 90

prec <- (TP/(TP+FP))
View(prec) # 0.740566


recall <- (TP/(TP+FN))
View(recall) # 0.635628

F1 <- 2*((prec*recall)/(prec+recall))
View(F1) # 	0.68409 


# 9 WhenDiagnosed (WD) ----

WDEx <- read_csv("WhenDiag_ExECT.csv", na = c("","NA","null", "NULL"), col_names = FALSE)
# Adding col_names - previously used header but this may add a space in front of each value, not sure if this is to do with the way CSV was saved
colnames(WDEx ) <- c("Letter","Start","End","CUI","PREF", "TimePeriod", "NumberOfTimePeriods",
                        "LowerNumberOfTimePeriods","UpperNumberOfTimePeriods",
                        "YearDate","MonthDate","DayDate","PointInTime","Age","AgeLower","AgeUpper","AgeUnit",
                        "Certainty","Negation","Experiencer","Rule" )

WDEx  <- WDEx  %>% 
  select(Letter,Start,End,CUI,TimePeriod, NumberOfTimePeriods,
         LowerNumberOfTimePeriods,UpperNumberOfTimePeriods,
         YearDate,MonthDate,DayDate,PointInTime,Age,AgeLower,AgeUpper,AgeUnit)


WDGS <- read_csv("MarkupWhenDiag.csv",na = c("","NA","null", "NULL"), col_names = FALSE )

colnames(WDGS) <- c("Letter","Start","End","CUI","PREF", "PHRASE", "TimePeriod", "NumberOfTimePeriods",
                       "LowerNumberOfTimePeriods","UpperNumberOfTimePeriods",
                       "YearDate","MonthDate","DayDate","PointInTime","Age","AgeLower","AgeUpper","AgeUnit",
                       "Certainty","Negation")

WDGS <- WDGS%>% 
  select(Letter,Start,End,CUI,TimePeriod, NumberOfTimePeriods,
         LowerNumberOfTimePeriods,UpperNumberOfTimePeriods,
         YearDate,MonthDate,DayDate,PointInTime,Age,AgeLower,AgeUpper,AgeUnit)

View(WDGS)
by <- join_by(Letter, CUI, overlaps(x$Start, x$End, y$Start, y$End)) 

TP <- inner_join(WDEx, WDGS, by) %>% 
  count()
#View(TP)
FP <- anti_join(WDEx, WDGS, by) %>% 
  count()
#View(FP)

FN <- anti_join(WDGS, WDEx, by) %>% 
  count()
View(FN)

prec <- (TP/(TP+FP))
View(prec) # 0.9375 same as GATE

recall <- (TP/(TP+FN))
View(recall) # 0.88235 same as GATE

F1 <- 2*((prec*recall)/(prec+recall))
View(F1) # 0.909091 same as GATE

# Per letter score based on specific CUI match

WDExLetter <- WDEx %>% 
  select(Letter, CUI) %>% 
  distinct()
#View(OnsetExLetter)

WDGSLetter <- WDGS %>% 
  select(Letter, CUI) %>% 
  distinct()


by <- join_by(Letter, CUI)

TP <- inner_join(WDExLetter,WDGSLetter,by) %>% 
  count()


FP <- anti_join(WDExLetter,WDGSLetter,by) %>% 
  count()

View(FP)

FN <- anti_join(WDGSLetter, WDExLetter, by) %>% 
  count()
#View(FN)

prec <- (TP/(TP+FP))
View(prec) # 	0.9375

recall <- (TP/(TP+FN))
View(recall) # 0.882353

F1 <- 2*((prec*recall)/(prec+recall))
View(F1) # 	0.909091




