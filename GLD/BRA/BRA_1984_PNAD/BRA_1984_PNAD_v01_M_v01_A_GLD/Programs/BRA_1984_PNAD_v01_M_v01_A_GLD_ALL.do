
/*%%============================================================================
      0: GLD Harmonization Preamble
============================================================================%%*/

/* -----------------------------------------------------------------------------

<_Program name_> 			BRA_1984_PNAD_v01_M_v01_A_GLD_ALL.do </_Program name_>
<_Application_> 			STATA 17.0 <_Application_>
<_Author(s)_> 				World Bank Jobs Group (gld@worldbank.org) </_Author(s)_>
<_Date created_> 			2022-04-01 </_Date created_>

--------------------------------------------------------------------------------

<_Country_> 				BRA </_Country_>
<_Survey Title_> 			PNAD </_Survey Title_>
<_Survey Year_> 			1984 </_Survey Year_>
<_Study ID_> 				BRA_1984_PNAD_v01_M </_Study ID_>
<_Data collection from_> 	09/1984 </_Data collection from_>
<_Data collection to_> 		09/1984 </_Data collection to_>
<_Source of dataset_> 		https://www.ibge.gov.br/estatisticas/sociais/trabalho/9127-pesquisa-nacional-por-amostra-de-domicilios.html?=&t=downloads </_Source of dataset_>
<_Sample size (HH)_> 		116,409 </_Sample size (HH)_>
<_Sample size (IND)_> 		514,866 </_Sample size (IND)_>
<_Sampling method_> 		Probabilistic sampling of households obtained in
three selection stages: primary units - municipalities; secondary units -
census sectors; tertiary units - domicile units </_Sampling method_>
<_Geographic coverage_> 	Metropolitan Area </_Geographic coverage_>
<_Currency_> 				Brazilian Cruzeiro (Cr$) </_Currency_>

--------------------------------------------------------------------------------

<_ICLS Version_> 			ICLS-13 </_ICLS Version_>
<_ISCED Version_> 			isced_2011 </_ISCED Version_>
<_ISCO Version_> 			ISCO 1988 </_ISCO Version_>
<_OCCUP National_> 			CBO Domiciliar </_OCCUP National_>
<_ISIC Version_> 			ISIC Rev. 3 </_ISIC Version_>
<_INDUS National_> 			CNAE Domiciliar </_INDUS National_>

--------------------------------------------------------------------------------
<_Version Control_>

* Date: [YYYY-MM-DD] - [Description of changes]
* Date: [YYYY-MM-DD] - [Description of changes]

</_Version Control_>

------------------------------------------------------------------------------*/


/*%%============================================================================
   1: Setting up of program environment, dataset
============================================================================%%*/

*----------1.1: Initial commands-----------------------------------------------*

	clear all
	set more 1

*----------1.2 Set directories-------------------------------------------------*


*----------1.2 Set directories-------------------------------------------------*

	local path_input "Y:\GLD\BRA\BRA_1984_PNAD\BRA_1984_PNAD_v01_M\Data\Stata"
	local path_output "Y:\GLD\BRA\BRA_1984_PNAD\BRA_1984_PNAD_v01_M_v01_A_GLD\Data\Harmonized"

*----------1.3 Merge Household and People files--------------------------------*

	local year = 1984
	local digitos = substr("`year'", 3, 2)

* Get some of what you did in the transformation and put it here

	use "`path_input'\pnad1984.dta",clear


/*%%============================================================================
   2: Survey & ID
============================================================================%%*/


	bys id_dom: gen id_pes = _n

		lab var id_pes "Individual id"




*----------2.1.1.1: Checking weights & interview type--------------------------*

cap gen count = 1

	tab count [iweight = v9991]

	* 0 instances where HH weight is missing
	count if v9991 == .

	egen tag = diff(v9981 v9991)
	tab tag, missing

