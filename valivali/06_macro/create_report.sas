/*** HELP START ***//*

### Macro:

    %create_report

### Purpose:

    Generates an RTF/PDF **Validation Report** using ODS RTF/PDF and PROC ODSTEXT/PROC REPORT.
    Reads *description.sas* from a SAS Package source folder (via `sourcelocation`)
    to display package name, version, and required packages in the header.

### Parameters:

- `sourcelocation` (optional): Path to a SAS package **source folder** containing `description.sas`.  
  If blank, the header shows placeholder values for Package/Version/ReqPackages.  

- `reporter` (required): Person responsible for the report, printed under the title.  

- `general` (optional): Introductory remarks shown in the *General Information* section.  

- `requirements` (optional): Bullet-like text for the *Requirements* section. Supports `^{newline}` escapes.  

- `results` (optional): Dataset name with three columns: `test_description`, `test_result` (`PASS`/`FAIL`), and `test_comments`.  
  If not provided, the macro creates a small `dummy_results` dataset.  

- `additional` (optional): Free text printed in the *Additional comments* section.  

- `references` (optional): Reference URLs or document titles, each separated with `^{newline}`.  

- `outfilelocation` (required): Existing folder path where the RTF/PDF file will be written.  
   ** Note: `outrtflocation` was used by v0.1.0. Changed arguement name to cover RTF and PDF. It is kept in use in pallalel with the new arguement.  

### Sample code:

~~~sas

%create_report(
  outfilelocation = C:\Temp
) ;

%create_report(
  sourcelocation = C\Temp\mypackage ,
  reporter = John,
  general  = %nrstr(Validation of reporting utilities.),
  requirements = %nrstr(
   - %<check_1> ^{newline}
    Confirm macro variable resolution. ^{newline}
   - %<check_2> ^{newline}
    Confirm date formatting and newline rendering.
  ),
  results = temp.mypackage_test,
  additional = %nrstr(No additional comments.),
  references = %nrstr(
    https://company.example/validation ^{newline}
    Document reference
  ),
  outfilelocation = C:\Temp
);

~~~

### Notes:

 - In case of reporting results from %assertgraph(), 300 px x 300 px or smaller is desirable to place two graphs in a row.
   %create_report() will output graphs stored in locations which are described in `gpath1` and `gpath2` in %assertgraph().

### URL:
https://github.com/PharmaForest/valivali

---

Author:                 Ryo Nakaya
Latest update Date: 2025-11-23

---

*//*** HELP END ***/

