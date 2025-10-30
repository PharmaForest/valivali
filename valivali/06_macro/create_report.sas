/*** HELP START ***//*

### Macro:

    %create_report

### Purpose:

    Generates an RTF **Validation Report** using ODS RTF and PROC ODSTEXT/PROC REPORT.
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

- `outrtflocation` (required): Existing folder path where the RTF file will be written.  

### Sample code:

~~~sas

%create_report(
  outrtflocation = C:\Temp
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
  outrtflocation = C:\Temp
);

~~~

### URL:
https://github.com/PharmaForest/valivali

---

Author:                 Ryo Nakaya
Latest update Date: 2025-10-30

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
  outrtflocation = /* path for output rtf */
  );

  /*===macro start===*/

	/*Check outrtflocation*/
  %if %superq(outrtflocation)= %then %do;
    %put ERROR: The parameter OUTRTFLOCATION must be specified.;
    %abort cancel;
  %end;

  %if %sysfunc(fileexist(%superq(outrtflocation))) = 0 %then %do;
    %put ERROR: The specified folder does not exist: %superq(outrtflocation);
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

	title; footnote;
	ods rtf file="&outrtflocation./Validation_Report_&package._&version..rtf" style=journal startpage=no;

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
	  p "SAS: &SYSVER" /
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

	ods rtf close;
	ods rtf startpage=yes;

	title; footnote;

%mend ;
