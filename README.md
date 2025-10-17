# valivali (Latest version 0.0.2 on 17Oct2025)
**Valivali is a validation toolbox** that provides utilities to test and validate SAS packages.  
Use it during package creation and verification to ensure expected behavior and reproducible results.  
Valivali loads {sasjscore} package developed by Allan Bowe when valivali is loaded and strongly influenced and powered by [sasjscore](https://github.com/SASPAC/sasjscore). You need to install {sasjscore} to use the package.   
By loading valivali, users can utilize valivali original macros in addition to {sasjscore} macros for validation.  

BTW, "valivali" means bad boy's vibes in Japanese😁  
<img src="https://github.com/PharmaForest/valivali/blob/main/valivali_logo.png?raw=true" alt="valivali" width="300"/>

Available macros for validations are as below.
- %mp_assertdataset	: To see datasets are equal by proc compare    
- %mp_assert				: To see if condition is TRUE (from sasjscore)  
- %mp_assertcols		: To see if columns(variables) are in expected condition (from sasjscore)    
- %mp_assertcolvals	: To see if values in variables are in expected condition (from sasjscore)  
- %mp_assertdsobs		: To see if # of observations is in expected condition (from sasjscore)  
- %mp_assertscope		: To check macro scope (from sasjscore)
  
For usage of macros from sasjscore, please see [sasjscore](https://github.com/SASPAC/sasjscore).  
 
---

## %mp_assertdataset

### Purpose:
Compares two SAS data sets using `PROC COMPARE` and asserts equality. Writes a concise PASS/FAIL message to the SAS log and optionally appends a row to an output results data set.
            
### Parameters:
~~~sas
 - base (required)    : Data set used as BASE in PROC COMPARE.
 - compare (required) : Data set used as COMPARE in PROC COMPARE.
 - desc (optional)    : Free-text description of the assertion; stored in the output table when `outds` is set.  
 - puttolog (optional, default=Y)  : To switch put NOTE and ERROR of PASS/FAIL into log (Can change to puttolog=N if FAIL is expected in test)  
 - id (optional)      : ID variable list for PROC COMPARE (e.g., `id=USUBJID`).
 - by (optional)      : BY variable list for PROC COMPARE (e.g., `by=USUBJID VISIT`).
 - criterion (optional, default=0)  : Tolerance for comparisons (PROC COMPARE `criterion=`).
 - method (optional, default=absolute)  : Comparison method (PROC COMPARE `method=`).
 - outds (optional, default=work.test_results)  : Results table to append a PASS/FAIL record.
~~~

### Example usage:
~~~sas
%mp_assertdataset(
  base     = work.adsl_expected,
  compare  = work.adsl_actual,
  desc     = Check ADSL content matches,
  puttolog = Y,
  criterion= 1e-12,
  method   = absolute,
  outds    = test_results
)
~~~

 Author:     Ryo Nakaya  
 Latest Update Date:  2025-10-16

## %set_tmp_lib

### Purpose:
Assign library to locations for Windows or other(Linux, Unix). This can be used to assign common location across different sessions to be run during tests in %GeneratePackage().  
            
### Parameters:
~~~sas
 - `lib` (required, default=TMP): Library name to assign. 
 - `winpath` (required, default=C:\Temp): Location for windows  
 - `otherpath` (required, default=/tmp): Location for other OS(Linux, Unix)  
~~~

### Example usage:
In each test script, you can add below.
~~~sas
%loadPackage(valivali)
%set_tmp_lib() /* Assign TMP to common location */

/* test scripts like */
%mp_assertdataset(
  base     = work.adsl_expected,
  compare  = work.adsl_actual,
  desc     = Check ADSL content matches,
  puttolog = Y,
  criterion= 1e-12,
  method   = absolute,
  outds    = TMP.test_results /* Append to the file in the TMP library */
)
~~~

 Author:     Ryo Nakaya  
 Latest Update Date:  2025-10-17  

---
 
## Version history  
0.0.2(17October2025)	: Added %set_tmp_lib  
0.0.1(16October2025)	: Initial version

## What is SAS Packages?

The package is built on top of **SAS Packages Framework(SPF)** developed by Bartosz Jablonski.

For more information about the framework, see [SAS Packages Framework](https://github.com/yabwon/SAS_PACKAGES).

You can also find more SAS Packages (SASPacs) in the [SAS Packages Archive(SASPAC)](https://github.com/SASPAC).

## How to use SAS Packages? (quick start)

### 1. Set-up SAS Packages Framework

First, create a directory for your packages and assign a `packages` fileref to it.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas
filename packages "\path\to\your\packages";
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Secondly, enable the SAS Packages Framework.
(If you don't have SAS Packages Framework installed, follow the instruction in 
[SPF documentation](https://github.com/yabwon/SAS_PACKAGES/tree/main/SPF/Documentation) 
to install SAS Packages Framework.)

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas
%include packages(SPFinit.sas)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


### 2. Install SAS package

Install SAS package you want to use with the SPF's `%installPackage()` macro.

- For packages located in **SAS Packages Archive(SASPAC)** run:
  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas
  %installPackage(packageName)
  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- For packages located in **PharmaForest** run:
  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas
  %installPackage(packageName, mirror=PharmaForest)
  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- For packages located at some network location run:
  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas
  %installPackage(packageName, sourcePath=https://some/internet/location/for/packages)
  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  (e.g. `%installPackage(ABC, sourcePath=https://github.com/SomeRepo/ABC/raw/main/)`)


### 3. Load SAS package

Load SAS package you want to use with the SPF's `%loadPackage()` macro.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~sas
%loadPackage(packageName)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


### Enjoy!

---
