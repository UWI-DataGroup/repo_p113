** HEADER -----------------------------------------------------
**  DO-FILE METADATA
//  algorithm name			        lupus_lca_preparation.do
//  project:				        Epidemiology of Lupus in ST.Lucia
//  analysts:						Ian HAMBLETON
//	date last modified	            20-Aug-2018
//  algorithm task			        Saint Lucia Chloropleth

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
cap log using "`logpath'\sla_map", replace
** HEADER -----------------------------------------------------


** LOAD SHAPE FILES FOR SLA
** These have been downloaded from: http://www.diva-gis.org/gdata
** Administrative Areas
** License: These data were extracted from the GADM database (www.gadm.org), version 2.5, July 2015.
** They can be used for non-commercial purposes only.
** It is not allowed to redistribute these data, or use them for commercial purposes, without prior consent.

** SAINT LUCIA - ADMIN LEVEL 0 -- Country-level
#delimit ;
shp2dta using "`datapath'\version01\1-input\shape\LCA_adm0"
				,
                data("`datapath'\version01\1-input\shape\lca0_database")
                coor("`datapath'\version01\1-input\shape\lca0_coords")
                replace
                genid(_polygonid);
#delimit cr

** SAINT LUCIA - ADMIN LEVEL 1 -- District-level
#delimit ;
shp2dta using "`datapath'\version01\1-input\shape\LCA_adm1"
				,
                data("`datapath'\version01\1-input\shape\lca1_database")
                coor("`datapath'\version01\1-input\shape\lca1_coords")
                replace
                genid(_polygonid);
#delimit cr

** Add Incidence Rates
tempfile ir1 ir2
input   str12 NAME_1  _polygonid  ir
        "Anse-la-Raye"  	   1   3.4
        "Canaries"	           2   4.1
        "Castries"	           3   3.7
        "Choiseul"             4   1.9
        "Dennery"	           5   1.9
        "Gros Islet"	       6   5.2
        "Laborie"	           7   2.1
        "Micoud"	           8   2.3
        "Soufrière"	           9   1.5
        "Vieux Fort"	      10   3.3
end
save `ir1'
use "`datapath'\version01\1-input\shape\lca1_database", replace
merge 1:1 _polygonid using `ir1'
drop _merge
save `ir2'


** Coordinates for names
input _polygonid str40 state byvar_lb yvar_lb xvar_lb
  1   "Anse-la-Raye"	1	
  2   "Canaries"	  	1
  3   "Castries"	  	1
  4   "Choiseul"    	1
  5   "Dennery"	    	1
  6   "Gros Islet"	    1
  7   "Laborie"	  	    1
  8   "Micoud"	  	    1
  9   "Soufrière"	  	1
 10   "Vieux Fort"	    1
 end
tempfile sla_location
save `sla_location', replace


** (GRAPHIC 1)  SAINT LUCIA DISTRICTS
** Lupus incidence by district
use `ir2', replace
#delimit ;
spmap 	ir using "`datapath'\version01\1-input\shape\lca1_coords", moc(gs10)
		id(_polygonid)
		oc(gs0 gs0 gs0 gs0 gs0)
		os(0.1 0.1 0.1 0.1 0.1)
		fcolor("254 227 145" "254 196 79" "254 153 41" "217 95 14" "153 52 4"  )
		clmethod(custom) clbreaks(1 2 3 4 5 6) clnumber(5)
		legend(ring(0) position(11) bm(r=5 b=5) size(4) symy(4) symx(4))
        legs(2)
        title("Lupus incidence (per 100,000 person years)",bm(r=5 b=5)  size(*0.95))
		///polygon(data("data\coords\india_minus_names_1287.dta") oc(gs8) os(0.05))
		///label(data("C:\ado\personal\map_coordinates\in1_database_location") by(byvar_lb) xcoord(xvar_lb) ycoord(yvar_lb) label(_polygonid) color(gs4) size(2.75) length(15 15))
		///line(data("C:\ado\personal\map_coordinates\in1_database_lines.dta") by(byvar_ln) col(gs4) size(0.25) )
		;
# delimit cr
