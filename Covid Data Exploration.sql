CREATE DATABASE Covid

SELECT *
FROM [Covid].[dbo].[Deaths]

SELECT *
FROM [Covid].[dbo].[Vaccinations]

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM [Covid].[dbo].[Deaths]
WHERE continent IS NOT NULL 

-- Total Cases vs Total Deaths: the likelihood of dying if you contract covid 
SELECT location, 
       date, 
       total_cases, 
       total_deaths, 
       CAST(total_deaths AS float)/CAST(total_cases AS float) * 100 as death_rate
FROM [Covid].[dbo].[Deaths]
WHERE continent IS NOT NULL 

-- Total Cases vs Population: the percentage of population infected with Covid
SELECT location, 
       date, 
       population, 
       total_cases,  
       CAST(total_cases AS float)/population * 100 as infected_percentage
From [Covid].[dbo].[Deaths]
WHERE continent IS NOT NULL 

-- Infection rate across countries
SELECT location, 
       population, 
       MAX(total_cases) AS highest_infection,  
       Max(CAST(total_cases AS float)/population) * 100 AS infection_rate
FROM [Covid].[dbo].[Deaths]
GROUP BY location, population
ORDER BY infection_rate DESC

-- Death count across ountries
SELECT Location, MAX(total_deaths) AS death_count
FROM [Covid].[dbo].[Deaths]
WHERE continent IS NOT NULL 
GROUP BY Location
ORDER BY death_count DESC

-- Percentage of death compared to population across countries
SELECT location, 
       population, 
       MAX(total_deaths) AS highest_death_percentage,  
       Max(CAST(total_deaths AS float)/population) * 100 AS death_percentage
FROM [Covid].[dbo].[Deaths]
GROUP BY location, population
ORDER BY death_percentage DESC

-- Data at continent level: death count across contintents
SELECT continent, MAX(total_deaths) AS total_death
FROM [Covid].[dbo].[Deaths]
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY total_death DESC

-- Data at globle level
SELECT SUM(new_cases) AS total_cases, 
       SUM(new_deaths) AS total_deaths, 
       SUM(CAST(new_deaths AS float))/SUM(CAST(New_Cases AS float)) * 100 AS death_rate_globle
FROM [Covid].[dbo].[Deaths]
-- WHERE continent IS NOT NULL

-- Total Population vs Vaccinations: percentage of population that has recieved at least one vaccine
SELECT dea.continent, 
       dea.location, 
       dea.date, 
       dea.population, 
       vac.new_vaccinations, 
       SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_vaccinated 
FROM [Covid].[dbo].[Deaths] dea
JOIN [Covid].[dbo].[Vaccinations] vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

-- Using CTE to perform calculation on PARTITION BY  in previous query
WITH Pop_Vac_CTE (Continent, Location, Date, Population, New_Vaccinations, Rolling_vaccinated) AS(
    SELECT dea.continent, 
           dea.location, 
           dea.date, 
           dea.population, 
           vac.new_vaccinations, 
           SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_vaccinated 
    FROM [Covid].[dbo].[Deaths] dea
    JOIN [Covid].[dbo].[Vaccinations] vac
        ON dea.location = vac.location
        AND dea.date = vac.date
    WHERE dea.continent IS NOT NULL
)
SELECT *, (rolling_vaccinated/Population) * 100 AS rolling_vaccinated_percentage
FROM Pop_Vac

-- Using Temp Table to perform calculation on PARTITION BY in previous query
DROP TABLE IF EXISTS #Pop_Vac_Temp
CREATE TABLE #Pop_Vac_Temp(
    Continent nvarchar(255),
    Location nvarchar(255),
    Date date,
    Population numeric,
    New_vaccinations numeric,
    Rolling_vaccinated numeric
)

INSERT INTO #Pop_Vac_Temp
SELECT dea.continent, 
       dea.location, 
       dea.date, 
       dea.population, 
       vac.new_vaccinations, 
       SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_vaccinated 
FROM [Covid].[dbo].[Deaths] dea
JOIN [Covid].[dbo].[Vaccinations] vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *, (rolling_vaccinated/Population) * 100 AS rolling_vaccinated_percentage
FROM #Pop_Vac_Temp

GO

-- Creating View to store data for later visualizations
CREATE VIEW Pop_Vac AS
    SELECT dea.continent, 
           dea.location, 
           dea.date, 
           dea.population, 
           vac.new_vaccinations, 
           SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_vaccinated 
    FROM [Covid].[dbo].[Deaths] dea
    JOIN [Covid].[dbo].[Vaccinations] vac
        ON dea.location = vac.location
        AND dea.date = vac.date
    WHERE dea.continent IS NOT NULL

GO

SELECT *
FROM Pop_Vac