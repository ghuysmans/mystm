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

CREATE TRIGGER machine_transition_i
BEFORE INSERT ON machine
FOR EACH ROW
IF NEW.state <> 'a' THEN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Illegal initial state';
END IF //

CREATE TRIGGER machine_transition_u
BEFORE UPDATE ON machine
FOR EACH ROW BEGIN
IF OLD.state<>NEW.state
AND NOT EXISTS(SELECT * FROM transition WHERE a=OLD.state AND b=NEW.state) THEN
  SET @msg = CONCAT('Illegal state transition: ', OLD.state, ' -> ', NEW.state);
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT=@msg;
END IF;
END //
