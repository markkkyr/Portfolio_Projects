SELECT *
FROM insurance


-- Creating Age Bracket 
SELECT age,
(CASE
	WHEN age >= 45 THEN 'Old (45+)'
	WHEN age BETWEEN 30 and 44 THEN 'Middle age (30-44)'
	WHEN age <= 29 THEN 'Young (18-29)'
	END) AS Age_Bracket
FROM insurance;

ALTER Table insurance
ADD Age_Bracket nvarchar(255);

UPDATE insurance
SET Age_Bracket = CASE
	WHEN age >= 45 THEN 'Old (45+)'
	WHEN age BETWEEN 30 and 44 THEN 'Middle age (30-44)'
	WHEN age <= 29 THEN 'Young (18-29)'
	END;

-- Viewing MAX and AVG Charges by age, region

SELECT DISTINCT (Age_Bracket) , COUNT (Age_Bracket) AS CountOfPeople, MAX(cast(charges as FLOAT)) as MAX_Charges, SUM(cast(charges as float)) as Total_charges
FROM insurance
GROUP BY Age_Bracket
ORDER BY 3 DESC;


SELECT Age_Bracket, sex, region, AVG(cast(charges as FLOAT)) as AVG_Charges, SUM(cast(charges as float)) as Total_charges
FROM insurance
GROUP BY age_bracket, sex , region
ORDER BY 1 DESC


SELECT region,
(CASE 
	WHEN smoker = 'yes' THEN 'Smoking'
	WHEN smoker = 'no' THEN 'Non-Smoking'

END) AS Smoke,

AVG(cast(charges as FLOAT)) AS AVG_Charges,
SUM(cast(charges as FLOAT)) AS Total_charges
FROM insurance 
GROUP BY region, Smoker
ORDER BY 1;

-- Charges by BMI 

SELECT region, sex, AVG(cast(bmi as FLOAT)) AS AVG_Bmi, AVG(cast(charges as FLOAT)) as AVG_Charges, MAX(cast(charges as FLOAT)) as MAX_Charges, SUM(cast(charges as float)) as Total_charges
FROM insurance
GROUP BY region , sex
ORDER BY region


