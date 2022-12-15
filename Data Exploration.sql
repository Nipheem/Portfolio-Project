/*
Covid 19 Data Exploration
Skills used: Joins, CTE's, Temp Table,Window Functions, Aggregate Function, Creating Views, Coverting Data Types
*/

SELECT * 
FROM covid_death$
WHERE continent IS NOT NULL
ORDER BY 3,4

--SELECT *
--FROM covid_vaccination$
--ORDER BY 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM covid_death$
WHERE continent IS NOT NULL
ORDER BY 1,2

--Total Cases vs Total Deaths Percentage

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_percentage 
FROM covid_death$
--WHERE location LIKE '%china'
ORDER BY 1,2

--Total Cases vs Total Population

SELECT location, date, population, total_cases, (total_cases/population)*100 AS infected_population_percentage 
FROM covid_death$
--WHERE location LIKE '%china' AND
WHERE continent IS NOT NULL
ORDER BY 1,2

--Countries with Highest Infection Rate Compare to Population

SELECT location, population, MAX(total_cases) AS highest_infection_count, MAX((total_cases/population))*100 AS infected_population_percentage  
FROM covid_death$
--WHERE location LIKE '%china'
GROUP BY location, population
ORDER BY infected_population_percentage DESC

--Countries with Highest Death Count per Population

SELECT location, MAX(CAST(total_deaths as int)) AS total_death_count    
FROM covid_death$
--WHERE location LIKE '%china' AND
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY total_death_count DESC

--Continent with the Highest Deaths Count per Population 

SELECT continent, MAX(CAST(total_deaths as int)) AS total_death_count    
FROM covid_death$
--WHERE location LIKE '%china' AND
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY total_death_count DESC

--Global numbers

SELECT date, SUM(new_cases) AS total_case, SUM(CAST(new_deaths as int)) As total_deaths, SUM(CAST(new_deaths as int))/SUM(new_cases) AS death_percentage 
FROM covid_death$
--WHERE location LIKE '%china'
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

SELECT SUM(new_cases) AS total_case, SUM(CAST(new_deaths as int)) As total_deaths, SUM(CAST(new_deaths as int))/SUM(new_cases) AS death_percentage 
FROM covid_death$
--WHERE location LIKE '%china'
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2

--Total Population vs Vaccination

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION by dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
--(rolling_people_vaccinated/population)*100
FROM covid_death$ dea
INNER JOIN covid_vaccination$ vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

--CTE
WITH popvsvac (continent,location, date, population, new_vacinnation, rolling_people_vaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION by dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
--(rolling_people_vaccinated/population)*100
FROM covid_death$ dea
INNER JOIN covid_vaccination$ vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *,(rolling_people_vaccinated/population)*100
FROM popvsvac

--Temp Table

DROP TABLE IF EXISTS #percentpopulationvaccinated
CREATE TABLE #percentpopulationvaccinated
(
continent nvarchar (255),
location nvarchar (255),
date datetime,
population numeric,
new_vaccinations numeric,
rolling_people_vaccinated numeric
)
INSERT INTO #percentpopulationvaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION by dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
--(rolling_people_vaccinated/population)*100
FROM covid_death$ dea
INNER JOIN covid_vaccination$ vac
ON dea.location = vac.location
AND dea.date = vac.date
--WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
SELECT *,(rolling_people_vaccinated/population)*100
FROM #percentpopulationvaccinated

--Create View For Visualization

CREATE VIEW percentpopulationvaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION by dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
--(rolling_people_vaccinated/population)*100
FROM covid_death$ dea
INNER JOIN covid_vaccination$ vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL









