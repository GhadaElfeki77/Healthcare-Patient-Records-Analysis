--**Hospital Patient Records Analysis Using SQL

CREATE TABLE encounters (
    Id NVARCHAR(50),
    START NVARCHAR(50),
    STOP NVARCHAR(50),
    PATIENT NVARCHAR(50),
    ORGANIZATION NVARCHAR(50),
    PAYER NVARCHAR(50),
    ENCOUNTERCLASS NVARCHAR(50),
    CODE NVARCHAR(50),
    DESCRIPTION NVARCHAR(255),
    BASE_ENCOUNTER_COST DECIMAL(18,2),
    TOTAL_CLAIM_COST DECIMAL(18,2),
    PAYER_COVERAGE DECIMAL(18,2),
    REASONCODE NVARCHAR(50),
    REASONDESCRIPTION NVARCHAR(500)
);


BULK INSERT encounters
FROM 'D:\AI Codin Acadmy Course\Final projects of data analysis\SQL\Hospital+Patient+Records-20260620T220931Z-3-001\Hospital+Patient+Records\encounters.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    CODEPAGE = '65001'
);

--**Phase 1: Data Exploration
--1. Total Patients

SELECT COUNT(*) AS Total_Patients
FROM patients

--2. Total Encounters

SELECT COUNT(*) AS Total_Encounters
FROM encounters

--3. Total Insurance Providers

SELECT COUNT(*) AS Total_Payers
FROM payers

--4. Total Organizations

SELECT COUNT(*) AS Total_Organizations
FROM organizations

--Phase 2: Patient Demographics

--5. Patients by Gender

SELECT
    GENDER,
    COUNT(*) AS Total_Patients
FROM patients
GROUP BY GENDER
ORDER BY Total_Patients DESC

--6. Patients by Race

SELECT
    RACE,
    COUNT(*) AS Total_Patients
FROM patients
GROUP BY RACE
ORDER BY Total_Patients DESC

--7. Patients by Ethnicity

SELECT
    ETHNICITY,
    COUNT(*) AS Total_Patients
FROM patients
GROUP BY ETHNICITY
ORDER BY Total_Patients DESC

--**Phase 3: Age Analysis

--Age Calculation

SELECT
    Id,
    BIRTHDATE,
    DATEDIFF(YEAR,BIRTHDATE,GETDATE()) AS Age
FROM patients

--Age Group Analysis

SELECT
CASE
    WHEN DATEDIFF(YEAR,BIRTHDATE,GETDATE()) < 18 THEN 'Child'
    WHEN DATEDIFF(YEAR,BIRTHDATE,GETDATE()) BETWEEN 18 AND 35 THEN 'Young Adult'
    WHEN DATEDIFF(YEAR,BIRTHDATE,GETDATE()) BETWEEN 36 AND 55 THEN 'Adult'
    ELSE 'Senior'
END AS Age_Group,
COUNT(*) AS Total_Patients
FROM patients
GROUP BY
CASE
    WHEN DATEDIFF(YEAR,BIRTHDATE,GETDATE()) < 18 THEN 'Child'
    WHEN DATEDIFF(YEAR,BIRTHDATE,GETDATE()) BETWEEN 18 AND 35 THEN 'Young Adult'
    WHEN DATEDIFF(YEAR,BIRTHDATE,GETDATE()) BETWEEN 36 AND 55 THEN 'Adult'
    ELSE 'Senior'
END
ORDER BY Total_Patients DESC


--4. Encounter Analysis

--Encounters by Class

SELECT
    ENCOUNTERCLASS,
    COUNT(*) AS Total_Encounters
FROM encounters
GROUP BY ENCOUNTERCLASS
ORDER BY Total_Encounters DESC;

--Top 10 Encounter Types

SELECT TOP 10
    DESCRIPTION,
    COUNT(*) AS Total_Encounters
FROM encounters
GROUP BY DESCRIPTION
ORDER BY Total_Encounters DESC;


--Top 10 Medical Reasons

SELECT TOP 10
    REASONDESCRIPTION,
    COUNT(*) AS Total_Cases
FROM encounters
WHERE REASONDESCRIPTION IS NOT NULL
GROUP BY REASONDESCRIPTION
ORDER BY Total_Cases DESC;


--5. Financial Analysis

--Total Claim Cost

SELECT
    SUM(TOTAL_CLAIM_COST) AS Total_Claim_Cost
FROM encounters;

--Average Claim Cost

SELECT
    AVG(TOTAL_CLAIM_COST) AS Average_Claim_Cost
