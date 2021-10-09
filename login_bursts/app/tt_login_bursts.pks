CREATE OR REPLACE PACKAGE TT_Login_Bursts AS
/***************************************************************************************************
Name: TT_Login_Bursts.pks               Author: Brendan Furey                      Date: 07-Mar-2021

Package spec component in the unit_testing_sql module.

The module 

    GitHub: https://github.com/BrenPatF/  (31 July 2016)
    Blog:   http://aprogrammerwrites.eu/? (10 May 2015)

PACKAGES
====================================================================================================
|  Package          |  Notes                                                                       |
|==================================================================================================|
| *TT_Login_Bursts* |  Unit testing the login views. Depends on the module trapit_oracle_tester    |
====================================================================================================

This file has the TT_Login_Bursts package spec

***************************************************************************************************/

FUNCTION Purely_Wrap_View_MRE(
            p_inp_3lis                     L3_chr_arr)
            RETURN                         L2_chr_arr;
FUNCTION Purely_Wrap_View_MOD(
            p_inp_3lis                     L3_chr_arr)
            RETURN                         L2_chr_arr;
FUNCTION Purely_Wrap_View_RSF(
            p_inp_3lis                     L3_chr_arr)
            RETURN                         L2_chr_arr;
FUNCTION Purely_Wrap_View_ANA(
            p_inp_3lis                     L3_chr_arr)
            RETURN                         L2_chr_arr;

END TT_Login_Bursts;
/
