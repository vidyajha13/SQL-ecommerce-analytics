#created a table to analysing the yearly revenue and growth of revenue yearly.
  
create table if not exists august-mesh-488818-i9.ecommerce_analysing.yearly_growth_rate as 
(
  with yearly_revenues as 
  (
   select 
	   year,
	   sum(total_revenue) as yearly_revenue
  from `august-mesh-488818-i9.ecommerce_analysing.monthly_growth_rate`
  group by year)
  
  select 
     year,
     yearly_revenue,
     round(safe_divide(
     yearly_revenue -lag(yearly_revenue) over(order by year),
    lag(yearly_revenue) over(order by year))*100,2) as yearly_growth_percentage
  from yearly_revenues
  );

# this is find the carg% helps for understand the actual growth_rate of a business
with yearly_revenues as (
select year,sum(total_revenue) as yearly_revenue
from `august-mesh-488818-i9.ecommerce_analysing.monthly_growth_rate`
group by year)

select 
 pow(
  max(yearly_revenue)/min(yearly_revenue),1.0/(max(year)-min(year))
  ) - 1 as cagr
from yearly_revenues;
  
