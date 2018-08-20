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
local datapath "X:\The University of the West Indies\DataGroup - repo_data\data_p113\"
** LOGFILES to unencrypted OneDrive folder
local logpath X:\OneDrive - The University of the West Indies\repo_datagroup\repo_p113

** Close any open log fileand open a new log file
capture log close
cap log using "`logpath'\lupus_lca_preparation", replace
** HEADER -----------------------------------------------------



** ------------------------------------------------------------------------------------
** THE DATA
** 2011 India census with populations to District level
** And UNICEF numbers of people reporting open defecation
** Open Defecation data provided by UNICEF-ROSA - 10-MAR-2016
** Populatiion data at district level from -->  http://www.dataforall.org/dashboard/censusinfoindia_pca/
** ------------------------------------------------------------------------------------
** THE PLAN
** (1) STATISTICS
**		A - 	Prevalence of open-defecation
**		B - 	Open-defecation inequality at the State-level (so inequalities between districts)
**			This will allow a direct comparison of the Indian states
** (2) VISUALS
**		A -	Create an initial page for India as a whole
**		B - 	Then a single page (or half-page) per State, looking at open-defecation at the district level
** 		C -	Create the following graphics for the prevalence of open defecation
** 			Map 001 - Whole of India - State-level - prevalence of open-defecation
** 			Map 002 - Whole of India - District-level - prevalence of open-defecation
** 			Map 003 (Series) - one for each Indian state, showing prevalence of open defecation at he district-level
** ------------------------------------------------------------------------------------

** Read the dataset
import excel using "data\in_2011_census.xlsx", clear sheet("dataset") first
order state state_code state_subdivision district_pop district_code pop open_def district_def check district_to_include pop_to_include notes

** state_subdivision
rename state_subdivision t1
encode t1, gen(state_subdivision)
label var state_subdivision "State (1) or Union territory (2)"
drop t1
order state_subdivision, after(state_code)

** State numeric code
gen state_id = .
order state_id, after(state)
replace state_id = 1287 if state_code == "IN.AN"
replace state_id = 1288 if state_code == "IN.AP"
replace state_id = 1289 if state_code == "IN.AR"
replace state_id = 1290 if state_code == "IN.AS"
replace state_id = 1291 if state_code == "IN.BR"
replace state_id = 1292 if state_code == "IN.CH"
replace state_id = 1293 if state_code == "IN.CT"
replace state_id = 1294 if state_code == "IN.DN"
replace state_id = 1295 if state_code == "IN.DD"
replace state_id = 1296 if state_code == "IN.DL"
replace state_id = 1297 if state_code == "IN.GA"
replace state_id = 1298 if state_code == "IN.GJ"
replace state_id = 1299 if state_code == "IN.HR"
replace state_id = 1300 if state_code == "IN.HP"
replace state_id = 1301 if state_code == "IN.JK"
replace state_id = 1302 if state_code == "IN.JH"
replace state_id = 1303 if state_code == "IN.KA"
replace state_id = 1304 if state_code == "IN.KL"
replace state_id = 1305 if state_code == "IN.LD"
replace state_id = 1306 if state_code == "IN.MP"
replace state_id = 1307 if state_code == "IN.MH"
replace state_id = 1308 if state_code == "IN.MN"
replace state_id = 1309 if state_code == "IN.ML"
replace state_id = 1310 if state_code == "IN.MZ"
replace state_id = 1311 if state_code == "IN.NL"
replace state_id = 1312 if state_code == "IN.OR"
replace state_id = 1313 if state_code == "IN.PY"
replace state_id = 1314 if state_code == "IN.PB"
replace state_id = 1315 if state_code == "IN.RJ"
replace state_id = 1316 if state_code == "IN.SK"
replace state_id = 1317 if state_code == "IN.TN"
replace state_id = 1318 if state_code == "IN.TR"
replace state_id = 1319 if state_code == "IN.UP"
replace state_id = 1320 if state_code == "IN.UT"
replace state_id = 1321 if state_code == "IN.WB"
#delimit ;
label define state_id 	1287 "Andaman & Nicobar"
						1288 "Andhra Pradesh"
						1289 "Arunachal Pradesh"
						1290 "Assam"
						1291 "Bihar"
						1292 "Chandigarh"
						1293 "Chhattisgarh"
						1294 "Dadra & Nagar Haveli"
						1295 "Daman & Diu"
						1296 "Delhi"
						1297 "Goa"
						1298 "Gujarat"
						1299 "Haryana"
						1300 "Himachal Pradesh"
						1301 "Jammu & Kashmir"
						1302 "Jharkhand"
						1303 "Karnataka"
						1304 "Kerala"
						1305 "Lakshadweep"
						1306 "Madhya Pradesh"
						1307 "Maharashtra"
						1308 "Manipur"
						1309 "Meghalaya"
						1310 "Mizoram"
						1311 "Nagaland"
						1312 "Orissa"
						1313 "Pondicherry"
						1314 "Punjab"
						1315 "Rajasthan"
						1316 "Sikkim"
						1317 "Tamil Nadu"
						1318 "Tripura"
						1319 "Uttar Pradesh"
						1320 "Uttaranchal"
						1321 "West Bengal", modify;
