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

** MORTALITY RATES
** 16-AUG-2018
** 13 people have died - across the full time frame
** Full time frame had XX person years

	** Overall MR
preserve
	gen dead = 0
    replace dead = 1 if alive==0
	drop if sex==2
	*male population
	*gen pop2 = 50091*10 + 57698*10 + 67848*10 + 76859*5 + 80094*5 + 84684*5 + 86812*3.33
	*female population
	gen pop2 = 54063*10 + 60281*10 + 70332*10 + 80086*5 + 83616*5 + 87890*5 + 90395*3.33
	collapse (sum) dead, by(pop2)
	gen mrc=(dead/(pop2))*100000
restore

** Survival RATES
** KEEP limited number of variables for ease
tempfile s1 s2 s3 s4
keep pid sex dob aad discount
gen yob = year(dob)
gen yod = yob+aad
gen mod = 01
gen dod = 01
gen date_diag = mdy(mod, dod, yod)
format date_diag %dD_m_CY
keep pid sex dob date_diag discount
sort pid
save `s1'

import excel using "`datapath'\version01\1-input\Lupus Database 2018_workingfile_v2_30-04-2018.xlsx", sheet("survival") first clear
drop LASTFU
rename ID pid
drop if pid==.
gen dlast = 1
gen mlast = 1 if mlast_str=="jan"
replace mlast = 2 if mlast_str=="feb"
replace mlast = 3 if mlast_str=="mar"
replace mlast = 4 if mlast_str=="apr"
replace mlast = 5 if mlast_str=="may"
replace mlast = 6 if mlast_str=="jun"
replace mlast = 7 if mlast_str=="jul"
replace mlast = 8 if mlast_str=="aug"
replace mlast = 9 if mlast_str=="sep"
replace mlast = 10 if mlast_str=="oct"
replace mlast = 11 if mlast_str=="nov"
replace mlast = 12 if mlast_str=="dec"
gen date_last = mdy(mlast, dlast, ylast)
format date_last %dD_m_CY
keep pid date_last

** Dates of death
** JL 18/11/14
** VJ 20/04/2015
** SJ 17/03/2016
** TR 13/04/2009
** LM 05/09/08
** MA 26/12/2009
** BA 3/11/16
** LB 01/07/15
** FH 03/11/07
** LV 24/08/2012
** SS 30/07/2014
** AR 11/11/2012
** C.F 11/11/2013
gen date_death = .
replace date_death = d(26dec2009) if pid==7
replace date_death = d(03nov2016) if pid==10
replace date_death = d(01jul2015) if pid==17
replace date_death = d(11nov2013) if pid==48
replace date_death = d(03nov2007) if pid==65
replace date_death = d(17mar2016) if pid==75
replace date_death = d(20apr2015) if pid==80
replace date_death = d(18nov2014) if pid==92
replace date_death = d(05sep2008) if pid==100
replace date_death = d(13apr2009) if pid==121
replace date_death = d(11nov2012) if pid==122
replace date_death = d(30jul2014) if pid==129
replace date_death = d(24aug2012) if pid==143
format date_death %dD_m_CY

gen status = 0
#delimit ;
    replace status = 1 if   pid==7 | pid==10 | pid==17 |
                            pid==48 | pid==65 | pid==75 |
                            pid==80 | pid==92 | pid==100 |
                            pid==121 | pid==122 | pid==129 | pid==143;
#delimit cr
replace date_last = date_death if date_death<.
drop date_death
sort pid
merge 1:1 pid using `s1'
keep if _merge==3
drop _merge
order pid sex status dob date_diag date_last discount


** Age at diagnosis (months / years)
gen aad1 = int((date_diag - dob)/30.4375)
gen aad2 = int((date_diag - dob)/365.25)
** Age at last visit (months / years)
gen aal1 = int((date_last - dob)/30.4375)
gen aal2 = int((date_last - dob)/365.25)


** stset aal2, failure(status) origin(aad2)
stset date_last, id(pid) fail(status=1) origin(time date_diag) scale(365.25)
sts test discount
sts list

#delimit ;
sts gr  , by(discount)
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
	name(figX, replace)
	;
#delimit cr

streg i.discount i.sex, d(weibull) hr
#delimit ;
	stcurve, surv at1(discount=0) at2(discount=1) lp("l" "-") lc(gs0 gs8)
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
	name(FigY, replace)
	;
#delimit cr

/*
** NOT USED

**regression 1: Cerebritis (y/n); Predictors: sex, age, duration of diagnosis, education, occupation, discount, adherence
logistic cereb sex age i.educ2
logistic cereb sex age discount
logistic cereb i.sex age dx2now i.educ2 i.occ_grade1 discount adh


**regression 3:	Dialysis (y/n); Predictors: sex, age, duration of diagnosis, education, occupation, discount, adherence
logistic dial sex age i.educ2
logistic dial sex age discount
logistic dial i.sex age dx2now i.educ2 i.occ_grade1 discount adh
logistic dial sex age dx2now educ2 occ_grade1 discount adh
