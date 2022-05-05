CREATE TABLE transition(
  a ENUM('a', 'b', 'c'),
  b ENUM('a', 'b', 'c'),
  PRIMARY KEY (a, b)
);

CREATE TABLE machine(
  id INT PRIMARY KEY AUTO_INCREMENT,
  state ENUM('a', 'b', 'c') NOT NULL DEFAULT 'a'
);


DELIMITER //

CREATE TRIGGER machine_transition_u
BEFORE UPDATE ON machine
FOR EACH ROW BEGIN
IF NOT EXISTS(SELECT * FROM transition WHERE a=OLD.state AND b=NEW.state) THEN
  SET @msg = CONCAT('Illegal state transition: ', OLD.state, ' -> ', NEW.state);
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT=@msg;
END IF;
END //

DELIMITER ;

CREATE USER IF NOT EXISTS u@'localhost' IDENTIFIED BY '';
REVOKE ALL PRIVILEGES ON mystm.* FROM u@'localhost'; /* reproducible */
GRANT SELECT, INSERT(id), UPDATE(state), DELETE ON mystm.machine TO u@'localhost';
