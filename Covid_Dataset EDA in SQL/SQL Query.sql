

------------------------------------------- Deaths Table --------------------------------------------------

select * 
from CovidDB..Covid_Deaths
where continent is not null
order by 3,4

-- selecting main features 

select location, date,total_cases,new_cases,total_deaths,population
from CovidDB..Covid_Deaths
where continent is not null
order by 1,2

-- Total Cases Vs Total Deaths

select location, date,total_cases,total_deaths,(total_deaths/total_cases)*100 [Cases_Death%]
from CovidDB..Covid_Deaths
where location like '%egyp%' and continent is not null
order by 1,2


-- Total Cases Vs Population 

select location, date,total_cases,population,(total_cases/population)*100 [Population_Death%]
from CovidDB..Covid_Deaths
where location like '%egyp%' and continent is not null
order by 1,2

-- Countries with Highest Infection Rate Compared to Population

select location, total_cases,population,Max((total_cases/population)*100) [Population_Death%]
from CovidDB..Covid_Deaths
where continent is not null
group by location,total_cases,population
order by 4 desc

-- Highest Deaths Count Per Population

select location, Max(cast(total_deaths as int)) [TotalDeathCount]
from CovidDB..Covid_Deaths
where continent is not null
group by location
order by 2 desc

-- Highest Deaths Count Per Continent

select location, Max(cast(total_deaths as int)) [TotalDeathCount]
from CovidDB..Covid_Deaths
where continent is  null
group by location
order by 2 desc

-- Total Cases, Total Deaths per Day Globally

select date, SUM(new_cases) Total_NewCases,
SUM(cast (new_deaths as int)) Total_NewDeaths,
(SUM(cast (new_deaths as int)) /sum(new_cases))*100 [Population_Death%]
from CovidDB..Covid_Deaths
where continent is not null
group by date
order by 2 desc

-- Total Cases, Total Deaths till Now Wroldwide 

select SUM(new_cases) Total_NewCases,
SUM(cast (new_deaths as int)) Total_NewDeaths,
(SUM(cast (new_deaths as int)) /sum(new_cases))*100 [Population_Death%]
from CovidDB..Covid_Deaths
where continent is not null

------------------------------------------- Vaccination Table --------------------------------------------------

-- Total Vaccinated No. Vs Population 

select de.continent, de.location, de.date, de.population, convert (int, va.new_vaccinations) new_vaccinations
from Covid_Deaths de join Covid_Vaccinations va
on de.date = va.date and de.location = va.location 
where de.continent is not null
order by 5 desc

-- Started Vaccination Date Worldwide 

select top (1) new_vaccinations, date, continent, location
from Covid_Vaccinations va
where va.continent is not null
order by 1 desc

-- Adding A Comulative New_Vaccinations Column Partitioned by Location

-- Using CTE

with PopVsVac (continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated) 
as 
(
select de.continent, de.location, de.date, de.population,va.new_vaccinations,
sum (convert (numeric, va.new_vaccinations))
over (partition by de.location order by de.location,de.date) as RollingPeopleVaccinated
from Covid_Deaths de join Covid_Vaccinations va
on de.date = va.date and de.location = va.location 
where de.continent is not null
-- order by 5 desc
)

select *, (RollingPeopleVaccinated/Population)*100 PercentageTotal 
from PopVsVac
order by 7 desc

-- Using Temp Table 

Drop table if exists #OfPopulationVaccinated
create table #OfPopulationVaccinated 
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime, 
Population Numeric,
New_Vaccinations Numeric,
RollingPeopleVaccinated Numeric
)

insert into #OfPopulationVaccinated

select de.continent, de.location, de.date, de.population,va.new_vaccinations,
sum (convert (numeric, va.new_vaccinations))
over (partition by de.location order by de.location,de.date) as RollingPeopleVaccinated
from Covid_Deaths de join Covid_Vaccinations va
on de.date = va.date and de.location = va.location 
where de.continent is not null

select *, (RollingPeopleVaccinated/Population)*100 PercentageTotal 
from #OfPopulationVaccinated
order by 7 desc

-- Creating Simple View

create view PopulationVaccinated
as 
select de.continent, de.location, de.date, de.population,va.new_vaccinations,
sum (convert (numeric, va.new_vaccinations))
over (partition by de.location order by de.location,de.date) as RollingPeopleVaccinated
from Covid_Deaths de join Covid_Vaccinations va
on de.date = va.date and de.location = va.location 
where de.continent is not null


-- selecting from the view 

	select * from PopulationVaccinated
	order by 6 desc