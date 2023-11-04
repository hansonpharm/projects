SELECT *
FROM [dbo].['covid deaths$']
--where continent is NOT NULL
order by 2,3

select *
from [dbo].['covid vaccinations$']
where continent is NOT NULL
order by 2,3

-- Selecting needed data

Select location, date, total_cases, new_cases, total_deaths, population
where continent is NOT NULL
from ['covid deaths$']
order by 1,2

-- Total cases vs Total deaths in Nigeria
-- showing rate of deaths per infected population

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Deathpercent
from ['covid deaths$']
where location like 'Nigeria'
order by 1,2

-- Total cases vs population

Select location, date, total_cases, population, (total_deaths/population)*100 as Infection_rate
from ['covid deaths$']
--where location like 'Nigeria'
order by 1,2

-- countries with highest infection rate compared to population

Select location, population,  MAX(total_cases) as Highest_Infection_count,  MAX((total_cases/population)) *100 as percent_pop_infected
from ['covid deaths$']
Group by location, population
order by percent_pop_infected desc

--  Countries showing highest Death count
Select location,  MAX(total_deaths) as Highest_Death_count
from ['covid deaths$']
where continent is NOT NULL
Group by location
order by Highest_Death_count desc

-- Death count by continent

Select location,  MAX(CAST(total_deaths AS int)) as Total_Death_count
from ['covid deaths$']
where continent = 'Africa'
Group by location
order by Total_Death_count desc

Select continent,  MAX(CAST(total_deaths AS int)) as Total_Death_count
from ['covid deaths$']
where location is not null
Group by continent
order by Total_Death_count desc

select  SUM(new_cases) as total_cases, SUM(CAST(new_deaths AS int)) as total_deaths, 
SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from [dbo].['covid deaths$']
WHERE location like '%Nigeria%'
--where continent is NOT NULL
--GROUP BY date
ORDER BY 1,2


-- vaccinations vs population
--Using CTE
with PopvsVac (continent, location, date, population,new_vaccinations, RollingPeopleVac)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(Convert(numeric, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVac
From [dbo].['covid deaths$'] dea
join [dbo].['covid vaccinations$'] vac
on dea.location = vac.location
and dea.date = vac.date
--where dea.continent is not null
where dea.location = 'Nigeria'
)
Select *, (RollingPeopleVac/population)*100 as PercentVacinated
from PopvsVac

-- total vaccinations by Country
select dea.location,sum(cast(vac.new_vaccinations as numeric)) as total_vaccinations
from [dbo].['covid deaths$'] dea
join [dbo].['covid vaccinations$'] vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--where dea.location = 'Nigeria'
group by dea.location, dea.continent
order by 2 desc


-- Creating views for later visualization

create view vaccinationsbycountry as
(
select dea.location,sum(cast(vac.new_vaccinations as numeric)) as total_vaccinations
from [dbo].['covid deaths$'] dea
join [dbo].['covid vaccinations$'] vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--where dea.location = 'Nigeria'
group by dea.location, dea.continent
--order by 2 desc
)

Select * 
from vaccinationsbycountry