* Copyright 2020, Sunnee Billingsley, All rights reserved.
*for adaptation of below


/*
*******************************
The code was prepared by the Institute for Structural Research - IBS.
In case of using it please include the following citation:

Hardy, W., Keister, R. and Lewandowski, P. (2018). Educational upgrading, structural change and the task composition of jobs in Europe. Economics Of Transition 26.

For details, you can find the paper here: https://onlinelibrary.wiley.com/doi/full/10.1111/ecot.12145
*******************************

*******************************
This code was written for Stata 12 but should work for other versions without any or any major changes.
*******************************

*******************************
Other Notes
* The code below was last run for the 20.1 O*NET dataset release (2015).
* Parts of the code are based on the do-files provided on the website of David Autor (http://economics.mit.edu/faculty/dautor/data/acemoglu) and his measures of task content.
* The initial conversion to .dta format might be different for previous years (that are not in .xlsx), but should pose no problems.
*******************************
*/


//insert the path to your .xlsx O*NET data directory. Files required for the derivation of task content items:
* Abilities.xlsx
* Skills.xlsx
* Work Activities.xlsx
* Work Context.xlsx
//downloaded from: https://www.onetcenter.org/database.html . 
global source"C:\Users\sbill\Documents\Work\Covid\onetsoc_to_isco_cws_ibs\onetsoc_to_isco_cws_ibs"   

//insert the path to your crosswalks directory.
global crosswalks "C:\Users\sbill\Documents\Work\Covid\onetsoc_to_isco_cws_ibs\onetsoc_to_isco_cws_ibs"

//insert the path for your output files (the do-file will create several .dta files along the way - one for each classification).
global output "C:\Users\sbill\Documents\Work\Covid\output"


clear all	

//save the data in .dta format.
/*
import excel using "$source\\Abilities.xlsx", firstrow clear
	rename *, lower
save "$source\\Abilities.dta", replace

import excel using "$source\\Skills.xlsx", firstrow clear
	rename *, lower
save "$source\\Skills.dta", replace

import excel using "$source\\Work Activities.xlsx", firstrow clear
	rename *, lower
save "$source\\Work Activities.dta", replace

import excel using "$source\\Work Context.xlsx", firstrow clear
	rename *, lower
save "$source\\Work Context.dta", replace
*/

import excel using "$source\\Exposed_to_Disease_or_InfectionsONet.xlsx", firstrow clear
	rename *, lower
	rename b onetsoccode
	rename browsebyonetdata exposure
	rename c occupation
save "$source\\Exposure.dta", replace

import excel using "$source\\Physical_ProximityONet.xls", firstrow clear
	rename *, lower
	rename b onetsoccode
	rename browsebyonetdata proximity
	rename c occupation
save "$source\\Proximity.dta", replace

import excel using "$source\\Contact_With_OthersONet.xls", firstrow clear
	rename *, lower
	rename b onetsoccode
	rename browsebyonetdata contact
	rename c occupation
save "$source\\Contact.dta", replace

//append the prepared O*NET data, but only the needed variables
clear all
append using "$source\Abilities.dta", keep(scaleid datavalue onetsoccode elementid)
append using "$source\Skills.dta", keep(scaleid datavalue onetsoccode elementid)
append using "$source\Work Context.dta", keep(scaleid datavalue onetsoccode elementid)
append using "$source\Work Activities.dta", keep(scaleid datavalue onetsoccode elementid)
merge m:m onetsoccode using "$source\Exposure.dta"
drop _merge
merge m:m onetsoccode using "$source\Proximity.dta"
drop _merge
merge m:m onetsoccode using "$source\Contact.dta"
drop _merge



//keep only the needed measurements 
keep if scaleid=="IM" | scaleid=="CX"
drop scaleid

//simplify values and names
rename datavalue score
replace elementid=subinstr(elementid, ".", "", 5) 

//reshape so that each ONET-SOC code has one observation with all task measures */
reshape wide score, i(onetsoccode) j(elementid) string

//simplify names
renpfix score t_

//some correction for the calculation of task contents (scale reversion of selected items)
gen t_4C3b8_rev=6-t_4C3b8
gen t_4C1a2l_rev=6-t_4C1a2l
gen t_4C2a3_rev=6-t_4C2a3
foreach var in t_4A4a4 t_4A4a5 t_4A4a8 t_4A4b5 t_4A1b2 t_4A3a2 t_4A3a3 t_4A3a4 t_4A3b4 t_4A3b5 {
	gen `var'_rev=6-`var'
}

