@..\..\install_prereq\initspool install_sf_sn_log_deathstar

-- Log Table: All the rooms in the deathstar that were accessed at some point
DROP TABLE log_deathstar_room_access 
/
create table log_deathstar_room_access
(
  id integer generated always as identity primary key,
  key_id integer,
  room_name varchar2(4000),
  character_name varchar2(4000),
  log_date timestamp default current_timestamp
)
/

-- Log Table: All the actions that happened in a room, but we don't have the room name, just some key_id
DROP TABLE log_deathstar_room_actions 
/
create table log_deathstar_room_actions
(
  id integer generated always as identity primary key,
  key_id integer,
  action varchar2(4000),
  done_by varchar2(4000),
  log_date timestamp default current_timestamp
)
/

-- Log Table: Repairs done in a room, but again we don't have the room name
DROP TABLE log_deathstar_room_repairs 
/
create table log_deathstar_room_repairs
(
  id integer generated always as identity primary key,
  key_id integer,
  action varchar2(4000),
  repair_completion varchar2(100),
  repaired_by varchar2(4000),
  log_date timestamp default current_timestamp
)
/

PROMPT Add the ut records
BEGIN
  Trapit.Add_Ttu('TT_Feuertips_13',    'Purely_Wrap_Feuertips_13_POC',  'UT_EXAMPLES', 'Y', 'sf_sn_log_deathstar.json', 'Feuertips 13 - Base');
  Trapit.Add_Ttu('TT_Feuertips_13_V1', 'Purely_Wrap_Feuertips_13_POC',  'UT_EXAMPLES', 'Y', 'sf_sn_log_deathstar.json', 'Feuertips 13 - v1');
  Trapit.Add_Ttu('TT_Feuertips_13_V2', 'Purely_Wrap_Feuertips_13_POC',  'UT_EXAMPLES', 'Y', 'sf_sn_log_deathstar.json', 'Feuertips 13 - v2');
END;
/
PROMPT Packages creation
PROMPT =================

PROMPT Create package Feuertips_13 in 3 versions
@feuertips_13.pks
@feuertips_13.pkb

@feuertips_13_v1.pks
@feuertips_13_v1.pkb

@feuertips_13_v2.pks
@feuertips_13_v2.pkb

PROMPT Create package TT_Feuertips_13 in 3 versions
@tt_feuertips_13.pks
@tt_feuertips_13.pkb

@tt_feuertips_13_v1.pks
@tt_feuertips_13_v1.pkb

@tt_feuertips_13_v2.pks
@tt_feuertips_13_v2.pkb

PROMPT Run example script
@sf_tip_13_sn_example

@..\..\install_prereq\endspool