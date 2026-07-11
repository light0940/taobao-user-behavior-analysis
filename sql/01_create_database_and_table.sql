CREATE DATABASE IF NOT EXISTS taobao_user_behavior
DEFAULT CHARACTER SET utf8mb4
DEFAULT COLLATE utf8mb4_0900_ai_ci;

USE taobao_user_behavior;

CREATE TABLE IF NOT EXISTS user_behavior (
    event_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    user_id INT NOT NULL,
    item_id INT NOT NULL,
    category_id INT NOT NULL,
    behavior_type VARCHAR(10) NOT NULL,
    `timestamp` BIGINT NOT NULL,
    event_time DATETIME NOT NULL,
    event_date DATE NOT NULL,
    `hour` TINYINT NOT NULL,
    weekday TINYINT NOT NULL,
    PRIMARY KEY (event_id),
    INDEX idx_user_time (user_id, event_time),
    INDEX idx_behavior_time (behavior_type, event_time),
    INDEX idx_category_behavior (category_id, behavior_type),
    INDEX idx_event_date (event_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 在 Navicat 中将 raw_data/UserBehavior_clean.csv 导入 user_behavior 表。
-- CSV 字段顺序：
-- user_id,item_id,category_id,behavior_type,timestamp,event_time,event_date,hour,weekday
