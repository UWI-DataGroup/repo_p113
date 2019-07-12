** HEADER -----------------------------------------------------
**  DO-FILE METADATA
//  algorithm name			lupus_lca_regressions.do
//  project:						Epidemiology of Lupus in ST.Lucia
//  analysts:						Ian HAMBLETON
//	date last modified	15-Aug-2018
//  algorithm task			Regressions

** General algorithm set-up
version 15
clear all
macro drop _all
set more 1
set linesize 80

** Set working directories: this is for DATASET and LOGFILE import and export
** DATASETS to encrypted SharePoint folder
local datapath "X:\The University of the West Indies\DataGroup - repo_data\data_p113\"
** LOGFILES to unencrypted OneDrive folder
local logpath X:\OneDrive - The University of the West Indies\repo_datagroup\repo_p113

** Close any open log fileand open a new log file
capture log close
cap log using "`logpath'\lupus_lca_regressions", replace
** HEADER -----------------------------------------------------

*import data
use "`datapath'\version01\2-working\lupus_lca_april2018_v3.dta", clear

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


/*
**regression 1: Severity  (y/n): Predictors: sex, age, duration of diagnosis, education, occupation, discount, adherence
logistic sev age
logistic sev sex
logistic sev dx2now
logistic sev acr
logistic sev slicc
logistic sev sex age dx2now educ2
logistic sev sex age dx2now discount
logistic sev sex age dx2now self2
logistic sev sex age dx2now adh2
** logistic sev i.sex age dx2now i.educ2 i.occ_grade1 discount adh
** logistic sev sex age dx2now educ2 occ_grade1 discount adh


**regression 2: Adherence (y/n); Predictors: sex, age, duration of diagnosis, education, occupation, discount
logistic adh2 age
logistic adh2 sex
logistic adh2 dx2now
logistic adh2 acr
logistic adh2 slicc
logistic adh2 sex age dx2now educ2
logistic adh2 sex age dx2now discount
logistic adh2 sex age dx2now self2
** logistic adh2 sex age dx2now educ2 i.occ_grade1 discount
** logistic adh2 sex age dx2now educ2 occ_grade1 discount



*/

** Survival RATES
** KEEP limited number of variables for ease
tempfile s1 s2 s3 s4
keep pid sex dob aad discount adh2 educ2 occ_grade1 sev self2
gen yob = year(dob)
gen yod = yob+aad
gen mod = 01
gen dod = 01
gen date_diag = mdy(mod, dod, yod)
format date_diag %dD_m_CY
keep pid sex dob date_diag discount adh2 educ2 occ_grade1 sev self2
sort pid
save `s1'

** 17-MAR-2019
** We import a new survival dataset created by Cleo Altenor in early March
** This new file records accurate DoB and Date of last visit to clinic
** Study End = 31-Mar-2019. DOLV must therefore be backdated 
import excel using "`datapath'\version01\1-input\20190317_lupus_entry_final.xlsx", sheet("irh_prepared") first clear
drop N name1 name2 
rename id pid
rename sex sex_str 
drop if pid==.

** Convert month from string to numeric
rename last_visit_month t1
gen last_visit_month = 1 if t1=="jan"
replace last_visit_month = 2 if t1=="feb"
replace last_visit_month = 3 if t1=="mar"
replace last_visit_month = 4 if t1=="apr"
replace last_visit_month = 5 if t1=="may"
replace last_visit_month = 6 if t1=="jun"
replace last_visit_month = 7 if t1=="jul"
replace last_visit_month = 8 if t1=="aug"
replace last_visit_month = 9 if t1=="sep"
replace last_visit_month = 10 if t1=="oct"
replace last_visit_month = 11 if t1=="nov"
replace last_visit_month = 12 if t1=="dec"
drop t1

** Date of last visit to clinic / date of death
gen date_last = mdy(last_visit_month, last_visit_day, last_visit_year)
format date_last %dD_m_CY

** Date of diagnosis
gen date_diag = mdy(diag_month, diag_day, diag_year)
format date_diag %dD_m_CY