%macro create_report(
  sourcelocation= ,
  reporter = <Reporter Name>,
  general = %nrstr(<General description or introductory remarks>),
  requirements = %nrstr(
 - %<macro_1> ^{newline}
<Description of requirement 1> ^{newline}

 - %<macro_2> ^{newline}
<Description of requirement 2> ^{newline}
  ),
  results = ,
  additional = %nrstr(<Additional comments or notes>),
  references = %nrstr(
<Reference URL1 or document1> ^{newline}
<Reference URL2 or document2> ^{newline}
  ),
  outfilelocation = ,/* path for output RTF/PDF */
  outrtflocation = /* old arguement of outfilelocation */
  );

  /*===macro start===*/
  %local _app_lib _app_mem _has_graphrecs_rtf _has_graphrecs_pdf;

	/*Check outfilelocation*/
  %if %superq(outfilelocation)= %then %do;
   %if %superq(outrtflocation)= %then %do;
    %put ERROR: The parameter OUTFILELOCATION must be specified.;
    %abort cancel;
   %end;
   %else %do;
    %let outfilelocation = &outrtflocation;
   %end;
  %end;

  %if %sysfunc(fileexist(%superq(outfilelocation))) = 0 %then %do;
    %put ERROR: The specified folder does not exist: %superq(outfilelocation);
    %abort cancel;
  %end;

	/*Dummy data for validation results*/
  %if %superq(results)= %then %do ;
  data dummy_results ;
	  length test_description $256. test_result $20. test_comments $256. ;
	  test_description = "<Dummy description. Check macro variable resolution>"; 
	  test_result = "PASS";
	  test_comments = "<Dummy comments. Macro resolved correctly without warning messages.>"; 
	  output;

	  test_description = "<Dummy description. Validate date format conversion>";
	  test_result = "FAIL";
	  test_comments = "<Dummy comments. Conversion failed when input date was missing.>"; 
	  output;
  run ;
  %end ;

	/*Obtain package and version from description.sas*/
	  %if %superq(sourcelocation)= %then %do;
	    %let package = Package Name ; /*<> cannot be used in file name*/
		%let version = x.x.x ;
		%let author = <Author Name> ;
		%let reqpackages = <Required packages> ;
	  %end;
	  %else %do ;/*if sourcelocation is not blank*/
  	    %let descfile = &sourcelocation./description.sas; /*File path*/

	    %if %sysfunc(fileexist(&descfile.)) = 0 %then %do;
	      %put ERROR: File not found: &descfile.;
	      %return;
	    %end;

	    data _descfile; /*create dataset of description*/
	      infile "&descfile." truncover;
	      length line $200;
	      input line $200.;
	    run;

	    data _null_;
	      set _descfile end=last;
	      retain package version reqpackages author;

		  if upcase(compress(line, ' ')) =: "PACKAGE:" then do;
	        package = strip(scan(line, 2, ':'));
	      end;
		  if upcase(compress(line, ' ')) =: "VERSION:" then do;
  		    version = strip(scan(line, 2, ':'));
	      end;
		  if upcase(compress(line, ' ')) =: "AUTHOR:" then do;
  		    author = strip(scan(line, 2, ':'));
	      end;
		  if upcase(compress(line, ' ')) =: "REQPACKAGES:" then do;
  		    reqpackages = strip(scan(line, 2, ':'));
	      end;

		  if last then do;
		    if missing(reqpackages) then reqpackages = "-";
		    call symputx('package',     package,     'L'); 
		    call symputx('version',     version,     'L');
		    call symputx('author',     author,     'L');
		    call symputx('reqpackages', reqpackages, 'L');
		  end;
	    run;
	  %end ;

	ods escapechar = '^' ; /*escape character*/
	options nodate nonumber linesize=256 topmargin=1in bottommargin=1in leftmargin=0.8in rightmargin=0.8in ;

	ods listing close ;

	/*create RTF*/
	title; footnote;
	ods rtf file="&outfilelocation./Validation_Report_&package._&version..rtf" style=journal startpage=no;

	proc odstext;
	  p "Validation Report" /
	    style=[just=c font_weight=bold font_size=28pt] ;
	  p "&package (Version &version)" /
	    style=[just=c font_weight=bold font_size=18pt] ;
	  p "" /
	    style=[just=c font_weight=bold font_size=12pt] ;
	  p "&reporter" /
	    style=[just=c font_size=12pt] ;
	  p "" /
	    style=[just=c font_weight=bold font_size=12pt] ;
	  p "%sysfunc(today(), date9.)" /
	    style=[just=c font_size=12pt] ;
	  p "" /
	    style=[just=c font_weight=bold font_size=12pt] ;

	  p "General Information" / /*Section title*/
	    style=[just=l font_weight=bold font_size=14pt] ;
	  p "&general" /
	    style=[just=l font_size=10pt] ;
	  p "" /
	    style=[just=l font_weight=bold font_size=10pt] ;

	  p "Validation Environment" / /*Section title*/
	    style=[just=l font_weight=bold font_size=14pt] ;
	  p "OS: &SYSSCP" /
	    style=[just=l font_size=10pt] ;
	  p "SAS: &SYSVLONG" /
	    style=[just=l font_size=10pt] ;
	  p "Required Packages: &reqpackages" /
	    style=[just=l font_size=10pt] ;
	  p "Execution Datetime: %sysfunc(datetime(), datetime19.)" /
	    style=[just=l font_size=10pt] ;
	  p "" /
	    style=[just=l font_weight=bold font_size=10pt] ;

	  p "Authors" / /*Section title*/
	    style=[just=l font_weight=bold font_size=14pt] ;
	  p "&author" /
	    style=[just=l font_size=10pt] ;
	  p "" /
	    style=[just=l font_weight=bold font_size=10pt] ;

	  p "Requirements" / /*Section title*/
	    style=[just=l font_weight=bold font_size=14pt] ;
	  p "&requirements" /
	    style=[just=l font_size=10pt] ;
	  p "" /
	    style=[just=l font_weight=bold font_size=10pt] ;

	  p "Validation Records" / /*Section title*/
	    style=[just=l font_weight=bold font_size=14pt] ;
	run;

	%if %superq(results)= %then %do ;
	  %let results = dummy_results ;
	%end ;

	  /* Appendix: Extract records with gpath1/gpath2 */
	%let _has_graphrecs_rtf = 0;

  /* libname.memname */
	%if %index(&results.,.) %then %do;
	  %let _app_lib = %scan(&results., 1, .);
	  %let _app_mem = %scan(&results., 2, .);
	%end;
	%else %do;
	  %let _app_lib = WORK;
	  %let _app_mem = &results.;
	%end;

  /* Check existence of gpath1/gpath2 columns */
  %let _has_graphrecs_rtf = 0;
  %let _has_gpathcols_rtf = 0;

  proc sql noprint;
    select count(*) into :_has_gpathcols_rtf
    from dictionary.columns
    where libname = "%upcase(&_app_lib.)"
      and memname = "%upcase(&_app_mem.)"
      and upcase(name) in ("GPATH1","GPATH2");
  quit;

  /* Extract if gpath1/gpath2 exist */
  %if &_has_gpathcols_rtf > 0 %then %do;
    proc sql noprint;
      create table _appendix_graphs_rtf as
        select *
        from &results.
        where coalesce(strip(gpath1),'') ne "" 
           or coalesce(strip(gpath2),'') ne "";
      select count(*) into :_has_graphrecs_rtf from _appendix_graphs_rtf;
    quit;
  %end;

  /*proc report*/
	proc report data=&results. style(header)=[font_weight=bold font_style=roman font_size=11pt];
	  columns test_description test_result test_comments;
	  define test_description	/ display "Test Description" style(column)=[cellwidth=3.3in just=l] width=100 ;
	  define test_result		/ display "Result" style(column)=[cellwidth=0.6in just=c] ;
	  define test_comments	/ display "Comments" style(column)=[cellwidth=2.2in just=l] width=100 ;

	  compute test_result;
	    length _sty $200;
	    _sty = "";  /* reset each row */
	    select (upcase(strip(test_result)));
	      when ("PASS") _sty = "style=[font_weight=bold color=green]";
	      when ("FAIL") _sty = "style=[font_weight=bold color=red]";
		  when ("CHECK") _sty = "style=[font_weight=bold color=orange]";
	      otherwise      _sty = "";  /* no special style */
	    end;
	    if _sty ne "" then call define(_col_, "style", _sty);
	  endcomp;
	run;

	proc odstext;
	  p "Additional comments" / /*Section title*/
	    style=[just=l font_weight=bold font_size=14pt] ;
	  p "&additional" /
	    style=[just=l font_size=10pt] ;
	  p "" /
	    style=[just=l font_weight=bold font_size=10pt] ;

	  p "References" / /*Section title*/
	    style=[just=l font_weight=bold font_size=14pt] ;
	  p "&references" /
	    style=[just=l font_size=10pt] ;
	  p "" /
	    style=[just=l font_weight=bold font_size=10pt] ;
	run;

	/* Appendix */
	%if &_has_graphrecs_rtf > 0 %then %do;

	  data _appendix_pairs_rtf;
	    set _appendix_graphs_rtf;
	    length label $500;
	    if not missing(test_target) and not missing(test_ID) then
	      label = "("||strip(test_target)||") ["||strip(test_ID)||"]";
	    else
	      label = "Plot";
	  run;

	  proc odstext;
	    p "Appendix" /
	      style=[just=l font_weight=bold font_size=14pt];
	  run;

	  proc report data=_appendix_pairs_rtf nowd
	    style(report)=[just=l cellspacing=0 cellpadding=0]
	    style(header)=[font_weight=bold]
	    style(column)=[just=c];
	    columns label gpath1 gpath2;

	    define label / noprint;
	    define gpath1 / display "Previous"
	      style(column)=[cellwidth=3.2in];
	    define gpath2 / display "Current"
	      style(column)=[cellwidth=3.2in];

	    compute gpath1;
	      length _sty $200;
	      if not missing(gpath1) then do;
	        _sty   = 'style={preimage="' || trim(gpath1) ||
	                 '" pretext="' || trim(label) ||'"}';
	        gpath1 = '';
	      end;
	      else do;
	        gpath1 = '';
	        _sty = 'style={}';
	      end;
	      call define(_col_,'style',_sty);
	    endcomp;

	    compute gpath2;
	      length _sty $200;
	      if not missing(gpath2) then do;
	        _sty   = 'style={preimage="' || trim(gpath2) ||
	                 '" pretext="' || trim(label) ||'"}';
	        gpath2 = ''; 
	      end;
	      else _sty = 'style={}';
	      call define(_col_,'style',_sty);
	    endcomp;
	  run;

	  proc datasets lib=work nolist;
	    delete _appendix_graphs_rtf _appendix_pairs_rtf;
	  quit;

	%end;  /* &_has_graphrecs_rtf > 0 */


	ods rtf close;
	title; footnote;



	/*create PDF*/
	title; footnote;
	ods pdf file="&outfilelocation./Validation_Report_&package._&version..pdf" style=journal startpage=no;

	proc odstext;
	  p "Validation Report" /
	    style=[just=c font_weight=bold font_size=28pt] ;
	  p "&package (Version &version)" /
	    style=[just=c font_weight=bold font_size=18pt] ;
	  p "" /
	    style=[just=c font_weight=bold font_size=12pt] ;
	  p "&reporter" /
	    style=[just=c font_size=12pt] ;
	  p "" /
	    style=[just=c font_weight=bold font_size=12pt] ;
	  p "%sysfunc(today(), date9.)" /
	    style=[just=c font_size=12pt] ;
	  p "" /
	    style=[just=c font_weight=bold font_size=12pt] ;

	  p "General Information" / /*Section title*/
	    style=[just=l font_weight=bold font_size=14pt] ;
	  p "&general" /
	    style=[just=l font_size=10pt] ;
	  p "" /
	    style=[just=l font_weight=bold font_size=10pt] ;

	  p "Validation Environment" / /*Section title*/
	    style=[just=l font_weight=bold font_size=14pt] ;
	  p "OS: &SYSSCP" /
	    style=[just=l font_size=10pt] ;
	  p "SAS: &SYSVLONG" /
	    style=[just=l font_size=10pt] ;
	  p "Required Packages: &reqpackages" /
	    style=[just=l font_size=10pt] ;
	  p "Execution Datetime: %sysfunc(datetime(), datetime19.)" /
	    style=[just=l font_size=10pt] ;
	  p "" /
	    style=[just=l font_weight=bold font_size=10pt] ;

	  p "Authors" / /*Section title*/
	    style=[just=l font_weight=bold font_size=14pt] ;
	  p "&author" /
	    style=[just=l font_size=10pt] ;
	  p "" /
	    style=[just=l font_weight=bold font_size=10pt] ;

	  p "Requirements" / /*Section title*/
	    style=[just=l font_weight=bold font_size=14pt] ;
	  p "&requirements" /
	    style=[just=l font_size=10pt] ;
	  p "" /
	    style=[just=l font_weight=bold font_size=10pt] ;

	  p "Validation Records" / /*Section title*/
	    style=[just=l font_weight=bold font_size=14pt] ;
	run;

	%if %superq(results)= %then %do ;
	  %let results = dummy_results ;
	%end ;

  /* Check existence of variable gpath1/gpath2 and non-missing record */
  %let _has_graphrecs_pdf = 0;
  %let _has_gpathcols_pdf = 0;

  %if %index(&results.,.) %then %do;
    %let _app_lib = %scan(&results., 1, .);
    %let _app_mem = %scan(&results., 2, .);
  %end;
  %else %do;
    %let _app_lib = WORK;
    %let _app_mem = &results.;
  %end;

  proc sql noprint;
    select count(*) into :_has_gpathcols_pdf
    from dictionary.columns
    where libname = "%upcase(&_app_lib.)"
      and memname = "%upcase(&_app_mem.)"
      and upcase(name) in ("GPATH1","GPATH2");
  quit;

  %if &_has_gpathcols_pdf > 0 %then %do;
    proc sql noprint;
      create table _appendix_graphs_pdf as
        select *
        from &results.
        where coalesce(strip(gpath1),'') ne "" 
           or coalesce(strip(gpath2),'') ne "";
      select count(*) into :_has_graphrecs_pdf from _appendix_graphs_pdf;
    quit;
  %end;

	proc report data=&results. style(header)=[font_weight=bold font_style=roman font_size=11pt];
	  columns test_description test_result test_comments;
	  define test_description	/ display "Test Description" style(column)=[cellwidth=3.3in just=l] width=100 ;
	  define test_result		/ display "Result" style(column)=[cellwidth=0.6in just=c] ;
	  define test_comments	/ display "Comments" style(column)=[cellwidth=2.2in just=l] width=100 ;

	  compute test_result;
	    length _sty $200;
	    _sty = "";  /* reset each row */
	    select (upcase(strip(test_result)));
	      when ("PASS") _sty = "style=[font_weight=bold color=green]";
	      when ("FAIL") _sty = "style=[font_weight=bold color=red]";
		  when ("CHECK") _sty = "style=[font_weight=bold color=orange]";
	      otherwise      _sty = "";  /* no special style */
	    end;
	    if _sty ne "" then call define(_col_, "style", _sty);
	  endcomp;
	run;

	proc odstext;
	  p "Additional comments" / /*Section title*/
	    style=[just=l font_weight=bold font_size=14pt] ;
	  p "&additional" /
	    style=[just=l font_size=10pt] ;
	  p "" /
	    style=[just=l font_weight=bold font_size=10pt] ;

	  p "References" / /*Section title*/
	    style=[just=l font_weight=bold font_size=14pt] ;
	  p "&references" /
	    style=[just=l font_size=10pt] ;
	  p "" /
	    style=[just=l font_weight=bold font_size=10pt] ;
	run;

  /* Appendix */
  %if &_has_graphrecs_pdf > 0 %then %do;
    proc odstext;
      p "Appendix" /
        style=[just=l font_weight=bold font_size=14pt] ;
    run;

	ods layout gridded columns=2;

	data _null_;
	  set _appendix_graphs_pdf;
	    if not missing(test_target) and not missing(test_ID) then do;
	      if substr(test_target,1,1) = '%' then
	        /* To avoid warning by % instead using ^{unicode 0025} */
	        _label = '(' || '^{unicode 0025}' || strip(substr(test_target,2)) ||') [' || strip(test_ID) || ']';
	      else
	        _label = '(' || strip(test_target) || ') [' || strip(test_ID) || ']';
	    end;
	    else do;
	      _label = 'Plot';
	    end;

		call execute('ods region;');
		call execute('proc odstext;');
	    if not missing(gpath1) then do;
	      call execute(
	        '  p "^{style [preimage=''' || trim(gpath1) ||
	        ''']}" / style=[just=c];'
	      );
	    end;
	    call execute(
	      '  p "%nrstr(' || trim(_label) ||
	      ') Previous" / style=[just=c font_weight=bold font_size=10pt];'
	    );
	    call execute('run;');

	    call execute('ods region;');
	    call execute('proc odstext;');
	    if not missing(gpath2) then do;
	      call execute(
	        '  p "^{style [preimage=''' || trim(gpath2) ||
	        ''']}" / style=[just=c];'
	      );
	    end;
	    call execute(
	      '  p "%nrstr(' || trim(_label) ||
	      ') Current" / style=[just=c font_weight=bold font_size=10pt];'
	    );
	    call execute('run;');
	  run;
	ods layout end;


    proc datasets lib=work nolist;
      delete _appendix_graphs_pdf;
    quit;
  %end;

	ods pdf close;
	title; footnote;

	ods listing;

%mend ;