//keep only needed items
keep onetsoccode t_4A2a4 t_4A2b2 t_4A4a1 t_4A4a4 t_4A4b4 t_4A4b5 t_4C3b7 t_4C3b4 t_4C3b8_rev t_4C3d3 t_4A3a3 t_4C2d1i t_4A3a4 t_4C2d1g t_1A2a2 t_1A1f1 t_2B1a t_4C1a2l_rev t_4A4a5_rev t_4A4a8_rev t_4A1b2_rev t_4A3a2_rev t_4A3b4_rev t_4A3b5_rev exposure proximity contact occupation

//final cleaning
sort onetsoccode
rename onetsoccode onetsoc10
destring exposure, gen (expos) ignore ("Not available")
destring proximity, gen (prox) ignore ("Not available")
destring contact, gen (cont) ignore ("Not available")

*******the following lines will convert the values to other classifications, averaging them along the way, by classification codes*******
*******the code will save the data in each classification along the way, modify this as necessary if you only want to acquire one final file*******

//saving the clean, O*NET-SOC 10 data
save "$output\onetsoc10.dta", replace

/*
//from O*NET-SOC 10 to O*NET-SOC 09
use "$output\onetsoc10.dta", clear
	joinby onetsoc10 using "$crosswalks\onetsoc09_onetsoc10.dta"
	collapse (mean) t_* , by(onetsoc09)
save "$output\onetsoc09.dta", replace
*/

//from O*NET-SOC 10 to SOC 10
use "$output\onetsoc10.dta", clear
	replace onetsoc10 = subinstr(onetsoc10, "-", "", 1)
	destring onetsoc10, replace
	gen soc10=int(onetsoc10)
save "$output\soc10test.dta", replace
	collapse (mean) t_* expos prox cont, by(soc10)

save "$output\soc10.dta", replace

/*
//from O*NET-SOC 09 na SOC 00
use "$output\onetsoc09.dta", clear
	replace onetsoc09 = subinstr(onetsoc09, "-", "", 1)
	destring onetsoc09, replace
	gen soc00=int(onetsoc09)
	collapse (mean) t_* , by(soc00)
save "$output\soc00.dta", replace
*/

/*
//from SOC 00 to ISCO-88
use "$output\soc00.dta", clear
	joinby soc00 using "$crosswalks\isco88_soc00.dta"
	collapse (mean) t_* , by(isco88)
	destring isco88, replace
	drop if isco88==.
save "$output\isco88.dta", replace
*/

//from SOC 10 to ISCO-08
use "$output\soc10.dta", clear
	joinby soc10 using "$crosswalks\soc10_isco08.dta"
	collapse (mean) t_* expos prox cont, by(isco08)
save "$output\isco08.dta", replace

keep isco08 expos prox cont
save "$output\isco08_Allmeasures.dta", replace

*now working with 4 to 3 level isco
gen isco3level=isco08/10
gen isco08lev3=int(isco3level)
drop isco3level

*is this a big loss?
preserve
collapse (mean) expos cont prox, by (isco08lev3)
rename expos meanexp 
rename cont meancont 
rename prox meanprox
save "$output\meanAll.dta", replace
restore
merge m:1 isco08lev3 using "$output\meanAll.dta"
drop _merge
gen diffmean=meanexp-expos

save "$output\3digitIsco08_All.dta", replace

*now getting the data key for ssyk from SCB

import excel using "$source\\webb_nyckel_ssyk2012_isco-08_20160905.xlsx", firstrow clear
	rename SSYK2012kod ssyk2012
	rename ISCO08 isco08
	keep ssyk2012 isco08
	destring ssyk2012, gen (ssyk)
	destring isco08, gen (isco)
	duplicates drop ssyk isco, force
	drop isco08
	rename isco isco08
	save "$source\\ssykKey.dta", replace

merge m:1 isco08 using "$output\isco08_Allmeasures.dta"
	gen missing=0 if _merge==3
	replace missing=1 if _merge==1
	replace missing=2 if _merge==2
	label define missing 0 "not missing" 1 "missing exposure data" 2 "missing ssyk" , modify
	label values missing missing    
	drop _merge
	drop ssyk2012

*creating an aggregate measure for the three
egen covrisk2=rsum(expos prox cont)
gen covrisk=covrisk2/3
sum covrisk, d

save "$output\\SsykIscoAll.dta", replace


