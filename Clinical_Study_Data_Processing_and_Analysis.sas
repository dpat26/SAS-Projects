|**********************************************************************;
* Project           : Clinical Study Data Processing and Analysis with SAS,Study1
*
* Program name      : Clinical_Study_Data_Processing_and_Analysis.sas
*
* Author            : dpat26
*
* Date created      : 20240320
*
* Purpose           : Processing and analyzing clinical study data.
|**********************************************************************;

* turn on note messages in the log;
options notes; 

/* Create user defined formats */
proc format;
  value sex 
  1 = 'Female'
  2 = 'Male'
     ;
  value race 
  1 = 'Asian'
  2 = 'Black'
  3 = 'Caucasian'
  4 = 'Other'
     ;
run;

*** Check Format catalog for stored format***;

data study; /* Create a data set called study*/
  * 1 Read in the data;
  /* use infile statement to read in the external file containing raw data*/
  infile "/home/u63743031/my_shared_file_links/justina.flavin/c_629/suppTRP-1062.txt" MISSOVER dsd; /*dlm=',' can be used*/
  /* read in variables specifying their types and variable: Site with length of 1, Pt as character of length 2, Dosedate as a date, and */
  /* all other variables should be created as numeric with the default length of 8. */
  input         Site:	   $1. 
  		Pt:	   $2.
  		Sex	
  		Race
  		Dosedate:  mmddyy10. /*read in with informat*/
  		Height
  		Weight
  		Result1
  		Result2
  		Result3
  		;
  format Dosedate mmddyy10.; /*apply format */
  
  * 2 Create a new variable called Doselot;
  
  /* If the dose date is in 1997, then the dose lot is S0576. 
  If the dose date is in 1998 and on or before 10 January 1998, then the dose lot is P1122. 
  If the dose date is after 10 January 1998, then the dose lot is P0526. 
  */ 
  /* Using logical comparison operators to create conditional statements*/
  /* Use date range from 1st jan to 31dec in year for if then else conditions */
  if Dosedate ge '01JAN1997'd and Dosedate le '31DEC1997'd then doselot= 'S0576'; else 
  /* Use date range from 1st jan to 31dec and on or before 10jan*/
  if Dosedate ge '01JAN1998'd and Dosedate le '31DEC1998'd and DoseDate le '10JAN1998'd  then doselot= 'P1122'; else 
  if Dosedate gt '10JAN1998'd then doselot= 'P0526'; else
  if Dosedate = "" then doselot = '';

  * 3 Create two new variables called prot_amend and limit;
  
  /* If the dose lot is P0526 then the Protocol Amendment is B.
  For all other dose lots, the Protocol Amendment is A.
  The Lower Limit of Detection is 0.03 for female patients who received dose lot P0526.
  The Lower Limit of Detection is 0.02 for male patients who received dose lot P0526.
  The Lower Limit of Detection is 0.02 for patients who received dose lots S0576 and P1122.
  */

 /* Set prot_amend and limit based on the conditions provided based on the Sex*/	
  if doselot= 'P0526' then do;
   	prot_amend = 'B';
  	if Sex = 1 then limit = '0.03';
  	else if Sex = 2 then limit = '0.02';
  end;
  
  else if doselot = 'S0576' then do;
  	prot_amend = 'A';
  	limit = 0.02;
  end;
  
  * 4 Using a select statement, create a new variable called site_name;
  
  /* The Site values and associated names are: J=Aurora Health Associates, Q=Omaha Medical Center, R=Sherwin Heights Healthcare */
  length site_name $30.; /* add max length or arbitrary length to ensure no truncation*/ 
  select(site);
	when('J') site_name = 'Aurora Health Associates';
	when('Q') site_name = 'Omaha Medical Center';
	when('R') site_name = 'Sherwin Heights Healthcare';
 	otherwise;
  end;
  
* 5 - Create and apply formats to the Sex and Race variables;

/* The decodes for sex are 1=Female, 2=Male
The decodes for race are 1=Asian, 2=Black, 3=Caucasian, 4=Other
*/
  format sex sex. race race.; /* another method Apply formats for sex and race column based on Proc Format prior to code*/

  * 6 Create labels;

  label Site = 'Study Site'
  		Pt = 'Patient'
  		Dosedate = 'Dose Date'
  		doselot = 'Dose Lot'
  		prot_amend = 'Protocol Amendment'
  		limit = 'Lower Limit of Detection'
  		site_name = 'Site Name'
  		;
run;
