capture log close
cd "\\micro.intra\Projekt\P0864$\P0864_Gem\MariaBo\"
set more off
set scheme burd, perm

use final_sample.dta, clear

* Expos (only containing one dimension of exposure) is dropped and replaced with covrisk (which is a summarized measure)
drop if covrisk==0
corr covrisk expos

drop expos
rename covrisk expos

****************** 
* TIME VARIABLES *
******************

* END
gen end_date=mdy(05, 08, 2020)

* DATE OF BIRTH
destring fodarman, replace

* year
gen byear=(trunc(fodarman/100))

* month
gen bmonth=fodarman-(byear*100)

* random day of birth
set seed 11
gen byte random28=1+int((28-1+1)*uniform())
gen byte random30=1+int((30-1+1)*uniform())
gen byte random31=1+int((31-1+1)*uniform())

gen byte bday=random28 if bmonth==2
replace bday=random30 if bmonth==4 | bmonth==6 | bmonth==9 | bmonth==11
replace bday=random31 if bmonth==1 |bmonth==3 | bmonth==5 | bmonth==7 | bmonth==8 | bmonth==10 | bmonth==12

drop random28 random30 random31

gen double bdate=mdy(bmonth,bday,byear)

format bdate end_date ddatecod_clean %td

drop covid19
rename covid_clean covid19

gen sttime=ddatecod_clean-bdate
replace sttime=end_date-bdate if ddatecod_clean==.

gen enter_date=mdy(03,05,2020)
gen enter_time=enter_date-bdate

gen allcause=0
replace allcause=1 if ddatecod_clean!=. & covid19!=1

* Generate variable on turning 20
gen date20=mdy(month(bdate),day(bdate),year(bdate)+20)
format date20 enter_date %td

* Create 67+ for analyses on old sample (those aged 67+ in march)
gen date67=mdy(month(bdate),day(bdate),year(bdate)+67)
format date67 enter_date enter_time %td 
gen aged_67_plus=0
replace aged_67_plus=1 if date67<enter_date

* Only keep those aged 20+ in march
drop if date20>enter_date

save paper_3.dta, replace


use paper_3.dta, clear
log using "\\micro.intra\Projekt\P0864$\P0864_Gem\MariaBo\paper3_200723.log", replace

********************************
* OCCUPATIONAL CHARACTERISTICS *
********************************

***********************
* GENERAL DEFINITIONS *
***********************
gen ssyk=0
replace ssyk=1 if ssyk_1 !=.
label variable ssyk "Has registered occupation"
label define ssyk 1"Has registered occupation vs. not", modify
label values ssyk ssyk

gen ssyk_1=trunc(ssyk4_2012_j16/1000)

gen ssyk123=0 if ssyk_1!=.
replace ssyk123=1 if ssyk_1==1 | ssyk_1==2 | ssyk_1==3
label define ssyk123 1"Skilled occ. vs. other occ.", modify
label values ssyk123 ssyk123

gen w_b_collar=0 if ssyk4_2012_j16!=.
replace w_b_collar=1 if ssyk_1<=4 & ssyk_1!=1
replace w_b_collar=0 if ssyk4_2012_j16==3451 | ssyk4_2012_j16==4211 | ssyk4_2012_j16==4321 | ssyk4_2012_j16==4322 | ssyk4_2012_j16==4323 | ssyk4_2012_j16==4420
replace w_b_collar=1 if ssyk4_2012_j16==5111 | ssyk4_2012_j16==5113 | ssyk4_2012_j16==5242 
replace w_b_collar=2 if ssyk_1==1
replace w_b_collar=9 if ssyk4_2012_j16==.
label variable w_b_collar "Manual vs. skilled labor"
label define w_b_collar 0"Manual" 1"Skilled" 2"Managerial" 9"No SSYK", modify
label values w_b_collar w_b_collar

gen white_collar=w_b_collar==0
gen blue_collar=w_b_collar==1
gen manager=w_b_collar==2

egen expos_5=cut(expos), at(0,5,10,20,50,100) label
egen expos_3=cut(expos), group(3) label


