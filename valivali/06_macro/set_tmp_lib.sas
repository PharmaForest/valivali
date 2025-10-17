/*** HELP START ***//*

### Macro:

    %set_tmp_lib

### Purpose:

    Create libref of TMP for specific location based on Windows or else(Linux, Unix)

### Parameters:

 - `lib` (required, default=TMP): Library name to assign. 

 - `winpath` (required, default=C:\Temp): Location for windows  

 - `otherpath` (required, default=/tmp): Location for other OS(Linux, Unix)  

### Returns:

    libref for location  

### Sample code:

~~~sas
%set_tmp_lib(
  lib=TMP,
  winpath=C:\Temp,
  otherpath=/tmp
);
~~~
### Notes:

 - Default paths are typical paths

### URL:

https://github.com/PharmaForest/valivali

---
Author:                 Ryo Nakaya
Latest update Date: 2025-10-17
---

*//*** HELP END ***/

%macro set_tmp_lib(
	lib=TMP,
	winpath=C:\Temp,
	otherpath=/tmp );
  %if %upcase(&SYSSCP) = WIN %then %do;
    libname &lib. "&winpath";
  %end;
  %else %do;
    libname &lib. "&otherpath";
  %end;
%mend;