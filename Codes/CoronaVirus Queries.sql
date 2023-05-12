select *
From [Portfolio Project]..CovidDeath
Where continent is not null
Order by 3,4

select *
From [Portfolio Project]..CovidVaccination
Order by 3,4

--selecting target data
select Location, date, total_cases, new_cases, total_deaths, population
From [Portfolio Project]..CovidDeath
Where continent is not null
Order by 1,2


---Looking at the Total cases vs Death cases 

select Location, date, total_cases, new_cases, total_deaths, population
From [Portfolio Project]..CovidDeath
Order by 1,2

---Calculating Death rate
select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_percentage
From [Portfolio Project]..CovidDeath
Where location like '%Nigeria%'
Order by 1,2

select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_percentage
From [Portfolio Project]..CovidDeath
Where location like '%States%'
Order by 1,2

--Calculating Infection rate 
select Location, date, total_cases, population, (total_cases/population)*100 as Infected_percentage
From [Portfolio Project]..CovidDeath
Where location like '%States%'
Order by 1,2

select Location, date, total_cases, population, (total_cases/population)*100 as Infected_percentage
From [Portfolio Project]..CovidDeath
Where location like '%Nigeria%'
Order by 1,2

select Location, population, Max(total_cases) as Highest_Infection_Percentage,  Max(total_cases/population)*100 as Infected_percentage
From [Portfolio Project]..CovidDeath
Group by Location, population
Order by Infected_percentage desc


select Location,population, Max(cast(total_deaths as int)) as MaximumDeath
From [Portfolio Project]..CovidDeath
Where continent is not null
Group by Location,population
Order by MaximumDeath desc


select Location, Max(cast(total_deaths as int)) as MaximumDeath
From [Portfolio Project]..CovidDeath
Where continent is null
Group by Location, continent
Order by MaximumDeath desc

select Location, Max(cast(total_deaths as int)) as MaximumDeath
From [Portfolio Project]..CovidDeath
Where continent is  not null
Group by Location, continent
Order by MaximumDeath desc

select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_percentage
From [Portfolio Project]..CovidDeath
Where continent like '%Africa%'
Order by continent


--Global check
select date,sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeath
From [Portfolio Project]..CovidDeath
Where continent is null
Group by date
order by 1,2

--Checking the daily death globally
select date, sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeath 
From [Portfolio Project]..CovidDeath
Where continent is null
Group by date
order by 1,2

--checking total infection
select sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeath 
From [Portfolio Project]..CovidDeath
Where continent is null
--Group by date
order by 1,2

--checking total infection rate  
select sum(new_cases) as TotalCases, sum(cast(new_deaths as float)) as TotalDeath , sum(cast(new_deaths as float))/sum(New_Cases) as DeathRate
From [Portfolio Project]..CovidDeath
Where continent is null
Group by date
order by 1,2


--looking at the total population vs vaccination
select *
From [Portfolio Project]..CovidDeath death
Join [Portfolio Project]..CovidVaccination Vacc
	On death.location = Vacc.location
	and death.date = Vacc.date

select death.date, death.population, death.location, Vacc.new_vaccinations
From [Portfolio Project]..CovidDeath death
Join [Portfolio Project]..CovidVaccination Vacc
	On death.location = Vacc.location
	and death.date = Vacc.date
Where death.continent is not null
Order by 1,2


select death.date, death.population, death.location, Vacc.total_vaccinations,Vacc.new_vaccinations
From [Portfolio Project]..CovidDeath death
Join [Portfolio Project]..CovidVaccination Vacc
	On death.location = Vacc.location
	and death.date = Vacc.date
Where death.continent is null
Order by 1,2

select death.date, death.population, death.location, death.continent, Vacc.new_vaccinations, 
Sum(CONVERT(float,new_vaccinations )) over (partition by death.location order by death.location, death.date) as RollingPeopleVaccinated
From [Portfolio project]..CovidDeath death
Join [Portfolio Project]..CovidVaccination Vacc
		On death.date = Vacc.date
		and death.location = Vacc.location
Where death.continent is not null
Order by 1,2

--Use CTE

With PopvsVacc (date, population, location, continent, new_vacinations, RollingPeopleVaccinated) as
(
select death.date, death.population, death.location, death.continent, Vacc.new_vaccinations, 
Sum(CONVERT(float,new_vaccinations )) over (partition by death.location order by death.location, death.date) as RollingPeopleVaccinated
From [Portfolio project]..CovidDeath death
Join [Portfolio Project]..CovidVaccination Vacc
		On death.date = Vacc.date
		and death.location = Vacc.location
Where death.continent is not null

)
select *, (RollingPeopleVaccinated/population)*100
From PopvsVacc


--Use Temp Table


Create Table #PercentagePopulationVaccinated
(
date datetime,
population numeric,
location nvarchar(255),
continent nvarchar(255),
new_vaccination numeric,
RollingPeopleVaccinated nvarchar(255)
)
Insert into #PercentagePopulationVaccinated
select death.date, death.population, death.location, death.continent, Vacc.new_vaccinations, 
Sum(CONVERT(float,new_vaccinations )) over (partition by death.location order by death.location, death.date) as RollingPeopleVaccinated
From [Portfolio project]..CovidDeath death
Join [Portfolio Project]..CovidVaccination Vacc
		On death.date = Vacc.date
		and death.location = Vacc.location
Where death.continent is not null

select *, (RollingPeopleVaccinated/population)*100
From #PercentagePopulationVaccinated


Drop Table if exists #PercentagePopulationVaccinated
Create Table #PercentagePopulationVaccinated
(
date datetime,
population numeric,
location nvarchar(255),
continent nvarchar(255),
new_vaccination numeric,
RollingPeopleVaccinated nvarchar(255)
)
Insert into #PercentagePopulationVaccinated
select death.date, death.population, death.location, death.continent, Vacc.new_vaccinations, 
Sum(CONVERT(float,new_vaccinations )) over (partition by death.location order by death.location, death.date) as RollingPeopleVaccinated
From [Portfolio project]..CovidDeath death
Join [Portfolio Project]..CovidVaccination Vacc
		On death.date = Vacc.date
		and death.location = Vacc.location
--Where death.continent is not null

select *, (RollingPeopleVaccinated/population)*100
From #PercentagePopulationVaccinated

--Creating Views

Create View  NigeriaEffect as
select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_percentage
From [Portfolio Project]..CovidDeath
Where location like '%Nigeria%'
--Order by 1,2

Create View GlobalEffect as 
select date,sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeath
From [Portfolio Project]..CovidDeath
Where continent is null
Group by date
--order by 1,2


