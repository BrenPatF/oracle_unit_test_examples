CREATE OR REPLACE PACKAGE BODY TT_Login_Bursts AS
/***************************************************************************************************
Name: TT_Login_Bursts.pkb               Author: Brendan Furey                      Date: 14-Mar-2021

Package body component in the oracle_unit_test_examples module.

The module contains a simple data model with several views containing different queries for 
reporting the initial event in 'bursts of activity', with login times as the particular domain here.
There is a unit test package for automated testing of the views using the Math Function Unit Testing
design pattern.

    GitHub: https://github.com/BrenPatF/oracle_unit_test_examples
    Blog:   http://aprogrammerwrites.eu/?p=

PACKAGES
====================================================================================================
|  Package          |  Notes                                                                       |
|==================================================================================================|
| *TT_Login_Bursts* |  Unit testing the login views. Depends on the module trapit_oracle_tester    |
====================================================================================================

This file has the TT_Login_Bursts package body
***************************************************************************************************/

/***************************************************************************************************

add_Logins: Inserts input records into logins table

***************************************************************************************************/
PROCEDURE add_Logins(
            p_login_2lis                     L2_chr_arr) IS -- input list of lists for records
BEGIN

  FOR i IN 1..p_login_2lis.COUNT LOOP
    INSERT INTO logins VALUES (p_login_2lis(i)(1), To_Date(p_login_2lis(i)(2), 'DDMMYYYY HH24:MI'));
  END LOOP;

END add_Logins;

/***************************************************************************************************

purely_Wrap_View: Private unit test wrapper function for Utils.View_To_List, with view name passed
                  in by the public functions

    Returns the 'actual' outputs, given the inputs for a scenario, with the signature expected for
    the Math Function Unit Testing design pattern, namely:

      Input parameter: 3-level list (type L3_chr_arr) with test inputs as group/record/field
      Return Value: 2-level list (type L2_chr_arr) with test outputs as group/record (with record as
                   delimited fields string)

***************************************************************************************************/
FUNCTION purely_Wrap_View(
            p_view_name                    VARCHAR2,     -- view name
            p_inp_3lis                     L3_chr_arr)   -- input list of lists (record, field)
            RETURN                         L2_chr_arr IS -- output list of lists (group, record)

  l_act_2lis                     L2_chr_arr := L2_chr_arr();
BEGIN

  DELETE logins;
  add_Logins(p_login_2lis     => p_inp_3lis(1));

  l_act_2lis.EXTEND;
  l_act_2lis(1) := Utils.View_To_List(
                                p_view_name     => p_view_name,
                                p_sel_value_lis => L1_chr_arr('personid', 'block_start_login_time'),
                                p_order_by      => 'personid, block_start_login_time');
  ROLLBACK;
  RETURN l_act_2lis;

END purely_Wrap_View;
/***************************************************************************************************

Purely_Wrap_View_*: Entry point methods for the unit tests. Each one just calls purely_Wrap_API, 
                   passing the view name

***************************************************************************************************/
FUNCTION Purely_Wrap_View_MRE(
            p_inp_3lis                     L3_chr_arr)   -- input level 3 list (group, record, field)
            RETURN                         L2_chr_arr IS -- output list of lists (group, record)
BEGIN

  RETURN purely_Wrap_View(p_view_name => 'Match_Recognize_V',
                          p_inp_3lis  => p_inp_3lis);

END Purely_Wrap_View_MRE;

FUNCTION Purely_Wrap_View_MOD(
            p_inp_3lis                     L3_chr_arr)   -- input level 3 list (group, record, field)
            RETURN                         L2_chr_arr IS -- output list of lists (group, record)
BEGIN

  RETURN purely_Wrap_View(p_view_name => 'Model_V',
                          p_inp_3lis  => p_inp_3lis);

END Purely_Wrap_View_MOD;

FUNCTION Purely_Wrap_View_RSF(
            p_inp_3lis                     L3_chr_arr)   -- input level 3 list (group, record, field)
            RETURN                         L2_chr_arr IS -- output list of lists (group, record)
BEGIN

  RETURN purely_Wrap_View(p_view_name => 'Recursive_SQF_V',
                          p_inp_3lis  => p_inp_3lis);

END Purely_Wrap_View_RSF;

FUNCTION Purely_Wrap_View_ANA(
            p_inp_3lis                     L3_chr_arr)   -- input level 3 list (group, record, field)
            RETURN                         L2_chr_arr IS -- output list of lists (group, record)
BEGIN

  RETURN purely_Wrap_View(p_view_name => 'Analytics_V',
                          p_inp_3lis  => p_inp_3lis);

END Purely_Wrap_View_ANA;

END TT_Login_Bursts;
/
SHO ERR