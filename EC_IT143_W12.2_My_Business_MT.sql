USE [Cyclist Dataset];
/*****************************************************************************************************************
NAME:    DivvyBikes.com
PURPOSE: The purpose of this script is to answer the questions had by some of the key stakeholders from the community.

MODIFICATION LOG:
Ver      Date        Author        Description
-----   ----------   -----------   -------------------------------------------------------------------------------
1.0     12/14/2022   MTENNEY       1. I built this script for EC IT143

RUNTIME: 
Xm Xs

NOTES: 
Chicago Department of Transportation owns bikes and ebikes and scooters, along with charging stations and other infrastructure. 
Lyft manages the bike rental service. The dataset this script uses includes tables of quarterly rental records.
 
******************************************************************************************************************/
--Q1 From Amy Farrow, CIO of Lyft: We want to know a little about the demographics of our riders. What percentage of riders are Females 45 years old and above, 
--versus Males 45 and older for those who have provided this information? Also, what are the average rental times for those groups? 

--A1 below:


/* This is the simplified formula I found on https://www.sqlshack.com/sql-percentage-calculation-examples-in-sql-server/ for calculating a percentage within a column.

SELECT val,
val * 100/(SELECT SUM(val) FROM Scores) as 'Percentage of Total'
From Scores

*/

SELECT TOP 1 
	(SELECT COUNT(Gender) AS [Number of Female Users]
	FROM Divvy_Trips_2019_Q3
	WHERE Gender = 'female' AND BirthYear <= 1974) AS [Number of 3rd Quarter Female Users 45 Years or Older],
	
	(SELECT COUNT(Gender) AS [Number of Female Users]
	FROM Divvy_Trips_2019_Q3
	WHERE Gender = 'female' AND BirthYear <= 1974)
	
	* 100/																--divide by the total number of users and multiply by 100 to get a percentage of women over 44 to total users
	
	(SELECT Count(Gender) AS [Total Users]
	FROM Divvy_Trips_2019_Q3
	WHERE Gender IS Not Null) as 'Percentage of Total Users', ' ' AS 'VS',	
	
	(SELECT COUNT(Gender) AS [Number of Male Users]						--Repeat calculations for percentage of male users, 45 years or older
	FROM Divvy_Trips_2019_Q3
	WHERE Gender = 'male' AND BirthYear <= 1974) AS [Number of 3rd Quarter Male Users 45 Years or Older],

	(SELECT COUNT(Gender) AS [Number of Male Users]						--number of male users over 44
	FROM Divvy_Trips_2019_Q3
	WHERE Gender = 'male' AND BirthYear <= 1974)
	
	* 100/																--divide by the total number of users and multiply by 100 to get a percentage of women over 44 to total users
	
	(SELECT Count(Gender) AS [Total Users]								--Total number of users
	FROM Divvy_Trips_2019_Q3
	WHERE Gender IS Not Null) as 'Percentage of Total Users'
From Divvy_Trips_2019_Q2


--Q2 From Amy Farrow, CIO of Lyft: I want to see if usage differs between our User Types: Subscribers and Customers. What is the ratio of Customers to Subscribers
--that use Chicago's Divvy bicycle transportation system, and what are the the average rental durations for each group? 

--A2 the best we can do with this query is to use the about 90% of records that actually have gender and birth data. Answer follows:

/*	SELECT Count(UserType) AS [Total Users]
	FROM Divvy_Trips_2019_Q3

	SELECT Count(UserType) AS [Total Subscribers]
	FROM Divvy_Trips_2019_Q3
	WHERE UserType = 'Subscriber'

	SELECT Count(UserType) AS [Total Customers]
	FROM Divvy_Trips_2019_Q3
	WHERE UserType = 'Customer'
	*/

SELECT Top 1 
	(SELECT Cast(Count(UserType)as float)  AS [Total Customers]							--Numerator of ratio. Have to cast one component of calculation as float or decimal to convert from default int data type.
	FROM Divvy_Trips_2019_Q3
	WHERE UserType = 'Customer') 
	/
	(SELECT Count(UserType)
	FROM Divvy_Trips_2019_Q3
	WHERE UserType = 'Subscriber')
	AS [Ratio of Customers to Subscribers],
	
	(SELECT AVG(TripDuration) 																		--Get average trip duration for Customers	
	FROM	Divvy_Trips_2019_Q3
	WHERE UserType = 'Customer') / 60 AS [Average Customer Ride Duration (in Minutes)],

	(SELECT AVG(TripDuration) 																		--Get average trip duration for Subscriber	
	FROM	Divvy_Trips_2019_Q3
	WHERE UserType = 'Subscriber') / 60 AS [Average Subscriber Ride Duration (in Minutes)]										
FROM Divvy_Trips_2019_Q3


--Q3 We would like to know what percentage of our Subscribers are women versus the percentage of Customers that are women. Also, what is the age range of all female users?

