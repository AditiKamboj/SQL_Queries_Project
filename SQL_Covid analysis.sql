Select * from PortfolioProject..Coviddeaths

Select SUM(new_cases) as total_deaths from PortfolioProject..Coviddeaths Where location like '%states%' 
--where continent is not null 
---Queries used for Tableau Project-------------

-----Query 1 Total no. of deaths during covid according to location-----
Select location, SUM(cast (new_deaths as int)) as TotalDeathCount
From PortfolioProject..Coviddeaths
where continent is null
and location not in ('World', 'European Union', 'International','High income', 'Upper middle income', 'Lower middle income', 'Low income')
Group by location
order by TotalDeathCount desc

-----Query 2 Death percentage by Population-----------
Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..Coviddeaths
where location not in ('World', 'European Union', 'International','High income', 'Upper middle income', 'Lower middle income', 'Low income')
Group by location, population
order by PercentPopulationInfected desc

-----Query 3 Country with highest infection rate-----------
Select Location, population, date, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..Coviddeaths
where location not in ('World', 'European Union', 'International','High income', 'Upper middle income', 'Lower middle income', 'Low income')
Group by location, population, date
order by PercentPopulationInfected desc

-----Query 4 Death Percentage by Population-----
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..Coviddeaths
where continent is not null
order by 1, 2

--------Looking at Total Population vs Vaccination-----------------
Select dea.date, dea.continent, dea.location, vac.new_vaccinations, SUM(Cast(vac.new_vaccinations as BIGINT)) OVER(Partition by dea.location 
Order by dea.location, dea.date) as RollingPeopleVaccinated from PortfolioProject..Coviddeaths dea
Join PortfolioProject..CovidVaccinations vac
On dea.location= vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

------------Use CTE-------------------
With PopVsVac(Continent, location, population, date, RollingPeopleVaccinated, New_Vaccinations)
as(
Select dea.date, dea.population, dea.continent, dea.location, vac.new_vaccinations, SUM(Cast(vac.new_vaccinations as BIGINT)) 
  OVER(Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated from PortfolioProject..Coviddeaths dea
Join PortfolioProject..CovidVaccinations vac
On dea.location= vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/population)* 100 from PopVsVac

-----TEMP Table---------------
Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(Cast(vac.new_vaccinations as BIGINT)) 
OVER(Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated from PortfolioProject..Coviddeaths dea
Join PortfolioProject..CovidVaccinations vac
On dea.location= vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

Select *, (RollingPeopleVaccinated/population)* 100 from #PercentPopulationVaccinated

------------Creating View------------
Create view PercentPopulationVaccinated as
Select dea.date, dea.continent, dea.location, vac.new_vaccinations, SUM(Cast(vac.new_vaccinations as BIGINT)) OVER(Partition by dea.location 
Order by dea.location, dea.date) as RollingPeopleVaccinated from PortfolioProject..Coviddeaths dea
Join PortfolioProject..CovidVaccinations vac
On dea.location= vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select * from PercentPopulationVaccinated
