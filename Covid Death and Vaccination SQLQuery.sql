Select * 
From PortfolioProject..CovidDeaths$
order by 3,4

--Select * 
--From PortfolioProject..CovidVaccinations$
--order by 3,4

select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths$
order by 1, 2

--Looking at total cases vs total deaths
Select Location,date,total_cases,total_deaths,
(total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
where Location Like '%states%'
Order by 1, 2

--Looking at total cases vs Population
--shows what percentage of population got covid
Select Location,date,total_cases,population,
(total_cases/population)*100 as PercentPopulationinfected
From PortfolioProject..CovidDeaths$
Where Location Like '%states%'
Order by 1, 2

--Looking at countries with infection rate compared to population
Select Location,population,
Max(total_cases) as HighestInfectionRate,
Max((total_cases/population))*100 as PercentPopulationinfected
From PortfolioProject..CovidDeaths$
Group by Location,population
Order by PercentPopulationinfected desc

Select * 
From PortfolioProject..CovidDeaths$
Where continent is not NULL
order by 3,4

--Showing countries with highest death count per population
Select Location,
Max(cast(total_deaths as int)) as HighestDeathCount
--Max((total_deaths/population))*100 as PercentPopulationdeathRate
From PortfolioProject..CovidDeaths$
Where continent is not NULL
Group by Location
Order by HighestDeathCount desc

--Lets's break thing down by continent
Select continent,
Max(cast(total_deaths as int)) as HighestDeathCount
--Max((total_deaths/population))*100 as PercentPopulationdeathRate
From PortfolioProject..CovidDeaths$
Where continent is not NULL
Group by continent
Order by HighestDeathCount desc

--Global Numbers
Select --date, 
Sum(new_cases) as Total_cases, 
Sum(cast(new_deaths as int)) as Total_deaths
From PortfolioProject..CovidDeaths$
Where continent is not NULL
--Group by date
Order by 1,2

--Covid Vaccination Table

Select * 
From PortfolioProject..CovidDeaths$ dea join 
PortfolioProject..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date

--Looking at total Population Vs Vaccination

Select dea.continent,dea.location,dea.population,dea.continent,
vac.new_vaccinations
From PortfolioProject..CovidDeaths$ dea join 
PortfolioProject..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not NULL
Order by 2,3

--Rolling people vaccinated
Select dea.continent,dea.location,dea.population,dea.continent,
Sum(Convert(int,vac.new_vaccinations)) Over (partition by dea.location
Order by dea.location,dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea join 
PortfolioProject..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not NULL
Order by 2,3

--Using CTE
With PopVsVac (Continent,Location,Date,Population,RollingPeopleVaccinated,New_vaccinations)
as
(
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
Sum(Convert(int,vac.new_vaccinations)) Over (partition by dea.location
Order by dea.location,dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea join 
PortfolioProject..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not NULL
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopVsVac

--TEMP Table
Create Table #PercentPopulationVaccinated
(
 Continent varchar(255),
 Location varchar(255),
 Date datetime,
 population numeric,
 New_Vaccination numeric,
 RollingPeopleVaccinated numeric
)
Insert Into #PercentPopulationVaccinated
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
Sum(Convert(int,vac.new_vaccinations)) Over (partition by dea.location
Order by dea.location,dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea join 
PortfolioProject..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not NULL

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

--Creating view to store data for later visualization

Create View PercentPopulationVaccinated as
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
Sum(Convert(int,vac.new_vaccinations)) Over (partition by dea.location
Order by dea.location,dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea join 
PortfolioProject..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not NULL

Select * 
From PercentPopulationVaccinated