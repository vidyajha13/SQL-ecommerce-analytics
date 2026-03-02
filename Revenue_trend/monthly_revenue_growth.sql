#created the table contain monthly revenue and monthly revenue growth rate.
  
create table if not exists  august-mesh-488818-i9.ecommerce_analysing.monthly_growth_rate
as 
with monthly_revenue as
 (
  select
    month,
    year,
    SUM(revenue) as total_revenue
  from `august-mesh-488818-i9.ecommerce_analysing.clear_revenue_table`
  where year >= extract(year from date_sub(current_date,interval 3 year))
  group by year,month
  order by year,month
  )
select
  month,
  year,
  total_revenue,
  lag(total_revenue) over(order by year,month) as prev_month_revenue,
  round(safe_divide(
    total_revenue-lag(total_revenue) over(order by year,month),
    lag(total_revenue) over( order by year,month))*100,2) as month_growth_percentage
from monthly_revenue
order by year,month;