FROM encounters;


--Total Insurance Coverage

SELECT
    SUM(PAYER_COVERAGE) AS Total_Insurance_Coverage
FROM encounters;


--Average Insurance Coverage

SELECT
    AVG(PAYER_COVERAGE) AS Average_Insurance_Coverage
FROM encounters;


--Most Expensive Encounters

SELECT TOP 10
    DESCRIPTION,
    TOTAL_CLAIM_COST
FROM encounters
ORDER BY TOTAL_CLAIM_COST DESC;


--6. Join Analysis

--Encounters by Gender

SELECT
    p.GENDER,
    COUNT(*) AS Total_Encounters
FROM encounters e
INNER JOIN patients p
    ON e.PATIENT = p.Id
GROUP BY p.GENDER
ORDER BY Total_Encounters DESC;


--Cost by Gender

SELECT
    p.GENDER,
    SUM(e.TOTAL_CLAIM_COST) AS Total_Cost
FROM encounters e
INNER JOIN patients p
    ON e.PATIENT = p.Id
GROUP BY p.GENDER
ORDER BY Total_Cost DESC;


--Encounters by Race

SELECT
    p.RACE,
    COUNT(*) AS Total_Encounters
FROM encounters e
INNER JOIN patients p
    ON e.PATIENT = p.Id
GROUP BY p.RACE
ORDER BY Total_Encounters DESC;


--7. Insurance Analysis

--Encounters by Insurance Provider

SELECT
    py.NAME,
    COUNT(*) AS Total_Encounters
FROM encounters e
INNER JOIN payers py
    ON e.PAYER = py.Id
GROUP BY py.NAME
ORDER BY Total_Encounters DESC;


--Claim Cost by Insurance Provider

SELECT
    py.NAME,
    SUM(e.TOTAL_CLAIM_COST) AS Total_Cost
FROM encounters e
INNER JOIN payers py
    ON e.PAYER = py.Id
GROUP BY py.NAME
ORDER BY Total_Cost DESC;

--8. Top 10 Patients by Healthcare Cost

SELECT TOP 10
    p.FIRST,
    p.LAST,
    SUM(e.TOTAL_CLAIM_COST) AS Total_Cost
FROM patients p
INNER JOIN encounters e
    ON p.Id = e.PATIENT
GROUP BY p.FIRST, p.LAST
ORDER BY Total_Cost DESC;


--Average Cost by Encounter Class

SELECT
    ENCOUNTERCLASS,
    AVG(TOTAL_CLAIM_COST) AS Avg_Cost
FROM encounters
GROUP BY ENCOUNTERCLASS
ORDER BY Avg_Cost DESC;


--Ranking Encounter Classes by Cost

SELECT
    ENCOUNTERCLASS,
    SUM(TOTAL_CLAIM_COST) AS Total_Cost,
    RANK() OVER(
        ORDER BY SUM(TOTAL_CLAIM_COST) DESC
    ) AS Cost_Rank
FROM encounters
GROUP BY ENCOUNTERCLASS;



--**Dashboard Dataset

--Sheet 1: KPI Summary

SELECT
    (SELECT COUNT(*) FROM patients) AS Total_Patients,
    (SELECT COUNT(*) FROM encounters) AS Total_Encounters,
    (SELECT COUNT(*) FROM payers) AS Total_Payers,
    (SELECT SUM(TOTAL_CLAIM_COST) FROM encounters) AS Total_Claim_Cost,
    (SELECT AVG(TOTAL_CLAIM_COST) FROM encounters) AS Avg_Claim_Cost;


--Sheet 2: Gender Analysis

SELECT
    p.GENDER,
    COUNT(*) AS Total_Encounters,
    SUM(e.TOTAL_CLAIM_COST) AS Total_Cost
FROM encounters e
INNER JOIN patients p
ON e.PATIENT = p.Id
GROUP BY p.GENDER;


--Sheet 3: Race Analysis

SELECT
    p.RACE,
    COUNT(*) AS Total_Encounters
FROM encounters e
INNER JOIN patients p
ON e.PATIENT = p.Id
GROUP BY p.RACE
ORDER BY Total_Encounters DESC;


--Sheet 4: Encounter Class

SELECT
    ENCOUNTERCLASS,
    COUNT(*) AS Total_Encounters,
    SUM(TOTAL_CLAIM_COST) AS Total_Cost
FROM encounters
GROUP BY ENCOUNTERCLASS
ORDER BY Total_Encounters DESC;


