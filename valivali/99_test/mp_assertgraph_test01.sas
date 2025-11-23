/*** HELP START ***//*

### Purpose:
- Unit test for the %mp_assertgraph() macro

### Expected result:  
- WORK.TEST dataset will be created with test_result=CHECK

*//*** HELP END ***/

ods listing gpath="C:\Temp\test\expected";
ods graphics / reset=all
                   imagename="testplot1"
                   imagefmt=png
                   width=300px
                   height=300px;

data dummy;
    x = 0; y = 0; output;
	x=1; y=1; output;
run;
proc sgplot data=dummy ;
    scatter x=x y=y ; 
run;

ods listing gpath="C:\Temp\test\output";
ods graphics / reset=all
                   imagename="testplot2"
                   imagefmt=png
                   width=300px
                   height=300px;

data dummy;
    x = 1; y = 1; output;
	x=2; y=2; output;
run;
proc sgplot data=dummy ;
    scatter x=x y=y ; 
run;

%mp_assertgraph(
  gpath1 = C:\Temp\test\expected\testplot1.png,
  gpath2 = C:\Temp\test\output\testplot2.png,
  desc   = checking two graphs,
  outds  = work.testresults
);
