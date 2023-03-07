USE ig_clone;

/*We want to reward our users who have been around the longest. 
Find the 5 oldest users*/
SELECT *
FROM users
ORDER BY created_at 
LIMIT 5;


/*What day of the week do most users register on? 
We need to figure out when to schedule an ad campaign*/
SELECT 
     date_format(created_at, '%W') AS 'day of the week',
     COUNT(*) AS 'total registration'
FROM users
GROUP BY 1
ORDER BY 2 DESC;


/* We want to target our inactive users with an email campaign.
Find users who have never posted a photo*/
SELECT username
FROM users u 
LEFT JOIN photos p 
         ON u.id = p.user_id
WHERE p.id IS NULL;      


/* We're running a new contset to see who can get the most likes on a single photo.
WHO WON??!!*/
SELECT u.username, p.image_url, COUNT(*) AS total_likes
FROM users u 
JOIN photos p 
    ON u.id = p.user_id
JOIN likes l 
    ON p.id = l.photo_id
GROUP BY p.id
ORDER BY total_likes DESC;


/* Our investors want to know...
How many times does the average user post?
Eliminating users who have never posted*/
WITH total_posts AS(
    SELECT u.id AS user_id, p.id AS photo_id,
    COUNT(p.id) AS posts
    FROM  users  u 
    JOIN photos p 
       ON u.id = p.user_id
	GROUP BY u.id
    HAVING posts > 0
)    
SELECT
      ROUND(SUM(posts) / COUNT(user_id),2) AS average_post
FROM total_posts;

/* version 2
But without excluding users who have never posted*/
SELECT 
      ROUND((SELECT COUNT(*) FROM photos)/(SELECT COUNT(*) FROM users),2) AS average_posts;         


/* user ranking by postings higher to lower*/
SELECT u.username, 
       COUNT(p.image_url) AS number_of_posts
FROM users u 
JOIN photos p 
    ON u.id = p.user_id
GROUP BY u.id
 ORDER BY number_of_posts DESC;   
 
 
 /* Total number of users who have posted atleaat once*/
 SELECT
      COUNT(DISTINCT(u.id)) AS 'total number of users with posts'
FROM users u 
JOIN photos p 
    ON u.id = p.user_id   ; 
    
    
/* A brand want to know which hashtags to use in a post 
What are the top 5 most commonly used hashtags?*/
SELECT tag_name, COUNT(tag_name) AS total
FROM tags  t 
JOIN photo_tags pt 
    ON t.id = pt.tag_id
GROUP BY t.id
ORDER BY total DESC  ; 

/* version 2
Using a temporary table*/
WITH total_tags AS(
SELECT tag_id,
	   COUNT(photo_id) as total
FROM photo_tags
GROUP BY tag_id
ORDER BY total DESC
)
SELECT tag_name, total
FROM tags t 
JOIN total_tags
    ON t.id = total_tags.tag_id
ORDER BY total DESC
LIMIT 5;    


/* We have a small problem with bots on our site...
Find users who have liked every single photo on the site*/
SELECT u.username,
      COUNT(u.id) AS likes_by_user
FROM users u 
JOIN likes l 
    ON u.id = l.user_id
GROUP BY u.id
HAVING likes_by_user = (SELECT COUNT(*) FROM photos);


/* We also have a problem with celebrities
Find users who have never commented on a photo*/
SELECT username, comment_text
FROM users
LEFT JOIN comments
      ON users.id = comments.user_id
GROUP BY users.id
HAVING comment_text IS NULL;

/* We can output how many they are*/
SELECT COUNT(*) AS number_of_users_without_comments
FROM (
      SELECT username, comment_text
FROM users
LEFT JOIN comments
      ON users.id = comments.user_id
GROUP BY users.id
HAVING comment_text IS NULL
) AS number_of_users_without_comments;


/* MEGA CHALLENGES
Are we overrun with bots and celebrity accounts?
Find the persentage of users who have either never commentes on a photo or have commented on every photo*/
SELECT tableA.total_A AS 'Number of users who never commented',
       (tableA.total_A/(SELECT COUNT(*) FROM users))*100 AS '%',
       tableB.total_B As 'Number of users who likes every photo',
       (tableB.total_B/(SELECT COUNT(*) FROM users))*100 AS '%'
FROM (
        SELECT COUNT(*) AS total_A
        FROM (
               SELECT username, comment_text
               FROM users
               LEFT JOIN comments ON users.id = comments.user_id
               GROUP BY users.id
               HAVING comment_text IS NULL
        ) AS total_number_of_users_without_comments
)   AS tableA
    JOIN(
          SELECT COUNT(*) AS total_B
          FROM (
                 SELECT users.id, username, COUNT(users.id) AS total_likes_by_user
                 FROM users
                 JOIN likes ON users.id = likes.user_id
                 GROUP BY users.id
                 HAVING total_likes_by_user = (SELECT COUNT(*) FROM photos)
          ) AS total_number_users_likes_every_photo
    )AS tableB;
    
    
/* Find users who have commented on a photo*/
SELECT username, comment_text
FROM users u 
LEFT JOIN comments c 
      ON u.id = c.user_id
GROUP BY u.id
HAVING comment_text IS NOT NULL;    

SELECT COUNT(*) AS total_number_users_with_comments
FROM (
        SELECT username, comment_text
		FROM users u 
        LEFT JOIN comments c 
            ON u.id = c.user_id
        GROUP BY u.id
        HAVING comment_text IS NOT NULL
) AS total_number_users_with_comments; 


/* Who are these celebrities?
Find users with the highest number of followers*/
SELECT username,
      COUNT(follower_id) AS number_of_followers
FROM users
JOIN follows
    ON users.id = follows.followee_id
GROUP BY users.id
ORDER BY number_of_followers DESC;    