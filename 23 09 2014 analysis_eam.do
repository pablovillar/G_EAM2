*******************************************
****** GAZELLES COLOMBIAN ANALYSIS  *******
****** ENCUESTA ANUAL MANUFACTURERA *******
******      SERIE 2005 - 2012       *******
*******************************************

**1. Declare panel data and balanced it
clear
cd "\\bdatos_server\SALA DE PROCESAMIENTO\THIN_19\PABLO VILLAR\ENTRA\EAM\panel"
use panel_clean, clear

drop if anope>periodo // Drop observations if the firm's creation year is after to survey year
					  // 213 observations were deleted of 64672 in total

xtset nordemp periodo
xtdescribe

g ano_seguido=.  // keep the firms with at least 4 consecutive years in surveys
by nordemp: replace ano_seguido=cond(L.ano_seguido==.,1,L.ano_seguido+1)
by nordemp: egen max_ano_seguido=max(ano_seguido)

by nordemp: g total_anos_ecuesta=_N
drop if max_ano_seguido<total_anos_ecuesta // keep if all surveys years are consecutive - 2360 observations deleted
 
keep if max_ano_seguido>=4 // with this we delete 6684 observations of 62099
drop *seguido

tab periodo, g(year) // generate a dummy per year, 0=there isn't survey for that year 1=yes
forval i=5(1)8 {
	forval j=1(1)2 {
		g sum_year`j'_year`i'=year`j'+year`i'
		by nordemp: egen total_sum_year`j'_year`i'=total(sum_year`j'_year`i')
		drop if total_sum_year`j'_year`i'==0
	}
} // this process delete firms that aren't continuing or exiting firms

xtdescribe

** Defining continuing and exiting firms
by nordemp: egen max_year8=max(year8)
g exiting_firm=(max_year8==0)
g continuing_firm=(max_year8==1)

drop year* max_year8 sum_year* total_sum_year*

label var continuing_firm "Continuing firms"
label var exiting_firm "Exiting firms"

* Distribution of continuing and exiting firms
graph pie continuing_firm exiting_firm if periodo==2005,  plabel(_all percent,  size(*1.5) color(white)) ///
plabel(_all name, gap(5) size(*1.5) color(white)) ///
legend(off) title("Distribution of continuing and exiting firms") ///
note(" " "Source: EAM, DANE" "             Calculated by authors")
graph export graph_pie.png , replace width(1000)

**2. Rename Variables Graphs
rename valorven ing_op
rename periodo year

**3. Create Variables GDP DEFLATOR and EXC
*GDP DEFLATOR*
g DFL2005=1
g DFL2006=1.0577059
g DFL2007=1.111059
g DFL2008=1.195007
g DFL2009=1.235732
g DFL2010=1.283385
g DFL2011=1.369695
g DFL2012=1.413117
g DFL2013=1.439407

g DFL_UNV=.

forval i=2005(1)2012 {
replace DFL_UNV=DFL`i' if year==`i' 
}

drop DFL20*

*Exchange rate*
g EXC=0.00044

**4. Generate USD and delfated variables
g ring_op=ing/DFL_UNV
g ring_op_usd=(ring_op*EXC)*1000 // it is multiplied by 1000 because the sales was in thousands pesos

**5. Generating Size of firms  (turning 0s into missing)

recode ring_op_usd (0.1/100000=1 "micro") (100000.1/19999999.9=2 "SME") (20000000/max=3 "large") (0 . =.), g(size) test

** Generating Size of firms  by second definition (in period t as the average of sales in t and t-1)
g average_ring_op_usd=(ring_op_usd + L.ring_op_usd)/2
recode average_ring_op_usd (0.1/100000=1 "micro") (100000.1/19999999.9=2 "SME") (20000000/max=3 "large") (0 . =.), g(size2) test

**6. Label the graphs variables
label var ring_op_usd "Sales Constant 2005 USD" 
label var size "Size (IADB and WB definitions)"
label var size2 "Size (Average of sales in t and t-1)"
label var year "Year"

**7. Set of Graphs 1: Distribution size per year
*In the report done without turning 0s into missing*
cd "\\bdatos_server\SALA DE PROCESAMIENTO\THIN_19\PABLO VILLAR\SALE\Graphics"
*Graph1. Mean sales divided by size per year*
* Graph1a. size (IDB and WB definitions)
graph bar (mean) ring_op_usd, over(size, label(angle(vertical))) over(year) ///
ylabel(,format(%14.0g) angle(horizontal)) ytitle("Mean of Sales Constant 2005 USD") ///
title("Mean Sales by size and year") subtitle("Size (IDB and WB definitions)") ///
note(" " "Source: EAM, DANE" "             Calculated by authors")
graph export graph1a.png , replace width(1000)
* Graph1b. size2 (in period t as the average of sales in t and t-1)
graph bar (mean) ring_op_usd, over(size2, label(angle(vertical))) over(year) ///
ylabel(,format(%14.0g) angle(horizontal)) ytitle("Mean of Sales Constant 2005 USD") ///
title("Mean Sales by size and year") subtitle("Size (As average of sales in t and t-1)") ///
note(" " "Source: EAM, DANE" "             Calculated by authors")
graph export graph1b.png , replace width(1000)


*Graph2. Distribution of size per year*
* Graph2a. size (IADB and WB definitions)
histogram size, discrete percent  xlabel(1 2 3, valuelabels) ylabel(10(40)90, labsize(small)) ///
by(year, title("Distribution of size per year") note("Source: EAM, DANE" "             Calculated by authors"))
graph export graph2a.png , replace width(1000)
* Graph2b. size2 (in period t as the average of sales in t and t-1)
histogram size2 if year!=2005, discrete percent  xlabel(1 2 3, valuelabels) ylabel(10(40)90, labsize(small)) ///
by(year, title("Distribution of size per year") note("Source: EAM, DANE" "             Calculated by authors"))
graph export graph2b.png , replace width(1000)

/* The next process in this comment will balance the panel last 5 year (acording to Supersociedades Analysis)
however, this isn't necesary in the reference document "Gazelles Colombia analysis update 9 03 2014.docx". 

**8. Create Balanced Panel: Balanced Panel Last 5 Years in sales **
xtbalance, range(2008 2012) miss(ing_op)   // (18439 observations deleted due to out of range) 
										   // (8428 observations deleted due to discontinues) 
										   //  We are left with 52.87% of the sample (30145)

cd "\\bdatos_server\SALA DE PROCESAMIENTO\THIN_19\PABLO VILLAR\ENTRA\EAM\panel"
save clean5year, replace

clear
cd "\\bdatos_server\SALA DE PROCESAMIENTO\THIN_19\PABLO VILLAR\ENTRA\EAM\panel"
use clean5year, clear
cd "\\bdatos_server\SALA DE PROCESAMIENTO\THIN_19\PABLO VILLAR\SALE\Graphics"

**9.Set of Graphs 1: Distribution size per year with the balanced panel**

*Graph3a. Mean sales divided by size per year size (IDB and WB definitions)*
graph bar (mean) ring_op_usd, over(size, label(angle(vertical))) over(year) ///
ylabel(,format(%14.0g) angle(horizontal)) ytitle("Mean of Sales Constant 2005 USD") ///
title("Mean Sales by size and year") subtitle("Size (IDB and WB definitions)" "Balanced panel 2008-2012") ///
note(" " "Source: EAM, DANE" "             Calculated by authors")
graph save graph3a , replace
* Graph3b. size2 (in period t as the average of sales in t and t-1)
graph bar (mean) ring_op_usd, over(size2, label(angle(vertical))) over(year) ///
ylabel(,format(%14.0g) angle(horizontal)) ytitle("Mean of Sales Constant 2005 USD") ///
title("Mean Sales by size and year") subtitle("Size (As average of sales in t and t-1)" "Balanced panel 2008-2012") ///
note(" " "Source: EAM, DANE" "             Calculated by authors")
graph save graph3b , replace


*Graph4. Distribution of size per year*
* Graph4a. size (IADB and WB definitions)
histogram size, discrete percent  xlabel(1 2 3, valuelabels) ylabel(10(40)90, labsize(small)) ///
by(year, title("Distribution of size per year") subtitle("Balanced panel 2008-2012") ///
note("Source: EAM, DANE" "             Calculated by authors"))
graph save graph4a , replace
* Graph4b. size2 (in period t as the average of sales in t and t-1)
histogram size2 if year!=2005, discrete percent  xlabel(1 2 3, valuelabels) ylabel(10(40)90, labsize(small)) ///
by(year, title("Distribution of size per year") subtitle("Balanced panel 2008-2012") ///
note("Source: EAM, DANE" "             Calculated by authors"))
graph save graph4b , replace

*/


**10. Set of Graphs 2 & Growth Rates*

*Generate growth rate*
bysort nordemp: g g_ring_op_usd=round(D.ring_op_usd/L.ring_op_usd , 0.001)
recode g_ring_op_usd (-1=.)
replace g_ring_op_usd=g_ring_op_usd*100

*Create ranges of growth with no growth detailed*
recode g_ring_op_usd (-100/-50=-8 "-100% to -50%") (-49.999/-40=-7 "-50% to -40%") ///
(-39.999/-30=-6 "-40% to -30%") (-29.999/-20=-5 "-30% to -20%") (-19.999/-15=-4 "-20% to -15%") ///
(-14.999/-10=-3 "-15% to -10%") (-9.999/-5=-2 "-10% to -5%") (-4.999/0=-1 "-5% to 0%") ///
(0.001/4.999=0 "0% to 5%") (5/9.999=1 "5% to 10%") ///
(10/19.999=2 "10% to 20%") (20/29.999=3 "20% to 30%") (30/39.999=4 "30% to 40%") ///
(40/49.999=5 "40% to 50%") (50/59.999=6 "50% to 60%") (60/69.999=7 "60% to 70%") ///
(70/79.999=8 "70% to 80%") (80/89.999=9 "80% to 90%") (90/99.999=10 "90% to 100%") ///
(100/149.999=11 "100% to 150%") (150/199.999=12 "150% to 200%") (200/299.999=13 "200% to 300%") ///
(300/399.999=14 "300% to 400%") (400/max=15 ">400%") (missing=.) ///
, g(range_growth) test
label var range_growth "Sales Growth (Range)"

*Graph 5. Distribution growth sales rangs*
* Only for continuing firms 
forval i=2006(1)2012 {
histogram range_growth if year==`i' & continuing_firm==1, discrete xlabel(-8(1)15, valuelabel angle(45) labsize(small)) ///
xtitle("Sales Growth (Range)") ytitle("Percent (%)") ylabel(#10) percent ///
by(year,title("Sales Growth for continuing firms") note("Source: EAM, DANE" "             Calculated by authors"))
graph export graph5_1_`i'.png , replace width(1000)
}

histogram range_growth if year!=2005 & continuing_firm==1, discrete percent  ///
xlabel(-8(1)15, valuelabel angle(45) labsize(tiny)) ylabel(#5, labsize(small)) ///
by(year, title("Distribution growth sales rangs per year") subtitle("Sales Growth for continuing firms") ///
note("Source: EAM, DANE" "             Calculated by authors"))
graph export graph5_1.png , replace width(1000)

* Only for exiting firms 
forval i=2006(1)2011 {
histogram range_growth if year==`i' & exiting==1, discrete xlabel(-8(1)15, valuelabel angle(45) labsize(small)) ///
xtitle("Sales Growth (Range)") ytitle("Percent (%)") ylabel(#10) percent ///
by(year,title("Sales Growth for exiting firms") note("Source: EAM, DANE" "             Calculated by authors"))
graph export graph5_2_`i'.png , replace width(1000)
}


histogram range_growth if year!=2005 & exiting==1, discrete percent  ///
xlabel(-8(1)15, valuelabel angle(45) labsize(tiny)) ylabel(#5, labsize(small)) ///
by(year, title("Distribution growth sales rangs per year") subtitle("Sales Growth for exiting firms") ///
note("Source: EAM, DANE" "             Calculated by authors"))
graph export graph5_2.png , replace width(1000)

* For overall firms 
forval i=2006(1)2012 {
histogram range_growth if year==`i', discrete xlabel(-8(1)15, valuelabel angle(45) labsize(small)) ///
xtitle("Sales Growth (Range)") ytitle("Percent (%)") ylabel(#10) percent ///
by(year,title("Sales Growth for overall firms") note("Source: EAM, DANE" "             Calculated by authors"))
graph export graph5_`i'.png , replace width(1000)
}

histogram range_growth if year!=2005 & exiting==1, discrete percent  ///
xlabel(-8(1)15, valuelabel angle(45) labsize(tiny)) ylabel(#5, labsize(small)) ///
by(year, title("Distribution of growth sales rangs per year") subtitle("Sales Growth for overall firms") ///
note("Source: EAM, DANE" "             Calculated by authors"))
graph export graph5.png , replace width(1000)


*OJO
** Grah Means of annual sales growth across years and plot the mean distributions as well.
* Graph6. 
graph bar (mean) g_ring_op_usd, over(year) ///
ylabel(,format(%14.0g) angle(horizontal)) ytitle("Mean of Sales Constant 2005 USD") ///
title("Mean Sales by size and year") subtitle("Size (IDB and WB definitions)") ///
note(" " "Source: EAM, DANE" "             Calculated by authors")

graph export graph1a.png , replace width(1000)
over(size, label(angle(vertical)))




*******
*OJO***
*Generate second growth rate as sales at time period T minus sales growth at time period T-1 divided by the average of sales at T and T-1*
bysort nordemp: g g_ring_op_usd=round(D.ring_op_usd/L.ring_op_usd , 0.001)
recode g_ring_op_usd (-1=.)
bysort nordemp: g g_ring_op_usd_2=round((g_ring_op_usd - L.g_ring_op_usd)/((g_ring_op_usd + L.g_ring_op_usd)/2) , 0.01) 





**Graph 7a: Creating Aggregate Sales Growth*

bysort year: egen total_sales=total(ring_op_usd)
xtset nordemp year
bysort nordemp: g gtotal_sales=round(D.total_sales/L.total_sales , 0.001)
replace gtotal_sales=gtotal_sales*100

graph twoway bar gtotal_sales year if year!=2008,  ytitle(Growth of Aggregate Sales (%)) ///
title("Growth of Aggregate Sales by year") note("Source: EAM, DANE" "             Calculated by authors")

