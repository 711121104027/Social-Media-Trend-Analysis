/* ---  User Tbale ---- */

CREATE TABLE users (
    user_id SERIAL PRIMARY KEY,
    username VARCHAR(50),
    age INT,
    country VARCHAR(50),
    joined_date DATE DEFAULT CURRENT_DATE
);

INSERT INTO users (username, age, country)
SELECT 
    'user_' || i,
    (RANDOM() * 30 + 18)::INT,
    CASE
        WHEN i % 4 = 0 THEN 'USA'
        WHEN i % 4 = 1 THEN 'India'
        WHEN i % 4 = 2 THEN 'UK'
        ELSE 'South Korea'
    END
FROM generate_series(1, 100) AS s(i);

Select * from users

/* ---- Platforms Table ---- */

CREATE TABLE platforms (
    platform_id SERIAL PRIMARY KEY,
    platform_name VARCHAR(50)
);

INSERT INTO platforms (platform_name)
VALUES ('Twitter'), ('Instagram'), ('Facebook'), ('YouTube'), ('Reddit');

Select * from platforms

/* ---- Posts Table ---- */

CREATE TABLE posts (
    post_id SERIAL PRIMARY KEY,
    user_id INT REFERENCES users(user_id),
    platform_id INT REFERENCES platforms(platform_id),
    content TEXT,
    post_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    sentiment_score DECIMAL(3,2),
    is_misinformation BOOLEAN DEFAULT FALSE
);

INSERT INTO posts (user_id, platform_id, content, post_date, sentiment_score, is_misinformation)
SELECT 
    (RANDOM() * 99 + 1)::INT,
    (RANDOM() * 4 + 1)::INT,
    'Sample post content ' || gs,
    NOW() - (INTERVAL '1 day' * (RANDOM() * 60)),
    ROUND((RANDOM() * 2 - 1)::NUMERIC, 2),
    (RANDOM() < 0.1)
FROM generate_series(1, 200) AS gs;

select * from posts

/* ---- Hashtags Table ---- */

CREATE TABLE hashtags (
    hashtag_id SERIAL PRIMARY KEY,
    hashtag_text VARCHAR(50)
);

INSERT INTO hashtags (hashtag_text)
VALUES 
('#trend1'), ('#trend2'), ('#trend3'), ('#trend4'), ('#trend5'),
('#trend6'), ('#trend7'), ('#trend8'), ('#trend9'), ('#trend10'),
('#MentalHealth'), ('#Tech'), ('#Politics'), ('#KPop'), ('#AI'),
('#Election2024'), ('#ClimateChange'), ('#Gaming'), ('#Fashion'),
('#News'), ('#Education'), ('#Sports'), ('#Entertainment'), ('#Health');

select * from hashtags

/* ---- Post_Hashtags Table ---- */

CREATE TABLE post_hashtags (
    post_id INT REFERENCES posts(post_id),
    hashtag_id INT REFERENCES hashtags(hashtag_id),
    PRIMARY KEY (post_id, hashtag_id)
);

/* ------ Count of how many Hashtags are present in the table ----- */

SELECT MIN(hashtag_id), MAX(hashtag_id), COUNT(*) FROM hashtags;

/* ----- Insert values to the post_hashtags ---- */

WITH post_ids AS (
    SELECT post_id FROM posts ORDER BY RANDOM() LIMIT 100
),
hashtag_ids AS (
    SELECT hashtag_id FROM hashtags ORDER BY RANDOM() LIMIT 10
),
possible_combinations AS (
    SELECT p.post_id, h.hashtag_id
    FROM post_ids p CROSS JOIN hashtag_ids h
),
shuffled_pairs AS (
    SELECT post_id, hashtag_id
    FROM possible_combinations
    ORDER BY RANDOM()
    LIMIT 300
)
INSERT INTO post_hashtags (post_id, hashtag_id)
SELECT post_id, hashtag_id
FROM shuffled_pairs
ON CONFLICT DO NOTHING;

select * from post_hashtags

/* ---- Count of post_hashtags ---- */

SELECT COUNT(*) FROM post_hashtags;

/* ---- Engagements Table ---- */

CREATE TABLE engagements (
    engagement_id SERIAL PRIMARY KEY,
    post_id INT REFERENCES posts(post_id),
    views INT,
    likes INT,
    shares INT,
    comments INT
);

INSERT INTO engagements (post_id, views, likes, shares, comments)
SELECT 
    post_id,
    (RANDOM() * 1000)::INT,
    (RANDOM() * 500)::INT,
    (RANDOM() * 100)::INT,
    (RANDOM() * 200)::INT
FROM posts;

select * from engagements

/* ---- Impact of  Mental Health Table ---- */

CREATE TABLE mental_health_impact (
    impact_id SERIAL PRIMARY KEY,
    user_id INT REFERENCES users(user_id),
    platform_id INT REFERENCES platforms(platform_id),
    reported_anxiety BOOLEAN,
    reported_depression BOOLEAN,
    survey_date DATE DEFAULT CURRENT_DATE
);

INSERT INTO mental_health_impact (user_id, platform_id, reported_anxiety, reported_depression)
SELECT
    (RANDOM() * 99 + 1)::INT,
    (RANDOM() * 4 + 1)::INT,
    (RANDOM() < 0.2),
    (RANDOM() < 0.15)
FROM generate_series(1, 100);

select * from mental_health_impact

/* ---- Sentiment Analysis ----*/

SELECT 
    p.platform_name,
    ROUND(AVG(po.sentiment_score), 2) AS avg_sentiment
FROM posts po
JOIN platforms p ON po.platform_id = p.platform_id
GROUP BY p.platform_name;

/* ---- Hashtag Tracking ----*/

SELECT 
    h.hashtag_text,
    COUNT(*) AS usage_count
FROM post_hashtags ph
JOIN hashtags h ON ph.hashtag_id = h.hashtag_id
GROUP BY h.hashtag_text
ORDER BY usage_count DESC
LIMIT 10;

/* ---- Cross-Platform User Behavior ----*/

SELECT 
    u.username,
    p.platform_name,
    COUNT(po.post_id) AS post_count
FROM posts po
JOIN users u ON po.user_id = u.user_id
JOIN platforms p ON po.platform_id = p.platform_id
GROUP BY u.username, p.platform_name
ORDER BY u.username;

/* ---- Misinformation Tagging ----*/

SELECT 
    p.platform_name,
    COUNT(*) AS misinformation_count
FROM posts po
JOIN platforms p ON po.platform_id = p.platform_id
WHERE po.is_misinformation = TRUE
GROUP BY p.platform_name
ORDER BY misinformation_count DESC;

/* ---- Content Trend Analysis ----*/

SELECT 
    h.hashtag_text,
    SUM(e.views) AS total_views,
    SUM(e.likes) AS total_likes,
    SUM(e.shares) AS total_shares,
    SUM(e.comments) AS total_comments
FROM post_hashtags ph
JOIN hashtags h ON ph.hashtag_id = h.hashtag_id
JOIN engagements e ON ph.post_id = e.post_id
GROUP BY h.hashtag_text
ORDER BY total_views DESC
LIMIT 10;


