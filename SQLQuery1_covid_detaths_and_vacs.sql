/*SELECT *
FROM Portfolio_project..covid_deaths_1
ORDER BY location, date;*/

--SELECT *
--FROM Portfolio_project..covid_vaccinations
--ORDER BY location, date;

--Select for now only the data that we are going to be using

--SELECT location, date, total_cases, new_cases, total_deaths, population
--FROM Portfolio_project..covid_deaths_1
--order by location, date;


--Looking at the total cases vs total deaths


--SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100.0 as death_percentage  
--FROM Portfolio_project..covid_deaths_1
--WHERE location like '%states%'
--ORDER BY location, date;


--Looking at the total cases vs population
--

--SELECT location, date, total_cases, population, (total_cases/population)*100.0 as infected_percentage
--FROM Portfolio_project..covid_deaths_1
--WHERE location like '%states%'
--ORDER BY location, date

--Looking at the countries with highest infectation rate compared to population

--SELECT location, max((total_cases/population)*100.0) as max_total_infected_percentage

--FROM Portfolio_project..covid_deaths_1
--where total_cases is not NULL and location <> 'International'
--group by location
--order by max_total_infected_percentage DESC, location;

--Looking at the average infected total infected per day in the entire dataset

--select date, avg(total_cases) as avg_global_daily_accumulated_cases
--from Portfolio_project..covid_deaths_1
--where total_cases is not NULL and location <> 'International'
--group by date
--order by date;


--Looking for the countries  with the highest accumulated total death percentage respect to their population

--SELECT location, population, MAX(total_deaths) as highest_deaths_count,max((total_deaths/population)*100.0) as max_total_deaths_percentage
--FROM Portfolio_project..covid_deaths_1
--where total_deaths is not NULL and location <> 'International'
--group by location, population
--order by max_total_deaths_percentage DESC, location;


--Showing countries with highest death count per population
--SELECT location, MAX(CAST(total_deaths AS INT)) AS total_death_count
--FROM Portfolio_project..covid_deaths_1
--WHERE total_deaths IS NOT NULL
--GROUP BY location
--ORDER BY total_death_count;



--Same query as the previous one, but for continents 

--SELECT location, MAX(CAST(total_deaths AS INT)) AS total_death_count
--FROM Portfolio_project..covid_deaths_1
--WHERE continent IS NULL
--GROUP BY location
--ORDER BY total_death_count DESC;

SELECT continent, MAX(CAST(total_deaths AS INT)) AS total_death_count
FROM Portfolio_project..covid_deaths_1
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY total_death_count DESC;

--PERU
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100.0 as death_percentage
FROM Portfolio_project..covid_deaths_1
WHERE location = 'Peru' AND continent IS NOT NULL
ORDER BY 1, 2;
--GLOBAL NUMBERS

/*SELECT *
FROM Portfolio_project..covid_vaccinations*/


SELECT date, SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100.0 AS death_percentage 
FROM Portfolio_project..covid_deaths_1
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1, 2;


--Looking at Population vs vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS BIGINT)) 
	OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS total_vaccunated
FROM Portfolio_project..covid_deaths_1 as dea
JOIN Portfolio_project..covid_vaccinations as vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE (dea.continent IS NOT NULL)
ORDER BY 2, 3;

--USE CTE
WITH popvsvac (continent, location, date, population, new_vaccinations, total_vaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS BIGINT)) 
	OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS total_vaccunated
FROM Portfolio_project..covid_deaths_1 as dea
JOIN Portfolio_project..covid_vaccinations as vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE (dea.continent IS NOT NULL)
--ORDER BY 2, 3;
)
SELECT *, (total_vaccinated/population)*100.0 AS total_vac_percentage
FROM popvsvac


--TEMP TABLE

DROP TABLE IF EXISTS #percent_population_vaccinated
CREATE TABLE #percent_population_vaccinated(
continent NVARCHAR(255),
location NVARCHAR(255),
date DATETIME,
population NUMERIC,
new_vaccinations NUMERIC,
total_vaccinated NUMERIC
)

INSERT INTO #percent_population_vaccinated

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS BIGINT)) 
	OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS total_vaccunated
FROM Portfolio_project..covid_deaths_1 as dea
JOIN Portfolio_project..covid_vaccinations as vac
	ON dea.location = vac.location
	AND dea.date = vac.date
--WHERE (dea.continent IS NOT NULL)
--ORDER BY 2, 3;
SELECT *, (total_vaccinated/population)*100.0 AS total_vac_percentage
FROM #percent_population_vaccinated


--Creating a view for latter data visualizations

--DROP VIEW IF EXISTS percent_pop_vacc_view
CREATE VIEW percent_pop_vacc_view_1
AS
	SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations AS BIGINT)) 
		OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS total_vaccunated
	FROM Portfolio_project..covid_deaths_1 as dea
	JOIN Portfolio_project..covid_vaccinations as vac
		ON dea.location = vac.location
		AND dea.date = vac.date
	WHERE (dea.continent IS NOT NULL)
	--ORDER BY 2, 3;
