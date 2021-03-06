CREATE TABLE transition(
  a ENUM('a', 'b', 'c'),
  b ENUM('a', 'b', 'c'),
  PRIMARY KEY (a, b)
);

CREATE TABLE machine(
  id INT PRIMARY KEY AUTO_INCREMENT,
  location VARCHAR(15) NOT NULL /* or whatever */
);

CREATE TABLE machine_log(
  id INT PRIMARY KEY AUTO_INCREMENT,
  machine INT NOT NULL,
  state ENUM('a', 'b', 'c') NOT NULL DEFAULT 'a',
  ts TIMESTAMP,
  UNIQUE (machine, id),
  FOREIGN KEY (machine) REFERENCES machine(id) ON DELETE CASCADE
);

CREATE VIEW machine_state AS
SELECT machine, state, ts
FROM machine_log l
WHERE id=(SELECT MAX(id) FROM machine_log WHERE machine=l.machine);


DELIMITER //

CREATE TRIGGER machine_i
AFTER INSERT ON machine
FOR EACH ROW
INSERT INTO machine_log(machine) VALUES (NEW.id);
END //

CREATE TRIGGER machine_log_i
BEFORE INSERT ON machine_log
FOR EACH ROW BEGIN
DECLARE cur ENUM('a', 'b', 'c');
SELECT state INTO cur FROM machine_state WHERE machine=NEW.machine;
IF cur = NEW.state THEN
  SIGNAL SQLSTATE '23000' SET MESSAGE_TEXT='Duplicate transition';
ELSEIF NOT ISNULL(cur) /* not called by machine_i */
AND NOT EXISTS(SELECT * FROM transition WHERE a=cur AND b=NEW.state) THEN
  SET @msg = CONCAT('Illegal state transition: ', cur, ' -> ', NEW.state);
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT=@msg;
END IF;
END //

CREATE TRIGGER machine_log_d
BEFORE DELETE ON machine_log
FOR EACH ROW BEGIN
IF NOT EXISTS(SELECT * FROM machine_log WHERE machine=OLD.machine AND id>OLD.id) THEN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Can''t forget the state';
END IF;
END //
