/*** HELP START ***//*

### Purpose:
- Unit test for the %create_report() macro

### Expected result:  
- RTF and PDF files will be created in the folder with graph check results.
  (testplot1.png and testplot2.png are required in gpath1 and gpath2 folder for the test)

*//*** HELP END ***/

data dummy_results ;
  length test_description $256. test_result $20. test_comments $256. gpath1 $256. gpath2 $256. test_target $128. test_ID $64.;
  test_description = "<Dummy description. Check macro variable resolution>"; 
  test_result = "PASS";
  test_comments = "<Dummy comments. Macro resolved correctly without warning messages.>"; 
  output;

  test_description = "<Dummy description. Validate date format conversion>";
  test_result = "FAIL";
  test_comments = "<Dummy comments. Conversion failed when input date was missing.>"; 
  output;

  test_description = "<Dummy description. Validate date format conversion>";
  test_result = "CHECK";
  test_comments = "<Dummy comments. Check appendix.>";
  gpath1 = "C:\Temp\test\expected\testplot1.png" ;
  gpath2 = "C:\Temp\test\output\testplot2.png" ;
  test_target = "<macroname>" ;
  test_ID = "test01" ; 
  output;
run ;

%create_report(
  reporter = John,
  general  = %nrstr(Validation of reporting utilities.),
  requirements = %nrstr(
   - %<check_1> ^{newline}
    Confirm macro variable resolution. ^{newline}
   - %<check_2> ^{newline}
    Confirm date formatting and newline rendering.
  ),
  results = dummy_results ,
  additional = %nrstr(No additional comments.),
  references = %nrstr(
    https://company.example/validation ^{newline}
    Document reference
  ),
  outfilelocation = C:\Temp
);
