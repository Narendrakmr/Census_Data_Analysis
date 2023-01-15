use census;
SELECT * FROM dt1;
SELECT * FROM dt2;

##No of rows present in the dataset
Select count(*) from dt1 ;
select count(distinct district) from dt1; ##six district records seems to be repeated

Select count(*) from dt2 ;
select count(distinct district) from dt2;

 #checked that the records are different
select * from dt1 group by District having count(*)=2;
select * from dt1 where District='Pratapgarh';  

##query for particular state
select * from dt1 where State ='Madhya Pradesh' or State= 'Maharashtra' ;

 #sum of population of the entire country
select sum(population) as Total_Population from dt2;  ##'1210854977'


# Average growth of population of the entire country
select round(avg(Growth),2) as Average_Growth_country from dt1;  #'0.19'

# Average growth% of population state wise
select state , round(avg(Growth)*100,2) as Average_Growth_state from dt1 
							group by state order by Average_Growth_state;  

# Average sex ratio sate wise
select state , floor(avg(Sex_Ratio)) as Average_sexRatio from dt1 
                   group by state order by Average_sexRatio desc ;
                   
#Sates list having literacy>90
select state , literacy from dt1 group by state having literacy>90 ;

#top 3 sates showing highest growth
select state, avg(growth) as avg_growth from dt1 
  group by state order by avg_growth desc limit 3;
 

#bottom 3 state showing lowest sex ratio  
select state, avg(sex_ratio) as avg_sexRatio from dt1 
group by state order by avg_sexRatio  limit 3;

#Creation of temporary table 

drop table if exists top_bottom1,top_bottom2;
create temporary table top_bottom1 (state varchar(255) , avg_literacy int) ;
insert into top_bottom1 (select state , round(avg(literacy),0) from dt1
 group by state order by round(avg(literacy),0) desc limit 10);
 
 create temporary table top_bottom2 (state varchar(255) , avg_literacy int) ;
 insert into top_bottom2 (select state , round(avg(literacy),0) from dt1
 group by state order by round(avg(literacy),0) asc limit 10);
 
 #Union operator
 
 select * from top_bottom1 union select * from top_bottom2 order by avg_literacy desc;
 
 #Filtering the states starting with letter 'A'
 
 select * from dt1 where state like 'A%%';

##calculating total no of males and females district wise
select a.district,a.state,a.sex_ratio,b.population,
round(((sex_ratio*population)/(1000+sex_ratio)),0) as female_population,
round(((1000*population)/(1000+sex_ratio)),0) as male_population
from dt1 a inner join dt2 b on a.district=b.district;

##calculating total no of males and females state wise
select a.state,sum(b.population),
sum(round(((sex_ratio*population)/(1000+sex_ratio)),0)) as female_population,
sum(round(((1000*population)/(1000+sex_ratio)),0)) as male_population
from dt1 a inner join dt2 b on a.district=b.district group by State;

##Creating table dt3 to census database
create table dt3(select a.district,a.state,a.sex_ratio,b.population,
round(((sex_ratio*population)/(1000+sex_ratio)),0) as female_population,
round(((1000*population)/(1000+sex_ratio)),0) as male_population
from dt1 a inner join dt2 b on a.district=b.district);

##finding no of female and male population that is literate
select a.district,a.literacy,b.female_population,b.male_population,
round(((literacy/100)*female_population),0) as female_literacy,
round(((literacy/100)*male_population),0) as male_literacy
from dt1 a inner join dt3 b on a.district=b.district;

#finding the previous no of male and no of female 
select a.district , b.population as new_population , a.growth , b.female_population , b.male_population,
round((((100-growth)/100)*population),0) as prev_population ,
round((((100-growth)/100)*female_population),0) as prev_female,
round((((100-growth)/100)*male_population),0) as prev_male
from dt1 a inner join dt3 b on a.district=b.district ;

#bottom 3 districts from each state on the basis of low literacy rate 
create table literacy (select a.district,a.literacy,b.female_population,b.male_population,
round(((literacy/100)*female_population),0) as female_literacy,
round(((literacy/100)*male_population),0) as male_literacy
from dt1 a inner join dt3 b on a.district=b.district);

select * from (select a.state , a.district , l.literacy , 
rank() over(partition by state order by literacy asc ) as bottom_3 
from 
literacy l inner join dt1 a on l.district=a.district) c where c.bottom_3 in (1,2,3);



