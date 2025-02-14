select *
from dbo.coviddeaths

select*
from dbo.covidvaccinations

-- location,population and total cases 

select distinct location,population,total_cases
from dbo.coviddeaths
where continent is not null
order by total_cases

-- Peak number of daily new cases per country.

select distinct location,date,
max(new_cases) as peak_cases     
from dbo.coviddeaths
where continent is not null
group by location,date
order by peak_cases;

-- avarage of new cases

select continent,avg(cast(new_cases as int)) as avarage_new_cases
from dbo.coviddeaths
where continent is not null
group by continent

-- Covid Death percentage.

select distinct location,total_cases,total_deaths,
(total_deaths/total_cases)*100 as death_percentage
from dbo.coviddeaths
order by location

-- percentage of people vaccinated in africa.

select distinct  covd. location,covc.date, covd.population,covc.total_vaccinations,
(total_vaccinations/population)*100 as vaccination_percentage 
from dbo.covidvaccinations covc
join dbo.coviddeaths as covd
on covc.iso_code=covd.iso_code
where covc.location like 'africa'
order by date

-- countries with highest infection ratecompared to population.

 select location ,population,max(total_cases)as highest_infections, max((total_cases/population))*100 as
percentage_of_infections
from coviddeaths
group by location,population
order by highest_infections

-- countries with high death count.
--convert nvachar(255) and convert to integure.

select location,max(cast(total_deaths as int)) as total_death_count 
from coviddeaths
where continent is not null   
group by location
order by total_death_count desc

--Total cases vs total deaths

select location,date,total_cases,total_deaths,
(total_deaths )/(total_cases)*100 as death_percentage
from dbo.coviddeaths


-- percentage of vaccination rate.

select covd. location,
       max(total_vaccinations)/max(covd.population )*100 as vaccination_rate
from dbo.covidvaccinations as covc
join dbo.coviddeaths as covd
on covd.iso_code=covc.iso_code
group by covd. location
order by vaccination_rate


-- Total population vs Vaccinations

select covd.continent,covd.location,covd.date,covd.population,covc.new_vaccinations
,sum(convert(bigint,covc.new_vaccinations ))over(partition by covd.location order by covd.location,
covd.date) as Rolling_people_vaccinated
--,(Rolling_people_vaccinated/population)*100
from dbo.coviddeaths as covd
join dbo.covidvaccinations as covc
     on covd.location=covc.location
	 and covd.date=covc.date
where covd.continent is not null
order by 1,2


-- Using CTE

with poplvsvacs(continent,location,date,population,new_vaccinations,Rolling_pepole_vaccinated)
as 
(
select covd.continent,covd.location,covd.date,covd.population,covc.new_vaccinations
,sum(convert(bigint, covc.new_vaccinations))over(partition by covd.location order by covd.location,
covd.date) as Rolling_people_vaccinated
from dbo.coviddeaths as covd
join dbo.covidvaccinations as covc
     on covd.location=covc.location
	 and covd.date=covc.date
where covd.continent is not null
)
select*,(Rolling_pepole_vaccinated/population)*100 as Rolling_pepole_vaccinated_percent
from poplvsvacs


-- Temp Table

create table #percentpopulationvaccinated
(
continent nvarchar(255),
location nvarchar (255),
date datetime,
population numeric,
new_vaccinations numeric,
Rolling_people_vaccinated numeric
)

insert into #percentpopulationvaccinated
select covd.continent,covd.location,covd.date,covd.population,covc.new_vaccinations
,sum(convert(bigint, covc.new_vaccinations))over(partition by covd.location order by covd.location,
covd.date) as Rolling_people_vaccinated
from dbo.coviddeaths as covd
join dbo.covidvaccinations as covc
     on covd.location=covc.location
	 and covd.date=covc.date
where covd.continent is not null

select*,(Rolling_people_vaccinated/population)*100 as Rolling_pepole_vaccinated_percent
from #percentpopulationvaccinated


