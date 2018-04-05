DELIMITER $$
DROP PROCEDURE IF EXISTS `ClearClData`$$
CREATE PROCEDURE `ClearClData`()
BEGIN
DECLARE done INT DEFAULT FALSE;
DECLARE cl_version INTEGER;
DECLARE cl_table_name TEXT;
DECLARE curs1 CURSOR FOR SELECT `version_id`, `changelog_name` FROM enterprise_mview_metadata;
DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
OPEN curs1;
read_loop: LOOP
FETCH curs1 INTO cl_version,cl_table_name;
IF done THEN
LEAVE read_loop;
END IF;
SET @varSQL = CONCAT('DELETE FROM ', cl_table_name,' WHERE version_id < ', cl_version);
prepare stmt from @varSQL;
execute stmt;
drop prepare stmt;
set @optimize:=CONCAT('optimize table ',cl_table_name);
PREPARE `sql` FROM @optimize;
EXECUTE `sql`;
DEALLOCATE PREPARE `sql`;
END LOOP;
CLOSE curs1;
END$$
DELIMITER ;
