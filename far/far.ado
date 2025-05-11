*! Version 1.0 J.Andrés Riquelme 13may2012
/* This program performs the Fractionally Resampled Anderson Rubin test 
(Berkowitz, D., Caner, M. and Y. Fang, 2012: The validity of instruments revisited.
    Journal of Econometrics 166, pp. 255-266.

 Programmed by: J. Andrés Riquelme
 Please send any comment to: jariquel@ncsu.edu  */

capture program drop far
program define far, rclass
  	version 10.0
   	syntax anything [if] [in] [, reps(integer 10000) kappa(real 3) theta(numlist) ci level(real 95) GRid(numlist)]
       local 0 `anything'
	gettoken exog   0 : 0, parse("(")
	gettoken depvar exog : exog
	gettoken tmp    0 : 0, parse("(")
	gettoken endog  0 : 0, parse("=")
	gettoken tmp    0 : 0, parse("=")
	gettoken instr  0 : 0, parse(")")
// Begin input checking <---------------
// Check if there are any controls
	if (wordcount("`exog'") == 0) local exog ""	// immediately delete any blank chars
// Check for beta input (no input means significance test)
	capture matrix drop __theta
	tempvar  _theta
	local mm = wordcount("`endog'")
	matrix __theta = J(`mm', 1, 0) // default
	if ("`theta'" != "")  {
		local bb = wordcount("`theta'")
		if (`mm' != `bb') {
			noisily: display "{error:{bf:ERROR -} {it:theta()}: Number of given parameters must be equal to the number of endogenous variables.}"
			error(499)  				// code 499: generic error
       	}
		forvalues j = 1/`bb' {
			local _a:  word `j' of `theta'
			matrix __theta[`j', 1] = `_a'
		}
	}
// Check Conficence interval input:
	if (`level' < 0 | `level' > 100) {
			noisily: display "{error:{bf:ERROR -} {it:level()}: Confidence level must be between 0 and 100.}"
			error(499)  				// code 499: generic error
	}

// Check the "grid"
	// defaut grid:
	local gr_low -30
	local gr_upp 30
	local gr_incr = .01
	if ("`grid'" != "") {
		if (wordcount("`grid'") != 3) {
			noisily: display "{error:{bf:ERROR -} {it:grid()}: Grid option requires 3 inputs.}"
			error(499)  				// code 499: generic error	
		}
		local gr_low: word 1 of `grid' 
		local gr_upp: word 2 of `grid'
		local gr_incr: word 3 of `grid'
		if (`gr_low' >= `gr_upp' ) {
			noisily: display "{error:{bf:ERROR -} {it:grid()}: Lower limit must be lower than upper limit.}"
			error(499)  				// code 499: generic error	
		}
		if (`gr_incr' <= 0 ) {
			noisily: display "{error:{bf:ERROR -} {it:grid()}: Increment must be a possitive integer.}"
			error(499)  				// code 499: generic error	
		}
	}
	if ("`ci'" != "" & wordcount("`theta'") > 1) {
		noisily: display "{error:{bf:ERROR -} {it:ci}: Confidence Interval option valid only with one (1) endogenous variable.}"
		error(499)  				// code 499: generic error	
	}
// Check the number of repetitions:
	if `reps' <= 0 {
		noisily: display "{error:{bf:ERROR -} {it:reps()} must be a positive integer.}"
		error(499)  				// code 499: generic error
       }
// Check the kappa value:
	if (`kappa' < 0 ){
		noisily: display "{error:{bf:ERROR -} {it:kappa} out of range, it has to be a positive number.}"
		error(499)  				// code 499: generic error
       }
