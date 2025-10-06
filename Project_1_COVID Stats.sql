SELECT *
FROM portfolio_project..coviddeaths
WHERE continent is not NULL
ORDER BY 3,4;


SELECT *
FROM portfolio_project..covidvaccs
ORDER BY 3,4;

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM portfolio_project..coviddeaths
ORDER BY 1,2 ;

-- Total Cases vs Total Deaths

SELECT location, date, total_cases, total_deaths, (total_deaths / total_cases) *100 AS Death_Percentage
FROM portfolio_project..coviddeaths
WHERE location LIKE 'Pol%'
AND continent is not NULL
ORDER BY 1,2 ;

-- Total Cases vs Population

SELECT location, date, total_cases, population, (total_cases / population) *100 AS CovidPercentage_per_Population
FROM portfolio_project..coviddeaths
WHERE location = 'Poland'
AND continent is not NULL
ORDER BY 1,2 ;


-- Countries with highest covid cases and covid deaths compared to population

SELECT location, population, MAX(total_cases) AS HighestCovidCases,MAX((total_cases / population)) *100 AS Percentage_per_Population
FROM portfolio_project..coviddeaths
WHERE continent is not NULL
GROUP BY location, population
ORDER BY Percentage_per_Population DESC ;

SELECT location, population, MAX(total_deaths) AS HighestDeathsCases,MAX((total_deaths / population)) *100 AS Percentage_deaths_Population
FROM portfolio_project..coviddeaths
WHERE continent is not NULL
GROUP BY location, population
ORDER BY Percentage_deaths_Population DESC ;


SELECT location, MAX(cast(total_deaths as int)) AS HighestDeathsCases
FROM portfolio_project..coviddeaths
WHERE continent is not NULL
GROUP BY location
ORDER BY HighestDeathsCases DESC ;


-- Deaths by Continent

SELECT continent, MAX(cast(total_deaths as int)) AS TotalDeathsCases
FROM portfolio_project..coviddeaths
WHERE continent is   not NULL
GROUP BY continent
ORDER BY TotalDeathsCases DESC ;


-- WORLDWIDE STATS

SELECT  SUM(new_cases) AS NewCases_Worldwide, SUM(cast(new_deaths as int)) AS NewDeaths_Worldwide, SUM(cast(new_deaths as int))/SUM(new_cases) 
	*100 as DeathPercentage_Worldwide
FROM portfolio_project..coviddeaths
WHERE continent is not NULL
ORDER BY 1,2 ;

SELECT  date, SUM(new_cases) AS NewCases_Worldwide, SUM(cast(new_deaths as int)) AS NewDeaths_Worldwide, SUM(cast(new_deaths as int))/SUM(new_cases) 
	*100 as DeathPercentage_Worldwide
FROM portfolio_project..coviddeaths
WHERE continent is not NULL
GROUP BY date
ORDER BY 1,2 ;




-- Total population vs total vaccinations 

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY vac.location ORDER BY vac.date) as RollingCount_Vaccinations
FROM Portfolio_Project..CovidDeaths dea
JOIN Portfolio_Project..CovidVaccs vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not NULL
ORDER BY 2,3;


WITH Percentage_Rolling (continent,location,date,population,new_vaccinations, RollingCount_Vaccinations) AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY vac.location ORDER BY vac.date) as RollingCount_Vaccinations
FROM Portfolio_Project..CovidDeaths dea
JOIN Portfolio_Project..CovidVaccs vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not NULL
)
SELECT *, (RollingCount_Vaccinations/population) *100 AS RollingVaccs
FROM Percentage_Rolling

--  Temp Table 

DROP TABLE if exists #PopulationVaccsPercent
CREATE TABLE #PopulationVaccsPercent
(continent nvarchar(255) ,
location nvarchar(255),
date datetime,
population numeric, 
new_vaccinations numeric, 
RollingCount_Vaccinations numeric)

INSERT INTO #PopulationVaccsPercent
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY vac.location ORDER BY vac.date)
as RollingCount_Vaccinations
-- , (RollingCount_Vaccinations/population) *100 AS RollingVaccs
FROM Portfolio_Project..CovidDeaths dea
JOIN Portfolio_Project..CovidVaccs vac
	ON dea.location = vac.location
	AND dea.date = vac.date
-- WHERE dea.continent is not NULL
-- ORDER BY 2,3

SELECT *, (RollingCount_Vaccinations/population) *100 AS RollingVaccs
FROM #PopulationVaccsPercent
ORDER BY 2,3


-- VIEW data for visualizations
GO
CREATE View PopulationVaccsPercent AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY vac.location ORDER BY vac.date)
as RollingCount_Vaccinations
FROM Portfolio_Project..CovidDeaths dea
JOIN Portfolio_Project..CovidVaccs vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not NULL



SELECT *
FROM PopulationVaccsPercent