*----------2.2.1.2: Checking person id-----------------------------------------*

	distinct id_dom id_pes, joint

	egen id_pnad = concat(id_dom id_pes)
	sort id_pnad
	quietly by id_pnad: gen dup = cond(_N == 1, 0, _n)
	count if dup > 1

	gen year = `year'




*<_countrycode_>
	gen countrycode = "BRA"
	label variable countrycode "Country code"
*</_countrycode_>

*<_survname_>
	gen survname  = "PNAD"
	label variable survname "Survey acronym"
*</_survname_>

*<_survey_>
	gen survey = "Other Household Survey" // https://microdatalib.worldbank.org/index.php/catalog/3342
	label variable survey "Survey type"
*</_survey_>

*<_icls_v_>
	gen icls_v = "ICLS-13"
	label variable icls_v "ICLS version underlying questionnaire questions"
*</_icls_v_>

*<_isced_version_>
	gen isced_version = "isced_2011"
	label variable isced_version "Version of ISCED used for educat_isced"
*</_isced_version_>

*<_isco_version_>
	gen isco_version = "isco_1988"
	label variable isco_version "Version of ISCO used"
*</_isco_version_>

*<_isic_version_>
	gen isic_version = "isic_3"
	label variable isic_version "Version of ISIC used"
*</_isic_version_>

*<_year_>
/* <_year_note>

	1980's: didn't exist
	1990's: had only 2-digits

	1980's: V0101 represents HH number
	1983 & 1990: doesn't exist

*/

*<_vermast_>
	gen vermast = "v01"
	label variable vermast "Version of master data"
*</_vermast_>

*<_veralt_>
	gen veralt = "v01"
	label variable veralt "version of the alt/harmonized data"
*</_veralt_>

*<_harmonization_>
	gen harmonization = "GLD"
	label variable harmonization "Type of harmonization"
*</_harmonization_>

*<_int_year_>
	gen int_year = year
	label variable int_year "Year of interview"
*</_int_year_>

*<_int_month_>
	gen int_month = 9
	label define int_month_lab 1 "January" 2 "February" 3 "March" 4 "April" 5 "May" 6 "June" 7 "July" 8 "August" 9 "September" 10 "October" 11 "November" 12 "December"
	label value int_month int_month_lab
	label variable int_month "Month of interview"

*</_int_month_>

*<_hhid_>
/* <_hhid_note>

	1980's: V0101 is hhid
	1983 & 1990: V0101 doesn't exist; V0102 & V0103 do
	1992-2012: V0102 has 6-digits rather than 8-digits (lacking UF digits at begining)

	If inexists: avoid creating a sequential index (hhid = _n)

</_hhid_note> */
	cap drop __000000 __000001 __000002 __000003 __000004
	rename id_dom hhid
	label variable hhid "Household ID"


*<_pid_>
/* <_pid_note>

	1980's: doesn't exist
	As of 1992: name change

</_pid_note> */

	tostring id_pes, replace
	cap drop __000000 __000001 __000002 __000003 __000004

	egen pid = concat(hhid id_pes)
	label variable pid "Individual ID" //check
*</_pid_>

*<_weight_>

sum v9991, de

	rename v9991 weight
	replace weight = . if weight == -1
	label variable weight "Household sampling weight"
*	drop v9991
*</_weight_>

*<_wave_>
/* <_wave_note>

	Exists in PNADc

</_wave_note> */
	gen wave = .
	label variable wave "Survey wave"
*</_wave_>




/*%%============================================================================
   3: Geography
============================================================================%%*/

*<_urban_>
	recode v0003 (5=0)
	rename v0003 urban
	label var urban "Location is urban"
	la de lblurban 1 "Urban" 0 "Rural"
	label values urban lblurban
*</_urban_>


*<_subnatid1_>
/* <_subnatid1_note>

	Until 1992: not standardised

	1st digit of "UF" variable

</_subnatid1_note> */


	destring uf, replace

	recode uf (11/14=33) (20/29=35) (30/31 37=41) (32=42) (33/35=43) ///
(41/42=31) (43=32) (51=21) (52=22) (53=23) (54=24) (55=25) ///
(56=26) (57=27) (58=28) (59/60=29) (61=53) (71=11) (72=12) ///
(73=13) (74=14) (75=15) (76=16) (81=50) (82=51) (83=52)


/* CENSUS AREA  */
rename v0005 census_area

	gen subnatid1 = .
	replace subnatid1 = 1 if substr(string(uf), 1, 1) == "1"
	replace subnatid1 = 2 if substr(string(uf), 1, 1) == "2"
	replace subnatid1 = 3 if substr(string(uf), 1, 1) == "3"
	replace subnatid1 = 4 if substr(string(uf), 1, 1) == "4"
	replace subnatid1 = 5 if substr(string(uf), 1, 1) == "5"
	recast byte subnatid1
	label variable subnatid1 "Subnational ID at First Administrative Level"
	label define subnatid1_lab 1 "1 - North" 2 "2 - Northeast" 3 "3 - Southeast" 4 "4 - South" 5 "5 - Central-West"
	label values subnatid1 subnatid1_lab
*</_subnatid1_>

*<_subnatid2_>
/* <_subnatid2_note>

	Until 1992: not standardised
	Until 1992: TO (17) part of GO (52), though created in 1988 (changes region/subnatid1)

	2nd digit of "UF" variable

</_subnatid2_note> */

	gen subnatid2 = uf
	recast byte subnatid2
	label variable subnatid2 "Subnational ID at Second Administrative Level"
	label define subnatid2_lab	11 "11 - Rondonia" 12 "12 - Acre" 13 "13 - Amazonas" 14 "14 - Roraima" 15 "15 - Pará" 16 "16 - Amapa" 17 "17 - Tocantins" 21 "21 - Maranhao" 22 "22 - Piaui" 23 "23 - Ceara" 24 "24 - Rio Grande do Norte" 25 "25 - Paraiba" 26 "26 - Pernambuco" 27 "27 - Alagoas" 28 "28 - Sergipe" 29 "29 - Bahia" 31 "31 - Minas Gerais" 32 "32 - Espirito Santo" 33 "33 - Rio de Janeiro" 35 "35 - Sao Paulo" 41 "41 - Parana" 42 "42 - Santa Catarina" 43 "43 - Rio Grande do Sul" 50 "50 - Mato Grosso do Sul" 51 "51 - Mato Grosso" 52 "52 - Goias" 53 "53 - Distrito Federal"
	label values subnatid2 subnatid2_lab
*</_subnatid2_>

*<_subnatid3_>
/* <_subnatid3_note>

	area_censit: Census area code
	1 = Metropolitan area
	2 = Autorepresentative
	3 = Not autorepresentative

</_subnatid3_note> */
	gen subnatid3 = .
	replace subnatid3 = 1 if uf == 15 & census_area == 1
	replace subnatid3 = 2 if uf == 23 & census_area == 1
	replace subnatid3 = 3 if uf == 26 & census_area == 1
	replace subnatid3 = 4 if uf == 29 & census_area == 1
	replace subnatid3 = 5 if uf == 31 & census_area == 1
	replace subnatid3 = 6 if uf == 33 & census_area == 1
	replace subnatid3 = 7 if uf == 35 & census_area == 1
	replace subnatid3 = 8 if uf == 41 & census_area == 1
	replace subnatid3 = 9 if uf == 43 & census_area == 1
	recast byte subnatid3
	label variable subnatid3 "Subnational ID at Third Administrative Level"
	label define subnatid3_lab 1 "1 - Belem" 2 "2 - Fortaleza" 3 "3 - Recife" 4 "4 - Salvador" 5 "5 - Belo Horizonte" 6 "6 - Rio de Janeiro" 7 "7 - Sao Paulo" 8 "8 - Curitiba" 9 "9 - Porto Alegre"
	label values subnatid3 subnatid3_lab
	drop uf census_area
*</_subnatid3_>

*<_subnatidsurvey_>
	gen subnatidsurvey = "subnatid3"
	tostring subnatidsurvey, replace
	replace subnatidsurvey = "subnatid2" if subnatid3 == .
	label variable subnatidsurvey "Administrative level at which survey is representative"
*</_subnatidsurvey_>

*<_subnatid1_prev_>
	gen subnatid1_prev = .
	label variable subnatid1_prev "Classification used for subnatid1 from previous survey"
*</_subnatid2_prev_>

*<_subnatid2_prev_>
	gen subnatid2_prev = .
	label variable subnatid2_prev "Classification used for subnatid2 from previous survey"
*</_subnatid2_prev_>

*<_subnatid3_prev_>
	gen subnatid3_prev = .
	label variable subnatid3_prev "Classification used for subnatid3 from previous survey"
*</_subnatid3_prev_>

*<_gen gaul_adm1_code_>
/* <_gaul_adm1_code_note>

	Brazil 37

</_gaul_adm1_code_note> */
	gen gaul_adm1_code = .
	label variable gaul_adm1_code "Global Administrative Unit Layers (GAUL) Admin 1 code"
*</_gen gaul_adm1_code_>

*<_gen gaul_adm2_code_>
	gen gaul_adm2_code = subnatid2
	recode gaul_adm2_code (11 = 686) (12 = 665) (13 = 668) (14 = 687) (15 = 678) (16 = 667) (17 = 691) (21 = 674) (22 = 682) (23 = 670) (24 = 684) (25 = 679) (26 = 681) (27 = 666) (28 = 690) (29 = 669) (31 = 677) (32 = 672) (33 = 683) (35 = 689) (41 = 680) (42 = 688) (43 = 685) (50 = 676) (51 = 675) (52 = 673) (53 = 671)
	label variable gaul_adm2_code "Global Administrative Unit Layers (GAUL) Admin 2 code"
	label define gaul_adm2_code_lab	686 "686 - Rondonia" 665 "665 - Acre" 668 "668 - Amazonas" 687 "687 - Roraima" 678 "678 - Pará" 667 "667 - Amapa" 691 "691 - Tocantins" 674 "674 - Maranhao"682 "682 - Piaui" 670 "670 - Ceara" 684 "684 - Rio Grande do Norte" 679 "679 - Paraiba" 681 "681 - Pernambuco" 666 "666 - Alagoas" 690 "690 - Sergipe" 669 "669 - Bahia" 677 "677 - Minas Gerais" 672 "672 - Espirito Santo" 683 "683 - Rio de Janeiro" 689 "689 - Sao Paulo" 680 "680 - Parana" 688 "688 - Santa Catarina" 685 "685 - Rio Grande do Sul" 676 "676 - Mato Grosso do Sul" 675 "675 - Mato Grosso" 673 "673 - Goias" 671 "671 - Distrito Federal"
	label values gaul_adm2_code gaul_adm2_code_lab
*</_gen gaul_adm2_code_>

*<_gen gaul_adm3_code_>
	gen gaul_adm3_code = .
	label variable gaul_adm3_code "Global Administrative Unit Layers (GAUL) Admin 3 code"
*</_gen gaul_adm3_code_>




/*%%============================================================================
   4: Demography
============================================================================%%*/



*<_hsize_>
/* <_hsize_note>

	1992-1981: contains "-1", which should be changed to missing (.)

</_hsize_note> */

	rename v0107 hsize
	label variable hsize "Household size"

    replace hsize = . if hsize == -1
*</_hsize_>

*<_age_>
/* <_age_note>

	Check: <=5 years, age registered with decimals

	1980's: simetimes age and YoB are switched
	Contains 999", which should be changed to missing (.)

	Until 2000: YoB registered with only 3-digits
	DoB = "00", MoB = "20" | "30" and YoB = "0"-"98" mean "deduced/estimated"

</_age_note> */
	rename v0805 age
	sum age, de
	replace age = . if age == 999
	label variable age "Individual age"
*</_age_>

*<_male_>
	rename v0303 male
	recode male (1 = 1) (3 = 0)
	label variable male "Sex - Ind is male"
	label define male_lab 0 "Female" 1 "Male"
	label values male male_lab
*</_male_>


gen relationcs = .
gen relationharm = .
gen marital = .

*<_eye_dsablty_>
	gen eye_dsablty = .
	recast byte eye_dsablty
	label variable eye_dsablty "Difficulty related to eyesight"
	label define eye_dsablty_lab 1 "Cannot do at all" 9 "No Information"
	label values eye_dsablty eye_dsablty_lab
cap	drop v6501
*</_eye_dsablty_>

*<_hear_dsablty_>
	gen hear_dsablty = .
	recast byte hear_dsablty
	label variable hear_dsablty "Difficulty related to hearing"
	label define hear_dsablty_lab  1 "Cannot do at all"  9 "No Information"
	label values hear_dsablty hear_dsablty_lab
cap	drop v6511
*</_hear_dsablty_>

*<_walk_dsablty_>
	gen walk_dsablty = .
*	recode walk_dsablty (6 = 4) (. = 1)
	recast byte walk_dsablty
*	replace walk_dsablty = 3 if v6561 == 7
	label variable walk_dsablty "Difficulty related to climbing stairs"
	label define walk_dsablty_lab 1 "No - no difficulty" 2 "Yes - some difficulty" 3 "Yes - a lot of difficulty" 4 "Cannot do at all"
	label values walk_dsablty walk_dsablty_lab
cap	drop v6551
*</_walk_dsablty_>

*<_conc_dsord_>
	gen conc_dsord = .
	recast byte conc_dsord
	label variable conc_dsord "Difficulty related to concentration or remembering"
	label define conc_dsord_lab 1 "No - no difficulty" 2 "Yes - some difficulty" 3 "Yes - a lot of difficulty" 4 "Cannot do at all"
	label values conc_dsord conc_dsord_lab
*</_conc_dsord_>

*<_slfcre_dsablty_>
	gen slfcre_dsablty = .
	recast byte slfcre_dsablty
	label variable slfcre_dsablty "Difficulty related to selfcare"
	label define slfcre_dsablty_lab 1 "No - no difficulty" 2 "Yes - some difficulty" 3 "Yes - a lot of difficulty" 4 "Cannot do at all" 5 "Cannot at all"
	label values slfcre_dsablty slfcre_dsablty_lab
*</_slfcre_dsablty_>

*<_comm_dsablty_>
	gen comm_dsablty = .
	recast byte comm_dsablty
	label variable comm_dsablty "Difficulty related to communicating"
	label define comm_dsablty_lab 1 "No - no difficulty" 2 "Yes - some difficulty" 3 "Yes - a lot of difficulty" 4 "Cannot do at all" 5 "Cannot at all"
	label values comm_dsablty comm_dsablty_lab
*</_comm_dsablty_>




/*%%============================================================================
   5: Migration
============================================================================%%*/




/* <__note>

	1992: Introduced

</__note> */


*<_migrated_mod_age_>
/* <_migrated_mod_age_note>

	Exists in PNADc

</_migrated_mod_age_note> */
	gen migrated_mod_age = .
	label variable migrated_mod_age "Migration module application age"
*</_migrated_mod_age_>

*<_migrated_ref_time_>
/* <_migrated_ref_time_note>

	Time-reference: [1-9] years and "10 or more"

</_migrated_ref_time_note> */
	gen migrated_ref_time = .
	label variable migrated_ref_time "Reference time applied to migration questions (in years)"
*</_migrated_ref_time_>

*<_migrated_binary_>

	gen migrated_binary = .
	recast byte migrated_binary
	label variable migrated_binary "Individual has migrated"
	label define migrated_binary_lab 0 "No" 1 "Yes"
	label values migrated_binary migrated_binary_lab
*</_migrated_binary_>

*<_migrated_years_>
/* <_migrated_years_note>

	0 = Less than a year ago; 1-9, years ago; 10 = 10 or more years ago (Mario)
	For those people who migrated at different times from different administrative regions, we consider the most recent one!

</_migrated_years_note> */

	gen migrated_years = .
	label variable migrated_years "Years since latest migration"
*</_migrated_years_>

*<_migrated_from_urban_>
	gen migrated_from_urban = .
	recast byte migrated_from_urban
	label variable migrated_from_urban "Migrated from area"
	label define migrated_from_urban_lab 0 "Rural" 1 "Urban"
	label values migrated_from_urban migrated_from_urban_lab
*</_migrated_from_>

*<_migrated_from_cat_>
/* <_migrated_from_cat_note>

	admin1 = Region
	admin2 = State
	admin3 = Municipality !!!

</_migrated_from_cat_note> */
	gen migrated_from_cat = .

	recast byte migrated_from_cat
	label variable migrated_from_cat "Category of migration area"
	label define migrated_from_cat_lab 1 "From same admin3 area" 2 "From same admin2 area" 3 "From same admin1 area" 4 "From other admin1 area" 5 "From other country"
	label values migrated_from_cat migrated_from_cat_lab

*</_migrated_from_cat_>

*<_migrated_from_code_>
/* <_migrated_from_code_note>

	subnatid1 = Region
	subnatid2 = State
	subnatid3 = Municipality

</_migrated_from_code_note> */
	gen migrated_from_code = .
	recast byte migrated_from_code
	label variable migrated_from_code "Code of migration area as subnatid level of migrated_from-cat"
	label define migrated_from_code_lab 1 "1 - North" 2 "2 - Northeast" 3 "3 - Southeast" 4 "4 - South" 5 "5 - Central-West"	11 "11 - Rondonia" 12 "12 - Acre" 13 "13 - Amazonas" 14 "14 - Roraima" 15 "15 - Pará" 16 "16 - Amapa" 17 "17 - Tocantins" 21 "21 - Maranhao" 22 "22 - Piaui" 23 "23 - Ceara" 24 "24 - Rio Grande do Norte" 25 "25 - Paraiba" 26 "26 - Pernambuco" 27 "27 - Alagoas" 28 "28 - Sergipe" 29 "29 - Bahia" 31 "31 - Minas Gerais" 32 "32 - Espirito Santo" 33 "33 - Rio de Janeiro" 35 "35 - Sao Paulo" 41 "41 - Parana" 42 "42 - Santa Catarina" 43 "43 - Rio Grande do Sul" 50 "50 - Mato Grosso do Sul" 51 "51 - Mato Grosso" 52 "52 - Goias" 53 "53 - Distrito Federal"
	label values migrated_from_code migrated_from_code_lab

*</_migrated_from_code_>

*<_migrated_from_country_>
	gen migrated_from_country = ""
	label variable migrated_from_country "Code of migration country (ISO 3 Letter Code)"
*</_migrated_from_country_>

*<_migrated_reason_>
	gen migrated_reason = .
	recast byte migrated_reason
	label variable migrated_reason "Reason for migrating"
	label define migrated_reason_lab 1 "Family reasons" 2 "Educational reasons" 3 "Employment" 4 "Forced (political reasons, natural disaster, ...)" 5 "Other reason"
	label values migrated_reason migrated_reason_lab
*</_migrated_reason_>


/*%%============================================================================
   6: Education
============================================================================%%*/




*<_ed_mod_age_>
/* <_ed_mod_age_note>

	Exists in PNADc
	Until 1994: only asked to people 5 years or older
	As of 1995: asked to all ages

	Comparability throughout the years is compromised:
	1992: skip pattern introduced

</_ed_mod_age_note> */
	gen ed_mod_age = 0
	label variable ed_mod_age "Education module application age"
*</_ed_mod_age_>

*<_school_>
/* <_school_note>

	Comparability throughout the years is compromised:
	1980's: "Pre-school" not considered
	1990's: "Pre-school" considered, but not separate from "School"
	As of 1981: "Pre-school" and "School" are considered separately

</_school_note> */
	gen school = (v0314 !=0) if v0314 !=.
	label variable school "Attending school"
	label define school_lab 0 "No" 1 "Yes"
	label values school school_lab
*</_school_>

*<_literacy_>
	recode v0311 (3 = 0) (1 = 1) (9 = .)
	rename v0311 literacy
	label variable literacy "Individual can read & write"
	label define literacy_lab 0 "No" 1 "Yes"
	label values literacy literacy_lab
*</_literacy_>

*<_educy_>
/* <_educy_note>

	PNAD: 1 = no or < 1y instruction
	2-15 = 1-14y, 16 = 15+y; 17 = undetermined
	[1 ignored and "1" subtracted]

	Unti 1992: one set of values for each of 0-8, 9-11 and 12+
	As of 1992: 0-16

</_educy_note> */
	gen educy = v0318 - 1 if v0318 >= 1 & v0318 < 9

	replace educy =1 if   v0314==1 & v0312==2
replace educy =2 if   v0314==1 & v0312==3
replace educy =3 if   v0314==1 & v0312==4

replace educy =4 if   v0314==2 & v0312==1
replace educy =5 if   v0314==2 & v0312==2
replace educy =6 if   v0314==2 & v0312==3
replace educy =7 if   v0314==2 & v0312==4

replace educy =8 if   v0314==3 &  v0312==1
replace educy =9 if   v0314==3 &  v0312==2
replace educy =10 if   v0314==3 &  v0312==3

replace educy =0 if   v0314==4 & v0312==1
replace educy =1 if   v0314==4 & v0312==2
replace educy =2 if   v0314==4 & v0312==3
replace educy =3 if   v0314==4 & v0312==4
replace educy =4 if   v0314==4 & v0312==5
replace educy =5 if   v0314==4 & v0312==6
replace educy =6 if   v0314==4 & v0312==7
replace educy =7 if   v0314==4 & v0312==8

replace educy =8 if   v0314==5 &  v0312==1
replace educy =9 if   v0314==5 &  v0312==2
replace educy =10 if   v0314==5 &  v0312==3
replace educy =11 if   v0314==5 &  v0312==4

replace educy =11 if   v0314==6 & v0312==1
replace educy =12 if   v0314==6 & v0312==2
replace educy =13 if   v0314==6 & v0312==3
replace educy =14 if   v0314==6 & v0312==4
replace educy =15 if   v0314==6 & v0312==5
replace educy =16 if   v0314==6 & v0312==6

replace educy =0 if   v0314==7

replace educy =0 if   v0314==8

replace educy =0 if   v0314==9 &  v0312==1
replace educy =1 if   v0314==9 &  v0312==2
replace educy =2 if   v0314==9 &  v0312==3
replace educy =3 if   v0314==9 &  v0312==4
replace educy =4 if   v0314==9 &  v0312==5
replace educy =5 if   v0314==9 &  v0312==6
replace educy =6 if   v0314==9 &  v0312==7
replace educy =7 if   v0314==9 &  v0312==8

replace educy =8 if   v0314==10 &  v0312==1
replace educy =9 if   v0314==10 &  v0312==2
replace educy =10 if   v0314==10 &  v0312==3

replace educy =0 if   v0314==11 &  v0312==1
replace educy =1 if   v0314==11 &  v0312==2
replace educy =2 if   v0314==11 &  v0312==3
replace educy =3 if   v0314==11 &  v0312==4
replace educy =4 if   v0314==11 &  v0312==5
replace educy =5 if   v0314==11 &  v0312==6
replace educy =6 if   v0314==11 &  v0312==7
replace educy =7 if   v0314==11 &  v0312==8

replace educy =8 if   v0314==12 &  v0312==1
replace educy =9 if   v0314==12 &  v0312==2
replace educy =10 if   v0314==12 &  v0312==3

replace educy =11 if   v0314==14

replace educy =15 if   v0314==15

/* pessoas que não freqüentam */
replace educy =1 if   v0317==1 & v0315==1
replace educy =2 if   v0317==1 & v0315==2
replace educy =3 if   v0317==1 & v0315==3
replace educy =4 if   v0317==1 & v0315==4
replace educy =4 if   v0317==1 & v0315==5

replace educy =5 if   v0317==2 & v0315==1
replace educy =6 if   v0317==2 & v0315==2
replace educy =7 if   v0317==2 & v0315==3
replace educy =8 if   v0317==2 & v0315==4
replace educy =8 if   v0317==2 & v0315==5

replace educy =9 if   v0317==3 & v0315==1
replace educy =10 if   v0317==3 & v0315==2
replace educy =11 if   v0317==3 & v0315==3
replace educy =11 if   v0317==3 & v0315==4

replace educy =1 if   v0317==4 & v0315==1
replace educy =2 if   v0317==4 & v0315==2
replace educy =3 if   v0317==4 & v0315==3
replace educy =4 if   v0317==4 & v0315==4
replace educy =5 if   v0317==4 & v0315==5
replace educy =6 if   v0317==4 & v0315==6
replace educy =7 if   v0317==4 & v0315==7
replace educy =8 if   v0317==4 & v0315==8

replace educy =9 if   v0317==5 & v0315==1
replace educy =10 if   v0317==5 & v0315==2
replace educy =11 if   v0317==5 & v0315==3
replace educy =11 if   v0317==5 & v0315==4

replace educy =12 if   v0317==6 & v0315==1
replace educy =13 if   v0317==6 & v0315==2
replace educy =14 if   v0317==6 & v0315==3
replace educy =15 if   v0317==6 & v0315==4
replace educy =16 if   v0317==6 & v0315==5
replace educy =17 if   v0317==6 & v0315==6

replace educy =17 if   v0317==7 & v0315==2
replace educy =18 if   v0317==7 & v0315==3
replace educy =19 if  v0317==7 & v0315>=4
replace educy =0 if   v0312==0 & v0314==0 & v0315==0 & v0317==0


	recast float educy
	label variable educy "Years of education"
	drop v0312 v0315 v0317 v0318
*</_educy_>

*<_educat7_>
/* <_educat7_note>

	GLD's category 6 "Higer than secondary but not university" has no equivalent

	1980's: "Pre-school" not considered
	1990's: "Pre-school" considered, but not separate from "School"
	As of 1981: "Pre-school" and "School" are considered separately

	As of 1981: "Classe de alfabetização" category is added
	1981 & 1992: "Alfabetização de adultos" exists

</_educat7_note> */
	gen educat7 = .

	replace educat7 = 1 if educy == 0
	replace educat7 = 2 if (educy >= 1 & educy <= 7) | (v0314 == 1 | v0314 == 2 | v0314 == 4 | v0314 == 7 | v0314 == 8 | v0314 == 9 | v0314 == 11)
	replace educat7 = 3 if educy == 8
	replace educat7 = 4 if (educy >= 9 & educy <= 10) | (v0314 == 14 | v0314 == 12 | v0314 == 10 | v0314 == 5 | v0314 == 3)
	replace educat7 = 5 if educy == 11
	replace educat7 = 7 if (educy >= 12 & educy <= 15) | (v0314 == 13 | v0314 == 6)

	recast byte educat7
	label variable educat7 "Level of education 1"
	label define educat7_lab 1 "No education" 2 "Primary incomplete" 3 "Primary complete" 4 "Secondary incomplete" 5 "Secondary complete" 6 "Higher than secondary but not university" 7"University incomplete or complete"
	label values educat7 educat7_lab
*</_educat7_>

*<_educat5_>
/* <_educat5_note>

	1980's: "Pre-school" not considered
	1990's: "Pre-school" considered, but not separate from "School"
	As of 1981: "Pre-school" and "School" are considered separately

	As of 1981: "Classe de alfabetização" category is added
	1981 & 1992: "Alfabetização de adultos" exists

</_educat5_note> */
	gen educat5 = educat7
	recode educat5 (1 = 1) (2 = 2) (3/4 = 3) (5 = 4) (6/7 = 5) (8 = .)
	recast byte educat5
	label variable educat5 "Level of education 2"
	label define educat5_lab 1 "No education" 2 "Primary incomplete" 3 "Primary complete but secondary incomplete" 4 "secondary complete" 5 "Some tertiary/post-secondary"
	label values educat5 educat5_lab
*</_edycat5_>

*<_educat4_>
/* <_educat4_note>

	1980's: "Pre-school" not considered
	1990's: "Pre-school" considered, but not separate from "School"
	As of 1981: "Pre-school" and "School" are considered separately

	As of 1981: "Classe de alfabetização" category is added
	1981 & 1992: "Alfabetização de adultos" exists

</_educat4_note> */
	gen educat4 = educat7
	recode educat4 (1 = 1) (2/4 = 2) (5 = 3) (6/7 = 4) (8 = .)
	recast byte educat4
	label variable educat4 "Level of education 3"
	label define educat4_lab 1 "No education" 2 "Primary" 3 "Secondary" 4 "Post-secondary"
	label values educat4 educat4_lab
*</_educat4_>

*<_educat_isced_>
	gen educat_isced = educat7
	recode educat_isced (1 8 = .) (2 = 102) (3 = 104) (4 = 302) (5 = 304) (6 = 602) (7 = 604)
	recast float educat_isced
	label variable educat_isced "ISCED 1981 standardised level of education"
	label define educat_isced_lab 102 "Primary education, not further defined, recognised successful completion of programme is sufficient for partial completion of ISCED level but without direct access to programmes at higher ISCED levels" 104 "Primary education, not further defined, recognised successful completion of programme is sufficient for completion of ISCED level and with direct access to programmes at higher ISCED levels" 302 "Upper secondary education, not further defined, recognised successful completion of programme is sufficient for partial completion of ISCED level but without direct access to programmes at higher ISCED levels" 304 "Upper secondary education, not further defined, recognised successful completion of programme is sufficient for completion of ISCED level and with direct access to programmes at higher ISCED levels" 602 "Bachelor's or equivalent level, not further defined, recognised successful completion of programme is sufficient for partial completion of ISCED level but without direct access to programmes at higher ISCED levels" 604 "Bachelor's or equivalent level, not further defined, recognised successful completion of programme is sufficient for completion of ISCED level and with direct access to programmes at higher ISCED levels"
	label values educat_isced educat_isced_lab
*</_educat_isced_>

*<_educat_orig_>
/* <_educat_orig_note>

	1980's: "Pre-school" not considered
	1990's: "Pre-school" considered, but not separate from "School"
	As of 1981: "Pre-school" and "School" are considered separately

	1981: "Classe de alfabetização" category is added
	1981 & 1992: "Alfabetização de adultos" exists

	1980's: old nomenclature ("primeiro grau", instead of "ensino fundamental")

</_educat_orig_note> */
	gen educat_orig = .
*	rename V4745 educat_orig
*	recode educat_orig (8 = .)
*	recast byte educat_orig
*	label variable educat_orig "Original survey education code"
*	label define educat_orig_lab 1 "Sem instrução" 2 "Fundamental incompleto ou equivalente" 3 "Fundamental completo ou equivalente" 4 "Médio incompleto ou equivalente" 5 "Médio completo ou equivalente" 6 "Superior incompleto ou equivalente"	7 "Superior completo"
*	label values educat_orig educat_orig_lab
*</_educat_orig_>




/*%%============================================================================
   7: Training
============================================================================%%*/




*<_vocational_>
	gen vocational = .
	recast byte vocational
	label variable vocational "Ever received vocational training"
	label define vocational_lab 0 "No" 1 "Yes"
	label values vocational vocational_lab
*</_vocational_>

*<_vocational_type_>
	gen vocational_type = .
	recast byte vocational_type
	label variable vocational_type "Type of vocational training"
	label define vocational_type_lab 1 "Inside Enterprise" 2 "External"
	label values vocational_type vocational_type_lab
*</_vocational_type_>

*<_vocational_length_l_>
	gen vocational_length_l = .
	recast float vocational_length_l
	label variable vocational_length_l "Length of training in months, lower limit"
*</_vocational_length_l_>

*<_vocational_length_u_>
	gen vocational_length_u = .
	recast float vocational_length_u
	label variable vocational_length_u "Length of training in months, upper limit"
*</_vocational_length_u_>

*<_vocational_field_>
	gen vocational_field = .
	label variable vocational_field "Field of training"
*</_vocational_field_>

*<_vocational_financed_>
	gen vocational_financed = .
	recast byte vocational_financed
	label variable vocational_financed "How training was financed"
	label define vocational_financed_lab 1 "Employer" 2 "Government" 3 "Mixed Emploer/Government" 4 "Own funds" 5 "Other"
	label values vocational_financed vocational_financed_lab
*</_vocational_financed_>




/*%%============================================================================
   8: Labour
============================================================================%%*/



/* <__note>

	Correcting Missings

</__note> */
/* INCOME */

/* RECODE: MONTHLY INCOME IN CASH */
recode v0537 (9999999=.) if year >= 1981 & year <= 1984
recode v0537 (999999999=.) if year >= 1985 & year <= 1990

/* RECODE: MONTHLY INCOME IN PRODUCTS/GOODS */
recode v0538 (9999999=.) if year >= 1981 & year <= 1984
recode v0538 (999999999=.) if year >= 1985 & year <= 1990

/* RECODE: MONTHLY INCOME IN CASH OTHER */
recode v0549 (9999999=.) if year >= 1981 & year <= 1984
recode v0549 (999999999=.) if year >= 1985 & year <= 1990

/* RECODE: MONTHLY INCOME IN PRODUCTS/GOODS OTHER */
recode v0550 (9999999=.) if year >= 1981 & year <= 1984
recode v0550 (999999999=.) if year >= 1985 & year <= 1990

/* RECODE: RETIREMENT PENSIONS */
recode v0578 (9999999=.) if year >= 1981 & year <= 1984
recode v0578 (999999999=.) if year >= 1985 & year <= 1990

/* RECODE: OTHER PENSIONS */
recode v0579 (9999999=.) if year >= 1981 & year <= 1984
recode v0579 (999999999=.) if year >= 1985 & year <= 1990

/* RECODE: PERMANENT ALLOWANCE */
recode v0580 (9999999=.) if year >= 1981 & year <= 1984
recode v0580 (999999999=.) if year >= 1985 & year <= 1990

/* RECODE: RENTAL AMOUNT RECEIVED */
recode v0581 (9999999=.) if year >= 1981 & year <= 1984
recode v0581 (999999999=.) if year >= 1985 & year <= 1990

/* RECODE: OTHERS */
recode v0582 (9999999=.) if year >= 1981 & year <= 1984
recode v0582 (999999999=.) if year >= 1985 & year <= 1990

/* RECODE: MONTHLY INCOME MAIN OCCUPATION */
recode v0600 (9999999=.) if year >= 1981 & year <= 1984
recode v0600 (999999999=.) if year >= 1985 & year <= 1990

/* RECODE: MONTHLY INCOME ALL JOBS */
recode v0601 (9999999=.) if year >= 1981 & year <= 1984
recode v0601 (999999999=.) if year >= 1985 & year <= 1990

/* RECODE: MONTHLY INCOME ALL SOURCES */
recode v0602 (9999999=.) if year >= 1981 & year <= 1984
recode v0602 (999999999=.) if year >= 1985 & year <= 1990

replace v5010 =. if v5010>=9999999

/* CONVERTING NOMINAL VALUES TO REAIS (MONETARY UNIT) */
/* AND DEFLATIONING (OCT/2012) */
gen double deflator = 0.807544/100000 if year == 1990
format deflator %26.25f
replace deflator = 0.269888/1000000 if year == 1989
replace deflator = 0.196307/10000000 if year == 1988
replace deflator = 0.241162/100000000 if year == 1987
replace deflator = 0.602708/1000000000 if year == 1986
replace deflator = 0.304402/1000000000 if year == 1985
replace deflator = 0.962506/10000000000 if year == 1984
replace deflator = 0.330205/10000000000 if year == 1983
replace deflator = 0.133929/10000000000 if year == 1982
replace deflator = 0.636330/100000000000 if year == 1981

label var deflator "deflator - price level: Oct/2012"

gen double converter = 2750000 if year >= 1989
replace converter = 2750000000 if year >= 1986 & year <= 1988
replace converter = 2750000000000 if year <= 1985

label var converter "currency converter"

/* <__note>

	1992: A broader definition of "work" was adopted, that includes
	"production for own consumption" and "construction for own use"

	1992: skip pattern introduced

</__note> */


*<_minlaborage_>
/* <_minlaborage_note>

	1981: 10 <- It is not 5
	PNADc: 14

</_minlaborage_note> */
	gen minlaborage = 10
	label variable minlaborage "Labor module application age"
*</_minlaborage_>

*----------8.1: 7 day reference overall----------------------------------------*

*<_lstatus_>
/* <_lstatus_note>

	Comparability throughout the years is compromised:
	"Trabalhou" (V9001) is compatible throughout, but "estava afastado" is not,
	due to skip pattern introduction and order change (V9004 in 1990's and V9002 in 2000's);
	With both, we get "tinha trabalho", which indicates employment/unemployment

	Until 2006: V4764 was V4755
	Until 2006 (except 1996 & 1997): "employed" could be answered by people 5 years or older

	1981: V4754 is V4754

</_lstatus_note> */
	gen lstatus = .
	replace lstatus = 1 if (v0501 == 1 | v0501 == 2) & age >= minlaborage
	replace lstatus = 2 if (v0501 == 3 | v0513 == 1) & age >= minlaborage
	replace lstatus = 3 if (v0501 == 4 | v0501 == 5 | v0501 == 6 | v0501 == 7) & v0513 == 3 & age >= minlaborage
	recast byte lstatus
	label variable lstatus "Labor status"
	label define lstatus_lab 1 "Employed" 2 "Unemployed" 3 "Non-LF"
	label values lstatus lstatus_lab
	drop v0513
*</_lstatus_>

*<_potential_lf_>
	gen potential_lf = .
	recast byte potential_lf
	label variable potential_lf "Potential labour force status"
	label define potential_lf_lab 0 "No" 1 "Yes"
	label values potential_lf potential_lf_lab
*</_potential_lf_>

*<_underemployment_>
	gen underemployment = .
	recast byte underemployment
	label variable underemployment "Underemployment status"
	label define underemployment_lab 0 "No" 1 "Yes"
	label values underemployment underemployment_lab
*</_underemployment_>

*<_nlfreason_>
	gen nlfreason = v0501 - 3 if v0501 >= 4 & v0501 <= 7
	recode nlfreason (4 = 5)
	recast byte nlfreason
	label variable nlfreason "Reason not in the labor force"
	label define nlfreason_lab 1 "Student" 2 "Housekeeper" 3 "Retired" 4 "Disabled" 5 "Other"
	label values nlfreason nlfreason_lab
	drop v0501
*</_nlfreason_>

*<_unempldur_l_>
	gen unempldur_l = v0516 if v0516 >= 0 & v0516 <= 24
	label variable unempldur_l "Unemployment duration (months) lower bracket"
*</_unempldur_l_>

*<_unempldur_u_>
	gen unempldur_u = unempldur_l // Check; A: Don't worry about that
	label variable unempldur_u "Unemployment duration (months) upper bracket"
*</_unempldur_u_>



*----------8.2: 7 day reference main job---------------------------------------*



*<_empstat_>
/* <_empstat_note>

	For all individuals

	Comparability throughout the years is compromised:
	Until 1992: "funcionários públicos estatutários" (public servants) and "militares" (army) could not be identified
	Until 1992: "trabalhadores domésticos" (domestic workers) inexisted
	Until 1992: "empregados" (workers) contained both "com carteira" and "sem carteira" (formal and informal)
	As of 1992: "production for own consumption" and "construction for own use" exist
	As of 1981: "empregado sem declaração de carteira" (probably) became "empregados sem carteira"
	As of 1981: "trabalhador doméstico sem declaração de carteira" (probably) became "trabalhadores domésticos sem carteira"

	1981: V4756 is V4756

</_empstat_note> */
	rename v5050 empstat
	recode empstat (1 = 1) (2 = 4) (3 = 3) (4 = 2) (5 = 5)
	replace empstat = . if lstatus != 1
	recast byte empstat
	label variable empstat "Employment status during past week primary 7 day recall"
	label define empstat_lab 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed" 5 "Other, workers not classified by status"
	label values empstat empstat_lab
*</_empstat_>

*<_industry_orig_>
/* <_industry_orig_note>

	CNAE-Domiciliar
	*Classificação Nacional de Atividades Econômicas (CNAE)

	Until 2006: V9907? was ?
	Until 2006 (except 1996 & 1997): "employed" could be answered by people 5 years or older?

	Comparability throughout the years is compromised:
	Until 2000: one set of codes (all throughout)
	2002: Adopted standardised set of codes (CNAE)

</_industry_orig_note> */
	gen str5 industry_orig = string(v0504, "%05.0f")
	replace industry_orig = "" if lstatus != 1 | age < minlaborage | industry_orig == "."
	label variable industry_orig "Original survey industry code, main job 7 day recall"
*</_industry_orig_>

*<_industrycat_isic_>
/* <_industrycat_isic_note>

	ISIC Rev. 3

</_industrycat_isic_note> */

	tostring v0504, replace

	forv i = 1(1)99 {

		if `i' >= 1 & `i' <= 9 {
		replace v0504 = "00`i'" if v0504 == "`i'"
		}
		else if `i' >= 10 & `i' <= 99 {
		replace v0504 = "0`i'" if v0504 == "`i'"
		}


	}

	merge m:1 v0504 using "`path_input'\Ind_Corresp_198090s.dta"
	drop if _merge == 2
	gen industrycat_isic = floor(v9997/10) *100
	tostring industrycat_isic, replace
	replace industrycat_isic = "0100" if industrycat_isic == "100"
	replace industrycat_isic = "0200" if industrycat_isic == "200"
	replace industrycat_isic = "0300" if industrycat_isic == "300"
	replace industrycat_isic = "0400" if industrycat_isic == "400"
	replace industrycat_isic = "0500" if industrycat_isic == "500"
	replace industrycat_isic = "5100" if v0504 == "410"
	replace industrycat_isic = "5000" if v0504 == "419"
	replace industrycat_isic = "5200" if industrycat_isic == "5300"
	replace industrycat_isic = "" if industrycat_isic == "."
	replace industrycat_isic = "" if industrycat_isic == "00"
	label variable industrycat_isic "ISIC code of primary job 7 day recall)"
	drop _merge v0504
	replace industrycat_isic = "" if industrycat_isic == ""
