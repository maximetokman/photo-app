-- to run from psql prompt"
-- \i /Users/vanwars/northwestern/webdev/photo-app/drop_tables.sql

drop table IF EXISTS "comments" CASCADE;
drop table IF EXISTS "likes_posts" CASCADE;
drop table IF EXISTS "likes_comments" CASCADE;
drop table IF EXISTS "following" CASCADE;
drop table IF EXISTS "followers" CASCADE;
drop table IF EXISTS "bookmarks" CASCADE;
drop table IF EXISTS "posts" CASCADE;
drop table IF EXISTS "users" CASCADE;


-- Useful queries:
-- Who is nreyes following?
-- SELECT u.id, u.username, f.id, f.username
-- FROM users as u
-- INNER JOIN "following" as m
--       ON u.id=m.user_id
-- INNER JOIN users as f
--       ON m.following_id=f.id
-- WHERE u.username = 'carterscott';

-- -- What has nreyes posted?
-- SELECT u.id, u.username, p.caption, count(c.id) as num_comments
-- FROM users as u
-- INNER JOIN "posts" as p
--       ON u.id=p.user_id
-- INNER JOIN "comments" as c
--       ON c.post_id=p.id
-- WHERE u.username = 'carterscott'
-- GROUP BY u.id, u.username, p.caption;

-- -- How many comments does nreyes have for each of their posts?
-- SELECT p.id, u.id, u.username, count(c.id) as num_comments
-- FROM users as u
-- INNER JOIN "posts" as p
--       ON u.id=p.user_id
-- INNER JOIN "comments" as c
--       ON c.post_id=p.id
-- WHERE u.username = 'carterscott'
-- GROUP BY u.id, u.username, p.id
-- ORDER BY num_comments;


-- What have carterscott & ppl their following posted?
-- SELECT p.id as post_id, p.pub_date, substring(p.caption, 0, 50), u.id, u.username
-- FROM (
--     (
--         SELECT u.id, u.username 
--         FROM users as u 
--         WHERE u.username = 'carterscott'
--     )
--     UNION
--     (
--         SELECT f.id, f.username
--         FROM users as u
--         INNER JOIN "following" as m
--             ON u.id=m.user_id
--         INNER JOIN users as f
--             ON m.following_id=f.id
--         WHERE u.username = 'carterscott'
--     )
-- ) as u
-- INNER JOIN "posts" as p
--     ON u.id = p.user_id
-- ORDER BY p.pub_date desc;


CREATE VIEW v_news_feed AS
(SELECT a.post_id, a.follower_id, a.follower, a.creator_id, a.creator FROM (
( 
   SELECT p.id as post_id,
      u2.id as follower_id, u2.username as follower,
      f.following_id as creator_id, u1.username as creator
   FROM posts p
   INNER JOIN following f ON
      f.user_id = p.user_id
   INNER JOIN users u1 ON
      f.following_id = u1.id
   INNER JOIN users u2 ON
      f.user_id = u2.id
)
UNION
(
   SELECT p.id as post_id,
      p.user_id as follower_id, u.username as follower,
      u.id as creator_id, u.username as creator
   FROM posts p
   INNER JOIN users u ON
   p.user_id = u.id
)) as a
ORDER by a.follower_id);
