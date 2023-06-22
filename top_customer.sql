-- Top 10 khach hang co tong tien mua hang cao nhat
SELECT ma_KH,ten_KH,SUM(tongtienHD) AS total_paid
    FROM `order`
    WHERE ma_KH NOT IN ('KHACHLE', 'KH000042', 'KH000005', 'KH000004', 'KH000007')
    AND ngay_tao < '2023-06-01'
    GROUP BY 1,2
    ORDER BY total_paid DESC
    LIMIT 10;


-- Tim 5 san pham duoc mua nhieu nhat cua moi KH thuoc top 10 KH co doanh thu cao nhat
WITH top_customer AS (  -- CTE top_customer
    SELECT ma_KH,ten_KH,SUM(tongtienHD) AS total_paid
    FROM `order`
    WHERE ma_KH NOT IN ('KHACHLE', 'KH000042', 'KH000005', 'KH000004', 'KH000007')  -- loai bo gia tri phan tan du lieu
    AND ngay_tao < '2023-06-01' -- xet den het 05/2023
    GROUP BY 1,2
    ORDER BY total_paid DESC
    LIMIT 10
)
SELECT tenKH, tensanpham
FROM
(SELECT tenKH,maKH,tensanpham,
       ROW_NUMBER() OVER (PARTITION BY tenKH ORDER BY count(*) desc ) AS row_num    -- moi KH se tra ra cac san pham duoc danh thu tu theo so giao dich giam dan
FROM transaction t
JOIN top_customer tc ON t.maKH = tc.ma_KH
GROUP BY 1,2,3) AS sub -- bang con sub la ket hop giua CTE va bang transaction
JOIN top_customer tc ON sub.maKH = tc.ma_KH
WHERE row_num <= 5  -- ket hop CTE va sub de lay 5 sp dau
ORDER BY total_paid DESC ;



-- Tim 5 san pham co doanh thu cao nhat cho moi KH thuoc top 10 KH co doanh thu cao nhat
WITH top_customer1 AS (
    SELECT ma_KH,ten_KH,SUM(tongtiensaugiam) AS total_paid
    FROM `order`
    WHERE ma_KH NOT IN ('KHACHLE', 'KH000042', 'KH000005', 'KH000004', 'KH000007')
    AND ngay_tao < '2023-06-01' -- xet den het 05/2023
    GROUP BY 1,2
    ORDER BY total_paid DESC
    LIMIT 10
)
, top_product1 AS (
    SELECT tenKH, tensanpham,total_paid
    FROM (SELECT maKH,
                 tenKH,
                 tensanpham,
                 ROW_NUMBER() OVER (PARTITION BY tenKH ORDER BY SUM(tongtienthanhtoan) DESC ) AS row_num1 -- moi KH se tra ra cac san pham duoc danh thu tu theo doanh thu giam dan
          FROM transaction t1
                   JOIN top_customer1 tc1 ON t1.maKH = tc1.ma_KH
          GROUP BY 1, 2, 3) AS sub1
             JOIN top_customer1 tc1 ON sub1.maKH = tc1.ma_KH
    WHERE row_num1 <= 5
    ORDER BY total_paid DESC
)
SELECT tenKH,total_paid,GROUP_CONCAT(tensanpham SEPARATOR ' ; ') AS top_5_product -- tra ra ket qua 5 sp theo dang tensanpham1 ; ... ;  tensanpham5
FROM top_product1
GROUP BY 1,2
ORDER BY 2 DESC ;

