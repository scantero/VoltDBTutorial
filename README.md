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

#Tutoral 4
Creamos la tabla states y vamos a modificar las tablas anteriores porque les sobran columnas.

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
