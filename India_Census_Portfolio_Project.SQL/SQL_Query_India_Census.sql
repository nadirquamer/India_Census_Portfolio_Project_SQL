/*

Indian Census Data Exploration

Skills used: Joins, Create Table, Drop Table, Union Table, Windows Functions, Aggregate Functions

*/


select * from ProjectCensus..data1

select * from ProjectCensus..data2


--number of rows into our dataset

select count(*) from ProjectCensus..Data1
select count(*) from ProjectCensus..Data2


--dataset for Jharkhand and Bihar

select * from ProjectCensus..data1 where state in ('Jharkhand','Bihar')
order by state


--population of India

select sum(population) population from ProjectCensus..data2


--avg growth % of India

select avg(growth)*100 as avg_growth from ProjectCensus..data1


--avg growth % of States

select state, avg(growth)*100 as avg_growth from ProjectCensus..data1 
group by state


-- avg sex ratio of India

select avg(sex_ratio) as avg_sex_ratio from ProjectCensus..data1


-- avg sex ratio of States

select state, round(avg(sex_ratio),0)as avg_sex_ratio from ProjectCensus..data1 
group by State order by 2 desc


--avg literacy of India

select avg(literacy) as avg_literacy from ProjectCensus..data1 


-- --avg literacy of States

select state, round(avg(literacy),0) as avg_literacy from ProjectCensus..data1 
group by state order by 2 desc


-- -- --avg literacy of States greater then 90

select state, round(avg(literacy),0) as avg_literacy from ProjectCensus..data1 
group by state having round(avg(literacy),0)>90 order by 2 desc


-- top 3 states showing highest growth ratio

select top 3 state, avg(growth)*100 as avg_growth from ProjectCensus..data1 
group by state order by 2 desc


-- bottom 3 states showing lowest sex ratio

select top 3 state, round(avg(sex_ratio),0)as avg_sex_ratio from ProjectCensus..data1 
group by State order by 2 


-- CREATING and DROPPING Table

--top and bottom 3 states in literacy

drop table if exists #topstates
create table #topstates
(state nvarchar(255),
topstates float
 )

insert into #topstates
select state, round(avg(literacy),0) as avg_literacy from ProjectCensus..data1 
group by state order by 2 desc

select top 3 * from #topstates
order by 2 desc

-- bottom 3 states

drop table if exists #bottomstates
create table #bottomstates
(state nvarchar(255),
bottomstates float
 )

insert into #bottomstates
select state, round(avg(literacy),0) as avg_literacy from ProjectCensus..data1 
group by state order by 2 desc

select top 3 * from #bottomstates
order by 2 asc

--UNION OPERATOR

