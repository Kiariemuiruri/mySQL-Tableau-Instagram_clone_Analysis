/* We want to record all unfollows automatically
We use SQL triggers to automatically track transaction background*/

Delimiter $$

CREATE TRIGGER unfollow
     AFTER DELETE ON Follows FOR EACH ROW
     BEGIN
        INSERT INTO Unfollows
		  SET
			follower_id = OLD.follower_id,
			followee_id = OLD.followee_id;
	 END;
     
$$  