--Sheet 5: Insurance Analysis

SELECT
    py.NAME,
    COUNT(*) AS Total_Encounters,
    SUM(e.TOTAL_CLAIM_COST) AS Total_Cost
FROM encounters e
INNER JOIN payers py
ON e.PAYER = py.Id
GROUP BY py.NAME
ORDER BY Total_Cost DESC;


--Sheet 6: Top Medical Reasons

SELECT TOP 20
    REASONDESCRIPTION,
    COUNT(*) AS Total_Cases
FROM encounters
WHERE REASONDESCRIPTION IS NOT NULL
GROUP BY REASONDESCRIPTION
ORDER BY Total_Cases DESC;


--Sheet 7: Top Costly Encounters

SELECT TOP 20
    DESCRIPTION,
    SUM(TOTAL_CLAIM_COST) AS Total_Cost
FROM encounters
GROUP BY DESCRIPTION
ORDER BY Total_Cost DESC;



--**CREATE VIEW\

--KPI Summary

GO
DROP VIEW vw_Gender_Analysis;
DROP VIEW vw_Encounter_Class
DROP VIEW vw_Insurance_Analysis
DROP VIEW vw_Race_Analysis
DROP VIEW vw_Top_Medical_Reasons
GO



GO

CREATE OR ALTER VIEW vw_KPI_Summary
AS
SELECT
    (SELECT COUNT(*) FROM patients) AS Total_Patients,
    (SELECT COUNT(*) FROM encounters) AS Total_Encounters,
    (SELECT COUNT(*) FROM payers) AS Total_Payers,
    (SELECT SUM(TOTAL_CLAIM_COST) FROM encounters) AS Total_Claim_Cost,
    (SELECT AVG(TOTAL_CLAIM_COST) FROM encounters) AS Avg_Claim_Cost;
    GO

--Encounter_Class

Go
CREATE VIEW vw_Encounter_Class AS
SELECT
    ENCOUNTERCLASS,
    COUNT(*) AS Total_Encounters,
    SUM(TOTAL_CLAIM_COST) AS Total_Cost
FROM encounters
GROUP BY ENCOUNTERCLASS;
GO

--Gender Analysis

GO

CREATE OR ALTER VIEW vw_Gender_Analysis
AS
SELECT
    p.GENDER,
    COUNT(*) AS Total_Encounters,
    SUM(e.TOTAL_CLAIM_COST) AS Total_Cost
FROM encounters e
JOIN patients p
    ON e.PATIENT = p.Id
GROUP BY p.GENDER;

GO

--Race Analysis

GO
CREATE OR ALTER VIEW  vw_Race_Analysis AS
SELECT
    p.RACE,
    COUNT(*) AS Total_Encounters
FROM encounters e
INNER JOIN patients p
ON e.PATIENT = p.Id
GROUP BY p.RACE;
GO


--Insurance_Analysis

GO
CREATE OR ALTER VIEW vw_Insurance_Analysis AS
SELECT
    py.NAME,
    COUNT(*) AS Total_Encounters,
    SUM(e.TOTAL_CLAIM_COST) AS Total_Cost
FROM encounters e
INNER JOIN payers py
ON e.PAYER = py.Id
GROUP BY py.NAME;
GO

--Top Medical Reasons

GO
CREATE OR ALTER VIEW vw_Top_Medical_Reasons AS
SELECT
    REASONDESCRIPTION,
    COUNT(*) AS Total_Cases
FROM encounters
WHERE REASONDESCRIPTION IS NOT NULL
GROUP BY REASONDESCRIPTION;
GO


SELECT *
FROM vw_KPI_Summary
SELECT *
FROM vw_Encounter_Class;

SELECT * 
FROM vw_Gender_Analysis;


SELECT *
FROM vw_Race_Analysis


SELECT *
FROM vw_Insurance_Analysis

SELECT
    CAST(REPLACE(REPLACE([START],'T',' '),'Z','') AS DATETIME) AS EncounterDate
FROM encounters;


SELECT
    *,
    CAST(REPLACE(REPLACE([START],'T',' '),'Z','') AS DATETIME) AS EncounterDate
FROM encounters;

ALTER TABLE encounters
ADD EncounterDate DATETIME;

UPDATE encounters
SET EncounterDate=
CAST(REPLACE(REPLACE([START],'T',' '),'Z','') AS DATETIME);


SELECT
    *,
    CAST(REPLACE(REPLACE([START],'T',' '),'Z','') AS DATETIME) AS EncounterDate
FROM encounters;

