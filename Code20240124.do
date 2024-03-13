set trace off
clear
set more off
set matsize 800

global basedirectory="D:\Documents\Research\Groundwater\Paper\Groundwater & Agriculture"
global Code="$basedirectory\Code"
global Data="$basedirectory\Data"
global Output="$basedirectory\Output"

log using "$Output/Results.log",name(Results) replace



****************************************
***********  Summary statistics (Table 1)

// Input and Output
use "$Data\ATFP20240124.dta",clear 
replace Water=Water/10
replace Yield=Yield/10
sum Labor Machinery Fertilizer Water Land Yield  //N=670
//  Groundwater Use and Control variables
use "$Data\PanelData20240124",clear
sum GWU x1 x2 x3 x4 x5 x6 x7 








****************************************
*************  ATFP results (Table 2, Table A1)

use "$Data\ATFP20240124.dta",clear 
xtset id year  
*** Rename
gen y = Yield
gen l = Labor
gen k = Machinery
gen f = Fertilizer
gen w = Water
gen m = Land
sum y l k f w
*** Make sure input and output factors are in logarithmic form
gen ly = log(y)
gen ll = log(l)
gen lk = log(k)
gen lf = log(f)
gen lw = log(w)
gen lm = log(m)
*** Define IDF variables
gen ly2 = 0.5*ly*ly
generate lmneg = - lm
generate tilde_l = ll-lm
generate tilde_k = lk-lm
generate tilde_f = lf-lm
generate tilde_w = lw-lm
generate lyltl = ly*tilde_l
generate lyltk = ly*tilde_k
generate lyltf = ly*tilde_f
generate lyltw = ly*tilde_w
generate ltlltl = 0.5*tilde_l*tilde_l
generate ltlltk = 0.5*tilde_l*tilde_k
generate ltlltf = 0.5*tilde_l*tilde_f
generate ltlltw = 0.5*tilde_l*tilde_w
generate ltkltk = 0.5*tilde_k*tilde_k
generate ltkltf = tilde_k*tilde_f
generate ltkltw = tilde_k*tilde_w
generate ltfltf = 0.5*tilde_f*tilde_f
generate ltfltw = tilde_f*tilde_w
generate ltwltw = 0.5*tilde_w*tilde_w
gen t = year-2009
gen tt = 0.5*t*t
gen tly = t*ly
generate ltlt = tilde_l*t
generate ltkt = tilde_k*t
generate ltft = tilde_f*t
generate ltwt = tilde_w*t


*  TFP Results

**   baseline:
// TL-Water-nNeutral  (SFA-IDF，translog function，constant return to scale)
global xlist ly ly2 tilde_l ltlltl tilde_k ltkltk tilde_f ltfltf tilde_w ltwltw lyltl lyltk lyltf ltlltk ltlltf lyltw ltlltw ltkltf ltkltw ltfltw t tt tly ltlt ltkt ltft ltwt
xtfrontier lmneg $xlist ,tvd    //log(L)=926.82819 
outreg2 using table2.doc,replace bdec(3) tdec(2) ctitle(y)
estat ic   // AIC = -1789.656 
est sto UM
matrix b1 = e(b)
predict yhat
predict TE, te
drop yhat 
generate TC = _b[t] + _b[tt]*t + _b[tly]*ly + _b[ltlt]*tilde_l + _b[ltkt]*tilde_k+ _b[ltft]*tilde_f + _b[ltwt]*tilde_w

**   the other TFPs & LR test results
// CD-Water-nNeutral  (the IDF function follows the form of the Cobb-Douglas input function)
global xlist1 ly tilde_l tilde_k tilde_f tilde_w t tt tly ltlt ltkt ltft ltwt
xtfrontier lmneg $xlist1,tvd 
outreg2 using table2.doc,append bdec(3) tdec(2) ctitle(y)
estat ic     //AIC = -1604.519
est sto RM1   //log(L)=819.25971 
lrtest UM RM1  //LR test: LR chi2(16)=215.14; Prob>chi2=0.0000
matrix b1 = e(b)
predict TE1, te
generate TC1 = _b[t] + _b[tt]*t + _b[tly]*ly + _b[ltlt]*tilde_l + _b[ltkt]*tilde_k+ _b[ltft]*tilde_f + _b[ltwt]*tilde_w

