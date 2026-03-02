# find the repeated customers rate to help the business performance
create table if not exists august-mesh-488818-i9.ecommerce_analysing.customer_retention as (
with user_orders as (
  select 
    user_id,
    count(order_id) as order_counts
    from `august-mesh-488818-i9.ecommerce_analysing.clear_revenue_table`
    group by user_id
)
select 
  count(*) as total_customer,
  count(
    case
      when order_counts>1 then 1
    end
  ) as repeated_customers,
  round(count(
    case
      when order_counts>1 then 1
    end
  )*100/count(*)) as RPR
from user_orders
);