************************************
* SPECIFIC OCCUPATIONAL CATEGORIES *
************************************
gen work_care=0 if ssyk3d!=.
replace work_care=1 if ssyk3d==221 | ssyk3d==222 | ssyk3d==223 | ssyk3d==532 | ssyk3d==533 
replace work_care=0 if ssyk4_2012_j16==2222 | ssyk4_2012_j16==2225 | ssyk4_2012_j16==2233 | ssyk4_2012_j16==2234
label variable work_care "Care occ."
label define work_care 1 "Care occ. vs other occ.", modify
label values work_care work_care

gen taxi_bus=0 if ssyk4_2012_j16!=.
replace taxi_bus=1 if ssyk4_2012_j16==8321 | ssyk4_2012_j16==8331
label variable taxi_bus "Taxi/bus driver"
label define taxi_bus 1"Taxi/bus driver vs. other occ.", modify
label values taxi_bus taxi_bus

gen occ_butcher=0 if ssyk4_2012_j16!=.
replace occ_butcher=1 if ssyk4_2012_j16==7611
label variable occ_butcher "Meat packer"
label define occ_butcher 1"Meat packer vs. other occ.", modify
label values occ_butcher occ_butcher

gen occ_teacher=0 if ssyk4_2012_j16!=.
replace occ_teacher=1 if ssyk3d==234 | ssyk4_2012_j16==5311
label variable occ_teacher "Teacher"
label define occ_teacher 1"Teachers vs. other occ.", modify
label values occ_teacher occ_teacher

gen cashier_rest=0 if ssyk4_2012_j16!=.
replace cashier_rest=1 if ssyk3d==522 | ssyk3d==941 | ssyk3d==523
label variable cashier_rest "Service sector"
label define cashier_rest 1 "Service sector vs. other occ.", modify
label values cashier_rest cashier_rest

gen occ_police_guard=0 if ssyk4_2012_j16!=.
replace occ_police_guard=1 if ssyk4_2012_j16==5412 | ssyk4_2012_j16== 5413 | ssyk4_2012_j16== 3360 
label variable occ_police_guard "Police, security guard etc."
label define occ_police_guard 1"Police, security guard vs. other occ.", modify
label values occ_police_guard occ_police_guard

gen occ_delivery=0 if ssyk4_2012_j16!=.
replace occ_delivery=1 if ssyk4_2012_j16==4420 | ssyk4_2012_j16==8329
label variable occ_delivery "Delivery and postal"
label define occ_delivery 1"Delivery and postal worker vs. other occ", modify
label values occ_delivery occ_delivery

gen occ_cleaner=0 if ssyk4_2012_j16!=.
replace occ_cleaner=1 if ssyk4_2012_j16==9111
label variable occ_cleaner "Cleaner"
label define occ_cleaner 1"Cleaner vs. other occ.", modify
label values occ_cleaner occ_cleaner

gen it_technician=0 if ssyk4_2012_j16!=.
replace it_technician=1 if ssyk3d==251
label variable it_technician "IT technician"
label define occ_cleaner 1"IT technician vs. other occ.", modify

egen occupation=group(it_technician occ_cleaner occ_delivery occ_police_guard cashier_rest occ_teacher occ_butcher taxi_bus work_care), label

label define occupation 1"Other" 2"Care" 3"Taxi/bus" 4"Meat packer" 5"Teacher" 6"Service" 7"Police, guard" 8"Delivery & postal" 9"Cleaner" 10"IT technician" , modify

gen occ_other=0 if ssyk3d!=.
replace occ_other=1 if occupation==1


	**********************************************************
	* OLD INDIVIDUALS GET THESE VARIABLES ON HOUSEHOLD LEVEL *
	**********************************************************
	
* For old individuals, these variables are set to . so that household measures doesn't accidently capture ego's characteristics
foreach i in occ_other it_technician occ_cleaner occ_delivery occ_police_guard cashier_rest occ_teacher occ_butcher taxi_bus work_care expos ssyk white_collar blue_collar manager {
replace `i'=. if aged_67_plus==1
}

bysort lopnrlgh: egen max_expos=max(expos) if lopnrlgh!=.

foreach i in occ_other it_technician occ_cleaner occ_delivery occ_police_guard cashier_rest occ_teacher occ_butcher taxi_bus work_care ssyk white_collar blue_collar manager {
bysort lopnrlgh: egen ant_lgh_`i'=total(`i') if lopnrlgh!=. & ant_lgh<20
gen ant_lgh_`i'_dum=0 if ant_lgh_`i'!=.
replace ant_lgh_`i'_dum=1 if ant_lgh_`i'>0 & ant_lgh_`i'!=.
}



