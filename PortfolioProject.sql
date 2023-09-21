use [Portfolio project]
select * from CovidDeaths$ order by 3,4
select * from Covidvaccinations$ order by 3,4
select location,date,total_cases,new_cases,total_deaths,population from CovidDeaths$ order by 1,2
-- looking at total cases vs total deaths

select location,date,total_cases,new_cases,total_deaths,(total_deaths/total_cases)*100 as deathpercentage
from CovidDeaths$  where location like '%india%' order by 1,2

-- looking at total_cases vs population

select location,date,total_cases,new_cases,population,(total_cases/population)*100 as deathpercentage
from CovidDeaths$  where location like'%india%' order by 1,2

-- looking at countries with highest infection rate compared to population

select location,population,max(total_cases) as highestinfectioncount,max((total_cases/population))*100 as percentpopulatedinfected from 
CovidDeaths$ group by location,
population order by percentpopulatedinfected

select location,max(cast(total_deaths as int)) CovidDeaths$ where location is not null 

select location,population,max(total_cases) as highestinfactcount,max(total_cases/population)*100 as percentpopulatedinfected from CovidDeaths$ 
group by population 
order by percentpopulatedinfected desc

--showing countries with highest death count population

select location,max(total_deaths) as totaldeathcount from CovidDeaths$ 
group by location 
order by totaldeathcount desc

-- let's break things by continent

-- showing the continent with highest death count per population

select continent,max(cast(total_deaths as int))as totaldeathcount from CovidDeaths$ where continent is  null
group by continent 
order by totaldeathcount desc

select continent from CovidDeaths$


-- global numbers

select sum(new_cases) as total_cases,sum(cast(new_deaths as int)) as total_deaths,sum(cast(new_deaths as int))/sum(new_cases)*100 as deathpercentage 

	-- new_cases,population,(total_cases/population)*100 as deathpercentage 
from CovidDeaths$ where 
continent is not null --group by date
order by 1,2

-- looking at total population vs vaccinations
-- use cte
with popvsvac (continent,location,date,population,new_vaccinations,rollingpeoplevaccinated) as
(
select dea.continent,dea.location,dea.date,dea.population,dea.new_vaccinations,sum(convert(int,vac.new_vaccinations)) 
over (partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated
from CovidDeaths$ dea join Covidvaccinations$ vac on dea.location=vac.location and dea.date=vac.date where dea.continent is not null --order by 1,2
)
select *, (rollingpeoplevaccinated/population)*100 from popvsvac

-- temp table
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

drop table #PercentPopulationVaccinated

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths$ dea
Join Covidvaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
select *, (rollingpeoplevaccinated/population)*100 from #percentpopulationvaccinated

-- creating view to store data for later visuaization

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths$ dea
Join Covidvaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

select * from PercentPopulationVaccinated