// TL-Water-nNeutral with no technical progress 
global xlist2 ly ly2 lyltl lyltk lyltf lyltw tilde_l tilde_k tilde_f tilde_w ltlltl ltlltk ltlltf ltlltw ltkltk ltkltf ltkltw ltfltf ltfltw ltwltw 
sfpanel lmneg $xlist2, model(bc92) //log(L)=810.8118
di -2*( 810.8118-926.82819 ) //232.03278

// TL-Water-Neutral   (technological progress is Hicks-neutral)
global xvar3 ly ly2 tilde_l ltlltl tilde_k ltlltk tilde_f ltlltf tilde_w ltlltw lyltl lyltk lyltf ltkltk ltkltf lyltw ltkltw ltfltf ltfltw ltwltw t tt
xtfrontier lmneg $xvar3,tvd  //超越对数
outreg2 using table2.doc,append bdec(3) tdec(2) ctitle(y)
estat ic   //AIC=-1738.188
est sto RM3
lrtest UM RM3
matrix b1 = e(b)
predict TE2, te
generate TC2 = _b[t] + _b[tt]*t 

// TL-Water-nNeutral with constant technical inefficiency term
xtfrontier lmneg $xlist,ti
//outreg2 using table2.doc,append bdec(3) tdec(2) ctitle(y)
estat ic  //AIC=-1649.211
di -2*( 855.6054 -926.82819 ) //142.44558
matrix b1 = e(b)
predict TE3, te
generate TC3 = _b[t] + _b[tt]*t + _b[tly]*ly + _b[ltlt]*tilde_l + _b[ltkt]*tilde_k+ _b[ltft]*tilde_f + _b[ltwt]*tilde_w

// TL-nWater-nNeutral
global xlist4 ly ly2 tilde_l ltlltl tilde_k ltkltk tilde_f ltfltf lyltl lyltk lyltf ltlltk ltlltf ltkltf t tt tly ltlt ltkt ltft 
xtfrontier lmneg $xlist4,tvd 
outreg2 using table2.doc,append bdec(3) tdec(2) ctitle(y)
estat ic  //AIC=-1779.042
matrix b1 = e(b)
predict TE4, te
generate TC4 = _b[t] + _b[tt]*t + _b[tly]*ly + _b[ltlt]*tilde_l + _b[ltkt]*tilde_k+ _b[ltft]*tilde_f 













****************************************
************* Panel results
use "$Data\PanelData20240124",clear
xtset id year
gen y = ln(TFP)
gen x = GWU
global c x1 x2 x3 x4 x5 x6 x7




* Panel estimates results (table 3)

** Column(1)
ivregress 2sls y (x=WR) l.y ,robust
//ivreg2 y (x=WR) l.y ,robust
outreg2 using table3.doc,replace bdec(3) tdec(2) ctitle(y)

** Column(2)
ivregress 2sls y (x=WR) l.y $c ,robust
outreg2 using table3.doc,append bdec(3) tdec(2) ctitle(y)

** Column(3)
ivregress 2sls y (x=WR) $c i.id i.year,robust
outreg2 using table3.doc,append bdec(3) tdec(2) ctitle(y)

** Column(4)
xtabond2 y l.y x $c WR, gmm(l.y,l(1 4) collapse) gmm(x,l(1 .) collapse) gmm(x1,l(1 4) collapse)gmm(x2,l(1 4) collapse)gmm(x3,l(1 4) collapse)gmm(x4,l(1 4) collapse) gmm(x5,l(1 4) collapse)gmm(x6,l(1 4) collapse)gmm(x7,l(1 4) collapse) iv(WR) robust twostep small orthogonal
outreg2 using table3.doc,append bdec(3) tdec(2) ctitle(y)

** Column(5): baseline
xtabond2 y l.y x $c WR, gmm(l.y,l(1 4) collapse) gmm(x,l(1 4) collapse) gmm(x1,l(1 4) collapse)gmm(x2,l(1 4) collapse)gmm(x3,l(1 4) collapse)gmm(x4,l(1 4) collapse) gmm(x5,l(1 4) collapse)gmm(x6,l(1 4) collapse)gmm(x7,l(1 4) collapse) iv(WR i.year) robust twostep small orthogonal
outreg2 using table3.doc,append bdec(3) tdec(2) ctitle(y)





