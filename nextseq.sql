-- might be needed
-- SET GLOBAL log_bin_trust_function_creators = 1;

CREATE TABLE `sequence_data` (
    `sequence_name` varchar(100) NOT NULL,
    `sequence_increment` int(11) unsigned NOT NULL DEFAULT 1,
    `sequence_min_value` int(11) unsigned NOT NULL DEFAULT 1,
    `sequence_max_value` bigint(20) unsigned NOT NULL DEFAULT 18446744073709551615,
    `sequence_cur_value` bigint(20) unsigned DEFAULT 1,
    `sequence_cycle` boolean NOT NULL DEFAULT FALSE,
    PRIMARY KEY (`sequence_name`)
) ENGINE=MyISAM;

delimiter //
CREATE FUNCTION `nextval` (`seq_name` varchar(100))
RETURNS bigint(20) NOT DETERMINISTIC
BEGIN
    DECLARE cur_val bigint(20);
 
    SELECT
        sequence_cur_value INTO cur_val
    FROM
        sequence_data
    WHERE
        sequence_name = seq_name
    ;
 
    IF cur_val IS NOT NULL THEN
        UPDATE
            sequence_data
        SET
            sequence_cur_value = IF (
                (sequence_cur_value + sequence_increment) > sequence_max_value,
                IF (
                    sequence_cycle = TRUE,
                    sequence_min_value,
                    NULL
                ),
                sequence_cur_value + sequence_increment
            )
        WHERE
            sequence_name = seq_name
        ;
    END IF;
 
    RETURN cur_val;
END

CREATE FUNCTION `currval`(`seq_name` varchar(100))
RETURNS bigint(20) NOT DETERMINISTIC
BEGIN
    DECLARE cur_val bigint(20);
 
    SELECT
        sequence_cur_value INTO cur_val
    FROM
        sequence_data
    WHERE
        sequence_name = seq_name
    ;
 
    RETURN cur_val;
END

CREATE FUNCTION `setval` (`seq_name` varchar(100), `new_val` bigint(20))
RETURNS bigint(20) NOT DETERMINISTIC
BEGIN
    UPDATE
		sequence_data
	SET
		sequence_cur_value = new_val
    WHERE
        sequence_name = seq_name
    ;
 
    RETURN new_val;
END
//
delimiter ;

-- insert new sequence
-- INSERT INTO sequence_data (sequence_name) VALUE ('sq_my_sequence');

-- usage:
-- SELECT nextval('sq_my_sequence') as nextval
-- SELECT currval('sq_my_sequence') as currval
-- SELECT setval('sq_my_sequence', int_new_val) as newval
