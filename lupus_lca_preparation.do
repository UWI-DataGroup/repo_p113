** HEADER -----------------------------------------------------
**  DO-FILE METADATA
//  algorithm name			lupus_lca_preparation.do
//  project:						Epidemiology of Lupus in ST.Lucia
//  analysts:						Ian HAMBLETON
//	date last modified	15-Aug-2018
//  algorithm task			Preparing the data for analysis

** General algorithm set-up
version 15
clear all
macro drop _all
set more 1
set linesize 80

** Set working directories: this is for DATASET and LOGFILE import and export
** DATASETS to encrypted SharePoint folder
local datapath "X:\The University of the West Indies\DataGroup - repo_data\data_p113"
** LOGFILES to unencrypted OneDrive folder
local logpath X:\OneDrive - The University of the West Indies\repo_datagroup\repo_p113

** Close any open log fileand open a new log file
capture log close
cap log using "`logpath'\lupus_lca_preparation", replace
** HEADER -----------------------------------------------------


** ***************************************************
** DATASET PART 1.
** IAN HAMBLETON CODE
** ***************************************************

** Load the unprepared 2018 dataset
** Data from Amanda Greenidge. April 30, 2018.
import excel using "`datapath'\version01\1-input\Lupus Database 2018_workingfile_v2_30-04-2018.xlsx", sheet("Data pt1 (IH)") first

** Unique ID. Drop empty rows from dataset
rename ID pid
label var pid "Unique participant identifier"
drop if pid==.

** 1 person is not from LCS - delete
drop if pid ==81 & DISTRICT=="REGIONAL"

** LAST name
rename SURNAME last
label var last "Last name moniker"

** FIRST name
rename C first
label var first "First name moniker"

** SEX - remove trailing blanks
gen temp1 = strtrim(SEX)
encode temp1, gen(sex)
label var sex "Participant gender, 1=female, 2=male"
drop SEX temp1
order sex, after(first)

** Date of Birth - data Corrections due to mis-entered dates
rename DOB dob
replace dob = "12aug1984" if pid==14 & dob=="August 12th, 1984"
replace dob = "6May1997" if pid==28 & dob=="Tuesday May6th, 1997"
replace dob = "27jan1988" if pid==35 & dob=="January 27th, 1988"
replace dob = "29apr1992" if pid==50 & dob=="April 29th, 1992"
replace dob = "9dec1993" if pid==82 & dob=="December 9th, 1993"
replace dob = "13oct1980" if pid==104 & dob=="October 13th, 1980"
replace dob = "3jul1970" if pid==105 & dob=="July 3rd, 1970"
replace dob = "16apr1958" if pid==106 & dob=="April 16th, 1958"
replace dob = "10may1974" if pid==109 & dob=="May 10th, 1974"
replace dob = "6may1966" if pid==116 & dob=="May 6th 1966"
replace dob = "18apr1975" if pid==117 & dob=="April 18th, 1975"
replace dob = "17sep1950" if pid==130 & dob=="September 17th 1950"
replace dob = "27jan1983" if pid==133 & dob=="JANUARY 27TH, 1983"
replace dob = "23jun1984" if pid==135 & dob=="June 23rd, 1984"
rename dob temp1
gen dob = date(temp1, "DMY", 2018)
format dob %d d_mon_CY
label var dob "Date of birth"
order dob, after(sex)
drop temp1

** AGE. Extra last (numerical) part of this string
** New age - calculated age
gen today = d(13apr2018)
gen age = (today-dob)/365.25
label var age "Age at 13-April-2018"
order age, after(dob)

** AGE at diagnosis
rename AGEDX aad
label var aad "Age at diagnosis to the nearest year"

** Create 10-year age groups from age at diagnosis
gen aad10 = 1 if aad>=10 & aad<=19
replace aad10 = 2 if aad>=20 & aad<=29
replace aad10 = 3 if aad>=30 & aad<=39
replace aad10 = 4 if aad>=40 & aad<=49
replace aad10 = 5 if aad>=50 & aad<=59
replace aad10 = 6 if aad>=60 & aad<=69
label define aad10 1 "10-19" 2 "20-29" 3 "30-39" 4 "40-49" 5 "50-59" 6 "60-69",modify
label values aad10 aad10
label var aad10 "Age at diagnosis in 10-year age groups"
order aad aad10 , after(age)
drop AGE AGEGRPDX

** YEAR of First Symptoms
gen yosym = real(DATE1STSYMPTOMS)
label var yosym  "Year of first symptoms"
order yosym, after(aad10)

** YEAR of Diagnosis
rename YEARDx yodx
label var yodx "Year of diagnosis"
order yodx, after(yosym)

** YRS from 1st symptoms to diagnosis
gen sym2dx = yodx-yosym
label var sym2dx "Years from 1st symptoms to diagnosis"
order sym2dx, after(yodx)
drop Yrsfrom1stsymptomtoDx

** Years lived since Diagnosis
gen yeartoday = 2018
gen dx2now = 2018 - yodx
label var dx2now "Years from diagnosis to 2018"
order dx2now, after(sym2dx)
drop yeartoday

** VITAL STATUS
gen status = 1
replace status = 0 if YrslivedsinceDx=="DEAD"
label var status "vital status, 1=alive, 0=died"
label define status 0 "died" 1 "alive",modify
label values status status
order status, after(dx2now)

