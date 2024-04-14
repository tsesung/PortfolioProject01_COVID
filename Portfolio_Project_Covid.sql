
select * from CovidDeaths cd 
order by 3,4

select * from CovidVaccinations cv 
order by 3,4


--Data Cleanup
select * from CovidDeaths cd 
--update CovidDeaths set continent = NULL
where continent = ''

select * from CovidVaccinations cv 
--update CovidVaccinations set continent = NULL
where continent = ''


--Select columns to be used
select cd.continent, cd.location, cd.[date], cd.total_cases,  cd.new_cases, cd.total_deaths, cd.population 
from CovidDeaths cd 
order by cd.location, cd.[date] 

--Looking at Total Cases Vs Total Deaths
--Shows likelihood of death if contracting COVID in country
select cd.location, cd.[date], cd.total_cases, cd.total_deaths
, round((cd.total_deaths/cd.total_cases)*100,4) DeathPercentage
from CovidDeaths cd 
where cd.location = 'Malaysia'
order by cd.location, cd.[date] 

--Looking at Total Cases Vs Population
select cd.location, cd.[date], cd.total_cases, cd.population 
, round((cd.total_cases/population)*100,5) PopulationPercentage
from CovidDeaths cd 
where cd.location = 'Malaysia'
order by cd.location, cd.[date] 

--Looking at Countries with Highest Infection Rate Compared to Population
--Filter by Date
select cd.location Location, cd.population Population
, MAX(cd.total_cases) HighestTotalCase
, round(MAX(cd.total_cases/cd.population)*100,4) PercentPopulation
from CovidDeaths cd 
where cd.[date] < '01-01-2024'
group by cd.location, cd.population
order by 4 desc

--Looking at Countries with Highest Death Percentage
select cd.continent, cd.location Location, cd.population 
, MAX(cd.total_deaths) TotalDeath
, round(MAX(cd.total_deaths /cd.population)*100,4) PercentPopulation
from CovidDeaths cd 
where cd.[date] < '01-01-2024'
and (cd.continent is NOT NULL and cd.continent <> '')
and location not in ('World','High income','Upper middle income','Europe','North America','Asia','South America','Lower middle income','European Union')
group by cd.continent, cd.location, cd.population
order by 3 desc

--Total Death Breakdown by Continent
select cd.location Location, MAX(cd.total_deaths) TotalDeathCount 
from CovidDeaths cd 
where (cd.continent is null or cd.continent = '')
group by cd.location 
order by TotalDeathCount desc

--Global Numbers
select sum(cd.new_cases) TotalCases, sum(cd.new_deaths) TotalDeaths, (sum(cd.new_deaths)/sum(cd.new_cases)*100) DeathPercentage
from CovidDeaths cd 
where (cd.continent is not null or cd.continent <> '')
order by 1,2

--Looking at Total Population Vs Vaccinations
select cd.continent, cd.location, cd.[date] , cd.population, cv.new_vaccinations 
, sum(cv.new_vaccinations) over (PARTITION By cd.location order by cd.location, cd.date) as CumulativeTotalVaccinations
from CovidDeaths cd 
join CovidVaccinations cv 
on cd.location = cv.location and cd.[date] = cv.[date] 
where (cd.continent is not null or cd.continent <> '')
and cd.location = 'Canada'
order by 2,3


--Looking at Total Population Vs Vaccinations
--With CTE
WITH PopVsVac (Continent, Location, Date, Population, NewVaccinations, CumulativeTotalVaccinations) as (
	select cd.continent, cd.location, cd.[date] , cd.population, cv.new_vaccinations 
	, sum(cv.new_vaccinations) over (PARTITION By cd.location order by cd.location, cd.date) as CumulativeTotalVaccinations
	from CovidDeaths cd 
	join CovidVaccinations cv 
	on cd.location = cv.location and cd.[date] = cv.[date] 
	where (cd.continent is not null or cd.continent <> '')
--	and cd.location = 'Canada'
)
select Continent, Location, Date, Population, NewVaccinations, CumulativeTotalVaccinations
, ROUND(CumulativeTotalVaccinations / Population * 100, 5) CumulativePercentVaccinations
from PopVsVac pvv


--Looking at Total Population Vs Vaccinations
--With Temp Table
DROP TABLE IF EXISTS #PercentPopulationVaccinated

CREATE TABLE #PercentPopulationVaccinated (
	Continent varchar(50), 
	Location varchar(100), 
	Date datetime, 
	Population numeric, 
	NewVaccinations numeric, 
	CumulativeTotalVaccinations numeric
)

INSERT INTO #PercentPopulationVaccinated 
	select cd.continent, cd.location, cd.[date] , cd.population, cv.new_vaccinations 
	, sum(cv.new_vaccinations) over (PARTITION By cd.location order by cd.location, cd.date) as CumulativeTotalVaccinations
	from CovidDeaths cd 
	join CovidVaccinations cv 
	on cd.location = cv.location and cd.[date] = cv.[date] 
	where (cd.continent is not null or cd.continent <> '')


select Continent, Location, Date, Population, NewVaccinations, CumulativeTotalVaccinations 
, ROUND(CumulativeTotalVaccinations / Population * 100, 5) CumulativePercentVaccinations
from #PercentPopulationVaccinated 
where Location = 'Canada'
order by 1,2,3


--Creating View to store data for later visualizations
DROP VIEW IF EXISTS vPercentPopulationVaccinated 

CREATE VIEW vPercentPopulationVaccinated as
select cd.continent, cd.location, cd.[date] , cd.population, cv.new_vaccinations 
, sum(cv.new_vaccinations) over (PARTITION By cd.location order by cd.location, cd.date) as CumulativeTotalVaccinations
from CovidDeaths cd 
join CovidVaccinations cv 
on cd.location = cv.location and cd.[date] = cv.[date] 
where (cd.continent is not null or cd.continent <> '')

select * from vPercentPopulationVaccinated
order by 2,3



