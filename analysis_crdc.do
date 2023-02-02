/*******************************************************************************

PROJECT:		School counselor blog post
FILE AUTHOR:	Katharine Meyer
FILE PURPOSE:	Figures using CRDC data combined with state policy data

*******************************************************************************/

********************************************************
*Figure 1 - What does staffing look like across regions?
********************************************************

	use "${stata}/crdc_1718_clean.dta",  clear
		
		*By region
		graph bar has_sch_ftecounselor has_full_sch_ftecounselor met_asca, over(region) blabel(total, format(%5.2f)) legend(on label(1 "Has any counselor") label(2 "Has 1 FTE counselor") label(3 "Student-counselor ratio meets ASCA standards") size(small)) ytitle("Percent" " ", size(small)) title("Figure 1. School counselor staffing by region", size(medsmall)) graphregion(color(white)) note("Source: Authors' calculations, Civil Rights Data Collection, 2017-18" "Notes: Meeting ASCA standard defined as having a student-to-counselor ratio of 250:1 or less." "CRDC does not distinguish count of individuals from FTE; one FTE could represent one individual or two 0.5 FTE individuals, or other permutations.", size(tiny))
			graph save "$output/state_staffing.gph", replace
			graph export "${output}/state_staffing.png", replace
				
	preserve
		collapse (mean) has_sch_ftecounselor has_full_sch_ftecounselor met_asca, by(region)
		export excel using "${output}/figure1_data.xls", firstrow(variables) replace
	restore
			
		*By student population
		gen majority_bl = share_bl>.5
		gen majority_hi = share_hi>.5
		gen majority_wh = share_wh>.5
		gen group = ""
			replace group = "Majority Black" if majority_bl == 1 & group == ""
			replace group = "Majority Hispanic" if majority_hi == 1 & group == ""
			replace group = "Majority White" if majority_wh == 1 & group == ""
			replace group = "Other Majority" if group == ""
		
		*Simplest regression
		reg has_full_sch_ftecounselor majority_bl, r
		
		*Fully considering local context
		bys region: su majority_bl
		areg has_full_sch_ftecounselor majority_bl, r a(lea_state)
		areg has_sch_ftecounselor majority_bl, r a(lea_state)
		bys region: areg has_full_sch_ftecounselor majority_bl, r a(lea_state)
		bys region: areg has_sch_ftecounselor majority_bl, r a(lea_state)
						
******************************************************************************
*Figure 3 - How does staffing vary by whether state mandates counselor ratios?
******************************************************************************
use "${stata}/crdc_1718_clean.dta",  clear

	*Run the regressions comparing states
	areg met_asca secondary_ratio, a(region) r
	bys region: reg met_asca secondary_ratio, r 
	
	areg counselor_ratio secondary_ratio, a(region) r
	bys region: reg counselor_ratio secondary_ratio, r 

	areg has_sch_ftecounselor secondary_ratio, a(region) r
	bys region: reg has_sch_ftecounselor secondary_ratio, r 
		
	*Create the graphs
	graph bar met_asca, over(secondary_ratio, relabel(1 "No State Mandated Ratio" 2 "State Mandated Student-Counselor Ratio")) asyvars bar(1, color(orange)) bar(2, color(blue)) over(region) blabel(total, format(%5.2f)) ytitle("Percent of schools with 250:1 or lower ratio" " ", size(small)) title("Figure 3. States with counselor policies more likely to meet ASCA standards", size(medsmall)) subtitle("By Census region", size(small)) graphregion(color(white))
			graph save "$output/state_asca.gph", replace
			graph export "${output}/state_asca.png", replace
	
	graph bar counselor_ratio, over(secondary_ratio, relabel(1 "No State Mandated Ratio" 2 "State Mandated Student-Counselor Ratio")) asyvars bar(1, color(orange)) bar(2, color(blue)) over(region) blabel(total, format(%5.2f)) ytitle("Student-Counselor Ratio" " ", size(small)) title("Figure 3. State counselor policies reduce counselor caseloads", size(medsmall)) subtitle("By Census region", size(small)) graphregion(color(white))
			graph save "$output/state_caseloads.gph", replace
			graph export "${output}/state_caseloads.png", replace

	preserve
		collapse (mean) counselor_ratio met_asca, by(region secondary_ratio)
		export excel using "${output}/figure3_data.xls", firstrow(variables) replace
	restore