** Discount or exemption from charges
gen discount = Discountexempt
label define discount 0 "no" 1 "discount", modify
label values discount discount
label var discount "Exemption from or discount on medical charges"
order discount, after(status)

** District
gen district = .
replace district = 1 if  DISTRICT=="ANSE LA RAYE" | DISTRICT=="ANSE-LA-RAYE"
replace district = 2 if  DISTRICT=="BABONNEAU"
replace district = 3 if  DISTRICT=="CANARIES"
replace district = 4 if  DISTRICT=="CASTRIES"
replace district = 5 if  DISTRICT=="CHOISEUL"
replace district = 6 if  DISTRICT=="DENNERY"
replace district = 7 if  DISTRICT=="GROS ISLET" | DISTRICT=="GROS-ISLET" | DISTRICT=="Gros Islet"
replace district = 8 if  DISTRICT=="LABORIE" | DISTRICT=="Laborie"
replace district = 9 if  DISTRICT=="MICOUD"
replace district = 10 if DISTRICT=="SOUFRIERE"
replace district = 11 if DISTRICT=="VIEUX FORT" | DISTRICT=="VIEUX-FORT" | DISTRICT=="Vieux Fort"
label define district 	1 "Anse-la-Raye"	///
						2 "Babonneau"		///
						3 "Canaries"		///
						4 "Castries"		///
						5 "Choiseul"		///
						6 "Dennery"			///
						7 "Gros-Islet"		///
						8 "Laborie"			///
						9 "Micoud"			///
						10 "Soufriere"		///
						11 "Vieux Fort"

label values district district

label var district "District of residence"
order district, after(discount)

** Education
gen educ = .
replace educ = 1 if Education=="1"
replace educ = 2 if Education=="2"
replace educ = 3 if Education=="3"
label define educ 1 "primary" 2 "secondary" 3 "tertiary",modify
label values educ educ
label var educ "Participant educational level"
order educ, after(district)

** Occupation
replace OCCUPATIONISCO08=" " if OCCUPATIONISCO08=="UNKNOWN"
replace OCCUPATIONISCO08="5" if OCCUPATIONISCO08=="?5"
replace OCCUPATIONISCO08=" " if OCCUPATIONISCO08=="x"
gen occ=.
replace occ = 0 if OCCUPATIONISCO08=="0"
replace occ = 1 if OCCUPATIONISCO08=="1"
replace occ = 2 if OCCUPATIONISCO08=="2"
replace occ = 3 if OCCUPATIONISCO08=="3"
replace occ = 4 if OCCUPATIONISCO08=="4"
replace occ = 5 if OCCUPATIONISCO08=="5"
replace occ = 6 if OCCUPATIONISCO08=="6"
replace occ = 7 if OCCUPATIONISCO08=="7"
replace occ = 8 if OCCUPATIONISCO08=="8"
replace occ = 9 if OCCUPATIONISCO08=="9"
replace occ = 10 if OCCUPATIONISCO08=="10"
label define occ 	0 "unempl/stud/hwife" 	1 "managers" 		2 "professionals" 	3 "technicians"		///
					4 "clerical"			5 "service/sales"	6 "skilled agri"	7 "craft"			///
					8 "plant operators"		9 "elementary"		10 "armed forces",modify
label values occ occ
label var occ "Participant occupation"
order occ, after(educ)

** DROP
drop YrslivedsinceDx DATE1STSYMPTOMS ADDRESS Discountexempt today DISTRICT Education OCCUPATIONISCO08

** Save the file
label data "Lupus in St.Lucia: dataset 13-april-2018"
save "`datapath'\version01\2-working\lupus_lca_001", replace






** ***************************************************
** DATASET PART 2.
** CATHERINE BROWN CODE
** ***************************************************
** Load the unprepared 2018 dataset
import excel using "`datapath'\version01\1-input\Lupus Database 2018_workingfile_v2_30-04-2018.xlsx", sheet("Data pt2 (CB)") first clear

** Unique ID. Drop empty rows from dataset
rename ID pid
label var pid "Unique participant identifier"
drop if pid==.

** RENAME VARIABLES
rename ANA ana
rename RNP rnp
rename DSDNA dna
rename SSA ssa
rename SSB ssb
rename Sm sm
rename SCL scl
rename ACL acl
rename LAC lac
rename β2GP1 b2gp1
rename RF rf
rename antiCCP ccp
rename antiJo1 jo1
rename ANCA anca
rename loC3C4 lowc3c4
rename VitD25OHlow lowvd
rename Alopecia alo
rename Arthritis arth
rename Malarrash mrash
rename Discoidrash drash
rename Lymphnodes lymn
rename Photosensitivity photo
rename Anaemiahemolytic anem
rename Lymphopenia lymp
rename Thrombocytopenia tbcp
rename Proteinuria protu
rename Spontaneousmiscarriage smisc
rename PleuriticChestpain plchp
rename Fever fev
rename Neuro neur
rename Fatigue fati
rename Raynauds ray
rename OralNasalulcers ulcer
rename MyalgiaMyositis mymy
rename Drymoutheyes dry
rename Alopecia1 alo1
rename Arthritis arth1
rename Malarrash1 mrash1
rename Discoidrash1 drash1
rename Lymphnodes1 lymn1
rename Photosensitivity1 photo1
rename Anaemia1 anem1
rename Lymphopenia1 lymp1
rename Thrombocytopenia1 tbcp1
rename Proteinuria1 protu1
rename Spontaneousmiscarriage1 smisc1
rename PleuriticChestpain1 plchp1
rename Neuro1 neur1
rename Fever1 fev1

