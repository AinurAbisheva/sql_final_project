WITH monthly_stats AS (
    SELECT
        ID_client,
        DATE_FORMAT(new_date, '%Y-%m') AS month_,
        COUNT(Id_check) AS operations_cnt,
        AVG(Sum_payment) AS avg_check,
        SUM(Sum_payment) AS total_sum
    FROM transactions_info
    GROUP BY ID_client, month_
),

clients_full_year AS (
    SELECT
        ID_client
    FROM monthly_stats
    GROUP BY ID_client
    HAVING COUNT(DISTINCT month_) = 12
)

SELECT
    ms.ID_client,
    ms.month_,
    ms.operations_cnt,
    ROUND(ms.avg_check, 2) AS avg_check,
    ROUND(ms.total_sum, 2) AS total_sum
FROM monthly_stats ms
JOIN clients_full_year cf
    ON ms.ID_client = cf.ID_client
ORDER BY ms.ID_client, ms.month_;

SELECT
    DATE_FORMAT(new_date, '%Y-%m') AS month_,
    ROUND(AVG(Sum_payment), 2) AS avg_month_check
FROM transactions_info
GROUP BY month_
ORDER BY month_;

SELECT
    DATE_FORMAT(new_date, '%Y-%m') AS month_,
    ROUND(COUNT(Id_check) / COUNT(DISTINCT ID_client), 2) AS avg_operations
FROM transactions_info
GROUP BY month_
ORDER BY month_;

SELECT
    DATE_FORMAT(new_date, '%Y-%m') AS month_,
    COUNT(DISTINCT ID_client) AS clients_count
FROM transactions_info
GROUP BY month_
ORDER BY month_;

SELECT
    DATE_FORMAT(new_date, '%Y-%m') AS month_,

    COUNT(*) AS month_operations,

    ROUND(
        COUNT(*) * 100.0 /
        (SELECT COUNT(*) FROM transactions_info),
        2
    ) AS operations_percent,

    ROUND(
        SUM(Sum_payment),
        2
    ) AS month_sum,

    ROUND(
        SUM(Sum_payment) * 100.0 /
        (SELECT SUM(Sum_payment) FROM transactions_info),
        2
    ) AS sum_percent

FROM transactions_info

GROUP BY DATE_FORMAT(new_date, '%Y-%m')

ORDER BY DATE_FORMAT(new_date, '%Y-%m');

SELECT
    DATE_FORMAT(t.new_date, '%Y-%m') AS month_,
    c.Gender,

    COUNT(DISTINCT t.ID_client) AS clients_count,

    ROUND(SUM(t.Sum_payment), 2) AS total_spent,

    ROUND(
        SUM(t.Sum_payment) * 100.0 /
        SUM(SUM(t.Sum_payment)) OVER (
            PARTITION BY DATE_FORMAT(t.new_date, '%Y-%m')
        ),
        2
    ) AS spending_share_percent

FROM transactions_info t
JOIN customers c
    ON t.ID_client = c.Id_client

GROUP BY month_, c.Gender
ORDER BY month_, c.Gender;

SELECT
    CASE
        WHEN c.Age IS NULL THEN 'No Age'
        WHEN c.Age BETWEEN 0 AND 9 THEN '0-9'
        WHEN c.Age BETWEEN 10 AND 19 THEN '10-19'
        WHEN c.Age BETWEEN 20 AND 29 THEN '20-29'
        WHEN c.Age BETWEEN 30 AND 39 THEN '30-39'
        WHEN c.Age BETWEEN 40 AND 49 THEN '40-49'
        WHEN c.Age BETWEEN 50 AND 59 THEN '50-59'
        WHEN c.Age BETWEEN 60 AND 69 THEN '60-69'
        WHEN c.Age BETWEEN 70 AND 79 THEN '70-79'
        ELSE '80+'
    END AS age_group,

    CONCAT(YEAR(t.new_date), '-Q', QUARTER(t.new_date)) AS quarter_,

    COUNT(t.Id_check) AS operations_count,

    ROUND(SUM(t.Sum_payment), 2) AS total_sum,

    ROUND(AVG(t.Sum_payment), 2) AS avg_check,

    ROUND(
        SUM(t.Sum_payment) * 100.0 /
        SUM(SUM(t.Sum_payment)) OVER (
            PARTITION BY CONCAT(YEAR(t.new_date), '-Q', QUARTER(t.new_date))
        ),
        2
    ) AS quarter_percent

FROM transactions_info t

JOIN customers c
    ON t.ID_client = c.Id_client

GROUP BY
    age_group,
    quarter_

ORDER BY
    quarter_,
    age_group;