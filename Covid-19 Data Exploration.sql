/*
Covid 19 Data Exploration 
*/

SELECT *
FROM dbo.worldometer_data
WHERE Continent IS NOT NULL
ORDER BY Continent;

-- Select Data that we are going to be starting with
SELECT Country_Region, Continent, Population, TotalCases, NewCases, TotalDeaths, TotalRecovered
FROM dbo.worldometer_data
WHERE Continent IS NOT NULL;