*</_industrycat_isic_>

*<_industrycat10_>
	gen industrycat10 = substr(industrycat_isic, 1, 2)
	destring industrycat10, replace
	replace industrycat10 = 1 if industrycat10 < 10
	replace industrycat10 = 2 if (industrycat10 >= 10 & industrycat10 < 15)
	replace industrycat10 = 3 if (industrycat10 >= 15 & industrycat10 < 37)
	replace industrycat10 = 4 if (industrycat10 >= 37 & industrycat10 < 45)
	replace industrycat10 = 5 if (industrycat10 >= 45 & industrycat10 < 50)
	replace industrycat10 = 6 if (industrycat10 >= 50 & industrycat10 < 60)
	replace industrycat10 = 7 if (industrycat10 >= 60 & industrycat10 < 65)
	replace industrycat10 = 8 if (industrycat10 >= 65 & industrycat10 < 75)
	replace industrycat10 = 9 if (industrycat10 >= 75 & industrycat10 < 80)
	replace industrycat10 = 10 if (industrycat10 >= 80 & industrycat10 < 100)
	recast byte industrycat10
	label variable industrycat10 "1 digit industry classification, primary job 7 day recall"
	label define industrycat10_lab 1 "Agriculture" 2 "Mining" 3 "Manufacturing" 4 "Public utility" 5 "Construction" 6 "Commerce" 7 "Transport and Communications" 8 "Financial and Business Services" 9 "Public Administration" 10 "Other Services, Unspecified"
	label values industrycat10 industrycat10_lab