*  The results of other ATFPs and land output values (table 4)

** Column(1): Baseline, TL-Water-nNeutral
replace y = ln(TFP)
replace x = GWU
xtabond2 y l.y x $c WR, gmm(l.y,l(1 4) collapse) gmm(x,l(1 4) collapse) gmm(x1,l(1 4) collapse)gmm(x2,l(1 4) collapse)gmm(x3,l(1 4) collapse)gmm(x4,l(1 4) collapse) gmm(x5,l(1 4) collapse)gmm(x6,l(1 4) collapse)gmm(x7,l(1 4) collapse) iv(WR i.year) robust twostep small orthogonal
//Arellano-Bond test for AR(2) in first differences: z =   0.20  Pr > z =  0.843
//Hansen test of overid. restrictions: chi2(44)   =  56.72  Prob > chi2 =  0.123
outreg2 using table4.doc,replace bdec(3) tdec(2) ctitle(y)

** Column(2): CD-Water-nNeutral
replace y = ln(TFP1)
xtabond2 y l.y x $c WR, gmm(l.y,l(1 4) collapse) gmm(x,l(1 4) collapse) gmm(x1,l(1 4) collapse)gmm(x2,l(1 4) collapse)gmm(x3,l(1 4) collapse)gmm(x4,l(1 4) collapse) gmm(x5,l(1 4) collapse)gmm(x6,l(1 4) collapse)gmm(x7,l(1 4) collapse) iv(WR i.year) robust twostep small orthogonal
//Arellano-Bond test for AR(2) in first differences: z =  -1.12  Pr > z =  0.261
//Hansen test of overid. restrictions: chi2(44)   =  51.52  Prob > chi2 =  0.203
outreg2 using table4.doc,append bdec(3) tdec(2) ctitle(y)

** Column(3): TL-Water-Neutral
replace y = ln(TFP2)
xtabond2 y l.y x $c WR, gmm(l.y,l(1 4) collapse) gmm(x,l(1 4) collapse) gmm(x1,l(1 4) collapse)gmm(x2,l(1 4) collapse)gmm(x3,l(1 4) collapse)gmm(x4,l(1 4) collapse) gmm(x5,l(1 4) collapse)gmm(x6,l(1 4) collapse)gmm(x7,l(1 4) collapse) iv(WR i.year) robust twostep small orthogonal
//Arellano-Bond test for AR(2) in first differences: z =  -0.52  Pr > z =  0.606
//Hansen test of overid. restrictions: chi2(44)   =   51.15  Prob > chi2 =  0.213
outreg2 using table4.doc,append bdec(3) tdec(2) ctitle(y)

/*/*TFP3*/
replace y = ln(TFP3)
xtabond2 y l.y x $c WR, gmm(l.y,l(1 4) collapse) gmm(x,l(1 4) collapse) gmm(x1,l(1 4) collapse)gmm(x2,l(1 4) collapse)gmm(x3,l(1 4) collapse)gmm(x4,l(1 4) collapse) gmm(x5,l(1 4) collapse)gmm(x6,l(1 4) collapse)gmm(x7,l(1 4) collapse) iv(WR i.year) robust twostep small orthogonal
//Arellano-Bond test for AR(2) in first differences: z =   -1.53  Pr > z =  0.126
//Hansen test of overid. restrictions: chi2(44)   =  51.38  Prob > chi2 =  0.207
outreg2 using table4.doc,append bdec(3) tdec(2) ctitle(y)  */

** Column(4): TL-nWater-nNeutral
replace y = ln(TFP4)
xtabond2 y l.y x $c WR, gmm(l.y,l(1 4) collapse) gmm(x,l(1 4) collapse) gmm(x1,l(1 4) collapse)gmm(x2,l(1 4) collapse)gmm(x3,l(1 4) collapse)gmm(x4,l(1 4) collapse) gmm(x5,l(1 4) collapse)gmm(x6,l(1 4) collapse)gmm(x7,l(1 4) collapse) iv(WR i.year) robust twostep small 
//Arellano-Bond test for AR(2) in first differences: z =  -1.65  Pr > z =  0.099
//Hansen test of overid. restrictions: chi2(44)   =  52.52  Prob > chi2 =  0.177
outreg2 using table4.doc,append bdec(3) tdec(2) ctitle(y)

