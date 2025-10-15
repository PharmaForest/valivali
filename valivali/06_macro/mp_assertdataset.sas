/*** HELP START ***//*

### Macro:

    %mp_assertdataset

### Purpose:

    Compares two SAS data sets using `PROC COMPARE` and asserts equality. Writes a concise PASS/FAIL
    message to the SAS log and optionally appends a row to an output results data set.

### Parameters:

 - `base` (required): Data set used as BASE in PROC COMPARE.

 - `compare` (required): Data set used as COMPARE in PROC COMPARE.

 - `desc` (optional): Free-text description of the assertion; stored in the output table when `outds` is set.  

 - `puttolog` (optional, default=Y): To switch put NOTE and ERROR of PASS/FAIL into log  
    (Can change to puttolog=N if FAIL is expected in test)  

 - `id` (optional): ID variable list for PROC COMPARE (e.g., `id=USUBJID`).

 - `by` (optional): BY variable list for PROC COMPARE (e.g., `by=USUBJID VISIT`).

 - `criterion` (optional, default=0): Tolerance for comparisons (PROC COMPARE `criterion=`).

 - `method` (optional, default=absolute): Comparison method (PROC COMPARE `method=`).

 - `outds` (optional, default=work.test_results): Results table to append a PASS/FAIL record.

### Returns:

    Creates/updates the data set named in `outds`, prints PASS/FAIL to the log.

### Sample code:

~~~sas
%mp_assertdataset(
  base=work.adsl_expected,
  compare=work.adsl_actual,
  desc=Check ADSL content matches,
  puttolog=Y,
  id=USUBJID,
  by=USUBJID VISIT,
  criterion=1e-12,
  method=absolute,
  outds=work.unit_test_results
);
~~~
### Notes:

 - `NE` (number of diffs) from PROC COMPARE is used to determine PASS (NE=0) or FAIL (NE>0).

 - If `outds` does not exist, it will be created with standard columns (`test_description`, `test_result`, `test_comments`).

 - This macro does not modify input data; it only reads them to compare.

### URL:

https://github.com/PharmaForest/valivali

---
Author:                 Ryo Nakaya
Latest update Date: 2025-10-15
---

*//*** HELP END ***/

%macro mp_assertdataset(
  base=,					/* parameter in proc compare */
  compare=,				/* parameter in proc compare */
  desc=,					/* description */
  puttolog=Y,			/* put NOTE and ERROR in log */
  id=,						/* parameter in proc compare(e.g. id=USUBJID) */
  by=,      	            /* parameter in proc compare(e.g. by=USUBJID VISIT) */
  criterion=0,       		/* parameter in proc compare */
  method=absolute,    /* parameter in proc compare */
  outds=work.test_results /* output dataset */
);

  %local _ne _equal test_result;

  proc compare base=&base. compare=&compare.
    out=_out outnoequal
    criterion=&criterion. method=&method.
    noprint;
  %if %length(&by.) %then %do; by &by.; %end;
  %if %length(&id.) %then %do; id &id.; %end;
  run;

  data _null_;
    if 0 then set _out nobs=n;
    call symputx('_ne', n, 'L');
  run;

  %let _equal = %sysfunc(ifc(&_ne=0, 1, 0));

  %if &_equal %then %do;
    %if &puttolog = Y %then %do;
	    %put NOTE: MP_ASSERTDATASET: PASS (no differences). NE=&_ne;
	%end;
    %let test_result=PASS;
  %end;
  %else %do;
    %if &puttolog = Y %then %do;
	    %put ERROR: MP_ASSERTDATASET: FAIL (differences found). NE=&_ne;
	%end;
    %let test_result=FAIL;
  %end;

  %if %length(&outds.) %then %do;

    %if not %sysfunc(exist(&outds.)) %then %do;
      data &outds.;
        length test_description $256 test_result $4 test_comments $256;
        stop;
      run;
    %end;

    data _assert_row;
      length test_description $256 test_result $4 test_comments $256;
      test_description = coalescec(symget('desc'),'');
      test_result      = symget('test_result');
      test_comments = catx(" ", "MP_ASSERTDATASET: proc compare",
			cats("base=", symget('base')),
			cats("compare=", symget('compare'))
		);
    run;

    proc append base=&outds. data=_assert_row force; run;
    proc datasets lib=work nolist; delete _assert_row; quit;
  %end;
%mend ;
