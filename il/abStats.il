/* abStats.il

Author     A.D.Beckett
Group      Custom IC (UK), Cadence Design Systems Ltd.
Language   SKILL
Date       Sep 02, 2005 
Modified   Jul 30, 2013 
By         A.D.Beckett

Functions to allow processing of statistical data from monte carlo
data. The normal OCEAN functions only print or plot the mean and
standard deviation - the functions in this file return the mean,
standard deviation, median, percentiles, minimum or maximum
for further calculation.

To use:

  results=abReadMonteData("./simulation/myblock/spectre/schematic/monteCarlo")
  mean=abMean(results "rmult_27")
  std=abStd(results "rmult_27")
  popstd=abStd(results "rmult_27" nil) ; population standard deviation
  median=abMedian(results "rmult_27") 
  percent25=abPercentile(results "rmult_27" 25) ; lower quartile
  min=abMin(results "rmult_27")
  max=abMax(results "rmult_27")

In an OCEAN script, you can also read the monte carlo data using:

  results=abReadMonteData(strcat(resultsDir() "/monteCarlo"))

or (if the results are already open)

  results=abReadMonteData(strcat(openResults() "/monteCarlo"))

If using results from ADE XL, where the data is not "swept", you
should use this (to avoid the heuristics which try to identify the
sweep values):

  results=abReadMonteData("/path/to/monteCarlo" ?noSweep t)

Can also use:

  abMonteDataFilter(results "rmult_27" ?lower 200 ?upper 300)

to filter the data. This will affect the abMean and abStd results,
as it will have filtered the values less than the lower and greater than
the upper.

Note that the normal histogram() function shows the population rather than
sample standard deviation (which it should not - PCR 807278).

If you want to plot the values versus the interation, you can do:

  plot(abMonteWaveform(results "rmult_27") ?expr '("rmult_27"))

If you want to see how the standard deviation or mean varies with number of
iterations, you can do:

  plot(abStdVersusIterationWaveform(results "rmult_27")
  plot(abMeanVersusIterationWaveform(results "rmult_27")

Note that this only really makes sense with random (standard) sampling
rather than Latin Hypercube (lhs). With LHS the number of iterations is
known in advance and affects each sample, whereas with random you can
keep adding more samples to improve the result.

Extended 27/3/07 to support swept monte carlo data
Extended 17/4/07 to support data filtering
Extended 18/2/08 to support percentile/median calculations
Extended 6/3/09 to support min/max and waveform generation
Extended 21/7/10 to produce stddev vs iteration waveform
Extended 22/7/10 to produce mean vs iteration waveform
Extended 23/7/12 to support reading non-sweep data

***************************************************

SCCS Info: @(#) abStats.il 07/30/13.14:18:06 1.10

*/

;------------------------------------------------------------------------
; Define structure used to contain results
;------------------------------------------------------------------------
defstruct(abMonteData N datatab lowerFilter upperFilter)

/****************************************************************
*                                                               *
*           abReadMonteData(monteDir "t" [?noSweep t])          *
*                                                               *
* Given the monteCarlo directory, return a structure containing *
*  the table of results and the number of points in the sample  *
*                                                               *
****************************************************************/

