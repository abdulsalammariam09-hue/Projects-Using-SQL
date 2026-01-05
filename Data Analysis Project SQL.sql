#LOADING MY DATA
SELECT *
FROM `DATABASE`.covidvacinationcreated;

SELECT *
FROM `DATABASE`.coviddeathshalf;

SELECT *
FROM `DATABASE`.covidvaccinations;

#SELECTING THE DATA TO WORK ON 
SELECT location,date,total_cases,new_cases,total_deaths,population
FROM coviddeathshalf;


#LOOKING AT TOTAL CASES AND NO OF TOTAL DEATH by percentage
SELECT location,date,total_cases, total_deaths,ROUND((total_deaths/total_cases)*100,2)AS percentage_per_deathoppp
FROM coviddeathshalf
#WHERE location LIKE '%state%'
ORDER BY 1,2;

#LOOKING AT TOTAL CCASES VERS POPULATION
SELECT location,date,total_cases,population,MAX(total_cases/population)*100 AS cases_by_percentage
FROM coviddeathshalf
#WHERE location='%state%'
GROUP BY location,date,total_cases,population
ORDER BY 1,2;


#LOOKING AT MAX  TOTAL CASES VERS POPULATION
SELECT location,date,MAX(total_cases) AS highestinfection ,population,MAX(ROUND(total_cases/population))*100,2 AS cases_by_percentage
FROM coviddeathshalf
#WHERE location='%state%'
GROUP BY location,date,population
ORDER BY 1,2;



#MAXIMUM
SELECT location,population,MAX(total_cases) AS highestinfection,MAX(total_cases/population)*100 AS cases_by_percentage
FROM coviddeathshalf
#WHERE location = '%state%'
GROUP BY location,population
ORDER BY cases_by_percentage DESC;


#MAXIMUM DEATH COUNT
SELECT location,MAX(CAST(total_deaths AS UNSIGNED)) Death_count
FROM coviddeathshalf
#WHERE location = '%state%'
GROUP BY location
ORDER BY Death_count ASC;

#WORKING BY CONTINENT
SELECT continent,MAX(CAST(total_deaths AS UNSIGNED)) Death_count
FROM coviddeathshalf
#WHERE continent is null 
GROUP BY continent
ORDER BY Death_count ASC;


#GLOBA  CONTINENT 
#LOOKING AT TOTAL CASES AND NO OF TOTAL DEATH by percentage #SIGNED allows negative numbers UNSIGNED does not
#ALWAYS GUARD YOUR DIVISION BY DIVIDING BY 0
SELECT date,SUM(new_cases) new_cases,SUM(CAST(new_deaths AS UNSIGNED)) new_deaths ,ROUND(SUM(CAST(new_deaths AS UNSIGNED))/NULLIF(SUM(CAST(new_cases AS UNSIGNED)),0)*100,2)AS percentage_per_death
FROM coviddeathshalf
#WHERE location LIKE '%state%'
GROUP BY date
ORDER BY 1,2;

SELECT SUM(new_cases) new_cases,SUM(CAST(new_deaths AS SIGNED)) new_deaths ,
ROUND(SUM(CAST(new_deaths AS SIGNED))/SUM(CAST(new_cases AS SIGNED))*100,2)AS percentage_per_death
FROM coviddeathshalf
#WHERE location LIKE '%state%'
#GROUP BY date
ORDER BY 1,2;

SELECT SUM(new_deaths + 0) new_deaths #,ROUND(SUM(CAST(new_deaths AS UNSIGNED))/NULLIF(SUM(CAST(new_cases AS UNSIGNED)),0)*100,2)AS percentage_per_death
FROM coviddeathshalf;
#WHERE location LIKE '%state%'
#GROUP BY date
#ORDER BY 1,2;

SELECT SUM(CAST(new_deaths AS SIGNED)) new_deaths #,ROUND(SUM(CAST(new_deaths AS UNSIGNED))/NULLIF(SUM(CAST(new_cases AS UNSIGNED)),0)*100,2)AS percentage_per_death
FROM coviddeathshalf;
#WHERE location LIKE '%state%'
#GROUP BY date
#ORDER BY 1,2;

