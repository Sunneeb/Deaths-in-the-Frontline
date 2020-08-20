* Copyright 2020, Maria Brandén, All rights reserved.

cd "\\micro.intra\Projekt\P0864$\P0864_Gem\MariaBo"
set more off
use sample.dta, clear


** DEATHS***

* Cause of death, covid and all
clear
odbc load, table("Sos_r_cov_dors") dsn("P0864") lowercase 
gen Sos_r_cov_dors=1
duplicates tag lopnr , gen(dupl1)
drop if lopnr==5605427 & doddatum==19540419
drop dupl1
foreach i of varlist doddatum- icdkoder {
rename `i' `i'_cov
}
gen covid=1
save covid.dta, replace

clear
odbc load, table("Sos_r_dors_14745_2020") dsn("P0864") lowercase 
gen Sos_r_dors_14745_2020=1
duplicates tag lopnr , gen(dupl1)
destring dodsdat, replace
drop if dupl1==1 & dodsdat!=doddatum
drop dupl1

merge 1:1 lopnr using covid.dta

browse dodsdat_cov if _merge==2
* Those who are in the covid death file but not in the general death file are those who died recently
drop _merge
save covid.dta, replace


* MERGE TO MAIN SAMPLE
merge 1:1 lopnr using sample.dta
tab covid _merge, m

* 3 covid cases are not in population
drop if _merge==1

save sample.dta, replace

* Date of death is cleaned in a later do-file