**REMOVING X AND CHANGING TO NUMERICS
destring ana, replace
replace ana="." if ana=="x" | ana=="X"
destring ana, replace
replace rnp="." if rnp=="x" | rnp=="X"
destring rnp, replace
replace dna="." if dna=="x" | dna=="X"
destring dna, replace
replace ssa="." if ssa=="x" | ssa=="X"
destring ssa, replace
replace ssb="." if ssb=="x" | ssb=="X"
destring ssb, replace
replace sm="." if sm=="x" | sm=="X"
destring sm, replace
replace scl="." if scl=="x" | scl=="X"
destring scl, replace
replace acl="." if acl=="x" | acl=="X"
destring acl, replace
replace lac="." if lac=="x" | lac=="X"
destring lac, replace
rename b2gp1 gp1
replace gp1="." if gp1=="x" | gp1=="X"
destring gp1, replace
replace rf="." if rf=="x" | rf=="X"
destring rf, replace
replace ccp="." if ccp=="x" | ccp=="X"
destring ccp, replace
replace jo1="." if jo1=="x" | jo1=="X"
destring jo1, replace
replace anca="." if anca=="x" | anca=="X"
destring anca, replace
replace lowc3c4="." if lowc3c4=="x" | lowc3c4=="X"
destring lowc3c4, replace
replace lowvd="." if lowvd=="x" | lowvd=="X"
destring lowvd, replace

**SPLITTING VARIABLE INTO 2
rename fati temp1
gen fati=0
replace fati=1 if temp1=="1"
gen fati1=0
replace fati1=1 if temp1=="1*"
tab temp1 fati
tab temp1 fati1
drop temp1
rename ulcer temp1
gen ulcer=0
replace ulcer=1 if temp1=="1"
gen ulcer1=0
replace ulcer1=1 if temp1=="1*"
tab temp1 ulcer
tab temp1 ulcer1
drop temp1
rename ray temp1
gen ray=0
replace ray=1 if temp1=="1"
gen ray1=0
replace ray1=1 if temp1=="1*"
tab temp1 ray
tab temp1 ray1
drop temp1
rename mymy temp1
gen mymy=0
replace mymy=1 if temp1=="1"
gen mymy1=0
replace mymy1=1 if temp1=="1*"
tab temp1 mymy
tab temp1 mymy1
drop temp1
rename dry temp1
gen dry=0
replace dry=1 if temp1=="1"
gen dry1=0
replace dry1=1 if temp1=="1*"
tab temp1 dry
tab temp1 dry1
drop temp1

**LABELING DIAGNOSTIC TESTS FEATURES
label define diagt 0 "negative" 1 "positive"
label values ana daigt
label values rnp daigt
label values dna daigt
label values ssa daigt
label values ssb daigt
label values sm daigt
label values scl daigt
label values acl daigt
label values lac daigt
label values gp1 daigt
label values rf daigt
label values ccp daigt
label values jo1 daigt
label values anca daigt
label values lowc3c4 daigt
label values lowvd daigt
label define pfeat 0 "no" 1 "yes"
label values alo pfeat
label values arth pfeat
label values mrash pfeat
label values drash pfeat
label values lymn pfeat
label values photo pfeat
label values fev pfeat
label values anem pfeat
label values lymp pfeat
label values tbcp pfeat
label values protu pfeat
label values smisc pfeat
label values plchp pfeat
label values neur pfeat
label values alo1 pfeat
label define dfeat 0 "no" 1 "yes"
label values alo1 dfeat
label values arth1 dfeat
label values mrash1 dfeat
label values drash1 dfeat
label values lymn1 dfeat
label values photo1 dfeat
label values fev1 dfeat
label values anem1 dfeat
label values lymp1 dfeat
label values tbcp1 dfeat
label values protu1 dfeat
label values smisc1 dfeat
label values plchp1 dfeat
label values neur1 dfeat

** Save the file
label data "Lupus in St.Lucia: dataset 13-april-2018"
save "`datapath'\version01\2-working\lupus_lca_002", replace







** ***************************************************
** DATASET PART 3.
** CHRISTINA HOWITT CODE
** ***************************************************

*import data from excel to Stata
import excel "`datapath'\version01\1-input\Lupus Database 2018_workingfile_v2_30-04-2018.xlsx", sheet("Data pt3 (CH)") firstrow clear

** DO-FILE SECTION 01: Prep section 1 of variables (investigations)
rename ECHO echo
label variable echo "echocardiogram (investigation)"
replace echo = "." if echo =="X"
replace echo = "" in 145
destring echo, replace
drop if ID >144
label define invest 0 "negative" 1 "positive"
label values echo invest

rename HRCTChest ct
label variable ct "high resolution CT of chest (investigation)"
replace ct = "." if ct =="X"
replace ct = "." if ct =="x"
destring ct, replace
label values ct invest

