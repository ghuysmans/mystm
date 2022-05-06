DELETE FROM transition;
DELETE FROM machine;
INSERT INTO transition VALUES ('a', 'b'), ('b', 'c');

--insert p
INSERT INTO machine(location) VALUES ('p');
SET @p = LAST_INSERT_ID();

--update p
INSERT INTO machine_log(machine, state) VALUES (@p, 'b');

--insert q
INSERT INTO machine(location) VALUES ('q');

--delete old p
DELETE FROM machine_log WHERE machine=@p AND state='a';

--delete new p (nope)
DELETE FROM machine_log WHERE machine=@p;
