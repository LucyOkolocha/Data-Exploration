Select *
From SQL_Portfolio_Project..Covid_Deaths$
order by 3,4

Select *
From SQL_Portfolio_Project..Covid_Vaccines$

-- To select the data to use

Select Location, Date, Total_cases, New_cases, Total_deaths, Population
From SQL_Portfolio_Project..Covid_Deaths$
order by 1,2


-- Total Cases vs Total Deaths
-- Shows the likelihood of dying if you contract covid in your country

Select Location, Date, total_cases, total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage
From SQL_Portfolio_Project..Covid_Deaths$
Where location = 'Africa'
Order by 1,2


-- Total Cases vs Population
-- Shows what percentage of population got covid

Select Location, Date, population, total_cases, (total_cases/population) * 100 as PercentPopulationInfected
From SQL_Portfolio_Project..Covid_Deaths$
--Where location = 'Africa'
Order by 1,2

-- Countries with highest Infection Rate compared to Population

Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX(total_deaths/total_cases) * 100 as PercentPopulationInfected
From SQL_Portfolio_Project..Covid_Deaths$
--Where location = 'Africa'
Group by Location, Population
Order by PercentPopulationInfected desc

-- Countries with Highest Death Count per Population

Select Location, MAX(CAST(total_deaths as int)) as TotalDeathCount
From SQL_Portfolio_Project..Covid_Deaths$
--Where location = 'Africa'
Where continent IS NOT NULL
Group by Location
Order by TotalDeathCount desc


-- LET'S BREAK THINGS DOWN BY CONTINENT
-- Showing continents with the highest death count per population

Select continent, MAX(CAST(total_deaths as int)) as TotalDeathCount
From SQL_Portfolio_Project..Covid_Deaths$
--Where location = 'Africa'
Where continent IS NOT NULL
Group by continent
Order by TotalDeathCount desc

-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int)) / SUM (new_cases) * 100 as DeathPercentage
From SQL_Portfolio_Project..Covid_Deaths$
Where continent IS NOT NULL
--Group by Date
Order by 1,2


-- Join both tables

Select *
From SQL_Portfolio_Project..Covid_Deaths$ dea
Join SQL_Portfolio_Project..Covid_Vaccines$ vac
	On dea.location = vac.location
	and dea.date = vac.date


-- Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From SQL_Portfolio_Project..Covid_Deaths$ dea
Join SQL_Portfolio_Project..Covid_Vaccines$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent IS NOT NULL
order by 2, 3


-- Partition 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From SQL_Portfolio_Project..Covid_Deaths$ dea
Join SQL_Portfolio_Project..Covid_Vaccines$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent IS NOT NULL
Order by 2, 3

-- Use CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From SQL_Portfolio_Project..Covid_Deaths$ dea
Join SQL_Portfolio_Project..Covid_Vaccines$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent IS NOT NULL
--Order by 2, 3
)
Select *, (RollingPeopleVaccinated / Population) * 100
From PopvsVac


-- TEMP TABLE

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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From SQL_Portfolio_Project..Covid_Deaths$ dea
Join SQL_Portfolio_Project..Covid_Vaccines$ vac
	On dea.location = vac.location
	and dea.date = vac.date


Select *, (RollingPeopleVaccinated/Population) * 100
From #PercentPopulationVaccinated

-- Creating Views to store data  for later visualizations


Create View PercentPopulationVaccinate as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(Bigint, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From SQL_Portfolio_Project..Covid_Deaths$ dea
Join SQL_Portfolio_Project..Covid_Vaccines$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent IS NOT NULL


 Select *
 From PercentPopVaccinated


CREATE VIEW PopulationVsVaccinated as
Select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations
,SUM(CONVERT (Bigint, vac.new_vaccinations)) Over (Partition by dea.location Order by dea.location
,dea.date) as RollingPeepsVaccinated
From [Project Portfolio 2]..CovidDeaths as dea
Join [Project Portfolio 2]..CovidVaccinations as vac
     On dea.location = vac.location
	 and dea.date = vac.date
Where dea.continent is not null

Select *
From PopulationVsVaccinated


CREATE VIEW GlobalDeathsCaseCount as
Select date, Sum(new_cases) as total_cases,  Sum(CONVERT(Bigint,new_deaths ))as total_deaths,
    Sum(cast(new_deaths as int))/Sum(new_cases)*100 as
	GlobalDeathPercentage
From [Project Portfolio 2]..CovidDeaths
Where continent is not null
Group by date


CREATE VIEW HighestTotalDeathCount as 

Select continent, location, Max(CONVERT(Bigint,Total_deaths)) as TotalDeathCount
From [Project Portfolio 2].dbo.CovidDeaths
Where continent is not null
Group by continent,location


CREATE VIEW TotalCasesUnitedStates as
Select continent location, date, population,total_cases,(total_cases/population)*100 as PercentPopulationInfected
From [Project Portfolio 2].dbo.CovidDeaths
Where location like '%states%'
and continent is not null

CREATE VIEW TotalCasesNigeria as
Select continent, location, date, population,total_cases,(total_cases/population)*100 as PercentPopulationInfected
From [Project Portfolio 2].dbo.CovidDeaths
Where location like '%Nigeria%'
and continent is not nul


CREATE VIEW TotalCasesNigeria as
Select continent, location, date, population,total_cases,(total_cases/population)*100 as PercentPopulationInfected
From [Project Portfolio 2].dbo.CovidDeaths
Where location like '%Nigeria%'
and continent is not null

CREATE VIEW TotalCasesSouthAfrica as
Select continent, location, date, population,total_cases,(total_cases/population)*100 as PercentPopulationInfected
From [Project Portfolio 2].dbo.CovidDeaths
Where location like '%South Africa%'
and continent is not null


CREATE VIEW TotalCasesCanada as
Select continent, location, date, population,total_cases,(total_cases/population)*100 as PercentPopulationInfected
From [Project Portfolio 2].dbo.CovidDeaths
Where location like '%Canada%'
and continent is not null


CREATE VIEW TotalCasesUnitedKingdom as
Select continent, location, date, population,total_cases,(total_cases/population)*100 as PercentPopulationInfected
From [Project Portfolio 2].dbo.CovidDeaths
Where location like '%United Kingdom%'
and continent is not null
