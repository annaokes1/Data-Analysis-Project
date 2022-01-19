-- First step is to understand your dataset
-- What are they columns, what is your data showing you
-- If you have multiple tables, then what is the primary key (the column they have in common)

SELECT * FROM Project_Walkthrough.netflix_costs;
SELECT * FROM Project_Walkthrough.netflix_libraries;

-- Lets Explore the Costs table first (note price is in usd $) 

-- What is the average price of each subscription offer per month 
SELECT ROUND(avg(basic_cost),2) AS AvgBasicCost, ROUND(avg(standard_cost),2) AS AvgStandardCost, ROUND(avg(premium_cost),2) AS AvgPremiumCost
FROM Project_Walkthrough.netflix_costs; 

-- What is the average price of each subscription by Continent
SELECT Continent, ROUND(avg(basic_cost),2) AS AvgBasicCost, ROUND(avg(standard_cost),2) AS AvgStandardCost, ROUND(avg(premium_cost),2) AS AvgPremiumCost
FROM Project_Walkthrough.netflix_costs
GROUP BY Continent; 

-- What is difference between a basic plan and premium & what country has the highest difference
SELECT *, ROUND(premium_cost - basic_cost,2) AS Difference
FROM Project_Walkthrough.netflix_costs
ORDER BY Difference DESC; 

-- Min & Max price by continent
SELECT Continent, ROUND(MIN(basic_cost),2) AS MinBasicCost, ROUND(MIN(standard_cost),2) AS MinStandardCost, ROUND(Min(premium_cost),2) AS MinPremiumCost
,ROUND(MAX(basic_cost),2) AS MaxBasicCost, ROUND(MAX(standard_cost),2) AS MaxStandardCost, ROUND(MAX(premium_cost),2) AS MaxPremiumCost
FROM Project_Walkthrough.netflix_costs
GROUP BY Continent; 

-- Lets explore the Libraries table now
SELECT * FROM Project_Walkthrough.netflix_libraries;

-- Top 5 countries for library database
SELECT * FROM Project_Walkthrough.netflix_libraries
ORDER BY Library_Size DESC
LIMIT 5;

-- Bottom 5 countries for library database
SELECT * FROM Project_Walkthrough.netflix_libraries
ORDER BY Library_Size ASC
LIMIT 5;

-- % Of movies/tv shows 
SELECT *, No_of_Movies/Library_Size * 100 AS PercentofMovies, No_of_Tvshows/Library_Size * 100 AS PercentofTvshows 
FROM Project_Walkthrough.netflix_libraries
ORDER BY Library_Size DESC;

-- Lets combine our datasets together based on Country
SELECT * FROM Project_Walkthrough.netflix_costs nc
INNER JOIN Project_Walkthrough.netflix_libraries nl 
ON nc.Country = nl.Country;

SELECT nc.Country, nc.Continent, nc.basic_cost, nc.standard_cost, nc.premium_cost,
nl.Library_Size, nl.No_of_Tvshows, nl.No_of_Movies 
FROM Project_Walkthrough.netflix_costs nc
INNER JOIN Project_Walkthrough.netflix_libraries nl 
ON nc.Country = nl.Country;

-- Lets see what the data looks like for the UK
SELECT nc.Country, nc.Continent, nc.basic_cost, nc.standard_cost, nc.premium_cost,
nl.Library_Size, nl.No_of_Tvshows, nl.No_of_Movies 
FROM Project_Walkthrough.netflix_costs nc
INNER JOIN Project_Walkthrough.netflix_libraries nl 
ON nc.Country = nl.Country
WHERE nc.Country = 'United Kingdom';

-- What countries have a higher premium cost than the UK 
SELECT nc.Country, nc.Continent, nc.premium_cost,
nl.Library_Size, nl.No_of_Tvshows, nl.No_of_Movies 
FROM Project_Walkthrough.netflix_costs nc
INNER JOIN Project_Walkthrough.netflix_libraries nl 
ON nc.Country = nl.Country
WHERE nc.premium_cost > (SELECT premium_cost FROM Project_Walkthrough.netflix_costs WHERE Country = 'United Kingdom')
ORDER BY nc.premium_cost DESC;

-- What countries have a higher premium cost than the UK but less library size
SELECT nc.Country, nc.Continent, nc.premium_cost,
nl.Library_Size, nl.No_of_Tvshows, nl.No_of_Movies 
FROM Project_Walkthrough.netflix_costs nc
INNER JOIN Project_Walkthrough.netflix_libraries nl 
ON nc.Country = nl.Country
WHERE nc.premium_cost > (SELECT premium_cost FROM Project_Walkthrough.netflix_costs WHERE Country = 'United Kingdom')
AND nl.Library_Size < (SELECT Library_Size FROM Project_Walkthrough.netflix_libraries WHERE Country = 'United Kingdom')
ORDER BY nc.premium_cost DESC;

-- Whats the avg premium cost & avg library size per continent
SELECT nc.Continent,  avg(nc.premium_cost) AS AvgPremium,avg(nl.Library_Size) as AvgLibrarySize
FROM Project_Walkthrough.netflix_costs nc
INNER JOIN Project_Walkthrough.netflix_libraries nl 
ON nc.Country = nl.Country
GROUP BY 1
ORDER BY 2 Desc;

-- Count number of countries per continent in dataset
SELECT nc.Continent,  count(nc.Country) AS NoofCountries
FROM Project_Walkthrough.netflix_costs nc
INNER JOIN Project_Walkthrough.netflix_libraries nl 
ON nc.Country = nl.Country
GROUP BY 1
ORDER BY 2 Desc;

-- Which countries are getting the best value for money 
SELECT nc.Country,  nc.premium_cost, nl.Library_Size,
-- When premium is less than avg AND library size is greater than avg then best value
CASE WHEN nc.premium_cost < (SELECT avg(premium_cost) FROM Project_Walkthrough.netflix_costs) AND 
nl.library_size > (SELECT avg(library_Size) FROM Project_Walkthrough.netflix_libraries) THEN 'Best Value'
-- when premium is more than avg AND library size is less than avg then worse value 
WHEN nc.premium_cost > (SELECT avg(premium_cost) FROM Project_Walkthrough.netflix_costs) AND 
nl.library_size < (SELECT avg(library_Size) FROM Project_Walkthrough.netflix_libraries) THEN 'Worse Value'
ELSE 'Mid Value'
END AS 'Netflix Value', 
ROUND((SELECT avg(library_Size) FROM Project_Walkthrough.netflix_libraries),0) AS LibraryAvgSize,
ROUND((SELECT avg(premium_cost) FROM Project_Walkthrough.netflix_costs),2) AS PremiumCostAvg
FROM Project_Walkthrough.netflix_costs nc
INNER JOIN Project_Walkthrough.netflix_libraries nl 
ON nc.Country = nl.Country;