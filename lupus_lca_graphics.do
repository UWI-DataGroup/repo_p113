* HEADER -----------------------------------------------------
**  DO-FILE METADATA
//  algorithm name			lupus_lca_graphics.do
//  project:						Epidemiology of Lupus in ST.Lucia
//  analysts:						Ian HAMBLETON
//	date last modified	15-Aug-2018
//  algorithm task			Graphics

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
cap log using "`logpath'\lupus_lca_graphics", replace
** HEADER -----------------------------------------------------



** Load the unprepared 2018 dataset
use "`datapath'\version01\2-working\lupus_lca_april2018_v3.dta", clear

** STATISTICS TO ACCOMPANY GRAPHICS ON PPTX SLIDES


** Grouped year of diagnosis
gen godx = 1 if yodx>=1970 & yodx<=1979
replace godx = 2 if yodx>=1980 & yodx<=1989
replace godx = 3 if yodx>=1990 & yodx<=1999
replace godx = 4 if yodx>=2000 & yodx<=2004
replace godx = 5 if yodx>=2005 & yodx<=2009
replace godx = 6 if yodx>=2010 & yodx<=2014
replace godx = 7 if yodx>=2015 & yodx<=2019
label define godx 1 "1970-79" 2 "1980-89" 3 "1990-99" 4 "2000-04" 5 "2005-09" 6 "2010-14" 7 "2015-19"
label values godx godx


** FIGURE 1.
** Numbers of SLE cases by Year of Diagnosis
preserve
	gen k=1
	collapse (sum) k, by(godx)
	#delimit ;
	graph twoway
		(bar k godx ,horizontal barw(0.75) lc("0 114 198") fc("0 114 198"))
		///(line loc2 aref2, lp("-") lc(gs0) lw(medium))
		,
		plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin))
		graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin))
		ysize(7)
		yscale(reverse noline)

		xlab(0(10)50,
		labs(medsmall) nogrid glc(gs14) angle(0) labgap(3))
		xscale(lw(vthin)) xtitle("Number of participants diagnosed", margin(t=2) size(medsmall))
		xmtick(0(5)50)

		ylab(1 "1970-79" 2 "1980-89" 3 "1990-99" 4 "2000-04" 5 "2005-09" 6 "2010-14" 7 "2015-19",
		labs(medium) notick nogrid glc(gs14) angle(0) format(%9.0f))
		ytitle("", margin(r=3) size(large))
		yscale(lw(vthin) fill)

		///text(0.7 10.0 "10.0", place(c) size(medium))

		legend(off size(small) position(12) bm(t=1 b=0 l=0 r=0) colf cols(2)
		region(fcolor(gs16) lw(vthin) margin(l=2 r=2 t=2 b=2))
		)
		name(figure1);
	#delimit cr
restore

** FIGURE 1
** numbers in dataset by year of diagnosis
count
count if yodx>=2000
count if yodx>=2005
count if yodx>=2010
count if yodx>=2015



** FIGURE 2.
** Numbers of SLE cases by St.Lucia districts
preserve
	gen k=1
	collapse (sum) k, by(district)
	gsort -k
	gen order1 = _n
	decode district , gen(district_string)
	labmask order1, values(district_string)

	#delimit ;
	graph twoway
		(bar k order1 ,horizontal barw(0.75) lc("0 114 198") fc("0 114 198"))
		,
		plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin))
		graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin))
		ysize(7)
		yscale(reverse noline)

		xlab(0(10)50,
		labs(medsmall) nogrid glc(gs14) angle(0) labgap(3))
		xscale(lw(vthin)) xtitle("Number of participants diagnosed", margin(t=2) size(medsmall))
		xmtick(0(5)50)

		ylab(1(1)11,
		valuelabel labs(medium) notick nogrid glc(gs14) angle(0) format(%9.0f))
		ytitle("", margin(r=3) size(large))
		yscale(lw(vthin) fill)

		///text(0.7 10.0 "10.0", place(c) size(medium))

		legend(off size(small) position(12) bm(t=1 b=0 l=0 r=0) colf cols(2)
		region(fcolor(gs16) lw(vthin) margin(l=2 r=2 t=2 b=2))
		)
		name(figure2);
	#delimit cr