** Column(5): Yield per hectare
replace y = ln(yield/Land)
xtabond2 y l.y x $c WR, gmm(l.y,l(1 4) collapse) gmm(x,l(1 3) collapse) gmm(x1,l(1 3) collapse)gmm(x2,l(1 3) collapse)gmm(x3,l(1 3) collapse)gmm(x4,l(1 3) collapse) gmm(x5,l(1 3) collapse)gmm(x6,l(1 3) collapse)gmm(x7,l(1 3) collapse) iv(WR i.year) robust twostep small orthogonal
//Arellano-Bond test for AR(2) in first differences: z =   0.21  Pr > z =  0.835
//Hansen test of overid. restrictions: chi2(36)   =  41.03  Prob > chi2 =  0.260
outreg2 using table4.doc,append bdec(3) tdec(2) ctitle(y)





*  Panel estimates of the impacts of groundwater exploitation on ATFP (Table A2)

** Column (1)-(3): y=TFP (TL-Water-nNeutral)
*  x=GWU
replace y = ln(TFP)
replace x = GWU
xtabond2 y l.y x $c WR, gmm(l.y,l(1 4) collapse) gmm(x,l(1 4) collapse) gmm(x1,l(1 4) collapse)gmm(x2,l(1 4) collapse)gmm(x3,l(1 4) collapse)gmm(x4,l(1 4) collapse) gmm(x5,l(1 4) collapse)gmm(x6,l(1 4) collapse)gmm(x7,l(1 4) collapse) iv(WR i.year) robust twostep small orthogonal
//Arellano-Bond test for AR(2) in first differences: z =   0.22  Pr > z =  0.843
//Hansen test of overid. restrictions: chi2(44)   =  56.72  Prob > chi2 =  0.123
outreg2 using tableA2.doc,replace bdec(3) tdec(2) ctitle(y)
*  x=ln(GWU)
replace y = ln(TFP)
replace x = ln( GWU )
xtabond2 y l.y x $c WR, gmm(l.y,l(1 4) collapse) gmm(x ,l(1 4) collapse) gmm(x1,l(1 4) collapse)gmm(x2,l(1 4) collapse)gmm(x3,l(1 4) collapse)gmm(x4,l(1 4) collapse) gmm(x5,l(1 4) collapse)gmm(x6,l(1 4) collapse)gmm(x7,l(1 4) collapse) iv(WR i.year) robust twostep small orthogonal
//Arellano-Bond test for AR(2) in first differences:  z =  -1.24  Pr > z =  0.216
//Hansen test of overid. restrictions: chi2(44)   =  54.20  Prob > chi2 =  0.139
outreg2 using tableA2.doc,append bdec(3) tdec(2) ctitle(y)
*  x=GWD
replace y = ln(TFP)
replace x = GWD
xtabond2 y l.y x $c WR, gmm(l.y,l(1 4) collapse) gmm(x,l(1 4) collapse) gmm(x1,l(1 4) collapse)gmm(x2,l(1 4) collapse)gmm(x3,l(1 4) collapse)gmm(x4,l(1 4) collapse) gmm(x5,l(1 4) collapse)gmm(x6,l(1 4) collapse)gmm(x7,l(1 4) collapse) iv(WR i.year) robust twostep small orthogonal
//Arellano-Bond test for AR(2) in first differences:z =  -0.83  Pr > z =  0.407
//Hansen test of overid. restrictions: chi2(44)   =  49.60  Prob > chi2 =  0.260
outreg2 using tableA2.doc,append bdec(3) tdec(2) ctitle(y)

