--Total Population and covid Vaccination Rate of India and a few near by countries

SELECT *
FROM COVIDPROJECTPF..[Covid Population Rate]
ORDER BY 3,4

--Needed Data

SELECT Location, DATE, total_cases, new_cases, total_deaths, population
FROM COVIDPROJECTPF..[Covid Population Rate]
ORDER BY 1

--death percentage

SELECT location, date, total_cases, total_deaths, (CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100 AS Deathpercentage
FROM COVIDPROJECTPF..[Covid Population Rate]
ORDER BY 1

--PopulationAffectedPercent

SELECT location, date, total_cases, population, (CONVERT(float, total_cases) / CONVERT(float, population)) * 100 AS PopulationInfectionPercent
FROM COVIDPROJECTPF..[Covid Population Rate]
ORDER BY 1

--Max Affected Percent

SELECT location, population, max(total_cases) as HighInfectionCount,  max(total_cases/population) * 100 AS PopulationInfectionPercent
FROM COVIDPROJECTPF..[Covid Population Rate]
GROUP BY location,population
ORDER BY PopulationInfectionPercent desc

--Total Death over countries

SELECT location, max(total_deaths) as CountofTotalDeath
FROM COVIDPROJECTPF..[Covid Population Rate]
GROUP BY location
ORDER BY CountofTotalDeath desc

--Death count of Asia (shows only IND)

SELECT continent, MAX(cast (Total_deaths as int)) as TotalDeathCount
FROM COVIDPROJECTPF..[Covid Population Rate]
GROUP BY continent

--Total Vaccinations

SELECT pop.location, pop.date, pop.population, vac.new_vaccinations
,SUM(vac.new_vaccinations) OVER (PARTITION BY pop.location order by pop.location
, pop.date) as PeopleVaccinated
FROM COVIDPROJECTPF..[Covid Population Rate] pop
JOIN COVIDPROJECTPF..[Covid Vaccination Rate] vac
    ON pop.location = vac.location
    and pop.date = vac.date
ORDER BY 1,2,3

--USING CTE
--Total Population vs Vaccinations

WITH POPvsVAC (location,data,population,new_vaccinations,PeopleVaccinated)
as
(SELECT pop.location, pop.date, pop.population, vac.new_vaccinations
,SUM(vac.new_vaccinations) OVER (PARTITION BY pop.location order by pop.location
, pop.date) as PeopleVaccinated
FROM COVIDPROJECTPF..[Covid Population Rate] pop
JOIN COVIDPROJECTPF..[Covid Vaccination Rate] vac
    ON pop.location = vac.location
    and pop.date = vac.date
)
SELECT *, (PeopleVaccinated/population)*100 as PercentofPopVaccinated
FROM POPvsVAC


--Using Temp Table calc PercentofPopVaccinated

DROP TABLE IF EXISTS #PercentofPopVaccinated
CREATE TABLE #PercentofPopVaccinated
( 
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
PeopleVaccinated numeric
)

INSERT INTO #PercentofPopVaccinated
SELECT pop.location, pop.date, pop.population, vac.new_vaccinations
,SUM(vac.new_vaccinations) OVER (PARTITION BY pop.location order by pop.location
, pop.date) as PeopleVaccinated
FROM COVIDPROJECTPF..[Covid Population Rate] pop
JOIN COVIDPROJECTPF..[Covid Vaccination Rate] vac
    ON pop.location = vac.location
    and pop.date = vac.date

SELECT *, (PeopleVaccinated/population)*100 as PercentofPopVaccinated
FROM #PercentofPopVaccinated

--CREATING VIEW FOR LATER VISUALIZATION

CREATE VIEW PercentofPopVaccinated AS
SELECT pop.location, pop.date, pop.population, vac.new_vaccinations
,SUM(vac.new_vaccinations) OVER (PARTITION BY pop.location order by pop.location
, pop.date) as PeopleVaccinated
FROM COVIDPROJECTPF..[Covid Population Rate] pop
JOIN COVIDPROJECTPF..[Covid Vaccination Rate] vac
    ON pop.location = vac.location
    and pop.date = vac.date

SELECT *
FROM PercentofPopVaccinated