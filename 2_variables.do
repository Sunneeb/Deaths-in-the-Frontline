* Copyright 2020, Maria Brandén, All rights reserved.

cd "\\micro.intra\Projekt\P0864$\P0864_Gem\MariaBo"
set more off

* year to calculate age by
global year=2019

* Variable construction
use sample.dta, clear
drop _merge

rename ssyk3_2012 ssyk3d
destring ssyk3d ssyk4_2012_j16, replace force

* Only study 20+ for income distribution since they are on the labor market
destring fodar, replace
gen age=$year-fodar

replace dispink04=. if age<20
egen dispink_3=xtile(dispink04), nq(3)
egen dispink_10=xtile(dispink04), nq(10)

	***********
	* HOUSING *
	***********
count if lopnrlgh==.
bysort lopnrlgh: gen ant_lgh=_N if lopnrlgh!=.
bysort lopnrlgh: gen n_lopnrlgh=1 if _n==1
count if ant_lgh>20 & ant_lgh!=.
	
	
	
gen Stockholm=1 if lan=="01"
replace Stockholm=0 if  lan!="01"

egen age_5=cut(age), at(0(5)200)
replace age_5=95 if age_5>95 & age_5!=.
replace age_5=40 if age_5<40

destring kon, replace
gen woman=0
replace woman=1 if kon==2

gen edu=substr(sun2000niva,1,1)
destring edu, replace force

gen edu_3=9
replace edu_3=1 if edu<=2
replace edu_3=2 if edu==3
replace edu_3=3 if edu>=4 & edu<=6


* Country of birth
destring fodelselandgrp, replace force

capture drop _merge


/*World Bank definition*/
* Definition from Paper 1

gen birthcountry=fodelselandgrp

gen mena = .
replace mena = 0 if birthcountry==1
replace mena = 1 if birthcountry>=2  & birthcountry<=22
replace mena = 1 if inlist(birthcountry, 24, 42)
replace mena = 2 if mena==. & birthcountry!=99 & birthcountry!=1
/*Pick out early countries from the first if statement included in HIC*/
replace mena = 2 if inlist(birthcountry, 6, 7, 16, 17, 18)
replace mena = 3 if inlist(birthcountry, 30, 31, 32, 33, 34, 35)

label define mena 0 "Sweden" 1 "HIC" 2 "LMIC other" 3 "LMIC MENA", modify
label variable mena "HIC vs LMIC w/MENA World Bank definitions"
label values mena mena
tab bcname mena, m

compress
save final_sample.dta, replace

* Link occupational characteristics on exposure
use "SsykIscoExposure.dta", clear
bysort ssyk: gen count_ssyk=_N
bysort isco: gen count_isco=_N

codebook ssyk /*429 unique occupations*/
codebook ssyk if count_ssyk==1 & count_isco==1 /*126 ssyk are 1-to-1-matches */
codebook ssyk if count_ssyk!=1 & count_isco==1 /*79 ssyk consist of many iscos, but these iscos are not included in other occupations*/
codebook ssyk if count_ssyk!=1 & count_isco!=1 /*116 ssyk consist of many iscos, and these iscos are also included in other occupations*/

* We average across SSYK, and if an ISCO is included in many occupations, we keep it in all occupations
collapse (mean) expos, by(ssyk)
rename ssyk ssyk4_2012_j16
replace expos=. if ssyk4_2012_j16==.
merge 1:m ssyk4_2012_j16 using final_sample.dta
save final_sample.dta, replace


use "SsykIscoAll.dta", clear
bysort ssyk: gen count_ssyk=_N
bysort isco: gen count_isco=_N

collapse (mean) covrisk, by(ssyk)
rename ssyk ssyk4_2012_j16
replace covrisk=. if ssyk4_2012_j16==.
merge 1:m ssyk4_2012_j16 using final_sample.dta
save final_sample.dta, replace

