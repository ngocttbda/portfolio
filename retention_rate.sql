CREATE VIEW retention_rate_monthly AS
WITH orders_by_month AS (
    SELECT maHD, maKH, DATE_FORMAT(ngaygiaodich, '%Y-%m') AS month  -- dinh dang ve yyyy-mm
    FROM transaction
), first_month_customer AS (
    SELECT maKH, min(month) AS first_month -- tim first month cua tung KH
    FROM orders_by_month
    GROUP BY 1 -- group by theo maKH
), new_customer_of_month AS (
    SELECT first_month, COUNT(maKH) AS new_customer -- dem so khach hang theo first month
    FROM first_month_customer
    GROUP BY 1
    ORDER BY 1
), active_customer_of_month AS (
    SELECT maKH, month AS retention_month -- tim nhung thang ma user co mua hang
    FROM orders_by_month
    GROUP BY 1, 2
    ORDER BY 1, 2
), retention_customer AS (
    SELECT first_month, retention_month, COUNT(a.maKH) AS retain_customer -- dem nhung KH co quay lai mua hang
    FROM active_customer_of_month a
             LEFT JOIN first_month_customer f ON a.maKH = f.maKH    -- ket hop CTE active_customer_of_month va first_month_customer
    GROUP BY 1, 2
)
SELECT r.first_month, r.retention_month, new_customer, retain_customer,
       retain_customer/new_customer AS retention_rate   -- tinh ty le giu chan khach hang
FROM retention_customer r
LEFT JOIN new_customer_of_month n ON r.first_month = n.first_month
ORDER BY 1,2;
