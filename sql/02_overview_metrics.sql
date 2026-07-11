USE taobao_user_behavior;

-- 样本总览
SELECT
    COUNT(*) AS total_events,
    COUNT(DISTINCT user_id) AS active_users,
    COUNT(DISTINCT item_id) AS active_items,
    COUNT(DISTINCT category_id) AS active_categories,
    MIN(event_time) AS min_event_time,
    MAX(event_time) AS max_event_time
FROM user_behavior;

-- 行为类型分布
SELECT
    behavior_type,
    COUNT(*) AS event_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS event_pct
FROM user_behavior
GROUP BY behavior_type
ORDER BY event_count DESC;

-- 每日行为趋势
SELECT
    event_date,
    COUNT(*) AS total_events,
    COUNT(DISTINCT user_id) AS active_users,
    SUM(behavior_type = 'pv') AS pv_events,
    SUM(behavior_type = 'cart') AS cart_events,
    SUM(behavior_type = 'fav') AS fav_events,
    SUM(behavior_type = 'buy') AS buy_events
FROM user_behavior
GROUP BY event_date
ORDER BY event_date;

-- 小时行为分布
SELECT
    `hour`,
    COUNT(*) AS total_events,
    SUM(behavior_type = 'pv') AS pv_events,
    SUM(behavior_type = 'cart') AS cart_events,
    SUM(behavior_type = 'fav') AS fav_events,
    SUM(behavior_type = 'buy') AS buy_events
FROM user_behavior
GROUP BY `hour`
ORDER BY `hour`;
