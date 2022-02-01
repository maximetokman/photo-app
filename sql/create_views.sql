DROP VIEW v_news_feed;

CREATE VIEW v_news_feed AS
SELECT a.post_id, a.follower_id, a.follower, a.creator_id, a.creator FROM (
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
ORDER by a.post_id;

