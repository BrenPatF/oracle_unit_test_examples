@..\..\install_prereq\initspool install_login_bursts
/***************************************************************************************************
Name: install_logins.sql                Author: Brendan Furey                      Date: 14-Mar-2021

Installation script for API Demo components in the Oracle Unit Testing SQL module. 

The module 

    GitHub: https://github.com/BrenPatF/https://github.com/BrenPatF/

There are install scripts in the lib, hr and app schemas. Note that installation of this module is
dependent on pre-requisite installs of other modules as described in the README.

INSTALL SCRIPTS
====================================================================================================
|  Script                    |  Notes                                                              |
|==================================================================================================|
|  APP SCHEMA                                                                                      |
|--------------------------------------------------------------------------------------------------|
| *install_login_bursts.sql* |  Creates logins components in app schema                            |
====================================================================================================
This file has the install script for the 

Components created in app schema:

    Tables              Description
    ==================  ============================================================================
    logins              Logins

    Views               Description
    ==================  ============================================================================
    Match_Recognize_V   View for solution by Match_Recognize
    Model_V             View for solution by Model clause
    Recursive_SQF_V     View for solution by Recursive subquery factors
    Analytics_V         View for (incorrect) solution by analytic functions

    Packages            Description
    ==================  ============================================================================
    TT_Login_Bursts     Unit test wrapper functions for login bursts views

    Metadata            Description
    ==================  ============================================================================
    tt_units            Record for each test packaged procedure. The input JSON files must first be
                        placed in the OS folder pointed to by INPUT_DIR directory

***************************************************************************************************/

DROP TABLE logins
/
CREATE TABLE logins (
    personid        VARCHAR2(10),
    login_time      DATE 
)
/
@c_views

PROMPT Insert the example logins
DECLARE
    PROCEDURE add_Logins(
                p_personid       VARCHAR2,
                p_login_time     VARCHAR2) IS
    BEGIN

      INSERT INTO logins VALUES (p_personid, To_Date(p_login_time, 'DDMMYYYY HH24:MI'));

    END add_Logins;
BEGIN

  add_Logins('1', '01012021 00:00');
  add_Logins('1', '01012021 01:00');
  add_Logins('1', '01012021 01:59');
  add_Logins('1', '01012021 02:00');
  add_Logins('1', '01012021 02:39');
  add_Logins('1', '01012021 03:00');

  add_Logins('1', '01012021 04:59');
  add_Logins('2', '01012021 01:01');
  add_Logins('2', '01012021 01:30');
  add_Logins('2', '01012021 02:00');
  add_Logins('2', '01012021 05:00');
  add_Logins('2', '01012021 06:00');

END;
/
PROMPT Example data
BREAK ON personid
SELECT personid, To_Char(login_time, 'DDMMYYYY HH24:MI') login_time
  FROM logins
ORDER BY 1, 2
/
PROMPT Solution for example data
SELECT personid, block_start_login_time 
  FROM Model_V 
ORDER BY 1, 2
/
PROMPT Add the ut records
BEGIN
  Trapit.Add_Ttu('TT_LOGIN_BURSTS',    'Purely_Wrap_View_MRE',  'UT_EXAMPLES', 'Y', 'login_bursts.json', 'Login Bursts - Match_Recognize');
  Trapit.Add_Ttu('TT_LOGIN_BURSTS',    'Purely_Wrap_View_MOD',  'UT_EXAMPLES', 'Y', 'login_bursts.json', 'Login Bursts - Model');
  Trapit.Add_Ttu('TT_LOGIN_BURSTS',    'Purely_Wrap_View_RSF',  'UT_EXAMPLES', 'Y', 'login_bursts.json', 'Login Bursts - Recursive');
  Trapit.Add_Ttu('TT_LOGIN_BURSTS',    'Purely_Wrap_View_ANA',  'UT_EXAMPLES', 'Y', 'login_bursts.json', 'Login Bursts - Analytics');
END;
/

PROMPT Packages creation
PROMPT =================

PROMPT Create package TT_Login_Bursts
@tt_login_bursts.pks
@tt_login_bursts.pkb

@..\..\install_prereq\endspool