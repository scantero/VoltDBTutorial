# VoltDBTutorial

Tutorial de VoltDB según los pasos del siguiente link:

https://docs.voltdb.com/tutorial/preface.php

En este caso de los puntos del 1 al 6.

# Uso VoltDB
## Tutorial 1
Terminal 1:
$ voltdb init
$ voltdb start

Terminal 2:
$ sqlcmd

##Tutorial 2

Una vez que creamos la nueva tabla y los índices, podemos cargar el archivo de datos adjunto:

Terminal 2:
$ cd data
$ csvloader --file people.txt --skip 1 people

Terminal 2:
$ cd data
$ csvloader --separator "|"  --skip 1   --file towns.txt  towns

##Tutorial 3
Partitioned Tables

PARTITION TABLE towns ON COLUMN state_num;
PARTITION TABLE people ON COLUMN state_num;
 Esto cambia el schema de la db , por tanto antes :

 Terminal 1:
 $voltadmin shutdown
 $voltdb init --force
 $voltdb start

#Tutorial 4
Creamos la tabla states.

Cargamos los datos a la tabla states:

$ csvloader --skip 1 -f data/states.csv states

Vamos a modificar las tablas anteriores porque les sobran columnas:

$ ALTER TABLE towns DROP COLUMN state;
$ ALTER TABLE people DROP COLUMN state;

#Tutorial 5
 [Part 5: Stored Procedures](https://docs.voltdb.com/tutorial/Part5.php)


 CREATE PROCEDURE leastpopulated
    PARTITION ON TABLE people COLUMN state_num
 AS
    SELECT TOP 1 county, abbreviation, population
      FROM people, states WHERE people.state_num=?
      AND people.state_num=states.state_num
      ORDER BY population ASC;

Para ejecutar el procedure:

$sqlcmd
$exec leastpopulated 6;

##Compiling Java Stored Procedures

1. $ javac -cp "$CLASSPATH:/opt/voltdb/voltdb/*"  UpdatePeople.java
2. $ jar cvf storedprocs.jar *.class
3. $ sqlcmd 1> load classes storedprocs.jar;

#Tutorial 6
  [Part 6: Client Applications](https://docs.voltdb.com/tutorial/Part6.php)

  1. Create a client connection to the database.

  2. Make one of more calls to stored procedures and interpret their results.

  3. Close the connection when you are done.

##Making the Sample Application Interactive

##Designing the Solution

  Two separate applications:

  · One to load the weather advisory data

  · Another to fetch the alerts for a specific location

##Designing the Stored Procedures for Data Access

  Two stored procedures:

  · FindAlert — to determine if a given alert already exists in the database

  · LoadAlert — to insert the information into both the nws_alert and local_alert table

##Creating the LoadWeather Client Application

  Read and parse the NWS alerts feed.

  For each alert, first check if it already exists in the database using the FindAlert procedure.

  · If yes, move on.

  · If no, insert the alert using the LoadAlert procedure.

##Running the LoadWeather Application

##Creating the GetWeather Application

##VoltDB in User Applications

##VoltDB in High Performance Applications

##Running the GetWeather Application
