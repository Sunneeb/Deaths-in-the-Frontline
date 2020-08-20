* Copyright 2020, Maria Brandén, All rights reserved.

capture log close
cd "\\micro.intra\Projekt\P0864$\P0864_Gem\MariaBo\"
use paper_3_sample.dta, clear


mean expos if aged_67_plus==0
tab1 w_b_collar occupation age_5 woman mena edu_3 dispink_3 Stockholm if aged_67_plus==0

mean expos if aged_67_plus==0 & covid19==1
tab1 w_b_collar occupation age_5 woman mena edu_3 dispink_3 Stockholm if aged_67_plus==0 & covid19==1



mean max_expos if aged_67_plus==1
tab1 ant_lgh_blue_collar_dum ant_lgh_white_collar_dum ant_lgh_manager_dum ant_lgh_occ_other_dum ant_lgh_occ_cleaner_dum ant_lgh_occ_delivery_dum ant_lgh_occ_police_guard_dum ant_lgh_cashier_rest_dum ant_lgh_occ_teacher_dum ant_lgh_occ_butcher_dum ant_lgh_taxi_bus_dum ant_lgh_work_care_dum ant_lgh_it_technician_dum age_5 woman mena edu_3 dispink_3 Stockholm if aged_67_plus==1

mean max_expos if aged_67_plus==1 & covid19==1
tab1 ant_lgh_blue_collar_dum ant_lgh_white_collar_dum ant_lgh_manager_dum ant_lgh_occ_other_dum ant_lgh_occ_cleaner_dum ant_lgh_occ_delivery_dum ant_lgh_occ_police_guard_dum ant_lgh_cashier_rest_dum ant_lgh_occ_teacher_dum ant_lgh_occ_butcher_dum ant_lgh_taxi_bus_dum ant_lgh_work_care_dum age_5 ant_lgh_it_technician_dum woman mena edu_3 dispink_3 Stockholm if aged_67_plus==1 & covid19==1


