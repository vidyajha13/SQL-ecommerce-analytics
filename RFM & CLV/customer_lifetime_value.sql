#customer behavior analysis by clv
create or replace table august-mesh-488818-i9.ecommerce_analysing.customer_clv_analysis as (
with customer_stats as (
  select
    o.user_id,
    count(distinct o.order_id) as total_orders,
    sum(oi.sale_price) as total_revenue,
    min(date(o.created_at)) as first_purchase,
    max(date(o.created_at)) as last_purchase
  from `bigquery-public-data.thelook_ecommerce.orders` o
  join `bigquery-public-data.thelook_ecommerce.order_items` oi
    on o.order_id = oi.order_id
  where o.status = 'Complete'
  group by o.user_id
),

clv_calc as (
  select
    user_id,
    total_revenue,
    total_orders,
    safe_divide(total_revenue, total_orders) AS avg_order_value,
    safe_divide(
      date_diff(last_purchase, first_purchase, DAY),
      365
    ) as lifespan_years,
    safe_divide(total_orders,
      safe_divide(DATE_DIFF(last_purchase, first_purchase, DAY),365)
    ) as purchase_frequency
  from customer_stats
  where total_orders > 1
)

select
  user_id,
  avg_order_value,
  purchase_frequency,
  lifespan_years,
  round(avg_order_value * purchase_frequency * lifespan_years,2) as estimated_clv
from clv_calc
);
