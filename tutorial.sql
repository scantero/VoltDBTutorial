

CREATE TABLE towns (
    town VARCHAR(64),
    state VARCHAR(2),
    state_num TINYINT NOT NULL,
    county VARCHAR(64),
    county_num SMALLINT NOT NULL,
    elevation INTEGER
 );
 CREATE INDEX town_idx ON towns (state_num, county_num);

 CREATE TABLE people (
    state_num TINYINT NOT NULL,
    county_num SMALLINT NOT NULL,
    state VARCHAR(20),
    county VARCHAR(64),
    population INTEGER
 );

 CREATE TABLE states (
   abbreviation VARCHAR(20),
   state_num TINYINT,
   name VARCHAR(20),
   PRIMARY KEY (state_num)
 );

 CREATE INDEX people_idx ON people (state_num, county_num);


PARTITION TABLE towns ON COLUMN state_num;
PARTITION TABLE people ON COLUMN state_num;

CREATE TABLE nws_event (
   id VARCHAR(256) NOT NULL,
   type VARCHAR(128),
   severity VARCHAR(128),
   SUMMARY VARCHAR(1024),
   starttime TIMESTAMP,
   endtime TIMESTAMP,
   updated TIMESTAMP,
   PRIMARY KEY (id)
);

CREATE TABLE local_event (
    state_num TINYINT NOT NULL,
    county_num SMALLINT NOT NULL,
    id VARCHAR(256) NOT NULL
);

CREATE INDEX local_event_idx ON local_event (state_num, county_num);
CREATE INDEX nws_event_idx ON nws_event (id);

PARTITION TABLE local_event ON COLUMN state_num;

CREATE PROCEDURE leastpopulated 
   PARTITION ON TABLE people COLUMN state_num
AS 
   SELECT TOP 1 county, abbreviation, population
     FROM people, states WHERE people.state_num=?
     AND people.state_num=states.state_num
     ORDER BY population ASC;


