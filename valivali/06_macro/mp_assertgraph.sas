/*** HELP START ***//*

### Macro:
    %mp_assertgraph

### Purpose:
    Assertion macro for graph comparison.
    It checks whether two graph files exist at the given paths (gpath1 and gpath2)
    before they are used to display graphs side by side in the report.

### Parameters:

 - `gpath1` (Conditionally required)  
      Full path to the first graph file to be checked. Either gpath1 or gpath2 should exist.

 - `gpath2` (Conditionally required)  
      Full path to the second graph file to be checked. Either gpath1 or gpath2 should exist.

 - `desc` (optional)  
      Free-text description of the assertion.  
      Stored in the output data set if `outds` is specified.

 - `outds` (optional, default=work.test_results)  
      Results table to append a CHECK record.

### Returns:

 - Creates/updates the data set named in `outds`, prints CHECK to the log.  
 - Variable `test_target` and `test_ID` will be created if `test_description` begins with () [].
   (e.g. description of (%macroname1) [test01] xxxxx, test_target=%macroname1, test_ID=test01)  

### Sample code:

~~~sas
%mp_assertgraph(
  gpath1 = /path/to/graph1.png,
  gpath2 = /path/to/graph2.png,
  desc   = Checking two graphs exist before side-by-side display,
  outds  = work.graph_checks
);
~~~

### URL:

https://github.com/PharmaForest/valivali

---
Author:                 Ryo Nakaya
Latest update Date: 2025-11-21
---

*//*** HELP END ***/

%macro mp_assertgraph(
  gpath1=,   						/* full path to first graph file */
  gpath2=,   						/* full path to second graph file */
  desc=,     						/* description of this assertion */
  outds=work.test_results    /* output dataset to append a single result row */
);

  %local _exist1 _exist2 _check_result _comment _lib _mem;

  /* basic parameter check: at least one of gpath1 or gpath2 is required */
  %if %superq(gpath1)= and %superq(gpath2)= %then %do;
    %put ERROR: MP_ASSERTGRAPH: At least one of gpath1= or gpath2= is required.;
    %return;
  %end;

  /* check file existence (allow one side to be blank) */
	%if %superq(gpath1)= %then
	  %let _exist1 = 0;
	%else
	  %let _exist1 = %sysfunc(fileexist(%superq(gpath1)));

	%if %superq(gpath2)= %then
	  %let _exist2 = 0;
	%else
	  %let _exist2 = %sysfunc(fileexist(%superq(gpath2)));

  %if &_exist1 or &_exist2 %then %do;
    %let _check_result = CHECK;

    %if &_exist1 and &_exist2 %then %do;
      %let _comment = MP_ASSERTGRAPH: Two graphs to be visually compared. See appendix. ;
    %end;
    %else %if &_exist1 %then %do;
      %let _comment = MP_ASSERTGRAPH: An output graph to be visually reviewed. See appendix. ;
    %end;
    %else %do;
      %let _comment = MP_ASSERTGRAPH: An output graph to be visually reviewed. See appendix. ;
    %end;

  %end;
  %else %do;
    %put ERROR: MP_ASSERTGRAPH: Neither gpath1 nor gpath2 exists.;
    %return;
  %end;

  /* write result row if outds is specified */
  %if %length(&outds.) %then %do;

    /* create structure */
    %if not %sysfunc(exist(&outds.)) %then %do;
      data &outds.;
        length test_description $256 test_result $5 test_comments $256 gpath1 gpath2 $512 test_target $128 test_ID $64;
        stop;
      run;
    %end;
	%else %do;
	  data &outds.;
	    length test_description $256 test_result $5 test_comments $256 gpath1 gpath2 $512 test_target $128 test_ID $64;
	    set &outds.;
	  run;
	%end;

    data _assert_row;
      length test_description $256 test_result $5 test_comments $256 gpath1 gpath2 $512 test_target $128 test_ID $64;
      test_description	= coalescec(symget('desc'),   '');
      test_result			= symget('_check_result');
      test_comments	= coalescec(symget('_comment'), '');
      gpath1				= symget('gpath1');
      gpath2				= symget('gpath2');

	  test_target			= scan(test_description, 1, '()[]');
	  test_ID				= scan(test_description, 2, '()[]');
    run;

    /* handle potential encoding differences between WORK and target library
       (same pattern as in %mp_assertdataset) */
    %if %index(&outds., .) %then %do;
      %let _lib = %scan(&outds., 1, .);
      %let _mem = %scan(&outds., 2, .);
    %end;
    %else %do;
      %let _lib = WORK;
      %let _mem = &outds.;
    %end;

    %if %upcase(&_lib.) ne WORK %then %do;
      proc copy in=&_lib. out=WORK noclone;
        select &_mem.;
      run;

      proc datasets lib=&_lib. nolist;
        delete &_mem.;
      quit;

      proc copy in=WORK out=&_lib.;
        select &_mem.;
      run;
    %end;

    proc append base=&outds. data=_assert_row force; run;
    proc datasets lib=work nolist; delete _assert_row; quit;
  %end;

%mend;
