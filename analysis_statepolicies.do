/*******************************************************************************

PROJECT:		School counselor blog post
FILE AUTHOR:	Katharine Meyer
FILE PURPOSE:	Figures using CRDC data combined with state policy data

*******************************************************************************/

*Run analyses	
use "${stata}/state_policies.dta", clear	

	graph bar elementary_mandate secondary_mandate secondary_ratio, over(region) blabel(total, format(%5.2f)) bargap(20) legend(on label(1 "Mandates Elementary Counseling") label(2 "Mandates Secondary Counseling") label(3 "Mandates Secondary Student-Counselor Ratio") col(1) size(small)) title("Figure 2. State School Counseling Policies", size(medsmall)) ytitle("Share of States with policy, within Region" " ", size(small)) yscale(range(0 1)) ylabel(0(.2)1) graphregion(color(white)) note("Source: American School Counseling Association, School Counseling Legislation" "Notes: Draws on ASCA legislative coding of state school counseling legislation. States coded as having ratio mandate if mandated (not just recommended)" "and stated specific threshold for counselor staffing.", size(tiny))
	graph save "${output}/state_policies.gph", replace
	graph export "${output}/state_policies.png", replace
	
*Export for map
use "${stata}/state_policies.dta", clear	
		gen threshold = ""
			replace threshold = "0" if strrpos(secondarythreshold, "None")
			replace threshold = secondarythreshold if strrpos(secondarythreshold, "None")!=1
			replace threshold = trim(threshold)
			replace threshold = "0" if strrpos(secondarythreshold, "Every")
			replace threshold = "450" if strrpos(secondarythreshold, "450*")
			replace threshold = "500" if strrpos(secondarythreshold, "500-749")
			destring threshold, replace
		tab threshold secondary_ratio, m
		keep state threshold
		export excel using "${output}/figure2map_data.xls", firstrow(variables) replace

