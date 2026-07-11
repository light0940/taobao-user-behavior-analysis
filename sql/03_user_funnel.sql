USE taobao_user_behavior;

-- 严格用户级顺序漏斗：首次浏览 -> 首次意向（加购或收藏）-> 首次购买
WITH first_pv AS (
    SELECT
        user_id,
        MIN(event_time) AS first_pv_time
    FROM user_behavior
    WHERE behavior_type = 'pv'
    GROUP BY user_id
),
first_intent AS (
    SELECT
        b.user_id,
        MIN(b.event_time) AS first_intent_time
    FROM user_behavior b
    JOIN first_pv p
        ON b.user_id = p.user_id
    WHERE b.behavior_type IN ('cart', 'fav')
      AND b.event_time > p.first_pv_time
    GROUP BY b.user_id
),
first_buy AS (
    SELECT
        b.user_id,
        MIN(b.event_time) AS first_buy_time
    FROM user_behavior b
    JOIN first_intent i
        ON b.user_id = i.user_id
    WHERE b.behavior_type = 'buy'
      AND b.event_time > i.first_intent_time
    GROUP BY b.user_id
),
cnt AS (
    SELECT
        (SELECT COUNT(*) FROM first_pv) AS pv_users,
        (SELECT COUNT(*) FROM first_intent) AS intent_users,
        (SELECT COUNT(*) FROM first_buy) AS buy_users
)
SELECT
    '浏览用户' AS stage_name,
    pv_users AS user_count,
    100.00 AS previous_step_rate,
    100.00 AS total_rate
FROM cnt
UNION ALL
SELECT
    '产生意向（加购或收藏）' AS stage_name,
    intent_users AS user_count,
    ROUND(intent_users * 100.0 / NULLIF(pv_users, 0), 2) AS previous_step_rate,
    ROUND(intent_users * 100.0 / NULLIF(pv_users, 0), 2) AS total_rate
FROM cnt
UNION ALL
SELECT
    '完成购买' AS stage_name,
    buy_users AS user_count,
    ROUND(buy_users * 100.0 / NULLIF(intent_users, 0), 2) AS previous_step_rate,
    ROUND(buy_users * 100.0 / NULLIF(pv_users, 0), 2) AS total_rate
FROM cnt;
