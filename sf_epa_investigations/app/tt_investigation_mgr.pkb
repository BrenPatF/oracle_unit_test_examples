CREATE OR REPLACE PACKAGE BODY TT_Investigation_Mgr AS
/***************************************************************************************************
Name: TT_Investigation_Mgr.pkb                   Author: Brendan Furey                      Date: 24-Aug-2019

Package body component in the plsql_network module. 

The module contains a PL/SQL package for the efficient analysis of networks that can be specified
by a view representing their node pair links. The package has a pipelined function that returns a
record for each link in all connected subnetworks, with the root node id used to identify the
subnetwork that a link belongs to. Examples are included showing how to call the function from SQL
to list a network in detail, or at any desired level of aggregation.

    GitHub: https://github.com/BrenPatF/plsql_network  (31 July 2016)
    Blog:   http://aprogrammerwrites.eu/?p=1426 (10 May 2015)

PACKAGES
====================================================================================================
|  Package      |  Notes                                                                           |
|===================================================================================================
|  Net_Pipe     |  Package with pipelined function for network analysis                            |
----------------------------------------------------------------------------------------------------
| *TT_Investigation_Mgr* |  Unit testing the Net_Pipe package. Depends on the module trapit_oracle_tester   |
====================================================================================================

This file has the TT_Investigation_Mgr package body. See README for API specification and examples of use.

***************************************************************************************************/

/***************************************************************************************************

add_Investigations: Insert investigation records to the investigation_details table from an input
                   array of triples

***************************************************************************************************/
PROCEDURE add_Investigations(
            p_investigation_2lis           L2_chr_arr) IS -- list of investigation triples
BEGIN

  FOR i IN 1..p_investigation_2lis.COUNT LOOP

    INSERT INTO investigation_details(
                    investigation_id,
                    spray_id,
                    pesticide_id
    ) VALUES (
                    p_investigation_2lis(i)(1), 
                    p_investigation_2lis(i)(2), 
                    p_investigation_2lis(i)(3)
    );

  END LOOP;

END add_Investigations;

/***************************************************************************************************

cursor_To_List: Call Utils Cursor_To_List function, passing an open cursor, and delimiter, and 
                return the resulting list of delimited records

***************************************************************************************************/
FUNCTION do_Call(
            p_investigation_lis            L1_chr_arr)   -- list of investigation triples
            RETURN                         L1_chr_arr IS -- list of delimited records
  l_ret_lis             L1_chr_arr;
BEGIN

  Investigation_Mgr.Pack_Details(
      p_investigation_id  => p_investigation_lis(1),
      p_spray_id          => p_investigation_lis(2),
      p_pesticide_id      => p_investigation_lis(3)
  );
  SELECT Utils.Join_Values(
                  investigation_id,
                  spray_id,
                  pesticide_id)
    BULK COLLECT
    INTO l_ret_lis
    FROM investigation_details
   ORDER BY id;
  RETURN l_ret_lis;

END do_Call;

/***************************************************************************************************

Purely_Wrap_Investigation_Mgr: Unit test wrapper function for Net_Pipe network analysis package

    Returns the 'actual' outputs, given the inputs for a scenario, with the signature expected for
    the Math Function Unit Testing design pattern, namely:

      Input parameter: 3-level list (type L3_chr_arr) with test inputs as group/record/field
      Return Value: 2-level list (type L2_chr_arr) with test outputs as group/record (with record as
                   delimited fields string)

***************************************************************************************************/
FUNCTION Purely_Wrap_Investigation_Mgr(
            p_inp_3lis                     L3_chr_arr)   -- input level 3 list (group, record, field)
            RETURN                         L2_chr_arr IS -- output list of lists (group, record)

  l_act_2lis                     L2_chr_arr := L2_chr_arr();
BEGIN

  add_Investigations(p_investigation_2lis => p_inp_3lis(1));
  l_act_2lis.EXTEND;
  l_act_2lis(1) := do_Call(p_investigation_lis => p_inp_3lis(2)(1));
  ROLLBACK;
  RETURN l_act_2lis;

END Purely_Wrap_Investigation_Mgr;

END TT_Investigation_Mgr;
/
SHO ERR