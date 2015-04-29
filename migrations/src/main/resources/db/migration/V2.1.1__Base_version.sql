/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

# Create Summary tables

DROP TABLE IF EXISTS `summary_tenant_jobs`;
CREATE TABLE `summary_tenant_jobs` (
  `id` int(11) unsigned NOT NULL,
  `status` varchar(16) NOT NULL,
  `count` double NOT NULL DEFAULT '0',
  `tenant_id` varchar(128) NOT NULL DEFAULT '',
  PRIMARY KEY (`status`,`tenant_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

DROP TABLE IF EXISTS `summary_user_jobs`;
CREATE TABLE `summary_user_jobs` (
  `id` int(11) unsigned NOT NULL,
  `owner` varchar(32) NOT NULL,
  `status` varchar(16) NOT NULL,
  `count` double NOT NULL DEFAULT '0',
  `tenant_id` varchar(128) NOT NULL DEFAULT '',
  PRIMARY KEY (`owner`,`status`,`tenant_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

# Increment tenant job count by status 

DROP TRIGGER IF EXISTS t_job_add_each;
DELIMITER $$
CREATE TRIGGER t_job_add_each AFTER INSERT ON jobs FOR EACH ROW
BEGIN
  INSERT INTO summary_tenant_jobs (status, count, tenant_id) VALUES (NEW.status, 1, NEW.tenant_id)
  ON DUPLICATE KEY UPDATE 
  	count = (count + 1);
  	
  INSERT INTO summary_user_jobs (owner, status, count, tenant_id) VALUES (NEW.owner, NEW.status, 1, NEW.tenant_id)
  ON DUPLICATE KEY UPDATE 
  	count = (count + 1);
END $$ 
DELIMITER ;

# Decrement tenant job count by status 

DROP TRIGGER IF EXISTS t_job_delete_each;
DELIMITER $$
CREATE TRIGGER t_job_delete_each AFTER DELETE ON jobs FOR EACH ROW
BEGIN
  UPDATE summary_tenant_jobs
    SET count = (count - 1) 
    WHERE status = OLD.status and tenant_id = OLD.tenant_id;
  
  UPDATE summary_user_jobs
    SET count = (count - 1) 
    WHERE owner = OLD.owner and status = OLD.status and tenant_id = OLD.tenant_id;
END $$

DELIMITER ;

# Update tenant job count by status 

DROP TRIGGER IF EXISTS t_job_update_each;
DELIMITER $$
CREATE TRIGGER t_job_update_each AFTER UPDATE ON jobs FOR EACH ROW
BEGIN
  IF (OLD.status <> NEW.status) THEN
	  UPDATE summary_tenant_jobs s
	    SET s.count = s.count - 1 
	    WHERE s.status = OLD.status and s.tenant_id = OLD.tenant_id;
	    
	  UPDATE summary_user_jobs s
	    SET s.count = s.count - 1 
	    WHERE owner = OLD.owner and status = OLD.status and tenant_id = OLD.tenant_id;
	
	  INSERT INTO summary_tenant_jobs (status, count, tenant_id) VALUES (NEW.status, 1, NEW.tenant_id)
	  ON DUPLICATE KEY UPDATE
	    count = (count + 1);
	  
	  INSERT INTO summary_user_jobs (owner, status, count, tenant_id) VALUES (NEW.owner, NEW.status, 1, NEW.tenant_id)
	  ON DUPLICATE KEY UPDATE
	    count = (count + 1);
  END IF;
END $$
DELIMITER ; 