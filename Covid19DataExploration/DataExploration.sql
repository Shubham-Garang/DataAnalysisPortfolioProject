/*
Covid 19 Data Exploration 

Data set Link: https://ourworldindata.org/covid-deaths

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/



SELECT * 
FROM PortfolioProject..CovidDeaths$
Where continent is not null 
order by 3,4


SELECT * 
FROM PortfolioProject..CovidVaccinations$
Where continent is not null
order by 3,4

-- Select Data that we are going to be starting with

SELECT location, date, total_cases, new_cases,total_deaths, population
FROM PortfolioProject..CovidDeaths$
Where continent is not null
order by 1,2 

-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in INDIA

SELECT location, date, total_cases, total_deaths, ((CAST(total_deaths AS float))/(CAST(total_cases AS float)))*100 as DeathRate
FROM PortfolioProject..CovidDeaths$
where location like 'INDIA' AND continent is not null
order by 1,2 

-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

SELECT location, date, population, total_cases, ((CAST(total_cases AS float))/(population))*100 as InfectedPercentage
FROM PortfolioProject..CovidDeaths$
where location like 'INDIA' AND continent is not null
order by 1,2 

-- Countries with Highest Infection Rate compared to Population

SELECT location, population, MAX(CAST(total_cases AS INT)) as HighestInfectionCount, MAX(((CAST(total_cases AS float))/(population))*100)
as InfectedPercentage
FROM PortfolioProject..CovidDeaths$
--where location like 'INDIA' AND continent is not null
Group by location,population
order by InfectedPercentage DESC

-- Countries with Highest Death Count per Population

SELECT location, MAX(CAST(total_deaths AS INT)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths$
Where continent is not null
Group by location,population
order by TotalDeathCount DESC

-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

SELECT continent, MAX(CAST(total_deaths AS INT)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths$
Where continent is not null
Group by continent
order by TotalDeathCount DESC

-- GLOBAL NUMBERS

SELECT SUM(new_cases) as Totalcases, SUM(cast(new_deaths as int)) as total_deaths, SUM((CAST(new_deaths AS INT)))/SUM(new_cases)*100 as DeathRate
FROM PortfolioProject..CovidDeaths$
Where continent is not null
--Group by continent
--Group by date
order by 1,2

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location,dea.date) as RollingVaccinationCount
--, (RollingVaccinationCount/population)*100
from PortfolioProject..CovidDeaths$ dea
 join PortfolioProject..CovidVaccinations$ vac
 on dea.location = vac.location
 and dea.date = vac.date
where dea.continent is not null
--and dea.location like 'India'
order by 2,3

-- Using CTE to perform Calculation on Partition By in previous query

with PopvsVac (continent, location, date, Population, New_vaccination, RollingVaccinationCount)
as
(
select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location,dea.date) as RollingvaccinationCount
--, (RollingVaccinationCount/population)*100
from PortfolioProject..CovidDeaths$ dea
 join PortfolioProject..CovidVaccinations$ vac
 on dea.location = vac.location
 and dea.date = vac.date
where dea.continent is not null
--and dea.location like 'India'
--order by 2,3
)
select *, (RollingVaccinationCount/population)*100
from PopvsVac

-- Using Temp Table to perform Calculation on Partition By in previous query


DROP TABLE if EXISTS #PercentPopulationvaccinated
Create Table #PercentPopulationvaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_Vaccinations numeric,
RollingVaccinationCount numeric
)
Insert Into #PercentPopulationvaccinated
select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location,dea.date) as RollingvaccinationCount
--, (RollingVaccinationCount/population)*100
from PortfolioProject..CovidDeaths$ dea
 join PortfolioProject..CovidVaccinations$ vac
 on dea.location = vac.location
 and dea.date = vac.date
where dea.continent is not null
--and dea.location like 'India'
--order by 2,3


select *, (RollingVaccinationCount/population)*100
from #PercentPopulationvaccinated


-- Creating View to store data for later visualizations



Create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location,dea.date) as RollingvaccinationCount
--, (RollingVaccinationCount/population)*100
from PortfolioProject..CovidDeaths$ dea
 join PortfolioProject..CovidVaccinations$ vac
 on dea.location = vac.location
 and dea.date = vac.date
where dea.continent is not null
--and dea.location like 'India'
--order by 2,3

select *
From PercentPopulationVaccinated