*</_industrycat10_>

*<_industrycat4_>
	gen industrycat4 = .
	replace industrycat4 = 1 if industrycat10 == 1
	replace industrycat4 = 2 if (industrycat10 == 2 | industrycat10 == 3 | industrycat10 == 4 | industrycat10 == 5)
	replace industrycat4 = 3 if (industrycat10 == 6 | industrycat10 == 7 | industrycat10 == 8 | industrycat10 == 9)
	replace industrycat4 = 4 if industrycat10 == 10
	label variable industrycat4 "Broad Economic Activities classification, primary job 7 day recall"
	label define industrycat4_lab 1 "Agriculture" 2 "Industry" 3 "Services" 4 "Other"
	label values industrycat4 industrycat4_lab
*</_industrycat4_>

*<_occup_orig_>
/* <_occup_orig_note>

	CBO-Domiciliar
	*Classificação Brasileira de Ocupação (CBO)

	Comparability throughout the years is compromised:
	Until 2000: one set of codes (all throughout)
	2002: Adopted standardised set of codes (CBO)

	1981: V4756 is V4756

</_occup_orig_note> */
	gen str4 occup_orig = string(v0503, "%04.0f")
	replace occup_orig = "" if lstatus != 1 | age < minlaborage
	label variable occup_orig "Original occupation record primary job 7 day recall"
*</_occup_orig_>

