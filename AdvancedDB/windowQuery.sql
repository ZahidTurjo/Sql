-- Compare each employee's salary to their department's average salary
use advanced_sql_db;
SELECT 
    concat(e.first_name,' ',e.last_name) as full_name,
    e.salary,d.department_name,
    avg(e.salary) over(partition by d.department_name) as avg_PerDeptSalary,
    e.salary -avg(e.salary) over(partition by d.department_name) as salary_diff
From
    employees e
        LEFT JOIN
    departments d ON e.department_id = d.department_id;
    
-- use CTE
with base_tab as(
select concat(e.first_name,' ',e.last_name) as full_name,
    e.salary,d.department_name,
    avg(e.salary) over(partition by d.department_name) as avg_deptSalary
from employees e left join departments d on e.department_id=d.department_id)
select B.*, B.salary-avg_deptSalary as diff
from base_tab B;

-- using subquery for doing the same task
select *,
	salary-avg_deptSalary as diff
From
(select concat(e.first_name,' ',e.last_name) as Full_name,
	d.department_name,e.salary,
    avg(e.salary)over(partition by d.department_name) as avg_deptSalary
from employees e left join departments d 
on e.department_id=d.department_id)as s;

-- MoM (Month over Month) Growth using Value Window Functions (LAG)

select Year(o.order_date),month(o.order_date),
sum(oi.unit_price * oi.quantity*(1-oi.discount)) as cm_sales,
lag(sum(oi.unit_price * oi.quantity*(1-oi.discount))) over(order by year(o.order_date),month(o.order_date)) as pm_sales,
sum(oi.unit_price * oi.quantity*(1-oi.discount))-lag(sum(oi.unit_price * oi.quantity*(1-oi.discount))) over(order by year(o.order_date),month(o.order_date))
as delta,
(sum(oi.unit_price * oi.quantity*(1-oi.discount))-lag(sum(oi.unit_price * oi.quantity*(1-oi.discount))) over(order by year(o.order_date),month(o.order_date)))*100/
lag(sum(oi.unit_price * oi.quantity*(1-oi.discount))) over(order by year(o.order_date),month(o.order_date)) as MOM

from orders o left join order_items oi 
on oi.order_id=o.order_id
group by 1 ,2
order by  1,2 ;

--  MoM (Month over Month) Growth using Value Window Functions (LAG)(Using CTE)
with base_table as 
(
select Year(o.order_date) as year,month(o.order_date) as month,
sum(oi.unit_price * oi.quantity*(1-oi.discount)) as cm_sales,
lag(sum(oi.unit_price * oi.quantity*(1-oi.discount))) over(order by year(o.order_date),month(o.order_date)) as pm_sales
from orders o left join order_items oi 
on oi.order_id=o.order_id
group by 1 ,2
order by  1,2 )
select b.year,b.month,b.cm_sales,b.pm_sales,b.cm_sales -b.pm_sales as delta ,
 (b.cm_sales -b.pm_sales)*100/b.pm_sales as MOM
from base_table b;

