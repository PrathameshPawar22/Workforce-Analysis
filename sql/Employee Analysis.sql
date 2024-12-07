create database projects;

Select * from projects.hr
limit 10;

##setting safe updates to 0 to update and alter table
SET SQL_SAFE_UPDATES =0;

##Change birthdate column to date type from text. Change format
Update projects.hr
SET birthdate= CASE
		When birthdate like '%/%' THen date_format(str_to_date(birthdate,'%m/%d/%y'),'%Y-%m-%d')
		When birthdate like '%-%' THen date_format(str_to_date(birthdate,'%m-%d-%y'),'%Y-%m-%d')
        ELSE NULL
	END;
    
ALTER Table projects.hr
modify column birthdate DATE;

##Change hiredate column to date type from text. Change format
UPDATE projects.hr
SET hire_date= CASE
		WHen hire_date like '%/%' then date_format(str_to_date(hire_date,'%m/%d/%y'),'%y-%m-%d')
        WHen hire_date like '%-%' then date_format(str_to_date(hire_date,'%m-%d-%y'),'%y-%m-%d')
		ELSE NULL
	END;
    
ALTER TABLE projects.hr
modify column hire_date DATE;

##Change termdate column to date type from text. Change format
UPDATE projects.hr
SET termdate= date(str_to_date(termdate,'%Y-%m-%d %H:%i:%s UTC'))
WHERE termdate IS NOT NULL
AND termdate NOT LIKE '% %'
AND STR_TO_DATE(termdate, '%Y-%m-%d %H:%i:%s UTC') IS NOT NULL;

Update projects.hr
SET termdate= NULL
where termdate IS NULL
	OR termdate like '% %'
    OR STR_TO_DATE(termdate, '%Y-%m-%d %H:%i:%s UTC') IS NULL;

ALTER TABLE projects.hr
Modify column termdate DATE;

Select * from projects.hr
limit 10;



## add age column
alter table projects.hr
add column age int;

##Calculating age
update projects.hr
SET age = floor(datediff(curdate(),birthdate)/365.25);

Select * from projects.hr
limit 10;

Select min(age) as youngest,
		max(age) as oldest
	from projects.hr;

Select count(*) from projects.hr
where termdate>curdate();


## 1.What is the gender breakdown of employees in the company?
Select gender,count(*) as count
from projects.hr
where age>=18
group by gender
;

## 2.What is the race/ethnicity breakdown of employees in the company?
Select race, count(*) as count
from projects.hr
where age>=18
group by race
order by count desc;

## 3.What is the age distribution of employees in the company?

Select * from projects.hr
limit 10;

Select CASE
	when age>=18 and age<=24 then '18-24'
    when age>=25 and age<=34 then '25-34'
    when age>=35 and age<=44 then '35-44'
    when age>=45 and age<=54 then '45-54'
    when age>=55 and age<=64 then '55-64'
    else '65+'
END AS age_group,
count(*) as count
from projects.hr
where age>=18
group by age_group
order by age_group;


## 4.How many employees work at headquarters versus remote locations?
Select location, count(*) as count
from projects.hr
where age>=18
group by location;

## 5.What is the average length of employment for employees who have been terminated?
Select round(avg(datediff(termdate, hire_date))/365,2) as avg_length_of_employment
from projects.hr
where age>=18 and termdate<=curdate() and termdate IS NOT NULL ;

## 6.How does the gender distribution vary across departments and job titles?
Select gender,department,jobtitle,count(*) as count
from projects.hr
where age>=18
group by gender,department,jobtitle
order by gender,department,jobtitle;

## 7.What is the distribution of job titles across the company?
Select jobtitle,count(*) as count
from projects.hr
where age>=18
group by jobtitle
order by jobtitle;

## 8.Which department has the highest turnover rate?
Select department, count(*) as total_count,
SUM(CASE when termdate<=curdate() AND termdate IS NOT NULL then 1 else 0 END) as termination_count,
SUM(CASE when termdate IS NULL then 1 else 0 END) as active_count,
SUM(CASE when termdate<=curdate() then 1 else 0 END) as a,
(SUM(CASE when termdate<=curdate() then 1 else 0 END)/count(*)) as termination_rate
from projects.hr
where age>=18
group by department
order by department;
    