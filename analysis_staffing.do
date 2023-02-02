/*******************************************************************************

PROJECT:		School counselor blog post
FILE AUTHOR:	Katharine Meyer
FILE DATE:		1/11/2023
FILE PURPOSE:	Summarize staffinng

*******************************************************************************/


*Analysis
use "${stata}/crdc_1718_clean.dta", clear
	keep if lea_state=="OK"
	egen keep = tag(sch_name lea_name) //Wilson HS duplicate
		keep if keep == 1
		capture drop keep
		isid sch_name lea_name
merge 1:m sch_name lea_name using "$stata/certified_1718_clean.dta"
	keep if _m==3
	capture drop _m
	egen school_flag = tag(sch_name lea_name) //use for school-level stats
	unique sch_name lea_name
	
*Job implementation
su only_counselor tot_counselor_jobs tot_counselor_schools counselor_fte_share ever_teacher ever_leader
	
	
*Staffing race relative to students	
	*Counselors
	preserve
		collapse (mean) black amin hisp white, by(lea_state)
		save "${stata}/counselorrace.dta", replace
	restore
	*Students
	preserve
		collapse (mean) share_bl share_am share_hi share_wh, by(lea_state)
		save "${stata}/studentrace.dta", replace
	restore
		
use "${stata}/counselorrace.dta", clear
	merge 1:1 lea_state using "${stata}/studentrace.dta"
	
		graph bar black share_bl amin share_am hisp share_hi, blabel(total, format(%5.2f)) ytitle("Percent" " ", size(small)) legend(on label(1 "Share Black Counselors") label(2 "Share Black Students") label(3 "Share American Indian/Native Counselors") label(4 "Share American Indian/Native Students") label(5 "Share Hispanic Counselors") label(6 "Share Hispanic Students") size(vsmall)) title("Figure 4. Racial and Ethnic Composition" "of Oklahoma Counselors and High School Students", size(medsmall)) subtitle("2017-18 academic year") graphregion(color(white))
			graph save "$output/demographics.gph", replace
			graph export "${output}/demographics.png", replace
		export excel using "${output}/figure4_data.xls", firstrow(variables) replace
	
*Job implementation
