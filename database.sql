ALTER TABLE course_meeting ADD id NUMBER;

CREATE SEQUENCE course_meeting_id_seq;

DECLARE
   CURSOR cm_RECS IS SELECT ROWID FROM course_meeting;
BEGIN
   FOR cm_REC IN cm_RECS LOOP
	UPDATE course_meeting SET id = course_meeting_id_seq.nextval WHERE ROWID = cm_REC.ROWID;
   END LOOP;
END;

CREATE OR REPLACE
TRIGGER "COURSEMANAGER"."COURSE_MEETING_ID_TRIG" 
BEFORE INSERT ON course_meeting
REFERENCING NEW AS NEW OLD AS OLD
for each row
begin
  if ( :new.id is null ) then
    SELECT course_meeting_id_seq.nextval INTO :new.id from dual;
  end if;
end;
