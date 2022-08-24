Select *
FROM portfolioProject..CovidDeaths
Order BY 3,4

--Select * 
--FROM portfolioProject..CovidVaccinations$
--Order By 3,4

Select Location, date, total_cases, new_cases, total_deaths, population
FROM portfolioProject..CovidDeaths
ORDER BY 1,2

-- Looking at total cases vs total deaths

Select Location, date, total_cases, total_deaths, (Total_deaths/total_cases)*100 as death_percentage
FROM portfolioProject..CovidDeaths
WHERE Location like '%states%'
ORDER BY 1, 2


-- Looking at Total cases vs Population

SELECT Location, date, total_cases, population, (total_cases/population)*100 as cases_per_population_percentage
FROM portfolioProject..CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2

-- Looking at Countries with highest infection rate

SELECT Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as HighestPercentPopinfected
FROM portfolioProject..CovidDeaths
GROUP BY Location, Population
ORDER BY HighestPercentPopinfected DESC

--Showing countries with the Highest Death Count per population

SELECT Location, MAX(cast(total_deaths as int)) as HighestDeathCount
FROM portfolioProject..CovidDeaths
WHERE continent is not null 
GROUP BY Location
ORDER BY HighestDeathCount DESC

--Showing continents with highest death counts per population

SELECT location, MAX(cast(total_deaths as int)) as HighestDeathCount
FROM portfolioProject..CovidDeaths
WHERE continent is null
GROUP BY location 
ORDER BY HighestDeathCount DESC

--Showing the continents with the highest death count

SELECT continent, MAX(cast(total_deaths as int)) as HighestDeathCount
FROM portfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY continent 
ORDER BY HighestDeathCount DESC

--Global numbers
SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_cases)*100 as GlobalDeathPercentage
FROM portfolioProject..CovidDeaths
WHERE Continent is not null
GROUP BY date
ORDER BY 1,2

--Full Join on both tables

SELECT *
FROM portfolioProject..CovidDeaths dea
Join portfolioProject..CovidVaccinations vac
	On dea.Location = vac.location
	and dea.date = vac.date

 --Looking at total population vs vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location ORDER BY dea.location, dea.Date) as RollingPeopleVaccinated
FROM portfolioProject..CovidDeaths dea
Join portfolioProject..CovidVaccinations vac
	On dea.Location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

--USE CTE 
WITH PopVSVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location ORDER BY dea.location, dea.Date) as RollingPeopleVaccinated
FROM portfolioProject..CovidDeaths dea
Join portfolioProject..CovidVaccinations vac
	On dea.Location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopVSVac

--Temp Table
DROP TABLE IF EXISTS #PercentPopulationVaccinated

CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location ORDER BY dea.location, dea.Date) as RollingPeopleVaccinated
FROM portfolioProject..CovidDeaths dea
Join portfolioProject..CovidVaccinations vac
	On dea.Location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated


--Creating View to store data for visualizations
CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location ORDER BY dea.location, dea.Date) as RollingPeopleVaccinated
FROM portfolioProject..CovidDeaths dea
Join portfolioProject..CovidVaccinations vac
	On dea.Location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null

SELECT * 
FROM PercentPopulationVaccinated