--A3 the best we can do with this query is also to use the about 90% of records that actually have gender and birth data. Answer follows:
--SELECT (Numerator / Denominator * 100)
--FROM (

SELECT TOP 1
	(SELECT COUNT(UserType)
	FROM Divvy_Trips_2019_Q3
	WHERE Gender = 'female' AND UserType = 'Subscriber') AS [The Number of Women Subscribers], ' ' AS 'Versus',

	(SELECT COUNT(UserType)
	FROM Divvy_Trips_2019_Q3
	WHERE Gender = 'female' AND UserType = 'Customer') AS [The Number of Women Customers],
	' ' AS 'And the Span of Woman Riders'' Ages, Ranges',
	
	2019 - MAX(BirthYear) AS [From the Youngest Female Rider],
	
	2019-MIN(BirthYear) AS [To the oldest Female Rider]
FROM Divvy_Trips_2019_Q3


--Q4 From Amanda Woodall, Chicago Department of Transportation: As we assist in management of the assets and infrastructure of the bikeshare program, 
--we would like to know how many bike stations we have, and the percentage of rentals that are initiated at each station, so we can know where 
--we might need to focus our infrastructure maintenance efforts. Will you please gather that information for us?

--A4 answer below:

--First, we want the total number of Bike Rental Stations
SELECT count(DISTINCT(StartStationName)) AS [Number of Bike Rental Stations]
FROM Divvy_Trips_2019_Q2

--Next, we want a columnar list of all of the rental stations' ID numbers, followed by the count of rentals at each station, followed by the rental station name/location.
SELECT  StartStationID AS [Rental Station ID#], COUNT(RentalID) AS [Number of Q2 Rentals], (SELECT Distinct StartStationName) AS [Station Name/Location]
FROM Divvy_Trips_2019_Q2
GROUP BY StartStationName, StartStationID --Grouping by Station allows the COUNT() function to separate the counting of number of rentals by each rental station.
ORDER BY [Number of Q2 Rentals] DESC;  --We will put the rental station's name with the most rentals first, so we can quickly see which sites will probably need maintenance most frequently.



--Q5 From an SQL Fundamentals course peer, Adam Hodacsek: How many bikes are rented by males and by females at the busiest location?

--A5 to follow:
/*
SELECT MAX(COUNT(RentalID)) AS [Number of Bike Rentals by Men During 2nd Quarter]
--[The Busiest Bike Rental Station]
FROM Divvy_Trips_2019_Q3
Where Gender = 'male'
GROUP BY StartStationID
Order By*/

/*
	SELECT StartStationID AS [Rental Station ID#], COUNT(RentalID) AS [Number of Q2 Rentals], (SELECT Distinct StartStationName) AS [Station Name/Location], StartStationID
	FROM Divvy_Trips_2019_Q2
	GROUP BY StartStationName, StartStationID --Grouping by Station allows the COUNT() function to separate the counting of number of rentals by each rental station.
	ORDER BY [Number of Q2 Rentals] DESC
*/
	
	SELECT COUNT(RentalID) AS [Bike Rentals by Females], (SELECT DISTINCT StartStationName) AS 'At Busiest Location'	--Gather number of rentals by females from location with highest traffic shown in results from above query
	FROM Divvy_Trips_2019_Q2
	WHERE Gender = 'female' AND StartStationID = 35
	Group by StartStationName

	SELECT COUNT(RentalID) AS [Bike Rentals by Males], (SELECT DISTINCT StartStationName) AS 'At Busiest Location'		--Gather number of rentals by males from location with highest traffic
	FROM Divvy_Trips_2019_Q2
	WHERE Gender = 'male' AND StartStationID = 35
	Group by StartStationName
	







/*                          --These are just to call each of the tables from the data set
SELECT * 
FROM Divvy_Trips_2019_Q2

SELECT * 
FROM Divvy_Trips_2019_Q3

SELECT * 
FROM Divvy_Trips_2019_Q4	
*/



/*
--You can disregard the importance of this first commented-out section. These are some commands I had to use to change the data types 
--of the columns to numerical data types in preparation for calculations that would be made with queries. The original import did not work as desired.

ALTER TABLE Divvy_Trips_2019_Q2
ALTER COLUMN RentalID FLOAT
ALTER TABLE Divvy_Trips_2019_Q2
ALTER COLUMN LocalStartTime DATETIME NOT NULL
ALTER TABLE Divvy_Trips_2019_Q2
ALTER COLUMN LocalEndTime DATETIME NOT NULL
ALTER TABLE Divvy_Trips_2019_Q2
ALTER COLUMN BikeID FLOAT NOT NULL
ALTER TABLE Divvy_Trips_2019_Q2
ALTER COLUMN DurationInSecondsUncapped FLOAT NOT NULL
ALTER TABLE Divvy_Trips_2019_Q2
ALTER COLUMN StartStationID FLOAT NOT NULL
ALTER TABLE Divvy_Trips_2019_Q2
ALTER COLUMN StartStationName NVARCHAR(50) NOT NULL
ALTER TABLE Divvy_Trips_2019_Q2
ALTER COLUMN EndStationID FLOAT NOT NULL
ALTER TABLE Divvy_Trips_2019_Q2
ALTER COLUMN EndStationName NVARCHAR(50) NOT NULL
ALTER TABLE Divvy_Trips_2019_Q2
ALTER COLUMN UserType NVARCHAR(50) NOT NULL
ALTER TABLE Divvy_Trips_2019_Q2
ALTER COLUMN Gender NVARCHAR(50)
ALTER TABLE Divvy_Trips_2019_Q2
ALTER COLUMN BirthYear FLOAT 
*/