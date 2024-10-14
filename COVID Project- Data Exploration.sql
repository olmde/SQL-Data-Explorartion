/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

Select *
From PortfolioProject..CovidDeaths
Where continent is not null 
order by 3,4



-- SELECTING DATA OF USE
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2;



-- COMPARISON OF TOTAL CASES vs. TOTAL DEATHS
-- SHOWS LIKLEKIHOOD OF DYING IF YOU CONTRACT COVID IN YOUR COUNTRY

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%kingdom%' AND continent IS NOT NULL
ORDER BY 1,2;



-- TOTAL CASES vs. POPULATION
-- SHOWS PERCENTAGE OF COUNTRY'S POPULATION INFECTED WITH COVID

SELECT location, date, population, total_cases, (total_cases/population)*100 AS InfectedPopulation
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%kingdom%' AND continent IS NOT NULL
ORDER BY 1,2;




-- ORDERED LIST OF COUNTRIES WITH HIGHEST INFECTIION RATE COMPARED TO POPULATION

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS InfectedPopulation
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY InfectedPopulation DESC;



-- ORDERED LIST OF COUNTRIES WITH HIGHEST DEATH COUNT PER POPULATION

SELECT location, population,  MAX(total_deaths) AS HighestDeathToll, MAX(total_deaths/population)*100 AS DeceasedPopulation
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY  DeceasedPopulation DESC;




-- ANALYSING VIA CONTINENT AS OPPOSED TO COUNTRY
-- ORDERED LIST OF CONTINENTS WITH HIGHEST DEATH COUNT PER POPULATION.

SELECT continent, MAX(total_deaths) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY  TotalDeathCount DESC;



-- GLOBAL NUMBERS PER DAY

SELECT date, SUM(new_cases) AS GlobalCases, SUM(new_deaths) AS GlobalDeaths, SUM(new_deaths)/SUM(new_cases)*100 AS GlobalDeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2


-- GLOBAL CONCURRENT NUMBERS 
SELECT SUM(new_cases) AS GlobalCases, SUM(new_deaths) AS GlobalDeaths, SUM(new_deaths)/SUM(new_cases)*100 AS GlobalDeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2



-- TOTAL POPULATION vs. TOTAL VACCINATION
-- SHOWS PERCENTAGE OF POPULATION THAT HAS RECEIVED AT LEAST ONE COVID VACCINE

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
    ON dea.location= vac.location AND dea.date=vac.date
WHERE dea.Continent IS NOT NULL
ORDER BY 2,3



-- USING CTE TO PERFORM CALCULATION ON PARTITION BY IN PREVIOUS QUERY

WITH PopvsVac (Continent, location, date, population, new_vaccinations,  RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
    ON dea.location= vac.location AND dea.date=vac.date
WHERE dea.Continent IS NOT NULL
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac



-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated



-- CREATING VIEW TO STORE FOR LATER VISUALISATIONS

CREATE VIEW PercentPopulationVaccinated AS 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
    ON dea.location= vac.location AND dea.date=vac.date
WHERE dea.Continent IS NOT NULL

