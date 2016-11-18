# VoltDBTutorial

Tutorial de VoltDB según los pasos del siguiente link:

https://docs.voltdb.com/tutorial/preface.php

En este caso de los puntos del 1 al 6.

# Uso VoltDB

## Tutorial 1
Para lanzar VoltDB necesitamos ejecutar en un terminal las siguientes instrucciones y dejarlo abierto durante todo el tiempo que estemos usando la base de datos, pues
en cuanto lo cerremos perderemos los datos. Para volver a tenerlos disponibles tendremos que volver a lanzar VoltDB y cargar de nuevo los datos.

Terminal 1: Este terminal lo mantendremos abierto
$ export PATH=/opt/voltdb/bin:$PATH
$ enable-voltdb
$ voltdb init --force
$ voltdb start

Es posible que el comando enable-voltdb en un ordenador fuera de los laboratorios no sea necesario.

Terminal 2: Aquí es donde realizaremos las acciones que necesitemos en nuestra BD
$ export PATH=/opt/voltdb/bin:$PATH
$ enable-voltdb

En un archivo tutorial.sql introduciremos todas las tablas que queremos crear. En este caso, por ahora definiremos la tabla towns:

CREATE TABLE towns (
   town VARCHAR(64),
   state VARCHAR(2),
   state_num TINYINT NOT NULL,
   county VARCHAR(64),
   county_num SMALLINT NOT NULL,
   elevation INTEGER
);


##Tutorial 2

Definimos la tabla people debajo de la tabla towns, que añadiremos al archivo tutorial.sql:

CREATE TABLE people (
  state_num TINYINT NOT NULL,
  county_num SMALLINT NOT NULL,
  state VARCHAR(20),
  county VARCHAR(64),
  population INTEGER
);

Además de las tablas, vamos a crear unos índices que nos ayuden a acceder más rápidamente a conjuntos de datos que usemos de forma más frecuente. Necesitaremos acceder a menudo a las parejas de datos (state_num, county_num), tanto en la tabla de towns como en la tabla de people, por lo que es adecuado crear dos índices para ambos casos. Para ello añadimos al archivo tutorial.sql las siguientes líneas:

CREATE INDEX town_idx ON towns (state_num, county_num);
CREATE INDEX people_idx ON people (state_num, county_num);

Para crear las tablas y tenerlas en memoria, necesitamos cargar el archivo tutorial.sql:
Continuando en el Terminal 2:

Terminal 2:
$ sqlcmd
1> file tutorial.sql;

Una vez que tengamos cargadas las nuevas tablas, tendremos que rellenar los campos de ambas haciendo uso de los datos que tenemos almacenados en los archivos towns.txt y people.txt. Para que las líneas siguientes funcionen correctamente, necesitamos tener los archivos towns.txt y people.txt bajo el mismo directorio que tutorial.sql, de lo contrario tendremos que especificar la ruta de los archivos .txt para que los encuentre:

Terminal 2:
$ csvloader --file people.txt --skip 1 people

Terminal 2:
$ csvloader --separator "|"  --skip 1   --file towns.txt  towns

##Tutorial 3

Partitioned Tables

Para agilizar el acceso a las tablas con muchas líneas y para permitir el acceso en paralelo a ellas desde varios puntos, se utilizan las particiones referentes a un campo de una tabla. Las particiones las maneja VoltDB, de modo que nosotros sólo tenemos que especificar el campo que queremos particionar. Para realizar las particiones que vamos a usar en nuestra BD añadiremos a nuestro archivo tutorial.sql las siguientes líneas:

PARTITION TABLE towns ON COLUMN state_num;
PARTITION TABLE people ON COLUMN state_num;


#Tutorial 4

Para evitar la duplicación de datos en las tablas towns y people al tener ambas el campo state ('state name'), definiremos una nueva tabla states que añadiremos a nuestro tutorial.sql:

CREATE TABLE states (
   abbreviation VARCHAR(20),
   state_num TINYINT,
   name VARCHAR(20),
   PRIMARY KEY (state_num)
);

Ahora ya podemos eliminar el campo state en ambas tablas:

CREATE TABLE towns (
   town VARCHAR(64),
--   state VARCHAR(20),
   state_num TINYINT NOT NULL,
   county VARCHAR(64),
   county_num SMALLINT NOT NULL,
   elevation INTEGER
);
CREATE TABLE people (
  state_num TINYINT NOT NULL,
  county_num SMALLINT NOT NULL,
--  state VARCHAR(20),
  town VARCHAR(64),
  population INTEGER
);

Para modificar las tablas anteriores también podemos añadir las siguiente líneas:

$ ALTER TABLE towns DROP COLUMN state;
$ ALTER TABLE people DROP COLUMN state;

Tanto las particiones como las nuevas tablas cambian el schema de la BD, por lo tanto necesitaremos lanzar de nuevo VoltDB, cargar la nueva estructura de nuestra BD y rellenar las tablas.
Cada vez que añadamos algún nuevo índice, una nueva partición, o redefinamos alguna tabla cambiando alguno de sus campos, necesitaremos cargar todo de nuevo.

 Terminal 1:
 $voltadmin shutdown
 $voltdb init --force
 $voltdb start

 Terminal 2:
 $ sqlcmd
 1> file tutorial.sql;
 2> exit
 $ csvloader --file people.txt --skip 1 people
 $ csvloader --separator "|"  --skip 1   --file towns.txt  towns
 $ csvloader --skip 1 -f states.csv states


