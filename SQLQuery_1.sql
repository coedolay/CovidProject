Select location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths
ORDER BY 1,2;

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in USA
SELECT location, date, total_cases, total_deaths, (total_deaths*1.0/total_cases*1.0)*100 as DeathPercentage
from CovidDeaths
where location like '%states%'
order by 1,2


-- Looking at Total Cases vs Population

SELECT location, date, population, total_cases, (total_cases*1.0/population)*100 as PercentPopulationInfected
from CovidDeaths
--Where location like '%states%'
order by 1,2


-- Looking at Countries with Highest Infection Rate compared to Population

SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases*1.0/population))*100 as PercentPopulation
from CovidDeaths
--Where location like '%states%'
group by location, population
order by PercentPopulation DESC


--Showing Countries with Highest Death Count per Population

SELECT location, MAX(total_deaths) as TotalDeathCount
from CovidDeaths
--Where location like '%states%'
where continent is NOT NULL
group by location
order by TotalDeathCount DESC


-- Breaking down by continent per total death count

SELECT continent, MAX(total_deaths) as TotalDeathCount
from CovidDeaths
where continent is not NULL
group by continent
order by TotalDeathCount DESC


-- Highest death each continent had 
SELECT continent, MAX(total_deaths) as TotalDeathCount
from CovidDeaths
where continent is not NULL
group by continent
order by TotalDeathCount DESC


-- Global numbers of total deaths
select SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(new_cases)*100 as DeathPercentage
FROM CovidDeaths
where continent is not NULL
ORDER by 1,2


-- Looking at Total Population VS Vaccination

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (PARTITION by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM CovidDeaths dea 
JOIN CovidVaccinations vac
    on dea.location = vac.location
    and dea.date = vac.date
WHERE dea.continent is not NULL
order by 2,3


-- USE CTE
with PopvsVac (continent, location, Date, Population, New_Vaccinations, RollingPeopleVaccinated )
AS
(
SELECT dea.continent, dea.location, dea.Date, dea.Population, cast(vac.new_vaccinations as int)
, SUM(Convert(int,vac.new_vaccinations)) OVER (PARTITION by dea.location order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM CovidDeaths dea 
JOIN CovidVaccinations vac
    on dea.location = vac.location
    and dea.date = vac.date
WHERE dea.continent is not NULL
--order by 2,3
)
SELECT *, (RollingPeopleVaccinated*1.0/Population*1.0)*100
FROM PopvsVac


-- Temp Table
DROP TABLE if EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent NVARCHAR(255),
Location NVARCHAR(255),
Date datetime,
Population NUMERIC,
New_vaccinations NUMERIC,
RollingPeopleVaccinated NUMERIC
)
Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.Date, dea.Population, cast(vac.new_vaccinations as int)
, SUM(Convert(int,vac.new_vaccinations)) OVER (PARTITION by dea.location order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM CovidDeaths dea 
JOIN CovidVaccinations vac
    on dea.location = vac.location
    and dea.date = vac.date
--WHERE dea.continent is not NULL
--order by 2,3

SELECT *, (RollingPeopleVaccinated*1.0/Population*1.0)*100
FROM #PercentPopulationVaccinated


--Creating View to store data for later visualizations
GO
Create View Vaccinated AS 
SELECT dea.continent, dea.location, dea.date, dea.Population, cast(vac.new_vaccinations as int) as New_vac
, SUM(Convert(int,vac.new_vaccinations)) OVER (PARTITION by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM CovidDeaths dea 
JOIN CovidVaccinations vac
    on dea.location = vac.location
    and dea.date = vac.date
WHERE dea.continent is not NULL
Go

SELECT * from Vaccinated