restore

** FIGURE 2
** Numbers by district
tabsort district



** FIGURE 3.
** Adherence by SEP (for which we use education)
** Staked bar chart

** Group the adherence variable into x2 categories
recode adh 2=0 3=1

*Group education into 2 groups
gen educ2 = educ
recode educ2 1=2
label define educ2 2 "secondary" 3 "tertiary",modify
label values educ2 educ2

** Numbers in each educational group
preserve
	drop if educ2==. | adh==.
	bysort educ2: gen denom=_N
	gen prev = (1/denom)*100

	gen adh_rev = adh
	recode adh_rev 1=0 0=1
	label define adh_rev 0 "adherent" 1 "not adherent"
	label values adh_rev adh_rev

	#delimit ;
		gen prev1 = prev if adh_rev==0;
		gen prev2 = prev if adh_rev==1;

	graph hbar (sum) prev1 prev2 , stack
		    plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin))
		    graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin))
			ysize(4)

			over(educ2, gap(5))
			blabel(none, format(%9.0f) pos(outside) size(medsmall))

			bar(1, bc(green*0.65) blw(vthin) blc(gs0))
			bar(2, bc(red*0.65) blw(vthin) blc(gs0))

		   	ylab(0(20)100, nogrid glc(gs0)) yscale(noline range(1(5)45))
		    ytitle("Prevalence of medication adherence", margin(t=3) size(medium))
			ymtick(0(10)100)

			legend(size(medium) position(12) bm(t=0 b=5 l=0 r=0) colf cols(1)
			region(fcolor(gs16) lw(vthin) margin(l=1 r=1 t=1 b=1))
			lab(2 "not adherent")
			lab(1 "adherent")
			)
			name(figure3);
	#delimit cr
restore

** FIGURE 3
** Adherence by SEP
tab adh educ2
tab adh educ2, col nofreq




** FIGURE 4.
** Involvement in self-help programme by SEP (for which we use education)
** Stacked bar chart

** Numbers in each educational group
preserve
	drop if educ2==. | self==.
	bysort educ2: gen denom=_N
	gen prev = (1/denom)*100

	gen self_rev = self
	recode self_rev 1=0 0=1
	label define self_rev 0 "in self-help programme" 1 "not in self-help programme"
	label values self_rev self_rev

	#delimit ;
	gen prev1 = prev if self_rev==0;
	gen prev2 = prev if self_rev==1;

	graph hbar (sum) prev1 prev2 , stack
		    plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin))
		    graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin))
			ysize(4)

			over(educ2, gap(5))
			blabel(none, format(%9.0f) pos(outside) size(medsmall))

			bar(1, bc(green*0.65) blw(vthin) blc(gs0))
			bar(2, bc(red*0.65) blw(vthin) blc(gs0))

		   	ylab(0(20)100, nogrid glc(gs0)) yscale(noline range(1(5)45))
		    ytitle("Prevalence in self-help programme", margin(t=3) size(medium))
			ymtick(0(10)100)

			legend(size(medium) position(12) bm(t=0 b=5 l=0 r=0) colf cols(1)
			region(fcolor(gs16) lw(vthin) margin(l=1 r=1 t=1 b=1))
			lab(2 "not in self-help programme")
			lab(1 "in self-help programme")
			)
			name(figure4);
	#delimit cr
restore

** FIGURE 4
** Self-help by SEP
tab self educ2
tab self educ2, col nofreq



** FIGURE 5.
** Immonosuppresants (x4 of these) by SEP (for which we use education)
** Stacked bar chart
** NOTE: immunosuppressants taken (n=4: azathioprine, mycophenolate mofetil, cyclophosphamide, rituximab)
** NOTE: Rituximab only mentioned once in Excel comments - not used

** aza  --> azathioprine
** mmf  --> mycophenolate mofetil
** cyc  --> cyclophosphamide

** Count of number of current immunosuppressants
recode aza 2=0
recode mmf 2=0
recode cyc 2=0
gen imm = aza + mmf + cyc