** Column (4)-(6): y=TFP4 (TL-nWater-nNeutral)
*  x=GWU
replace y = ln(TFP4)
replace x = GWU
xtabond2 y l.y x $c WR, gmm(l.y,l(1 4) collapse) gmm(x,l(1 4) collapse) gmm(x1,l(1 4) collapse)gmm(x2,l(1 4) collapse)gmm(x3,l(1 4) collapse)gmm(x4,l(1 4) collapse) gmm(x5,l(1 4) collapse)gmm(x6,l(1 4) collapse)gmm(x7,l(1 4) collapse) iv(WR i.year) robust twostep small 
//Arellano-Bond test for AR(2) in first differences: z =  -1.65  Pr > z =  0.099
//Hansen test of overid. restrictions: chi2(44)   =  52.52  Prob > chi2 =  0.177
outreg2 using tableA2.doc,append bdec(3) tdec(2) ctitle(y)
*  x=ln(GWU)
replace x = ln( GWU )
xtabond2 y l.y x $c WR, gmm(l.y,l(1 4) collapse) gmm(x,l(1 4) collapse) gmm(x1,l(1 4) collapse)gmm(x2,l(1 4) collapse)gmm(x3,l(1 4) collapse)gmm(x4,l(1 4) collapse) gmm(x5,l(1 4) collapse)gmm(x6,l(1 4) collapse)gmm(x7,l(1 4) collapse) iv(WR i.year) robust twostep small orthogonal
//Arellano-Bond test for AR(2) in first differences:  z =  -1.79  Pr > z =  0.073
//Hansen test of overid. restrictions: chi2(44)   =  49.82  Prob > chi2 =  0.253
outreg2 using tableA2.doc,append bdec(3) tdec(2) ctitle(y)
*  x=GWD
replace x = GWD
xtabond2 y l.y x $c WR, gmm(l.y,l(1 .) collapse) gmm(x,l(1 .) collapse) gmm(x1,l(1 4) collapse)gmm(x2,l(1 4) collapse)gmm(x3,l(1 4) collapse)gmm(x4,l(1 4) collapse) gmm(x5,l(1 4) collapse)gmm(x6,l(1 4) collapse)gmm(x7,l(1 4) collapse) iv(WR i.year) robust twostep small orthogonal
//Arellano-Bond test for AR(2) in first differences: z =  -1.88  Pr > z =  0.060
//Hansen test of overid. restrictions: chi2(44)   =   58.19  Prob > chi2 =  0.290
outreg2 using tableA2.doc,append bdec(3) tdec(2) ctitle(y)

















****************************************
************* Long-term estimates
use "$Data\LongDiffenrence_5year.dta",clear
xtset id T
global c x1 x2 x3 x4 x5 x6 x7






*   Long-difference estimates results: Table 5

**  TL-Water-nNeutral
ivregress 2sls lTFP llTFP (GWU = WR i.T i.id) $c,robust
estat overid  //0.1485
outreg2 using table5.doc,replace bdec(3) tdec(2) ctitle(y)

ivregress 2sls lTFP llTFP (lGWU = WR i.T i.id) $c,robust
estat overid  //0.1216
outreg2 using table5.doc,append bdec(3) tdec(2) ctitle(y)

ivregress 2sls lTFP llTFP (GWD = WR i.T i.id) $c,robust
estat overid  //0.0894
outreg2 using table5.doc,append bdec(3) tdec(2) ctitle(y)


**  TL-Water-Neutral
ivregress 2sls lTFP2 llTFP2 (GWU = WR i.T i.id) $c,robust
estat overid   //0.1608
outreg2 using table5.doc,append bdec(3) tdec(2) ctitle(y)


**  nWater
ivregress 2sls lTFP4 llTFP4 (GWU = WR i.T i.id) $c,robust
estat overid //p = 0.3698
outreg2 using table5.doc,append bdec(3) tdec(2) ctitle(y)

**  yield
ivregress 2sls ly lly (GWU = WR i.id i.T) $c,robust
estat overid   //p = 0.2567
outreg2 using table5.doc,append bdec(3) tdec(2) ctitle(y)









*  Long-term estimates of the impacts of groundwater use on ATFP (Table A.3.)

global c x1 x2 x3 x4 x5 x6 x7

**  (1) 5-year
use "$Data\LongDiffenrence_5year.dta",clear
xtset id T
ivregress 2sls lTFP llTFP (GWU = WR i.T i.id) $c,robust
estat overid  //0.1485
outreg2 using tableA3.doc,replace bdec(3) tdec(2) ctitle(y)

