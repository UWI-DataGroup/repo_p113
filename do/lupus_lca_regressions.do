** CHANGE THIS FOR RE-RUN ON NEW COMPUTER	
    cd "C:\Users\Christina\Google Drive\Christina_work\Projects\stlucia_lupus"

** CLOSE ANY OPEN LOG FILE AND OPEN A NEW LOG FILE
	capture log close
	log using stlucia_lupus_v1, replace

**  GENERAL DO-FILE COMMENTS
//  project:      St Lucia Lupus
//  author:       Christina Howitt 16-Apr-18
//  description:  This do-file has been created to carry out the regression analyses for the St Lucia lupus analysis
	
** DO-FILE SECTION 00
** DO-FILE SET UP COMMANDS
version 14.2
clear all
	
*import data 
use lupus_lca_april2018.dta, clear

numlabel, add mask ("#",)

**PREPARE VARIABLES
codebook cereb
codebook dx2now
codebook educ
codebook discount
tab discount, miss

** Group the adherence variable into x2 categories
recode adh 2=0 3=1
tab adh
gen adh2 =.
replace adh2=0 if adh==1
replace adh2=1 if adh==0
label define adh2 0 "Current adherent" 1 "Current non-adherent"
label values adh2 adh2

*Group education into 2 groups
tab educ
gen educ2 = educ
recode educ2 1=2 3=1
label define educ2 1 "tertiary" 2 "secondary",modify
label values educ2 educ2
tab educ2

*occupation groups
gen occ_grade1 =.
replace occ_grade1 = 1 if occ == 6 | occ == 7 | occ ==8 | occ==9
replace occ_grade1 = 2 if occ == 3 | occ == 4 | occ ==5
replace occ_grade1 = 3 if occ ==1 | occ ==2
replace occ_grade1 = 4 if occ ==0
label variable occ_grade1 "occupation grade"
label define occ_grade1 1 "Routine/manual" 2 "Intermediate" 3 "Professional" 4 "Not in employment"
label values occ_grade1 occ_grade1

*severity: Severity = Cerebritis OR Nephritis OR Dialysis
tab cereb, miss
tab neph, miss
tab dial, miss
gen sev=0
replace sev=1 if cereb==1 | neph==1 | dial==1
tab sev, miss
label define sev 1 "Severe" 0 "Not severe"
label values sev sev


*recode self-help so that higher category is bad
gen self2 =.
replace self2=0 if self==1
replace self2=1 if self==0
label define self2 0 "Done programme" 1 "Not done programme"
label values self2 self2 



**regression 2: Severity  (y/n): Predictors: sex, age, duration of diagnosis, education, occupation, discount, adherence
logistic sev sex age dx2now educ2
logistic sev sex age dx2now discount
logistic sev sex age dx2now self2
logistic sev sex age dx2now adh2
logistic sev i.sex age dx2now i.educ2 i.occ_grade1 discount adh
logistic sev sex age dx2now educ2 occ_grade1 discount adh


**regression 4: Adherence (y/n); Predictors: sex, age, duration of diagnosis, education, occupation, discount
logistic adh2 sex age dx2now educ2
logistic adh2 sex age dx2now discount
logistic adh2 sex age dx2now self2
logistic adh2 sex age dx2now educ2 i.occ_grade1 discount 
logistic adh2 sex age dx2now educ2 occ_grade1 discount 



/** CLOSE LOG FILE AND END THE DO-FILE
log close
exit

**regression 1: Cerebritis (y/n); Predictors: sex, age, duration of diagnosis, education, occupation, discount, adherence
logistic cereb sex age i.educ2
logistic cereb sex age discount
logistic cereb i.sex age dx2now i.educ2 i.occ_grade1 discount adh


**regression 3:	Dialysis (y/n); Predictors: sex, age, duration of diagnosis, education, occupation, discount, adherence
logistic dial sex age i.educ2
logistic dial sex age discount
logistic dial i.sex age dx2now i.educ2 i.occ_grade1 discount adh
logistic dial sex age dx2now educ2 occ_grade1 discount adh

