

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

 CREATE INDEX people_idx ON people (state_num, county_num);

 insert into towns values ('Billerica','Middlesex','MA');
 insert into towns values ('Buffalo','Erie','NY');
 insert into towns values ('Bay View','Erie','OH');

PARTITION TABLE towns ON COLUMN state_num;
PARTITION TABLE people ON COLUMN state_num;