** Numbers in each educational group
preserve
	drop if educ2==. | adh==.
	bysort educ2: gen denom=_N
	gen prev = (1/denom)*100

	#delimit ;
		gen prev1 = prev if imm==0;
		gen prev2 = prev if imm==1;
		gen prev3 = prev if imm==2;

	graph hbar (sum) prev1 prev2 prev3, stack
		    plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin))
		    graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin))
			ysize(4)

			over(educ2, gap(5))
			blabel(none, format(%9.0f) pos(outside) size(medsmall))

			bar(1, bc(green*0.65) blw(vthin) blc(gs0))
			bar(2, bc(orange) blw(vthin) blc(gs0))
			bar(3, bc(red*0.65) blw(vthin) blc(gs0))

		   	ylab(0(20)100, nogrid glc(gs0)) yscale(noline range(1(5)45))
		    ytitle("Prevalence of immunossuppreessant count (1 to 3)", margin(t=3) size(medium))
			ymtick(0(10)100)

			legend(size(medium) position(12) bm(t=0 b=5 l=0 r=0) colf cols(2)
			region(fcolor(gs16) lw(vthin) margin(l=1 r=1 t=1 b=1))
			lab(1 "0 drugs")
			lab(2 "1 drug")
			lab(3 "2 drugs")
			)
			name(figure5);
	#delimit cr
restore

** FIGURE 5
** Meds by SEP
tab imm educ2
tab imm educ2, col nofreq




** FIGURE 6a.
** SEVERITY COUNT by SEP (for which we use education)
** Stacked bar chart
** Severity defined dichotomously as
** SEVERE 		--> cerebritis OR nephritis OR dialysis
** NOT SEVERE 	--> NOT (cerebritis AND nephritis AND dialysis)
** cereb 	--> cerebritis
** neph 	--> nephritis
** dial		--> dialysis
drop if cereb==. | neph==. | 	 dial==.
gen sevc = cereb + neph + dial
recode sevc 3=2

** Numbers in each educational group
preserve
	drop if educ2==. | sevc==.
	bysort educ2: gen denom=_N
	gen prev = (1/denom)*100

	#delimit ;
		gen prev1 = prev if sev==0;
		gen prev2 = prev if sev==1;
		gen prev3 = prev if sev==2;

	graph hbar (sum) prev1 prev2 prev3 , stack
		    plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin))
		    graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin))
			ysize(4)

			over(educ2, gap(5))
			blabel(none, format(%9.0f) pos(outside) size(medsmall))

			bar(1, bc(green*0.65) blw(vthin) blc(gs0))
			bar(2, bc(orange) blw(vthin) blc(gs0))
			bar(3, bc(red*0.65) blw(vthin) blc(gs0))

		   	ylab(0(20)100, nogrid glc(gs0)) yscale(noline range(1(5)45))
		    ytitle("Prevalence of complications (count)", margin(t=3) size(medium))
			ymtick(0(10)100)

			legend(size(medium) position(12) bm(t=0 b=5 l=0 r=0) colf cols(2)
			region(fcolor(gs16) lw(vthin) margin(l=1 r=1 t=1 b=1))
			lab(1 "0 complications")
			lab(2 "1 complication")
			lab(3 "2+ complications")
			)
			name(figure6a);
	#delimit cr
restore

** FIGURE 6
** Symptoms by SEP
tab sevc educ2
tab sevc educ2, col nofreq




** FIGURE 6b.
** SEVERITY COUNT by SEP (for which we use education)
** Stacked bar chart
** Severity defined dichotomously as
** SEVERE 		--> cerebritis OR nephritis OR dialysis
** NOT SEVERE 	--> NOT (cerebritis AND nephritis AND dialysis)
** cereb 	--> cerebritis
** neph 	--> nephritis
** dial		--> dialysis
drop if cereb==. | neph==. | dial==.
gen sevi = 0
replace sevi = 1 if cereb==1 | neph==1 | dial==1

