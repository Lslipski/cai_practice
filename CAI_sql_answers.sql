/**************  QUESTION 1 **************
 Count of patients with ANY Tamoxifan AND ANY biomarker */

-- NOTE, the internet seems to think Nolvadex and Soltamax are the only major brand names
-- Some quick queries to see if codes and generic names are different sets, just in case

select distinct med_generic_name_name, count(distinct(med_start_date)) from medication where lower(med_generic_name_name) LIKE  '%tamoxifen%' group by 1;

/*   med_generic_name_name    | count 
----------------------------+-------
 Tamoxifen                  |   190
 tamoxifen citrate-nolvadex |    63
 tamoxifen-soltamox         |     6 */

select distinct med_brand_name_code, count(distinct(med_start_date)) from medication where lower(med_generic_name_name) LIKE  '%tamoxifen%' group by 1;

/*
 med_brand_name_code | count 
---------------------+-------
 10324               |   190
                     |    69
note, some missing codes given brand name
*/

select distinct med_generic_name_code, count(distinct(med_start_date)) from medication where  lower(med_generic_name_name) like '%soltamox%' or lower(med_generic_name_name) like  '%nolvadex%' group by 1;
/*
 med_generic_name_code | count 
-----------------------+-------
 281964                |    63
 498464                |     6
*/

/*
Looks like %tamoxifen% is going to give good coverage for medication table

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
WITH sub_q AS (select *, rank() over (partition by patient_id order by diagnosis_date) as diag_rank from condition order by diagnosis_date)
SELECT * 
FROM sub_q where diag_rank in (1,2,3)
ORDER BY patient_id, diagnosis_date
;