* ADDITIONAL LABELS

label define woman 0"Man" 1"Woman"
label values woman woman

label define edu_3 1"Primary" 2"Secondary" 3"Post-secondary" 9"Missing", modify
label values edu_3 edu_3
label define dispink_3 1"Lowest tertile" 2"Mid tertile" 3"Highest tertile", modify
label values dispink_3 dispink_3
label define Stockholm 0"Rest of Sweden" 1"Stockholm"
label values Stockholm Stockholm




	********************
	* SAMPLE SELECTION *
	********************

* Drop all who die before first covid case in Sweden
drop if ddatecod_clean<=enter_date

* SELECT INDIVIDUALS LIVING IN MUNICIPALITIES THAT HAVE AT LEAST 1 DEATH
bysort kommun: egen muni_cases=sum(covid19)
keep if Stockholm==1 | muni_cases>0
tab lan covid19

* OUR SAMPLE COUNT
keep if (aged_67_plus==0 & ssyk==1) | (aged_67_plus==1 & ant_lgh_ssyk_dum==1)
tab aged_67_plus

* Drop those who are not in sample (i.e. who are not part of the original background population)
drop if in2017pop!=1

* Missing on C of Birth 
drop if mena==.

* Missing on income 
drop if dispink04==.

* Exclude those who miss apartment number (important for the old; but we could think about keeping these observations for the young since we don't look at hh stuff there)
drop if lopnrlgh==. & aged_67_plus==1

tab1 woman  mena edu_3 dispink_3 Stockholm, m



* Count for text
tab aged_67_plus

tab ulorsak_cov if covid19==1

save paper_3_sample.dta, replace


use paper_3_sample.dta, clear
global ind "ib1.woman i.mena ib3.edu_3 ib3.dispink_3 i.Stockholm"

replace covid19=0 if covid19==.
gen exp= sttime-enter_time


***************
* 2020-07-14  *
***************
poisson covid19 c.expos i.age_5 ib1.woman  $ind if aged_67_plus==0, exposure(exp) vce(robust)
est store a1
margins, at(expos=(40(10)100)) post saving(margins_a1, replace)
est store ma1
poisson covid19 c.expos##c.expos##c.expos i.age_5 ib1.woman  $ind  if aged_67_plus==0, exposure(exp) vce(robust)
est store a2
margins, at(expos=(40(10)100)) post saving(margins_a2, replace)
est store ma2

replace w_b_collar=1 if w_b_collar==2
forvalues i=0(1)1 {
poisson covid19 c.expos##c.expos##c.expos  i.age_5  ib1.woman  $ind  if aged_67_plus==0 & w_b_collar==`i', exposure(exp) vce(robust)
est store a2_`i'
margins, at(expos=(40(10)100)) post saving(margins_a2_`i', replace)
est store ma2_`i'
}

* Old population; cubic and linear
poisson covid19 c.max_expos i.age_5 ib1.woman $ind if aged_67_plus==1, exposure(exp) vce(robust)
est store b1
margins, at(max_expos=(40(10)100)) post saving(margins_b1, replace)
est store mb1
poisson covid19 c.max_expos##c.max_expos##c.max_expos i.age_5 ib1.woman $ind if aged_67_plus==1, exposure(exp) vce(robust)
est store b2
margins, at(max_expos=(40(10)100)) post saving(margins_b2, replace)
est store mb2

replace ant_lgh_white_collar_dum=1 if ant_lgh_manager_dum==1
foreach i in blue_collar white_collar {
poisson covid19 c.max_expos##c.max_expos##c.max_expos i.age_5 ib1.woman $ind if aged_67_plus==1 & ant_lgh_`i'_dum, exposure(exp) vce(robust)
est store b2_`i'
margins, at(max_expos=(40(10)100)) post saving(margins_b2_`i', replace)
est store mb2_`i'
}

* Cuts all margins so that they cannot go below zero
foreach i in margins_a1 margins_a2 margins_a2_0  margins_a2_1 margins_b1 margins_b2 margins_b2_blue_collar  margins_b2_white_collar {
use `i'.dta, clear
replace _ci_lb=0 if _ci_lb<0
save `i'_noneg, replace
}

combomarginsplot margins_a1_noneg margins_a2_noneg, labels("Linear, full set of controls" "Cubic, full set of controls")  xtitle("Exposure in occupation") fileci1opts(recast(rarea) fcolor(blue%20)) fileci2opts(recast(rarea) fcolor(red%20)) title("")
graph save "Graph" "\\micro.intra\Projekt\P0864$\P0864_Gem\MariaBo\Figure1.gph", replace
graph export "\\micro.intra\Projekt\P0864$\P0864_Gem\MariaBo\Figure1.png", as(png) name("Graph") replace

combomarginsplot margins_a2_0_noneg  margins_a2_1_noneg  , labels("Manual" "Skilled" )  xtitle("Exposure in occupation")  fileci1opts(recast(rarea) fcolor(blue%20)) fileci2opts(recast(rarea) fcolor(red%20)) title("")
graph save "Graph" "\\micro.intra\Projekt\P0864$\P0864_Gem\MariaBo\Figure3.gph", replace
graph export "\\micro.intra\Projekt\P0864$\P0864_Gem\MariaBo\Figure3.png", as(png) name("Graph") replace

combomarginsplot margins_b1_noneg margins_b2_noneg, labels("Linear, full set of controls" "Cubic, full set of controls")  xtitle("Exposure in occupation")  fileci1opts(recast(rarea) fcolor(blue%20)) fileci2opts(recast(rarea) fcolor(red%20)) title("")
graph save "Graph" "\\micro.intra\Projekt\P0864$\P0864_Gem\MariaBo\Figure2.gph", replace
graph export "\\micro.intra\Projekt\P0864$\P0864_Gem\MariaBo\Figure2.png", as(png) name("Graph") replace

combomarginsplot  margins_b2_blue_collar_noneg  margins_b2_white_collar_noneg, labels("Manual" "Skilled")  xtitle("Exposure in occupation") fileci1opts(recast(rarea) fcolor(blue%20)) fileci2opts(recast(rarea) fcolor(red%20)) title("")
graph save "Graph" "\\micro.intra\Projekt\P0864$\P0864_Gem\MariaBo\Figure4.gph", replace
graph export "\\micro.intra\Projekt\P0864$\P0864_Gem\MariaBo\Figure4.png", as(png) name("Graph") replace

estout a1 a2* using "Paper3_Results_young.xls", eform replace label cells("b (fmt(3)) ci_l ci_u se p")  stats(risk N_fail N, fmt(0))
estout b1 b2* using "Paper3_Results_old.xls", eform replace label cells("b (fmt(3)) ci_l ci_u se p")  stats(risk N_fail N, fmt(0))
estout ma* mb* using "Paper3_Results_margins.xls",  replace label cells("b (fmt(6)) ci_l ci_u se p")  stats(risk N_fail N, fmt(0))

* Occupations
poisson covid19 ib10.occupation i.age_5 ib1.woman if aged_67_plus==0 & ssyk==1,  exposure(exp) vce(robust)
est store m4
poisson covid19 ib10.occupation i.age_5 ib1.woman $ind if aged_67_plus==0 & ssyk==1,  exposure(exp) vce(robust)
est store m5

poisson covid19 i.ant_lgh_occ_other_dum i.ant_lgh_work_care_dum  i.ant_lgh_taxi_bus_dum i.ant_lgh_occ_butcher_dum i.ant_lgh_occ_teacher_dum i.ant_lgh_cashier_rest_dum i.ant_lgh_occ_police_guard_dum i.ant_lgh_occ_delivery_dum i.ant_lgh_occ_cleaner_dum i.age_5 ib1.woman if aged_67_plus==1 & ant_lgh_ssyk_dum==1,  exposure(exp) vce(robust)
est store m8

poisson covid19 i.ant_lgh_occ_other_dum i.ant_lgh_work_care_dum  i.ant_lgh_taxi_bus_dum i.ant_lgh_occ_butcher_dum i.ant_lgh_occ_teacher_dum i.ant_lgh_cashier_rest_dum i.ant_lgh_occ_police_guard_dum i.ant_lgh_occ_delivery_dum i.ant_lgh_occ_cleaner_dum i.age_5 $ind  ib1.woman if aged_67_plus==1 & ant_lgh_ssyk_dum==1,  exposure(exp) vce(robust)
est store m9

* Occupational table
estout m4* m5* m8* m9* using "Paper3_Occupations.xls", eform replace label cells("b (fmt(2)) ci_l ci_u se p")  stats(risk N_fail N, fmt(0))



***
***
***







** Check: without control for immigrant status
global ind "ib1.woman ib3.edu_3 ib3.dispink_3 i.Stockholm"
poisson covid19 c.expos i.age_5 ib1.woman  $ind if aged_67_plus==0, exposure(exp) vce(robust)
est store c1
poisson covid19 c.expos##c.expos##c.expos i.age_5 ib1.woman  $ind  if aged_67_plus==0, exposure(exp) vce(robust)
est store c2

replace w_b_collar=1 if w_b_collar==2
forvalues i=0(1)1 {
poisson covid19 c.expos##c.expos##c.expos  i.age_5  ib1.woman  $ind  if aged_67_plus==0 & w_b_collar==`i', exposure(exp) vce(robust)
est store c2_`i'
}

poisson covid19 c.max_expos i.age_5 ib1.woman $ind if aged_67_plus==1, exposure(exp) vce(robust)
est store d1
poisson covid19 c.max_expos##c.max_expos##c.max_expos i.age_5 ib1.woman $ind if aged_67_plus==1, exposure(exp) vce(robust)
est store d2

replace ant_lgh_white_collar_dum=1 if ant_lgh_manager_dum==1
foreach i in blue_collar white_collar {
poisson covid19 c.max_expos##c.max_expos##c.max_expos i.age_5 ib1.woman $ind if aged_67_plus==1 & ant_lgh_`i'_dum, exposure(exp) vce(robust)
est store d2_`i'
}

estout c1 c2* using "Paper3_Results_no_imm_contr_young.xls", eform replace label cells("b (fmt(3)) ci_l ci_u se p")  stats(risk N_fail N, fmt(0))
estout d1 d2* using "Paper3_Results_no_imm_contr_old.xls", eform replace label cells("b (fmt(3)) ci_l ci_u se p")  stats(risk N_fail N, fmt(0))


** Check: categorical exposure
global ind "ib1.woman ib3.edu_3 i.mena ib3.dispink_3 i.Stockholm"
egen expos_cat=cut(expos), at(0 40 50 60 70 80 100) label
egen max_expos_cat=cut(max_expos),  at(0 40 50 60 70 80 100) label

poisson covid19 ib2.expos_cat i.age_5 ib1.woman  $ind if aged_67_plus==0, exposure(exp) vce(robust)
est store e1

replace w_b_collar=1 if w_b_collar==2
forvalues i=0(1)1 {
poisson covid19 ib2.expos_cat  i.age_5  ib1.woman  $ind  if aged_67_plus==0 & w_b_collar==`i', exposure(exp) vce(robust)
est store e1_`i'
}

poisson covid19 ib2.max_expos_cat i.age_5 ib1.woman $ind if aged_67_plus==1, exposure(exp) vce(robust)
est store f1

replace ant_lgh_white_collar_dum=1 if ant_lgh_manager_dum==1
foreach i in blue_collar white_collar {
poisson covid19 ib2.max_expos_cat i.age_5 ib1.woman $ind if aged_67_plus==1 & ant_lgh_`i'_dum, exposure(exp) vce(robust)
est store f1_`i'
}

coefplot (e1, label(All)) (e1_0, label(Manual)) (e1_1, label(Skilled)) , drop(*woman* *mena* *edu* *dispink* *Stockholm* *age* _cons)  xline(1) eform title("Occupation and COVID-19 mortality""Individuals younger than 67") baselevels
graph export "\\micro.intra\Projekt\P0864$\P0864_Gem\MariaBo\Young_cat.png", as(png) name("Graph") replace

coefplot (f1, label(All)) (f1_blue_collar, label(Manual)) (f1_white_collar, label(Skilled)) , drop(*woman* *mena* *edu* *dispink* *Stockholm* *age* _cons)  xline(1) eform title("Occupation and COVID-19 mortality""Individuals older than 67") baselevels
graph export "\\micro.intra\Projekt\P0864$\P0864_Gem\MariaBo\old_cat.png", as(png) name("Graph") replace

