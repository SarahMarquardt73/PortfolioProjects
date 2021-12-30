SELECT *
FROM 
	PortfolioProject1.DBO.Covid_Deaths$
	WHERE continent is not null
	ORDER BY 3,4

--SELECT *
--FROM 
--	PortfolioProject1.DBO.Covid_Vaccinations$
--	ORDER BY 3,4

--Select data that we are going to be using

SELECT 
	Location, date, total_cases, new_cases, total_deaths, population
FROM 
	PortfolioProject1.DBO.Covid_Deaths$
		ORDER BY 1,2

-- Looking at total cases versus total deaths
SELECT 
	Location, date, total_cases, total_deaths, 
	(total_deaths/total_cases)*100 AS DeathPercentage
FROM 
	PortfolioProject1.DBO.Covid_Deaths$
WHERE 
	Location like '%states%'
		ORDER BY 1,2
	

-- Looking at total cases vs. population (Infection rate)
-- Shows what percentage of the population got Covid
SELECT 
	Location, date, population, total_cases,  
	(total_cases/population)*100 AS InfectionRate
FROM 
	PortfolioProject1.DBO.Covid_Deaths$
WHERE 
	Location like '%states%'
		ORDER BY 1,2


--Looking at Countries with the highest infection rate compared to population
SELECT 
	Location, population, 
	MAX(total_cases) AS HighestInfectionCount, 
	MAX((total_cases/population))*100 AS  PercentPopulationInfected 
FROM 
	PortfolioProject1.DBO.Covid_Deaths$
--WHERE Location like '%states%'
	Group by location, population
		ORDER BY PercentPopulationInfected DESC


--Showing countries with the highest death count per population
SELECT 
	location, Max(cast(total_deaths as int)) AS TotalDeathCount
FROM 
	PortfolioProject1.DBO.Covid_Deaths$
--WHERE Location like '%states%'
WHERE continent is not null
	Group by location
		ORDER BY TotalDeathCount DESC


--Break down by continent
-- Showing the continents with the highest death count 
SELECT 
	continent, Max(cast(total_deaths as int)) AS TotalDeathCount
FROM 
	PortfolioProject1.DBO.Covid_Deaths$
--WHERE Location like '%states%'
WHERE continent is not null
	Group by continent
		ORDER BY TotalDeathCount DESC


-- Global numbers
SELECT 
	date, SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
FROM 
	PortfolioProject1.DBO.Covid_Deaths$
--WHERE Location like '%states%'
WHERE continent is not null
GROUP BY date
		ORDER BY 1,2


-- Global numbers without date
SELECT 
	SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
FROM 
	PortfolioProject1.DBO.Covid_Deaths$
--WHERE Location like '%states%'
WHERE continent is not null
--GROUP BY date

--MOVING ON TO VACCINATION RATES

--Looking at total population vs. vaccination
Select 
dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated

FROM PortfolioProject1.DBO.Covid_Deaths$ dea
Join PortfolioProject1.DBO.Covid_Vaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	order by 2,3


	--USE CTE 
	--USE CTE WHEN DOING FURTHER CALCULATIONS WITH  `ROLLINGPEOPLEVACCINATED` COLUMN

	With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
	as
	(
Select 
dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated

FROM PortfolioProject1.DBO.Covid_Deaths$ dea
Join PortfolioProject1.DBO.Covid_Vaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	--order by 2,3
	)
	Select *, (RollingPeopleVaccinated/Population)*100
	From PopvsVac

--TEMP TABLE
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)


Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated

FROM PortfolioProject1.DBO.Covid_Deaths$ dea
Join PortfolioProject1.DBO.Covid_Vaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	--order by 2,3

	Select *, (RollingPeopleVaccinated/Population)*100
	From #PercentPopulationVaccinated



	---CREATING VIEW TO STORE DATA FOR LATER VISUALIZATIONS
	Create View PercentPopulationVaccinated2 as 
	Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated

FROM PortfolioProject1.DBO.Covid_Deaths$ dea
Join PortfolioProject1.DBO.Covid_Vaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	--order by 2,3

