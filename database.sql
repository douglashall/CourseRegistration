drop table registration_action cascade constraints;
drop table registration_context cascade constraints;
drop table registration_context_state cascade constraints;
drop table registration_state cascade constraints;
drop table registration_student cascade constraints;
drop table student_course cascade constraints;

drop sequence registration_action_id_seq;
drop sequence registration_ctx_id_seq;
drop sequence registration_ctx_state_id_seq;
drop sequence registration_state_id_seq;
drop sequence registration_student_id_seq;
drop sequence student_course_id_seq;

create table registration_action (id number(19,0) not null, action varchar2(255) not null, school_id number(19,0), state_after_id number(19,0) not null, state_before_id number(19,0), primary key (id));
create table registration_context (id number(19,0) not null, date_processed date, processed number(10,0) not null, processed_by varchar2(255), primary key (id));
create table registration_context_state (id number(19,0) not null, created_by varchar2(255) not null, date_created date not null, registration_context_id number(19,0) not null, registration_state_id number(19,0) not null, primary key (id));
create table registration_state (id number(19,0) not null, state varchar2(255) not null, terminal number(10,0) not null, type varchar2(255) not null, primary key (id));
create table registration_student (id number(19,0) not null, degree_year number(19,0) not null, home_school_id varchar2(255) not null, program_department varchar2(255) not null, user_id varchar2(255) not null, primary key (id));
create table student_course (id number(19,0) not null, active number(10,0) not null, course_instance_id number(19,0) not null, date_created date not null, degree_year number(19,0), grading_option varchar2(255), home_school_id varchar2(255), last_updated date not null, level_option varchar2(255), program_department varchar2(255), registration_context_id number(19,0), user_id varchar2(255) not null, primary key (id));

alter table registration_action add constraint FKD620007CCD56B6E0 foreign key (state_before_id) references registration_state;
alter table registration_action add constraint FKD620007CCE16797F foreign key (state_after_id) references registration_state;
alter table registration_context_state add constraint FK7730A0FB60FB14C2 foreign key (registration_context_id) references registration_context;
alter table registration_context_state add constraint FK7730A0FBBF6D4B82 foreign key (registration_state_id) references registration_state;
alter table student_course add constraint FKB0A3729F60FB14C2 foreign key (registration_context_id) references registration_context;
alter table student_course add constraint FKB0A3729F8AD3A3BB foreign key (course_instance_id) references course_instance;

create sequence registration_action_id_seq;
create sequence registration_ctx_id_seq;
create sequence registration_ctx_state_id_seq;
create sequence registration_state_id_seq;
create sequence registration_student_id_seq;
create sequence student_course_id_seq;

INSERT INTO registration_state (id, state, terminal, type) VALUES (registration_state_id_seq.nextval, 'Approved', 1, 'approve');
INSERT INTO registration_state (id, state, terminal, type) VALUES (registration_state_id_seq.nextval, 'Denied', 1, 'deny');
INSERT INTO registration_state (id, state, terminal, type) VALUES (registration_state_id_seq.nextval, 'Awaiting Faculty Approval', 0, 'pending');

INSERT INTO registration_action (id, school_id, action, state_before_id, state_after_id) VALUES (registration_action_id_seq.nextval, null, 'submit', null, 3);
INSERT INTO registration_action (id, school_id, action, state_before_id, state_after_id) VALUES (registration_action_id_seq.nextval, null, 'register', null, 1);
INSERT INTO registration_action (id, school_id, action, state_before_id, state_after_id) VALUES (registration_action_id_seq.nextval, null, 'faculty_approve', 3, 1);
INSERT INTO registration_action (id, school_id, action, state_before_id, state_after_id) VALUES (registration_action_id_seq.nextval, null, 'faculty_deny', 3, 2);