*<_occup_isco_>
/* <_occup_isco_note>

	ISCO-88

</_occup_isco_note> */
tostring v0503, replace

	forv i = 1(1)99 {

		if `i' >= 1 & `i' <= 9 {
		replace v0503 = "00`i'" if v0503 == "`i'"
		}
		else if `i' >= 10 & `i' <= 99 {
		replace v0503 = "0`i'" if v0503 == "`i'"
		}


	}

merge m:1 v0503 using "`path_input'\isco_88_cbo_80_DD.dta"
drop if _merge == 2
gen occup_isco = isco_88+"00"
replace occup_isco = "0100" if occup_isco == "100"
label variable occup_isco "ISCO code of primary job 7 day recall"
drop _merge
replace occup_isco = "" if occup_isco == "."
replace occup_isco = "" if occup_isco == "00"
*</_occup_isco_>

*<_occup_skill_>
/* <_occup_skill_note>

	ISCO
	1 = elementary occupations
	2 = clerks; service workers and ship and market sales workers; skilled agriculture and fischery workers; craft and related trades workers; plant and machine operators and assemblers
	3 = legislators, senior officials and managers; professionals; technicians and associate professionals
	Armed Forces are missing & other classifications are missing (.)

</_occup_skill_note> */
	gen occup_skill = .
	replace occup_skill = 1 if lstatus == 1 & (substr(occup_isco, 1, 1) == "1" | substr(occup_isco, 1, 1) == "2" | substr(occup_isco, 1, 1) == "3")
	replace occup_skill = 2 if lstatus == 1 & (substr(occup_isco, 1, 1) == "4" | substr(occup_isco, 1, 1) == "5" | substr(occup_isco, 1, 1) == "6" | substr(occup_isco, 1, 1) == "7" | substr(occup_isco, 1, 1) == "8")
	replace occup_skill = 3 if lstatus == 1 & substr(occup_isco, 1, 1) == "9"
	recast byte occup_skill
	label variable occup_skill "Skill based on ISCO standard primary job 7 day recall"
	label define occup_skill_lab 1 "Low skill" 2 "Medium skill" 3 "High skill"
	label values occup_skill occup_skill_lab
*</_occup_skill_>

*<_occup_>
	gen occup = .
	replace occup = 1 if lstatus == 1 & substr(occup_isco, 1, 1) == "1"
	replace occup = 2 if lstatus == 1 & substr(occup_isco, 1, 1) == "2"
	replace occup = 3 if lstatus == 1 & substr(occup_isco, 1, 1) == "3"
	replace occup = 4 if lstatus == 1 & substr(occup_isco, 1, 1) == "4"
	replace occup = 5 if lstatus == 1 & substr(occup_isco, 1, 1) == "5"
	replace occup = 6 if lstatus == 1 & substr(occup_isco, 1, 1) == "6"
	replace occup = 7 if lstatus == 1 & substr(occup_isco, 1, 1) == "7"
	replace occup = 8 if lstatus == 1 & substr(occup_isco, 1, 1) == "8"
	replace occup = 9 if lstatus == 1 & substr(occup_isco, 1, 1) == "9"
	replace occup = 0 if lstatus == 1 & substr(occup_isco, 1, 1) == "10"
	recast byte occup
	label variable occup "1 digit occupational classification, primary job 7 day recall"
	label define occup_lab 1 "Managers" 2 "Professionals" 3 "Technicians" 4 "Clerks" 5 "Service and market sales workers" 6 "Skilled agricultural" 7 "Craft workers" 8 "Machine operators" 9 "Elementary occupations" 10 "Armed forces" 99 "Others"
	label values occup occup_lab
*</_occup_>

*<_ocusec_>
/* <_ocusec_note>

	Do NOT code basis of occupation (ISCO) or industry (ISIC) code

	</_ocusec_note> */

	gen ocusec = .


	recast byte ocusec
	label variable ocusec "Sector of activity primary job 7 day recall"
	label define ocusec_lab 1 "Public Sector, Central Government, Army" 2 "Private, NGO" 3 "State owned" 4 "Public or State-owned, but cannot distinguish"
	label values ocusec ocusec_lab

*</_ocusec_>

*<_wage_no_compen_>
/* <_wage_no_compen_note>

	Prefer using gross wages, rather than net wages

	1980's: only "Primary" and "All Other" jobs exist

</_wage_no_compen_note> */
	rename v0600 wage_no_compen // Check; A: Total Labor Income
	replace wage_no_compen = . if lstatus != 1 | age < minlaborage
	replace wage_no_compen = 0 if empstat == 2
	replace wage_no_compen = . if wage_no_compen > 999000000000
	format wage_no_compen %12.0f
	label variable wage_no_compen "Last wage payment primary job 7 day recall"
*</_wage_no_compen_>

*<_unitwage_>
	gen unitwage = 5
	replace unitwage = . if lstatus != 1
	recast byte unitwage
	label variable unitwage "Last wage's time unit primary job 7 day recall"
	label define unitwage_lab 1 "Daily" 2 "Weekly" 3 "Every two weeks" 4 "Bimonths" 5 "Monthly" 6 "Trimester" 7 "Biannual" 8 "Annually" 9 "Hourly" 10 "Other"
	label values unitwage unitwage_lab
*</_unitwage_>

*<_whours_>
	rename v0510 whours
	replace whours = . if lstatus != 1
	label variable whours "Hours of work in last week primary job 7 day recall"
*</_whours_>

*<_wmonths_>
	gen wmonths = . // V9612 + 12*V9611
	*replace wmonth = . if lstatus != 1 | wmonths > 12
	label variable wmonths "Months of work in past 12 months primary job 7 day recall"
*</_wmonths_>

*<_contract_>
/* <_contract_note>

	Comparability throughout the years is compromised:
	Until 1992: "empregados" (workers) contained both "com carteira" and "sem carteira" (formal and informal)
</_contract_note> */
	rename v0506 contract
	recode contract (4 = 0) (2 = 1) (9 = .)
	replace contract = . if lstatus != 1
	label variable contract "Employment has contract primary job 7 day recall"
	label define contract_lab 0 "Without contract" 1 "With contract"
	label values contract contract_lab
*</_contract_>

*<_wage_total_>
/* <_wage_total_note>

	Prefer using gross wages, rather than net wages

	1980's: only "Primary" and "All Other" jobs exist

	1981: V4718 is V4768

	13º salário

</_wage_total_note> */
	gen wage_total = . //wage_no_compen*wmonths
	*replace wage_total = wage_total + wage_no_compen if wmonths == 12 & contract == 1 * check; A: Ignore that
	label variable wage_total "Annualized total wage primary job 7 day recall"
*</_wage_total_>

*<_healthins_>
	gen healthins = .
	label variable healthins "Employment has health insurance primary job 7 day recall"
	label define healthins_lab 0 "Without health insurance" 1 "With health insurance"
	label values healthins healthins_lab
*</_healthins_>

*<_socialsec_>
	rename v0511 socialsec // [1981: 4761]
	recode socialsec (3 = 0) (1 = 1) (9 = .)
	replace socialsec = . if lstatus != 1
	label variable socialsec "Employment has social security insurance primary job 7 day recall"
	label define socialsec_lab 0 "With social security" 1 "Without social security"
	label values socialsec socialsec_lab
*</_socialsec_>

*<_union_>
	gen union = .
	label variable union "Union membership at primary job 7 day recall"
	label define union_lab 0 "Not union member" 1 "Union member"
	label values union union_lab
*</_union_>

*<_firmsize_l_>
	gen firmsize_l = .
	recast byte firmsize_l
	label variable firmsize_l "Firm size (lower bracket) primary job 7 day recall"
*</_firmsize_l_>

*<_firmsize_u_>
	gen firmsize_u = firmsize_l
	label variable firmsize_u "Firm size (upperr bracket) primary job 7 day recall"
*</_firmsize_u_>



*----------8.3: 7 day reference secondary job----------------------------------*
* Since labels are the same as main job, values are labelled using main job labels



*<_empstat_2_>
/* <_empstat_2_note>

	For all individuals

</_empstat_2_note> */

// check; A: Everything should be missing on _2

	gen empstat_2 = .
	replace empstat_2 = . if lstatus != 1
	recast byte empstat_2
	label variable empstat_2 "Employment status during past week secondary job 7 day recall"
	label values empstat_2 empstat_lab
*</_empstat_2_>

*<_industry_orig_2_>
/* <_industry_orig_2_note>

	CNAE-Domiciliar
	*Classificação Nacional de Atividades Econômicas (CNAE)

</_industry_orig_2_note> */
	gen str5 industry_orig_2 = ""
	replace industry_orig_2 = "" if lstatus != 1 | age < minlaborage | industry_orig_2 == "."
	replace industry_orig_2 = "45000" if industry_orig_2 == "45999"
	replace industry_orig_2 = "15050" if industry_orig_2 == "15055"
	label variable industry_orig_2 "Original survey industry code, secondary job 7 day recall"
*</_industry_orig_2_>

*<_industrycat_isic_2_>
/* <_industrycat_isic_2_note>

	ISIC Rev. 3

</_industrycat_isic_2_note> */


	gen cnae_91 = industry_orig_2
	gen industrycat_isic_2 = .
	cap	label variable industrycat_isic_2 "ISIC code of secondary job 7 day recall"

	/*
cap	merge m:1 cnae_91 using "`path_input'\isic_3_cnae_91.dta"
cap	drop if _merge==2
cap	rename isic_3 industrycat_isic_2
cap	drop _merge cnae_91
cap	replace industrycat_isic_2 = "" if industrycat_isic_2 == ""
*</_industrycat_isic_2_>
*/
*<_industrycat10_2_>
	gen industrycat10_2 =.
	recast byte industrycat10_2
	label variable industrycat10_2 "1 digit industry classification, secondary job 7 day recall"
	label values industrycat10_2 industrycat10_lab
*</_industrycat10_2_>

*<_industrycat4_2_>
	gen industrycat4_2 = .

	label variable industrycat4_2 "Broad Economic Activity classification, secondary job 7 day recall"
	label values industrycat4_2 industrycat4_lab
*</_industrycat4_2_>

*<_occup_orig_2_>
/* <_occup_orig_2_note>

	CBO-Domiciliar
	*Classificação Brasileira de Ocupação (CBO)

</_occup_orig_2_note> */
	gen str4 occup_orig_2 = ""
	replace occup_orig_2 = "" if lstatus != 1 | age < minlaborage
	replace occup_orig_2 = "" if occup_orig_2 == "."
	label variable occup_orig_2 "Original occupational record secondary job 7 day recall"
*</_occup_orig_2_>

*<_occup_isco_2_>
/* <_occup_isco_2_note>

	ISCO-88

</_occup_isco_2_note> */
	gen cbo_91 = occup_orig_2
	gen occup_isco_2 = .
	/*
cap	merge m:1 cbo_91 using "`path_input'\isco_88_cbo_91.dta"
cap	drop if _merge == 2
cap	rename isco_88 occup_isco_2
cap	drop _merge cbo_91
*/
cap	label variable occup_isco_2 "ISCO code of secondary job 7 day recall"

cap	replace occup_isco_2 = "" if occup_isco_2 == ""
*</_occup_isco_2_>

*<_occup_skill_2_>
/* <_occup_skill_2_note>

	ISCO
	1 = elementary occupations
	2 = clerks; service workers and ship and market sales workers; skilled agriculture and fischery workers; craft and related trades workers; plant and machine operators and assemblers
	3 = legislators, senior officials and managers; professionals; technicians and associate professionals
	Armed Forces are missing & other classifications are missing (.)

</_occup_skill_2_note> */
	gen occup_skill_2 = .
	recast byte occup_skill_2
	label variable occup_skill_2 "Skill based on ISCO standard secondary job 7 day recall"
	label values occup_skill_2 occup_skill_lab
*</_occup_skill_2_>

*<_occup_2_>
/* <_occup_2_note>

	Do the dirty work

</_occup_2_note> */
	gen occup_2 = .

	recast byte occup_2
	label variable occup_2 "1 digit occupational classification, secondary job 7 day recall"
	label values occup_2 occup_lab
*</_occup_2_>

*<_ocusec_2_>
/* <_ocusec_2_note>

	Do NOT code basis of occupation (ISCO) or industry (ISIC) code

</_ocusec_2_note> */
	gen ocusec_2 = .
	*recode ocusec_2 (4 = 1)
	recast byte ocusec_2
	label variable ocusec_2 "Sector of activity secondary job 7 day recall"
	label values ocusec_2 ocusec_lab
