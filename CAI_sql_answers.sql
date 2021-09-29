/**************  QUESTION 1 **************
 Count of patients with ANY Tamoxifan AND ANY biomarker */

-- NOTE, it seems that Nolvadex and Soltamax are the only major brand names
-- Also, no primary key on medications, so using med_start_date for now, but would want to find a unique key for more elaborate analyses
-- Some quick queries to see if codes and generic names are different sets, just in case


-- What are the generic names for Tamoxifan?

select distinct med_generic_name_name, count(distinct(med_start_date)) from medication where lower(med_generic_name_name) LIKE  '%tamoxifen%' group by 1;

/*   med_generic_name_name    | count 
----------------------------+-------
 Tamoxifen                  |   190
 tamoxifen citrate-nolvadex |    63
 tamoxifen-soltamox         |     6 

NOTE, it looks like one main generic name and one lesser used name for both brand names 
/*


-- Do these different brand names have different brand name codes I should be aware of?

select distinct med_brand_name_code, count(distinct(med_start_date)) from medication where lower(med_generic_name_name) LIKE  '%tamoxifen%' group by 1;

/*
 med_brand_name_code | count 
---------------------+-------
 10324               |   190
                     |    69
NOTE, all brand name codes for Tamoxifan are either 10324 or blank
*/


-- If we search generic names for only the 2 brand names, are there any additional codes that do not get covered by simply searching for Tamoxifan?

select distinct med_generic_name_code, count(distinct(med_start_date)) from medication where  lower(med_generic_name_name) like '%soltamox%' or lower(med_generic_name_name) like  '%nolvadex%' group by 1;

/*
 med_generic_name_code | count 
-----------------------+-------
 281964                |    63
 498464                |     6

NOTE, it looks like  %tamoxifen% is going to give good coverage for medication table
*/ 



-- Ceiling for result: Total unique patients with biomarkers

select count(distinct(patient_id)) from biomarker;

/*
 count 
-------
   196
*/

-- MAIN QUERY
SELECT count(distinct(m.patient_id))
FROM medication m
INNER JOIN (SELECT distinct patient_id from biomarker) b
ON m.patient_id = b.patient_id
WHERE lower(m.med_generic_name_name) like '%tamoxifen%'
;
/*
 count 
-------
    77
*/






/**************  QUESTION 2 **************
Create a table with the 3 earliest diagnoses for each patient */

-- NOTE: It looks like there is no diagnosis_ID primary key here, so I'll just allow ties on diagnosis_date for now but would want to create some surrogate key later on to disambiguate

-- MAIN QUERY
CREATE TABLE top_diagnoses AS
WITH sub_q AS (select *, rank() over (partition by patient_id order by diagnosis_date) as diag_rank from condition order by diagnosis_date)
SELECT * 
FROM sub_q where diag_rank in (1,2,3)
ORDER BY patient_id, diagnosis_date
;