rename UGIE endo
label variable endo "upper GI endoscopy (investigation)"
replace endo = "." if endo =="X"
replace endo = "." if endo =="x"
destring endo, replace
label values endo invest

rename RENALBIOPSY biop
label variable biop "renal biopsy (investigation)"
replace biop = "." if biop =="X"
replace biop = "." if biop =="x"
destring biop, replace
label values biop invest

drop Result Comments

** DO-FILE SECTION 02: Prep section 2 of variables (complications)
label define comp 0 "absent" 1 "present"

rename Pericardialeffusion peri
label variable peri "pericardial effusion (complication)"
replace peri = "." if peri =="X"
replace peri = "." if peri =="x"
destring peri, replace
label values peri comp

rename Nephritis neph
label variable neph "nephritis (complication)"
replace neph = "." if neph =="X"
replace neph = "." if neph =="x"
destring neph, replace
label values neph comp

rename Renalfailure renal
label variable renal "renal failure (complication)"
replace renal = "." if renal =="X"
replace renal = "." if renal =="x"
destring renal, replace
label values renal comp

rename Dialysis dial
label variable dial "dialysis (complication)"
replace dial = "." if dial =="X"
replace dial = "." if dial =="x"
destring dial, replace
label values dial comp

rename CAcervixABNORMALPAPSMEAR cerv
label variable cerv "cervical dysplasia or cancer (complication)"
replace cerv = "." if cerv =="X"
replace cerv = "." if cerv =="x"
destring cerv, replace
label values cerv comp

rename Osteopeniaporosis osteo
label variable osteo "osteopenia or osteoporosis (complication)"
replace osteo = "." if osteo =="X"
replace osteo = "." if osteo =="x"
destring osteo, replace
label values osteo comp

replace AvascularNecrosis = "1" in 141
rename AvascularNecrosis avas
label variable avas "avascular necrosis(complication)"
replace avas = "." if avas =="X"
replace avas = "." if avas =="x"
destring avas, generate(avas1) force
replace avas1 = 0 in 107
drop avas
rename avas1 avas
label values avas comp

rename PLEURITIS pleur
tab pleur, miss
label variable pleur "pleuritis (complication)"
label values pleur comp

rename PulmonaryHTN pulm
tab pulm, miss
label variable pulm "pulmonary hypertension(complication)"
label values pulm comp

rename HTN htn
tab htn, miss
label variable htn "hypertension(complication)"
label values htn comp

rename Cataracts cat
tab cat, miss
label variable cat "cataracts(complication)"
label values cat comp

rename Lungdisease lung
tab lung, miss
label variable lung "Lung disease(complication)"
label values lung comp

rename PulmonaryFibrosis pulmf
tab pulmf, miss
label variable pulmf "Pulmonary Fibrosis(complication)"
label values pulmf comp

rename Cerebritis cereb
tab cereb, miss
replace cereb="1" if cereb=="1*"
destring cereb, replace
label variable cereb "Cerebritis(complication)"
label values cereb comp

rename DVTPETHROMBOSIS dvt
tab dvt, miss
label variable dvt "deep vein thrombosis, pulmonary effusion or thrombosis(complication)"
label values dvt comp

rename DM dm
tab dm, miss
label variable dm "diabetes mellitus(complication)"
replace dm = "." if dm =="X"
replace dm = "." if dm =="x"
destring dm, replace
label values dm comp

rename Lipid lipid
tab lipid, miss
label variable lipid "hyperlipidemia(complication)"
replace lipid = "." if lipid =="X"
replace lipid = "." if lipid =="x"
destring lipid, replace
label values lipid comp

destring BMI1, generate(bmi1) force
drop BMI1
label variable bmi1 "BMI at first doctor visit"

destring BMI2, generate(bmi2) force
drop BMI2
label variable bmi2 "BMI at latest doctor visit"

drop OtherComorbidities

** DO-FILE SECTION 03: Prep section 3 of variables (medications)
label define med 0 "Never" 1 "Current" 2 "Past"

rename HCQ hcq
label variable hcq "hydroxychloroquine"
tab hcq, miss
replace hcq="2" if hcq=="0*"
destring hcq, replace
label values hcq med

rename CHLOROQUINE chq
label variable chq "Chloroquine"
tab chq, miss
replace chq="2" if chq=="0*"
destring chq, replace
label values chq med

rename MMF mmf
label variable mmf "mycophenolate mofetil"
tab mmf, miss
replace mmf="2" if mmf=="0*"
destring mmf, replace
label values mmf med

rename AZA aza
label variable aza "azathioprine"
tab aza, miss
replace aza="2" if aza=="0*"
destring aza, replace
label values aza med

rename MTX mtx
label variable mtx "methotrexate"
tab mtx, miss
replace mtx="2" if mtx=="0*"
destring mtx, replace
label values mtx med

rename PRED pred
label variable pred "prednisolone"
tab pred, miss
replace pred="2" if pred=="0*"
replace pred="1" if pred=="1*"
destring pred, replace
label values pred med

rename Avdose pred_dose
destring pred_dose, generate(pred_dose2) force
drop pred_dose
rename pred_dose2 pred_dose
replace pred_dose=. if pred==0 | pred==2
label variable pred_dose "Current prednisolone dose (mg)"

