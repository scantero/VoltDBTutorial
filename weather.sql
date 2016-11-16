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
