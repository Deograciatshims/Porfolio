/****** Script for SelectTopNRows command from SSMS  ******/
SELECT *
  FROM [top movies rated].[dbo].['TMBD Movie Dataset2$']
  --where original_title= 'Love, Wedding, Marriage'

/**percentage of movies that were not profitable from the 2000s until now**/
Select original_title, budget, production_companies, release_year, profit, MIN(cast((profit/budget)*100 as int)) as lowprofitpercentage
FROM [top movies rated].[dbo].['TMBD Movie Dataset2$']
where release_year > 2000
and original_title is not NULL
Group by original_title, budget, production_companies, release_year, profit
order by lowprofitpercentage ASC

/**movies from the 2000s low budget VS high profit**/
SELECT original_title, production_companies, release_year, min(budget_adj) as lowerbudget, max(profit) as higherprofit
FROM [top movies rated].[dbo].['TMBD Movie Dataset2$']
where release_year > 2000
group by  original_title, production_companies, release_year
order by  lowerbudget ASC, higherprofit 

/** top 100 movies with the most profit of all time after 2010s revenue readjustment  **/
SELECT  original_title, production_companies, release_year, max(revenue_adj) as higherprofit
FROM [top movies rated].[dbo].['TMBD Movie Dataset2$']
Where revenue_adj> 633000000
group by original_title, production_companies, release_year
order by higherprofit DESC

/***global numbers**/


 SELECT  production_companies, release_year, SUM(budget_adj) as totalbudgaj, SUM(revenue_adj) as totalreveadj, sum(profit) as totalprofit, cast(sum(profit)/ SUM(budget_adj)  *100 as int)as percentagebuddg
FROM [top movies rated].[dbo].['TMBD Movie Dataset2$']
 group by production_companies, release_year
 order by 6 asc

 /**Revenue vs total readjusted revenue**/


 SELECT a.original_title, a.production_companies, a.release_year,  a.budget_adj, a.revenue, sum(convert(numeric, b.revenue_adj))
    OVER (Partition by a.production_companies Order by a.original_title,a.release_year) as updatedrevenue
	--, (updatedrevenue/ budget_adj)*100
 FROM [top movies rated].[dbo].['TMBD Movie Dataset2$'] a 
 Left outer join [top movies rated].[dbo].['TMBD Movie Dataset2$'] b
on a.id= b.id
and a.release_year= b.release_year
where a.original_title is not NULL
order by 1 asc


/**Using CTE to perform Calculation on Partition By in previous query**/

with RevVSReadjrev as 
(SELECT a.original_title, a.production_companies, a.release_year, a.revenue, a.budget_adj, sum(convert(numeric, b.revenue_adj))
    OVER (Partition by a.production_companies Order by a.original_title,a.release_year) as updatedrevenue
	--, (updatedrevenue/ budget_adj)*100
 FROM [top movies rated].[dbo].['TMBD Movie Dataset2$'] a 
 Left outer join [top movies rated].[dbo].['TMBD Movie Dataset2$'] b
on a.id= b.id
and a.release_year= b.release_year
--order by  1 asc
)

SELECT*	, cast((updatedrevenue/budget_adj)*100 as int)
FROM RevVSReadjrev
-- Using Temp Table to perform Calculation on Partition By in previous query


DROP Table if exists #Percentrevenueadj
Create TABLE #Percentrevenueadj
(original_title nvarchar (255),
production_companies nvarchar (255),
release_year float,
revenue float, 
budget_adj float, 
updatedrevenue float)

insert into #Percentrevenueadj
SELECT a.original_title, a.production_companies, a.release_year, a.revenue, a.budget_adj, sum(convert(numeric, b.revenue_adj))
    OVER (Partition by a.production_companies Order by a.original_title,a.release_year) as updatedrevenue
	--, (updatedrevenue/ budget_adj)*100
 FROM [top movies rated].[dbo].['TMBD Movie Dataset2$'] a 
 Left outer join [top movies rated].[dbo].['TMBD Movie Dataset2$'] b
on a.id= b.id
and a.release_year= b.release_year
--order by  1 asc

SELECT*	, cast((updatedrevenue/budget_adj)*100 as int)
FROM #Percentrevenueadj

SELECT *
FROM #Percentrevenueadj
-- Creating View to store data for later visualizations

CREATE VIEW Percentrevenueadj AS

SELECT a.original_title, a.production_companies, a.release_year, a.revenue, a.budget_adj, sum(convert(numeric, b.revenue_adj))
    OVER (Partition by a.production_companies Order by a.original_title,a.release_year) as updatedrevenue
	--, (updatedrevenue/ budget_adj)*100
 FROM [top movies rated].[dbo].['TMBD Movie Dataset2$'] a 
 Left outer join [top movies rated].[dbo].['TMBD Movie Dataset2$'] b
on a.id= b.id
and a.release_year= b.release_year

SELECT *
FROM Percentrevenueadj

