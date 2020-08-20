* Copyright 2020, Maria Brandén, All rights reserved.


cd "\\micro.intra\Projekt\P0864$\P0864_Gem\MariaBo"
set more off

* Set years for the different registers

*2019  RTB
global yearRTB=2019

*2018  LISA
global yearLISA=2018

*2019  Hushåll
global yearHushall=2019

*2019  sams deso
global yearSAMSDeSOInd=2019

* Total population
clear
odbc load, table("RTB$yearRTB") dsn("P0864") lowercase 
duplicates tag lopnr , gen(dupl1)
drop if dupl1>=1 & senpnr==0
keep lopnr kommun medblandgrp lan
save sample.dta, replace

* Background data
clear
odbc load, table("Totalpopulation_2020") dsn("P0864") lowercase 
duplicates tag lopnr , gen(dupl1)
drop if dupl1>=1 & senpnr==0
keep lopnr fodar kon  fodelselandgrp
merge 1:1 lopnr using sample.dta
keep if _merge!=1
rename _merge _merge_background
save sample.dta, replace

* Add old bakgrunddata so we know the exposure (since this is the sample we have deaths for, from Socialstyrelsen)
clear
odbc load, table("Totalpopulation") dsn("P0864") lowercase 
duplicates tag lopnr , gen(dupl1)
drop if dupl1>=1 & senpnr==0
keep lopnr foddar
merge 1:1 lopnr using sample.dta
gen in2017pop=1 if _merge==3

keep if _merge!=1
drop _merge
save sample.dta, replace

* Add LISA
clear
odbc load, table("LISA$yearLISA") dsn("P0864") lowercase 
duplicates tag lopnr , gen(dupl1)
drop if dupl1>=1 & senpnr==0
keep lopnr ssyk3_2012 ssyk4_2012 syssstat11 sun* dispink04 alos* arblos*
merge 1:1 lopnr using sample.dta

tab fodar _merge 
drop if _merge==1
drop _merge
save sample.dta, replace

* Dwelling register
clear
odbc load, table("Hushall$yearHushall") dsn("P0864") lowercase 
duplicates tag lopnr , gen(dupl1)
drop if dupl1>=1 & senpnr==0
keep lopnr antrum- lopnrlgh
merge 1:1 lopnr using sample.dta
tab fodar _merge 

drop if _merge==1
drop _merge
save sample.dta, replace

* DeSO
clear
odbc load, table("SAMSDeSOInd$yearSAMSDeSOInd") dsn("P0864") lowercase 
duplicates tag lopnr , gen(dupl1)
drop if dupl1>=1 & senpnr==0
keep lopnr deso
merge 1:1 lopnr using sample.dta
tab fodar _merge 

drop if _merge==1
drop _merge
save sample.dta, replace

* Names of birth countries
clear
import delimited "countryLabel.txt", delimiters(tab)
drop v3
rename birthcountry fodelselandgrp
destring fodelselandgrp, replace
merge 1:m fodelselandgrp using sample.dta
drop _merge
save sample.dta, replace


