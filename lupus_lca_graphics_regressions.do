* HEADER -----------------------------------------------------
**  DO-FILE METADATA
//  algorithm name			lupus_lca_graphics_regressions.do
//  project:						Epidemiology of Lupus in ST.Lucia
//  analysts:						Ian HAMBLETON
//	date last modified	15-Aug-2018
//  algorithm task			Graphics from regression outputs

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
cap log using "`logpath'\lupus_lca_graphics_regressions", replace
** HEADER -----------------------------------------------------

***input data
clear
input yind outcome pred or ll ul
2	1	1	1.74	0.83	3.62
3	1	2	3.45	1.52	7.83
4	1	3	1.23	0.39	3.90
5	1	4	1.45	0.71	2.97
8	2	1	2.68	1.27	5.67
9	2	2	2.36	1.07	5.23
10	2	3	3.42	0.87	13.39
end

label define pred 1 "Education" 2 "Discount" 3 "Self-help" 4 "Medication adherence"
label values pred pred



**graphic
#delimit ;
	gr twoway

		  (rcap ll ul yind if pred==1, horizontal lc(dknavy) fc(dknavy) lw(medium) msize(medium))
		  (sc yind  or if pred==1, m(d) mfc(dknavy) mlc(dknavy) msize(4))

		  (rcap ll ul yind if pred==2, horizontal lc(emidblue) fc(emidblue) lw(medium) msize(medium))
		  (sc yind  or if pred==2, m(d) mfc(emidblue) mlc(emidblue) msize(4))

		  (rcap ll ul yind if pred==3, horizontal lc(ebblue) fc(ebblue) lw(medium) msize(medium))
		  (sc yind  or if pred==3, m(d) mfc(ebblue) mlc(ebblue) msize(4))

		  (rcap ll ul yind if pred==4, horizontal lc(eltblue) fc(eltblue) lw(medium) msize(medium))
		  (sc yind  or if pred==4, m(d) mfc(eltblue) mlc(eltblue) msize(4))
		  ,
			plotregion(c(gs16) lw(vthin) ic(gs16) ilw(vthin) )
			graphregion(color(gs16) ic(gs16) ilw(vthin) lw(vthin))
			ysize(7.5) xsize(5)

			xtitle("Odds ratios", margin(t=4) size(medlarge))
			xscale (log)
			xlab (0.5 1 2 4 8 16)

			ylab( 1 " ",
			labs(medium) notick nogrid glc(gs14) angle(0) format(%9.0f))
			ytitle("", margin(r=3) size(large))
			yscale(noline reverse lw(none) range(0.5(0.5)11) fill)

			/// Added text and lines
			xline(1, lp("0.5") lc(gs2) lw(small))
			text(1.1 1.1 "Disease severity", place(e) size(5))
			text(7.1 1.1 "Adherence", place(e) size(5))

			legend(size(medium) position(3) bm(t=0 b=5 l=0 r=0) colf cols(1) order(2 4 6 8)
			region(fcolor(gs16) lw(vthin) margin(l=1 r=1 t=1 b=1))
			lab(2 "Education")
			lab(4 "Discount")
			lab(6 "Self-help")
			lab(8 "Adherence")
			)

			;
#delimit cr

/*1 "Disease severity" 7 "Medication adherence"
edkblue
emidblue
ebblue
