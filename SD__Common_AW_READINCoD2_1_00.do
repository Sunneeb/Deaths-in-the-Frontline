* Copyright 2020, Sven Drefahl, All rights reserved.
capture log close _all
clear 

* Define some variables;
local today=subinstr("`c(current_date)'"," ","",.)
local time=subinstr("`c(current_time)'",":","",.)

* stata version compatibility
version 16.0

* log file number
local vnum="1_02"

* Register name
local register "COD2"

* Projectname
local project "READIN"

* Open log file;
log using "$logfilepath/StataLog_Common_AW_`project'_`register'_`vnum'_`today'_`time'", replace text name(ODBC`register')
local logname=r(name)

timer clear 1

*******************************
* Load 2020 Covid mortality

odbc load , table ("Sos_r_cov_dors") dsn("P0864") lowercase

	* Unicode stuff
	***************************************************

	save "$datafilepath/Common_AW_`project'`register'_temp", replace

	cd "$datafilepath"

	clear

	unicode encoding set "latin1"
		
	capture unicode translate Common_AW_`project'`register'_temp.dta

	unicode erasebackups, badidea

	cd "$dofilepath"
	
	***************************************************

	
	use "$datafilepath/Common_AW_`project'`register'_temp"
	
	
* Tag duplicates for later handling
duplicates tag lopnr, generate(dupl1)

gen errorcod2=.
label variable errorcod2 "Error in COD2, e.g. duplicate by lopnr"
replace errorcod2=1 if dupl1!=0

* keep only one random occurence of each duplicate
bys lopnr: generate double rand_temp=runiform()
bys lopnr (rand_temp): keep if _n==1
drop rand_temp dupl1

* keep lopnr ar dodsdatn ulorsak errorcod

* Convert data to stata date format
gen dyear=substr(dodsdatn, 1,4)
gen dmonth=substr(dodsdatn, 6,2)
gen dday=substr(dodsdatn, 9,2)

gen dyear2=substr(dodsdat, 1,4)
gen dmonth2=substr(dodsdat, 5,2)
gen dday2=substr(dodsdat, 7,2)

destring dyear, replace
destring dmonth, replace
destring dday, replace
destring dyear2, replace
destring dmonth2, replace
destring dday2, replace 

replace dyear=dyear2 if dyear==.
replace dmonth=dmonth2 if dmonth==.
replace dday=dday2 if dday==.

replace errorcod2=2 if dmonth<1 | dmonth>12
replace errorcod2=3 if dday<1 | dday>31

gen ddatecod=mdy(dmonth, dday, dyear)
replace errorcod=4 if ddate==.
format ddatecod %td

gen covid=1

drop doddatum dodsdat dodsdatn dyear dmonth dday dyear2 dmonth2 dday2
drop icdkoder

* Format Changes and Saving the file;
format lopnr %14.0g

compress *

save "$datafilepath/Common_AW_`project'`register'_t1", replace

*************************************************
* 2020 all cause mortality

clear

odbc load , table ("Sos_r_skverket_dors_avi_14745_2020") dsn("P0864") lowercase

* Tag duplicates for later handling
duplicates tag lopnr, generate(dupl1)

gen errorcod2=.
label variable errorcod2 "Error in COD2, e.g. duplicate by lopnr"
replace errorcod2=1 if dupl1!=0

* keep only one random occurence of each duplicate
bys lopnr: generate double rand_temp=runiform()
bys lopnr (rand_temp): keep if _n==1
drop rand_temp dupl1

* Convert data to stata date format
gen dyear=substr(dodsdatn, 1,4)
gen dmonth=substr(dodsdatn, 6,2)
gen dday=substr(dodsdatn, 9,2)

gen dyear2=substr(dodsdat, 1,4)
gen dmonth2=substr(dodsdat, 5,2)
gen dday2=substr(dodsdat, 7,2)

destring dyear, replace
destring dmonth, replace
destring dday, replace
destring dyear2, replace
destring dmonth2, replace
destring dday2, replace 

replace dyear=dyear2 if dyear==.
replace dmonth=dmonth2 if dmonth==.
replace dday=dday2 if dday==.

replace errorcod2=2 if dmonth<1 | dmonth>12
replace errorcod2=3 if dday<1 | dday>31

gen ddatecod=mdy(dmonth, dday, dyear)
replace errorcod=4 if ddate==.
format ddatecod %td

drop ar doddatum dodsdat dodsdatn dyear dmonth dday dyear2 dmonth2 dday2 distrikt

* Format Changes and Saving the file;
format lopnr %14.0g

compress *

save "$datafilepath/Common_AW_`project'`register'_t2", replace

*************************************************
* 2017-19 all cause mortality

clear

odbc load , table ("Sos_r_dors_14745_2020") dsn("P0864") lowercase

* Tag duplicates for later handling
duplicates tag lopnr, generate(dupl1)

gen errorcod2=.
label variable errorcod2 "Error in COD, e.g. duplicate by lopnr"
replace errorcod2=1 if dupl1!=0

* keep only one random occurence of each duplicate
bys lopnr: generate double rand_temp=runiform()
bys lopnr (rand_temp): keep if _n==1
drop rand_temp dupl1

drop morsak* daldman alkohol diabetes dodutl lkf

* Convert data to stata date format
tostring ar, replace
tostring doddatum, replace
gen dyear=substr(dodsdat, 1,4)
replace dyear=ar if dyear==""
gen dmonth=substr(dodsdat, 5,2)
gen dday=substr(dodsdat, 7,2)

gen dyear2=substr(doddatum, 1,4)
gen dmonth2=substr(doddatum, 5,2)
gen dday2=substr(doddatum, 7,2)

destring dyear, replace
destring dmonth, replace
destring dday, replace
destring dyear2, replace
destring dmonth2, replace
destring dday2, replace

replace dmonth=dmonth2 if dmonth<1 | dmonth>12
replace dday=dday2 if dday<1 | dday>31

replace errorcod=2 if dmonth<1 | dmonth>12
replace errorcod=3 if dday<1 | dday>31

gen ddatecod=mdy(dmonth, dday, dyear)
replace errorcod=4 if ddate==.
format ddatecod %td

drop ar doddatum dodsdat dyear dmonth dday dyear2 dmonth2 dday2 dod_kommun

* Append COD data 2020

*append using "$datafilepath/Common_AW_`project'`register'_t2"

*rename ddatecod ddatecod1
merge 1:1 lopnr ddatecod using "$datafilepath/Common_AW_`project'`register'_t2"

* Drop those duplicates with missing info on date of death in one duplicate
duplicates tag lopnr, generate(dupl1)
drop if ddatecod==. & dupl1!=0
drop dupl1

* Identify mismatches on date of death and keep errorcod
duplicates tag lopnr, generate(dupl2)
replace errorcod2=5 if dupl2!=0

* Keep only one of the occasions randomly
bys lopnr: generate double rand_temp=runiform()
bys lopnr (rand_temp): keep if _n==1
drop rand_temp dupl2

rename _merge _mergeCOD2020

* Merge with covid mortality

merge 1:1 lopnr ddatecod using "$datafilepath/Common_AW_`project'`register'_t1", update

* Drop those duplicates with missing info on date of death in one duplicate
duplicates tag lopnr, generate(dupl1)
drop if ddatecod==. & dupl1!=0
drop dupl1

* Identify mismatches on date of death and keep record
duplicates tag lopnr, generate(dupl2)
replace errorcod2=6 if dupl2!=0

* Keep only information from covid data
drop if dupl2!=0 & _merge==1
drop dupl2

rename _merge _mergeCODCovid

* Save combined file
save "$datafilepath/Common_AW_`project'`register'", replace

* Delete temporary files
erase "$datafilepath/Common_AW_`project'`register'_temp.dta"
erase "$datafilepath/Common_AW_`project'`register'_t1.dta"
erase "$datafilepath/Common_AW_`project'`register'_t2.dta"

timer list 1

log close `logname'



