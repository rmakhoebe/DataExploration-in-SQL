
SELECT location,date,population,new_cases,total_cases,total_deaths
FROM CovidDeaths
ORDER BY 1,2;

--Look at Total Cases vs Total Deaths
SELECT location, date, total_cases,total_deaths, (CAST(total_deaths as float)/CAST(total_cases as float))*100 as DeathPercentage
FROM CovidDeaths
ORDER BY 1,2;

--Look at Total Cases vs Population of a country
SELECT continent, location, date,population, total_cases,(total_cases/population)*100 as InfectionPercentage
FROM CovidDeaths;

--What Country has the highest infection compared to its population
SELECT location,population, MAX(CAST(total_cases as float)) as HighestInfectionCount, MAX((total_cases/population))*100 as HighestInfectionPercentage
FROM CovidDeaths
WHERE Continent is not NULL
GROUP BY location, population
ORDER BY HighestInfectionPercentage DESC;

--Showing Countries with highest death count compared to its population

SELECT location, population, MAX(CAST(total_deaths as INT)) as HighestDeathCount
FROM CovidDeaths
WHERE continent is not NULL
GROUP BY location,population
ORDER BY HighestDeathCount DESC;


--SHOWING CONTINENTS WITH THE HIGHEST DEATH COUNT
SELECT continent, MAX(CAST(total_deaths as INT)) as HighestDeathCount
FROM CovidDeaths
--WHERE continent is NOT NULL
GROUP BY continent
ORDER BY HighestDeathCount DESC;

--GLOBAL COVID CASES FOR A PARTICULAR DAY
SELECT date,SUM(CAST(new_cases as float)) as TotalNewCases
,SUM(CAST(total_cases as float)) as TotalCases
,SUM(CAST(new_deaths as float)) as NewDeaths
,SUM(CAST(total_deaths as float)) as TotalDeaths, (SUM(CAST(total_deaths as float))/SUM(CAST(total_cases as float)))*100 as DailyDeathPercentage
FROM SQLTutorial2.dbo.Deaths
WHERE continent is not NULL
GROUP BY date
ORDER BY 1; 

--TOTAL GLOBAL COVID STATS
SELECT SUM(new_cases) as TotalCases, SUM(new_deaths) as TotalDeaths, (SUM(new_deaths)/SUM(new_cases))*100 as GlobalDeathPercentage
FROM CovidDeaths
WHERE continent is not NULL;


--LOOKING AT TOTAL COUNTRY VACCINATIONS VS COUNTRY POPULATION USING CTE

WITH VaccinatedPeople (continent, location, date,population, new_vaccinations, RollingPeopleVaccinated) 
as (
	SELECT Dea.continent, Dea.location, Dea.date, Dea.population, vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) as RollingPeopleVaccinated
	FROM CovidDeaths as Dea
	JOIN CovidVaccinations as Vac
	ON Dea.location = Vac.location
	AND Dea.date = Vac.date
	WHERE Dea.continent is NOT NULL
	)

	SELECT*, (RollingPeopleVaccinated/population)*100 as VaccinatedPercentage
	FROM VaccinatedPeople;



--LOOKING AT TOTAL COUNTRY VACCINATIONS VS COUNTRY POPULATION USING TEMP TABLE

DROP TABLE if exists #VaccinatedStats
CREATE TABLE #VaccinatedStats
(
	continent nvarchar(255),
	location nvarchar(255),
	date DATE,
	population NUMERIC,
	new_vaccinations NUMERIC,
	RollingPeopleVaccinated NUMERIC
	)

	INSERT INTO #VaccinatedStats
			SELECT Dea.continent, Dea.location, Dea.date, Dea.population, vac.new_vaccinations,
			SUM(CAST(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) as RollingPeopleVaccinated
			FROM CovidDeaths as Dea
			JOIN CovidVaccinations as Vac
			ON Dea.location = Vac.location
			AND Dea.date = Vac.date
			WHERE Dea.continent is NOT NULL

SELECT*, (RollingPeopleVaccinated/population) as VaccinationPercentage
FROM #VaccinatedStats


--Creating a view to store data for later visualizations

CREATE View VaccinationPercentage as
	SELECT Dea.continent, Dea.location, Dea.date, Dea.population, vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) as RollingPeopleVaccinated
	FROM CovidDeaths as Dea
	JOIN CovidVaccinations as Vac
	ON Dea.location = Vac.location
	AND Dea.date = Vac.date
	WHERE Dea.continent is NOT NULL

	SELECT*
	FROM VaccinationPercentage