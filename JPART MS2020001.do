use "C:\Users\jason\OneDrive\Data\Habitat\oldStataHPI.dta", clear

sort dmu year

gen lntotal = ln(TotalNRRR)
gen lnprogram = ln(TOTAL_PROGRAM_SERVICES)
gen lnoverhead = ln(TOTAL_MANAGEMENT)
gen lnvol = ln(TOT_VOLUNTEERS)
gen lnemp = ln(ALL_YEAR_EMPLOYEES)
gen lncontrib = ln(CONTRIB_ALL)
gen lnfundexp = ln(TOTAL_FUNDRAISING)
gen percnew = New / TotalNRRR
gen lnscore = ln(score)
gen overhead2 = TOTAL_MANAGEMENT^2
gen oratio = TOTAL_MANAGEMENT / (TOTAL_MANAGEMENT + TOTAL_PROGRAM_SERVICES)
gen lnexpenses = ln(EXPENSES_TOTAL)
gen lnnew = ln(New)
gen lnrecycle = ln(Recycle)
gen lnrehab = ln(Rehab) 
gen lnrepair = ln(Repair)
gen lnsavings = ln(SAVINGS_EOY)
gen lnassets = ln(ASSETS_TOTAL_EOY)
gen age = year - FORMATION_YEAR
gen lnage = ln(age)
gen overheadsq = TOTAL_MANAGEMENT^2

gen year2010 = 0
replace year2010 =1 if year== 2010
gen year2011 = 0
replace year2011 =1 if year== 2011
gen year2012 = 0
replace year2012 =1 if year== 2012
gen year2013 = 0
replace year2013 =1 if year== 2013
gen year2014 = 0
replace year2014 =1 if year== 2014
gen year2015 = 0
replace year2015 =1 if year== 2015
gen year2016 = 0
replace year2016 =1 if year== 2016

gen lnHPI=ln(HPI)
gen lnHPI90=ln(HPIwith1990base)
gen lngov = ln(GOV_GRANTS)
gen lnsales = ln(GROSS_SALES)
gen lncontribgoods = ln(CONTRIB_NONCASH) 
gen lncontribother = ln(CONTRIB_OTHER)
gen lnservice = ln(SERVICE_REVENUE) 
gen donations = CONTRIB_ALL - GOV_GRANTS
gen lndonations = ln(donations)

*Data Table
preserve
drop if TOTAL_FUNDRAISING ==0
drop if TotalNRR ==0
drop if TOTAL_PROGRAM_SERVICES ==0
drop if TOTAL_MANAGEMENT ==0
drop if CONTRIB_ALL ==0
tabout TOTAL_PROGRAM_SERVICES TOTAL_MANAGEMENT TotalNRRR New Recycle Rehab Repair CONTRIB_ALL TOTAL_FUNDRAISING percnew score oratio HPI using donorsdatatable2.doc, replace
restore

*No government grants data table
preserve
keep if GOV_GRANTS ==.
summarize TOTAL_PROGRAM_SERVICES TotalNRRR TOTAL_MANAGEMENT New Recycle Rehab Repair CONTRIB_ALL TOTAL_FUNDRAISING HPI
restore


*USE These for contributions paper
xtreg lncontrib l.lncontrib lnfundexp score, fe robust
xtreg lncontrib l.lncontrib lnfundexp l.score, fe robust

xtabond lncontrib lnfundexp percnew lntotal score oratio year2010-year2016, twostep vce(robust) inst(HPI)
estat abond

xtabond lncontrib lnfundexp percnew lntotal year2010-year2016, twostep vce(robust) inst(HPI)
estat abond
outreg2 using performance.doc, replace ctitle(Total Houses) stats(coef se) keep(lnfundexp percnew lntotal) addtext(Year FE, YES) 

xtabond lncontrib lnfundexp percnew lntotal lnscore year2010-year2016, twostep vce(robust) inst(HPI)
estat abond
outreg2 using performance.doc, append ctitle(DEA Efficiency) stats(coef se) keep(lnfundexp percnew lntotal lnscore) addtext(Year FE, YES) 

xtabond lncontrib lnfundexp percnew lntotal lnscore lngov oratio year2010-year2016, twostep vce(robust) inst(HPI)
estat abond
outreg2 using performance.doc, append ctitle(Overhead Ratio) stats(coef se) keep(lnfundexp percnew lntotal lnscore oratio) addtext(Year FE, YES) 


*Corrected donations findings
xtabond lndonations lnfundexp percnew lntotal lnscore lngov oratio year2010-year2016, twostep vce(gmm) inst(HPI)
outreg2 using govtperformance.doc, replace ctitle(Donors) stats(coef se) keep(lnfundexp lntotal lnscore lngov oratio) addtext(Year FE, YES) 
xtabond lngov lntotal lnscore oratio percnew lndonations year2010-year2016, twostep vce(gmm) inst(HPI)
outreg2 using govtperformance.doc, append ctitle(Government) stats(coef se) keep(lntotal lnscore lncontrib oratio) addtext(Year FE, YES) 
estat abond

xtabond lndonations lnfundexp lntotal lnoverhead lngov lnprogram year2010-year2016, twostep vce(gmm) inst(HPI)
outreg2 using govtperformancefixed2.doc, replace ctitle(Donors) stats(coef se) keep(lnfundexp lntotal lnscore lngov oratio) addtext(Year FE, YES) 
xtabond lngov lntotal lnoverhead lnprogram lndonations year2010-year2016, twostep vce(gmm) inst(HPI)
outreg2 using govtperformancefixed2.doc, append ctitle(Government) stats(coef se) keep(lntotal lnscore lncontrib oratio) addtext(Year FE, YES) 
estat abond


xtabond lngov lntotal lnscore oratio percnew lncontrib year2010-year2016, twostep vce(gmm) inst(HPI)
est sto govtperf
margins lntotal

xtabond lngov l(0/1).lntotal l(0/1).lnscore l(0/1).oratio l(0/1).lncontrib year2010-year2015, twostep vce(gmm) inst(HPI)
xtabond lngov l(0/1).lntotal l(0/1).lnscore l(0/1).oratio l(0/1).lncontrib year2010-year2014, twostep vce(gmm) inst(HPI)
xtabond lngov l(0/1).lntotal l(0/1).oratio l(0/1).lncontrib year2010-year2013, twostep vce(gmm) inst(HPI)

graph twoway (lfit lngov lntotal) (lfit lncontrib lntotal)

xtabond lncontrib lnfundexp percnew lntotal lnscore lngov oratio year2010-year2016, twostep vce(gmm) inst(HPI)
predict contribhat
xtabond lngov lntotal lnscore oratio percnew lncontrib year2010-year2016, twostep vce(gmm) inst(HPI)
predict govhat
graph twoway (lfit govhat lntotal) (lfit contribhat lntotal) if lntotal<4.1

*System GMM models
xtabond2 lndonations l.lntotal l.lnexpenses l.lnHPI l.lnfundexp, gmm(lndonations l.lntotal l.lnexpenses l.lnHPI l.lnfundexp) iv(year2013-year2016) robust twostep small 
xtabond2 lngov l.lntotal l.lnexpenses l.lnHPI year2013-year2016, gmm(lngov l.lntotal l.lnexpenses l.lnHPI) iv(year2013-year2016) robust twostep small 

xtabond2 lndonations l.lndonations l.lntotal l.lnexpenses l.lnHPI l.lnfundexp, gmm(l.lndonations l.lntotal l.lnexpenses l.lnHPI l.lnfundexp) iv(year2013-year2016) robust twostep small 
xtabond2 lngov l.lngov l.lntotal l.lnexpenses l.lnHPI year2013-year2016, gmm(l.lngov l.lntotal l.lnexpenses l.lnHPI) iv(year2013-year2016) robust twostep small 