*</_ocusec_2_>

*<_wage_no_compen_2_>
/* <_wage_no_compen_2_note>

	Prefer using gross wages, rather than net wages

	1980's: doesn't exist (only "Primary" and "All Other" jobs do)

</_wage_no_compen_2_note> */
	replace v0601 = 0 if v0601 ==.
	g v0600 = wage_no_compen
	replace v0600 = 0 if v0600 ==.

	gen wage_no_compen_2 = v0601 - v0600
	replace wage_no_compen_2 = . if lstatus != 1 | age < minlaborage
	replace wage_no_compen_2 = 0 if empstat == 2
	replace wage_no_compen_2 = . if wage_no_compen_2 > 999000000000
	format wage_no_compen_2 %12.0f
	label variable wage_no_compen_2 "Last wage payment secondary job 7 day recall"
	drop v0600 v0601
*</_wage_no_compen_2_>

*<_unitwage_2_>
	gen unitwage_2 = 5
	replace unitwage_2 = . if lstatus != 1
	recast byte unitwage_2
	label variable  unitwage_2 "Last wages' time unit secondary job 7 day recall"
	label values unitwage_2 unitwage_lab
*</_unitwage_2_>

*<_whours_2_>
	replace v5100 = 0 if v5100 ==.
	gen hours_aux = whours
	replace hours_aux = 0 if hours_aux ==.
	gen whours_2 = v5100-hours_aux
	replace whours_2 = . if lstatus != 1
	label variable whours_2 "Hours of work in last week secondary job 7 day recall"
	drop v5100 hours_aux
*</_whours_2_>

*<_wmonths_2_>
	gen wmonths_2 = .
	label variable wmonths_2 "Months of work in the past 12 months secondary job 7 day recall"
*</_wmonths_2_>

*<_wage_total_2_>
/* <_wage_total_2_note>

	1980's: doesn't exist (only "Primary" and "All Other" jobs do)

	Prefer using gross wages, rather than net wages

</_wage_total_2_note> */
	gen wage_total_2 = . // wage_no_compen_2*wmonths_2
	*replace wage_total_2 = wage_total_2 + wage_no_compen_2 if wmonth_2s == 12 & contract_2 == 1
	label variable wage_total_2 "Annualized total wage secondary job 7 day recall"
*</_wage_total_2_>

*<_firmsize_l_2_>/
	gen firmsize_l_2 = .
	recast byte firmsize_l_2
	label variable firmsize_l_2 "Firm size (lower bracket) secondary job 7 day recall"
*</_firmsize_l_2_>

*<_firmsize_u_2_>
	gen firmsize_u_2 = firmsize_l_2
	label variable firmsize_u_2 "Firm size (upper bracket) secondary job 7 day recall"
*</_firmsize_u_2_>


*----------8.4: 7 day reference additional jobs--------------------------------*
* Since labels are the same as main job, values are labelled using main job labels


*<_t_hours_others_>
	gen t_hours_others = .
	replace t_hours_others = . if lstatus != 1
	label variable t_hours_others "Annualized hours worked in all but primary and secondary jobs 7 day recall"
*	drop V9105
*</_t_hours_others_>

*<_t_wage_nocompen_others_>
/* <_t_wage_nocompen_others_note>

	There are no wmonths_others and empstat_others

	Prefer using gross wages, rather than net wages

	1980's: only "Primary" and "All Other" jobs exist

</_t_wage_nocompen_others_note> */
*	replace V1022 = . if lstatus != 1 | age < minlaborage
*	replace V1022 = 0 if empstat_others == 2
*	replace V1022 = . if V1022 > 999000000000
*	format V1022 %12.0f
	gen t_wage_nocompen_others = . // wmonths_others*V1022
	label variable t_wage_nocompen_others "Annualized wage in all but 1st & 2nd jobs excl. bonuses, etc. 7 day recall"
*	drop V1022
*</_t_wage_nocompen_others_>

*<_t_wage_others_>
/* <_t_wage_others_note>

	There are no wmonths_others and empstat_others

	Prefer using gross wages, rather than net wages

	1980's: only "Primary" and "All Other" jobs exist

</_t_wage_others_note> */
*	replace V1025 = . if lstatus != 1 | age < minlaborage
*	replace V1025 = 0 if empstat_others == 2
*	replace V1025 = . if V1025 > 999000000000
*	format V1025 %12.0f
	gen t_wage_others = . // wmonths_others*V1025 + t_wage_nocompen_others
	label variable t_wage_others "Annualized wage in all but primary and secondary jobs (12-mon ref period)"
*	drop V1025
*</_t_wage_others_>


*----------8.5: 7 day reference total summary----------------------------------*
* Since labels are the same as main job, values are labelled using main job labels


*<_t_hours_total_>
	gen t_hours_total = 52*(whours + whours_2)
	replace t_hours_total = . if lstatus != 1
	label variable t_hours_total "Annualized hours worked in all jobs 7 day recall"
*</_t_hours_total_>

*<_t_wage_nocompen_total_>
/* <_t_wage_nocompen_total_note>

	There are no wmonths_total and empstat_total

	Prefer using gross wages, rather than net wages

	1980's: only "Primary" and "All Other" jobs exist
* check; A: Ignore that
</_t_wage_nocompen_total_note> */
	gen t_wage_nocompen_total = . // wage_no_compen + wage_no_compen_2 + t_wage_nocompen_others
	label variable t_wage_nocompen_total "Annualized wage in all jobs excl. bonuses, etc. 7 day recall"
*</_t_wage_nocompen_total_>

*<_t_wage_total_>
/* <_t_wage_total_note>

	There are no wmonths_total and empstat_total

	Prefer using gross wages, rather than net wages

	1980's: only "Primary" and "All Other" jobs exist

	1981: 4719 is 4769

</_t_wage_total_note> */
	gen t_wage_total = . // (wage_total + wage_total_2 + t_wage_others)*wmonths_total or V4769*wmonths_total?
	label variable t_wage_total "Annualized total wage for all jobs 7 day recall"
*	drop V4769
*</_t_wage_total_>


*----------8.6: 12 month reference overall-------------------------------------*
* Since labels are the same as main job, values are labelled using main job labels


/* <__note>

	1992: A broader definition of "work" was adopted, that includes
	"production for own consumption" and "construction for own use"

	1992: skip pattern introduced

</__note> */

*<_lstatus_year_>
/* <_lstatus_year_note>

	Comparability throughout the years is compromised:
	"Trabalhou" (V9001) is compatible throughout, but "estava afastado" is not,
	due to skip pattern introduction and order change (V9004 in 1990's and V9002 in 2000's);
	With both, we get "tinha trabalho", which indicates employment/unemployment

	Until 2006: V4764 was V4764
	Until 2006 (except 1996 & 1997): "employed" could be answered by people 5 years or older

	1981: V4763 is V4763

</_lstatus_year_note> */
	gen lstatus_year = .
	recast byte lstatus
	label variable lstatus_year "Labor status during last year"
	label values lstatus_year lstatus_lab
*</_lstatus_year_>

*<_potential_lf_year_>
	gen potential_lf_year = .
	recast byte potential_lf_year
	label variable potential_lf_year "Potential labour force status during last year"
	label values potential_lf_year potential_lf_lab
*</_potential_lf_year_>

*<_underemployment_year_>
	gen underemployment_year = .
	recast byte underemployment_year
	label variable underemployment_year "Underemployment status during last year"
	label values underemployment_year underemployment_lab
*</_underemployment_year_>

*<_nlfreason_year_>
	gen nlfreason_year = .
	recast byte nlfreason_year
	label variable nlfreason_year "Reason not in the labor force during last year"
	label values nlfreason_year nlfreason_lab
*</_nlfreason_year_>

*<_unempldur_l_year_>
	gen unempldur_l_year = .
	label variable unempldur_l_year "Unemployment duration (months) during last year lower bracket"
*</_unempldur_l_year_>

*<_unempldur_u_year_>
	gen unempldur_u_year = unempldur_l_year
	label variable unempldur_u_year "Unemployment duration (months) during last year upper bracket"
*</_unempldur_u_year_>


*----------8.7: 12 month reference main job------------------------------------*
* Since labels are the same as main job, values are labelled using main job labels


*<_empstat_year_>
/* <_empstat_year_note>

	For all individuals

	Comparability throughout the years is compromised:
	Until 1992: "funcionários públicos estatutários" (public servants) and "militares" (army) could not be identified
	Until 1992: "trabalhadores domésticos" (domestic workers) inexisted
	Until 1992: "empregados" (workers) contained both "com carteira" and "sem carteira" (formal and informal)
	As of 1992: "production for own consumption" and "construction for own use" exist
	As of 1981: "empregado sem declaração de carteira" (probably) became "empregados sem carteira"
	As of 1981: "trabalhador doméstico sem declaração de carteira" (probably) became "trabalhadores domésticos sem carteira"

	1981: V4765 is V4765

</_empstat_year_note> */
	gen empstat_year = .
	replace empstat_year = . if lstatus_year != 1
	label variable empstat_year "Employment status during past week primary job 12 month recall"
	label values empstat_year empstat_lab
*</_empstat_year_>

*<_industry_orig_year_>
/* <_industry_orig_year_note>

	CNAE-Domiciliar
	*Classificação Nacional de Atividades Econômicas (CNAE)

	Until 2006: V9907? was ?
	Until 2006 (except 1996 & 1997): "employed" could be answered by people 5 years or older?

	Comparability throughout the years is compromised:
	Until 2000: one set of codes (all throughout)
	2000?: Adopted standardised set of codes (CNAE)

</_industry_orig_year_note> */

	gen industry_orig_year = industry_orig
	label variable industry_orig_year "Original survey industry code, main job 12 month recall"
*</_industry_orig_year_>

*<_industrycat_isic_year_>
/* <_industrycat_isic_year_note>

	ISIC Rev. 3

</_industrycat_isic_year_note> */
gen industrycat_isic_year = .
cap	label variable industrycat_isic_year "ISIC code of primary job 12 month recall"
/*
	gen cnae_91 = industry_orig_year
cap	merge m:1 cnae_91 using "`path_input'\isic_3_cnae_91.dta"
cap	drop if _merge==2
cap	rename isic_3 industrycat_isic_year
cap	drop _merge cnae_91
cap	replace industrycat_isic_year = "" if industrycat_isic_year == ""
*</_industrycat_isic_year_>
*/
*<_industrycat10_year_>
	gen industrycat10_year = .
	recast byte industrycat10_year
	label variable industrycat10_year "1 digit industry classification, primary job 12 month recall"
	label values industrycat10_year industrycat10_lab
*</_industrycat10_year_>

*<_industrycat4_year_>
	gen industrycat4_year = .
	label variable industrycat4_year "Broad Economic Activities classification, primary job 7 day recall"
	label values industrycat4_year industrycat4_lab
*</_industrycat4_year_>

*<_occup_orig_year_>
/* <_occup_orig_year_note>

	CBO-Domiciliar
	*Classificação Brasileira de Ocupação (CBO)

	Comparability throughout the years is compromised:
	Until 2000: one set of codes (all throughout)
	2002: Adopted standardised set of codes (CBO)

	1981: V4765 is V4765

</_occup_orig_year_note> */
	gen occup_orig_year = .
	label variable occup_orig_year "Original occupation record primary job 12 month recall"
*</_occup_orig_year_>

*<occup_isco_year_>
/* <_occup_isco_year_note>

	ISCO-88

</_occup_isco_year_note> */
gen occup_isco_year =.
label variable occup_isco_year "ISCO code of secondary job 12 month recall"
/*
	gen cbo_91 = occup_orig_year
cap	merge m:1 cbo_91 using "`path_input'\isco_88_cbo_91.dta"
cap	drop if _merge == 2
cap	rename isco_88 occup_isco_year
cap	drop _merge cbo_91
cap	replace occup_isco_year = "" if occup_isco_year == ""
*</_occup_isco_year_>
*/
*<_occup_skill_year_>
/* <_occup_skill_year_note>

	ISCO
	1 = elementary occupations
	2 = clerks; service workers and ship and market sales workers; skilled agriculture and fischery workers; craft and related trades workers; plant and machine operators and assemblers
	3 = legislators, senior officials and managers; professionals; technicians and associate professionals
	Armed Forces are missing & other classifications are missing (.)

</_occup_skill_year_note> */
	gen occup_skill_year = .
	recast byte occup_skill_year
	label variable occup_skill_year "Skill based on ISCO standard secondary job 7 day recall"
	label values occup_skill_year occup_skill_lab
