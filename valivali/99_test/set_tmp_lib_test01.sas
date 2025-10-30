/*** HELP START ***//*

### Purpose:
- Unit test for the %set_tmp_lib() macro

### Expected result:  
- test folder is created in the path

*//*** HELP END ***/

%set_tmp_lib(
  lib=TEMP,
  winpath=C:\Temp,
  otherpath=/tmp,
  newfolder=test
)