use advanced_sql_db;
-- calculating running sum
select Year(o.order_date),
month(o.order_date),
sum(oi.unit_price*oi.quantity*(1-oi.discount)) as cm_sales,
sum(sum(oi.unit_price*oi.quantity*(1-oi.discount))) over (partition by year(o.order_date) order by month(o.order_date)
rows between unbounded preceding and current row) as runnig_sum_sales
from orders o 
left join order_items oi
on o.order_id=oi.order_id
WHERE O.STATUS = 'Delivered'
Group by 1 ,2
order by 1,2
;

-- 3 month moving average
select Year(o.order_date),
month(o.order_date),
sum(oi.unit_price*oi.quantity*(1-oi.discount)) as cm_sales,
sum(sum(oi.unit_price*oi.quantity*(1-oi.discount))) over (partition by year(o.order_date) order by month(o.order_date)
rows between unbounded preceding and current row) as runnig_sum_sales,
avg(sum(oi.unit_price*oi.quantity*(1-oi.discount))) over (partition by year(o.order_date)
 order by month(o.order_date)
 rows between 2 preceding and current row
 ) as  moving_avg
from orders o 
left join order_items oi
on o.order_id=oi.order_id
WHERE O.STATUS = 'Delivered'
Group by 1 ,2
order by 1,2
;

-- Salary rank of each employee in his/her department
select 
e.employee_id,
d.department_name,
concat(e.first_name,' ',e.last_name) as full_name,
e.hire_date,
e.salary ,
rank() over(partition by d.department_id order by e.salary desc) as ranking_Rank,
dense_rank() over(partition by d.department_id order by e.salary desc) as ranking_dense_Rank,
row_number() over(partition by d.department_id order by e.salary desc) as ranking_unique

from employees e
left join departments d
on d.department_id=e.department_id;



