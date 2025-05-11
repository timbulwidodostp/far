{smcl}
{* !version 1.1.1 19may2012 by Andrés Riquelme}{...}
{cmd:help far}{right: ({browse "http://www.stata-journal.com/article.html?article=st0307":SJ13-3: st0307})}
{hline}

{title:Title}

{p2colset 5 12 14 2}{...}
{p2col :{hi: far} {hline 2}}Fractionally resampled Anderson-Rubin test{p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 14 2}
{cmd:far} {depvar} [{it:{help varlist:varlist1}}]
{cmd:(}{it:varlist2} {cmd:=} {it:varlist_iv}{cmd:)}
{ifin}
[{cmd:,} {it:options}]

{synoptset 18}{...}
{synopthdr}
{synoptline}
{synopt :{opt reps(#)}}specify the number of repetitions of the resampling procedure; default is {cmd:reps(10000)}{p_end}
{synopt :{opt kappa(#)}}specify the constant kappa for the correction factor of the FAR test; default is {cmd:kappa(3)}, and any positive real number  can be used{p_end}
{synopt :{opth theta:(numlist:numlist1)}}allow for user-defined hypothesis test{p_end}
{synopt :{opt ci}}enable the user to test for different values of the reduced form equation and search for the confidence interval defined by {opt level(#)}
 under the grid defined by {opt grid(numlist2)}{p_end}
{synopt :{opt level(#)}}significance level for the test in the grid search; default is {cmd:level(95)}{p_end}
{synopt :{opth gr:id(numlist:numlist2)}}specify the grid for the values of the reduced-form parameter to be tested; default is {cmd:grid(-30, 30, 0.01)}{p_end}
{synoptline}
{p2colreset}{...}


{title:Description}

{pstd}
{cmd:far} performs the fractionally resampled Anderson-Rubin (FAR) test for
the joint significance of the endogenous regressors in an
instrumental-variables estimation (see {helpb ivregress}) of {depvar} using
the optional controls in {it:{help varlist:varlist1}}, the endogenous
regressors in {it:varlist2}, and the instrumental variables in
{it:varlist_iv}.


{title:Options}

{phang}
{opt reps(#)} specifies the number of repetitions of the
resampling procedure.  A large number of repetitions is necessary for
the results in section 3 of the article to be valid.  The default is
{cmd:reps(10000)}, and it gives fast and reliable estimates in small
samples (n<100).  If the number of repetitions is not large enough, the
FAR test p-values may vary.

{phang}
{opt kappa(#)} specifies the value of the kappa constant.  Any
positive real number may be used.  The default is {cmd:kappa(3)} (see
section 5 in the accompanying article for justification of the selected
default value).

{phang}
{opth theta:(numlist:numlist1)} allows for a user-defined hypothesis test.
{it:numlist1} is a list of values for the endogenous parameters to be
tested (one for each endogenous variable).  If {opt theta()} is not
specified, the {cmd:far} command will perform a significance test (all
the values in {it:numlist1} will be set as 0).  By implementing this
option, the user can invert the FAR test to find confidence intervals
for theta_0.

{phang}
{cmd:ci} enables the user to test for a grid of different values
of theta_0 and search for the (1-alpha)% confidence interval for the
true scalar theta.  The significance level and the grid can be
customized by using the options {opt level(#)} and {opt grid(numlist2)}.
This option is available when there is only one endogenous variable.

{phang}
{opt level(#)} is the significance level for the test in the grid
search.  The default is {cmd:level(95)}.

{phang}
{opth grid:(numlist:numlist2)} specifies the grid for the values of theta_0
to be tested.  {it:numlist2} consists of three elements: the minimum
level, the maximum level, and the increments of the grid.  The default
is {cmd:grid(-30, 30, 0.01)}.


{title:Examples}

{pstd}Setup{p_end}
{phang2}{cmd:. use fardata}{p_end}

{pstd}Estimate the FAR test by using the default parameters:{p_end}
{phang2}{cmd:. far logpgp95 malfal94 (avexp = logem4)}{p_end}

{pstd}Estimate the FAR test, increasing the resampling repetitions to
100,000 and setting kappa=2:{p_end}
{phang2}{cmd:. far logpgp95 malfal94 (avexp = logem4), reps(100000) kappa(2)}{p_end}

{pstd}Estimate the FAR test, setting the parameter for the endogenous
parameter theta=2:{p_end}
{phang2}{cmd:. far logpgp95 malfal94 (avexp = logem4), theta(2)}{p_end}

{pstd}Estimate the FAR test and the default grid:{p_end}
{phang2}{cmd:. far logpgp95 malfal94 (avexp = logem4), ci}{p_end}

{pstd}Estimate the FAR test and a customized grid:{p_end}
{phang2}{cmd:. far logpgp95 malfal94 (avexp = logem4), ci grid(0.67, 0.71, 0.001) level(95)}{p_end}
{phang2}{cmd:. matrix list r(ci)}{p_end}


{title:Stored results}

{pstd}
{cmd:far} stores the following in {cmd:r()}:

{synoptset 15 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:r(n)}}number of observations{p_end}
{synopt:{cmd:r(ar)}}full-sample Anderson-Rubin statistic{p_end}
{synopt:{cmd:r(arp)}}full-sample p-value{p_end}
{synopt:{cmd:r(farp)}}FAR p-value{p_end}
{synopt:{cmd:r(reps)}}resampling repetitions{p_end}
{synopt:{cmd:r(kappa)}}the constant kappa{p_end}
{synopt:{cmd:r(k)}}number of instruments{p_end}
{synopt:{cmd:r(l)}}number of controls{p_end}
{synopt:{cmd:r(m)}}number of endogenous variables{p_end}

{synoptset 15 tabbed}{...}
{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:r(cmdline)}}command as typed{p_end}
{synopt:{cmd:r(depvar)}}name of dependent variable{p_end}
{synopt:{cmd:r(title)}}title in estimation output{p_end}
{synopt:{cmd:r(exogenous)}}list of controls{p_end}
{synopt:{cmd:r(endogenous)}}list of endogenous variables{p_end}
{synopt:{cmd:r(instruments)}}list of instruments{p_end}
{synopt:{cmd:r(grid)}}grid values{p_end}

{synoptset 15 tabbed}{...}
{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:r(theta)}}endogenous parameters tested{p_end}
{synopt:{cmd:r(ci)}}fractionally resampled p-values for the parameters in the
grid{p_end}


{title:Authors}

{pstd}Andr{c e'}s Riquelme{p_end}
{pstd}North Carolina State University{p_end}
{pstd}Department of Economics{p_end}
{pstd}Raleigh, NC{p_end}
{pstd}jariquel@ncsu.edu{p_end}

{pstd}Daniel Berkowitz{p_end}
{pstd}University of Pittsburgh{p_end}
{pstd}Department of Economics{p_end}
{pstd}Pittsburgh, PA{p_end}
{pstd}dmberk@pitt.edu{p_end}

{pstd}Mehmet Caner{p_end}
{pstd}North Carolina State University{p_end}
{pstd}Department of Economics{p_end}
{pstd}Raleigh, NC{p_end}
{pstd}mcaner@ncsu.edu{p_end}


{title:Also see}

{p 4 14 2}
Article:  {it:Stata Journal}, volume 13, number 3: {browse "http://www.stata-journal.com/article.html?article=st0307":st0307}

{p 5 14 2}
Manual:  {manlink R ivregress}

{p 7 14 2}
Help:  {manhelp ivregress R:ivregress}{p_end}