procedure(abReadMonteData(monteDir @key noSweep "tg")
    let((mcdata mcparam line columnMapping datatab N data
	currentMapping columnMappings previousSuffix thisSuffix)
	;----------------------------------------------------------------
	; First read the names of all the parameters, and the
	; order that they are defined in
	;----------------------------------------------------------------
	mcparam=infile(strcat(monteDir "/mcparam"))
	if(mcparam then
	    while(gets(line mcparam)
		unless(rexMatchp("^#" line)
		    columnMapping=tconc(columnMapping car(parseString(line)))
		)
	    )
	    close(mcparam)
	else
	    error("Could not read %s/mcparam" monteDir)
	)
	;----------------------------------------------------------------
	; convert from tconc to ordinary list
	;----------------------------------------------------------------
	columnMapping=car(columnMapping)
	if(noSweep then
	    columnMappings=list(columnMapping)
	else
	    ;------------------------------------------------------------
	    ; Now figure out whether a sweep has been done, and
	    ; split the column mappings into multiple sets. This
	    ; is done by looking for a training _XXX in the 
	    ; parameter name
	    ;------------------------------------------------------------
	    rexCompile("_[^_]*$")
	    foreach(param columnMapping
		rexExecute(param)
		thisSuffix=rexSubstitute("\\0")
		unless(!currentMapping || thisSuffix==previousSuffix
		    currentMapping=car(currentMapping)
		    columnMappings=tconc(columnMappings currentMapping)
		    currentMapping=nil
		)
		currentMapping=tconc(currentMapping param)
		previousSuffix=thisSuffix
	    )
	    currentMapping=car(currentMapping)
	    columnMappings=tconc(columnMappings currentMapping)
	    columnMappings=car(columnMappings)
	)
	;----------------------------------------------------------------
	; Now read the mcdata file
	;----------------------------------------------------------------
	mcdata=infile(strcat(monteDir "/mcdata"))
	if(mcdata then
	    datatab=makeTable('datatab nil)
	    foreach(colMapping columnMappings
		foreach(param colMapping
		    datatab[param]=makeTable('valueTab)
		)
	    ) ; foreach columnMappings
	    N=0
	    data=lineread(mcdata)
	    while(data
		foreach(colMapping columnMappings
		    foreach((param value) colMapping data
			datatab[param][N]=value
		    )
		    data=lineread(mcdata)
		) ; foreach columnMappings
		N++
	    )
	    close(mcdata)
	    make_abMonteData(?N N ?datatab datatab 
		?lowerFilter makeTable('filter nil)
		?upperFilter makeTable('filter nil))
	else
	    error("Could not read %s/mcdata" monteDir)
	) ; if mcdata
    ) ; let
) ; procedure abReadMonteData

/*****************************************************************
*                                                                *
*               abMonteFilter(monteData param val)               *
*                                                                *
* Internal function to compare a value against the filter limits *
*   for that parameter. Returns either the value or nil if it    *
*                          was filtered                          *
*                                                                *
*****************************************************************/

procedure(abMonteFilter(monteData param val)
    let((limit)
	limit=monteData->lowerFilter[param]
	when(limit && val<limit val=nil)
	limit=monteData->upperFilter[param]
	when(val && limit && val>limit val=nil)
	val
    ) ; let
) ; procedure

/***************************************************************
*                                                              *
*                   abMean(monteData param)                    *
*                                                              *
* Given a results set read with abReadMonteData, and the name  *
*      of a parameter, calculate the mean and return it.       *
*                                                              *
***************************************************************/

procedure(abMean(monteData param)
    let(((sum 0.0) (N 0) val valtab)
	valtab=monteData->datatab[param]
	if(valtab then
	    for(i 0 sub1(monteData->N)
		val=abMonteFilter(monteData param valtab[i])
		when(val
		    sum=sum+val
		    N++
		)
	    ) ; for
	    unless(zerop(N)
		sum/N
	    ) ; unless
	else
	    error("Could not find parameter %s amongst %L\n"
		param monteData->datatab->?
	    )
	) ; if
    ) ; let
) ; procedure


/***************************************************************
*                                                              *
*         abStd(monteData param @optional (sample t))          *
*                                                              *
*  Given a results set, a parameter name, return the standard  *
*   deviation. The default is to calculation sample standard   *
* deviation, but if the third argument is nil, it will compute *
*              the population standard deviation.              *
*                                                              *
***************************************************************/

procedure(abStd(monteData param @optional (sample t))
    let(((sum 0.0) (N 0) val valtab mean)
	mean=abMean(monteData param)
	; don't need to validate that param exists, since
	; error will have been found by abMean
	when(mean
	    valtab=monteData->datatab[param]
	    for(i 0 sub1(monteData->N)
		val=abMonteFilter(monteData param valtab[i])
		when(val
		    sum=sum+(val-mean)**2
		    N++
		)
	    )
	    if(sample then
		if(N>1 then
		    sqrt(sum/(N-1))
		else
		    0.0
		)
	    else
		sqrt(sum/N)
	    ) ; if
	) ; when mean
    ) ; let
) ; procedure

/***************************************************************
*                                                              *
*                    abMin(monteData param)                    *
*                                                              *
*     Given a results set and a parameter name, return the     *
*                minimum value in the results.                 *
*                                                              *
***************************************************************/

procedure(abMin(monteData param)
    let((minVal val valtab)
	valtab=monteData->datatab[param]
	if(valtab then
	    for(i 0 sub1(monteData->N)
		val=abMonteFilter(monteData param valtab[i])
		when(val
		    minVal=if(minVal min(val minVal) val)
		)
	    ) ; for
	else
	    error("Could not find parameter %s amongst %L\n"
		param monteData->datatab->?
	    )
	) ; if
	minVal
    ) ; let
) ; procedure

/***************************************************************
*                                                              *
*                    abMax(monteData param)                    *
*                                                              *
*     Given a results set and a parameter name, return the     *
*                maximum value in the results.                 *
*                                                              *
***************************************************************/

procedure(abMax(monteData param)
    let((maxVal val valtab)
	valtab=monteData->datatab[param]
	if(valtab then
	    for(i 0 sub1(monteData->N)
		val=abMonteFilter(monteData param valtab[i])
		when(val
		    maxVal=if(maxVal max(val maxVal) val)
		)
	    ) ; for
	else
	    error("Could not find parameter %s amongst %L\n"
		param monteData->datatab->?
	    )
	) ; if
	maxVal
    ) ; let
) ; procedure

/***************************************************************
*                                                              *
*           abPercentile(monteData param percentile)           *
*                                                              *
*  Given results data read with abReadMonteData, a parameter   *
*  name, and a percentile (e.g. 25 for the 25th percentile),   *
*            return the value for that percentile.             *
*                                                              *
***************************************************************/

procedure(abPercentile(monteData param percentile)
    let(((N 0) val valtab valList n Pn Vn VnPlus1)
	valtab=monteData->datatab[param]
	if(valtab then
	    ;------------------------------------------------------------
	    ; Filter the values, and produce a sorted list
	    ;------------------------------------------------------------
	    for(i 0 sub1(monteData->N)
		val=abMonteFilter(monteData param valtab[i])
		when(val
		    valList=cons(val valList)
		    N++
		)
	    ) ; for
	    valList=sort(valList 'lessp)
	    ;------------------------------------------------------------
	    ; Calculate the position corresponding to the desired
	    ; percentile. 
	    ; If below first point, use the first point. If above
	    ; the last point, use the last point. Otherwise linearly
	    ; interpolate.
	    ;------------------------------------------------------------
	    percentile=float(percentile)
	    n=percentile*N/100+0.5
	    cond(
		(n<=1.0 car(valList))
		(n>=N car(last(valList)))
		(t
		    n=floor(n)
		    Pn=100.0*(n-0.5)/N
		    Vn=nthelem(n valList)
		    VnPlus1=nthelem(n+1 valList)
		    Vn+N*(percentile-Pn)*(VnPlus1-Vn)/100.0
		)
	    )
	else
	    error("Could not find parameter %s amongst %L\n"
		param monteData->datatab->?
	    )
	) ; if
    ) ; let
) ; procedure

/***************************************************************
*                                                              *
*                  abMedian(monteData param)                   *
*                                                              *
*     Given results data read with abReadMonteData, and a      *
*              parameter name, return the median.              *
*                                                              *
***************************************************************/

procedure(abMedian(monteData param)
    abPercentile(monteData param 50)
) ; procedure

/***************************************************************
*                                                              *
*                 abMonteParamNames(monteData)                 *
*                                                              *
*    Returns the names of the parameters that were read in     *
*                                                              *
***************************************************************/

procedure(abMonteParamNames(monteData)
    sort(monteData->datatab->? 'alphalessp)
) ; procedure

/***************************************************************
*                                                              *
*             abMonteNumSamples(monteData [param])             *
*                                                              *
*   Returns the number of samples, either as a whole, or for   *
*   a specified parameter (takes into account data filtering)  *
*                                                              *
***************************************************************/

procedure(abMonteNumSamples(monteData @optional param)
    let(((N 0) val valtab)
	;----------------------------------------------------------------
	; If parameter is given, give the number of filtered
	; results for that parameter
	;----------------------------------------------------------------
	if(param && 
	    (monteData->lowerFilter[param] || monteData->upperFilter[param])
	then
	    valtab=monteData->datatab[param]
	    for(i 0 sub1(monteData->N)
		val=abMonteFilter(monteData param valtab[i])
		when(val
		    N++
		)
	    )
	    N
	else
	    monteData->N
	) ; if
    ) ; let
) ; procedure

/***************************************************************
*                                                              *
*               abMonteWaveform(monteData param)               *
*                                                              *
* Given the monteData and a parameter name, return a waveform  *
*          constructed from the filtered data points.          *
*                                                              *
***************************************************************/

procedure(abMonteWaveform(monteData param)
    let((xVec yVec valtab val)
	valtab=monteData->datatab[param]
	if(valtab then
	    xVec=drCreateVec('intlong monteData->N)
	    yVec=drCreateVec('double monteData->N)
	    for(i 0 sub1(monteData->N)
		val=abMonteFilter(monteData param valtab[i])
		when(val
		    drAddElem(xVec add1(i))
		    drAddElem(yVec val)
		) ; when
	    ) ; for
	    xVec~>name="iteration"
	    drCreateWaveform(xVec yVec)
	else
	    error("Could not find parameter %s amongst %L\n"
		param monteData->datatab->?
	    )
	) ; if
    ) ; let
) ; procedure

/*********************************************************************
*                                                                    *
* abStdVersusIterationWaveform(monteData param @optional (sample t)) *
*                                                                    *
* Produce a waveform showing how the standard deviation varies with  *
*    number of iterations. Uses the filtered data points only. As    *
*    with abStd, uses the sample rather than population standard     *
*                       deviation by default.                        *
*                                                                    *
*********************************************************************/

procedure(abStdVersusIterationWaveform(monteData param @optional (sample t))
    let((xVec yVec valtab val (N 0) (sum 0.0) mean filteredValues varSum
	std)
	valtab=monteData->datatab[param]
	filteredValues=makeVector(monteData->N)
	if(valtab then
	    xVec=drCreateVec('intlong monteData->N)
	    yVec=drCreateVec('double monteData->N)
	    ;------------------------------------------------------------
	    ; Iterate over all the points, finding the non-filtered
	    ; values
	    ;------------------------------------------------------------
	    for(i 0 sub1(monteData->N)
		val=abMonteFilter(monteData param valtab[i])
		when(val
		    ;----------------------------------------------------
		    ; Store the filtered values for the inner loop 
		    ; and then calculate the current mean
		    ;----------------------------------------------------
		    filteredValues[N]=val
		    sum=sum+val
		    N++
		    mean=sum/N
		    ;----------------------------------------------------
		    ; Calculate the standard deviation up to this
		    ; point. Can't really avoid this being O(2) without
		    ; using some expansion which is less accurate
		    ;----------------------------------------------------
		    varSum=0.0
		    for(j 0 sub1(N)
			varSum=varSum+(filteredValues[j]-mean)**2
		    )
		    std=
			if(sample then
			    if(N>1 then
				sqrt(varSum/(N-1))
			    else
				0.0
			    )
			else
			    sqrt(varSum/N)
			)
		    ;----------------------------------------------------
		    ; Add the calculated standard deviation to the waveform
		    ;----------------------------------------------------
		    drAddElem(xVec add1(i))
		    drAddElem(yVec std)
		) ; when
	    ) ; for
	    xVec~>name="iteration"
	    drCreateWaveform(xVec yVec)
	else
	    error("Could not find parameter %s amongst %L\n"
		param monteData->datatab->?
	    )
	) ; if
    ) ; let
) ; procedure

/***************************************************************
*                                                              *
*        abMeanVersusIterationWaveform(monteData param)        *
*                                                              *
*     Produce a waveform showing how the mean varies with      *
*  number of iterations. Uses the filtered data points only.   *
*                                                              *
***************************************************************/

procedure(abMeanVersusIterationWaveform(monteData param)
    let((xVec yVec valtab val (N 0) (sum 0.0) mean)
	valtab=monteData->datatab[param]
	if(valtab then
	    xVec=drCreateVec('intlong monteData->N)
	    yVec=drCreateVec('double monteData->N)
	    ;------------------------------------------------------------
	    ; Iterate over all the points, finding the non-filtered
	    ; values
	    ;------------------------------------------------------------
	    for(i 0 sub1(monteData->N)
		val=abMonteFilter(monteData param valtab[i])
		when(val
		    sum=sum+val
		    N++
		    mean=sum/N
		    ;----------------------------------------------------
		    ; Add the calculated mean to the waveform
		    ;----------------------------------------------------
		    drAddElem(xVec add1(i))
		    drAddElem(yVec mean)
		) ; when
	    ) ; for
	    xVec~>name="iteration"
	    drCreateWaveform(xVec yVec)
	else
	    error("Could not find parameter %s amongst %L\n"
		param monteData->datatab->?
	    )
	) ; if
    ) ; let
) ; procedure

/***************************************************************
*                                                              *
* abMonteDataFilter(monteData param [?lower low] [?upper up])  *
*                                                              *
*    Set the filter limits - affects abMean and abStd  - to    *
*             the specified lower or upper values              *
*                                                              *
***************************************************************/

procedure(abMonteDataFilter(monteData param @key lower upper)
    monteData->lowerFilter[param]=lower
    monteData->upperFilter[param]=upper
    t
) ; procedure
