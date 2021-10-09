CREATE OR REPLACE PACKAGE TT_Feuertips_13_V2 AS
/***************************************************************************************************
Name: TT_Feuertips_13_V2.pkb                   Author: Brendan Furey               Date: 28-Aug-2021

Package spec component in the oracle_unit_test_examples module. 

The module contains 

    GitHub: https://github.com/BrenPatF/oracle_unit_test_examples
    Blog:   http://aprogrammerwrites.eu/?p=

PACKAGES
====================================================================================================
|  Package             |  Notes                                                                    |
|==================================================================================================|
|  Feuertips_13_V2     |  Package with version 1 bug-fixed from original                           |
|--------------------------------------------------------------------------------------------------|
| *TT_Feuertips_13_V2* |  Unit testing the Feuertips_13_V2 package. Depends on the module          |
|                      |  trapit_oracle_tester                                                     |
====================================================================================================

This file has the TT_Feuertips_13_V2 package spec

***************************************************************************************************/
FUNCTION Purely_Wrap_Feuertips_13_POC(
              p_inp_3lis                     L3_chr_arr)
              RETURN                         L2_chr_arr;

END TT_Feuertips_13_V2;
/