rename Cyclophosphamide cyc
label variable cyc "Cyclophosphamide"
tab cyc, miss
replace cyc="2" if cyc=="0*"
destring cyc, replace
label values cyc med

rename Warfarin warf
label variable warf "Warfarin"
tab warf, miss
replace warf="2" if warf=="0*"
destring warf, replace
label values warf med

rename ASA asp
label variable asp "Asparin"
tab asp, miss
replace asp="2" if asp=="0*"
destring asp, replace
label values asp med

rename Bisphosphonates bis
label variable bis "Bisphosphonates"
tab bis, miss
replace bis="2" if bis=="0*"
destring bis, replace
label values bis med


** DO-FILE SECTION 04: Prep section 4 of variables (other)
drop SLEDAI CONTAC_NO

rename ALIVE alive
label define alive 0 "dead" 1 "alive"
label values alive alive

rename FAMILY_Hx fam
tab fam, miss
replace fam="1" if fam=="1 (15YR OLD SISTER IN 2017 WITH NEPHRITIS)"
destring fam, replace
label define fam 0 "no family history" 1 "family history"
label values fam fam

rename ACR_CRITERIA acr
label variable acr "# of criteria according to Am Coll of Rheumatology"

rename SLICC slicc
label variable slicc "# of criteria according to Systemic Lupus International Collaborating Clinics"

rename Adherent adh
label variable adh "Subjective measure of whether participant is taking medication >80% of the time"
replace adh="2" if adh=="0*"
replace adh="3" if adh=="1*"
replace adh="." if adh=="?"
destring adh, replace
label define adh 0 "current non-adherent" 1 "current adherent" 2 "non-adherent, but used to be adherent" 3 "adherent, but used to be non-adherent"
label values adh adh

rename SelfMxprogram self
label variable self "self-management programme"
label define self 0 "Not done programme" 1 "Done programme"
label values self self

drop AW AX COMMENTS


** Save the file
rename ID pid
label data "Lupus in St.Lucia: dataset 13-april-2018"
save "`datapath'\version01\2-working\lupus_lca_003", replace




** *****************************************************
** Merge the three datasets
** *****************************************************
use "`datapath'\version01\2-working\lupus_lca_001", clear
merge 1:1 pid using "`datapath'\version01\2-working\lupus_lca_002"
drop if _merge==2
drop _merge
merge 1:1 pid using "`datapath'\version01\2-working\lupus_lca_003"
drop if _merge==2
drop _merge


** *****************************************************
** Save the MERGED file
** *****************************************************
label data "Lupus in St.Lucia: dataset 13-april-2018"
save "`datapath'\version01\2-working\lupus_lca_april2018_v3", replace




** *****************************************************
** CB Descriptive analyses
** *****************************************************

** Recode education into 2 categories
gen educ2 = educ
recode educ2 1=2
label values educ2 educ
order educ2, before(occ)

** Recode occupation into 4 categories
gen occ_grade1 =.
replace occ_grade1 = 1 if occ == 6 | occ == 7 | occ ==8 | occ==9
replace occ_grade1 = 2 if occ == 3 | occ == 4 | occ ==5
replace occ_grade1 = 3 if occ ==1 | occ ==2
replace occ_grade1 = 4 if occ==0
label variable occ_grade1 "occupation grade"
label define occ_grade1 1 "Routine/manual" 2 "Intermediate" 3 "Professional" 4 "Not in employment"
label values occ_grade1 occ_grade1

** Recode adherence into 2 categories
recode adh 2=0 3=1

** Table 1**********************************************
* Age at diagnosis
sum aad
bysort sex: sum aad
* Age at analysis (13 April 2018)
sum age
bysort sex: sum  age
tab sex
tab educ2
tab occ_grade1
tab discount
tab fam


** Table 2a*********************************************
*Diagnostic tests