SELECT SUM(CAST(new_deaths AS SIGNED)) # (new_deaths + 0)
FROM coviddeathshalf;
#WHERE location LIKE '%state%'
#GROUP BY date
#ORDER BY 1,2;

#total population vs vacination  
SELECT*
FROM `DATABASE`.covidvaccinations
JOIN coviddeathshalf
 ON covidvaccinations.location = coviddeathshalf.location 
     AND covidvaccinations.date = coviddeathshalf.date;

SELECT cd.continent,cd.date,cd.location,cd.population,cv.new_vaccinations
FROM `DATABASE`.covidvaccinations AS cv
JOIN coviddeathshalf as cd
ON cv.location =cd.location and cv.date = cd.date
WHERE cd.continent IS NOT NULL;

SELECT cd.continent,cd.date,cd.location,cd.population,cv.new_vaccinations,
SUM(cv.new_vaccinations +0 ) OVER (PARTITION BY cd.location ORDER BY cd.location,cd.Date)
AS rollingpeoplevaccinated
FROM `DATABASE`.covidvaccinations AS cv
JOIN coviddeathshalf as cd
ON cv.location =cd.location and cv.date = cd.date
WHERE cd.continent IS NOT NULL;

#USE CTE (FOR TEMPORARILY SAVING  A TABLE)
WITH POPVSVAC (continent,location,date,population,new_vaccinations,
rollingpeoplevaccinated) AS
(SELECT cd.continent,cd.date,cd.location,cd.population,cv.new_vaccinations,
SUM(cv.new_vaccinations +0 ) OVER (PARTITION BY cd.location ORDER BY cd.location,cd.Date)
AS rollingpeoplevaccinated
FROM `DATABASE`.covidvaccinations AS cv
JOIN coviddeathshalf as cd
ON cv.location =cd.location and cv.date = cd.date
WHERE cd.continent IS NOT NULL)
SELECT*, rollingpeoplevaccinated/NULLIF(population,0) *100
FROM POPVSVAC;


DROP TEMPORARY TABLE IF EXISTS percentagepopulation;

CREATE TEMPORARY TABLE percentagepopulation (
    continent VARCHAR(255),
    location VARCHAR(255),
    Date DATETIME,
    population NUMERIC,
    new_vaccinations NUMERIC,
    rollingpeoplevaccinated NUMERIC
);
#MySQL expects DATETIME in this format YYYY-MM-DD
INSERT INTO percentagepopulation
SELECT 
    cd.continent,
    cd.location,
	STR_TO_DATE(cd.date, '%d/%m/%Y') AS date_recorded,
    cd.population,
   CAST(REPLACE(cv.new_vaccinations, ',', '.') AS DECIMAL(10,3)),
    SUM(CAST(REPLACE(cv.new_vaccinations, ',', '.') AS DECIMAL(10,3)))
        OVER (PARTITION BY cd.location ORDER BY cd.date)
FROM covidvaccinations cv
JOIN coviddeathshalf cd
    ON cv.location = cd.location 
   AND cv.date = cd.date
WHERE cd.continent IS NOT NULL;

SELECT *,
       (rollingpeoplevaccinated / population) * 100 AS percent_vaccinated
FROM percentagepopulation;




#making a view for visualization
SELECT continent,MAX(CAST(total_deaths AS UNSIGNED)) Death_count
FROM coviddeathshalf
WHERE continent is not null 
GROUP BY continent
ORDER BY Death_count ASC;

CREATE VIEW percentagepopulation AS
SELECT 
    cd.continent,
    cd.location,
    cd.date,
    cd.population,
    cv.new_vaccinations,
    SUM(cv.new_vaccinations) 
        OVER (PARTITION BY cd.location ORDER BY cd.date) 
        AS rollingpeoplevaccinated
FROM covidvaccinations cv
JOIN coviddeathshalf cd
    ON cv.location = cd.location 
   AND cv.date = cd.date
WHERE cd.continent IS NOT NULL;



SELECT *
FROM percentagepopulation;