*Round 2 Rerun robust Model
xtabond2 lndonations l.lndonations l.lntotal l.lnfundexp year2013-year2016, gmm(l.lndonations l.lntotal l.lnfundexp year2013-year2016) iv(year2013-year2016 lnHPI) robust small orthogonal 
estimates store D
predict donorshat
outreg2 using govtperformanceR2.doc, replace ctitle(Donors) stats(coef se pval) keep(l.lndonations l.lntotal l.lnfundexp) addstat(Hansen Test, e(hansenp), F Stat, e(F)) addtext(Year FE, YES) 


xtabond2 lngov l.lngov l.lntotal year2013-year2016, gmm(l.lngov l.lntotal year2013-year2016) iv(year2013-year2016 HPI) robust small orthogonal 
estimates store G
predict governmenthat
outreg2 using govtperformanceR2.doc, append ctitle(Government Funding) stats(coef se pval) keep(l.lngov l.lntotal) addstat(Hansen Test, e(hansenp), F Stat, e(F)) addtext(Year FE, YES) 

graph twoway (lfit governmenthat l.lntotal) (scatter governmenthat l.lntotal) (lfit donorshat l.lntotal) (scatter donorshat l.lntotal) 

*Coefficient Plot
 coefplot D, bylabel(Donations) ///
|| G, bylabel(Government Funding)  ///
||, drop(_cons) keep(L.lntotal) xline(0)

coefplot D, bylabel(Donations) || G, bylabel(Government Funding) ///
||, drop(_cons) keep(L.lntotal) xline(0) byopts(compact cols(1))


*Instrument checks
xtreg l.lntotal HPI, robust
xtreg l.lngov l.lntotal HPI, robust
xtreg l.lndonations l.lntotal HPI, robust

xtivreg lngov l.lngov (l.lntotal = l.HPI) year2013-year2016, re small
xtivreg lngov l.lngov (l.lntotal = l.HPI) year2013-year2016, first small
xtoverid


*Reviewer 3 problems
xtabond2 lngov l.lngov l.lntotal year2013-year2016, gmm(l.lngov l.lntotal year2013-year2016) iv(year2013-year2016 HPI lnservice) robust small orthogonal 
gen lnnoncash = ln(CONTRIB_NONCASH)
gen lncash = ln(CONTRIB_OTHER)
xtabond2 lnnoncash l.lnnoncash l.lntotal l.lnfundexp year2013-year2016, gmm(l.lndonations l.lntotal l.lnfundexp year2013-year2016) iv(year2013-year2016 lnHPI) robust small orthogonal 
xtabond2 lncash l.lncash l.lntotal l.lnfundexp year2013-year2016, gmm(l.lndonations l.lntotal l.lnfundexp year2013-year2016) iv(year2013-year2016 lnHPI) robust small orthogonal 

xtabond2 lngov l.lngov l.lntotal l.lnprogram year2013-year2016, gmm(l.lngov l.lntotal l.lnprogram year2013-year2016) iv(year2013-year2016 HPI lnservice) robust small orthogonal
outreg2 using reviewer3checkR2.doc, replace ctitle(Donors) stats(coef se pval) keep(l.lndonations l.lntotal l.lnprogram) addstat(Hansen Test, e(hansenp), F Stat, e(F)) addtext(Year FE, YES) 
 
xtabond2 lngov l.lngov l.lntotal l.lnservice year2013-year2016, gmm(l.lngov l.lntotal l.lnservice year2013-year2016) iv(year2013-year2016 HPI lnservice) robust small orthogonal 
outreg2 using reviewer3checkR2.doc, append ctitle(Donors) stats(coef se pval) keep(l.lndonations l.lntotal l.lnservice) addstat(Hansen Test, e(hansenp), F Stat, e(F)) addtext(Year FE, YES) 


xtabond2 lngov l.lngov l.lntotal year2013-year2016, gmm(l.lngov l.lntotal year2013-year2016) iv(year2013-year2016 HPI) robust small orthogonal 