// -------------------> End Input Checking
	marksample touse
	mata : far_1("`depvar'", "`exog'", "`endog'", "`instr'", "`touse'", `reps', `kappa',  ///
                    "`ci'",  `level', `gr_low', `gr_upp', `gr_incr' ) // send vars to mata
// Output preparation and display.
	local title "Fractionally resampled Anderson and Rubin test"
	local n_   : display %7.0f `r(N)'
	local farp_: display %9.4f `r(FARp)'
	local arp_ : display %9.4f `r(ARp)'
	local ar_  : display %9.4f `r(AR)'
	local reps_: display %9.0f `r(REPS)'
	display ""
	display "{input:`title'.}"
	display "{hline 15}{c TT}{hline 60}"
	display "{input:               {c |}  Full sample  Full sample      FAR}"
	display "{input:               {c |}   statistic     p-value      p-value     reps       N}"
	display "{hline 15}{c +}{hline 60}"
	display "{input: AR-test       {c |}}  {result:`ar_'}   {result:`arp_'}    {result:`farp_'} {result:`reps_'} {result:`n_'}" 
	display "{hline 15}{c BT}{hline 60}"
	return scalar level = `level'
	return scalar n = r(N)
	return scalar m = r(M)
	return scalar l = r(L)
	return scalar k = r(K)
	return scalar kappa = r(kappa)
	return scalar reps = r(REPS)
	return scalar farp = r(FARp)
	return scalar arp = r(ARp)
	return scalar ar  = r(AR)
	if (`reps' != 1000 | `kappa' != 3 | "`theta'" != "" | `level' != 95 | "`ci'" != "" |"`grid'" != "") local optc ","
	if (`reps'  != 1000) local optr  " reps(`reps')"
	if (`kappa' !=  3) local optk " c(`kappa')"
	if ("`theta'" != "") local optb " theta(`theta')"
	if (`level' != 95 ) local optl " level(`level')"
	if ("`grid'" != "") local optg " grid(`gr_low', `gr_upp', `gr_incr')"
	return local grid `grid'
	return local theta `theta'
	return local instruments `instr'
	return local endogenous `endog'
	return local exogenous `exog'
	return local depvar `depvar'
	return local cmdline "far `anything' `if' `in'`optc'`optr'`optk'`optb' `ci'`optl'`optg'"
	return local title `title'
	return matrix theta __theta
	matrix colnames rci = theta FAR-p test
	return matrix ci rci
end

capture mata mata drop far_1()
mata
void far_1(string scalar depvar, string scalar exog, string scalar endog, ///
		 string scalar instr, string scalar touse, ///
		 real nb, real kappa, string scalar ci, real level, real gr_low, real gr_upp, real gr_incr)
{
	real matrix M, Y, Z , W
	real colvector y
	real scalar n, m, ar, far
	M=Y=Z=W=y=.
	theta = st_matrix("__theta")
	st_view(y, ., tokens(depvar), touse)
	if (exog != "") {
		st_view(W, ., tokens(exog)  , touse)
	}
	else {
		W = J(rows(y),1,1)				// dummy single column to check for missings
	}
	st_view(Y, ., tokens(endog) , touse)
	st_view(Z, ., tokens(instr) , touse)
//Eliminate missing values from the sample
	M = y , W , Y , Z
	tfilter = 1::rows(M)
	for(i=1; i<=rows(M); i++) {
		for(j=1; j<=cols(M); j++) {
			if (!(M[i,j] <.))  tfilter[i] = .
		}
	}
	filter = min(tfilter)
	for(k = min(filter)+1; k <= rows(tfilter); k++) {
		if (tfilter[k,1] != .)  filter = filter \ tfilter[k,1]
	}
	filter = filter'
	n = length(filter)
	M = M[(filter), 1..cols(M)]
	y = y[(filter), 1..cols(y)]
//Get the Endogenous
	Y = Y[(filter), 1..cols(Y)]
	m = cols(Y)                    // m: number of endogenous
//     Check collinearity: endogenous
	if (rank(Y) < m) {
		errprintf("Error: Collinear endogenous variables\n")
		exit(499)
	}
//Get the Controls
	if (exog == "" ) W = J(n,1,1)				// no controls
	if (exog != "" ) W = J(n,1,1), W[(filter), 1..cols(W)]	// controls
	l = cols(W)                    // l: number of controls
//     Check for collinearity: controls
	if (exog != "" & rank(W) < l) {
		errprintf("Error: Collinear controls\n")
		exit(499)
	}
//Get the Instruments
	Z = Z[(filter), 1..cols(Z)]
	k = cols(Z)                    // k: number of instruments
//     Check for collinearity: instruments
	if (rank(Z) < k) {
		errprintf("Error: Collinear instruments\n")
		exit(499)
	}
//Project out controls
	P = W*invsym(W'*W)*W'		//Projection matrix
	Yw = Y - P*Y
	yw = y - P*y
	Zw = Z - P*Z
//Estimates without confidence interval
	results = far_2(yw, Yw, Zw, n, m, kappa, nb, theta)
	ar  = results[1]
	arp = results[2]
	farp= results[3]
//Export results to main routine
	st_rclear()
	st_numscalar("r(N)", n)
	st_numscalar("r(L)", l)
	st_numscalar("r(M)", m)
	st_numscalar("r(K)", k)
	st_numscalar("r(AR)", ar)
	st_numscalar("r(FARp)", farp)
	st_numscalar("r(ARp)", arp)
	st_numscalar("r(REPS)", nb)
	st_numscalar("r(kappa)", kappa)
//Confidence interval
	grid = (theta[1,1], farp, farp>= level/100)
	if (ci != "") {
		grid = range(gr_low, gr_upp, gr_incr)
		grid = grid , J(rows(grid), 2,0)			// Make the grid and results
		for(k=1; k<=rows(grid); k++) {
			results = far_2(yw, Yw, Zw, n, m, kappa, nb, grid[k,1])
			grid[k,2] = results[3]
			grid[k,3] = grid[k,2] >= (100-level)/100
		}
	}
	st_matrix("rci", grid)
}
end

capture mata mata drop far_2()
mata
function far_2(real matrix yw, real matrix Yw, real matrix Zw, ///  
		 real n, real m, real kappa, real nb, real matrix b0)
{
//Full Sample Heteroskedasticity robust Anderson Rubin Test
	err = Zw:*(yw-Yw*b0)			// Structural error
	vc  = (err'*err)/n			// Estimated covariance matrix
	ar  = ((yw-Yw*b0)'*Zw*invsym(vc)*Zw'*(yw-Yw*b0))/n // Het. robust Anderson Rubin test
//FAR values
	f = 1/2 - kappa/sqrt(n)			// Fraction of original sample to be resampled
	b = ceil(n*f)				// Block size
	f = b/n
	arb = J(nb,1,0)				// Anderson-Rubin test matrix pre-allocation
	for(i=1; i <= nb; i++) {
		blq = J(b,1,0)
		r1  = ceil((n::n-b+1):*uniform(b,1))+(0::b-1)  //Random sample (with repetition)
		r2  = 1::n
		for(h=1; h < b; h++) {
			r2[(h, r1[h])] = r2[(r1[h], h)]	// Random resampling
		}
		blq    = r2[(1..b),1]			// Random resample (no repetition)
 		err2   = yw - Yw*b0
		arb[i] = (b/(1-f))*((err2[blq]'*Zw[blq,.])/b)*invsym(vc)*((Zw[blq,.]'*err2[blq])/b)
	}
	arb = sort(arb,1)
	arp = 1-chi2(m, ar)			// Anderson-rubin p value estimate 
	farp = mean(ar :<= arb)			// Resampled anderson rubin p value estimate
	return(ar, arp, farp)
}
end