*</_occup_skill_year_>

*<_occup_year_>
	gen occup_year = .
	recast byte occup_year
	label variable occup_year "1 digit occupational classification, secondary job 12 month recall"
	label values occup_year occup_lab
*</_occup_year_>

*<_ocusec_year_>
/* <_ocusec_year_note>

	Do NOT code basis of occupation (ISCO) or industry (ISIC) code

</_ocusec_year_note> */
	gen ocusec_year = .
	recast byte ocusec_year
	label variable ocusec_year "Sector of activity primary job 7 day recall"
	label values ocusec_year ocusec_lab
*</_ocusec_year_>

*<_wage_no_compen_year_>
/* <_wage_no_compen_year_note>

	Prefer using gross wages, rather than net wages

	1980's: only "Primary" and "All Other" jobs exist

	1981: [V4718] is [V4768]

</_wage_no_compen_year_note> */
	gen wage_no_compen_year = .
	format wage_no_compen_year %12.0f
	label variable wage_no_compen_year "Last wage payment primary job 12 month recall"
*</_wage_no_compen_year_>

*<_unitwage_year_>
	gen unitwage_year = .
	recast byte unitwage_year
	label variable unitwage_year "Last wage's time unit primary job 12 month recall"
	label values unitwage_year unitwage_lab
*</_unitwage_year_>

*<_whours_year_>
	gen whours_year = .
	label variable whours_year "Hours of work in last week primary job 12 mon recall"
*</_whours_year_>

*<_wmonths_year_>
	gen wmonths_year = .
	label variable wmonths_year "Months of work in past 12 months primary job 12 month recall"
*</_wmonths_year_>

*<_wage_total_year_>
/* <_wage_total_year_note>

	Prefer using gross wages, rather than net wages

	1980's: only "Primary" and "All Other" jobs exist

</_wage_total_year_note> */
	gen wage_total_year = .
	label variable wage_total_year "Annualized total wage primary job 12 month recall"
*</_wage_total_year_>

*<_contract_year_>
/* <_contract_year_note>

	Comparability throughout the years is compromised:
	Until 1992: "empregados" (workers) contained both "com carteira" and "sem carteira" (formal and informal)

</_contract_year_note> */
	gen contract_year =.

	label variable contract_year "Employment has contract primary job 12 month recall"
	label values contract_year contract_lab
*</_contract_year_>

*<_healthins_year_>
	gen healthins_year = .
	label variable healthins_year "Employment has health insurance primary job 12 month recall"
	label values healthins_year healthins_lab
*</_healthins_year_>

*<_socialsec_year_>
	gen socialsec_year = .
	label variable socialsec_year "Employment has social security insurance primary job 12 month recall"
	label values socialsec_year socialsec_lab
*</_socialsec_year_>

*<_union_year_>
	gen union_year =.
	replace union_year = . if lstatus_year != 1
	label variable union_year "Union membership at primary job 12 month recall"
	label values union_year union_lab
*</_union_year_>

*<_firmsize_l_year_>
	gen firmsize_l_year = .
	recast byte firmsize_l_year
	label variable firmsize_l_year "Firm size (lower bracket) primary job 12 month recall"
*</_firmsize_l_year_>

*<_firmsize_u_year_>
	gen firmsize_u_year = firmsize_l_year
	label variable firmsize_u_year "Firm size (upper bracket), primary job 12 month recall"
*</_firmsize_u_year_>


*----------8.8: 12 month reference secondary job-------------------------------*
* Since labels are the same as main job, values are labelled using main job labels


*<_empstat_2_year_>
/* <_empstat_2_year_note>

	For all individuals

</_empstat_2_year_note> */
	gen empstat_2_year = .
	label variable empstat_2_year "Employment status during past week secondary job 12 month recall"
	label values empstat_2_year empstat_lab
*</_empstat_2_year_>

*<_industry_orig_2_year_>
/* <_industry_orig_2_year_note>

	CNAE-Domiciliar
	*Classificação Nacional de Atividades Econômicas (CNAE)

</_industry_orig_2_year_note> */


	gen str5 industry_orig_2_year = industry_orig_2
	replace industry_orig_2_year = "" if lstatus_year != 1 | age < minlaborage | industry_orig_2_year == "."
	label variable industry_orig_2_year "Original survey industry code, secondary job 12 month recall"
*</_industry_orig_2_year_>

*<_industrycat_isic_2_year_>
/* <_industrycat_isic_2_year_note>

	ISIC Rev. 3

</_industrycat_isic_2_year_note> */
	gen industrycat_isic_2_year = industrycat_isic_2
	tostring industrycat_isic_2_year, replace
	label variable industrycat_isic_2_year "ISIC code of secondary job 12 month recall"
*</_industrycat_isic_2_year_>

*<industrycat10_2_year_>
	gen industrycat10_2_year = .
	recast byte industrycat10_2_year
	label variable industrycat10_2_year "1 digit industry classification, secondary job 12 month recall"
	label values industrycat10_2_year industrycat10_lab
*</_industrycat10_2_year_>

*<_industrycat4_2_year_>
	gen industrycat4_2_year = .
	label variable industrycat4_2_year "Broad Economic Activities classification, secondary job 12 month recall"
	label values industrycat4_2_year industrycat4_lab
*</_industrycat4_2_year_>

*<_occup_orig_2_year_>
/* <_occup_orig_2_year_note>

	CBO-Domiciliar
	*Classificação Brasileira de Ocupação (CBO)

</_occup_orig_2_year_note> */
	*gen str4 occup_orig_2_year = .
	gen occup_orig_2_year = occup_orig_2
	replace occup_orig_2_year = "" if lstatus != 1 | age < minlaborage
	label variable occup_orig_2_year "Original occupational record secondary job 12 month recall"
*</_occup_orig_2_year_>

*<_occup_isco_2_year_>
/* <_occup_isco_2_year_note>

	ISCO-88

</_occup_isco_2_year_note> */
	*gen cbo = . // occup_orig_2_year
	gen occup_isco_2_year = .
	*merge m:1 cbo using "`path_input'\isco_cbo.dta"
	*drop if _merge == 2
	*rename isco occup_isco_2_year
	*label variable occup_isco_2_year "ISCO code of secondary job 12 month recall"
	*drop _merge cbo
	*replace occup_isco_2_year = "." if occup_isco_2_year == ""
*</_occup_isco_2_year_>

*<_occup_skill_2_year_>
/* <_occup_skill_2_year_note>

	ISCO
	1 = elementary occupations
	2 = clerks; service workers and ship and market sales workers; skilled agriculture and fischery workers; craft and related trades workers; plant and machine operators and assemblers
	3 = legislators, senior officials and managers; professionals; technicians and associate professionals
	Armed Forces are missing & other classifications are missing (.)

</_occup_skill_2_year_note> */
	gen occup_skill_2_year = .
	*replace occup_skill_2_year = 1 if lstatus_year == 1 & (substr(occup_isco_2_year, 1, 1) == "1" | substr(occup_isco_2_year, 1, 1) == "2" | substr(occup_isco_2_year, 1, 1) == "3")
	*replace occup_skill_2_year = 2 if lstatus_year == 1 & (substr(occup_isco_2_year, 1, 1) == "4" | substr(occup_isco_2_year, 1, 1) == "5" | substr(occup_isco_2_year, 1, 1) == "6" | substr(occup_isco_2_year, 1, 1) == "7" | substr(occup_isco_2_year, 1, 1) == "8")
	*replace occup_skill_2_year = 3 if lstatus_year == 1 & substr(occup_isco_2_year, 1, 1) == "9"
	recast byte occup_skill_2_year
	label variable occup_skill_2_year "Skill based on ISCO standard secondary job 12 month recall"
	label values occup_skill_2_year occup_skill_lab
*</_occup_skill_2_year_>

*<_occup_2_year_>
/* <_occup_2_year_note>

	Do the dirty work

</_occup_2_year_note> */
	gen occup_2_year = .
	*replace occup_2_year = 1 if lstatus_year == 1 & substr(occup_isco_2_year, 1, 1) == "1"
	*replace occup_2_year = 2 if lstatus_year == 1 & substr(occup_isco_2_year, 1, 1) == "2"
	*replace occup_2_year = 3 if lstatus_year == 1 & substr(occup_isco_2_year, 1, 1) == "3"
	*replace occup_2_year = 4 if lstatus_year == 1 & substr(occup_isco_2_year, 1, 1) == "4"
	*replace occup_2_year = 5 if lstatus_year == 1 & substr(occup_isco_2_year, 1, 1) == "5"
	*replace occup_2_year = 6 if lstatus_year == 1 & substr(occup_isco_2_year, 1, 1) == "6"
	*replace occup_2_year = 7 if lstatus_year == 1 & substr(occup_isco_2_year, 1, 1) == "7"
	*replace occup_2_year = 8 if lstatus_year == 1 & substr(occup_isco_2_year, 1, 1) == "8"
	*replace occup_2_year = 9 if lstatus_year == 1 & substr(occup_isco_2_year, 1, 1) == "9"
	*replace occup_2_year = 0 if lstatus_year == 1 & substr(occup_isco_2_year, 1, 1) == "10"
	recast byte occup_2_year
	label variable occup_2_year "1 digit occupational classification, secondary job 12 month recall"
	label values occup_2_year occup_lab
*</_occup_2_year_>

*<_ocusec_2_year_>
/* <_ocusec_note>

	Do NOT code basis of occupation (ISCO) or industry (ISIC) code

</_ocusec_note> */
	gen ocusec_2_year = .
	recast byte ocusec_2_year
	label variable ocusec_2_year "Sector of activity primary job 12 month recall"
	label values ocusec_2_year ocusec_lab
*</_ocusec_2_year_>

*<_wage_no_compen_2_year_>
/* <_wage_no_compen_2_year_note>

	1980's: doesn't exist (only "Primary" and "All Other" jobs do)

	Prefer using gross wages, rather than net wages

</_wage_no_compen_2_year_note> */

	gen wage_no_compen_2_year = .
	format wage_no_compen_2_year %12.0f
	label variable wage_no_compen_2_year "Last wage payment secondary job 12 month recall"
*</_wage_no_compen_2_year_>

*<_unitwage_2_year_>
	gen unitwage_2_year = .
	recast byte unitwage_2_year
	label variable unitwage_2_year "Last wage' time unit secondary job 12 month recall"
	label values unitwage_2_year unitwage_lab
*</_unitwage_2_year_>

*<_whours_2_year_>
	gen whours_2_year = .
	label variable whours_2_year "Hours of work in last week secondary job 12 month recall"
*</_whours_2_year_>

*<_wmonths_2_year_>
	gen wmonths_2_year = .
	label variable wmonths_2_year "Months of work in past 12 months secondary job 12 month recall"
*</_wmonths_2_year_>

*<_wage_total_2_year_>
/* <_wage_total_2_year_note>

	1980's: doesn't exist (only "Primary" and "All Other" jobs do)

	Prefer using gross wages, rather than net wages

</_wage_total_2_year_note> */
	gen wage_total_2_year = .
	label variable wage_total_2_year "Annualized total wage secondary job 12 month recall"
*</_wage_total_2_year_>

*<_firmsize_l_2_year_>
	gen firmsize_l_2_year = .
	recast byte firmsize_l_2_year
	label variable firmsize_l_2_year "Firm size (lower bracket) secondary job 12 month recall"
*</_firmsize_l_2_year_>

*<_firmsize_u_2_year_>
	gen firmsize_u_2_year = firmsize_l_2_year
	label variable firmsize_u_2_year "Firm size (upper bracket) secondary job 12 month recall"
*</_firmsize_u_2_year_>


*----------8.9: 12 month reference additional jobs-----------------------------*
* Since labels are the same as main job, values are labelled using main job labels


