ALTER TABLE course_meeting ADD course_meeting_primary_key NUMBER;

CREATE SEQUENCE course_meeting_id_seq;

DECLARE
   CURSOR cm_RECS IS SELECT ROWID FROM course_meeting;
BEGIN
   FOR cm_REC IN cm_RECS LOOP
	UPDATE course_meeting SET course_meeting_primary_key = course_meeting_id_seq.nextval WHERE ROWID = cm_REC.ROWID;
   END LOOP;
END;

CREATE OR REPLACE
TRIGGER "COURSEMANAGER"."COURSE_MEETING_ID_TRIG" 
BEFORE INSERT ON course_meeting
REFERENCING NEW AS NEW OLD AS OLD
for each row
begin
  if ( :new.course_meeting_primary_key is null ) then
    SELECT course_meeting_id_seq.nextval INTO :new.course_meeting_primary_key from dual;
  end if;
end;

ALTER TABLE school ADD school_primary_key NUMBER;

CREATE SEQUENCE school_id_seq;

DECLARE
   CURSOR s_RECS IS SELECT ROWID FROM school;
BEGIN
   FOR s_REC IN s_RECS LOOP
	UPDATE school SET school_primary_key = school_id_seq.nextval WHERE ROWID = s_REC.ROWID;
   END LOOP;
END;

INSERT INTO registration_state (id, state, terminal) VALUES (registration_state_id_seq.nextval, 'Approved', 1);
INSERT INTO registration_state (id, state, terminal) VALUES (registration_state_id_seq.nextval, 'Denied', 1);
INSERT INTO registration_state (id, state, terminal) VALUES (registration_state_id_seq.nextval, 'Awaiting Faculty Approval', 0);

INSERT INTO registration_action (id, school_id, action, state_before_id, state_after_id) VALUES (registration_action_id_seq.nextval, null, 'register', null, 3);
INSERT INTO registration_action (id, school_id, action, state_before_id, state_after_id) VALUES (registration_action_id_seq.nextval, null, 'faculty_approve', 3, 1);
INSERT INTO registration_action (id, school_id, action, state_before_id, state_after_id) VALUES (registration_action_id_seq.nextval, null, 'faculty_deny', 3, 2);