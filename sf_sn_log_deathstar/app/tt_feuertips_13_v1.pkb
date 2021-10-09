CREATE OR REPLACE PACKAGE BODY TT_Feuertips_13_V1 AS
/***************************************************************************************************
Name: TT_Feuertips_13_V1.pkb                   Author: Brendan Furey               Date: 28-Aug-2021

Package body component in the unit_testing_sql module. 

The module contains 

    GitHub: https://github.com/BrenPatF/unit_testing_sql
    Blog:   http://aprogrammerwrites.eu/?p=

PACKAGES
====================================================================================================
|  Package             |  Notes                                                                    |
|==================================================================================================|
|  Feuertips_13_V1     |  Package with version 1 bug-fixed from original                           |
|--------------------------------------------------------------------------------------------------|
| *TT_Feuertips_13_V1* |  Unit testing the Feuertips_13_V1 package. Depends on the module          |
|                      |  trapit_oracle_tester                                                     |
====================================================================================================

This file has the TT_Feuertips_13_V1 package body

***************************************************************************************************/

/***************************************************************************************************

add_Room_Recs: Insert investigation records to the investigation_details table from an input
               array of triples

***************************************************************************************************/
PROCEDURE add_Room_Recs(
            p_room_access_2lis           L2_chr_arr,    -- list of room access triples
            p_room_action_2lis           L2_chr_arr,    -- list of room action triples
            p_room_repair_2lis           L2_chr_arr) IS -- list of room repair quads
BEGIN

  FOR i IN 1..p_room_access_2lis.COUNT LOOP

    INSERT INTO log_deathstar_room_access(
                    key_id, 
                    room_name, 
                    character_name
    ) VALUES (
                    p_room_access_2lis(i)(1), 
                    p_room_access_2lis(i)(2), 
                    p_room_access_2lis(i)(3)
    );

  END LOOP;

  FOR i IN 1..p_room_action_2lis.COUNT LOOP

    INSERT INTO log_deathstar_room_actions(
                    key_id, 
                    action, 
                    done_by
    ) VALUES (
                    p_room_action_2lis(i)(1), 
                    p_room_action_2lis(i)(2), 
                    p_room_action_2lis(i)(3)
    );

  END LOOP;

  FOR i IN 1..p_room_repair_2lis.COUNT LOOP

    INSERT INTO log_deathstar_room_repairs(
                    key_id, 
                    action, 
                    repair_completion, 
                    repaired_by
    ) VALUES (
                    p_room_repair_2lis(i)(1), 
                    p_room_repair_2lis(i)(2), 
                    p_room_repair_2lis(i)(3),
                    p_room_repair_2lis(i)(4)
    );

  END LOOP;

END add_Room_Recs;

/***************************************************************************************************

Purely_Wrap_Investigation_Mgr: Unit test wrapper function for Feuertips_13 demo package

    Returns the 'actual' outputs, given the inputs for a scenario, with the signature expected for
    the Math Function Unit Testing design pattern, namely:

      Input parameter: 3-level list (type L3_chr_arr) with test inputs as group/record/field
      Return Value: 2-level list (type L2_chr_arr) with test outputs as group/record (with record as
                   delimited fields string)

***************************************************************************************************/
FUNCTION Purely_Wrap_Feuertips_13_POC(
            p_inp_3lis                     L3_chr_arr)   -- input level 3 list (group, record, field)
            RETURN                         L2_chr_arr IS -- output list of lists (group, record)

  l_act_2lis                     L2_chr_arr := L2_chr_arr();
BEGIN

  add_Room_Recs(p_room_access_2lis  => p_inp_3lis(1),
                p_room_action_2lis  => p_inp_3lis(2),
                p_room_repair_2lis  => p_inp_3lis(3));
  Feuertips_13_V1.Feuertips_13_POC;
  l_act_2lis.EXTEND(2);
  l_act_2lis(1) := Utils.Read_File(p_file_name => 'room_action.log');  Utils.Delete_File(p_file_name => 'room_action.log');
  l_act_2lis(2) := Utils.Read_File(p_file_name => 'room_repair.log');  Utils.Delete_File(p_file_name => 'room_repair.log');
  ROLLBACK;
  RETURN l_act_2lis;

EXCEPTION
  WHEN OTHERS THEN
    UTL_File.fclose_all;
    RAISE;

END Purely_Wrap_Feuertips_13_POC;

END TT_Feuertips_13_V1;
/
SHO ERR