*<_t_hours_others_year_>
	gen t_hours_others_year = .
	label variable t_hours_others_year "Annualized hours worked in all but primary and secondary job 12 month recall"
*</_t_hours_others_year_>

*<_t_wage_nocompen_others_year_>
/* <_t_wage_nocompen_others_year_note>

	There are no wmonths_others_year and empstat_others_year

	Prefer using gross wages, rather than net wages

	1980's: only "Primary" and "All Other" jobs exist

</_t_wage_nocompen_others_year_note> */
	gen t_wage_nocompen_others_year = .
	label variable t_wage_nocompen_others_year "Annualized wage in all but 1st & 2nd jobs excl. bonuses, etc. 12 month recall"
*</_t_wage_nocompen_others_year_>

*<_t_wage_others_year_>
/* <_t_wage_others_year_note>

	There are no wmonths_others_year and empstat_others_year

	Prefer using gross wages, rather than net wages

	1980's: only "Primary" and "All Other" jobs exist

</_t_wage_others_year_note> */
	gen t_wage_others_year = .
	label variable t_wage_others_year "Annualized wage in all but primary and secondary job 12 month recall"
*</_t_wage_others_year_>


*----------8.10: 12 month total summary----------------------------------------*
* Since labels are the same as main job, values are labelled using main job labels


*<_t_hours_total_year_>
	gen t_hours_total_year = .
	label variable t_hours_total_year "Annualized hours worked in all job 12 month recall"
*</_t_hours_total_year_>

*<_t_wage_nocompen_total_year_>
/* <_t_wage_nocompen_total_year_note>

	There are no wmonths_total_year and empstat_total_year

	Prefer using gross wages, rather than net wages

	1980's: only "Primary" and "All Other" jobs exist

</_t_wage_nocompen_total_year_note> */
	gen t_wage_nocompen_total_year = .
	label variable t_wage_nocompen_total_year "Annualized wage in all jobs excl. bonuses, etc. 12 month recall"
*</_t_wage_nocompen_total_year_>

*<_t_wage_total_year_>
/* <_t_wage_total_year_note>

	There are no wmonths_total_year and empstat_total_year

	Prefer using gross wages, rather than net wages

	1980's: only "Primary" and "All Other" jobs exist

</_t_wage_total_year_note> */
	gen t_wage_total_year = .
	label variable t_wage_total_year "Annualized total wage for all jobs 12 month recall"
*</_t_wage_total_year_>


*----------8.11: Overall across reference periods------------------------------*
* Since labels are the same as main job, values are labelled using main job labels


*<_njobs_>
/* <_njobs_note>

	1 = one; 3 = two; 5 = 3 or more

</_njobs_note> */
	gen njobs = 1 if whours_2 != .
	recode njobs (1 = 1) (3 = 2) (5 = 3) // 3 = 3+
	label variable njobs "Total number of jobs"
*</_njobs_>

*<_t_hours_annual_>
	gen t_hours_annual = .
	label variable t_hours_annual "Total hours worked in all jobs in the previous 12 months"
*</_t_hours_annual_>

*<_linc_nc_>
	gen linc_nc = .
	label variable linc_nc "Total annual wage income in all jobs, excl. bonuses, etc."
*</_linc_nc_>

*<_laborincome_>
	gen laborincome = .
	label variable laborincome "Total annual individual labor income in all jobs, incl. bonuses, etc."
 *</_laborincome_>



*----------8.13: Labour cleanup------------------------------------------------*


*<_% Correction min age_>

** Drop info for cases under the age for which questions to be asked (do not need a variable for this)
	local lab_var "minlaborage lstatus nlfreason unempldur_l unempldur_u empstat ocusec industry_orig industrycat_isic industrycat10 industrycat4 occup_orig occup_isco occup_skill occup wage_no_compen unitwage whours wmonths wage_total contract healthins socialsec union firmsize_l firmsize_u empstat_2 ocusec_2 industry_orig_2 industrycat_isic_2 industrycat10_2 industrycat4_2 occup_orig_2 occup_isco_2 occup_skill_2 occup_2 wage_no_compen_2 unitwage_2 whours_2 wmonths_2 wage_total_2 firmsize_l_2 firmsize_u_2 t_hours_others t_wage_nocompen_others t_wage_others t_hours_total t_wage_nocompen_total t_wage_total lstatus_year nlfreason_year unempldur_l_year unempldur_u_year empstat_year ocusec_year industry_orig_year industrycat_isic_year industrycat10_year industrycat4_year occup_orig_year occup_isco_year occup_skill_year occup_year unitwage_year whours_year wmonths_year wage_total_year contract_year healthins_year socialsec_year union_year firmsize_l_year firmsize_u_year empstat_2_year ocusec_2_year industry_orig_2_year industrycat_isic_2_year industrycat10_2_year industrycat4_2_year occup_orig_2_year occup_isco_2_year occup_skill_2_year occup_2_year wage_no_compen_2_year unitwage_2_year whours_2_year wmonths_2_year wage_total_2_year firmsize_l_2_year firmsize_u_2_year t_hours_others_year t_wage_nocompen_others_year t_wage_others_year t_hours_total_year t_wage_nocompen_total_year t_wage_total_year njobs t_hours_annual linc_nc laborincome"

	foreach v of local lab_var {
		cap confirm numeric variable `v'
		if _rc == 0 { // is indeed numeric
			replace `v'= . if (age < minlaborage & !missing(age))
		}
		else { // is not
			replace `v'= "" if (age < minlaborage & !missing(age))
		}

	}

*</_% Correction min age_>



/*%%============================================================================
   9: Final steps
============================================================================%%*/


quietly{

*<_% KEEP VARIABLES - ALL_>

	keep countrycode survname survey icls_v isced_version isco_version isic_version year vermast veralt harmonization int_year int_month hhid pid weight  wave urban subnatid1 subnatid2 subnatid3 subnatidsurvey subnatid1_prev subnatid2_prev subnatid3_prev gaul_adm1_code gaul_adm2_code gaul_adm3_code hsize age male relationharm relationcs marital eye_dsablty hear_dsablty walk_dsablty conc_dsord slfcre_dsablty comm_dsablty migrated_mod_age migrated_ref_time migrated_binary migrated_years migrated_from_urban migrated_from_cat migrated_from_code migrated_from_country migrated_reason ed_mod_age school literacy educy educat7 educat5 educat4 educat_orig educat_isced vocational vocational_type vocational_length_l vocational_length_u vocational_field vocational_financed minlaborage lstatus potential_lf underemployment nlfreason unempldur_l unempldur_u empstat ocusec industry_orig industrycat_isic industrycat10 industrycat4 occup_orig occup_isco occup_skill occup wage_no_compen unitwage whours wmonths wage_total contract healthins socialsec union firmsize_l firmsize_u empstat_2 ocusec_2 industry_orig_2 industrycat_isic_2 industrycat10_2 industrycat4_2 occup_orig_2 occup_isco_2 occup_skill_2 occup_2 wage_no_compen_2 unitwage_2 whours_2 wmonths_2 wage_total_2 firmsize_l_2 firmsize_u_2 t_hours_others t_wage_nocompen_others t_wage_others t_hours_total t_wage_nocompen_total t_wage_total lstatus_year potential_lf_year underemployment_year nlfreason_year unempldur_l_year unempldur_u_year empstat_year ocusec_year industry_orig_year industrycat_isic_year industrycat10_year industrycat4_year occup_orig_year occup_isco_year occup_skill_year occup_year wage_no_compen_year unitwage_year whours_year wmonths_year wage_total_year contract_year healthins_year socialsec_year union_year firmsize_l_year firmsize_u_year empstat_2_year ocusec_2_year industry_orig_2_year industrycat_isic_2_year industrycat10_2_year industrycat4_2_year occup_orig_2_year occup_isco_2_year occup_skill_2_year occup_2_year wage_no_compen_2_year unitwage_2_year whours_2_year wmonths_2_year wage_total_2_year firmsize_l_2_year firmsize_u_2_year t_hours_others_year t_wage_nocompen_others_year t_wage_others_year t_hours_total_year t_wage_nocompen_total_year t_wage_total_year njobs t_hours_annual linc_nc laborincome

*</_% KEEP VARIABLES - ALL_>

*<_% ORDER VARIABLES_>

	order countrycode survname survey icls_v isced_version isco_version isic_version year vermast veralt harmonization int_year int_month hhid pid weight  wave urban subnatid1 subnatid2 subnatid3 subnatidsurvey subnatid1_prev subnatid2_prev subnatid3_prev gaul_adm1_code gaul_adm2_code gaul_adm3_code hsize age male relationharm relationcs marital eye_dsablty hear_dsablty walk_dsablty conc_dsord slfcre_dsablty comm_dsablty migrated_mod_age migrated_ref_time migrated_binary migrated_years migrated_from_urban migrated_from_cat migrated_from_code migrated_from_country migrated_reason ed_mod_age school literacy educy educat7 educat5 educat4 educat_orig educat_isced vocational vocational_type vocational_length_l vocational_length_u vocational_field vocational_financed minlaborage lstatus potential_lf underemployment nlfreason unempldur_l unempldur_u empstat ocusec industry_orig industrycat_isic industrycat10 industrycat4 occup_orig occup_isco occup_skill occup wage_no_compen unitwage whours wmonths wage_total contract healthins socialsec union firmsize_l firmsize_u empstat_2 ocusec_2 industry_orig_2 industrycat_isic_2 industrycat10_2 industrycat4_2 occup_orig_2 occup_isco_2 occup_skill_2 occup_2 wage_no_compen_2 unitwage_2 whours_2 wmonths_2 wage_total_2 firmsize_l_2 firmsize_u_2 t_hours_others t_wage_nocompen_others t_wage_others t_hours_total t_wage_nocompen_total t_wage_total lstatus_year potential_lf_year underemployment_year nlfreason_year unempldur_l_year unempldur_u_year empstat_year ocusec_year industry_orig_year industrycat_isic_year industrycat10_year industrycat4_year occup_orig_year occup_isco_year occup_skill_year occup_year wage_no_compen_year unitwage_year whours_year wmonths_year wage_total_year contract_year healthins_year socialsec_year union_year firmsize_l_year firmsize_u_year empstat_2_year ocusec_2_year industry_orig_2_year industrycat_isic_2_year industrycat10_2_year industrycat4_2_year occup_orig_2_year occup_isco_2_year occup_skill_2_year occup_2_year wage_no_compen_2_year unitwage_2_year whours_2_year wmonths_2_year wage_total_2_year firmsize_l_2_year firmsize_u_2_year t_hours_others_year t_wage_nocompen_others_year t_wage_others_year t_hours_total_year t_wage_nocompen_total_year t_wage_total_year njobs t_hours_annual linc_nc laborincome

*</_% ORDER VARIABLES_>

*<_% DROP UNUSED LABELS_>

	* Store all labels in data
	label dir
	local all_lab `r(names)'

	* Store all variables with a label, extract value label names
	local used_lab = ""
	ds, has(vallabel)

	local labelled_vars `r(varlist)'

	foreach varName of local labelled_vars {
		local y : value label `varName'
		local used_lab `"`used_lab' `y'"'
	}

	set trace on
	* Compare lists, `notused' is list of labels in directory but not used in final variables
	local notused 		: list all_lab - used_lab 		// local `notused' defines value labs not in remaining vars
	local notused_len 	: list sizeof notused 			// store size of local

	* drop labels if the length of the notused vector is 1 or greater, otherwise nothing to drop
	if `notused_len' >= 1 {
		label drop `notused'
	}
	else {
		di "There are no unused labels to drop. No value labels dropped."
	}
	set trace off


*</_% DROP UNUSED LABELS_>

}


*<_% COMPRESS_>

compress

*</_% COMPRESS_>


*<_% DELETE MISSING VARIABLES_>

quietly: describe, varlist
local kept_vars `r(varlist)'

foreach var of local kept_vars {
   capture assert missing(`var')
   if !_rc drop `var'
}

*</_% DELETE MISSING VARIABLES_>


*<_% SAVE_>

	save "`path_output'\BRA_1984_PNAD_v01_M_v01_A_GLD_ALL.dta", replace
	clear

*</_% SAVE_>



*-------------------------------------------------------------------------------