* Antinuclear antibody. Line 1
tab ana
local num = r(N)
tab ana,miss
local denom = r(N)
dis "`num' / `denom' = " (`num' / `denom')*100

* double-stranded DNA. line 2
tab dna
local num = r(N)
tab dna,miss
local denom = r(N)
dis "`num' / `denom' = " (`num' / `denom')*100

* RNP antibody. Line 3
tab rnp
local num = r(N)
tab rnp,miss
local denom = r(N)
dis "`num' / `denom' = " (`num' / `denom')*100

* anti-Smith antibody. Line 4
tab sm
local num = r(N)
tab sm,miss
local denom = r(N)
dis "`num' / `denom' = " (`num' / `denom')*100

* Anti-SSA. Line 5
tab ssa
local num = r(N)
tab ssa,miss
local denom = r(N)
dis "`num' / `denom' = " (`num' / `denom')*100

* anti-SSB. Line 6
tab ssb
local num = r(N)
tab ssb,miss
local denom = r(N)
dis "`num' / `denom' = " (`num' / `denom')*100

* anti-cardiolipin antibodies. Line 7
tab acl
local num = r(N)
tab acl,miss
local denom = r(N)
dis "`num' / `denom' = " (`num' / `denom')*100

* lupus anticoagulant. Line 8
tab lac
local num = r(N)
tab lac,miss
local denom = r(N)
dis "`num' / `denom' = " (`num' / `denom')*100

* β-2-glycoprotein-1. Line 9
tab gp1
local num = r(N)
tab gp1,miss
local denom = r(N)
dis "`num' / `denom' = " (`num' / `denom')*100

* Rheumatoid factors. Line 10
tab rf
local num = r(N)
tab rf,miss
local denom = r(N)
dis "`num' / `denom' = " (`num' / `denom')*100

** anti-Scleroderma 70 antibody. Line 11
tab scl
local num = r(N)
tab scl,miss
local denom = r(N)
dis "`num' / `denom' = " (`num' / `denom')*100

* anti-cyclic citrullinated peptide antibodies. Line 12
tab ccp
local num = r(N)
tab ccp,miss
local denom = r(N)
dis "`num' / `denom' = " (`num' / `denom')*100

* anti-neutrophil cytoplasmic antibodies. Line 13
tab anca
local num = r(N)
tab anca,miss
local denom = r(N)
dis "`num' / `denom' = " (`num' / `denom')*100

* Jo1 antibodies. Line 14
tab jo1
local num = r(N)
tab jo1,miss
local denom = r(N)
dis "`num' / `denom' = " (`num' / `denom')*100


** OTHER investigations
** C3 and C4 (low)
tab lowc3c4
local num = r(N)
tab lowc3c4,miss
local denom = r(N)
dis "`num' / `denom' = " (`num' / `denom')*100

** 25-hydroxy vitamin D (low)
tab lowvd
local num = r(N)
tab lowvd,miss
local denom = r(N)
dis "`num' / `denom' = " (`num' / `denom')*100

** Echocardiogram
tab echo
local num = r(N)
tab echo,miss
local denom = r(N)
dis "`num' / `denom' = " (`num' / `denom')*100

** High-resolution chest CT
tab ct
local num = r(N)
tab ct,miss
local denom = r(N)
dis "`num' / `denom' = " (`num' / `denom')*100

** Upper GI endoscopy
tab endo
local num = r(N)
tab endo,miss
local denom = r(N)
dis "`num' / `denom' = " (`num' / `denom')*100

** Renal biopsy
tab biop
local num = r(N)
gen biopk=1
tab biopk if neph==1, miss
local denom = r(N)
dis "`num' / `denom' = " (`num' / `denom')*100


** Table 2b*********************************************
** Presenting features
tab arth
tab fati
tab alo
tab drash
tab anem
tab photo
tab fev
tab plchp
tab lymp
tab mrash
tab mymy
tab protu
tab dry
tab ulcer
tab lymn
tab ray
tab tbcp
tab neur
tab smisc

*Diagnostic criteria
tab acr
gen acrmeet=0
order acrmeet, before(slicc)
replace acrmeet=1 if acr>=4 & acr<.
label variable acrmeet "Person meets ACR criteria"
label define acrmeet 0 "does not meet ACR criteria" 1 "meets ACR criteria"
label values acrmeet acrmeet
tab acrmeet
tab slicc
gen sliccmeet=0
order sliccmeet, before(adh)
replace sliccmeet=1 if slicc>=4 & slicc<.
label variable sliccmeet "Person meets SLICC criteria"
label define sliccmeet 0 "does not meet SLICC criteria" 1 "meets SLICC criteria"
label values sliccmeet sliccmeet
tab sliccmeet
*Meeting SLICC but not ACR & vice versa											// CH: I have no idea if this makes sense
preserve
	drop if neph==. | (ana==0 & dna==.) | (dna==0 & ana==.)
	gen slicc_var = 0
	replace slicc_var = 1 if neph==1 & (ana==1 | dna==1)
	tab slicc_var
restore


** *******************************************
** Table 3a
** Developed features among 143 patients with systemic lupus erythematosus
** *******************************************
tab protu1
tab alo1
tab neur1
tab plchp1
tab ray1
tab drash1
tab tbcp1
tab photo1
tab fev1
tab arth1
tab ulcer1
tab mrash1
tab dry1
tab lymn1
tab anem1
tab lymp1
tab mymy1
tab fati1
tab smisc1


** *********************************************
** Table 3b
** SLE complications among 143 patients with systemic lupus erythematosus
** *********************************************
* Overwight or obese
gen ovob=0
order ovob, before(hcq)
label variable ovob "Person overweight or obese"
label define ovob 0 "not overweight or obese" 1 "overweight or obese"
label values ovob ovob
replace ovob=1 if bmi2>=25 & bmi2<.
replace ovob=. if bmi2==.
tab ovob
** Overweight or obese at presentation
gen ovob1=0
order ovob1, after(ovob)
label variable ovob1 "Person overweight or obese at presentation"
label define ovob1 0 "not overweight or obese at presentation" 1 "overweight or obese at presentation"
label values ovob1 ovob1
replace ovob1=1 if bmi1>=25 & bmi1<.
replace ovob1=. if bmi1==.
tab ovob1
** Overweight or Obese at last follow-up rename ovob ovob2
rename ovob ovob2
order ovob2, after(ovob1)
label variable ovob2 "Person overweight or obese at last follow up"
label define ovob2 0 "not overweight or obese at last follow up" 1 "overweight or obese at last follow up"
label values ovob2 ovob2
replace ovob2=1 if bmi2>=25 & bmi2<.
replace ovob2=. if bmi2==.
tab ovob2

tab neph
tab htn
tab osteo
tab lipid
tab cereb
tab pleur
tab peri
tab renal
tab lung
tab dvt
tab cerv
tab avas
tab dm
tab pulm
tab pulmf
tab cat



** *********************************************
** Table 3c
** Disease severity by markers of socio-economic position
** *********************************************
foreach var in educ2 occ_grade1 discount {
	preserve
		drop if cereb==. | neph==. | dial==. | `var'==.
		gen sev=0
		replace sev=1 if cereb==1 | neph==1 | dial==1
		tab sev `var', freq  col
	restore
	}



** *********************************************
** Table 4A
** SLE medications among 143 patients
** *********************************************
tab hcq
tab chq
tab mmf
tab aza
tab mtx
tab pred
tab cyc
tab warf
tab asp
tab bis

tab self

** 16-AUG-2018
** ANALYSIS EXTRA
** (1) Tabulate prednisolone dose
gen pdosec = .
replace pdosec = 1 if pred_dose==0
replace pdosec = 2 if pred_dose>0 & pred_dose<=7.5
replace pdosec = 3 if pred_dose>7.5 & pred_dose<=15
replace pdosec = 4 if pred_dose>15 & pred_dose<=30
replace pdosec = 5 if pred_dose>30 & pred_dose<=60
tab pred_dose
tab pdosec

** (2) Osteo and current prednisolone use
gen bone = 0
replace bone = 1 if osteo==1
replace bone = . if osteo==.
gen prednow = 0
replace prednow = 1 if pred==1
tab prednow bone, row chi exact
table bone, c(mean pred_dose sd pred_dose)
ttest pred_dose, by(bone)




/*

** Table 4b**********************************************
foreach var in educ2 occ_grade1 discount {
	preserve
		drop if adh==. | `var'==.
		tab adh `var', freq  col
	restore
	}




** Addendum*********************************************
*Calculate incidence rate per year band as seen in Figure 1
	*1. Create variable for general popln, by yearband
preserve
	gen pop1=.
	label variable pop1 "Popl'n of St. Lucia at year-band of diagnosis"
	replace pop1=104160 if yodx>=1970 & yodx<=1979
	replace pop1=117987 if yodx>=1980 & yodx<=1989
	replace pop1=138185 if yodx>=1990 & yodx<=1999
	replace pop1=156949 if yodx>=2000 & yodx<=2004
	replace pop1=163714 if yodx>=2005 & yodx<=2009
	replace pop1=172580 if yodx>=2010 & yodx<=2014
	replace pop1=177206 if yodx>=2015 & yodx<=2019
	*2. Create variable for general popln, by sex
	gen pop2=.
	label variable pop2 "Sex-stratified popl'n of St. Lucia at year-band of diagnosis"
	replace pop2=54063 if sex==1 & yodx>=1970 & yodx<=1979
	replace pop2=50091 if sex==2 & yodx>=1970 & yodx<=1979
	replace pop2=60281 if sex==1 & yodx>=1980 & yodx<=1989
	replace pop2=57698 if sex==2 & yodx>=1980 & yodx<=1989
	replace pop2=70332 if sex==1 & yodx>=1990 & yodx<=1999
	replace pop2=67848 if sex==2 & yodx>=1990 & yodx<=1999
	replace pop2=80086 if sex==1 & yodx>=2000 & yodx<=2004
	replace pop2=76859 if sex==2 & yodx>=2000 & yodx<=2004
	replace pop2=83616 if sex==1 & yodx>=2005 & yodx<=2009
	replace pop2=80094 if sex==2 & yodx>=2005 & yodx<=2009
	replace pop2=87890 if sex==1 & yodx>=2010 & yodx<=2014
	replace pop2=84684 if sex==2 & yodx>=2010 & yodx<=2014
	replace pop2=90395 if sex==1 & yodx>=2015 & yodx<=2019
	replace pop2=86812 if sex==2 & yodx>=2015 & yodx<=2019
	*3. Group year of diagnosis
	gen godx = 1 if yodx>=1970 & yodx<=1979
	replace godx = 2 if yodx>=1980 & yodx<=1989
	replace godx = 3 if yodx>=1990 & yodx<=1999
	replace godx = 4 if yodx>=2000 & yodx<=2004
	replace godx = 5 if yodx>=2005 & yodx<=2009
	replace godx = 6 if yodx>=2010 & yodx<=2014
	replace godx = 7 if yodx>=2015 & yodx<=2019
	label variable godx "Group of diagnosis (by year)"
	label define godx 1 "1970-79" 2 "1980-89" 3 "1990-99" 4 "2000-04" 5 "2005-09" 6 "2010-14" 7 "2015-19"
	label values godx godx
	*4. Collapse year of diagnoses into year-bands
	drop if sex==2
	gen k=1
	collapse (sum) k, by(godx pop1 pop2)
	sort godx
	gen ir=.
	replace ir=(k/(pop2*10))*100000 if godx<=3
	replace ir=(k/(pop2*5))*100000 if godx>=4 & godx<=6
	replace ir=(k/(pop2*3.33))*100000 if godx==7
	gen pop3=pop2
	replace pop3=(pop2*10) if godx<=3
	replace pop3=(pop2*5) if godx>=4 & godx<=6
	replace pop3= (pop2*3.33) if godx==7
	*IH used "cii prop" command to calculate the confidence intervals for these
restore

	** Overall IR
preserve
	gen country = 1
	drop if sex==2
	*male population
	*gen pop2 = 50091*10 + 57698*10 + 67848*10 + 76859*5 + 80094*5 + 84684*5 + 86812*3.33
	*female population
	gen pop2 = 54063*10 + 60281*10 + 70332*10 + 80086*5 + 83616*5 + 87890*5 + 90395*3.33
	collapse (sum) country, by(pop2)
	gen irc=(country/(pop2))*100000
restore

** Overall IR since 2010
preserve
	keep if yodx>=2010
	drop if sex==2
	gen country = 1
	gen pop3 = 84684*5 + 86812*3.33
	collapse (sum) country, by(pop3)
	gen irc=(country/(pop3))*100000
restore

*Figure 1b: Calculate relative incidence by district (using 2016 CMO report for district popl'n)
preserve
	gen dpop=.
	replace dpop=6211 if district==1
	replace dpop=6343 if district==2
	replace dpop=1021 if district==3
	replace dpop=25536 if district==4
	replace dpop=3346 if district==5
	replace dpop=6455 if district==6
	replace dpop=13675 if district==7
	replace dpop=4031 if district==8
	replace dpop=8172 if district==9
	replace dpop=4169 if district==10
	replace dpop=8271 if district==11

	*4. Collapse year of diagnoses into districts
	drop if sex==2
	gen k=1
	collapse (sum) k, by(district dpop)
	sort district
	gen ir=.
	replace ir=(k/(dpop*48))*100000
	gen dpop1=dpop
	replace dpop1=(dpop*48)
	gsort -ir

	*IH used "cii prop" command to calculate the confidence intervals for these
restore

*/

** -------------------------------------------
** 20-AUG-2018
** FINAL ad-hoc percentages
** -------------------------------------------

** 1. % on dialysis who were non-adherent
tab dial
tab adh
tab dial adh, row

** 2. % hypertensive
tab htn

** 3. % diabetic
tab dm

** 4. % with dyslipidemia
tab lipid

** 5. % with obesity
mark ob1 if bmi1>=30 & bmi1<.
replace ob1 = . if bmi1==.
mark ov1 if bmi1>=25 & bmi1<.
replace ov1 = . if bmi1==.
tab ob1
tab ov1
mark ob2 if bmi2>=30 & bmi2<.
replace ob2 = . if bmi2==.
mark ov2 if bmi2>=25 & bmi2<.
replace ov2 = . if bmi2==.
tab ob2
tab ov2

** 6. % patients with nephritis and dialysis who also are:
**		A. Hypertensive
tab dial htn, row
**		B. Diabetic
tab dial dm, row
**		C. Dyslipidemic
tab dial lipid, row
**		D. Obese
tab dial ob2, row
**		E. All of the above
gen call = 0
replace call = 1 if htn==1 & dm==1 & lipid==1 & ob2==1
tab dial call, row



/*
** WORKING NOTES (To be ignored)
*Table 1: Calculate overall incidence (1970 - 2018)
	*Code changed in appropriate section

*Table 1 (?): Calculate average time it took to get diagnosed (years from symptoms to diagnosis)
	summarize sym2dx, detail

*Table 2a: Recalculate renal biopsy as % of people with nephritis who had renal biopsy
	*Code changed in appropriate section

*Table 3b: Label existing "% Overweight or obese" as "% Overweight or obese at last follow up"; and calculate "% Overweight or obese at presentation"
	*Code changed in appropriate section

*After Table 4a (in text perhaps): calculate % who did the self-help program
	*Code changed in appropriate section

*Nephritis data is incorrect. This affects Fig 2A-2D, Figure 4, Table 2a (Renal biopsy), Table 3c, Table 5a. Need to rerun.

*Regression figure (CH has her own dofile): Need to have each predictor have a different symbol (abstract is monochromatic).

*/

** For appendices - tablulating SLE criteria

codebook acr
gen acrg=.
replace acrg=1 if acr<=5
replace acrg=2 if acr==6 | acr==7
replace acrg=3 if acr==8 | acr==9
replace acrg=4 if acr==10 | acr==11
label variable acrg "Person meets ACR criteria, by group"
label define acrg 1 "meets <=5 ACR criteria" 2 "meets 6-7 ACR criteria" 3 "meets 8-9 ACR criteria" 4 "meets 10-11 ACR criteria"
label values acrg acrg
tab acrg
prop acrg

codebook slicc
gen sliccg=.
replace sliccg=1 if slicc<=5
replace sliccg=2 if slicc==6 | slicc==7
replace sliccg=3 if slicc==8 | slicc==9
replace sliccg=4 if slicc==10 | slicc==11
replace sliccg=5 if slicc==12 | slicc==13
replace sliccg=6 if slicc==14 | slicc==15
replace sliccg=7 if slicc==16 | slicc==17
label variable sliccg "Person meets SLICC criteria, by group"
label define sliccg 1 "meets <=5 SLICC criteria" 2 "meets 6-7 SLICC criteria" 3 "meets 8-9 SLICC criteria" 4 "meets 10-11 SLICC criteria" 5 "meets 12-13 SLICC criteria" 6 "meets 14-15 SLICC criteria" 7 "meets 16-17 SLICC criteria"
label values sliccg sliccg
tab sliccg
prop sliccg
