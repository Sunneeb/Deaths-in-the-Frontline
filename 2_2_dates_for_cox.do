* Copyright 2020, Maria Brandén, All rights reserved.

cd "\\micro.intra\Projekt\P0864$\P0864_Gem\MariaBo"

clear
odbc load, table("Fodelseuppg_2020") dsn("P0864") lowercase 
duplicates tag lopnr , gen(dupl1)
drop if dupl1>=1 & senpnr==0

keep fodarman lopnr


** ADD NEW DEATH DATA; CLEANED BY SVEN (DERIVED FROM DO-FILE WITH SIMILAR NAME)
merge 1:1 lopnr using "\\micro.intra\Projekt\P0864$\P0864_Gem\MariaBo\Deaths\Common_AW_READINCOD2.dta" , 
keep if _merge!=2
keep lopnr ddatecod covid fodarman
rename ddatecod ddatecod_clean
rename covid covid_clean

merge 1:1 lopnr using final_sample.dta
keep if _merge==3
codebook fodarman
save final_sample.dta, replace