#delimit cr
label values state_id state_id
rename state_id ID_1
label var ID_1 "Unique id: to link to ShapeFile"
label var state_code "ISO standard code for each Indian state"
label var district_code "ISO standard code for each Indian district"
label var district_pop "The district name from census 2011"
label var pop "district populations from census 2011"
label var open_def "Population reporting open defecation from UNICEF"
label var district_pop "The district name from UNICEF"
label var check "Indicator for which district links must be checked for accuracy"
label var district_to_include "District for which pop value still to be included"
label var pop_to_include "Pop value still to be included"
label var notes "Brief note to help assess accuracy of district link"

** open_def to numeric
rename open_def t1
gen open_def = real(t1)
drop t1

** -------------------------------------------------------------------
** People practicing OD per square km
** -------------------------------------------------------------------
gen area_district = area_rural + area_urban
gen odsqkm = (open_def/area_district)

/*
** Save the District-Level file
label data "India open defecation: district-level dataset"
save "data\in_dataset_district.dta", replace

** Create a State-level file
** Check values against the original dataset transmitted by UNICEF
** STATE POPULATION
bysort ID_1: egen spop = sum(pop)
format spop %12.0fc
label var spop "State-level population"
replace spop = . if spop==0

** STATE OPEN-DEFECATION
bysort ID_1: egen sdef = sum(open_def)
format sdef %12.0fc
label var sdef "State-level # reporting open-defecation"
replace sdef = . if sdef==0

** PROPORTION reporting open-defecation
gen pdef = (sdef/spop)*100
label var pdef "Proportion reporting open defecation"
** restrict to 1 row per state
sort ID_1
egen keep = tag(ID_1)
keep if keep==1
keep state ID_1 state_code state_subdivision spop sdef pdef area_state

** Save the District-Level file
label data "India open defecation: state-level dataset"
save "data\in_dataset_state.dta", replace
drop _all

** INDIA - ADMIN LEVEL 0 -- Country-level
shp2dta using "C:\ado\personal\shapefiles\india\india_pre2016\IND_adm0"	///
				, data(C:\ado\personal\map_coordinates\in0_database) coor(C:\ado\personal\map_coordinates\in0_coords) replace genid(_polygonid)

** INDIA - ADMIN LEVEL 1 -- State-level
shp2dta using "C:\ado\personal\shapefiles\india\india_pre2016\IND_adm1"	///
				, data(C:\ado\personal\map_coordinates\in1_database) coor(C:\ado\personal\map_coordinates\in1_coords) replace genid(_polygonid)

** INDIA - ADMIN LEVEL 2 -- District-level
shp2dta using "C:\ado\personal\shapefiles\india\india_pre2016\IND_adm2"	///
				, data(C:\ado\personal\map_coordinates\in2_database) coor(C:\ado\personal\map_coordinates\in2_coords) replace genid(_polygonid)


** ---------------------------------------------------------------------------------------
** GRAPHIC 1A
** INDIA BY STATE - with STATE NAMES
** ---------------------------------------------------------------------------------------
** To Do
** ---------------------------------------------------------------------------------------
** (1) Map 1 – re-position numbering for small states and union territories (such as Delhi, Puducherry etc)
** (2) Map 1 – add lines to link numbers to territories
** (3) Map 1 – add Andaman & Nicobar to chart
** ---------------------------------------------------------------------------------------
** Coordinates for names
input _polygonid str40 state byvar_lb yvar_lb xvar_lb
  1      "Andaman and Nicobar"	1	10	93
  2           "Andhra Pradesh"	1	15.833333	79.75
  3        "Arunachal Pradesh"	1	28.25	94.666667
  4                    "Assam"	1	26.25	93
  5                    "Bihar"	1	25.75	85.75
  6               "Chandigarh"	1	32.15	80.25
  7             "Chhattisgarh"	1	21.5	82
  8   "Dadra and Nagar Haveli"	1	18.166667	71.03333
  9            "Daman and Diu"	1	19.4	70.87
 10                    "Delhi"	1	28.6667	78.6
 11                      "Goa"	1	15.333333	72.08333
 12                  "Gujarat"	1	23	71.75
 13                  "Haryana"	1	29.25	76.333333
 14         "Himachal Pradesh"	1	31.91667	77.25
 15        "Jammu and Kashmir"	1	33.91667	76.66667
 16                "Jharkhand"	1	23.75	85.5
 17                "Karnataka"	1	14.666667	75.833333
 18                   "Kerala"	1	7.6	76
 19              "Lakshadweep"	1	11	71
 20           "Madhya Pradesh"	1	23.5	78.5
 21              "Maharashtra"	1	19.5	76
 22                  "Manipur"	1	24.75	93.833333
 23                "Meghalaya"	1	24.5	90.333333
 24                  "Mizoram"	1	23.333333	92.833333
 25                 "Nagaland"	1	26.083333	96.5
 26                   "Orissa"	1	20.5	84.41667
 27               "Puducherry"	1	11.933333	82.816667
 27               "Puducherry"	1	15.933333	84.816667
 28                   "Punjab"	1	30.91667	75.41667
 29                "Rajasthan"	1	26.583333	73.833333
 30                   "Sikkim"	1	29.583333	88.5
 31               "Tamil Nadu"	1	11	78.333333
 32                  "Tripura"	1	22	91
 33            "Uttar Pradesh"	1	27	80.75
 34              "Uttaranchal"	1	30.25	79.25
 35              "West Bengal"	1	23	88
 end
tempfile in_location
save `in_location', replace
save "C:\ado\personal\map_coordinates\in1_database_location", replace
drop _all

** Create LINE Dataset of Region Pointers - We Add these lines to the basemap dataset
drop _all
input _ID str40 state byvar_ln _Y _X
  6				  "Chandigarh"	1	0			0
  6				  "Chandigarh"	1	30.8		77.0 85
  6               "Chandigarh"	1	32.1		79.9
  8   "Dadra and Nagar Haveli"	1	0			0
  8   "Dadra and Nagar Haveli"	1	19.9		72.9
  8   "Dadra and Nagar Haveli"	1	18.25		71.35
  9            "Daman and Diu"	1	0			0
  9            "Daman and Diu"	1	20.5		72.7
  9            "Daman and Diu"	1	19.5		71.1
  9            "Daman and Diu"	1	0			0
  9            "Daman and Diu"	1	19.75		70.9
  9            "Daman and Diu"	1	20.475		70.82
  10                    "Delhi"	1	0			0
 10                    "Delhi"	1	28.6667		77.1
 10                    "Delhi"	1	28.6667		78.2
 11                      "Goa"	1	0			0
 11                      "Goa"	1	15.333333	74.15
 11                      "Goa"	1	15.333333	72.55
 18                   "Kerala"	1	0			0
 18                   "Kerala"	1	9.5			76.8
 18                   "Kerala"	1	8.0			76.1
 23                "Meghalaya"	1	0			0
 23                "Meghalaya"	1	25.7		91.6
 23                "Meghalaya"	1	24.8		90.5
 27               "Puducherry"	1	0			0
 27               "Puducherry"	1	11.8		80
 27               "Puducherry"	1	11.933333	82.3
 27               "Puducherry"	1	0			0
 27               "Puducherry"	1	10.9		80
 27               "Puducherry"	1	11.933333	82.3
 27               "Puducherry"	1	0			0
 27               "Puducherry"	1	16.45		82.4
 27               "Puducherry"	1	15.933333	84.3
 30                   "Sikkim"	1	0			0
 30                   "Sikkim"	1	27.5		88.5
 30                   "Sikkim"	1	29.1		88.5
 32                  "Tripura"	1	0			0
 32                  "Tripura"	1	23.5		91.7
 32                  "Tripura"	1	22.1		91
end
replace _X=. if _X==0
replace _Y=. if _Y==0
save "C:\ado\personal\map_coordinates\in1_database_lines", replace
drop _all

** Code for colours
input _polygonid str40 state color
  1      "Andaman and Nicobar"	25
  2           "Andhra Pradesh"	25
  3        "Arunachal Pradesh"	25
  4                    "Assam"	85
  5                    "Bihar"	85
  6               "Chandigarh"	85
  7             "Chhattisgarh"	85
  8   "Dadra and Nagar Haveli"	85
  9            "Daman and Diu"	85
 10                    "Delhi"	85
 11                      "Goa"	85
 12                  "Gujarat"	45
 13                  "Haryana"	25
 14         "Himachal Pradesh"	65
 15        "Jammu and Kashmir"	25
 16                "Jharkhand"	25
 17                "Karnataka"	45
 18                   "Kerala"	25
 19              "Lakshadweep"	25
 20           "Madhya Pradesh"	25
 21              "Maharashtra"	65
 22                  "Manipur"	25
 23                "Meghalaya"	25
 24                  "Mizoram"	65
 25                 "Nagaland"	45
 26                   "Orissa"	65
 27               "Puducherry"	85
 28                   "Punjab"	45
 29                "Rajasthan"	65
 30                   "Sikkim"	65
 31               "Tamil Nadu"	65
 32                  "Tripura"	25
 33            "Uttar Pradesh"	45
 34              "Uttaranchal"	85
 35              "West Bengal"	45
 end
tempfile in_color
save `in_color', replace

merge 1:1 _polygonid using "C:\ado\personal\map_coordinates\in1_database"
drop _merge
save "C:\ado\personal\map_coordinates\in1_database_color", replace


** For visual clarity, we remove the remote Andaman & Nicobar Islands (ID_1 = 1287) (_ID = 1)
use C:\ado\personal\map_coordinates\in1_coords, replace
**drop if inlist(_ID, 1)
save data\coords\india_minus_names_1287, replace





** (GRAPHIC 1)  INDIAN STATES (minus Andaman and Nicobar Islands)
** Open defecation prevalence by state
use C:\ado\personal\map_coordinates\in1_database_color, replace
#delimit ;
spmap 	color using "data\coords\india_minus_names_1287.dta", moc(gs10)
		id(_polygonid)
		oc("179 226 205" "253 205 172" "203 213 232" "244 202 228")
		os(0.01 0.01 0.01 0.01 0.01)
		fcolor("179 226 205" "253 205 172" "203 213 232" "244 202 228")
		clmethod(custom) clbreaks(20 40 60 80 100) clnumber(4)
		legenda(off)
		polygon(data("data\coords\india_minus_names_1287.dta") oc(gs8) os(0.05))
		label(data("C:\ado\personal\map_coordinates\in1_database_location") by(byvar_lb) xcoord(xvar_lb) ycoord(yvar_lb) label(_polygonid) color(gs4) size(2.75) length(15 15))
		line(data("C:\ado\personal\map_coordinates\in1_database_lines.dta") by(byvar_ln) col(gs4) size(0.25) )
		;
# delimit cr
