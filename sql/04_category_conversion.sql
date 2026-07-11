USE taobao_user_behavior;

-- 类目转化表现：寻找高浏览、低购买的潜在问题类目
WITH category_stats AS (
    SELECT
        category_id,
        COUNT(DISTINCT CASE WHEN behavior_type = 'pv' THEN user_id END) AS browse_users,
        COUNT(DISTINCT CASE WHEN behavior_type IN ('cart', 'fav') THEN user_id END) AS intent_users,
        COUNT(DISTINCT CASE WHEN behavior_type = 'buy' THEN user_id END) AS buy_users
    FROM user_behavior
    GROUP BY category_id
)
SELECT
    category_id,
    browse_users,
    intent_users,
    buy_users,
    ROUND(buy_users * 100.0 / NULLIF(browse_users, 0), 2) AS buy_users_per_100_browsers,
    browse_users - buy_users AS potential_loss_users
FROM category_stats
WHERE browse_users >= 100
ORDER BY potential_loss_users DESC, buy_users_per_100_browsers ASC
LIMIT 20;

-- P0 类目复核
WITH category_stats AS (
    SELECT
        category_id,
        COUNT(DISTINCT CASE WHEN behavior_type = 'pv' THEN user_id END) AS browse_users,
        COUNT(DISTINCT CASE WHEN behavior_type IN ('cart', 'fav') THEN user_id END) AS intent_users,
        COUNT(DISTINCT CASE WHEN behavior_type = 'buy' THEN user_id END) AS buy_users
    FROM user_behavior
    GROUP BY category_id
)
SELECT
    category_id,
    browse_users,
    intent_users,
    buy_users,
    ROUND(buy_users * 100.0 / NULLIF(browse_users, 0), 2) AS buy_users_per_100_browsers,
    browse_users - buy_users AS potential_loss_users
FROM category_stats
WHERE category_id = 2355072;
