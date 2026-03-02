#understand how valuable a customer is to a business based on their past transactions.
create  or replace table `august-mesh-488818-i9.ecommerce_analysing.rfm_segmentation` as (
with base_rfm as 
(
  select 
    user_id,
    date_diff(current_date(),max(date(created_at)),day) as recency,
    count(distinct order_id) AS frequency,
    sum(sale_price) AS monetary
  from bigquery-public-data.thelook_ecommerce.order_items
  where status = 'Complete'
  group by user_id
),
rfm_scores as (
  select *,
  ntile(5) over (order by  recency desc) as r_score,
  ntile(5) over (order by frequency) as f_score,
  ntile(5) over (order by monetary) as m_score
  from base_rfm
)
select
  *,
  case
    when r_score >=4 and f_score >=4 and m_score >=4 then 'Champions'
    when r_score >=3 and f_score >=3 then 'Loyal Customers'
    when m_score >=4 and f_score <=2 then 'Big Spenders'
    when r_score <=2 and f_score >=3 then 'At Risk'
    when r_score <=2 and f_score <=2 then 'Churned'
    else 'Average Customers'
  end as customer_segment
from rfm_scores
);