**  (2) 2-year
use "$Data\LongDiffenrence_2year.dta",clear
xtset id T
ivregress 2sls lTFP llTFP (GWU=WR i.T i.id) $c if year==2010|year==2018,robust
estat overid  //p = 0.0770
outreg2 using tableA3.doc,append bdec(3) tdec(2) ctitle(y)

**  (3)-(6) 
use "$Data\PanelData20240124",clear
xtset id year
gen y = ln(TFP)
//  (3)2010 and 2018
ivregress 2sls y (GWU=WR i.id i.year) l.y $c if year==2010|year==2018,robust
estat overid //0.3630
outreg2 using tableA3.doc,append bdec(3) tdec(2) ctitle(y)
//  (4) 2010 and 2019
ivregress 2sls y (GWU=WR i.id i.year) l.y $c if year==2010|year==2019,robust
estat overid //0.3890
outreg2 using tableA3.doc,append bdec(3) tdec(2) ctitle(y)
//  (5)2011 and 2018
ivregress 2sls y (GWU=WR i.id i.year) l.y $c if year==2011|year==2018,robust
estat overid //0.0562
outreg2 using tableA3.doc,append bdec(3) tdec(2) ctitle(y)
//  (6) 2011 and 2019
ivregress 2sls y (GWU=WR i.id i.year) l.y $c if year==2011|year==2019,robust
estat overid //0.1769
outreg2 using tableA3.doc,append bdec(3) tdec(2) ctitle(y)




















****************************************
************* Adaption and mechanisms



*  Adaption and mechanisms: Table 6, Panel A

use "$Data\PanelData20240124",clear
xtset id year
gen y = ln(TFP)
gen x = GWU
global c x1 x2 x3 x4 x5 x6 x7


**  output
replace y = ln(yield/Land)
replace x = GWU
xtabond2 y l.y x $c WR, gmm(l.y,l(1 4) collapse) gmm(x,l(1 3) collapse) gmm(x1,l(1 3) collapse)gmm(x2,l(1 3) collapse)gmm(x3,l(1 3) collapse)gmm(x4,l(1 3) collapse) gmm(x5,l(1 3) collapse)gmm(x6,l(1 3) collapse)gmm(x7,l(1 3) collapse) iv(WR i.year) robust twostep small orthogonal
//Arellano-Bond test for AR(2) in first differences: z =   0.21  Pr > z =  0.835
//Hansen test of overid. restrictions: chi2(36)   =  41.03  Prob > chi2 =  0.260
outreg2 using tableA4.A.doc,replace bdec(3) tdec(2) ctitle(y)

**  TFP
replace y = ln(TFP)
replace x = GWU
xtabond2 y l.y x $c WR, gmm(l.y,l(1 4) collapse) gmm(x,l(1 4) collapse) gmm(x1,l(1 4) collapse)gmm(x2,l(1 4) collapse)gmm(x3,l(1 4) collapse)gmm(x4,l(1 4) collapse) gmm(x5,l(1 4) collapse)gmm(x6,l(1 4) collapse)gmm(x7,l(1 4) collapse) iv(WR i.year) robust twostep small orthogonal
//Arellano-Bond test for AR(2) in first differences: z =   0.20  Pr > z =  0.843
//Hansen test of overid. restrictions: chi2(44)   =  55.04  Prob > chi2 =  0.123
outreg2 using tableA4.A.doc,append bdec(3) tdec(2) ctitle(y)

**  input
/*Machinery*/
replace y = ln(Machinery/ Land)
replace x = GWU
xtabond2 y l.y x $c WR, gmm(l.y,l(1 4) collapse) gmm(x,l(1 4) collapse) gmm(x1,l(1 4) collapse)gmm(x2,l(1 4) collapse)gmm(x3,l(1 4) collapse)gmm(x4,l(1 4) collapse) gmm(x5,l(1 4) collapse)gmm(x6,l(1 4) collapse)gmm(x7,l(1 4) collapse) iv(WR i.year) robust twostep small orthogonal
//Arellano-Bond test for AR(2) in first differences:  z =   1.47  Pr > z =  0.142
//Hansen test of overid. restrictions: chi2(44)   =  55.24  Prob > chi2 =  0.119
outreg2 using tableA4.A.doc,append bdec(3) tdec(2) ctitle(y)

