SELECT *
FROM PortfolioProjects..CovidDeaths
WHERE continent is not null
order by 3,4


--SELECT *
--FROM PortfolioProjects..CovidVaccinations
--order by 3,4

---Select data that to be used

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProjects..CovidDeaths
order by 1,2


-- Total Cases vs Total Deaths
--Likelihood od dying if contracted COVID
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProjects..CovidDeaths
where location like '%Nigeria%'
order by 1,2

--Total Cases vs Population
--Percentage of the population that contacted COVID
SELECT Location, date, population, total_cases, (total_cases/population)*100 asInfectedPercentage
FROM PortfolioProjects..CovidDeaths
--where location like '%Nigeria%'
order by 1, 2


--Countries with highest infection rate
SELECT Location, population, MAX(total_cases) as HighestIfectionCount, MAX((total_cases/population))*100 as 
	InfectedPoplationPercentage
FROM PortfolioProjects..CovidDeaths
--where location like '%Nigeria%'
GROUP BY Location, population
order by InfectedPoplationPercentage


--Countries with the highest death count per population
SELECT Location, MAX(cast(total_deaths as int)) as TotalDeathCount 
FROM PortfolioProjects..CovidDeaths
--where location like '%Nigeria%'
WHERE continent is not null
GROUP BY Location
order by TotalDeathCount DESC


--Continent
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount 
FROM PortfolioProjects..CovidDeaths
--where location like '%Nigeria%'
WHERE continent is not null
GROUP BY continent
order by TotalDeathCount DESC

--Continents with the highest death counts

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount 
FROM PortfolioProjects..CovidDeaths
--where location like '%Nigeria%'
WHERE continent is not null
GROUP BY continent
order by TotalDeathCount DESC

--GLOBAL NUMBERS

SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProjects..CovidDeaths
--where location like '%Nigeria%'
WHERE continent is not null
GROUP BY date
order by 1,2

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProjects..CovidDeaths
--where location like '%Nigeria%'
WHERE continent is not null
--GROUP BY date
order by 1,2


--PORTFOILIO PROJECT COVID VACCINE
SELECT*
FROM PortfolioProjects..CovidDeaths dea
JOIN PortfolioProjects..CovidVaccinations vac
     ON dea.location = vac.location
	 and dea.date = vac.date
	 

--Total population vs Vaccination

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as int)) OVER (partition by dea.location 
	Order by dea.location, dea.date) as RollingPeopleVaccinated,
	(RollingPeopleVaccinated/population)*100	
FROM PortfolioProjects..CovidDeaths dea
JOIN PortfolioProjects..CovidVaccinations vac
     ON dea.location = vac.location
	 and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY  2, 3


--USING CTE

with PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as int)) OVER (partition by dea.location 
	Order by dea.location, dea.date) as RollingPeopleVaccinated
	--,(RollingPeopleVaccinated/population)*100
FROM PortfolioProjects..CovidDeaths dea
JOIN PortfolioProjects..CovidVaccinations vac
     ON dea.location = vac.location
	 and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY  2, 3
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac
--WHERE RollingPeopleVaccinated is not null



--USING TEMP TABLE
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar (255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)


INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as int)) OVER (partition by dea.location 
	Order by dea.location, dea.date) as RollingPeopleVaccinated
	--,(RollingPeopleVaccinated/population)*100
FROM PortfolioProjects..CovidDeaths dea
JOIN PortfolioProjects..CovidVaccinations vac
     ON dea.location = vac.location
	 and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY  2, 3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated


--CREATING VIEW TO STORE DATA FOR LATER VISUALIZATION

Create View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as int)) OVER (partition by dea.location 
	Order by dea.location, dea.date) as RollingPeopleVaccinated
	--,(RollingPeopleVaccinated/population)*100
FROM PortfolioProjects..CovidDeaths dea
JOIN PortfolioProjects..CovidVaccinations vac
     ON dea.location = vac.location
	 and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY  2, 3

Select *
From PercentPopulationVaccinated