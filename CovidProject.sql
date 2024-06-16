/****** Script for SelectTopNRows command from SSMS  ******/
SELECT *
FROM PortfolioProject..CovidDeaths
Where continent is not null
order by 3,4


  SELECT Location, date, total_cases,new_cases,total_deaths,population
  FROM PortfolioProject..CovidDeaths
  ORDER BY 1,2

  --Looking at total deaths vs total cases
  -- this shows the likelyhood of dying if you are contracting covid in your country the DeathPercentage

  SELECT Location, date, total_cases,total_deaths ,(total_deaths/total_cases)*100 as DeathPercentage
  FROM PortfolioProject..CovidDeaths
  WHERE location like '%Africa%'
  ORDER BY 1,2

-- Looking at the total cases vs the Population

SELECT Location, date, total_cases, population, (total_cases/population)*100 as PercentPopulationInfected
  FROM PortfolioProject..CovidDeaths
  WHERE location like '%Canada%'
  ORDER BY 1,2

 --Countries with the highest infection Rates compared to population

SELECT Location, population, MAX(total_cases)as HighestInfectionCount,MAX((total_cases/population))*100 as 
PercentPopulationInfected
  FROM PortfolioProject..CovidDeaths
  --WHERE location like '%Canada%'
  Group  by Location,population
  Order by PercentPopulationInfected desc

  --desc gets the highest number first


--Showing countries with highest death count per population
 SELECT Location, MAX(cast(total_deaths as int)) as HighestDeath 
  FROM PortfolioProject..CovidDeaths
  --WHERE location like '%Canada%'
  Where continent is not null
  Group  by Location
  Order by HighestDeath desc

  --- let's break it down by continent
    --Continent with the highest death count 

   SELECT continent, MAX(cast(total_deaths as int)) as HighestDeath 
  FROM PortfolioProject..CovidDeaths
  --WHERE location like '%Canada%'
  Where continent is not null
  Group  by continent
  Order by HighestDeath desc

  --Global Numbers
  SELECT  date,SUM(new_cases) as Sum_cases, SUM(cast(new_deaths as int)) as Sum_deaths,
  SUM(cast(new_deaths as int))/SUM(new_cases)*100 as Death_percentage
  -- total_cases,total_deaths ,(total_deaths/total_cases)*100 as DeathPercentage
  FROM PortfolioProject..CovidDeaths
  --WHERE location like '%Africa%'
   Where  continent is not null
   Group by date
   --used only with an aggreate function
  ORDER BY 1,2

  ---let's work on the vaccination table now and will create a CTE so that we can perform futher calculations on the table using a new column
  --we just created called RollingVaccinations 
  
  With PopVsVac (continent,location,date,population,new_vaccinations,RollingPeopleVaccinated) as
  (
  SELECT dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as int)) OVER(Partition by dea.Location order by dea.Location,dea.date) 
as RollingPeopleVaccinated
---it adds up the new_vaccinations and when there is non or zeros it will not add anything 
---So that after counting one country like canada it starts over  
From PortfolioProject..CovidDeaths dea
  Join PortfolioProject..CovidVaccination vac
   ON dea.Location = vac.Location
   and dea.date = vac.date
   WHERE dea.continent is not null --and vac.new_vaccinations is not null
   --order by 2,3
    )
	Select*,(RollingPeopleVaccinated/Population)*100 as Vacc_Pop
	From  PopVsVac
	-- this will give you the number of people vaccinated in a certain  population for example 
	--37% were vaccinated in the pop of Seychelles

	--TEMP TABLE
	DROP Table if exists #PercentPopulationVaccinated
	Create Table #PercentPopulationVaccinated
	(
	continent  nvarchar(255),
	location  nvarchar(255),
	date  datetime,
	population  numeric,
	new_vaccinations  numeric,
	RollingPeopleVaccinated  int ,
	)

	Insert into #PercentPopulationVaccinated
	 SELECT dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as int)) OVER(Partition by dea.Location order by dea.Location,dea.date) 
as RollingPeopleVaccinated
---it adds up the new_vaccinations and when there is non or zeros it will not add anything 
---So that after counting one country like canada it starts over  
From PortfolioProject..CovidDeaths dea
  Join PortfolioProject..CovidVaccination vac
   ON dea.Location = vac.Location
   and dea.date = vac.date
   WHERE dea.continent is not null --and vac.new_vaccinations is not null
   --order by 2,3

   SELECT *,(RollingPeopleVaccinated/Population)*100 as Vacc_Population
	From #PercentPopulationVaccinated 
	--WHERE  new_vaccinations is not null


	---Creating view to store data for later visualizations in Tableau

	CREATE VIEW PercentPopulationVaccinated as
	SELECT dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as int)) OVER(Partition by dea.Location order by dea.Location,dea.date) 
as RollingPeopleVaccinated
---it adds up the new_vaccinations and when there is non or zeros it will not add anything 
---So that after counting one country like canada it starts over  
From PortfolioProject..CovidDeaths dea
  Join PortfolioProject..CovidVaccination vac
   ON dea.Location = vac.Location
   and dea.date = vac.date
   WHERE dea.continent is not null 
   --and vac.new_vaccinations is not null
   --order by 2,3

   Select *
   FROM PercentPopulationVaccinated