#Tutorial 5

##Stored Procedures

 Los procedimientos almacenados nos permiten ejecutar querys y poder hacer una llamada a estas querys que estarán almacenadas en nuestro servidor, evitando que se tengan que estar escribiendo cada vez que necesitemos realizar esa búsqueda. También nos permiten definir el quivalente a las transacciones, evitando que se interrumpan durante su ejecución. Nos devuelven igual que las búsquedas o las transacciones una tabla.

 Vamos a crear el procedimiento leastpopulated, que utilizará la partición que definimos anteriormente sobre la columna state_num para agilizar la búsqueda (no podremos utilizar una partición en un procedimiento que previamente no esté definida en nuestra BD), y que nos devolverá los condados de un estado ordenados por número de habitantes de menor a mayor.

 Las interrogaciones nos permiten definir variables al llamar al procedimiento. El número de interrogaciones nos indicará el número de variables a incluir en la llamada al procedimiento. En este caso tan sólo tenemos el número del estado que queremos consultar.


 CREATE PROCEDURE leastpopulated
    PARTITION ON TABLE people COLUMN state_num
 AS
    SELECT TOP 1 county, abbreviation, population
      FROM people, states WHERE people.state_num=?
      AND people.state_num=states.state_num
      ORDER BY population ASC;

(Para ejecutar el procedure:
$ sqlcmd
$ exec leastpopulated 6;)

Añadimos el procedimiento a nuestro archivo tutorial.sql

##Compiling Java Stored Procedures

Los procedimientos pueden estar almacenados en un archivo java, y se pueden definir en nuestra BD llamando a esa clase java. Lo definiremos así:

CREATE PROCEDURE
  PARTITION ON TABLE people COLUMN state_num  
  FROM CLASS UpdatePeople;

Añadimos el procedimiento a nuestro tutorial.sql

Como hemos modificado nuestra BD tendremos que volver a lanzarlo todo como hicimos anteriormente. Pero en este caso, al usar una clase de java, tendremos que compilar el archivo al que nos referimos para que al cargar tutorial.sql no nos salte error. Para ello:

Terminal 1:
$voltadmin shutdown
$voltdb init --force
$voltdb start

Terminal 2:
$ javac -cp "$CLASSPATH:/opt/voltdb/voltdb/*"  UpdatePeople.java              **  
$ jar cvf UpdatePeople.jar *.class                                            **
$ sqlcmd
1> load classes UpdatePeople.jar;
2> file tutorial.sql;
3> exit
$ csvloader --file people.txt --skip 1 people
$ csvloader --separator "|"  --skip 1   --file towns.txt  towns
$ csvloader --skip 1 -f states.csv states

#Tutorial 6

##Client Applications

  Para crear una aplicación cliente seguiremos los siguientes pasos:

  1) Crear una conexión cliente a la BD
  2) Hacer una o más llamadas a procedimientos almacenados e interpretar los resultados
  3) Cerrar la conexión cuando el cliente haya finalizado

Para que el cliente pueda crear alertas sobre una ubicación específica y consultar esas alertas, vamos a definir dos nuevas tablas y dos nuevos procedimientos que el cliente pueda usar como aplicaciones, que añadiremos al archivo weather.sql:

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

CREATE PROCEDURE FindAlert AS
   SELECT id, updated FROM nws_event
   WHERE id = ?;

CREATE PROCEDURE FROM CLASS LoadAlert;

CREATE PROCEDURE GetAlertsByLocation
   PARTITION ON TABLE local_event COLUMN state_num
   AS SELECT w.id, w.summary, w.type, w.severity,
             w.starttime, w.endtime
             FROM nws_event as w, local_event as l
             WHERE l.id=w.id and
                   l.state_num=? and l.county_num = ? and
                   w.endtime > TO_TIMESTAMP(MILLISECOND,?)
             ORDER BY w.endtime;

Esta nueva parte de la BD la necesitamos cargar en nuestro Terminal 2 que es el que estamos utilizando como servidor. De nuevo podemos observar que uno de los procedimientos está utilizando la clase LoadAlert, por lo que tendremos que proceder como antes, compilando el archivo java, y después cargando el archivo .sql:

Terminal 2:
$ javac -cp "$CLASSPATH:/opt/voltdb/voltdb/*"  LoadAlert.java                 **
$ jar cvf storedprocs.jar *.class                                             **
$ sqlcmd
1> load classes storedprocs.jar;
2> file weather.sql;


##Creating the LoadWeather Client Application

  Read and parse the NWS alerts feed.

  For each alert, first check if it already exists in the database using the FindAlert procedure.

  · If yes, move on.

  · If no, insert the alert using the LoadAlert procedure.

##Running the LoadWeather Application
->Simply add the location of the VoltDB client library to the environment variable PYTHONPATH. For example, if VoltDB is installed in your home directory as the folder ~/voltdb, the command to use is:

$ export PYTHONPATH="$HOME/voltdb/lib/python/"

->You will also need weather alerts data to load.

$ python LoadWeather.py < data/alerts.xml

->Or you can pipe the most recent alerts directly from the NWS web site:

$ curl https://alerts.weather.gov/cap/us.php?x=0 | python LoadWeather.py


##Creating the GetWeather Application

##VoltDB in User Applications

##VoltDB in High Performance Applications

##Running the GetWeather Application