select * from (
select top 3 * from #topstates order by 2 desc) a
union
select * from (
select top 3 * from #bottomstates order by 2 asc) b


-- state starting with letter a 0r b

select distinct state from ProjectCensus..data1 where state like 'a%' or state like 'b%'


-- state starting with letter a and ending with letter m

select distinct state from ProjectCensus..data1 where state like 'a%' and state like '%m'


-- JOINING TABLE

select a.district, a.state, a.sex_ratio/1000 sex_ratio, b.population from ProjectCensus..data1 a inner join ProjectCensus..data2 b on a.district = b.district


-- total no. of male and total no. of female district wise

select c.district, c.state,round(c.population/(c.sex_ratio+1),0) male, round((c.population*c.sex_ratio)/(c.sex_ratio+1),0) females from
(select a.district, a.state, a.sex_ratio/1000 sex_ratio, b.population from ProjectCensus..data1 a inner join ProjectCensus..data2 b on a.district = b.district) c


--total no. of male and total no. of female state wise

select d.state, sum(d.male) total_male, sum(d.females) total_female from
(select c.district, c.state,round(c.population/(c.sex_ratio+1),0) male, round((c.population*c.sex_ratio)/(c.sex_ratio+1),0) females from
(select a.district, a.state, a.sex_ratio/1000 sex_ratio, b.population from ProjectCensus..data1 a inner join ProjectCensus..data2 b on a.district = b.district) c) d
group by d.state


-- total literacy ratio

select a.district, a.state, a.literacy literacy_ratio, b.population from projectCensus..data1 a inner join projectcensus..data2 b on a.district = b.district


--total no. of literate and total no. of illiterate people district wise

select c.district, c.state, round(c.literacy_ratio*c.population,0) literate_people, round((1-c.literacy_ratio)*c.population,0) illiterate_people from
(select a.district, a.state, a.literacy/100 literacy_ratio, b.population from projectCensus..data1 a inner join projectcensus..data2 b on a.district = b.district) c


--total no. of literate and total no. of illiterate people district wise

select d.state, sum(d.literate_people) total_literate_pop, sum(d.illiterate_people) total_illiterate_pop from
(select c.district, c.state, round(c.literacy_ratio*c.population,0) literate_people, round((1-c.literacy_ratio)*c.population,0) illiterate_people from
(select a.district, a.state, a.literacy/100 literacy_ratio, b.population from projectCensus..data1 a inner join projectcensus..data2 b on a.district = b.district) c) d
group by d.state 


-- previous census population districts wise

select c.district, c.state, round(c.population/(1+c.growth),0) previous_census_population, c.growth decadal_growth, c.population current_census_population from
(select a.district, a.state, a.growth, b.population from ProjectCensus..data1 a inner join ProjectCensus..data2 b on a.district= b.district) c


-- previous census population states wise

select d.state, sum(d.previous_census_population) previous_census_population, sum(d.decadal_growth) decadal_growth, sum(d.current_census_population) current_census_population from
(select c.district, c.state, round(c.population/(1+c.growth),0) previous_census_population, c.growth decadal_growth, c.population current_census_population from
(select a.district, a.state, a.growth, b.population from ProjectCensus..data1 a inner join ProjectCensus..data2 b on a.district= b.district) c) d
group by state


-- total previous census population 

select sum(e.previous_census_population) total_previous_census_population, sum(e.current_census_population) total_current_census_population from
(select d.state, sum(d.previous_census_population) previous_census_population, sum(d.decadal_growth) decadal_growth, sum(d.current_census_population) current_census_population from
(select c.district, c.state, round(c.population/(1+c.growth),0) previous_census_population, c.growth decadal_growth, c.population current_census_population from
(select a.district, a.state, a.growth, b.population from ProjectCensus..data1 a inner join ProjectCensus..data2 b on a.district= b.district) c) d
group by state) e


--population vs area

select k.total_area/k.total_previous_census_population total_previous_census_population_vs_area, k.total_area/k.total_current_census_population total_current_census_population_vs_area from
(select j.total_area, i.total_previous_census_population, i.total_current_census_population from
(select '1' as keyy, h.* from 
(select sum(e.previous_census_population) total_previous_census_population, sum(e.current_census_population) total_current_census_population from
(select d.state, sum(d.previous_census_population) previous_census_population, sum(d.decadal_growth) decadal_growth, sum(d.current_census_population) current_census_population from
(select c.district, c.state, round(c.population/(1+c.growth),0) previous_census_population, c.growth decadal_growth, c.population current_census_population from
(select a.district, a.state, a.growth, b.population from ProjectCensus..data1 a inner join ProjectCensus..data2 b on a.district= b.district) c) d
group by state) e) h) i
inner join
(select '1' as keyy, g.* from 
(select sum(area_km2) as total_area from ProjectCensus..data2) g) j on j.keyy = i.keyy) k


--WINDOW FUNCTION

--output top 3 districts from each states with highest literacy rate

select a.* from
(select district, state, literacy, rank() over(partition by state order by literacy desc) rnk from ProjectCensus..data1) a
where a.rnk in (1,2,3) order by state