/* 
	Angelica Froio, Amaan Gadatia, Vicky Weng
	CSC 315-02: sample_queries.sql for Phase V(a)
	Professor DeGood
	4/8/24

*/

-- Query 1
-- Display vaccine codes and their text values.
SELECT * FROM vaccines;

-- Query 2
-- Fetch all goats who had a session in September 2018.
SELECT B.animal_id, A.dob, B.when_measured, B.activity_code, V.value_txt, A.status_current, C.goat_age
FROM Animal A, Activity B, vaccines V, ages C
WHERE B.when_measured > '2018-09-01 00:00:00' 
    AND B.when_measured < '2018-09-30 00:00:00' 
    AND V.picklistvalue_id = B.activity_code
    AND B.animal_id = A.animal_id
    AND A.status_current = 'Current'
    AND C.animal_id = A.animal_id;

-- Query 3
-- Fetch all goats born within the first half of 2017 that 
-- received the chlamydia vaccine and had an overall adg > 0.1.
SELECT B.animal_id, A.dob, A.overall_adg, B.when_measured, B.activity_code, V.value_txt
FROM Animal A, Activity B, vaccines V
WHERE A.dob > '2017-01-01 00:00:00' 
    AND A.dob < '2017-06-01 00:00:00' 
    AND B.activity_code = 737
    AND V.picklistvalue_id = B.activity_code
    AND A.overall_adg <> ''
    AND CAST(A.overall_adg AS DECIMAL(6,2)) > 0.1
    AND B.animal_id = A.animal_id;

-- Query 4
-- Display time it took for goat 3760 to recieve chamydia vaccine.
SELECT * FROM time_til_vax T
WHERE T.picklistvalue_id = 737
    AND T.animal_id = 3760;

-- Query 5
-- Display goat info from Query 3 along with time in between birth and vaccinaiton.
SELECT B.animal_id, A.dob, A.status_current, B.when_measured, B.activity_code,  
        V.value_txt, T.vax_time
FROM Animal A, Activity B, vaccines V, time_til_vax T
WHERE V.picklistvalue_id = B.activity_code
    AND B.animal_id = A.animal_id
    AND B.activity_code = 737
    AND B.animal_id = T.animal_id
    AND B.when_measured = T.when_measured
    AND A.dob > '2017-01-01 00:00:00' 
    AND A.dob < '2017-06-01 00:00:00';

-- Query 6
-- Display overall_adg on goat info from Query 5.
SELECT B.animal_id, A.status_current, A.overall_adg, V.value_txt, T.vax_time
FROM Animal A, Activity B, vaccines V, time_til_vax T
WHERE V.picklistvalue_id = B.activity_code
    AND B.animal_id = A.animal_id
    AND B.activity_code = 737
    AND B.animal_id = T.animal_id
    AND B.when_measured = T.when_measured
    AND CAST(A.overall_adg AS DECIMAL(6,2)) > 0.1
    AND A.dob > '2017-01-01 00:00:00' 
    AND A.dob < '2017-06-01 00:00:00';

-- Query 7
-- Fetch all goats born within the first half of 2017 that recieved the 5-in-1 
-- vaccine and had an overall_adg > 0.1, and display time to be vaccinaed.
SELECT B.animal_id, A.status_current, A.overall_adg, V.value_txt, T.vax_time
FROM Animal A, Activity B, vaccines V, time_til_vax T
WHERE V.picklistvalue_id = B.activity_code
    AND B.animal_id = A.animal_id
    AND B.activity_code = 49
    AND B.animal_id = T.animal_id
    AND B.when_measured = T.when_measured
    AND CAST(A.overall_adg AS DECIMAL(6,2)) > 0.1
    AND A.dob > '2017-01-01 00:00:00' 
    AND A.dob < '2017-06-01 00:00:00';

SELECT T.vax_time, A.overall_adg
FROM Animal A, time_til_vax T
WHERE A.animal_id = T.animal_id
    AND A.overall_adg IS NOT NULL
    AND A.dob > '2017-01-01 00:00:00' 
    AND A.dob < '2017-06-01 00:00:00';

SELECT A.animal_id, A.animal_group, W.alpha_value, W.when_measured
FROM Animal A, weights W
WHERE A.animal_group = '4th BRD GRP'
    AND A.animal_id = W.animal_id;
    
SELECT DISTINCT ON (A.animal_id) A.animal_id, W.alpha_value, W.when_measured 
FROM Animal A 
JOIN weights W ON A.animal_id = W.animal_id 
JOIN (
    SELECT animal_id, MAX(when_measured) AS max_when_measured 
    FROM weights 
    GROUP BY animal_id
) AS max_weights ON W.animal_id = max_weights.animal_id AND W.when_measured = max_weights.max_when_measured 
WHERE A.animal_group = '4th BRD GRP';

SELECT A.animal_id, W.alpha_value, W.when_measured, C.age_at_measure FROM Animal A, weights W, weight_ages C WHERE A.animal_group = '1st BRD GRP' AND A.animal_id = W.animal_id AND A.animal_id = C.animal_id AND W.when_measured = C.when_measured;