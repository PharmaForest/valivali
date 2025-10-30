/*** HELP START ***//*

### Purpose:
- Unit test for the %create_report() macro

### Expected result:  
- RTF file will be created in the folder.

*//*** HELP END ***/

%create_report(
  reporter = John,
  general  = %nrstr(Validation of reporting utilities.),
  requirements = %nrstr(
   - %<check_1> ^{newline}
    Confirm macro variable resolution. ^{newline}
   - %<check_2> ^{newline}
    Confirm date formatting and newline rendering.
  ),
  results = ,
  additional = %nrstr(No additional comments.),
  references = %nrstr(
    https://company.example/validation ^{newline}
    Document reference
  ),
  outrtflocation = C:\Temp
);