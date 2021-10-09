DECLARE

  procedure setup_test_data as
  begin
    -- Make sure the tables we're using as input are empty
    delete from log_deathstar_room_actions;
    delete from log_deathstar_room_access;
    delete from log_deathstar_room_repairs;

    -- Add some test data for our tests
    insert into log_deathstar_room_access ( key_id, room_name, character_name ) values (1, 'Bridge', 'Darth Vader');
    insert into log_deathstar_room_access ( key_id, room_name, character_name ) values (1, 'Bridge', 'Mace Windu');
    insert into log_deathstar_room_access ( key_id, room_name, character_name ) values (2, 'Engine Room 1', 'R2D2');

    insert into log_deathstar_room_actions ( key_id, action, done_by ) values ( 1, 'Enter', 'Darth Vader');
    insert into log_deathstar_room_actions ( key_id, action, done_by ) values ( 1, 'Sit down', 'Darth Vader');
    insert into log_deathstar_room_actions ( key_id, action, done_by ) values ( 2, 'Enter', 'R2D2');
    insert into log_deathstar_room_actions ( key_id, action, done_by ) values ( 1, 'Enter', 'Mace Windu');
    insert into log_deathstar_room_actions ( key_id, action, done_by ) values ( 1, 'Activate Lightsaber', 'Mace Windu');
    insert into log_deathstar_room_actions ( key_id, action, done_by ) values ( 1, 'Jump up', 'Darth Vader');
    insert into log_deathstar_room_actions ( key_id, action, done_by ) values ( 2, 'Hack Console', 'R2D2');
    insert into log_deathstar_room_actions ( key_id, action, done_by ) values ( 1, 'Activate Lightsaber', 'Darth Vader');
    insert into log_deathstar_room_actions ( key_id, action, done_by ) values ( 1, 'Attack', 'Mace Windu');
    insert into log_deathstar_room_actions ( key_id, action, done_by ) values ( 2, 'Beep', 'R2D2');

    insert into log_deathstar_room_repairs ( key_id, action, repair_completion, repaired_by) values ( 1, 'Inspect', '50%', 'The Repairman');
    insert into log_deathstar_room_repairs ( key_id, action, repair_completion, repaired_by) values ( 1, 'Analyze', '53%', 'The Repairman');
    insert into log_deathstar_room_repairs ( key_id, action, repair_completion, repaired_by) values ( 1, 'Investigate', '57%', 'The Repairman');
    insert into log_deathstar_room_repairs ( key_id, action, repair_completion, repaired_by) values ( 2, 'Analyze', '25%', 'The Repairman');
    insert into log_deathstar_room_repairs ( key_id, action, repair_completion, repaired_by) values ( 1, 'Fix it', '95%', 'Lady Skillful');
    insert into log_deathstar_room_repairs ( key_id, action, repair_completion, repaired_by) values ( 2, 'Fix it', '100%', 'Lady Skillful');
  end;
BEGIN
    setup_test_data;
END;
/
COLUMN key_id FORMAT 990
BREAK ON key_id
COLUMN room_name FORMAT A15
COLUMN character_name FORMAT A15
COLUMN action FORMAT A20
COLUMN done_by FORMAT A15
COLUMN repair_completion FORMAT A15
COLUMN repaired_by FORMAT A15
PROMPT log_deathstar_room_access
SELECT key_id, room_name, character_name
  FROM log_deathstar_room_access
ORDER BY 1, 2, 3
/
PROMPT log_deathstar_room_actions
SELECT key_id, action, done_by
  FROM log_deathstar_room_actions
ORDER BY 1, 2, 3
/
PROMPT log_deathstar_room_repairs
SELECT key_id, action, repair_completion, repaired_by
  FROM log_deathstar_room_repairs
ORDER BY 1, 2, 3
/
DECLARE
  PROCEDURE List_File(p_file_name VARCHAR2) IS
    l_ret_lis     L1_chr_arr;
  BEGIN

    l_ret_lis := Utils.Read_File(p_file_name => p_file_name); 
    Utils.Delete_File(p_file_name => p_file_name);
    Utils.W('.');
    Utils.W(Utils.Heading('File ' || p_file_name || ' has lines...'));
    Utils.W(l_ret_lis);

  END List_File;

BEGIN

  Feuertips_13.Feuertips_13_POC;
  List_File(p_file_name => 'room_action.log');
  List_File(p_file_name => 'room_repair.log');

END;
/
ROLLBACK
/