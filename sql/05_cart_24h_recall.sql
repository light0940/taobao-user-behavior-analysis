USE taobao_user_behavior;

-- 首次加购后 24 小时成交诊断，粒度为同一用户 + 同一商品
WITH max_time AS (
    SELECT MAX(event_time) AS max_event_time
    FROM user_behavior
),
first_cart AS (
    SELECT
        user_id,
        item_id,
        category_id,
        MIN(event_time) AS first_cart_time
    FROM user_behavior
    WHERE behavior_type = 'cart'
    GROUP BY user_id, item_id, category_id
),
eligible_cart AS (
    SELECT c.*
    FROM first_cart c
    CROSS JOIN max_time m
    WHERE c.first_cart_time <= DATE_SUB(m.max_event_time, INTERVAL 24 HOUR)
),
cart_buy AS (
    SELECT
        c.user_id,
        c.item_id,
        c.category_id,
        c.first_cart_time,
        MIN(b.event_time) AS first_buy_after_cart
    FROM eligible_cart c
    LEFT JOIN user_behavior b
        ON c.user_id = b.user_id
       AND c.item_id = b.item_id
       AND b.behavior_type = 'buy'
       AND b.event_time > c.first_cart_time
    GROUP BY c.user_id, c.item_id, c.category_id, c.first_cart_time
),
tagged AS (
    SELECT
        *,
        CASE
            WHEN first_buy_after_cart <= DATE_ADD(first_cart_time, INTERVAL 24 HOUR)
            THEN 1
            ELSE 0
        END AS is_buy_24h
    FROM cart_buy
)
SELECT
    COUNT(*) AS eligible_cart_item_pairs,
    SUM(first_buy_after_cart IS NOT NULL) AS eventual_buy_pairs,
    SUM(is_buy_24h) AS buy_24h_pairs,
    ROUND(SUM(is_buy_24h) * 100.0 / NULLIF(COUNT(*), 0), 2) AS cart_to_buy_24h_rate
FROM tagged;

-- 按类目筛选召回优先级
WITH max_time AS (
    SELECT MAX(event_time) AS max_event_time
    FROM user_behavior
),
first_cart AS (
    SELECT
        user_id,
        item_id,
        category_id,
        MIN(event_time) AS first_cart_time
    FROM user_behavior
    WHERE behavior_type = 'cart'
    GROUP BY user_id, item_id, category_id
),
eligible_cart AS (
    SELECT c.*
    FROM first_cart c
    CROSS JOIN max_time m
    WHERE c.first_cart_time <= DATE_SUB(m.max_event_time, INTERVAL 24 HOUR)
),
cart_buy AS (
    SELECT
        c.user_id,
        c.item_id,
        c.category_id,
        c.first_cart_time,
        MIN(b.event_time) AS first_buy_after_cart
    FROM eligible_cart c
    LEFT JOIN user_behavior b
        ON c.user_id = b.user_id
       AND c.item_id = b.item_id
       AND b.behavior_type = 'buy'
       AND b.event_time > c.first_cart_time
    GROUP BY c.user_id, c.item_id, c.category_id, c.first_cart_time
),
tagged AS (
    SELECT
        *,
        CASE
            WHEN first_buy_after_cart <= DATE_ADD(first_cart_time, INTERVAL 24 HOUR)
            THEN 1
            ELSE 0
        END AS is_buy_24h
    FROM cart_buy
)
SELECT
    category_id,
    COUNT(*) AS cart_item_pairs,
    SUM(is_buy_24h) AS buy_24h_pairs,
    ROUND(SUM(is_buy_24h) * 100.0 / NULLIF(COUNT(*), 0), 2) AS cart_to_buy_24h_rate,
    COUNT(*) - SUM(is_buy_24h) AS recall_candidate_pairs,
    COUNT(DISTINCT CASE WHEN is_buy_24h = 0 THEN user_id END) AS recall_users
FROM tagged
GROUP BY category_id
HAVING cart_item_pairs >= 100
ORDER BY recall_candidate_pairs DESC, cart_to_buy_24h_rate ASC
LIMIT 20;

-- P0 类目 2355072 的召回用户清单
WITH max_time AS (
    SELECT MAX(event_time) AS max_event_time
    FROM user_behavior
),
first_cart AS (
    SELECT
        user_id,
        item_id,
        category_id,
        MIN(event_time) AS first_cart_time
    FROM user_behavior
    WHERE behavior_type = 'cart'
    GROUP BY user_id, item_id, category_id
),
eligible_cart AS (
    SELECT c.*
    FROM first_cart c
    CROSS JOIN max_time m
    WHERE c.first_cart_time <= DATE_SUB(m.max_event_time, INTERVAL 24 HOUR)
),
cart_buy AS (
    SELECT
        c.user_id,
        c.item_id,
        c.category_id,
        c.first_cart_time,
        MIN(b.event_time) AS first_buy_after_cart
    FROM eligible_cart c
    LEFT JOIN user_behavior b
        ON c.user_id = b.user_id
       AND c.item_id = b.item_id
       AND b.behavior_type = 'buy'
       AND b.event_time > c.first_cart_time
    GROUP BY c.user_id, c.item_id, c.category_id, c.first_cart_time
),
tagged AS (
    SELECT
        *,
        CASE
            WHEN first_buy_after_cart <= DATE_ADD(first_cart_time, INTERVAL 24 HOUR)
            THEN 1
            ELSE 0
        END AS is_buy_24h
    FROM cart_buy
)
SELECT
    user_id,
    COUNT(*) AS recall_candidate_items,
    MIN(first_cart_time) AS earliest_cart_time
FROM tagged
WHERE category_id = 2355072
  AND is_buy_24h = 0
GROUP BY user_id
ORDER BY recall_candidate_items DESC, earliest_cart_time
LIMIT 100;
