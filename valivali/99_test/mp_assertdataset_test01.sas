/*** HELP START ***//*

### Purpose:
- Unit test for the %mp_assertdataset() macro

### Expected result:  
- Dataset test_results is generated with observation of PASS and FAIL.  

*//*** HELP END ***/

/* Test datasets */
data _data1;
	input var1 var2 $ ;
	cards ;
	1 abc
	2 def
	3 ghi
	;
run;
data _data2 ; /*No diff with _data1*/
	set _data1 ;
run ;
data _data3;
	set _data1 end=eof ;
	if eof then var2="phi" ; /*ghi -> phi*/
run;

/*Compare*/
%mp_assertdataset(
  base=_data1,					/* parameter in proc compare */
  compare=_data2,				/* parameter in proc compare */
  desc=Compare _data1 and _data2, 	/* description */
  puttolog=N,	/*to suppress log*/
  id=,						/* parameter in proc compare(e.g. id=USUBJID) */
  by=,      	            /* parameter in proc compare(e.g. by=USUBJID VISIT) */
  criterion=0,       		/* parameter in proc compare */
  method=absolute    /* parameter in proc compare */
);
%mp_assertdataset(
  base=_data1,					/* parameter in proc compare */
  compare=_data3,				/* parameter in proc compare */
  desc=Compare _data1 and _data3, 	/* description */
  puttolog=N,	/*to suppress log*/
  id=,						/* parameter in proc compare(e.g. id=USUBJID) */
  by=,      	            /* parameter in proc compare(e.g. by=USUBJID VISIT) */
  criterion=0,       		/* parameter in proc compare */
  method=absolute    /* parameter in proc compare */
);
