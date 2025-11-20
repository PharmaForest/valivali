Type: Package
Package: valivali
Title: valivali - validation toolbox -
Version: 0.1.2
Author: PharmaForest
Maintainer: PharmaForest
License: MIT
Encoding: UTF8
Required: "Base SAS Software"
ReqPackages: "sasjscore"
DESCRIPTION START:

##  valivali
**A SAS package to support validation tasks**

Valivali is a validation toolbox that provides utilities to test and validate SAS packages.  
Use it during package creation and verification to ensure expected behavior and reproducible results.  
Valivali loads {sasjscore} package developed by Allan Bowe when valivali is loaded and strongly influenced and powered by {sasjscore}.  
By loading valivali, users can utilize valivali original macros in addition to {sasjscore} macros for validation.  

Available macros for validations are as below.
- %mp_assertdataset	: To see datasets are equal by proc compare    
- %mp_assert				: To see if condition is TRUE (from sasjscore)  
- %mp_assertcols		: To see if columns(variables) are in expected condition (from sasjscore)    
- %mp_assertcolvals	: To see if values in variables are in expected condition (from sasjscore)  
- %mp_assertdsobs		: To see if # of observations is in expected condition (from sasjscore)  
- %mp_assertscope		: To check macro scope (from sasjscore)    
- %set_tmp_lib				: To assign temporary libref for common location of Windows and other(Linux or Unix)  
- %create_report			: To create validation report rtf  


### Usage
For more details, please visit
- https://github.com/PharmaForest/valivali  
- https://github.com/SASPAC/sasjscore  

---

DESCRIPTION END: