/*** HELP START ***//*

### Macro:

    %set_tmp_lib

### Purpose:

    Create libref of TEMP(by default) for specific location based on Windows or else(Linux, Unix)

### Parameters:

 - `lib` (optional, default=TEMP): Library name to assign. 

 - `winpath` (optional, default=C:\Temp): Location for windows  

 - `otherpath` (optional, default=/tmp): Location for other OS(Linux, Unix)  

 - `newfolder` (optional): New folder in the path  

### Returns:

    libref for location or new folder in location (if newfolder is specified)   

### Sample code:

~~~sas
%set_tmp_lib(
  lib=TEMP,
  winpath=C:\Temp,
  otherpath=/tmp,
  newfolder=test
);
~~~
### Notes:

 - Default paths are typical paths

### URL:

https://github.com/PharmaForest/valivali

---
Author:                 Ryo Nakaya
Latest update Date: 2025-10-30
---

*//*** HELP END ***/

%macro set_tmp_lib(lib=TEMP, winpath=C:\Temp, otherpath=/tmp, newfolder=);
  %local basepath slash fullpath rc ;

  /*=== Pick base path and slash based on OS ===*/
  %if %upcase(&SYSSCP) = WIN %then %do;
    %let basepath = &winpath;
    %let slash    = \;
  %end;
  %else %do;
    %let basepath = &otherpath;
    %let slash    = /;
  %end;

  /*=== Build final path ===*/
  %if %length(&newfolder) %then %do;
    /* final folder is basepath/newfolder */
    %let fullpath = %sysfunc(catx(&slash, &basepath, &newfolder));
  %end;
  %else %do;
    /* just use basepath as-is */
    %let fullpath = &basepath;
  %end;

  /*=== Ensure directory exists ===*/
  %if %length(&newfolder) %then %do;

    /* only try to create when subfolder was requested */
    %if not %sysfunc(fileexist(&fullpath)) %then %do;
      %put NOTE: &fullpath does not exist. Creating...;

      /* dcreate takes (new-subdir-name, parent-dir) */
      %let rc = %sysfunc(dcreate(&newfolder, &basepath));

      %if &rc = 0 %then %put ERROR: Failed to create folder &fullpath;
    %end;
    %else %do;
      %put NOTE: &fullpath already exists.;
    %end;

  %end;
  %else %do;
    /* when no subfolder is requested, just sanity-check basepath */
    %if %sysfunc(fileexist(&fullpath)) %then %do;
      %put NOTE: Using existing folder &fullpath;
    %end;
    %else %do;
      %put ERROR: Base path &fullpath does not exist or is not accessible.;
    %end;
  %end;

  /*=== Assign library ===*/
  libname &lib "&fullpath";

%mend;