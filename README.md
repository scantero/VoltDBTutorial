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

Terminal 1:
$ cd data
$ csvloader --file people.txt --skip 1 people

Terminal 1:
$ cd data
$ csvloader --separator "|"  --skip 1   --file towns.txt  towns

##Tutorial 3
Partitioned Tables

PARTITION TABLE towns ON COLUMN state_num;
PARTITION TABLE people ON COLUMN state_num;

#Tutoral 4
Creamos la tabla states y vamos a modificar las tablas anteriores porque les sobran columnas.

$ ALTER TABLE towns DROP COLUMN state;
$ ALTER TABLE people DROP COLUMN state;
