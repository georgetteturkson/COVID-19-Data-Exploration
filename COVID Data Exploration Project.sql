/*
--COVID-19 Data Exploration 
--Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

--dataset

Select *
from [Portfolio Project ]..CovidDeaths
where continent is not null
order by 3,4



--Data to begin exploration
Select location, date,total_cases, new_cases, total_deaths, population
from [Portfolio Project ]..CovidDeaths
where continent is not null
order by 1,2


--LOOKING AT TOTAL CASES VS DEATH 

--finding the date on which the probability of dying was the highest if you contract covid in your the United States of America
Select location, date,total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from [Portfolio Project ]..CovidDeaths
where location like '%states%'
order by 5 DESC


--LOOKING AT TOTAL CASES VS THE POPULATION

--The country with the highest infection rate 
Select location, date,total_cases, population, (total_cases/population)*100 as InfectionRate
from [Portfolio Project ]..CovidDeaths
order by 5 desc

--Looking at countries with highest death count per population 
select location, MAX(cast(total_deaths as bigint)) as TotalDeathCount
from [Portfolio Project ] ..CovidDeaths
where continent is not null
Group by location, population
order by 2 desc


--BREAK THINGS BY CONTINENT

--showing continents with highest death count 

Select continent, MAX(Cast(total_deaths as bigint)) as TotalDeathCount
From [Portfolio Project ]..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc

--Global number

select date, SUM( new_cases)as total_cases,  SUM(cast( new_deaths as bigint)) as total_deaths, SUM(cast(New_deaths as bigint))/SUM(New_Cases)*100 as DeathPercentage
From [Portfolio Project ]..CovidDeaths
where continent is not null 
Group by date
Order by 1,2


--The date on which the first case of COVID-19 was reported globally?
select date,SUM( new_cases)as total_cases
from [Portfolio Project ]..CovidDeaths
where 
continent is not null
and total_cases is not null
group by date
order by 2 asc

--The total number of  cases globally 

select SUM( new_cases)as total_cases, SUM(cast(new_deaths as bigint)) as total_deaths, SUM(cast(New_deaths as bigint))/SUM(New_Cases)*100 as DeathPercentage
From [Portfolio Project ]..CovidDeaths
where continent is not null 
Order by 1,2

--LOOKING AT TOTAL POPULATION VS VACCINATION

--which country was the first to begin vaccinations?
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from [Portfolio Project ]..CovidDeaths dea
Join [Portfolio Project ]..CovidVaccinations vac
     On dea.location = vac.location
	 and dea.date = vac.date
where 
dea.continent is not null 
and vac.new_vaccinations is not null
order by 3

--Rolling Number of People Vaccinated 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingNumberOfPeopleVaccinated
From [Portfolio Project ]..CovidDeaths dea
Join [Portfolio Project ]..CovidVaccinations vac
     On dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null 
order by 3 

--Using CTE to accomodate new column and find percentage of population vaccinated 
with PopsvsVac (Continent, location, date, population,new_vaccinations, RollingNumberofPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingNumberOfPeopleVaccinated
From [Portfolio Project ]..CovidDeaths dea
Join [Portfolio Project ]..CovidVaccinations vac
     On dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
select*, (RollingNumberofPeopleVaccinated/population)*100 as PercentPopulationVaccinated 
from PopsvsVac

--Creating View to store data for later visaulisations 

Create View PercentPopulationVaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingNumberOfPeopleVaccinated
From [Portfolio Project ]..CovidDeaths dea
Join [Portfolio Project ]..CovidVaccinations vac
     On dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null 
--order by 2,3 

Select*
From PercentPopulationVaccinated