/*Fertilizer*/
replace y = ln(Fertilizer/ Land)
replace x = GWU
xtabond2 y l.y x $c WR, gmm(l.y,l(1 4) collapse) gmm(x,l(1 4) collapse) gmm(x1,l(1 4) collapse)gmm(x2,l(1 4) collapse)gmm(x3,l(1 4) collapse)gmm(x4,l(1 4) collapse) gmm(x5,l(1 4) collapse)gmm(x6,l(1 4) collapse)gmm(x7,l(1 4) collapse) iv(WR i.year) robust twostep small orthogonal
//Arellano-Bond test for AR(2) in first differences: z =   1.13  Pr > z =  0.258
//Hansen test of overid. restrictions:chi2(44)   =  52.60  Prob > chi2 =  0.175
outreg2 using tableA4.A.doc,append bdec(3) tdec(2) ctitle(y)

/*AgriWater*/
replace y = ln(AgriWater/ Land)
replace x = GWU
xtabond2 y l.y x $c WR, gmm(l.y,l(1 4) collapse) gmm(x,l(1 .) collapse) gmm(x1,l(1 4) collapse)gmm(x2,l(1 4) collapse)gmm(x3,l(1 4) collapse)gmm(x4,l(1 4) collapse) gmm(x5,l(1 4) collapse)gmm(x6,l(1 4) collapse)gmm(x7,l(1 4) collapse) iv(WR i.year) robust twostep small orthogonal
//Arellano-Bond test for AR(2) in first differences: z =  -0.33  Pr > z =  0.74
//Hansen test of overid. restrictions: chi2(49)   =  58.75  Prob > chi2 =  0.160
outreg2 using tableA4.A.doc,append bdec(3) tdec(2) ctitle(y)

/*Labor*/
replace y = ln(Labor/ Land)
replace x = GWU
xtabond2 y l.y x $c WR, gmm(l.y,l(1 .) collapse) gmm(x,l(1 4) collapse) gmm(x1,l(1 4) collapse)gmm(x2,l(1 4) collapse)gmm(x3,l(1 4) collapse)gmm(x4,l(1 4) collapse) gmm(x5,l(1 4) collapse)gmm(x6,l(1 4) collapse)gmm(x7,l(1 4) collapse) iv(WR i.year) robust twostep small orthogonal
//Arellano-Bond test for AR(2) in first differences: z =   0.88  Pr > z =  0.377
//Hansen test of overid. restrictions: chi2(48)   =  53.73  Prob > chi2 =  0.264
//outreg2 using table6A.doc,append bdec(3) tdec(2) ctitle(y)











*   Adaption and mechanisms: Table 6, Panel B

use "$Data\LongDiffenrence_5year.dta",clear
xtset id T
global c x1 x2 x3 x4 x5 x6 x7

**  output
ivregress 2sls ly lly (GWU = WR i.T i.id) $c,robust
//ivreg2 ly lly (GWU = WR i.T i.id) x1 x2 x3 x4 x5 x6 x7,robust
estat overid //0.2567
outreg2 using tableA4.B.doc,replace bdec(3) tdec(2) ctitle(y)

**  TFP
ivregress 2sls lTFP llTFP (GWU = WR i.T i.id) $c,robust
estat overid  //0.1485
outreg2 using tableA4.B.doc,append bdec(3) tdec(2) ctitle(y)

**  input
ivregress 2sls lk llk (GWU = WR i.T i.id) $c,robust
outreg2 using tableA4.B.doc,append bdec(3) tdec(2) ctitle(y)

ivregress 2sls lf llf (GWU = WR i.T i.id) $c,robust
outreg2 using tableA4.B.doc,append bdec(3) tdec(2) ctitle(y)

ivregress 2sls lw llw (GWU = WR i.T i.id) $c,robust
outreg2 using tableA4.B.doc,append bdec(3) tdec(2) ctitle(y)

ivregress 2sls ll lll (GWU = WR i.T i.id) $c,robust
//outreg2 using tableA.4.B.doc,append bdec(3) tdec(2) ctitle(y)






clear