** Numbers in each educational group
preserve
	drop if educ2==. | sevi==.
	bysort educ2: gen denom=_N
	gen prev = (1/denom)*100

	#delimit ;
		gen prev1 = prev if sevi==0;
		gen prev2 = prev if sevi==1;

	graph hbar (sum) prev1 prev2 , stack
		    plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin))
		    graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin))
			ysize(4)

			over(educ2, gap(5))
			blabel(none, format(%9.0f) pos(outside) size(medsmall))

			bar(1, bc(green*0.65) blw(vthin) blc(gs0))
			bar(2, bc(red*0.65) blw(vthin) blc(gs0))

		   	ylab(0(20)100, nogrid glc(gs0)) yscale(noline range(1(5)45))
		    ytitle("Prevalence of complications (indicator)", margin(t=3) size(medium))
			ymtick(0(10)100)

			legend(size(medium) position(12) bm(t=0 b=5 l=0 r=0) colf cols(1)
			region(fcolor(gs16) lw(vthin) margin(l=1 r=1 t=1 b=1))
			lab(1 "not severe")
			lab(2 "severe")
			)
			name(figure6b);
	#delimit cr
restore

** FIGURE 6b
** Symptoms by SEP
tab sevi educ2
tab sevi educ2, col nofreq




** FIGURE 7a.
** SEVERITY by DISCOUNT
** Stacked bar chart

** Numbers in each educational group
preserve
	drop if discount==. | sevc==.
	bysort discount: gen denom=_N
	gen prev = (1/denom)*100

	gen discount_rev = discount
	recode discount_rev 1=0 0=1
	label define discount_rev 1 "no discount" 0 "discount", modify
	label values discount_rev discount_rev

	#delimit ;
	gen prev1 = prev if sevc==0;
	gen prev2 = prev if sevc==1;
	gen prev3 = prev if sevc==2;

	graph hbar (sum) prev1 prev2 prev3 , stack
		    plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin))
		    graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin))
			ysize(4)

			over(discount_rev, gap(5))
			blabel(none, format(%9.0f) pos(outside) size(medsmall))

			bar(1, bc(green*0.65) blw(vthin) blc(gs0))
			bar(2, bc(orange) blw(vthin) blc(gs0))
			bar(3, bc(red*0.65) blw(vthin) blc(gs0))

		   	ylab(0(20)100, nogrid glc(gs0)) yscale(noline range(1(5)45))
		    ytitle("Prevalence of complications (count)", margin(t=3) size(medium))
			ymtick(0(10)100)

			legend(size(medium) position(12) bm(t=0 b=5 l=0 r=0) colf cols(2)
			region(fcolor(gs16) lw(vthin) margin(l=1 r=1 t=1 b=1))
			lab(1 "0 complications")
			lab(2 "1 complication")
			lab(3 "2+ complications")
			)
			name(figure7a);
	#delimit cr
restore

** FIGURE 7a
** Symptoms by SEP
tab sevc discount
tab sevc discount, col nofreq





** FIGURE 7b.
** SEVERITY by DISCOUNT
** Stacked bar chart

** Numbers in each educational group
preserve
	drop if discount==. | sevi==.
	bysort discount: gen denom=_N
	gen prev = (1/denom)*100

	gen discount_rev = discount
	recode discount_rev 1=0 0=1
	label define discount_rev 1 "no discount" 0 "discount", modify
	label values discount_rev discount_rev

	#delimit ;
	gen prev1 = prev if sevi==0;
	gen prev2 = prev if sevi==1;

	graph hbar (sum) prev1 prev2 , stack
		    plotregion(c(gs16) ic(gs16) ilw(thin) lw(thin))
		    graphregion(color(gs16) ic(gs16) ilw(thin) lw(thin))
			ysize(4)

			over(discount_rev, gap(5))
			blabel(none, format(%9.0f) pos(outside) size(medsmall))

			bar(1, bc(green*0.65) blw(vthin) blc(gs0))
			bar(2, bc(red*0.65) blw(vthin) blc(gs0))

		   	ylab(0(20)100, nogrid glc(gs0)) yscale(noline range(1(5)45))
		    ytitle("Prevalence of complications (indicator)", margin(t=3) size(medium))
			ymtick(0(10)100)

			legend(size(medium) position(12) bm(t=0 b=5 l=0 r=0) colf cols(1)
			region(fcolor(gs16) lw(vthin) margin(l=1 r=1 t=1 b=1))
			lab(1 "not severe")
			lab(2 "severe")
			)
			name(figure7b);
	#delimit cr
restore

** FIGURE 7b
** Symptoms by SEP
tab sevi discount
tab sevi discount, col nofreq
