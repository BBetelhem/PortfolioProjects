select * 
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4 

--select * 
--from PortfolioProject..CovidVaccinations
--order by 3,4 

select location, date, total_cases, new_cases, total_deaths, population 
from PortfolioProject..CovidDeaths
where continent is not null
order by 1, 2 


-- Total cases vs. Total deaths 
-- 
select location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%states%'
and continent is not null
order by 1, 2 


-- Total cases vs. Population
-- Shows percentage of population got covid, first in the United States

select location, date, population, total_cases, (total_cases/population) * 100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%states%'
order by 1, 2 

select location, date, population, total_cases, (total_cases/population) * 100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
order by 1, 2 


-- Countries with Highest Infection Rate compared to Population

select location, population, Max(total_cases) as HighestInfectionCount, Max((total_cases/population)) * 100 as 
PercentPopulationInfected
from PortfolioProject..CovidDeaths
-- where location like '%states%'
Group by location, population 
order by PercentPopulationInfected desc

-- Countries with Highest Death Count per Population 

select location, Max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
-- where location like '%states%'
where continent is not null
Group by location
order by TotalDeathCount desc


-- Breaking things down by Continents 

-- Continents with the highest death count per population 

select continent, Max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
-- where location like '%states%'
where continent is not null
Group by continent
order by TotalDeathCount desc


select continent, population, Max(total_cases) as HighestInfectionCount, Max((total_cases/population)) * 100 as 
PercentPopulationInfected
from PortfolioProject..CovidDeaths
-- where location like '%states%'
Group by continent, population 
order by PercentPopulationInfected desc



-- Global numbers 

select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast
(new_deaths as int))/sum (new_cases)* 100 as DeathPercentage
From PortfolioProject..CovidDeaths
-- Where location like '%states%' 
where continent is not null 
group by date
order by 1, 2


-- Total Population vs. Vaccincations 

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinate
	, (RollingPeopleVaccinate)/population) * 100
	-- sum(convert(int, vac.new_vaccinations)) over (partition by dea.location)
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac 
	on dea.location = vac.location
	and dea.date = vac.date 
where dea.continent is not null 
order by 2, 3


-- use CTE 

with PopvsVac (continent, location, date, population, new_vaccinations, rollingpeoplevaccinated)
as 
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinate
	--, (RollingPeopleVaccinate)/population) * 100
	-- sum(convert(int, vac.new_vaccinations)) over (partition by dea.location)
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac 
	on dea.location = vac.location
	and dea.date = vac.date 
where dea.continent is not null 
-- order by 2, 3 
)

select *, (rollingpeoplevaccinated/population) *100
from popvsvac 

-- Temp Table 

Drop table if exists #PercentPopulationsVaccinated
Create table #PercentPopulationsVaccinated 
(
Continent nvarchar(255), 
Location nvarchar(255), 
Date datetime , 
Population numeric, 
New_Vaccinations numeric, 
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationsVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinate
	--, (RollingPeopleVaccinate)/population) * 100
	-- sum(convert(int, vac.new_vaccinations)) over (partition by dea.location)
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac 
	on dea.location = vac.location
	and dea.date = vac.date 
-- where dea.continent is not null 
-- order by 2, 3 

select *, (rollingpeoplevaccinated/population) *100
from #PercentPopulationsVaccinated 

-- Creating view to store data for later visualizations 

create view PercentPopulationsVaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinate
	--, (RollingPeopleVaccinate)/population) * 100
	-- sum(convert(int, vac.new_vaccinations)) over (partition by dea.location)
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac 
	on dea.location = vac.location
	and dea.date = vac.date 
where dea.continent is not null 
-- order by 2, 3 

Select * 
From PercentPopulationVaccinated