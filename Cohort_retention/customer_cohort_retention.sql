#find  groups of people who made their first purchase in the same month and tracks their behavior month by month.
create or replace table `august-mesh-488818-i9.ecommerce_analysing.cohort_retention` as 
(
  with first_purchased as 
  (
    select
      user_id,
      date_trunc(min(date(created_at)),month) as cohort_month
    from bigquery-public-data.thelook_ecommerce.orders
    group by user_id
  ),
  monthly_activity as
  (
    select
      user_id,
      date_trunc(date(created_at),month) as activity_month
    from bigquery-public-data.thelook_ecommerce.orders
  ),
  cohort_data as
  (
    select 
      m.activity_month,
      f.cohort_month,
      date_diff(m.activity_month,f.cohort_month,month) as month_number,
      m.user_id
    from first_purchased f
    join monthly_activity as m
    on m.user_id = f.user_id
  ),
  cohort_size as 
  (
    select
    cohort_month,
    count(user_id) as total_users
    from cohort_data
    where month_number= 0
    group by cohort_month
  )
  select
    c.cohort_month,
    c.month_number,
    count(distinct c.user_id) AS active_users,
    round(
      count(distinct c.user_id) * 100.0 / s.total_users,
      2
    ) as retention_rate_percent
  from cohort_data c
  join cohort_size s
    on c.cohort_month = s.cohort_month
  where c.cohort_month >= date_sub(current_date(), interval 3 year)
  group by c.cohort_month, c.month_number, s.total_users
  order by c.cohort_month, c.month_number
);
