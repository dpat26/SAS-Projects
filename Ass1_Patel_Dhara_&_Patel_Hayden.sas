/* Programming Assignment 1  
   Use this template to help you complete the assignment by filling in the missing code.
   Some blank lines indicate that one or more statements is needed, others are white space to improve readability. 
   Name your completed program Ass1_lastname_firstname.sas  */

* turn on note messages in the log;
options notes; 

*5 Create user defined formats;
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

data study; /*Create a data set called study*/
  * 1 Read in the data;
  infile "/home/u63743031/my_shared_file_links/justina.flavin/c_629/suppTRP-1062.txt" MISSOVER dsd; /*dlm=',' can be used*/
  input Site:		    $1. 
  		Pt:				$2.
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
  
  /*Using logical comparison operators to create conditional statements*/
  /*Use date range from 1st jan to 31dec in year for if then else conditions */
 
  if Dosedate ge '01JAN1997'd and Dosedate le '31DEC1997'd then doselot= 'S0576'; else 
  /*Use date range from 1st jan to 31dec and on or before 10jan*/
  if Dosedate ge '01JAN1998'd and Dosedate le '31DEC1998'd and DoseDate le '10JAN1998'd  then doselot= 'P1122'; else 
  if Dosedate gt '10JAN1998'd then doselot= 'P0526'; else
  if Dosedate = "" then doselot = '';

  
  * 3 Create two new variables called prot_amend and limit;

 /*Set prot_amend and limit based on the conditions provided based on the Sex*/	
  if doselot= 'P0526' then do;
   	prot_amend = 'B';
  	if Sex = 1 then limit = '0.03';
  	if Sex = 2 then limit = '0.02';
  end;
  
  /*prot_amend = 'A'; */
  if doselot ^="" or doselot ^='P0526' then prot_amend ='A';
  if doselot= 'S0576' or doselot= 'P1122' then limit = '0.02';
  * 4 Create a new variable called site_name;
  length site_name $30.; /*add max length or arbitrary length to ensure no truncation*/ 
  select(site);
	when('J') site_name = 'Aurora Health Associates';
	when('Q') site_name = 'Omaha Medical Center';
	when('R') site_name = 'Sherwin Heights Healthcare';
 	otherwise;
  end;
 
   * 5 Apply formats;
  *format;
/* Multiple options when applying formats. We tested out various options */
/* Also learrned using not missing options when working with numeric variables */
/*   	if not missing(sex) then sex = put(sex, $sex.); */
/*   	if not missing(race) then race = put(race, $race.); */
  	/* Use if not missing to address missing . race value */

/* We made multiple attempts to address the warning without any solution*/
/* Reviewed proc format paper on LexJansen website and figured out not to use $ 
		sign when assigning format to numeric variable*/
/*  WARNING: Variable Sex has already been defined as numeric. */
/*  WARNING: Variable Race has already been defined as numeric. */
/* Realised not to add $sex. char format value using $ sign */ 
  	
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
  		
/*  General items practiced use Retain to align variable in output dataset */
/*  retain Pt Site site_name Dosedate doselot prot_amd limit; */
/* 	Tested drop options */
/* 	drop site_name; */
/* Or use keep */
/* 	keep Site Pt site_name; */
run;