sort pid
merge 1:1 pid using `s1'
keep if _merge==3
drop _merge
order pid sex sex_str alive dob date_diag date_last discount
drop sex_str diag_* last_*

** Fix 1 DOB
replace dob = d(26nov1983) if pid==73 & dob==. 
** Age at diagnosis (months / years)
gen aad1 = int((date_diag - dob)/30.4375)
gen aad2 = int((date_diag - dob)/365.25)
** Age at last visit (months / years)
gen aal1 = int((date_last - dob)/30.4375)
gen aal2 = int((date_last - dob)/365.25)


** stset aal2, failure(status) origin(aad2)
stset date_last, id(pid) fail(alive=0) origin(time date_diag) scale(365.25)

** K-M estimates
sts list

** Treatment discount (0=no, 1=yes)
sts test discount
** Treatment adherence (0 "Current adherent" 1 "Current non-adherent")
sts test adh2 
** Education (1 "tertiary" 2 "secondary")
sts test educ2 
** Occupation (1 "Routine/manual" 2 "Intermediate" 3 "Professional" 4 "Not in employment")
sts test occ_grade1 
** Severity (1 "Severe" 0 "Not severe")
sts test sev 
** Self-help programme (0 "Done programme" 1 "Not done programme")
sts test self2
** sts list

** K-M descriptive chart
#delimit ;
sts gr  , by(sev)
	graphregion(fcolor(gs16) icolor(gs16) )
	plotregion(fcolor(gs16) icolor(gs16) )
	ysize(4) xsize(3)

    plot1opts(lp("l") lw(medium) lc(gs0) )
    plot2opts(lp("-") lw(medium) lc(gs8) )

	xtitle("Age (years)", size(large) margin(t=3))
    xlab(, labs(large) nogrid glc(gs13)) xscale(lw(vthin) range(0(5)45))
	xtick(0(5)45)
	xmtick(0(2.5)45)

    ylab(0(0.2)1,labs(large) nogrid glc(gs13) angle(0) format(%9.1f)) yscale(lw(vthin))
	ytitle("Proportion alive", size(large) margin(r=3))
	///ymtick(0(0.1)1)

	/// addplot(line p_st t_st, sort lp("-") lc(gs0) || line p_ma t_ma, sort lp("-") lc(gs0))
	///text(0.62 41 "Any", place(e) size(*1.0))
	title("")
    legend(off)
	name(severity_KM, replace)
	;
#delimit cr

** WEIBULL: DISCOUNT by SEX
streg i.sev i.sex, d(weibull) hr
#delimit ;
	stcurve, surv at1(sev=0) at2(sev=1) lp("l" "-") lc(gs0 gs8)
	graphregion(fcolor(gs16) icolor(gs16) )
	plotregion(fcolor(gs16) icolor(gs16) )
	ysize(4) xsize(3)

    xlab(, labs(large) nogrid glc(gs13)) xscale(lw(vthin) range(0(5)45))
	xtitle("Age (years)", size(large) margin(t=3))
	xtick(0(5)45)
	xmtick(0(2.5)45)

    ylab(0(0.2)1,labs(large) nogrid glc(gs13) angle(0) format(%9.1f)) yscale(lw(vthin))
	ytitle("Proportion alive", size(large) margin(r=3))
	ymtick(0.4(0.05)1)

	legend(off size(medium) position(6) bm(t=1 b=0 l=0 r=0) colf cols(2)
	region(fcolor(gs16) lw(vthin) margin(l=2 r=2 t=2 b=2)) order(1 2)
	lab(1 "No Discount")
	lab(2 "Discount")
	)
	name(severity_weibull, replace)
	;
#delimit cr

** K-M descriptive chart
#delimit ;
sts gr  , by(adh)
	graphregion(fcolor(gs16) icolor(gs16) )
	plotregion(fcolor(gs16) icolor(gs16) )
	ysize(4) xsize(3)

    plot1opts(lp("l") lw(medium) lc(gs0) )
    plot2opts(lp("-") lw(medium) lc(gs8) )

	xtitle("Age (years)", size(large) margin(t=3))
    xlab(, labs(large) nogrid glc(gs13)) xscale(lw(vthin) range(0(5)45))
	xtick(0(5)45)
	xmtick(0(2.5)45)

    ylab(0(0.2)1,labs(large) nogrid glc(gs13) angle(0) format(%9.1f)) yscale(lw(vthin))
	ytitle("Proportion alive", size(large) margin(r=3))
	///ymtick(0(0.1)1)

	/// addplot(line p_st t_st, sort lp("-") lc(gs0) || line p_ma t_ma, sort lp("-") lc(gs0))
	///text(0.62 41 "Any", place(e) size(*1.0))
	title("")
    legend(off)
	name(adherence_KM, replace)
	;
#delimit cr

** WEIBULL: ADHERENCE by SEX
streg i.adh2 i.sex, d(weibull) hr
#delimit ;
	stcurve, surv at1(adh2=0) at2(adh2=1) lp("l" "-") lc(gs0 gs8)
	graphregion(fcolor(gs16) icolor(gs16) )
	plotregion(fcolor(gs16) icolor(gs16) )
	ysize(4) xsize(3)

    xlab(, labs(large) nogrid glc(gs13)) xscale(lw(vthin) range(0(5)45))
	xtitle("Age (years)", size(large) margin(t=3))
	xtick(0(5)45)
	xmtick(0(2.5)45)

    ylab(0(0.2)1,labs(large) nogrid glc(gs13) angle(0) format(%9.1f)) yscale(lw(vthin))
	ytitle("Proportion alive", size(large) margin(r=3))
	ymtick(0.4(0.05)1)

	legend(off size(medium) position(6) bm(t=1 b=0 l=0 r=0) colf cols(2)
	region(fcolor(gs16) lw(vthin) margin(l=2 r=2 t=2 b=2)) order(1 2)
	lab(1 "Adherent")
	lab(2 "Not Adherent")
	)
	name(adherence_weibull, replace)
	;
#delimit cr
