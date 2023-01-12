select *
from Project_covid..coviddeaths
order by 3,4

Select * from Project_covid..covidvac
order by 3,4

select location, date, total_cases, new_cases, total_deaths, Population
from Project_covid..coviddeaths order by 1,2

-- I remove the null values becaue I found duplicate dates with nulls entery in every columsns

select location, date, total_cases, new_cases, total_deaths, Population from coviddeaths
where population is not null
order by 1,2

--Looking at total cases vs Total Deaths 

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_percentage from coviddeaths
where population is not null 
order by 1,2

--Filter India's death % (Thing to remember - put inverted comma and like in string )

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_percentage from coviddeaths
where population is not null 
AND location like 'India'  
order by 1,2

--what % of popoulation got covid - total cases vs population
select location, date, total_cases, population, (total_cases/population)*100 as Infected from coviddeaths
where population is not null 
order by 1,2

--Looking at cuntries with Highest infection rate compared to population
select location,MAX (total_cases) as Highestinfectioncount, population, MAX((total_cases/population))*100 as Infected_Rate from coviddeaths
where population is not null
Group by location, population
order by Infected_Rate desc

--Countries with highest death counts
select location, MAX(cast(total_deaths as int)) as totaldeathscount 
from coviddeaths
where continent is not null
Group by location
order by totaldeathscount desc

--BREAK BY CONTINENT
select continent, MAX(cast(total_deaths as int)) as totaldeathscount 
from coviddeaths
where continent is not null
Group by continent
order by totaldeathscount desc

--GLOBAL NUMBERS
select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths,  SUM(cast(new_deaths as int))/SUM(new_cases)*100 as Deathpercentage
from coviddeaths
where continent is not null
Group by date
order by 1,2

--JOINING TWO TABLES

select *
from coviddeaths dea
join covidvac vac
on dea.location = vac.location
and dea.date = vac.date

--Total population vs Vaccination
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from coviddeaths dea
join covidvac vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
and dea.population is not null
order by 2,3

--Rolling count
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) Over (Partition by dea.location order by dea.location, dea.date) as Rolling_count
from coviddeaths dea
join covidvac vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
and dea.population is not null
order by 2,3

--ROLLING_COUNT / POPULATION * 100 BY CTE

with popvsvac (continent, locatio, date, population, new_vaccinations, Rolling_count)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) Over (Partition by dea.location order by dea.location, dea.date) as Rolling_count
from coviddeaths dea
join covidvac vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
and dea.population is not null
)
Select *, (Rolling_count/population)*100 as Rollinh_percentage from popvsvac
order by 2,3

--Creating View to store data for later visulations

 Create view popvsvac as
 select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) Over (Partition by dea.location order by dea.location, dea.date) as Rolling_count
from coviddeaths dea
join covidvac vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
and dea.population is not null
