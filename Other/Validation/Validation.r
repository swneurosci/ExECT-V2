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

setwd("YOUR WORKING DIRECTORY FOR GROOVY OUTPUTS")# set working dir

# Link for ExECT outputs - 
# Link for Markup/GoldStandard CSVs - https://zenodo.org/records/12520180. 

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


# annotations


PHEx$MonthDate <- as.numeric(PHEx$MonthDate)


by <- join_by(Letter, CUI, TimePeriod, NumberOfTimePeriods,
              LowerNumberOfTimePeriods,UpperNumberOfTimePeriods,
              YearDate,MonthDate,DayDate,PointInTime,Age,AgeLower,AgeUpper,AgeUnit,
              Certainty,Negation, overlaps(x$Start, x$End, y$Start, y$End)) 


TP <- inner_join(PHEx, PHGS, by) %>% 
  count()

View(TP)





FP <- anti_join(PHEx, PHGS, by) %>% 
  count() 

View(FP)

FN <- anti_join(PHGS, PHEx, by) %>% 
  count() 
View(FN)


# Precision, recall, F score for Patient History per-item result

prec <- (TP/(TP+FP))
View(prec) 

recall <- (TP/(TP+FN))
View(recall) 

F1 <- 2*((prec*recall)/(prec+recall))
View(F1) 
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
View(prec)

recall <- (TP/(TP+FN))
View(recall)

F1 <- 2*((prec*recall)/(prec+recall))
View(F1) 


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
View(prec) 

recall <- (TP/(TP+FN))
View(recall) 

F1 <- 2*((prec*recall)/(prec+recall))
View(F1) 

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
View(prec) 

recall <- (TP/(TP+FN))
View(recall)

F1 <- 2*((prec*recall)/(prec+recall))
View(F1) 



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
View(prec) 

recall <- (TP/(TP+FN))
View(recall) 

F1 <- 2*((prec*recall)/(prec+recall))
View(F1) 

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
View(prec) 

recall <- (TP/(TP+FN))
View(recall) 

F1 <- 2*((prec*recall)/(prec+recall))
View(F1) 


	

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
View(prec) 

recall <- (TP/(TP+FN))
View(recall) 

F1 <- 2*((prec*recall)/(prec+recall))
View(F1) 


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
View(prec) 

recall <- (TP/(TP+FN))
View(recall) 

F1 <- 2*((prec*recall)/(prec+recall))
View(F1) 


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
View(prec) 

recall <- (TP/(TP+FN))
View(recall) 

F1 <- 2*((prec*recall)/(prec+recall))
View(F1) 

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
 View(prec) 
 
 recall <- (TP/(TP+FN))
 View(recall) 
 
 F1 <- 2*((prec*recall)/(prec+recall))
 View(F1) 
 
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
 View(prec)
 
 recall <- (TP/(TP+FN))
 View(recall)
 
 F1 <- 2*((prec*recall)/(prec+recall))
 View(F1) 
 
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
 View(prec) 
 
 recall <- (TP/(TP+FN))
 View(recall) 
 
 F1 <- 2*((prec*recall)/(prec+recall))
 View(F1) 
 
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
View(prec) 

recall <- (TP/(TP+FN))
View(recall) 

F1 <- 2*((prec*recall)/(prec+recall))
View(F1) 

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
View(prec) 

recall <- (TP/(TP+FN))
View(recall)

F1 <- 2*((prec*recall)/(prec+recall))
View(F1) 


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
View(prec)

recall <- (TP/(TP+FN))
View(recall) 

F1 <- 2*((prec*recall)/(prec+recall))
View(F1) 

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
View(prec) 

recall <- (TP/(TP+FN))
View(recall) 

F1 <- 2*((prec*recall)/(prec+recall))
View(F1) 

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
View(prec)

recall <- (TP/(TP+FN))
View(recall) 

F1 <- 2*((prec*recall)/(prec+recall))
View(F1) 

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
View(prec) 

recall <- (TP/(TP+FN))
View(recall) 

F1 <- 2*((prec*recall)/(prec+recall))
View(F1) 

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
View(TP) 

FP <- anti_join(SFEx, SFGS, by) %>% 
  count()

View(FP)

FN <- anti_join(SFGS, SFEx, by) %>% 
  count()

View(FN) 

prec <- (TP/(TP+FP))
View(prec) 


recall <- (TP/(TP+FN))
View(recall) 

F1 <- 2*((prec*recall)/(prec+recall))
View(F1) 

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
View(TP) 

FP <- anti_join(SFExLetter, SFGSLetter, by) %>% 
  count()

View(FP) 

FN <- anti_join(SFGSLetter, SFExLetter, by) %>% 
  count()

View(FN) 

prec <- (TP/(TP+FP))
View(prec) 


recall <- (TP/(TP+FN))
View(recall) 

F1 <- 2*((prec*recall)/(prec+recall))
View(F1) 


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
View(prec)

recall <- (TP/(TP+FN))
View(recall) 

F1 <- 2*((prec*recall)/(prec+recall))
View(F1) 

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
View(prec) 

recall <- (TP/(TP+FN))
View(recall)

F1 <- 2*((prec*recall)/(prec+recall))
View(F1) 