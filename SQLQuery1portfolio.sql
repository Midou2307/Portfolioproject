select * from Portfolioproject..['owid-covid-data (1)$']
where continent is not null
--select * from Portfolioproject..['owid-covid-vacc]


select Location, date, total_cases, new_cases, total_deaths, population
from Portfolioproject..['owid-covid-data (1)$']
order by 1,2


-- looking at total cases vs total deaths
select location, date, total_cases, total_deaths, (convert(decimal, total_deaths) / convert ( decimal, total_cases))*10 as deathsperc
from Portfolioproject..['owid-covid-data (1)$']
where location like 'Algeria%'
order by 1,2

-- total cases vs population


select location, date, total_cases, population, (convert(decimal, total_cases) / convert ( decimal, population))*100 as deathsperc
from Portfolioproject..['owid-covid-data (1)$']
--where location like '%States%'
order by 1,2


-- looking at countries with hight infection rate compared to populationses

select location, population, max(total_cases) as highestinfect, max(convert(decimal, total_cases)) / max(convert ( decimal, population))*100 as percentpopuinfect
from Portfolioproject..['owid-covid-data (1)$']
--where location like '%States%'
group by location, population
order by percentpopuinfect desc

-- showing countries with highest death count per popu

select location, max(cast(total_deaths as int)) as totaldeaths
from Portfolioproject..['owid-covid-data (1)$']
--where location like '%States%'
where continent is not null
group by location
order by totaldeaths desc

-- let's break things down by continent

select location, max(cast(total_deaths as int)) as totaldeaths
from Portfolioproject..['owid-covid-data (1)$']
--where location like '%States%'
where continent is null
group by location
order by totaldeaths desc




-- showing continent highest death count peer popu

select continent, max(cast(total_deaths as int)) as totaldeaths
from Portfolioproject..['owid-covid-data (1)$']
--where location like '%States%'
where continent is not null
group by continent
order by totaldeaths desc



--global numbers
select date, sum(new_cases) as newcases, sum(new_deaths) as needeaths, 
case 
  when sum(cast(new_deaths as int))= 0 
  then sum(cast(new_deaths as int))+1/1
else
  sum(cast(new_deaths as int)) / sum(cast(new_cases as int))*100 
end as deathperc
from Portfolioproject..['owid-covid-data (1)$']
--where location like 'Algeria%'
where continent is not null
group by date
order by 1,2 



--total deaths
select sum(new_cases) as newcases, sum(new_deaths) as needeaths, 
case 
  when sum(cast(new_deaths as int))= 0 
  then sum(cast(new_deaths as int))+1/1
else
  sum(cast(new_deaths as int)) / sum(cast(new_cases as int))*100 
end as deathperc
from Portfolioproject..['owid-covid-data (1)$']
--where location like 'Algeria%'
where continent is not null
--group by date
order by 1,2 


-- looking at total popu vs vaccination

select dea.continent, dea.location, dea.date, dea.population, vac.new_tests,
sum(convert(bigint, vac.new_tests)) over (partition by dea.location order by dea.location, dea.date) as rollingpeople
--,(rollingpeople/population)*100
from Portfolioproject..['owid-covid-vacc] vac
join Portfolioproject..['owid-covid-data (1)$'] dea
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3



-- use cte

with popvsvac (continent, location, date, population, new_tests,rollingpeople)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_tests,
sum(convert(bigint, vac.new_tests)) over (partition by dea.location order by dea.location, dea.date) as rollingpeople
--,(rollingpeople/population)*100
from Portfolioproject..['owid-covid-vacc] vac
join Portfolioproject..['owid-covid-data (1)$'] dea
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select * , (rollingpeople / population)*100
from popvsvac




-- temp table

create table #percentpopvac
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_tests numeric,
rollingpeople numeric
)

insert into #percentpopvac
select dea.continent, dea.location, dea.date, dea.population, vac.new_tests,
sum(convert(bigint, vac.new_tests)) over (partition by dea.location order by dea.location, dea.date) as rollingpeople
--,(rollingpeople/population)*100
from Portfolioproject..['owid-covid-vacc] vac
join Portfolioproject..['owid-covid-data (1)$'] dea
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select * , (rollingpeople / population)*100
from #percentpopvac



-- crating view to store data for later visualization

create view percpopvac23
as
select dea.continent, dea.location, dea.date, dea.population, vac.new_tests,
sum(convert(bigint, vac.new_tests)) over (partition by dea.location order by dea.location, dea.date) as rollingpeople
--,(rollingpeople/population)*100
from Portfolioproject..['owid-covid-vacc] vac
join Portfolioproject..['owid-covid-data (1)$'] dea
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

--EXEC master.sys.sp_MSset_oledb_prop;













