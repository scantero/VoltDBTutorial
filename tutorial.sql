CREATE TABLE towns (
   town VARCHAR(64),
--   state VARCHAR(2),
   state_num TINYINT NOT NULL,
   county VARCHAR(64),
   county_num SMALLINT NOT NULL,
   elevation INTEGER
);
CREATE TABLE people (
   state_num TINYINT NOT NULL,
   county_num SMALLINT NOT NULL,
--   state VARCHAR(20),
   county VARCHAR(64),
   population INTEGER
);
CREATE TABLE states (
   abbreviation VARCHAR(20),
   state_num TINYINT,
   name VARCHAR(20),
   PRIMARY KEY (state_num)
);
CREATE INDEX town_idx ON towns (state_num, county_num);
CREATE INDEX people_idx ON people (state_num, county_num);

PARTITION TABLE towns ON COLUMN state_num;
PARTITION TABLE people ON COLUMN state_num;

--Tutorial 5 y 6


-- Da problemas error

--CREATE PROCEDURE leastpopulated
--  PARTITION PROCEDURE leastpopulated ON TABLE people COLUMN state_num
--AS
--    SELECT TOP 1 county, abbreviation, population
--      FROM people, states WHERE people.state_num=?
--      AND people.state_num=states.state_num
--      ORDER BY population ASC;


CREATE PROCEDURE
  PARTITION PROCEDURE ON TABLE people COLUMN state_num
  FROM CLASS UpdatePeople;
